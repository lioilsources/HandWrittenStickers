import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/content_pack.dart';
import '../models/glyph_sheet.dart';
import '../models/preset.dart';
import 'purchases/purchase_backend.dart';
import 'purchases/store_purchase_backend.dart';

enum PurchaseOutcome { purchased, pending, cancelled, error, unavailable }

/// Which content packs the user owns, and buying more.
///
/// Every feature of the app is free except saving presets (the `presets`
/// pack); everything else that is paid is content (sheets, presets).
/// Owned packs are cached in `entitlements.json`, so an offline start
/// never locks what the user bought.
class EntitlementService extends ChangeNotifier {
  static const String cacheFile = 'entitlements.json';

  final PurchaseBackend _backend;
  final Future<Directory?> Function() _directory;
  PackIndex _packs = PackIndex.empty;

  /// Owned pack ids, as last confirmed by the store or the cache.
  final Set<String> _owned = {};
  final Map<String, StoreProduct> _products = {};
  final Map<String, Completer<PurchaseOutcome>> _waiting = {};
  StreamSubscription<PurchaseEvent>? _subscription;
  Directory? _dir;
  bool _storeAvailable = false;
  bool _productsLoaded = false;

  /// Cache writes, one after another.
  Future<void> _cacheWrites = Future.value();
  bool _initialized = false;

  EntitlementService({
    required PurchaseBackend backend,
    Future<Directory?> Function()? directory,
  }) : _backend = backend,
       _directory = directory ?? _defaultDirectory;

  static Future<Directory?> _defaultDirectory() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (_) {
      return null;
    }
  }

  static Future<Directory?> _noDirectory() async => null;

  /// Everything owned, never touching the disk or a store: tests of
  /// screens that are not about packs.
  factory EntitlementService.unlocked() => EntitlementService(
    backend: FakePurchaseBackend(),
    directory: _noDirectory,
  ).._unlockAll = true;

  /// Nothing owned, a fake store, no disk.
  factory EntitlementService.fake(
    FakePurchaseBackend backend, {
    Future<Directory?> Function()? directory,
  }) => EntitlementService(
    backend: backend,
    directory: directory ?? _noDirectory,
  );

  bool _unlockAll = false;

  /// `--dart-define=HWS_PACKS=…`: `all`, `none` or a comma list of pack
  /// ids. Debug builds then use a fake store with those packs owned, so
  /// the paywall can be tried without a sandbox account and screenshots
  /// can show unlocked content.
  static const String debugPacks = String.fromEnvironment('HWS_PACKS');

  /// The service the app uses: the real store on iOS, Android and macOS,
  /// everything unlocked under `flutter test` and on the other desktops
  /// (developer tools without a store), a fake store with [debugPacks].
  factory EntitlementService.forPlatform() {
    if (debugPacks.isNotEmpty) {
      final owned = debugPacks == 'none'
          ? <String>{}
          : {
              for (final id in debugPacks.split(','))
                'com.ol1n.handwrittenStickers.pack.${id.trim()}',
            };
      // No cache file: fake purchases must not survive into a real build.
      return EntitlementService.fake(
        FakePurchaseBackend(owned: owned, prices: fakePrices),
      );
    }
    final testing = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final hasStore =
        !kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isMacOS);
    if (testing || !hasStore) return EntitlementService.unlocked();
    return EntitlementService(backend: StorePurchaseBackend());
  }

  /// Prices of the fake store, close to the real ones.
  static const Map<String, String> fakePrices = {
    'com.ol1n.handwrittenStickers.pack.handwriting': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.calligraphy': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.poster': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.kids': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.materials': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.presets': '25 Kč',
    'com.ol1n.handwrittenStickers.pack.all': '99 Kč',
  };

  bool get isInitialized => _initialized;
  bool get storeAvailable => _storeAvailable;

  /// The store has answered which products exist (prices may still be
  /// missing for products not set up in the store yet).
  bool get productsLoaded => _productsLoaded;
  PackIndex get packs => _packs;
  Set<String> get ownedPacks => Set.unmodifiable(_owned);

  /// Reads the cache, starts listening to the store and fetches prices.
  /// Never throws; without a store the cached packs still apply.
  Future<void> initialize(PackIndex packs) async {
    _packs = packs;
    _dir = await _directory();
    await _readCache();
    _subscription ??= _backend.updates.listen(_onEvent);
    _initialized = true;
    notifyListeners();
    _storeAvailable = await _backend.isAvailable();
    if (_storeAvailable) {
      try {
        for (final p in await _backend.products(_packs.productIds)) {
          _products[p.id] = p;
        }
      } catch (e) {
        debugPrint('Entitlements: no prices ($e)');
      }
      _productsLoaded = true;
    }
    notifyListeners();
  }

  bool ownsPack(String? packId) {
    if (packId == null || _unlockAll) return true;
    if (_owned.contains(packId)) return true;
    final all = _packs.all;
    return all != null && _owned.contains(all.id);
  }

  bool canUseSheet(GlyphSheet sheet) => ownsPack(sheet.pack);

  bool canUsePreset(Preset preset) => ownsPack(preset.pack);

  /// Saving, overwriting and renaming the user's presets. Applying a
  /// saved preset is always allowed.
  bool get canSavePresets =>
      ownsPack(_packs.forFeature(ContentPack.savePresetsFeature)?.id);

  /// Localised store price, or null while unknown.
  String? price(String packId) {
    final pack = _packs.byId(packId);
    return pack == null ? null : _products[pack.productId]?.price;
  }

  /// Whether the bundle of all packs is still worth offering: the user
  /// owns at most one pack (from the second one it costs more than the
  /// remaining packs bought separately).
  bool get offerAll {
    final all = _packs.all;
    if (all == null || ownsPack(all.id)) return false;
    return _owned.length <= 1;
  }

  /// Buys [packId]; completes when the store answers.
  Future<PurchaseOutcome> buy(String packId) async {
    final pack = _packs.byId(packId);
    final product = pack == null ? null : _products[pack.productId];
    if (pack == null || product == null) return PurchaseOutcome.unavailable;
    if (ownsPack(packId)) return PurchaseOutcome.purchased;
    final waiting = _waiting[pack.productId] ??= Completer<PurchaseOutcome>();
    try {
      await _backend.buy(product);
    } catch (e) {
      debugPrint('Entitlements: buy failed ($e)');
      _finish(pack.productId, PurchaseOutcome.error);
    }
    final outcome = await waiting.future;
    await _cacheWrites;
    return outcome;
  }

  /// "Restore purchases" button. Apple requires it; never call it
  /// unprompted, it can ask for the Apple ID password.
  Future<void> restore() async {
    try {
      await _backend.restore();
    } catch (e) {
      debugPrint('Entitlements: restore failed ($e)');
    }
    await _cacheWrites;
  }

  void _onEvent(PurchaseEvent event) {
    final pack = _packs.byProduct(event.productId);
    switch (event.kind) {
      case PurchaseEventKind.owned:
        if (pack != null && _owned.add(pack.id)) {
          _cacheWrites = _cacheWrites.then((_) => _writeCache());
          notifyListeners();
        }
        _finish(event.productId, PurchaseOutcome.purchased);
      case PurchaseEventKind.pending:
        _finish(event.productId, PurchaseOutcome.pending);
      case PurchaseEventKind.cancelled:
        _finish(event.productId, PurchaseOutcome.cancelled);
      case PurchaseEventKind.error:
        debugPrint(
          'Entitlements: ${event.productId} failed (${event.message})',
        );
        _finish(event.productId, PurchaseOutcome.error);
    }
  }

  void _finish(String productId, PurchaseOutcome outcome) {
    final c = _waiting.remove(productId);
    if (c != null && !c.isCompleted) c.complete(outcome);
  }

  Future<void> _readCache() async {
    final dir = _dir;
    if (dir == null) return;
    try {
      final file = File('${dir.path}/$cacheFile');
      if (!await file.exists()) return;
      final data = json.decode(await file.readAsString());
      if (data is Map && data['packs'] is List) {
        _owned.addAll((data['packs'] as List).whereType<String>());
      }
    } catch (e) {
      debugPrint('Entitlements: ignoring unreadable cache ($e)');
    }
  }

  Future<void> _writeCache() async {
    final dir = _dir;
    if (dir == null) return;
    try {
      await dir.create(recursive: true);
      final tmp = File('${dir.path}/$cacheFile.tmp');
      await tmp.writeAsString(
        json.encode({
          'packs': _owned.toList()..sort(),
          'checkedAt': DateTime.now().toIso8601String(),
        }),
        flush: true,
      );
      await tmp.rename('${dir.path}/$cacheFile');
    } catch (e) {
      debugPrint('Entitlements: could not write cache ($e)');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _backend.dispose();
    super.dispose();
  }
}

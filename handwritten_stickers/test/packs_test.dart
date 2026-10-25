import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/content_pack.dart';
import 'package:handwritten_stickers/models/glyph_sheet.dart';
import 'package:handwritten_stickers/models/preset.dart';
import 'package:handwritten_stickers/services/entitlement_service.dart';
import 'package:handwritten_stickers/services/preset_store.dart';
import 'package:handwritten_stickers/services/purchases/purchase_backend.dart';

const _p = 'com.ol1n.handwrittenStickers.pack.';

/// Sheets anyone can use without buying. Changing this list is a product
/// decision, not a side effect of adding a sheet.
const _freeSheets = {
  'laurinka',
  'caveat',
  'patrick_hand',
  'indie_flower',
  'reenie_beanie',
  'jessie_1',
  'dancing_script',
  'pacifico',
  'great_vibes',
  'amatic_sc',
  'bebas_neue',
  'playfair_display',
  'kid_bubble_peach',
  'kid_dynapuff',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('pack data', () {
    late PackIndex packs;
    late GlyphSheetIndex release;
    late List<Preset> presets;

    setUpAll(() async {
      packs = await PackIndex.load();
      release = await GlyphSheetIndex.load(includeUnbundled: false);
      final data =
          json.decode(await rootBundle.loadString(PresetStore.builtInAssetPath))
              as Map<String, dynamic>;
      presets = [
        for (final e in data['presets'] as List)
          Preset.builtInFromJson(e as Map<String, dynamic>),
      ];
    });

    test('ids and products are unique and use the app prefix', () {
      expect(
        packs.packs.map((p) => p.id).toSet(),
        hasLength(packs.packs.length),
      );
      expect(packs.productIds, hasLength(packs.packs.length));
      for (final p in packs.packs) {
        expect(p.productId, '$_p${p.id}');
      }
      expect(packs.all, isNotNull);
      expect(packs.forFeature(ContentPack.savePresetsFeature)?.id, 'presets');
    });

    test('every pack a sheet or preset names exists', () async {
      final all = await GlyphSheetIndex.load(includeUnbundled: true);
      for (final s in all.sheets) {
        if (s.pack != null) {
          expect(packs.byId(s.pack), isNotNull, reason: s.id);
        }
      }
      for (final p in presets) {
        if (p.pack != null) {
          expect(packs.byId(p.pack), isNotNull, reason: p.id);
        }
      }
    });

    test('the free sheets are exactly the agreed ones', () {
      final free = {
        for (final s in release.sheets)
          if (s.isFree) s.id,
      };
      expect(free, _freeSheets);
    });

    test('every category but materials has a free sheet in release', () {
      final categories = {
        for (final s in release.sheets)
          if (s.category != SheetCategory.material) s.category,
      };
      for (final c in categories) {
        expect(
          release.sheets.any((s) => s.category == c && s.isFree),
          isTrue,
          reason: c.name,
        );
      }
    });

    test('every content pack has sheets and presets in release builds', () {
      for (final pack in packs.single) {
        if (pack.feature != null) continue;
        expect(
          release.sheets.where((s) => s.pack == pack.id),
          isNotEmpty,
          reason: pack.id,
        );
        expect(
          presets.where((p) => p.pack == pack.id),
          isNotEmpty,
          reason: pack.id,
        );
      }
    });

    test('a pack preset uses a free sheet or one of its own pack', () {
      for (final p in presets) {
        final sheet = release.byId(p.sheetId);
        expect(sheet, isNotNull, reason: '${p.id} needs a release sheet');
        expect(
          sheet!.pack == null || sheet.pack == p.pack,
          isTrue,
          reason: '${p.id} (${p.pack}) uses ${sheet.id} (${sheet.pack})',
        );
      }
    });

    test('a sheet without pack is free', () {
      final s = GlyphSheet.fromJson({'id': 'x', 'name': 'X', 'path': 'a/'});
      expect(s.pack, isNull);
      expect(s.isFree, isTrue);
    });
  });

  group('EntitlementService', () {
    late PackIndex packs;
    setUpAll(() async => packs = await PackIndex.load());

    FakePurchaseBackend store({Set<String>? owned}) => FakePurchaseBackend(
      prices: EntitlementService.fakePrices,
      owned: owned,
    );

    GlyphSheet sheet(String? pack) =>
        GlyphSheet(id: 's', name: 'S', path: 'p/', source: 'font', pack: pack);

    test('free content is always usable, packs only once bought', () async {
      final backend = store();
      final e = EntitlementService.fake(backend);
      await e.initialize(packs);
      expect(e.canUseSheet(sheet(null)), isTrue);
      expect(e.canUseSheet(sheet('kids')), isFalse);
      expect(e.canSavePresets, isFalse);
      expect(e.price('kids'), '25 Kč');

      expect(await e.buy('kids'), PurchaseOutcome.purchased);
      expect(backend.bought, ['${_p}kids']);
      expect(e.canUseSheet(sheet('kids')), isTrue);
      expect(e.canUseSheet(sheet('poster')), isFalse);
    });

    test('the bundle unlocks every pack and the preset feature', () async {
      final e = EntitlementService.fake(store());
      await e.initialize(packs);
      expect(await e.buy('all'), PurchaseOutcome.purchased);
      for (final p in packs.packs) {
        expect(e.ownsPack(p.id), isTrue, reason: p.id);
      }
      expect(e.canSavePresets, isTrue);
    });

    test('the bundle is offered until two packs are owned', () async {
      final e = EntitlementService.fake(store());
      await e.initialize(packs);
      expect(e.offerAll, isTrue);
      await e.buy('kids');
      expect(e.offerAll, isTrue);
      await e.buy('poster');
      expect(e.offerAll, isFalse);
    });

    test('cancelled, pending and failed purchases unlock nothing', () async {
      final backend = store();
      final e = EntitlementService.fake(backend);
      await e.initialize(packs);
      for (final (kind, outcome) in [
        (PurchaseEventKind.cancelled, PurchaseOutcome.cancelled),
        (PurchaseEventKind.pending, PurchaseOutcome.pending),
        (PurchaseEventKind.error, PurchaseOutcome.error),
      ]) {
        backend.nextOutcome = kind;
        expect(await e.buy('kids'), outcome);
        expect(e.ownsPack('kids'), isFalse);
      }
    });

    test('without the store nothing can be bought', () async {
      final e = EntitlementService.fake(
        FakePurchaseBackend(prices: EntitlementService.fakePrices)
          ..available = false,
      );
      await e.initialize(packs);
      expect(e.storeAvailable, isFalse);
      expect(e.price('kids'), isNull);
      expect(await e.buy('kids'), PurchaseOutcome.unavailable);
    });

    test('a product missing from the store cannot be bought', () async {
      final e = EntitlementService.fake(FakePurchaseBackend());
      await e.initialize(packs);
      expect(e.productsLoaded, isTrue);
      expect(e.price('kids'), isNull);
      expect(await e.buy('kids'), PurchaseOutcome.unavailable);
    });

    test('restore brings back what the store says is owned', () async {
      final backend = store(owned: {'${_p}calligraphy'});
      final e = EntitlementService.fake(backend);
      await e.initialize(packs);
      expect(e.ownsPack('calligraphy'), isFalse, reason: 'no silent restore');
      await e.restore();
      expect(backend.restoreCalls, 1);
      expect(e.ownsPack('calligraphy'), isTrue);
    });

    test('owned packs survive a restart offline', () async {
      final dir = Directory.systemTemp.createTempSync('entitlements');
      addTearDown(() => dir.deleteSync(recursive: true));
      final a = EntitlementService.fake(store(), directory: () async => dir);
      await a.initialize(packs);
      await a.buy('materials');

      final offline = EntitlementService.fake(
        FakePurchaseBackend()..available = false,
        directory: () async => dir,
      );
      await offline.initialize(packs);
      expect(offline.ownsPack('materials'), isTrue);
      expect(offline.ownsPack('kids'), isFalse);
    });

    test('unlocked owns everything', () async {
      final e = EntitlementService.unlocked();
      await e.initialize(packs);
      expect(e.ownsPack('kids'), isTrue);
      expect(e.canSavePresets, isTrue);
    });
  });
}

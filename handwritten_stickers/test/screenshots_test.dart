import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/l10n/l10n.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';
import 'package:handwritten_stickers/services/entitlement_service.dart';
import 'package:handwritten_stickers/services/purchases/purchase_backend.dart';

/// Renders the editor to PNGs so the app can be shown without a device
/// (store page, release notes):
///
///     SCREENSHOT_DIR=/path/to/out flutter test test/screenshots_test.dart
///     SCREENSHOT_LOCALE=en SCREENSHOT_DIR=... (default: cs)
///     SCREENSHOT_DEVICE=iphone69|play|ipad13 SCREENSHOT_DIR=...
///
/// Devices are the sizes the stores ask for, see [_devices].
///
/// Without SCREENSHOT_DIR the tests are skipped: the output depends on the
/// machine's Skia and fonts, so it is not something CI should compare.
///
/// Real fonts are loaded by hand (the test font draws every letter as a
/// box) and glyph images decode inside `runAsync`, where real time passes.
/// Logical size and pixel ratio per device.
const _devices = <String, (Size, double)>{
  // iPhone 6.3": 1206×2622.
  'iphone63': (Size(402, 874), 3),
  // iPhone 6.9", the size App Store Connect requires: 1320×2868.
  'iphone69': (Size(440, 956), 3),
  // 9:16 for Google Play (longer side at most twice the shorter) and the
  // 5.5" iPhone slot: 1242×2208.
  'play': (Size(414, 736), 3),
  // iPad 13": 2064×2752.
  'ipad13': (Size(1032, 1376), 2),
  // Google Play 7" and 10" tablets: 9:16, both sides at least 1080: 1800×3200.
  'play_tablet': (Size(900, 1600), 2),
};
final _device =
    _devices[Platform.environment['SCREENSHOT_DEVICE'] ?? 'iphone63']!;
final _screen = _device.$1;
final _pixelRatio = _device.$2;

final _outDir = Platform.environment['SCREENSHOT_DIR'];
final _english = Platform.environment['SCREENSHOT_LOCALE'] == 'en';
final _locale = Locale(_english ? 'en' : 'cs');

/// The Czech or the English variant of a text in the shots.
String _t(String cs, String en) => _english ? en : cs;

Future<void> _loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) {
    fail('no material_fonts in the SDK at ${dir.path}: run `flutter precache`');
  }
  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${dir.path}/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final file in dir.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.startsWith('Roboto-')) roboto.addFont(read(name));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

void main() {
  final boundary = GlobalKey();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (_outDir != null) await _loadRealFonts();
  });

  /// Lets sheets, glyphs and emoji finish loading and decoding.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      // The emoji badge animates forever, so pumpAndSettle never returns.
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Everything unlocked unless [entitlements] says otherwise.
  Future<void> open(
    WidgetTester tester, {
    EntitlementService? entitlements,
  }) async {
    tester.view.devicePixelRatio = _pixelRatio;
    tester.view.physicalSize = _screen * _pixelRatio;
    addTearDown(tester.view.reset);
    WidgetsApp.debugAllowBannerOverride = false;
    addTearDown(() => WidgetsApp.debugAllowBannerOverride = true);
    // A fresh editor for every shot.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            fontFamily: 'Roboto',
          ),
          home: CanvasEditorScreen(
            includeUnbundledSheets: false,
            entitlements: entitlements,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> pickSheet(WidgetTester tester, String name) async {
    final chip = find.widgetWithText(ChoiceChip, name);
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await settle(tester);
  }

  Future<void> pickEmoji(
    WidgetTester tester,
    String category,
    String id,
  ) async {
    await tester.tap(find.byTooltip(_t('Emoji ke zprávě', 'Emoji tag')));
    await settle(tester);
    final chip = find.byKey(ValueKey('emoji-cat-$category'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await settle(tester);
    final tile = find.byKey(ValueKey('emoji-$id'));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await settle(tester);
  }

  Future<void> write(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await settle(tester);
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    await settle(tester);
    await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: _pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$_outDir/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  // One test for all shots: asset futures cached by the first test never
  // complete in the zone of a later one, which leaves the editor loading.
  testWidgets('screenshots', skip: _outDir == null, (tester) async {
    // Bubble letters with an emoji tag.
    await open(tester);
    await pickSheet(tester, _t('Bublinky broskev', 'Bubbles Peach'));
    await write(tester, _t('Ahoj maminko', 'Hi mummy'));
    await pickEmoji(tester, 'animals', 'animal_cat');
    await shoot(tester, 'stickers_1_bublinky');

    // A scanned child handwriting (the default sheet).
    await open(tester);
    await write(tester, _t('Mám tě ráda, babičko.', 'I love you, grandma.'));
    await shoot(tester, 'stickers_2_rukopis');

    // Calligraphy.
    await open(tester);
    await pickSheet(tester, 'Great Vibes');
    await write(tester, _t('Všechno nejlepší!', 'Happy birthday!'));
    await pickEmoji(tester, 'celebration', 'party_cake');
    await shoot(tester, 'stickers_3_kaligrafie');

    // Emoji picker.
    await open(tester);
    await pickSheet(tester, _t('Bublinky máta', 'Bubbles Mint'));
    await write(tester, _t('Dobrou noc', 'Good night'));
    await tester.tap(find.byTooltip(_t('Emoji ke zprávě', 'Emoji tag')));
    await shoot(tester, 'stickers_4_emoji');
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);

    // Style settings.
    await open(tester);
    await pickSheet(tester, 'Caveat');
    await write(tester, _t('Díky za všechno', 'Thanks for everything'));
    await tester.tap(find.text(_t('Rychlý vzkaz', 'Quick note')));
    await settle(tester);
    await settle(tester);
    await tester.tap(find.text(_t('Pokročilé nastavení', 'Advanced Settings')));
    await shoot(tester, 'stickers_5_styl');

    // Content packs, nothing bought yet.
    await open(
      tester,
      entitlements: EntitlementService.fake(
        FakePurchaseBackend(
          prices: {
            for (final e in EntitlementService.fakePrices.entries)
              e.key: _t(e.value, e.key.endsWith('.all') ? r'$3.99' : r'$0.99'),
          },
        ),
      ),
    );
    await tester.tap(find.byTooltip(_t('Balíčky', 'Packs')));
    for (var i = 0; i < 4; i++) {
      await settle(tester);
    }
    await shoot(tester, 'stickers_6_balicky');

    // Paywall of one pack.
    await tester.tap(find.byKey(const ValueKey('pack-calligraphy')));
    for (var i = 0; i < 4; i++) {
      await settle(tester);
    }
    await shoot(tester, 'stickers_7_paywall');
  });
}

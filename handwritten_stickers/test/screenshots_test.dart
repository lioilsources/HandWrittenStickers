import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';
import 'package:handwritten_stickers/services/entitlement_service.dart';
import 'package:handwritten_stickers/services/purchases/purchase_backend.dart';

/// Renders the editor to PNGs so the app can be shown without a device
/// (store page, release notes):
///
///     SCREENSHOT_DIR=/path/to/out flutter test test/screenshots_test.dart
///
/// Without SCREENSHOT_DIR the tests are skipped: the output depends on the
/// machine's Skia and fonts, so it is not something CI should compare.
///
/// Real fonts are loaded by hand (the test font draws every letter as a
/// box) and glyph images decode inside `runAsync`, where real time passes.
const _phone = Size(402, 874);
const _pixelRatio = 3.0;

final _outDir = Platform.environment['SCREENSHOT_DIR'];

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
    tester.view.physicalSize = _phone * _pixelRatio;
    addTearDown(tester.view.reset);
    WidgetsApp.debugAllowBannerOverride = false;
    addTearDown(() => WidgetsApp.debugAllowBannerOverride = true);
    // A fresh editor for every shot.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
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

  Future<void> pickEmoji(WidgetTester tester, String emoji) async {
    await tester.tap(find.byTooltip('Emoji ke zprávě'));
    await settle(tester);
    final tile = find.byKey(ValueKey('emoji-$emoji'));
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
    await pickSheet(tester, 'Bublinky broskev');
    await write(tester, 'Ahoj maminko');
    await pickEmoji(tester, '🐱');
    await shoot(tester, 'stickers_1_bublinky');

    // A scanned child handwriting (the default sheet).
    await open(tester);
    await write(tester, 'Mám tě ráda, babičko.');
    await shoot(tester, 'stickers_2_rukopis');

    // Calligraphy.
    await open(tester);
    await pickSheet(tester, 'Great Vibes');
    await write(tester, 'Všechno nejlepší!');
    await pickEmoji(tester, '🎂');
    await shoot(tester, 'stickers_3_kaligrafie');

    // Emoji picker.
    await open(tester);
    await pickSheet(tester, 'Bublinky máta');
    await write(tester, 'Dobrou noc');
    await tester.tap(find.byTooltip('Emoji ke zprávě'));
    await shoot(tester, 'stickers_4_emoji');
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);

    // Style settings.
    await open(tester);
    await pickSheet(tester, 'Caveat');
    await write(tester, 'Díky za všechno');
    await tester.tap(find.text('Rychlý vzkaz'));
    await settle(tester);
    await settle(tester);
    await tester.tap(find.text('Advanced Settings'));
    await shoot(tester, 'stickers_5_styl');

    // Content packs, nothing bought yet.
    await open(
      tester,
      entitlements: EntitlementService.fake(
        FakePurchaseBackend(prices: EntitlementService.fakePrices),
      ),
    );
    await tester.tap(find.byTooltip('Balíčky'));
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

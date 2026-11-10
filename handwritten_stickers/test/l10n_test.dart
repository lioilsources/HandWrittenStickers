import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/l10n/l10n.dart';
import 'package:handwritten_stickers/models/content_pack.dart';
import 'package:handwritten_stickers/models/glyph_sheet.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> arb(String locale) =>
      json.decode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

  Set<String> keys(Map<String, dynamic> arb) => {
    for (final k in arb.keys)
      if (!k.startsWith('@')) k,
  };

  test('Czech has every string English has', () {
    expect(keys(arb('cs')), keys(arb('en')));
  });

  test('Slovak devices get Czech, everyone else English', () {
    const supported = AppLocalizations.supportedLocales;
    expect(
      resolveAppLocale(const Locale('cs', 'CZ'), supported).languageCode,
      'cs',
    );
    expect(resolveAppLocale(const Locale('sk'), supported).languageCode, 'cs');
    expect(resolveAppLocale(const Locale('de'), supported).languageCode, 'en');
    expect(resolveAppLocale(null, supported).languageCode, 'en');
  });

  test('Czech counts use all three plural forms', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    expect(cs.sheetCount(1), '1 písmo');
    expect(cs.sheetCount(3), '3 písma');
    expect(cs.sheetCount(17), '17 písem');
    expect(
      lookupAppLocalizations(const Locale('en')).sheetCount(17),
      '17 fonts',
    );
  });

  test('sheets and packs are named in the requested language', () async {
    addTearDown(rootBundle.clear);
    final cs = await GlyphSheetIndex.load(includeUnbundled: true);
    final en = await GlyphSheetIndex.load(
      includeUnbundled: true,
      language: 'en',
    );
    expect(cs.byId('kid_bubble_peach')!.name, 'Bublinky broskev');
    expect(en.byId('kid_bubble_peach')!.name, 'Bubbles Peach');
    expect(en.byId('mat_gingerbread')!.name, 'Gingerbread');
    // Font names are the same everywhere.
    expect(en.byId('caveat')!.name, cs.byId('caveat')!.name);

    final packs = await PackIndex.load(language: 'en');
    expect(packs.byId('kids')!.name, isNot('Pro děti'));
    expect(packs.byId('calligraphy')!.sampleText, 'Happy birthday!');
    expect(
      (await PackIndex.load()).byId('calligraphy')!.sampleText,
      'Všechno nejlepší!',
    );
  });

  testWidgets('the editor follows the locale', (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(402, 1400) * 3;
    addTearDown(tester.view.reset);
    addTearDown(rootBundle.clear);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: CanvasEditorScreen(),
      ),
    );
    for (var i = 0; i < 100 && find.byType(TextField).evaluate().isEmpty; i++) {
      for (var j = 0; j < 10; j++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
    }
    expect(find.byTooltip('Save to Gallery'), findsOneWidget);
    expect(find.byTooltip('Packs'), findsOneWidget);
    // Category row, built-in preset and sheet name, all in English.
    expect(find.text('Kids'), findsOneWidget);
    expect(find.text('Quick note'), findsOneWidget);
    expect(find.text('Bubbles Peach'), findsOneWidget);
    expect(find.text('Rychlý vzkaz'), findsNothing);
  });
}

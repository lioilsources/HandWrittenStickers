import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/glyph_sheet.dart';
import 'package:handwritten_stickers/services/glyph_loader.dart';

/// Characters every bundled sheet must be able to render.
const _czechSample =
    'Příliš žluťoučký kůň úpěl ďábelské ódy. '
    'PŘÍLIŠ ŽLUŤOUČKÝ KŮŇ ÚPĚL ĎÁBELSKÉ ÓDY! 0123456789,?:-()';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sheets.json lists a default sheet', () async {
    final index = await GlyphSheetIndex.load();
    expect(index.sheets, isNotEmpty);
    expect(index.byId(index.defaultId), isNotNull);
    expect(
      index.sheets.map((s) => s.id).toSet().length,
      index.sheets.length,
      reason: 'sheet ids must be unique',
    );
  });

  test(
    'every bundled sheet has a manifest whose PNGs are all bundled',
    () async {
      final index = await GlyphSheetIndex.load();
      for (final sheet in index.sheets) {
        final manifestJson = await rootBundle.loadString(
          '${sheet.path}glyphs.json',
        );
        final Map<String, dynamic> manifest = json.decode(manifestJson);
        final glyphs = Map<String, String>.from(manifest['glyphs'] as Map);
        expect(
          glyphs.length,
          greaterThanOrEqualTo(150),
          reason: '${sheet.id} should cover the 160-character template',
        );

        for (final entry in glyphs.entries) {
          final data = await rootBundle.load('${sheet.path}${entry.value}');
          expect(
            data.lengthInBytes,
            greaterThan(0),
            reason: '${sheet.id}/${entry.value} for "${entry.key}" is empty',
          );
        }

        for (final rune in _czechSample.runes) {
          final ch = String.fromCharCode(rune);
          if (ch == ' ') continue;
          expect(
            glyphs.containsKey(ch),
            isTrue,
            reason: '${sheet.id} is missing "$ch"',
          );
        }
      }
    },
  );

  test('font sheets expose metrics and decode a glyph', () async {
    final index = await GlyphSheetIndex.load();
    for (final sheet in index.sheets.where((s) => !s.isHandwriting)) {
      final loader = GlyphLoader(sheetPath: sheet.path);
      await loader.initialize();
      expect(loader.hasMetrics, isTrue, reason: '${sheet.id} has no metrics');
      final glyph = await loader.getGlyph('ř');
      expect(glyph, isNotNull, reason: '${sheet.id} cannot load ř');
      expect(glyph!.metrics, isNotNull);
      expect(glyph.metrics!.advance, greaterThan(0));
      expect(glyph.metrics!.baseline, greaterThan(0));
    }
  });

  test('handwriting sheet still loads without metrics', () async {
    final loader = GlyphLoader(sheetPath: GlyphLoader.defaultSheetPath);
    await loader.initialize();
    final glyph = await loader.getGlyph('A');
    expect(glyph, isNotNull);
    expect(glyph!.hasMetrics, isFalse);
  });
}

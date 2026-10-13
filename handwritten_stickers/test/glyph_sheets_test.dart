import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/glyph_sheet.dart';
import 'package:handwritten_stickers/services/glyph_loader.dart';

/// Manifest `glyphs` values are a file name (v1/v2) or a list of variant
/// file names (v3).
List<String> _files(Object? value) =>
    value is List ? List<String>.from(value) : [value as String];

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
      final manifests = <String, Map<String, dynamic>>{};
      for (final sheet in index.sheets) {
        manifests[sheet.id] = json.decode(
          await rootBundle.loadString('${sheet.path}glyphs.json'),
        );
      }
      for (final sheet in index.sheets) {
        // Yield to the event loop: thousands of back-to-back asset loads
        // without a real async gap overflow the test zone's stack.
        await Future<void>.delayed(Duration.zero);
        final manifest = manifests[sheet.id]!;
        final glyphs = (manifest['glyphs'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, _files(v)),
        );
        final compose = (manifest['compose'] as Map<String, dynamic>?) ?? {};
        final fallbackId = manifest['fallback'] as String?;
        final fallback = fallbackId == null ? null : manifests[fallbackId];
        if (fallbackId != null) {
          expect(
            fallback,
            isNotNull,
            reason: '${sheet.id} falls back to unknown sheet $fallbackId',
          );
        }
        final fallbackGlyphs =
            (fallback?['glyphs'] as Map<String, dynamic>?) ?? {};

        bool renders(String ch) =>
            glyphs.containsKey(ch) ||
            compose.containsKey(ch) ||
            fallbackGlyphs.containsKey(ch);

        final covered = {
          ...glyphs.keys,
          ...compose.keys,
          ...fallbackGlyphs.keys,
        };
        expect(
          covered.length,
          greaterThanOrEqualTo(150),
          reason:
              '${sheet.id} should cover the 160-character template '
              '(own glyphs, compose rules and fallback sheet)',
        );

        for (final entry in glyphs.entries) {
          for (final file in entry.value) {
            final data = await rootBundle.load('${sheet.path}$file');
            expect(
              data.lengthInBytes,
              greaterThan(0),
              reason: '${sheet.id}/$file for "${entry.key}" is empty',
            );
          }
        }

        for (final parts in compose.values) {
          for (final part in parts as List) {
            expect(
              glyphs.containsKey(part),
              isTrue,
              reason: '${sheet.id} composes from missing glyph "$part"',
            );
          }
        }

        for (final rune in _czechSample.runes) {
          final ch = String.fromCharCode(rune);
          if (ch == ' ') continue;
          expect(renders(ch), isTrue, reason: '${sheet.id} is missing "$ch"');
        }
      }
    },
    // Loads every PNG of every sheet (100+ sheets × 160 glyphs).
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'sheets with manifest v2+ have metrics for every glyph variant',
    () async {
      final index = await GlyphSheetIndex.load();
      for (final sheet in index.sheets) {
        final Map<String, dynamic> manifest = json.decode(
          await rootBundle.loadString('${sheet.path}glyphs.json'),
        );
        // v1 = untrimmed cell scans without metrics (laid out cell by cell).
        // Regenerate them with `glyph_extractor extract/upgrade` (plan A1).
        if ((manifest['version'] as num) < 2) continue;
        final glyphs = manifest['glyphs'] as Map<String, dynamic>;
        final metrics = manifest['metrics'] as Map<String, dynamic>;
        for (final entry in glyphs.entries) {
          final m = metrics[entry.key];
          expect(m, isNotNull, reason: '${sheet.id} "${entry.key}" no metrics');
          final count = m is List ? m.length : 1;
          expect(
            count,
            _files(entry.value).length,
            reason: '${sheet.id} "${entry.key}" variants/metrics mismatch',
          );
        }
      }
    },
  );

  test('join points of joined sheets lie inside their glyph image', () async {
    final index = await GlyphSheetIndex.load();
    var joined = 0;
    for (final sheet in index.sheets) {
      final Map<String, dynamic> manifest = json.decode(
        await rootBundle.loadString('${sheet.path}glyphs.json'),
      );
      final metrics = manifest['metrics'] as Map<String, dynamic>?;
      if (manifest['strokeWidth'] == null || metrics == null) continue;
      joined++;
      expect(manifest['xHeight'], greaterThan(0), reason: sheet.id);
      var points = 0;
      for (final entry in metrics.entries) {
        for (final m in entry.value is List ? entry.value : [entry.value]) {
          for (final key in ['entry', 'exit']) {
            final p = m[key] as List?;
            if (p == null) continue;
            points++;
            expect(
              p[0] >= 0 && p[0] <= m['w'] && p[1] >= 0 && p[1] <= m['h'],
              isTrue,
              reason: '${sheet.id} "${entry.key}" $key $p outside its image',
            );
          }
        }
      }
      expect(points, greaterThan(50), reason: '${sheet.id} has few joins');
    }
    expect(joined, greaterThan(0), reason: 'no bundled sheet joins letters');
  });

  test('glyph file names are unique ignoring case', () async {
    // iOS and macOS builds run on case-insensitive volumes, where "A.png"
    // and "a.png" are one file and one of the two letters goes missing.
    final index = await GlyphSheetIndex.load();
    for (final sheet in index.sheets) {
      final Map<String, dynamic> manifest = json.decode(
        await rootBundle.loadString('${sheet.path}glyphs.json'),
      );
      final seen = <String, String>{};
      for (final entry
          in (manifest['glyphs'] as Map<String, dynamic>).entries) {
        for (final file in _files(entry.value)) {
          final other = seen[file.toLowerCase()];
          expect(
            other,
            isNull,
            reason: '${sheet.id}: "$file" and "$other" differ only by case',
          );
          seen[file.toLowerCase()] = file;
        }
      }
    }
  });

  test('release builds hide sheets marked "bundle": false', () async {
    final all = await GlyphSheetIndex.load(includeUnbundled: true);
    final release = await GlyphSheetIndex.load(includeUnbundled: false);
    expect(release.sheets.where((s) => !s.bundle), isEmpty);
    expect(release.sheets.length, all.sheets.where((s) => s.bundle).length);
    expect(
      release.byId(release.defaultId)?.bundle,
      isTrue,
      reason: 'the default sheet must be part of release builds',
    );
  });

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

  test('handwriting sheet loads with or without metrics', () async {
    final loader = GlyphLoader(sheetPath: GlyphLoader.defaultSheetPath);
    await loader.initialize();
    final glyph = await loader.getGlyph('A');
    expect(glyph, isNotNull);
    // v1 cell scans have no metrics, sheets from `extract` (v2+) have them.
    expect(glyph!.hasMetrics, loader.hasMetrics);
  });
}

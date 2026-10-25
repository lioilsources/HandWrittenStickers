import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/glyph_sheet.dart';
import 'package:handwritten_stickers/models/preset.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/services/preset_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StyleParams JSON', () {
    test('round-trips every field, colour included', () {
      const style = StyleParams(
        letterSpacing: 3.5,
        wordSpacing: 1.4,
        lineHeight: 1.6,
        baselineWobble: 0.25,
        sizeVariance: 0.12,
        rotationVariance: 0.33,
        opacityVariance: 0.07,
        inkColor: Color(0xFF1A2B3C),
        joinLetters: false,
        fontScale: 1.5,
        transparentBackground: false,
      );
      final decoded = StyleParams.fromJson(
        json.decode(json.encode(style.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, style);
      expect(style.toJson()['inkColor'], '#1a2b3c');
    });

    test('missing, malformed and unknown keys fall back to defaults', () {
      expect(StyleParams.fromJson({}), const StyleParams());
      expect(
        StyleParams.fromJson({
          'letterSpacing': 'wide',
          'inkColor': '#12',
          'futureKnob': 3,
          'lineHeight': 2,
        }),
        const StyleParams(lineHeight: 2),
      );
    });
  });

  group('PresetStore', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('presets_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    PresetStore store() => PresetStore(directory: () async => dir);

    test('saves, reloads, renames, overwrites and deletes', () async {
      final a = store();
      await a.load();
      expect(a.userPresets, isEmpty);
      final saved = await a.add(
        name: '  Můj styl ',
        sheetId: 'caveat',
        style: StyleParams.neat(),
      );
      expect(saved.name, 'Můj styl');
      expect(saved.id, startsWith('user:'));

      final b = store();
      await b.load();
      expect(b.userPresets.single.name, 'Můj styl');
      expect(b.userPresets.single.matches('caveat', StyleParams.neat()), true);

      await b.update(saved.id, name: 'Jiný');
      await b.update(saved.id, sheetId: 'kalam', style: StyleParams.fast());
      final c = store();
      await c.load();
      expect(c.userPresets.single.name, 'Jiný');
      expect(c.userPresets.single.matches('kalam', StyleParams.fast()), true);

      await c.delete(saved.id);
      final d = store();
      await d.load();
      expect(d.userPresets, isEmpty);
    });

    test('built-in presets cannot be changed through the store', () async {
      final s = store();
      await s.load();
      final builtIn = s.builtIns.first;
      expect(await s.update(builtIn.id, name: 'x'), isNull);
      await s.delete(builtIn.id);
      expect(s.builtIns.first.name, builtIn.name);
    });

    test('remembers the last editor state', () async {
      final a = store();
      await a.load();
      const state = EditorState(
        sheetId: 'kalam',
        style: StyleParams(baselineWobble: 0.9),
        presetId: 'builtin:casual',
      );
      await a.saveLastState(state);
      final b = store();
      await b.load();
      expect(b.lastState, state);
    });

    test('a corrupt file loads as empty instead of failing', () async {
      File('${dir.path}/${PresetStore.presetsFile}').writeAsStringSync('{');
      File(
        '${dir.path}/${PresetStore.editorStateFile}',
      ).writeAsStringSync('[1, 2]');
      final s = store();
      await s.load();
      expect(s.userPresets, isEmpty);
      expect(s.lastState, isNull);
      expect(s.builtIns, isNotEmpty);
      // And it can be written again.
      await s.add(name: 'Nový', sheetId: 'caveat', style: const StyleParams());
      final again = store();
      await again.load();
      expect(again.userPresets, hasLength(1));
    });

    test('without a directory it works in memory', () async {
      final s = PresetStore.inMemory();
      await s.load();
      await s.add(name: 'A', sheetId: 'caveat', style: const StyleParams());
      expect(s.userPresets, hasLength(1));
    });
  });

  test('every built-in preset uses a sheet from sheets.json', () async {
    final index = await GlyphSheetIndex.load(includeUnbundled: true);
    final data =
        json.decode(await rootBundle.loadString(PresetStore.builtInAssetPath))
            as Map<String, dynamic>;
    final presets = [
      for (final e in data['presets'] as List)
        Preset.builtInFromJson(e as Map<String, dynamic>),
    ];
    expect(presets, isNotEmpty);
    expect(presets.map((p) => p.id).toSet(), hasLength(presets.length));
    for (final p in presets) {
      expect(p.id, startsWith('builtin:'));
      expect(index.byId(p.sheetId), isNotNull, reason: '${p.id}: ${p.sheetId}');
    }
    // The free ones are the old Neat / Casual / Fast / Chaotic styles.
    expect(
      presets.firstWhere((p) => p.id == 'builtin:neat').style,
      StyleParams.neat().copyWith(),
    );
  });
}

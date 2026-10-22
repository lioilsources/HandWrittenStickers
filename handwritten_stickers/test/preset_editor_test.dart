import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/preset.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';
import 'package:handwritten_stickers/services/preset_store.dart';
import 'package:handwritten_stickers/widgets/handwritten_canvas.dart';
import 'package:handwritten_stickers/widgets/sheet_selector.dart';

void main() {
  /// Sheets and glyph images load from real assets, in real time.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  Future<PresetStore> open(WidgetTester tester, {PresetStore? store}) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(402, 1400) * 3;
    addTearDown(tester.view.reset);
    // rootBundle caches futures created in this test's fake-async zone;
    // awaited from the next test they never complete.
    addTearDown(rootBundle.clear);
    final presets = store ?? PresetStore.inMemory();
    await tester.pumpWidget(
      MaterialApp(home: CanvasEditorScreen(presetStore: presets)),
    );
    for (var i = 0; i < 100 && find.byType(TextField).evaluate().isEmpty; i++) {
      await settle(tester);
    }
    await tester.enterText(find.byType(TextField), 'Ahoj');
    await settle(tester);
    return presets;
  }

  String selectedSheet(WidgetTester tester) =>
      tester.widget<SheetSelector>(find.byType(SheetSelector)).selected.id;

  Future<void> tapPreset(WidgetTester tester, String id) async {
    final chip = find.byKey(ValueKey('preset-$id'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await settle(tester);
  }

  testWidgets('applying a preset switches sheet and style, keeps the text', (
    tester,
  ) async {
    final store = await open(tester);
    final before = tester
        .widget<HandwrittenCanvas>(find.byType(HandwrittenCanvas))
        .glyphs;

    final casual = store.byId('builtin:casual')!;
    await tapPreset(tester, casual.id);
    expect(selectedSheet(tester), casual.sheetId);
    final canvas = tester.widget<HandwrittenCanvas>(
      find.byType(HandwrittenCanvas),
    );
    expect(canvas.style, casual.style);
    expect(canvas.glyphs, hasLength(4));
    expect(canvas.glyphs, isNot(equals(before)));
    expect(find.byKey(const ValueKey('preset-modified')), findsNothing);
    expect(store.lastState, isNull, reason: 'saved after 500 ms');
    await tester.pump(const Duration(milliseconds: 600));
    expect(store.lastState?.presetId, casual.id);
  });

  testWidgets('save current look, apply it later, delete it', (tester) async {
    final store = await open(tester);
    await tapPreset(tester, 'builtin:neat');

    final save = find.byKey(const ValueKey('preset-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('preset-name')), 'Můj');
    await tester.tap(find.byKey(const ValueKey('preset-name-ok')));
    await tester.pumpAndSettle();
    await settle(tester);

    final mine = store.userPresets.single;
    expect(mine.name, 'Můj');
    expect(mine.sheetId, store.byId('builtin:neat')!.sheetId);
    expect(find.text('Můj'), findsOneWidget);

    // Switch away, then back to the saved preset.
    await tapPreset(tester, 'builtin:chaotic');
    expect(selectedSheet(tester), isNot(mine.sheetId));
    await tapPreset(tester, mine.id);
    expect(selectedSheet(tester), mine.sheetId);
    expect(
      tester.widget<HandwrittenCanvas>(find.byType(HandwrittenCanvas)).style,
      mine.style,
    );

    // Long press → delete → confirm.
    await tester.longPress(find.byKey(ValueKey('preset-${mine.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smazat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preset-delete-ok')));
    await tester.pumpAndSettle();
    await settle(tester);
    expect(store.userPresets, isEmpty);
    expect(find.text('Můj'), findsNothing);
  });

  testWidgets('changing a slider marks the preset as modified', (tester) async {
    await open(tester);
    await tapPreset(tester, 'builtin:neat');
    final advanced = find.text('Advanced Settings');
    await tester.ensureVisible(advanced);
    await tester.tap(advanced);
    await settle(tester);
    final slider = find.byType(Slider).first;
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(60, 0));
    await settle(tester);
    expect(find.byKey(const ValueKey('preset-modified')), findsOneWidget);
  });

  testWidgets('restores the last state on start', (tester) async {
    final store = PresetStore.inMemory();
    await store.load();
    final fast = store.byId('builtin:fast')!;
    await store.saveLastState(
      EditorState(sheetId: fast.sheetId, style: fast.style, presetId: fast.id),
    );
    await open(tester, store: store);
    expect(selectedSheet(tester), fast.sheetId);
    expect(
      tester.widget<HandwrittenCanvas>(find.byType(HandwrittenCanvas)).style,
      fast.style,
    );
  });

  testWidgets('a preset whose sheet is missing falls back to the default', (
    tester,
  ) async {
    final store = PresetStore.inMemory();
    await store.load();
    final ghost = await store.add(
      name: 'Duch',
      sheetId: 'no_such_sheet',
      style: const StyleParams(),
    );
    await open(tester, store: store);
    await tapPreset(tester, ghost.id);
    expect(find.textContaining('není k dispozici'), findsOneWidget);
  });
}

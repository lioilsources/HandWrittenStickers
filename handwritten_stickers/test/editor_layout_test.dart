import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';
import 'package:handwritten_stickers/widgets/handwritten_canvas.dart';

void main() {
  testWidgets('phone with the keyboard up still shows preview and text field', (
    tester,
  ) async {
    // iPhone-sized screen with the software keyboard open.
    const screen = Size(390, 844);
    const keyboard = 336.0;
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = screen * 3;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard * 3);
    addTearDown(tester.view.reset);

    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: const MaterialApp(home: CanvasEditorScreen()),
      ),
    );
    // Sheets and glyph images load from real assets.
    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
    }

    await settle();
    await tester.enterText(find.byType(TextField), 'Ahoj maminko.');
    await settle();

    final visibleBottom = screen.height - keyboard;
    final canvas = tester.getRect(find.byType(HandwrittenCanvas));
    final field = tester.getRect(find.byType(TextField));
    // The text is scaled up to the preview box, not drawn at layout size.
    expect(canvas.height, greaterThan(60));
    expect(canvas.bottom, lessThanOrEqualTo(field.top));
    expect(field.bottom, lessThanOrEqualTo(visibleBottom));

    final out = Platform.environment['EDITOR_LAYOUT_PNG'];
    if (out != null) {
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File(out).writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
  });
}

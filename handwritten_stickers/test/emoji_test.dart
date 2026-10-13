import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/emoji_tag.dart';
import 'package:handwritten_stickers/models/glyph.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/services/image_exporter.dart';
import 'package:image/image.dart' as img;

Future<ui.Image> _block(int w, int h) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = Colors.black,
  );
  return recorder.endRecording().toImage(w, h);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emoji index lists stickers that exist and decode', () async {
    final index = await EmojiIndex.load();
    expect(index.tags.length, greaterThanOrEqualTo(20));
    expect(index.tags.map((t) => t.emoji).toSet().length, index.tags.length);
    for (final tag in index.tags) {
      final data = await rootBundle.load(tag.asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(64), reason: tag.asset);
      expect(tag.name, isNotEmpty);
    }
  });

  test('emoji motion loops seamlessly and rests at phase 0', () {
    final a = EmojiMotion.at(0);
    final b = EmojiMotion.at(1);
    expect(a.lift, closeTo(0, 1e-12));
    expect(a.scale, closeTo(1, 1e-12));
    expect(a.angle, closeTo(0, 1e-12));
    expect(b.lift, closeTo(a.lift, 1e-9));
    expect(b.scale, closeTo(a.scale, 1e-9));
    expect(b.angle, closeTo(a.angle, 1e-9));
    // It actually moves mid-loop.
    expect(EmojiMotion.at(0.5).scale, greaterThan(1.05));
    expect(EmojiMotion.at(0.25).angle, greaterThan(0.05));
  });

  test('a tagged message exports as a looping GIF with the badge', () async {
    final index = await EmojiIndex.load();
    final glyph = Glyph(
      char: 'A',
      image: await _block(40, 60),
      width: 40,
      height: 60,
    );
    final glyphs = [
      PositionedGlyph(glyph: glyph, params: const GlyphParams(), x: 0, y: 0),
      PositionedGlyph(glyph: glyph, params: const GlyphParams(), x: 50, y: 0),
    ];
    final layout = StickerLayout.of(glyphs, withEmoji: true);
    expect(layout.badge, greaterThanOrEqualTo(44));
    expect(layout.width, greaterThan(90 + layout.badge));

    final gif = await ImageExporter.exportToGif(
      glyphs: glyphs,
      emoji: index.tags.first,
    );
    expect(gif, isNotNull);
    final decoded = img.decodeGif(gif!)!;
    expect(decoded.numFrames, EmojiMotion.gifFrames);
    final gifScale = ImageExporter.scaleFor(layout, ImageExporter.gifMaxSide);
    expect(decoded.width, closeTo(layout.width * gifScale, 2));
    // Messengers convert GIFs to video, which needs even dimensions.
    expect(decoded.width.isEven, isTrue);
    expect(decoded.height.isEven, isTrue);
    // One global colour table, no per-frame ones, frames left in place.
    expect(gif[10], 0xf7);
    expect(decoded.frames.last.getPixel(1, 1).r, greaterThan(250));
    // A short text is scaled up to a size messengers show at full width.
    expect(decoded.width, greaterThanOrEqualTo(900));

    // Untagged export stays a single PNG without the badge column.
    final png = await ImageExporter.exportToPng(
      glyphs: glyphs,
      style: const StyleParams(),
      backgroundColor: Colors.white,
    );
    final still = img.decodePng(png!)!;
    expect(
      still.width,
      ((90 + StickerLayout.padding * 2) * ImageExporter.maxScale).ceil(),
    );
  });
}

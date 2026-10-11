import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/emoji_tag.dart';
import '../models/glyph.dart';
import '../models/style_params.dart';

/// An exported sticker: PNG without an emoji tag, animated GIF with one.
class ExportedSticker {
  final Uint8List bytes;
  final String extension;

  const ExportedSticker(this.bytes, this.extension);

  bool get isAnimated => extension == 'gif';
}

/// Geometry of an exported sticker in layout units (before export scale).
class StickerLayout {
  static const double padding = 20.0;

  /// Size of the text block (glyph bounds).
  final Size text;

  /// Side of the emoji badge, 0 without one.
  final double badge;

  const StickerLayout(this.text, this.badge);

  /// The emoji sits right of the text, bottom-aligned with the last line.
  static const double _gap = 8.0;

  factory StickerLayout.of(List<PositionedGlyph> glyphs, {bool withEmoji = false}) {
    double maxX = 0;
    double maxY = 0;
    for (final pg in glyphs) {
      maxX = math.max(maxX, pg.x + pg.glyph.width * pg.params.scale);
      maxY = math.max(maxY, pg.y + pg.glyph.height * pg.params.scale);
    }
    // Big enough to read at a glance next to one line, never dwarfing text.
    final badge = withEmoji ? (maxY * 0.9).clamp(44.0, 120.0) : 0.0;
    return StickerLayout(Size(maxX, maxY), badge);
  }

  double get width =>
      text.width + padding * 2 + (badge > 0 ? _gap + badge : 0);

  double get height => math.max(text.height, badge) + padding * 2;

  /// Top-left of the badge box.
  Offset get badgeOrigin => Offset(
    padding + text.width + _gap,
    padding + math.max(text.height, badge) - badge,
  );
}

/// Service for exporting rendered handwritten text to images
class ImageExporter {
  /// Longest side of animated exports: GIFs get large fast, messengers
  /// show stickers small anyway.
  static const double gifMaxSide = 720;

  /// Export glyphs to PNG bytes (an emoji tag is drawn at rest).
  static Future<Uint8List?> exportToPng({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    Color? backgroundColor,
    double scale = 2.0,
    EmojiTag? emoji,
  }) async {
    if (glyphs.isEmpty) return null;
    final layout = StickerLayout.of(glyphs, withEmoji: emoji != null);
    final emojiImage = emoji == null ? null : await _loadImage(emoji.asset);
    final image = await renderFrame(
      glyphs: glyphs,
      layout: layout,
      scale: scale,
      backgroundColor: backgroundColor,
      emoji: emojiImage,
      phase: 0,
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  /// Export glyphs with an animated [emoji] as a looping GIF
  /// (one [EmojiMotion] loop, [EmojiMotion.gifFrames] frames).
  static Future<Uint8List?> exportToGif({
    required List<PositionedGlyph> glyphs,
    required EmojiTag emoji,
    Color backgroundColor = Colors.white,
    double maxScale = 2.0,
  }) async {
    if (glyphs.isEmpty) return null;
    final layout = StickerLayout.of(glyphs, withEmoji: true);
    final scale = math.min(
      maxScale,
      gifMaxSide / math.max(layout.width, layout.height),
    );
    final emojiImage = await _loadImage(emoji.asset);
    final frames = <Uint8List>[];
    int w = 0, h = 0;
    for (var i = 0; i < EmojiMotion.gifFrames; i++) {
      final frame = await renderFrame(
        glyphs: glyphs,
        layout: layout,
        scale: scale,
        backgroundColor: backgroundColor,
        emoji: emojiImage,
        phase: i / EmojiMotion.gifFrames,
      );
      w = frame.width;
      h = frame.height;
      final rgba = await frame.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
      frame.dispose();
      frames.add(rgba!.buffer.asUint8List());
    }
    emojiImage.dispose();
    final frameMs = EmojiMotion.period.inMilliseconds ~/ EmojiMotion.gifFrames;
    // Quantising 24 frames takes a while: keep it off the UI isolate.
    return compute(_encodeGif, _GifJob(w, h, frames, frameMs ~/ 10));
  }

  /// Draws one frame: background, glyphs, and the emoji at loop [phase].
  static Future<ui.Image> renderFrame({
    required List<PositionedGlyph> glyphs,
    required StickerLayout layout,
    required double scale,
    Color? backgroundColor,
    ui.Image? emoji,
    double phase = 0,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);

    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, layout.width, layout.height),
        Paint()..color = backgroundColor,
      );
    }

    canvas.save();
    canvas.translate(StickerLayout.padding, StickerLayout.padding);
    final paint = Paint()..filterQuality = FilterQuality.high;
    for (final pg in glyphs) {
      canvas.save();

      canvas.translate(pg.x, pg.y + pg.params.baselineOffset);

      if (pg.params.rotation != 0) {
        final centerX = pg.glyph.width * pg.params.scale / 2;
        final centerY = pg.glyph.height * pg.params.scale / 2;
        canvas.translate(centerX, centerY);
        canvas.rotate(pg.params.rotation * math.pi / 180);
        canvas.translate(-centerX, -centerY);
      }

      if (pg.params.scale != 1.0) {
        canvas.scale(pg.params.scale);
      }

      // Draw the glyph image (glyphs retain their original ink color from scan)
      canvas.drawImage(pg.glyph.image, Offset.zero, paint);

      canvas.restore();
    }
    canvas.restore();

    if (emoji != null && layout.badge > 0) {
      final m = EmojiMotion.at(phase);
      final b = layout.badge;
      final centre = layout.badgeOrigin + Offset(b / 2, b / 2 + b * m.lift);
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(m.angle);
      canvas.scale(m.scale);
      canvas.drawImageRect(
        emoji,
        Rect.fromLTWH(0, 0, emoji.width.toDouble(), emoji.height.toDouble()),
        Rect.fromCenter(center: Offset.zero, width: b, height: b),
        paint,
      );
      canvas.restore();
    }

    final picture = recorder.endRecording();
    return picture
        .toImage((layout.width * scale).ceil(), (layout.height * scale).ceil())
        .whenComplete(picture.dispose);
  }

  /// PNG without an emoji, animated GIF with one.
  static Future<ExportedSticker?> export({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    EmojiTag? emoji,
    bool transparent = false,
  }) async {
    if (emoji != null) {
      final gif = await exportToGif(glyphs: glyphs, emoji: emoji);
      return gif == null ? null : ExportedSticker(gif, 'gif');
    }
    final png = await exportToPng(
      glyphs: glyphs,
      style: style,
      backgroundColor: transparent ? null : Colors.white,
    );
    return png == null ? null : ExportedSticker(png, 'png');
  }

  static Future<File> _writeTemp(ExportedSticker sticker) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/handwritten_${DateTime.now().millisecondsSinceEpoch}.${sticker.extension}',
    );
    await file.writeAsBytes(sticker.bytes);
    return file;
  }

  /// Save image to gallery
  static Future<bool> saveToGallery({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    EmojiTag? emoji,
    bool transparent = false,
  }) async {
    final sticker = await export(
      glyphs: glyphs,
      style: style,
      emoji: emoji,
      transparent: transparent,
    );
    if (sticker == null) return false;

    try {
      final file = await _writeTemp(sticker);
      await Gal.putImage(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Share image
  static Future<void> shareImage({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    EmojiTag? emoji,
    bool transparent = false,
  }) async {
    final sticker = await export(
      glyphs: glyphs,
      style: style,
      emoji: emoji,
      transparent: transparent,
    );
    if (sticker == null) return;

    final file = await _writeTemp(sticker);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: sticker.isAnimated ? 'image/gif' : 'image/png')],
      text: 'Handwritten text',
    );
  }

  static Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }
}

class _GifJob {
  final int width;
  final int height;
  final List<Uint8List> frames;

  /// Frame duration in 1/100 s.
  final int delay;

  const _GifJob(this.width, this.height, this.frames, this.delay);
}

Uint8List _encodeGif(_GifJob job) {
  // No dithering: it sprinkles the white background with noise that
  // flickers from frame to frame.
  final encoder = img.GifEncoder(
    repeat: 0,
    delay: job.delay,
    samplingFactor: 4,
    dither: img.DitherKernel.none,
  );
  for (final rgba in job.frames) {
    encoder.addFrame(
      img.Image.fromBytes(
        width: job.width,
        height: job.height,
        bytes: rgba.buffer,
        numChannels: 4,
      ),
      duration: job.delay,
    );
  }
  return encoder.finish()!;
}

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
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
import 'glyph_painter.dart';

/// An exported sticker: PNG without an emoji tag, animated GIF with one.
class ExportedSticker {
  final Uint8List bytes;
  final String extension;

  const ExportedSticker(this.bytes, this.extension);

  bool get isAnimated => extension == 'gif';
}

/// Geometry of an exported sticker in layout units (before export scale).
class StickerLayout {
  static const double padding = 8.0;

  /// Size of the text block (glyph bounds).
  final Size text;

  /// Side of the emoji badge, 0 without one.
  final double badge;

  const StickerLayout(this.text, this.badge);

  /// The emoji sits right of the text, bottom-aligned with the last line.
  static const double _gap = 8.0;

  factory StickerLayout.of(
    List<PositionedGlyph> glyphs, {
    bool withEmoji = false,
  }) {
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

  double get width => text.width + padding * 2 + (badge > 0 ? _gap + badge : 0);

  double get height => math.max(text.height, badge) + padding * 2;

  /// Top-left of the badge box.
  Offset get badgeOrigin => Offset(
    padding + text.width + _gap,
    padding + math.max(text.height, badge) - badge,
  );
}

/// Service for exporting rendered handwritten text to images
class ImageExporter {
  /// Longest side of a still export in pixels. Messengers size an image by
  /// its pixels, so a short text exported at a fixed scale arrives tiny.
  static const double pngMaxSide = 1600;

  /// Longest side of animated exports: GIFs get large fast.
  static const double gifMaxSide = 960;

  /// Glyph sources are about 8× the layout height; past that the export
  /// only gets blurrier.
  static const double maxScale = 8.0;

  /// Export scale that brings the longest side of [layout] to [maxSide]
  /// pixels, capped at [maxScale].
  static double scaleFor(StickerLayout layout, double maxSide) =>
      math.min(maxScale, maxSide / math.max(layout.width, layout.height));

  /// Export glyphs to PNG bytes (an emoji tag is drawn at rest).
  static Future<Uint8List?> exportToPng({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    Color? backgroundColor,
    EmojiTag? emoji,
  }) async {
    if (glyphs.isEmpty) return null;
    final layout = StickerLayout.of(glyphs, withEmoji: emoji != null);
    final scale = scaleFor(layout, pngMaxSide);
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
  }) async {
    if (glyphs.isEmpty) return null;
    final layout = StickerLayout.of(glyphs, withEmoji: true);
    final scale = scaleFor(layout, gifMaxSide);
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
        evenSize: true,
      );
      w = frame.width;
      h = frame.height;
      final rgba = await frame.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      frame.dispose();
      frames.add(rgba!.buffer.asUint8List());
    }
    emojiImage.dispose();
    final frameMs = EmojiMotion.period.inMilliseconds ~/ EmojiMotion.gifFrames;
    // Quantising 24 frames takes a while: keep it off the UI isolate.
    return compute(_encodeGif, _GifJob(w, h, frames, frameMs ~/ 10));
  }

  /// Draws one frame: background, glyphs, and the emoji at loop [phase].
  /// [evenSize] rounds the pixel size up to even numbers: messengers turn
  /// GIFs into H.264 video, which cannot have an odd width or height.
  static Future<ui.Image> renderFrame({
    required List<PositionedGlyph> glyphs,
    required StickerLayout layout,
    required double scale,
    Color? backgroundColor,
    ui.Image? emoji,
    double phase = 0,
    bool evenSize = false,
  }) {
    var width = (layout.width * scale).ceil();
    var height = (layout.height * scale).ceil();
    if (evenSize) {
      width += width.isOdd ? 1 : 0;
      height += height.isOdd ? 1 : 0;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // The whole frame, including the pixels the size was rounded up by.
    if (backgroundColor != null) {
      canvas.drawColor(backgroundColor, BlendMode.src);
    }
    canvas.scale(scale);

    canvas.save();
    canvas.translate(StickerLayout.padding, StickerLayout.padding);
    paintGlyphs(canvas, glyphs, quality: FilterQuality.high);
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
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    }

    final picture = recorder.endRecording();
    return picture.toImage(width, height).whenComplete(picture.dispose);
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

  /// Share image. [origin] is the on-screen rect of the control that
  /// started the share: iOS anchors the share sheet to it and refuses to
  /// open the sheet without one.
  static Future<void> shareImage({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    EmojiTag? emoji,
    bool transparent = false,
    Rect? origin,
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
      // No caption: messengers would send it as a second message.
      [
        XFile(
          file.path,
          mimeType: sticker.isAnimated ? 'image/gif' : 'image/png',
        ),
      ],
      sharePositionOrigin: origin,
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
  img.Image frame(Uint8List rgba) => img.Image.fromBytes(
    width: job.width,
    height: job.height,
    bytes: rgba.buffer,
    numChannels: 4,
  );

  // One palette for the whole loop: every frame has the same colours, and
  // players that only read the global colour table show black otherwise.
  final palette = img.NeuralQuantizer(
    frame(job.frames.first),
    samplingFactor: 4,
  );
  // Frames are opaque and full size, so they are left in place (dispose 1)
  // rather than cleared to the background between frames.
  final encoder = img.GifEncoder(repeat: 0, delay: job.delay, dispose: 1);
  for (final rgba in job.frames) {
    // No dithering: it sprinkles the white background with noise that
    // flickers from frame to frame.
    encoder.addFrame(palette.getIndexImage(frame(rgba)), duration: job.delay);
  }
  return gifWithGlobalPalette(encoder.finish()!);
}

/// Rewrites a GIF whose frames all carry the same local colour table (what
/// `GifEncoder` writes) to declare it once as the global colour table.
/// Smaller, and readable by decoders that ignore local tables.
@visibleForTesting
Uint8List gifWithGlobalPalette(Uint8List gif) {
  const tableSize = 3 * 256;
  final out = BytesBuilder(copy: false);
  var pos = 13; // signature + logical screen descriptor
  var wroteHeader = false;

  // Copies a chain of data sub-blocks including its terminator.
  void copyBlocks() {
    final start = pos;
    while (gif[pos] != 0) {
      pos += gif[pos] + 1;
    }
    pos++;
    out.add(Uint8List.sublistView(gif, start, pos));
  }

  final pending = BytesBuilder(copy: false);
  while (pos < gif.length) {
    final type = gif[pos];
    if (type == 0x2c) {
      final packed = gif[pos + 9];
      if (packed != 0x87) {
        return gif; // not the layout we know how to rewrite
      }
      final table = Uint8List.sublistView(gif, pos + 10, pos + 10 + tableSize);
      if (!wroteHeader) {
        final header = Uint8List.fromList(gif.sublist(0, 13));
        header[10] = 0xf7; // global table, 8 bits per channel, 256 entries
        out.add(header);
        out.add(table);
        out.add(pending.takeBytes());
        wroteHeader = true;
      }
      final descriptor = Uint8List.fromList(gif.sublist(pos, pos + 10));
      descriptor[9] = 0; // no local table
      out.add(descriptor);
      pos += 10 + tableSize;
      out.addByte(gif[pos++]); // LZW minimum code size
      copyBlocks();
    } else if (type == 0x21) {
      final target = wroteHeader ? out : pending;
      final start = pos;
      pos += 2;
      while (gif[pos] != 0) {
        pos += gif[pos] + 1;
      }
      pos++;
      target.add(Uint8List.sublistView(gif, start, pos));
    } else {
      out.addByte(type); // trailer
      pos++;
    }
  }
  return wroteHeader ? out.toBytes() : gif;
}

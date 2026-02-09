import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/glyph.dart';
import '../models/style_params.dart';

/// Service for exporting rendered handwritten text to images
class ImageExporter {
  /// Export glyphs to PNG bytes
  static Future<Uint8List?> exportToPng({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    Color? backgroundColor,
    double scale = 2.0,
  }) async {
    if (glyphs.isEmpty) return null;

    // Calculate bounds
    double maxX = 0;
    double maxY = 0;
    for (final pg in glyphs) {
      final right = pg.x + pg.glyph.width * pg.params.scale;
      final bottom = pg.y + pg.glyph.height * pg.params.scale;
      if (right > maxX) maxX = right;
      if (bottom > maxY) maxY = bottom;
    }

    // Add padding
    const padding = 20.0;
    final width = (maxX + padding * 2) * scale;
    final height = (maxY + padding * 2) * scale;

    // Create picture recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scale for high resolution
    canvas.scale(scale);

    // Draw background
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, maxX + padding * 2, maxY + padding * 2),
        Paint()..color = backgroundColor,
      );
    }

    // Translate for padding
    canvas.translate(padding, padding);

    // Draw glyphs
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
      canvas.drawImage(pg.glyph.image, Offset.zero, Paint());

      canvas.restore();
    }

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Save image to gallery
  static Future<bool> saveToGallery({
    required List<PositionedGlyph> glyphs,
    required StyleParams style,
    bool transparent = false,
  }) async {
    final bytes = await exportToPng(
      glyphs: glyphs,
      style: style,
      backgroundColor: transparent ? null : Colors.white,
    );

    if (bytes == null) return false;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/handwritten_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
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
    bool transparent = false,
  }) async {
    final bytes = await exportToPng(
      glyphs: glyphs,
      style: style,
      backgroundColor: transparent ? null : Colors.white,
    );

    if (bytes == null) return;

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/handwritten_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    // Share
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Handwritten text',
    );
  }
}

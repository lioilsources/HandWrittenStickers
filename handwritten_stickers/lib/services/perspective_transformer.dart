import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

/// Applies perspective transformation to warp a photo so the grid area
/// maps to a perfectly aligned A4 image suitable for the Go glyph extractor.
class PerspectiveTransformer {
  // A4 at 300 DPI
  static const int a4Width = 2480;
  static const int a4Height = 3508;

  // Grid area at 300 DPI (matches Go template_generator.go)
  static const double marginTopMM = 15.0;
  static const double marginLeftMM = 15.0;
  static const double gridWidthMM = 180.0; // 8 × 22.5
  static const double gridHeightMM = 262.0; // 10 × 26.2

  static int _mmToPx(double mm) => (mm / 25.4 * 300).round();

  static int get gridWidthPx => _mmToPx(gridWidthMM);
  static int get gridHeightPx => _mmToPx(gridHeightMM);
  static int get marginTopPx => _mmToPx(marginTopMM);
  static int get marginLeftPx => _mmToPx(marginLeftMM);

  /// Transform a photo so the 4 [corners] (in image-pixel coords) of the
  /// grid area map onto a perfectly aligned A4 image at 300 DPI.
  ///
  /// [corners]: topLeft, topRight, bottomRight, bottomLeft of the grid.
  /// Returns PNG bytes of the resulting A4 image.
  static Future<Uint8List> transform({
    required ui.Image sourceImage,
    required List<ui.Offset> corners,
  }) async {
    // Convert ui.Image → image package Image
    final byteData =
        await sourceImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to read source image');

    final src = img.Image.fromBytes(
      width: sourceImage.width,
      height: sourceImage.height,
      bytes: byteData.buffer,
      numChannels: 4,
    );

    // Create target image for just the grid area
    final gridDst = img.Image(
      width: gridWidthPx,
      height: gridHeightPx,
    );

    // Warp: map the 4 corners from the photo onto the grid rectangle
    final warped = img.copyRectify(
      src,
      topLeft: img.Point(corners[0].dx, corners[0].dy),
      topRight: img.Point(corners[1].dx, corners[1].dy),
      bottomLeft: img.Point(corners[3].dx, corners[3].dy),
      bottomRight: img.Point(corners[2].dx, corners[2].dy),
      toImage: gridDst,
      interpolation: img.Interpolation.linear,
    );

    // Place the warped grid onto a full A4 canvas with white background
    final a4 = img.Image(width: a4Width, height: a4Height);
    img.fill(a4, color: img.ColorRgba8(255, 255, 255, 255));
    img.compositeImage(
      a4,
      warped,
      dstX: marginLeftPx,
      dstY: marginTopPx,
    );

    return Uint8List.fromList(img.encodePng(a4));
  }
}

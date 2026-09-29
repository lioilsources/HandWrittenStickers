import 'dart:ui' as ui;

/// Typographic metrics of a trimmed glyph image, in source-sheet pixels.
///
/// Produced by `glyph_extractor fontset` (manifest version 2). Sheets without
/// metrics (version 1, untrimmed cell scans) are laid out cell-by-cell.
class GlyphMetrics {
  /// Distance from the top edge of the image down to the baseline.
  final int baseline;

  /// Horizontal advance from the glyph origin to the next glyph origin.
  final int advance;

  /// Distance from the glyph origin to the left edge of the image.
  final int bearing;

  const GlyphMetrics({
    required this.baseline,
    required this.advance,
    required this.bearing,
  });

  factory GlyphMetrics.fromJson(Map<String, dynamic> json) {
    return GlyphMetrics(
      baseline: (json['baseline'] as num).toInt(),
      advance: (json['advance'] as num).toInt(),
      bearing: (json['bearing'] as num).toInt(),
    );
  }
}

/// Represents a single handwritten glyph (letter/character)
class Glyph {
  final String char;
  final ui.Image image;

  /// Image size in pixels.
  final int width;
  final int height;

  /// Baseline / advance information, or null for untrimmed cell scans.
  final GlyphMetrics? metrics;

  const Glyph({
    required this.char,
    required this.image,
    required this.width,
    required this.height,
    this.metrics,
  });

  bool get hasMetrics => metrics != null;
}

/// Parameters for rendering a specific instance of a glyph
class GlyphParams {
  /// Vertical offset from baseline (-2 to +2 px typical)
  final double baselineOffset;

  /// Horizontal adjustment to kerning
  final double kerningAdjust;

  /// Rotation in degrees (-3 to +3 typical)
  final double rotation;

  /// Scale factor (0.95 to 1.05 typical)
  final double scale;

  /// Which variant to use (if multiple available)
  final int variantIndex;

  /// Opacity (for ink pressure simulation)
  final double opacity;

  const GlyphParams({
    this.baselineOffset = 0,
    this.kerningAdjust = 0,
    this.rotation = 0,
    this.scale = 1.0,
    this.variantIndex = 0,
    this.opacity = 1.0,
  });

  GlyphParams copyWith({
    double? baselineOffset,
    double? kerningAdjust,
    double? rotation,
    double? scale,
    int? variantIndex,
    double? opacity,
  }) {
    return GlyphParams(
      baselineOffset: baselineOffset ?? this.baselineOffset,
      kerningAdjust: kerningAdjust ?? this.kerningAdjust,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      variantIndex: variantIndex ?? this.variantIndex,
      opacity: opacity ?? this.opacity,
    );
  }
}

/// Positioned glyph ready for rendering.
///
/// [x] and [y] are the top-left corner of the (scaled) glyph image.
class PositionedGlyph {
  final Glyph glyph;
  final GlyphParams params;
  final double x;
  final double y;

  const PositionedGlyph({
    required this.glyph,
    required this.params,
    required this.x,
    required this.y,
  });
}

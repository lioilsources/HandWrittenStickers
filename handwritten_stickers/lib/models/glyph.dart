import 'dart:ui' as ui;

/// Represents a single handwritten glyph (letter/character)
class Glyph {
  final String char;
  final ui.Image image;

  /// Bounding box within the original cell
  final int width;
  final int height;

  /// Typographic metrics
  final int leftBearing;
  final int rightBearing;
  final int baseline;

  const Glyph({
    required this.char,
    required this.image,
    required this.width,
    required this.height,
    this.leftBearing = 0,
    this.rightBearing = 0,
    this.baseline = 0,
  });

  /// Effective advance width (how much to move cursor after drawing)
  int get advanceWidth => width + leftBearing + rightBearing;
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

/// Positioned glyph ready for rendering
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

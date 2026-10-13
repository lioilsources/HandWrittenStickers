import 'dart:math' as math;
import 'dart:ui' as ui;

/// Typographic metrics of a trimmed glyph image, in source-sheet pixels.
///
/// Produced by `glyph_extractor` (manifest version 2+). Sheets without
/// metrics (version 1, untrimmed cell scans) are laid out cell-by-cell.
class GlyphMetrics {
  /// Distance from the top edge of the image down to the baseline.
  final int baseline;

  /// Horizontal advance from the glyph origin to the next glyph origin.
  final int advance;

  /// Distance from the glyph origin to the left edge of the image.
  final int bearing;

  /// Where the pen stroke of a joined (cursive) letter comes in on the left
  /// and leaves on the right; null when the letter does not join there.
  final JoinPoint? entry;
  final JoinPoint? exit;

  const GlyphMetrics({
    required this.baseline,
    required this.advance,
    required this.bearing,
    this.entry,
    this.exit,
  });

  factory GlyphMetrics.fromJson(Map<String, dynamic> json) {
    return GlyphMetrics(
      baseline: (json['baseline'] as num).toInt(),
      advance: (json['advance'] as num).toInt(),
      bearing: (json['bearing'] as num).toInt(),
      entry: JoinPoint.fromJson(json['entry']),
      exit: JoinPoint.fromJson(json['exit']),
    );
  }
}

/// A point of a glyph image (pixels from its top-left corner) where the pen
/// stroke can be joined, and the direction the pen travels through it in
/// degrees (0 = to the right, 90 = up). Stored as `[x, y, direction]`.
class JoinPoint {
  final double x;
  final double y;
  final double direction;

  const JoinPoint(this.x, this.y, [this.direction = 0]);

  static JoinPoint? fromJson(Object? json) {
    if (json is! List || json.length < 2) return null;
    return JoinPoint(
      (json[0] as num).toDouble(),
      (json[1] as num).toDouble(),
      json.length > 2 ? (json[2] as num).toDouble() : 0,
    );
  }
}

/// The pen stroke that joins a glyph to the one before it, in layout
/// coordinates.
class GlyphJoin {
  final ui.Offset from;
  final ui.Offset to;

  /// Pen direction at [from] and [to], degrees (0 = right, 90 = up).
  final double fromDirection;
  final double toDirection;

  /// Pen width and colour.
  final double width;
  final ui.Color color;

  const GlyphJoin({
    required this.from,
    required this.to,
    required this.fromDirection,
    required this.toDirection,
    required this.width,
    required this.color,
  });

  /// A cubic curve leaving [from] and arriving at [to] along the pen
  /// directions. Directions pointing backwards are pulled forward so the
  /// stroke never loops.
  ui.Path get path {
    final reach = (to - from).distance / 3;
    ui.Offset along(double degrees) {
      final r = degrees.clamp(-75.0, 75.0) * math.pi / 180;
      return ui.Offset(math.cos(r), -math.sin(r)) * reach;
    }

    final c1 = from + along(fromDirection);
    final c2 = to - along(toDirection);
    return ui.Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, to.dx, to.dy);
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

  /// The glyph carries its own colours (material letters) and must not be
  /// tinted with the ink colour.
  final bool colored;

  const Glyph({
    required this.char,
    required this.image,
    required this.width,
    required this.height,
    this.metrics,
    this.colored = false,
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

  /// Stroke joining this glyph to the previous one, if they are joined.
  final GlyphJoin? join;

  const PositionedGlyph({
    required this.glyph,
    required this.params,
    required this.x,
    required this.y,
    this.join,
  });

  /// Where the point [p] of the glyph image ends up once the glyph is
  /// scaled, rotated about its centre and shifted off the baseline, exactly
  /// as [paintGlyphs] draws it.
  ui.Offset place(JoinPoint p) => ui.Offset(x, y) + offsetOf(glyph, params, p);

  /// [place] relative to the glyph's top-left corner.
  static ui.Offset offsetOf(Glyph glyph, GlyphParams params, JoinPoint p) {
    final s = params.scale;
    final centre = ui.Offset(glyph.width * s / 2, glyph.height * s / 2);
    final v = ui.Offset(p.x * s, p.y * s) - centre;
    final r = params.rotation * math.pi / 180;
    final rotated = ui.Offset(
      v.dx * math.cos(r) - v.dy * math.sin(r),
      v.dx * math.sin(r) + v.dy * math.cos(r),
    );
    return centre + rotated + ui.Offset(0, params.baselineOffset);
  }
}

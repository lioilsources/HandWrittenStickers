import 'dart:math';

import '../models/glyph.dart';
import '../models/style_params.dart';
import 'glyph_loader.dart';

/// Service for calculating glyph positions and parameters
class GlyphRenderer {
  final GlyphLoader _loader;

  GlyphRenderer(this._loader);

  /// Generate positioned glyphs for the given text
  Future<List<PositionedGlyph>> layoutText({
    required String text,
    required StyleParams style,
    required double maxWidth,
    required double baseGlyphHeight,
  }) async {
    final List<PositionedGlyph> result = [];

    // Use text hash for deterministic randomness
    final random = Random(text.hashCode);

    double x = 0;
    double y = 0;
    final lineHeight = baseGlyphHeight * style.lineHeight;
    final spaceWidth = baseGlyphHeight * 0.5 * style.wordSpacing;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      // Handle whitespace
      if (char == ' ') {
        x += spaceWidth;
        continue;
      }

      if (char == '\n') {
        x = 0;
        y += lineHeight;
        continue;
      }

      // Get glyph
      final glyph = await _loader.getGlyph(char);
      if (glyph == null) {
        // Skip unknown characters or use placeholder
        x += baseGlyphHeight * 0.5;
        continue;
      }

      // Calculate scale to fit baseGlyphHeight
      final baseScale = baseGlyphHeight / glyph.height;

      // Generate randomized parameters based on style
      final params = _generateParams(style, random, baseScale);

      // Check for word wrap
      final effectiveWidth = glyph.width * params.scale;
      if (x + effectiveWidth > maxWidth && x > 0) {
        x = 0;
        y += lineHeight;
      }

      // Add positioned glyph
      result.add(PositionedGlyph(
        glyph: glyph,
        params: params,
        x: x,
        y: y,
      ));

      // Advance cursor
      x += effectiveWidth + style.letterSpacing + params.kerningAdjust;
    }

    return result;
  }

  /// Generate randomized glyph parameters based on style settings
  GlyphParams _generateParams(StyleParams style, Random random, double baseScale) {
    final scaleVariation = 1.0 + _randomRange(random, -0.05, 0.05) * style.sizeVariance;
    return GlyphParams(
      baselineOffset: _randomRange(random, -2, 2) * style.baselineWobble,
      kerningAdjust: _randomRange(random, -1, 1) * style.baselineWobble,
      rotation: _randomRange(random, -3, 3) * style.rotationVariance,
      scale: baseScale * scaleVariation,
      opacity: 1.0 - random.nextDouble() * style.opacityVariance,
    );
  }

  /// Generate a random value in the given range
  double _randomRange(Random random, double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  /// Calculate the total bounds of the laid out text
  Future<Size> calculateBounds({
    required String text,
    required StyleParams style,
    required double maxWidth,
    required double baseGlyphHeight,
  }) async {
    final glyphs = await layoutText(
      text: text,
      style: style,
      maxWidth: maxWidth,
      baseGlyphHeight: baseGlyphHeight,
    );

    if (glyphs.isEmpty) {
      return Size.zero;
    }

    double maxX = 0;
    double maxY = 0;

    for (final pg in glyphs) {
      final right = pg.x + pg.glyph.width * pg.params.scale;
      final bottom = pg.y + pg.glyph.height * pg.params.scale;

      if (right > maxX) maxX = right;
      if (bottom > maxY) maxY = bottom;
    }

    return Size(maxX, maxY);
  }
}

/// Simple Size class (to avoid depending on dart:ui here)
class Size {
  final double width;
  final double height;

  const Size(this.width, this.height);

  static const Size zero = Size(0, 0);

  bool get isEmpty => width <= 0 || height <= 0;
}

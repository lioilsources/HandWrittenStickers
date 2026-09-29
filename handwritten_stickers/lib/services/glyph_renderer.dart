import 'dart:math';

import '../models/glyph.dart';
import '../models/style_params.dart';
import 'glyph_loader.dart';

/// Service for calculating glyph positions and parameters
class GlyphRenderer {
  final GlyphLoader _loader;

  GlyphRenderer(this._loader);

  GlyphLoader get loader => _loader;

  /// Generate positioned glyphs for the given text.
  ///
  /// [baseGlyphHeight] is the on-screen height of one template cell. Sheets
  /// with metrics are scaled uniformly by `baseGlyphHeight / cellHeightPx`
  /// and every glyph is placed on the line baseline; sheets without metrics
  /// (untrimmed cell scans) are scaled to [baseGlyphHeight] cell by cell.
  Future<List<PositionedGlyph>> layoutText({
    required String text,
    required StyleParams style,
    required double maxWidth,
    required double baseGlyphHeight,
  }) async {
    final List<PositionedGlyph> result = [];

    if (!_loader.isInitialized) {
      await _loader.initialize();
    }

    // Use text hash for deterministic randomness
    final random = Random(text.hashCode);

    double x = 0;
    double y = 0;
    final lineHeight = baseGlyphHeight * style.lineHeight;
    final spaceWidth = baseGlyphHeight * 0.5 * style.wordSpacing;
    final baselineY = baseGlyphHeight * _loader.baselineRatio;
    final sheetScale = baseGlyphHeight / _loader.cellHeightPx;

    // Iterate over user-perceived characters so combining sequences and
    // surrogate pairs are not split.
    for (final char in text.runes.map(String.fromCharCode)) {
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

      final metrics = glyph.metrics;

      // Uniform scale for metric sheets, per-cell fit otherwise.
      final baseScale = metrics != null
          ? sheetScale
          : baseGlyphHeight / glyph.height;

      // Generate randomized parameters based on style
      final params = _generateParams(style, random, baseScale);
      final scale = params.scale;

      final advance = metrics != null
          ? metrics.advance * scale
          : glyph.width * scale;

      // Check for word wrap
      if (x + advance > maxWidth && x > 0) {
        x = 0;
        y += lineHeight;
      }

      // Top-left corner of the scaled image: on the baseline for metric
      // sheets, top of the cell otherwise.
      final drawX = metrics != null ? x + metrics.bearing * scale : x;
      final drawY = metrics != null
          ? y + baselineY - metrics.baseline * scale
          : y;

      result.add(
        PositionedGlyph(glyph: glyph, params: params, x: drawX, y: drawY),
      );

      // Advance cursor
      x += advance + style.letterSpacing + params.kerningAdjust;
    }

    return result;
  }

  /// Generate randomized glyph parameters based on style settings
  GlyphParams _generateParams(
    StyleParams style,
    Random random,
    double baseScale,
  ) {
    final scaleVariation =
        1.0 + _randomRange(random, -0.05, 0.05) * style.sizeVariance;
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

import 'dart:math';

import '../models/glyph.dart';
import '../models/style_params.dart';
import 'glyph_loader.dart';
import 'text_normalizer.dart';

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
  ///
  /// A character the sheet lacks is composed from base letter + accent
  /// glyph when possible, else taken from the fallback sheet, else skipped.
  /// With several variants per character, repeated letters never reuse the
  /// previous variant; the choice is deterministic for a given text.
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

    text = TextNormalizer.nfc(text);

    // Use text hash for deterministic randomness
    final random = Random(text.hashCode);
    final lastVariant = <String, int>{};

    double x = 0;
    double y = 0;
    final lineHeight = baseGlyphHeight * style.lineHeight;
    final spaceWidth = baseGlyphHeight * 0.5 * style.wordSpacing;
    final baselineY = baseGlyphHeight * _loader.baselineRatio;

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

      final resolved = await _resolve(char, random, lastVariant);
      if (resolved == null) {
        // Skip unknown characters or use placeholder
        x += baseGlyphHeight * 0.5;
        continue;
      }
      final glyph = resolved.glyph;
      final metrics = glyph.metrics;

      // Uniform scale for metric sheets, per-cell fit otherwise.
      final baseScale = metrics != null
          ? baseGlyphHeight / resolved.loader.cellHeightPx
          : baseGlyphHeight / glyph.height;

      // Generate randomized parameters based on style
      final params = _generateParams(
        style,
        random,
        baseScale,
        resolved.variant,
      );
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

      final accent = resolved.accent;
      if (accent != null) {
        result.add(
          _placeAccent(
            char,
            accent,
            glyph,
            params,
            drawX,
            drawY,
            resolved.loader.emHeightPx * scale,
          ),
        );
      }

      // Advance cursor
      x += advance + style.letterSpacing + params.kerningAdjust;
    }

    return result;
  }

  /// Widest a text block may be relative to its height before
  /// [balanceLines] breaks it. Messengers fit a sticker to a fixed width,
  /// so a long single line arrives with tiny letters.
  static const double maxBlockAspect = 3.0;

  /// Breaks [text] at spaces into the fewest lines of similar width whose
  /// block is at most [maxAspect] times wider than tall. Text with explicit
  /// line breaks is returned unchanged: the writer chose the lines.
  Future<String> balanceLines({
    required String text,
    required StyleParams style,
    required double baseGlyphHeight,
    double maxAspect = maxBlockAspect,
  }) async {
    if (text.contains('\n')) return text;
    final words = text.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length < 2) return text;

    final widths = <double>[];
    for (final word in words) {
      final bounds = await calculateBounds(
        text: word,
        style: style,
        maxWidth: double.infinity,
        baseGlyphHeight: baseGlyphHeight,
      );
      widths.add(bounds.width);
    }
    final space = baseGlyphHeight * 0.5 * style.wordSpacing;
    final lineHeight = baseGlyphHeight * style.lineHeight;

    // prefix[i] = width of words 0..i-1 without spaces.
    final prefix = [0.0];
    for (final w in widths) {
      prefix.add(prefix.last + w);
    }
    double lineWidth(int from, int to) =>
        prefix[to] - prefix[from] + space * (to - from - 1);

    // best[i] = narrowest block for words 0..i-1 in the current number of
    // lines; cut[n][i] = where its last line starts.
    final count = words.length;
    var best = [for (var i = 0; i <= count; i++) lineWidth(0, max(i, 1))];
    final cuts = <List<int>>[List.filled(count + 1, 0)];
    var lines = 1;
    while (best[count] / (lines * lineHeight) > maxAspect && lines < count) {
      lines++;
      final next = List.filled(count + 1, double.infinity);
      final cut = List.filled(count + 1, 0);
      for (var i = lines; i <= count; i++) {
        for (var j = lines - 1; j < i; j++) {
          final width = max(best[j], lineWidth(j, i));
          if (width < next[i]) {
            next[i] = width;
            cut[i] = j;
          }
        }
      }
      best = next;
      cuts.add(cut);
    }

    final starts = <int>[];
    for (var n = lines - 1, end = count; n > 0; n--) {
      end = cuts[n][end];
      starts.add(end);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      if (i > 0) buffer.write(starts.contains(i) ? '\n' : ' ');
      buffer.write(words[i]);
    }
    return buffer.toString();
  }

  /// Finds the glyph for [char]: own glyph, composed glyph, fallback sheet.
  Future<_Resolved?> _resolve(
    String char,
    Random random,
    Map<String, int> lastVariant,
  ) async {
    Future<_Resolved?> from(GlyphLoader loader, String key) async {
      final variant = _pickVariant(
        loader.variantCount(key),
        random,
        lastVariant[key],
      );
      final glyph = await loader.getGlyph(key, variant: variant);
      if (glyph == null) return null;
      lastVariant[key] = variant;
      return _Resolved(loader, glyph, variant);
    }

    if (_loader.variantCount(char) > 0 || _loader.availableCharacters.isEmpty) {
      final own = await from(_loader, char);
      if (own != null) return own;
    }

    final parts = _loader.composeParts(char);
    if (parts != null) {
      final base = await from(_loader, parts[0]);
      final accent = await _loader.getGlyph(parts[1]);
      if (base != null && accent != null && accent.metrics != null) {
        return _Resolved(base.loader, base.glyph, base.variant, accent);
      }
    }

    final fallback = _loader.fallbackLoader;
    if (fallback != null) {
      if (!fallback.isInitialized) await fallback.initialize();
      if (fallback.variantCount(char) > 0) return from(fallback, char);
    }
    return null;
  }

  /// Chooses a variant index; never repeats [previous] when there is a
  /// choice. Consumes randomness only for multi-variant glyphs, so sheets
  /// with one variant per character lay out exactly as before.
  int _pickVariant(int count, Random random, int? previous) {
    if (count <= 1) return 0;
    if (previous == null) return random.nextInt(count);
    final v = random.nextInt(count - 1);
    return v >= previous ? v + 1 : v;
  }

  /// Positions an accent glyph over (or, for ď/ť, beside) its base glyph.
  /// The accent is centred on the base image, [em] × 0.08 above its top.
  PositionedGlyph _placeAccent(
    String char,
    Glyph accent,
    Glyph base,
    GlyphParams params,
    double baseX,
    double baseY,
    double em,
  ) {
    final s = params.scale;
    final aw = accent.width * s;
    final ah = accent.height * s;
    final bw = base.width * s;
    double ax;
    double ay;
    if (TextNormalizer.isSideAccent(char)) {
      ax = baseX + bw - aw * 0.3;
      ay = baseY;
    } else {
      ax = baseX + (bw - aw) / 2;
      ay = baseY - em * 0.08 - ah;
    }
    return PositionedGlyph(glyph: accent, params: params, x: ax, y: ay);
  }

  /// Generate randomized glyph parameters based on style settings
  GlyphParams _generateParams(
    StyleParams style,
    Random random,
    double baseScale,
    int variant,
  ) {
    final scaleVariation =
        1.0 + _randomRange(random, -0.25, 0.25) * style.sizeVariance;
    return GlyphParams(
      baselineOffset: _randomRange(random, -2, 2) * style.baselineWobble,
      kerningAdjust: _randomRange(random, -1, 1) * style.baselineWobble,
      rotation: _randomRange(random, -12, 12) * style.rotationVariance,
      scale: baseScale * scaleVariation,
      opacity: 1.0 - random.nextDouble() * style.opacityVariance,
      variantIndex: variant,
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

class _Resolved {
  final GlyphLoader loader;
  final Glyph glyph;
  final int variant;

  /// Accent drawn over [glyph] for composed letters.
  final Glyph? accent;

  const _Resolved(this.loader, this.glyph, this.variant, [this.accent]);
}

/// Simple Size class (to avoid depending on dart:ui here)
class Size {
  final double width;
  final double height;

  const Size(this.width, this.height);

  static const Size zero = Size(0, 0);

  bool get isEmpty => width <= 0 || height <= 0;
}

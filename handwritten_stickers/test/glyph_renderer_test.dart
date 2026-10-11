import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/glyph.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/services/glyph_loader.dart';
import 'package:handwritten_stickers/services/glyph_renderer.dart';

/// Loader that serves in-memory glyphs instead of reading assets.
class _FakeLoader extends GlyphLoader {
  final Map<String, Glyph> glyphs;

  /// Extra variants: char → variants 1..n (variant 0 is in [glyphs]).
  final Map<String, List<Glyph>> variants;
  final Map<String, List<String>> compose;
  final double _cellHeight;
  final bool _hasMetrics;

  _FakeLoader(
    this.glyphs, {
    required double cellHeightPx,
    required bool hasMetrics,
    this.variants = const {},
    this.compose = const {},
  }) : _cellHeight = cellHeightPx,
       _hasMetrics = hasMetrics,
       super(sheetPath: 'assets/glyphs/fake/');

  @override
  Future<void> initialize() async {}

  @override
  bool get isInitialized => true;

  @override
  double get cellHeightPx => _cellHeight;

  @override
  double get baselineRatio => 0.75;

  @override
  bool get hasMetrics => _hasMetrics;

  @override
  double get emHeightPx => _cellHeight * 0.62;

  @override
  int variantCount(String char) =>
      glyphs.containsKey(char) ? 1 + (variants[char]?.length ?? 0) : 0;

  @override
  Set<String> get availableCharacters => glyphs.keys.toSet();

  @override
  bool hasGlyph(String char) => glyphs.containsKey(char);

  @override
  List<String>? composeParts(String char) => compose[char];

  @override
  Future<Glyph?> getGlyph(String char, {int variant = 0}) async {
    if (variant == 0) return glyphs[char];
    return variants[char]?[variant - 1];
  }
}

Future<Glyph> _glyph(
  String char,
  int w,
  int h, {
  required int baseline,
  required int advance,
  int bearing = 0,
}) async => Glyph(
  char: char,
  image: await _blankImage(w, h),
  width: w,
  height: h,
  metrics: GlyphMetrics(baseline: baseline, advance: advance, bearing: bearing),
);

Future<ui.Image> _blankImage(int w, int h) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = Colors.black,
  );
  return recorder.endRecording().toImage(w, h);
}

/// Style with all randomness switched off so positions are exact.
const _plain = StyleParams(
  letterSpacing: 0,
  wordSpacing: 1,
  lineHeight: 1.2,
  baselineWobble: 0,
  sizeVariance: 0,
  rotationVariance: 0,
  opacityVariance: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlyphRenderer with metrics (font sheets)', () {
    late _FakeLoader loader;

    setUpAll(() async {
      // Cell is 300 px tall; baseline sits at 225 px (0.75).
      loader = _FakeLoader(
        {
          // Tall ascender glyph: 100 px wide, 200 px tall, baseline 180 px
          // below its top, i.e. it descends 20 px.
          'l': Glyph(
            char: 'l',
            image: await _blankImage(100, 200),
            width: 100,
            height: 200,
            metrics: const GlyphMetrics(baseline: 180, advance: 90, bearing: 5),
          ),
          // Period: small blob sitting on the baseline.
          '.': Glyph(
            char: '.',
            image: await _blankImage(30, 30),
            width: 30,
            height: 30,
            metrics: const GlyphMetrics(baseline: 30, advance: 40, bearing: 5),
          ),
        },
        cellHeightPx: 300,
        hasMetrics: true,
      );
    });

    test(
      'scales every glyph uniformly by cell height, not by its own height',
      () async {
        final renderer = GlyphRenderer(loader);
        final out = await renderer.layoutText(
          text: 'l.',
          style: _plain,
          maxWidth: 1000,
          baseGlyphHeight: 30,
        );
        expect(out, hasLength(2));
        // 30 / 300 = 0.1 for both glyphs.
        expect(out[0].params.scale, closeTo(0.1, 1e-9));
        expect(out[1].params.scale, closeTo(0.1, 1e-9));
      },
    );

    test('places glyph images so their baselines coincide', () async {
      final renderer = GlyphRenderer(loader);
      final out = await renderer.layoutText(
        text: 'l.',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      final lineBaseline = 30 * 0.75;
      for (final pg in out) {
        final baselineOnScreen =
            pg.y + pg.glyph.metrics!.baseline * pg.params.scale;
        expect(baselineOnScreen, closeTo(lineBaseline, 1e-9));
      }
      // The period is drawn much lower than the 'l' top.
      expect(out[1].y, greaterThan(out[0].y));
    });

    test('advances by metric advance plus bearing offsets', () async {
      final renderer = GlyphRenderer(loader);
      final out = await renderer.layoutText(
        text: 'l.',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      // 'l': origin 0, bearing 5*0.1 → x = 0.5
      expect(out[0].x, closeTo(0.5, 1e-9));
      // '.': origin 90*0.1 = 9, bearing 0.5 → x = 9.5
      expect(out[1].x, closeTo(9.5, 1e-9));
    });

    test('wraps based on advance width', () async {
      final renderer = GlyphRenderer(loader);
      final out = await renderer.layoutText(
        text: 'lll',
        style: _plain,
        maxWidth: 20, // two 'l' (9 px each) fit, third wraps
        baseGlyphHeight: 30,
      );
      expect(out[2].y, greaterThan(out[1].y));
      expect(out[2].x, closeTo(0.5, 1e-9));
    });
  });

  group('GlyphRenderer with variants (manifest v3)', () {
    late _FakeLoader loader;

    setUpAll(() async {
      // Three variants of "a" that differ in width, so they are told apart.
      loader = _FakeLoader(
        {'a': await _glyph('a', 50, 60, baseline: 60, advance: 60)},
        variants: {
          'a': [
            await _glyph('a', 51, 60, baseline: 60, advance: 60),
            await _glyph('a', 52, 60, baseline: 60, advance: 60),
          ],
        },
        cellHeightPx: 300,
        hasMetrics: true,
      );
    });

    test('consecutive repeats of a letter use different variants', () async {
      final out = await GlyphRenderer(loader).layoutText(
        text: 'aaaaaa',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      expect(out, hasLength(6));
      for (var i = 1; i < out.length; i++) {
        expect(
          out[i].params.variantIndex,
          isNot(out[i - 1].params.variantIndex),
        );
        expect(out[i].glyph.width, isNot(out[i - 1].glyph.width));
      }
      expect(out.map((g) => g.params.variantIndex).toSet().length, 3);
    });

    test('the same text always gives the same variants', () async {
      Future<List<int>> run() async => (await GlyphRenderer(loader).layoutText(
        text: 'banana a aaa',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      )).map((g) => g.params.variantIndex).toList();
      expect(await run(), await run());
    });
  });

  group('GlyphRenderer composing accents and falling back', () {
    late _FakeLoader loader;
    late _FakeLoader fallback;

    setUpAll(() async {
      loader = _FakeLoader(
        {
          'c': await _glyph('c', 100, 100, baseline: 100, advance: 120),
          'caron': await _glyph('caron', 40, 20, baseline: 0, advance: 40),
        },
        compose: {
          'č': ['c', 'caron'],
        },
        cellHeightPx: 300,
        hasMetrics: true,
      );
      // Fallback sheet with a different geometry (cell 600 px).
      fallback = _FakeLoader(
        {'#': await _glyph('#', 200, 200, baseline: 200, advance: 220)},
        cellHeightPx: 600,
        hasMetrics: true,
      );
      loader.fallbackLoader = fallback;
    });

    test('composes č from c + caron, accent centred above the base', () async {
      final out = await GlyphRenderer(loader).layoutText(
        text: 'č',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      expect(out, hasLength(2));
      final base = out[0];
      final accent = out[1];
      expect(base.glyph.char, 'c');
      expect(accent.glyph.char, 'caron');
      const s = 0.1; // 30 / 300
      // Horizontal centres coincide.
      expect(
        accent.x + accent.glyph.width * s / 2,
        closeTo(base.x + base.glyph.width * s / 2, 1e-9),
      );
      // Accent bottom sits 0.08 em above the base top.
      expect(
        accent.y + accent.glyph.height * s,
        closeTo(base.y - 300 * 0.62 * s * 0.08, 1e-9),
      );
    });

    test('decomposed input (c + U+030C) is normalised to č', () async {
      final out = await GlyphRenderer(loader).layoutText(
        text: 'c\u030C',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      expect(out.map((g) => g.glyph.char), ['c', 'caron']);
    });

    test(
      'takes missing characters from the fallback sheet at its own scale',
      () async {
        final out = await GlyphRenderer(loader).layoutText(
          text: 'c#',
          style: _plain,
          maxWidth: 1000,
          baseGlyphHeight: 30,
        );
        expect(out, hasLength(2));
        expect(out[1].glyph.char, '#');
        // 30 / 600: the fallback cell maps to the same on-screen height.
        expect(out[1].params.scale, closeTo(0.05, 1e-9));
        // Same baseline for both sheets.
        expect(
          out[1].y + 200 * out[1].params.scale,
          closeTo(out[0].y + 100 * out[0].params.scale, 1e-9),
        );
        // Pen advanced by c (120 * 0.1).
        expect(out[1].x, closeTo(12, 1e-9));
      },
    );
  });

  group('GlyphRenderer without metrics (scanned cell sheets)', () {
    test('keeps legacy behaviour: fit each cell to baseGlyphHeight', () async {
      final loader = _FakeLoader(
        {
          'A': Glyph(
            char: 'A',
            image: await _blankImage(217, 252),
            width: 217,
            height: 252,
          ),
        },
        cellHeightPx: 252,
        hasMetrics: false,
      );
      final renderer = GlyphRenderer(loader);
      final out = await renderer.layoutText(
        text: 'AA',
        style: _plain,
        maxWidth: 1000,
        baseGlyphHeight: 30,
      );
      expect(out[0].x, 0);
      expect(out[0].y, 0);
      expect(out[0].params.scale, closeTo(30 / 252, 1e-9));
      expect(out[1].x, closeTo(217 * 30 / 252, 1e-9));
    });
  });
}

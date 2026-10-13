import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/models/glyph.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/services/glyph_loader.dart';
import 'package:handwritten_stickers/services/glyph_painter.dart';
import 'package:handwritten_stickers/services/glyph_renderer.dart';

/// Loader that serves in-memory glyphs instead of reading assets.
class _FakeLoader extends GlyphLoader {
  final Map<String, Glyph> glyphs;

  /// Extra variants: char → variants 1..n (variant 0 is in [glyphs]).
  final Map<String, List<Glyph>> variants;
  final Map<String, List<String>> compose;
  final double _cellHeight;
  final bool _hasMetrics;
  final double? _strokeWidth;

  _FakeLoader(
    this.glyphs, {
    required double cellHeightPx,
    required bool hasMetrics,
    this.variants = const {},
    this.compose = const {},
    double? strokeWidthPx,
  }) : _cellHeight = cellHeightPx,
       _hasMetrics = hasMetrics,
       _strokeWidth = strokeWidthPx,
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
  double? get strokeWidthPx => _strokeWidth;

  @override
  double get xHeightPx => 100;

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
  JoinPoint? entry,
  JoinPoint? exit,
}) async => Glyph(
  char: char,
  image: await _blankImage(w, h),
  width: w,
  height: h,
  metrics: GlyphMetrics(
    baseline: baseline,
    advance: advance,
    bearing: bearing,
    entry: entry,
    exit: exit,
  ),
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

  group('GlyphRenderer.balanceLines', () {
    late GlyphRenderer renderer;

    setUpAll(() async {
      // "l" advances 9 px at a 30 px cell; a line is 36 px tall.
      renderer = GlyphRenderer(
        _FakeLoader(
          {'l': await _glyph('l', 100, 200, baseline: 180, advance: 90)},
          cellHeightPx: 300,
          hasMetrics: true,
        ),
      );
    });

    Future<String> balance(String text) =>
        renderer.balanceLines(text: text, style: _plain, baseGlyphHeight: 30);

    test('keeps a short line whole', () async {
      expect(await balance('ll ll'), 'll ll');
      expect(await balance('llllllllllllllllllll'), 'llllllllllllllllllll');
    });

    test('breaks a long line into lines of similar width', () async {
      expect(await balance('lll lll lll lll'), 'lll lll\nlll lll');
      // The long word sets the width; the short ones share the other line.
      expect(await balance('l l llllllllll'), 'l l\nllllllllll');
    });

    test('leaves the lines the writer chose', () async {
      expect(await balance('lll lll lll\nlll'), 'lll lll lll\nlll');
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

  group('GlyphRenderer joining letters', () {
    late _FakeLoader loader;
    late GlyphRenderer renderer;

    // Cell 300 px laid out 30 px tall: scale 0.1, x-height 10, pen 0.5.
    // Glyph images are 10×10 on screen, the baseline along their bottom.
    Future<List<PositionedGlyph>> layout(
      String text, [
      StyleParams style = _plain,
    ]) => renderer.layoutText(
      text: text,
      style: style,
      maxWidth: double.infinity,
      baseGlyphHeight: 30,
    );

    setUpAll(() async {
      Future<Glyph> letter(String c, JoinPoint? entry, JoinPoint? exit) =>
          _glyph(
            c,
            100,
            100,
            baseline: 100,
            advance: 120,
            bearing: 10,
            entry: entry,
            exit: exit,
          );
      loader = _FakeLoader(
        {
          // Comes in and leaves half way up.
          'a': await letter(
            'a',
            const JoinPoint(0, 50),
            const JoinPoint(100, 50, 30),
          ),
          // Comes in lower, leaves higher.
          'b': await letter(
            'b',
            const JoinPoint(0, 80),
            const JoinPoint(100, 20),
          ),
          // A capital: leads into the next letter, takes no stroke itself.
          'A': await letter('A', null, const JoinPoint(100, 50)),
          '.': await letter('.', null, null),
        },
        cellHeightPx: 300,
        hasMetrics: true,
        strokeWidthPx: 5,
      );
      renderer = GlyphRenderer(loader);
    });

    test('the entry point lands a join gap right of the exit point', () async {
      final glyphs = await layout('aa');
      expect(glyphs[0].join, isNull);
      expect(glyphs[0].x, closeTo(1, 1e-9));
      // Exit of the first a: x = 1 + 10, y = 12.5 + 5.
      final join = glyphs[1].join!;
      expect(join.from, const Offset(11, 17.5));
      // Same height: just the fixed gap of a tenth of the x-height.
      expect(join.to.dx, closeTo(12, 1e-9));
      expect(join.to.dy, closeTo(17.5, 1e-9));
      expect(glyphs[1].x, closeTo(12, 1e-9));
      expect(join.width, closeTo(0.5, 1e-9));
      expect(join.fromDirection, 30);
    });

    test('a height difference widens the gap', () async {
      final glyphs = await layout('ab');
      // b comes in 3 px lower: gap = 1 + 0.4 × 3.
      expect(glyphs[1].join!.to.dy, closeTo(20.5, 1e-9));
      expect(glyphs[1].x, closeTo(11 + 2.2, 1e-9));
    });

    test('letter spacing lengthens the join', () async {
      final glyphs = await layout('aa', _plain.copyWith(letterSpacing: 5));
      expect(glyphs[1].x, closeTo(17, 1e-9));
      expect(glyphs[1].join!.to.dx, closeTo(17, 1e-9));
      // Far negative spacing stops where the strokes would overlap.
      final tight = await layout('aa', _plain.copyWith(letterSpacing: -10));
      expect(tight[1].x, closeTo(11 - 0.15, 1e-9));
    });

    test('words, lines and letters without points are not joined', () async {
      final spaced = await layout('a a');
      expect(spaced[1].join, isNull);
      expect(spaced[1].x, closeTo(12 + 15 + 1, 1e-9));

      final lines = await layout('a\na');
      expect(lines[1].join, isNull);

      // A capital joins forwards only; punctuation not at all.
      final mixed = await layout('aAa.a');
      expect(mixed[1].join, isNull, reason: 'nothing leads into a capital');
      expect(mixed[2].join, isNotNull, reason: 'the capital leads on');
      expect(mixed[3].join, isNull);
      expect(mixed[4].join, isNull);
    });

    test('joinLetters off gives the plain layout', () async {
      final glyphs = await layout('ab', _plain.copyWith(joinLetters: false));
      expect(glyphs.map((g) => g.join), everyElement(isNull));
      expect(glyphs[1].x, closeTo(12 + 1, 1e-9));
    });

    test('joins follow letters that wobble, tilt and change size', () async {
      const lively = StyleParams(
        baselineWobble: 1,
        sizeVariance: 1,
        rotationVariance: 1,
        opacityVariance: 0,
      );
      final glyphs = await layout('abab', lively);
      for (var i = 1; i < glyphs.length; i++) {
        final join = glyphs[i].join!;
        final exit = glyphs[i - 1].place(glyphs[i - 1].glyph.metrics!.exit!);
        final entry = glyphs[i].place(glyphs[i].glyph.metrics!.entry!);
        expect((join.from - exit).distance, closeTo(0, 1e-6));
        expect((join.to - entry).distance, closeTo(0, 1e-6));
        expect(join.to.dx, greaterThan(join.from.dx));
      }
    });

    test('the join is painted between the letters', () async {
      Future<int> alphaBetween(StyleParams style) async {
        final glyphs = await layout('ab', style);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..scale(10);
        paintGlyphs(canvas, glyphs);
        final image = await recorder.endRecording().toImage(400, 400);
        final bytes = (await image.toByteData())!;
        // Between the two 10 px wide letters, on the stroke.
        final x = ((glyphs[0].x + 10 + glyphs[1].x) / 2 * 10).round();
        var alpha = 0;
        for (var y = 0; y < 400; y++) {
          alpha = max(alpha, bytes.getUint8((y * 400 + x) * 4 + 3));
        }
        return alpha;
      }

      final spaced = _plain.copyWith(letterSpacing: 10);
      expect(await alphaBetween(spaced), greaterThan(200));
      expect(await alphaBetween(spaced.copyWith(joinLetters: false)), 0);
    });
  });
}

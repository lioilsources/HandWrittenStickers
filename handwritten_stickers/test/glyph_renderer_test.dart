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
  final double _cellHeight;
  final bool _hasMetrics;

  _FakeLoader(
    this.glyphs, {
    required double cellHeightPx,
    required bool hasMetrics,
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
  Future<Glyph?> getGlyph(String char) async => glyphs[char];
}

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

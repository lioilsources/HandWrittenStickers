import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/services/glyph_loader.dart';

/// Asset bundle serving an in-memory sheet.
class _MemoryBundle extends CachingAssetBundle {
  final Map<String, ByteData> files;
  _MemoryBundle(this.files);

  @override
  Future<ByteData> load(String key) async {
    final data = files[key];
    if (data == null) throw FlutterError('missing asset $key');
    return data;
  }
}

Future<ByteData> _png(int w, int h) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(
    recorder,
  ).drawRect(ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), ui.Paint());
  final image = await recorder.endRecording().toImage(w, h);
  return (await image.toByteData(format: ui.ImageByteFormat.png))!;
}

ByteData _text(String s) =>
    ByteData.sublistView(Uint8List.fromList(utf8.encode(s)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads a v3 manifest: variants, compose, fallback, colored', () async {
    const dir = 'assets/glyphs/v3/';
    final manifest = {
      'version': 3,
      'id': 'v3',
      'cellSize': {'width': 22.5, 'height': 26.2},
      'dpi': 300,
      'emHeight': 192,
      'baselineRatio': 0.75,
      'colored': true,
      'fallback': 'caveat',
      'compose': {
        'č': ['c', 'caron'],
      },
      'glyphs': {
        'a': ['a.png', 'a_1.png'],
        'c': 'c.png',
        'caron': 'caron.png',
      },
      'metrics': {
        'a': [
          {'w': 10, 'h': 12, 'baseline': 12, 'advance': 14, 'bearing': 2},
          {'w': 11, 'h': 12, 'baseline': 12, 'advance': 15, 'bearing': 2},
        ],
        'c': {'w': 9, 'h': 10, 'baseline': 10, 'advance': 13, 'bearing': 2},
        'caron': {'w': 6, 'h': 4, 'baseline': 0, 'advance': 6, 'bearing': 0},
      },
    };
    final loader = GlyphLoader(
      sheetPath: dir,
      bundle: _MemoryBundle({
        '${dir}glyphs.json': _text(json.encode(manifest)),
        '${dir}a.png': await _png(10, 12),
        '${dir}a_1.png': await _png(11, 12),
        '${dir}c.png': await _png(9, 10),
        '${dir}caron.png': await _png(6, 4),
      }),
    );
    await loader.initialize();

    expect(loader.variantCount('a'), 2);
    expect(loader.variantCount('c'), 1);
    expect(loader.variantCount('x'), 0);
    expect(loader.isColored, isTrue);
    expect(loader.fallbackId, 'caveat');
    expect(loader.emHeightPx, 192);

    final a0 = await loader.getGlyph('a');
    final a1 = await loader.getGlyph('a', variant: 1);
    expect(a0!.width, 10);
    expect(a1!.width, 11);
    expect(a1.metrics!.advance, 15);
    expect(a1.colored, isTrue);
    // Variant indices wrap around.
    expect((await loader.getGlyph('a', variant: 3))!.width, 11);

    expect(loader.composeParts('č'), ['c', 'caron']);
    // No rule and no base "e": cannot compose ě.
    expect(loader.composeParts('ě'), isNull);
  });

  test('derives compose parts from the accent glyphs a sheet has', () async {
    const dir = 'assets/glyphs/acc/';
    final m = {'w': 5, 'h': 5, 'baseline': 5, 'advance': 6, 'bearing': 0};
    final loader = GlyphLoader(
      sheetPath: dir,
      bundle: _MemoryBundle({
        '${dir}glyphs.json': _text(
          json.encode({
            'version': 2,
            'glyphs': {
              'e': 'e.png',
              'i': 'i.png',
              'caron': 'c.png',
              'acute': 'a.png',
            },
            'metrics': {'e': m, 'i': m, 'caron': m, 'acute': m},
          }),
        ),
      }),
    );
    await loader.initialize();
    expect(loader.composeParts('ě'), ['e', 'caron']);
    // No dotless ı in the sheet → the plain i is used.
    expect(loader.composeParts('í'), ['i', 'acute']);
    expect(loader.composeParts('ů'), isNull, reason: 'no ring glyph');
  });
}

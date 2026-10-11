// Not a test: a renderer run with `flutter test` so the real Flutter text
// engine and the CuteKidFonts painter draw every glyph exactly as in the
// package. Writes, per sheet, candidates/NNNN.png + candidates.json in the
// format of `glyph_extractor assemble` (see tools/sheets/README.md).
//
//   cd tools/kid_sheets && flutter test   (or ./build.sh for the whole chain)
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:cute_kid_fonts/cute_kid_fonts_testing.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 160-character template set (glyph_extractor/charset.go, same order).
const charset =
    'AÁBCČDĎEÉĚFGHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ0123456789.,!?:;-()"\'/@'
    '#&+=%*€\$[]{}<>\\_aábcčdďeéěfghiíjklmnňoópqrřsštťuúůvwxyýzž~`^|©®™'
    '°§¶•…–—„”‚’«»×÷±¼½¾¹²³µ¿¡ñÑßæÆøØ';

class SheetSpec {
  const SheetSpec(this.id, this.role, {this.palette, this.flat = false});
  final String id;
  final KidRole role;
  final KidPalette? palette;
  final bool flat;
}

const sheets = [
  SheetSpec('kid_bubble_peach', KidRole.title, palette: KidPalette.peach),
  SheetSpec('kid_bubble_mint', KidRole.title, palette: KidPalette.mint),
  SheetSpec('kid_bubble_lavender', KidRole.title, palette: KidPalette.lavender),
  SheetSpec('kid_bubble_lemon', KidRole.title, palette: KidPalette.lemon),
  SheetSpec('kid_bubble_sky', KidRole.title, palette: KidPalette.sky),
  SheetSpec('kid_bubble_italic', KidRole.titleItalic, palette: KidPalette.lavender),
  SheetSpec('kid_dynapuff', KidRole.title, flat: true),
  SheetSpec('kid_grandstander', KidRole.titleItalic, flat: true),
  SheetSpec('kid_baloo', KidRole.dialog, flat: true),
];

/// Font size in px. 220 px puts the capital H near the 0.70 em target of
/// 192 px ems, so `assemble` only scales down slightly.
const fontSize = 220.0;
const padding = 2;

Future<void> renderSheet(SheetSpec spec, Directory out) async {
  final dir = Directory('${out.path}/${spec.id}/candidates')..createSync(recursive: true);
  final candidates = <Map<String, Object?>>[];
  for (final ch in charset.runes.map(String.fromCharCode)) {
    final painter = KidBubblePainter(
      text: ch,
      role: spec.role,
      palette: spec.palette ?? KidPalette.sky,
      size: fontSize,
      flat: spec.flat,
      flatColor: const Color(0xFF000000),
      align: TextAlign.left,
    )..layout();
    final w = painter.size.width.ceil() + 2 * padding;
    final h = painter.size.height.ceil() + 2 * padding;
    final baseline = painter.baseline + padding;
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Offset(padding + 0.0, padding + 0.0));
    painter.dispose();
    final image = await recorder.endRecording().toImage(w, h);
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba))!;

    // Trim to the painted pixels (+ padding) so metrics describe the ink.
    var x0 = w, y0 = h, x1 = -1, y1 = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (rgba.getUint8((y * w + x) * 4 + 3) > 8) {
          if (x < x0) x0 = x;
          if (x > x1) x1 = x;
          if (y < y0) y0 = y;
          if (y > y1) y1 = y;
        }
      }
    }
    if (x1 < 0) continue; // nothing drawn (font lacks the glyph)
    x0 = (x0 - padding).clamp(0, w);
    y0 = (y0 - padding).clamp(0, h);
    x1 = (x1 + padding + 1).clamp(0, w);
    y1 = (y1 + padding + 1).clamp(0, h);
    final recorder2 = ui.PictureRecorder();
    Canvas(recorder2).drawImageRect(
      image,
      Rect.fromLTRB(x0.toDouble(), y0.toDouble(), x1.toDouble(), y1.toDouble()),
      Rect.fromLTWH(0, 0, (x1 - x0).toDouble(), (y1 - y0).toDouble()),
      Paint(),
    );
    final trimmed = await recorder2.endRecording().toImage(x1 - x0, y1 - y0);
    final png = (await trimmed.toByteData(format: ui.ImageByteFormat.png))!;
    final id = candidates.length;
    final file = 'candidates/${id.toString().padLeft(4, '0')}.png';
    File('${out.path}/${spec.id}/$file').writeAsBytesSync(png.buffer.asUint8List());
    candidates.add({
      'id': id,
      'file': file,
      'line': 0,
      'order': id,
      'bbox': [0, 0, x1 - x0, y1 - y0],
      'baseline': (baseline - y0).round(),
      'label': ch,
    });
    image.dispose();
    trimmed.dispose();
  }
  File('${out.path}/${spec.id}/candidates.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'source': 'CuteKidFonts ${spec.role.name}${spec.flat ? ' flat' : ' ${spec.palette!.name}'}',
      'dpi': 300,
      'candidates': candidates,
    }),
  );
  // ignore: avoid_print
  print('${spec.id}: ${candidates.length} glyphs');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadKidFonts);

  final out = Directory(Platform.environment['KID_SHEETS_OUT'] ?? 'build/candidates');
  final only = Platform.environment['KID_SHEETS_ONLY'];
  for (final spec in sheets) {
    if (only != null && !only.split(',').contains(spec.id)) continue;
    test('render ${spec.id}', () => renderSheet(spec, out), timeout: const Timeout(Duration(minutes: 5)));
  }
}

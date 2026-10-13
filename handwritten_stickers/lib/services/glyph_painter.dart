import 'dart:math' as math;
import 'dart:ui';

import '../models/glyph.dart';

/// Draws laid out glyphs and the pen strokes joining them. The preview and
/// the export both paint through here, so what is shared is what was seen.
void paintGlyphs(
  Canvas canvas,
  List<PositionedGlyph> glyphs, {
  FilterQuality quality = FilterQuality.medium,
}) {
  final imagePaint = Paint()..filterQuality = quality;
  final joinPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  for (final pg in glyphs) {
    final join = pg.join;
    // Ends that already meet need no stroke: the glyphs overlap there.
    if (join != null && (join.to - join.from).distance >= join.width / 2) {
      canvas.drawPath(
        join.path,
        joinPaint
          ..strokeWidth = join.width
          ..color = join.color,
      );
    }

    canvas.save();

    // Move to glyph position
    canvas.translate(pg.x, pg.y + pg.params.baselineOffset);

    // Apply rotation around glyph center
    if (pg.params.rotation != 0) {
      final centerX = pg.glyph.width * pg.params.scale / 2;
      final centerY = pg.glyph.height * pg.params.scale / 2;
      canvas.translate(centerX, centerY);
      canvas.rotate(pg.params.rotation * math.pi / 180);
      canvas.translate(-centerX, -centerY);
    }

    // Apply scale
    if (pg.params.scale != 1.0) {
      canvas.scale(pg.params.scale);
    }

    // Draw the glyph image (glyphs retain their original ink color from scan)
    canvas.drawImage(
      pg.glyph.image,
      Offset.zero,
      imagePaint..color = Color.fromRGBO(0, 0, 0, pg.params.opacity),
    );

    canvas.restore();
  }
}

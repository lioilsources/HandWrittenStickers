import 'package:flutter/material.dart';

import '../models/glyph.dart';
import '../models/style_params.dart';
import '../services/glyph_painter.dart';

/// Canvas widget for rendering handwritten text
class HandwrittenCanvas extends StatelessWidget {
  final List<PositionedGlyph> glyphs;
  final StyleParams style;
  final Color? backgroundColor;

  const HandwrittenCanvas({
    super.key,
    required this.glyphs,
    required this.style,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HandwrittenPainter(
        glyphs: glyphs,
        style: style,
        backgroundColor: backgroundColor,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for rendering positioned glyphs
class HandwrittenPainter extends CustomPainter {
  final List<PositionedGlyph> glyphs;
  final StyleParams style;
  final Color? backgroundColor;

  HandwrittenPainter({
    required this.glyphs,
    required this.style,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background if specified
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }

    paintGlyphs(canvas, glyphs);
  }

  @override
  bool shouldRepaint(HandwrittenPainter oldDelegate) {
    return oldDelegate.glyphs != glyphs ||
        oldDelegate.style != style ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Interactive canvas with zoom and pan
class InteractiveHandwrittenCanvas extends StatefulWidget {
  final List<PositionedGlyph> glyphs;
  final StyleParams style;
  final Color? backgroundColor;
  final double minScale;
  final double maxScale;

  const InteractiveHandwrittenCanvas({
    super.key,
    required this.glyphs,
    required this.style,
    this.backgroundColor,
    this.minScale = 0.5,
    this.maxScale = 3.0,
  });

  @override
  State<InteractiveHandwrittenCanvas> createState() =>
      _InteractiveHandwrittenCanvasState();
}

class _InteractiveHandwrittenCanvasState
    extends State<InteractiveHandwrittenCanvas> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      boundaryMargin: const EdgeInsets.all(100),
      child: HandwrittenCanvas(
        glyphs: widget.glyphs,
        style: widget.style,
        backgroundColor: widget.backgroundColor,
      ),
    );
  }
}

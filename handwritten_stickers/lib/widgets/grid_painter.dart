import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints an 8×10 grid with perspective distortion defined by 4 corner points.
///
/// The grid lines are interpolated between corners so the overlay matches
/// perspective-distorted photos of the A4 template.
class GridPainter extends CustomPainter {
  /// Corners in order: topLeft, topRight, bottomRight, bottomLeft.
  /// Coordinates are in image-pixel space.
  final List<Offset> corners;

  /// Number of columns (default 8)
  final int columns;

  /// Number of rows (default 10)
  final int rows;

  GridPainter({
    required this.corners,
    this.columns = 8,
    this.rows = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topLeft = corners[0];
    final topRight = corners[1];
    final bottomRight = corners[2];
    final bottomLeft = corners[3];

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xAA00CC44)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Outer border — thicker
    final borderPaint = Paint()
      ..color = const Color(0xCC00CC44)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw outer border
    final borderPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    canvas.drawPath(borderPath, borderPaint);

    // Draw horizontal lines (rows + 1 lines, skip first and last = border)
    for (int i = 1; i < rows; i++) {
      final t = i / rows;
      final left = Offset.lerp(topLeft, bottomLeft, t)!;
      final right = Offset.lerp(topRight, bottomRight, t)!;
      canvas.drawLine(left, right, gridPaint);
    }

    // Draw vertical lines (columns + 1 lines, skip first and last = border)
    for (int i = 1; i < columns; i++) {
      final t = i / columns;
      final top = Offset.lerp(topLeft, topRight, t)!;
      final bottom = Offset.lerp(bottomLeft, bottomRight, t)!;
      canvas.drawLine(top, bottom, gridPaint);
    }

    // Draw corner handles
    _drawCornerHandle(canvas, topLeft, 'TL');
    _drawCornerHandle(canvas, topRight, 'TR');
    _drawCornerHandle(canvas, bottomRight, 'BR');
    _drawCornerHandle(canvas, bottomLeft, 'BL');
  }

  void _drawCornerHandle(Canvas canvas, Offset position, String label) {
    const radius = 12.0;

    // Outer circle (white border)
    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Inner circle (blue fill)
    canvas.drawCircle(
      position,
      radius - 2,
      Paint()
        ..color = const Color(0xDD2196F3)
        ..style = PaintingStyle.fill,
    );

    // Label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    if (oldDelegate.corners.length != corners.length) return true;
    for (int i = 0; i < corners.length; i++) {
      if (oldDelegate.corners[i] != corners[i]) return true;
    }
    return false;
  }
}

// lib/modules/scan/widgets/scan_painter.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class ScanGridPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  ScanGridPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = AppColors.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 // Much thicker lines
      ..strokeCap = StrokeCap.round;

    // Responsive corner length based on container size
    final cornerLength = size.width * 0.15; // 15% of container width
    const cornerRadius = 12.0; // Rounded corners

    // Draw animated scanning line (thicker and more visible)
    final scanPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(animationValue * 0.8)
      ..strokeWidth = 4.0 // Thicker scanning line
      ..style = PaintingStyle.stroke;

    final scanY = size.height * animationValue;
    canvas.drawLine(
      Offset(0, scanY),
      Offset(size.width, scanY),
      scanPaint,
    );

    // Draw rounded corners only (no full square)

    // Top-left corner
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(0, cornerRadius),
        Offset(cornerLength, cornerRadius)
    );
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(cornerRadius, 0),
        Offset(cornerRadius, cornerLength)
    );

    // Top-right corner
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(size.width - cornerLength, cornerRadius),
        Offset(size.width, cornerRadius)
    );
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(size.width - cornerRadius, 0),
        Offset(size.width - cornerRadius, cornerLength)
    );

    // Bottom-left corner
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(0, size.height - cornerRadius),
        Offset(cornerLength, size.height - cornerRadius)
    );
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(cornerRadius, size.height - cornerLength),
        Offset(cornerRadius, size.height)
    );

    // Bottom-right corner
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(size.width - cornerLength, size.height - cornerRadius),
        Offset(size.width, size.height - cornerRadius)
    );
    _drawRoundedCorner(canvas, cornerPaint,
        Offset(size.width - cornerRadius, size.height - cornerLength),
        Offset(size.width - cornerRadius, size.height)
    );
  }

  void _drawRoundedCorner(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
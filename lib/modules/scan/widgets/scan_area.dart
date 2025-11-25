// lib/modules/scan/widgets/scan_area.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import 'scan_painter.dart';

class ScanArea extends StatelessWidget {
  final Animation<double> animation;

  const ScanArea({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive scan area size - 75% of screen width with limits
    final scanSize = (screenWidth * 0.75).clamp(300.0, 450.0);

    return Center(
      child: Container(
        width: scanSize,
        height: scanSize,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ScanGridPainter(
                animationValue: animation.value,
                color: AppColors.secondaryGreen,
              ),
            );
          },
        ),
      ),
    );
  }
}
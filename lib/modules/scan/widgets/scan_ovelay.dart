// lib/modules/scan/widgets/scan_overlay.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import 'scan_area.dart';

class ScanOverlay extends StatelessWidget {
  final Animation<double> animation;

  const ScanOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.2, 0.7, 1.0], // Adjusted stops to prevent overlap
          ),
        ),
        child: Column(
          children: [
            const _TopInfoSection(),
            Expanded(
              child: ScanArea(animation: animation),
            ),
            const SizedBox(height: 120), // Space for bottom controls
          ],
        ),
      ),
    );
  }
}

class _TopInfoSection extends StatelessWidget {
  const _TopInfoSection();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Text(
              'Scan Plant',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the plant within the frame for best results',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
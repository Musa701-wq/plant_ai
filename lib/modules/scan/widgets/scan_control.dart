// lib/modules/scan/widgets/scan_control.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../provider/scan_provider.dart';

class ScanControls extends StatelessWidget {
  final ScanProvider provider;

  const ScanControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TopControls(provider: provider),
        _BottomControls(provider: provider),
      ],
    );
  }
}

class _TopControls extends StatelessWidget {
  final ScanProvider provider;

  const _TopControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.only(top: 16, left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flash Toggle
              _ControlButton(
                icon: provider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                isActive: provider.isFlashOn,
                onTap: provider.toggleFlash,
              ),
              const SizedBox(width: 8),
              // Camera Switch
              _ControlButton(
                icon: Icons.cameraswitch,
                isActive: false,
                onTap: provider.switchCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final ScanProvider provider;

  const _BottomControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 40), // Increased margin to prevent overlap
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gallery Button
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: _GalleryButton(
                  onTap: () => provider.pickImageFromGallery(context),
                ),
              ),
              // Capture Button
              _CaptureButton(
                onTap: () => provider.captureImage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentYellow : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GalleryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Gallery',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.secondaryGreen,
              ],
            ),
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
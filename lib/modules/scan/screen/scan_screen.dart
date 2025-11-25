import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:untitled/modules/scan/screen/result_screen.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../provider/scan_provider.dart';
import '../widgets/image_preview.dart';
import '../widgets/scan_control.dart';
import '../widgets/scan_ovelay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  late ScanProvider _scanProvider;


  @override
  void initState() {
    super.initState();
    _scanProvider = Provider.of<ScanProvider>(context, listen: false);
    Future.microtask(() => _scanProvider.initCamera());
    _setupScanAnimation();
  }

  void _setupScanAnimation() {
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // 🧹 Ensure proper cleanup when leaving the screen
    _scanProvider.disposeCamera();
    _scanProvider.clearTemporaryStateSilently();
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();

    return WillPopScope(
      onWillPop: () async {
        await provider.disposeCamera();
        provider.clearTemporaryState();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildCameraPreview(provider),

            // Close Button - Added at the top
            if (provider.selectedImage == null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    await provider.disposeCamera();
                    provider.clearTemporaryState();
                    if (mounted) Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            if (provider.selectedImage == null) ...[
              ScanOverlay(animation: _scanAnimation),
              ScanControls(provider: provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(ScanProvider provider) {
    if (provider.selectedImage != null) {
      return ImagePreviewWidget(
        image: provider.selectedImage!,
        onConfirm: () {
          final imagePath = provider.prepareForIdentification();
          if (imagePath != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(imagePath: imagePath),
              ),
            );

          }
        },
        onRetake: () => provider.clearSelectedImage(),
      );
    }

    if (provider.isLoading) {
      return Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGreen),
              SizedBox(height: 12),
              Text(
                "Identifying plant...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }


    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
        ),
      );
    }

    if (!provider.isInitialized || provider.cameraController == null) {
      return const Center(
        child: Text(
          'Initializing Camera...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return CameraPreview(provider.cameraController!);
  }
}

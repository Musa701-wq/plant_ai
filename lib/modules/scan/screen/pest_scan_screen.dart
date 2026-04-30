import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../../Auth/auth_state.dart';
import '../../../my_app/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../scan/provider/scan_provider.dart';
import '../../scan/widgets/image_preview.dart';
import '../../scan/widgets/scan_control.dart';
import '../../scan/widgets/scan_ovelay.dart';

class PestScanScreen extends StatefulWidget {
  const PestScanScreen({super.key});

  @override
  State<PestScanScreen> createState() => _PestScanScreenState();
}

class _PestScanScreenState extends State<PestScanScreen> with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  late ScanProvider _scanProvider;

  @override
  void initState() {
    super.initState();
    _scanProvider = Provider.of<ScanProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanProvider.initCamera();
    });

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
            
            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
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
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bug_report, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'PEST DOCTOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 44), // Spacer for balance
                  ],
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
            Navigator.pushReplacementNamed(
              context, 
              AppRoutes.pestResult, 
              arguments: {'imagePath': imagePath},
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
              CircularProgressIndicator(color: Color(0xFFD32F2F)),
              SizedBox(height: 12),
              Text(
                "Analyzing for pests...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
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

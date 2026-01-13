import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:untitled/modules/scan/screen/result_screen.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart';
import '../../../Auth/google_auth.dart';
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

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  late ScanProvider _scanProvider;

  @override
  void initState() {
    super.initState();
    _scanProvider = Provider.of<ScanProvider>(context, listen: false);

    // Only initialize camera if user is signed in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthState>();
      if (authState.isUserSignedIn) {
        _scanProvider.initCamera();
      }
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
    // 🧹 Ensure proper cleanup when leaving the screen
    _scanProvider.disposeCamera();
    _scanProvider.clearTemporaryStateSilently();
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    // Check if user is signed in
    if (!authState.isUserSignedIn) {
      return _buildSignInRequiredScreen(context);
    }

    // User is signed in, show scan interface
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

  // NEW: Sign-in required screen for Scan
  Widget _buildSignInRequiredScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Scan Icon
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.2),
                            AppColors.secondaryGreen.withOpacity(0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.center_focus_strong,
                        size: 80,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Plant Scanner',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'Sign in to identify plants using your camera',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Features List
                    _buildFeatureItem(
                      icon: Icons.camera_alt,
                      title: 'Instant Identification',
                      description: 'Snap a photo and identify any plant instantly',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.info_outline,
                      title: 'Detailed Information',
                      description: 'Get care tips, growing conditions, and more',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.bookmark,
                      title: 'Save to Garden',
                      description: 'Add identified plants to your personal garden',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.history,
                      title: 'Scan History',
                      description: 'Access all your previous plant scans',
                    ),
                    const SizedBox(height: 40),

                    // Sign-in Buttons
                    _buildSignInButton(
                      context: context,
                      onPressed: () async {
                        //final success = await signInWithGoogleUI(context);
                        final success = await GoogleAuth.signInWithGoogleUI(context);
                        if (success && mounted) {
                          // Initialize camera after successful sign-in
                          _scanProvider.initCamera();
                        }
                      },
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    _buildSignInButton(
                      context: context,
                      onPressed: () async {
                        final success = await AppleAuth.signInWithAppleUI(context);
                        if (success && mounted) {
                          // Initialize camera after successful sign-in
                          _scanProvider.initCamera();
                        }
                      },
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 24),

                    // Privacy Note
                    Text(
                      'Your scans are private and secure',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button - Positioned at top left (outside SafeArea but inside Stack)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
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

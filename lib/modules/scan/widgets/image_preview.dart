// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../utils/app_colors.dart';
// import '../../../../utils/app_text_style.dart';
// import '../provider/scan_provider.dart';
//
// class ImagePreviewWidget extends StatelessWidget {
//   final File image;
//   final VoidCallback onConfirm;
//   final VoidCallback onRetake;
//
//   const ImagePreviewWidget({
//     super.key,
//     required this.image,
//     required this.onConfirm,
//     required this.onRetake,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Header Section
//                 _buildHeaderSection(context),
//
//                 // Image Preview with Frame
//                 Expanded(
//                   child: _buildImagePreview(screenWidth, screenHeight),
//                 ),
//
//                 // Action Buttons
//                 _buildActionButtons(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primaryGreen.withOpacity(0.9),
//             AppColors.secondaryGreen,
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryGreen.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.photo_camera,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Image Preview',
//                   style: AppTextStyles.headlineSmall.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 Text(
//                   'Review your captured plant image',
//                   style: AppTextStyles.caption.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // 🆕 Cross button at top-right
//           GestureDetector(
//             onTap: () async {
//               final provider = context.read<ScanProvider>();
//               await provider.disposeCamera();
//               provider.clearTemporaryState();
//               if (Navigator.canPop(context)) Navigator.pop(context);
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImagePreview(double screenWidth, double screenHeight) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             spreadRadius: 2,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Stack(
//           children: [
//             // Main Image
//             Image.file(
//               image,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//
//             // Gradient Overlay at bottom for text readability
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 100,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.8),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Scan Frame Overlay
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: AppColors.accentYellow.withOpacity(0.6),
//                     width: 3,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//
//             // Corner Indicators
//             _buildCornerIndicators(),
//
//             // Info Text
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryGreen.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.eco, color: Colors.white, size: 16),
//                         const SizedBox(width: 6),
//                         Text(
//                           'Ready for Identification',
//                           style: AppTextStyles.caption.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Ensure the plant is clearly visible',
//                     style: AppTextStyles.caption.copyWith(
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCornerIndicators() {
//     return Stack(
//       children: [
//         _corner(top: 10, left: 10, borderTop: true, borderLeft: true),
//         _corner(top: 10, right: 10, borderTop: true, borderRight: true),
//         _corner(bottom: 10, left: 10, borderBottom: true, borderLeft: true),
//         _corner(bottom: 10, right: 10, borderBottom: true, borderRight: true),
//       ],
//     );
//   }
//
//   Widget _corner({
//     double? top,
//     double? left,
//     double? right,
//     double? bottom,
//     bool borderTop = false,
//     bool borderLeft = false,
//     bool borderRight = false,
//     bool borderBottom = false,
//   }) {
//     return Positioned(
//       top: top,
//       left: left,
//       right: right,
//       bottom: bottom,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           border: Border(
//             top: borderTop ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
//             left: borderLeft ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
//             right: borderRight ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
//             bottom: borderBottom ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Retake Button
//           Expanded(
//             child: _button(
//               onTap: onRetake,
//               colors: [Colors.redAccent.withOpacity(0.9), Colors.orange.withOpacity(0.8)],
//               icon: Icons.refresh,
//               text: "Retake",
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Confirm Button
//           Expanded(
//             child: _button(
//               onTap: onConfirm,
//               colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
//               icon: Icons.check_circle,
//               text: "Identify Plant",
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _button({
//     required VoidCallback onTap,
//     required List<Color> colors,
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: LinearGradient(colors: colors),
//         boxShadow: [
//           BoxShadow(
//             color: colors.first.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(15),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: onTap,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 22),
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_style.dart';
import '../../../services/ads/AdsProvider.dart';
import '../provider/scan_provider.dart';

class ImagePreviewWidget extends StatefulWidget {
  final File image;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

  const ImagePreviewWidget({
    super.key,
    required this.image,
    required this.onConfirm,
    required this.onRetake,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  @override
  void initState() {
    super.initState();
    // // Preload rewarded ad when preview screen opens
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final adProvider = context.read<AdProvider>();
    //   adProvider.preloadAd(AdType.lensAd);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Section
                _buildHeaderSection(context),

                // Image Preview with Frame
                Expanded(
                  child: _buildImagePreview(screenWidth, screenHeight),
                ),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.9),
            AppColors.secondaryGreen,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image Preview',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Review your captured plant image',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // 🆕 Cross button at top-right
          GestureDetector(
            onTap: () async {
              final provider = context.read<ScanProvider>();
              await provider.disposeCamera();
              provider.clearTemporaryState();
              if (Navigator.canPop(context)) Navigator.pop(context);
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
        ],
      ),
    );
  }

  Widget _buildImagePreview(double screenWidth, double screenHeight) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Main Image
            Image.file(
              widget.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Gradient Overlay at bottom for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Scan Frame Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accentYellow.withOpacity(0.6),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Corner Indicators
            _buildCornerIndicators(),

            // Info Text
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Ready for Identification',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ensure the plant is clearly visible',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicators() {
    return Stack(
      children: [
        _corner(top: 10, left: 10, borderTop: true, borderLeft: true),
        _corner(top: 10, right: 10, borderTop: true, borderRight: true),
        _corner(bottom: 10, left: 10, borderBottom: true, borderLeft: true),
        _corner(bottom: 10, right: 10, borderBottom: true, borderRight: true),
      ],
    );
  }

  Widget _corner({
    double? top,
    double? left,
    double? right,
    double? bottom,
    bool borderTop = false,
    bool borderLeft = false,
    bool borderRight = false,
    bool borderBottom = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: borderTop ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
            left: borderLeft ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
            right: borderRight ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
            bottom: borderBottom ? BorderSide(color: AppColors.accentYellow, width: 3) : BorderSide.none,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Retake Button
          Expanded(
            child: _button(
              onTap: widget.onRetake,
              colors: [Colors.redAccent.withOpacity(0.9), Colors.orange.withOpacity(0.8)],
              icon: Icons.refresh,
              text: "Retake",
            ),
          ),
          const SizedBox(width: 16),
          //Confirm Button with Rewarded Ad
          Expanded(
            child: _button(
              onTap: () => widget.onConfirm(),
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              icon: Icons.check_circle,
              text: "Identify Plant",
            ),
          ),
        ],
      ),
    );
  }

  // // ---------- HANDLE IDENTIFY PLANT WITH REWARDED AD ----------
  // void _handleIdentifyPlant(BuildContext context) {
  //   final adProvider = context.read<AdProvider>();
  //
  //   // Check if rewarded ad is loaded
  //   if (adProvider.isLensAd && adProvider.lensAd != null) {
  //     // Show rewarded ad first, then proceed
  //     adProvider.showRewardedAd(
  //       AdType.lensAd,
  //       onRewarded: () {
  //         print("✅ User watched ad, proceeding with identification");
  //         widget.onConfirm();
  //       },
  //     );
  //   } else {
  //     // If ad not loaded, proceed without ad
  //     print("⚠️ Rewarded ad not ready, proceeding without ad");
  //     widget.onConfirm();
  //
  //     // Try to preload for next time
  //     adProvider.preloadAd(AdType.lensAd);
  //   }
  // }

  Widget _button({
    required VoidCallback onTap,
    required List<Color> colors,
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
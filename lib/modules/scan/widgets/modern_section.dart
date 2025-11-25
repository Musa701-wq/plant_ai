// import 'package:flutter/material.dart';
//
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
//
//
// class ModernSection extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Widget child;
//
//   const ModernSection({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.child,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primaryGreen,
//                     AppColors.secondaryGreen,
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: Colors.white, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               title,
//               overflow: TextOverflow.ellipsis,
//               style: AppTextStyles.headlineSmall.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         child,
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';


class ModernSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ModernSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Responsive scaling helpers
    double fontScale(double value) => value * (screenWidth / 375).clamp(0.75, 1.15);
    double sizeScale(double value) => value * (screenWidth / 375).clamp(0.8, 1.15);
    double heightScale(double value) => value * (screenHeight / 812).clamp(0.75, 1.2);

    // Check for different screen sizes
    final isSmallScreen = screenWidth < 360;
    final isTinyScreen = screenWidth < 340;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(sizeScale(isSmallScreen ? 6 : 8)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.secondaryGreen,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: sizeScale(isSmallScreen ? 18 : 20),
              ),
            ),
            SizedBox(width: sizeScale(isTinyScreen ? 8 : 12)),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: fontScale(isSmallScreen ? 16 : 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: heightScale(isSmallScreen ? 12 : 16)),
        child,
      ],
    );
  }
}
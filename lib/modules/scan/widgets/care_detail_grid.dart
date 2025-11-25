// import 'package:flutter/material.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../gemini/model/plant_model.dart';
// import 'gradient_card.dart';
//
// class CareDetailsGrid extends StatelessWidget {
//   final PlantDetails details;
//
//   const CareDetailsGrid({Key? key, required this.details}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final careData = [
//       CareItem("Temperature", details.temperatureRange, Icons.thermostat),
//       CareItem("Sunlight", details.sunlight, Icons.wb_sunny),
//       CareItem("Watering", details.watering, Icons.water_drop),
//       CareItem("Repotting", details.repotting, Icons.auto_fix_high),
//       CareItem("Fertilizing", details.fertilizing, Icons.spa),
//       CareItem("Pests", details.pests, Icons.bug_report),
//     ];
//
//     final width = MediaQuery.of(context).size.width;
//     final crossAxisCount = width < 360 ? 1 : 2;
//     final cardHeight = width < 380 ? 150.0 : 160.0; // fixed card height
//
//     return GradientCard(
//       child: GridView.builder(
//         itemCount: careData.length,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: width < 380 ? 1.6 : 1.4,
//         ),
//         itemBuilder: (context, index) =>
//             _buildCareDetailItem(context, careData[index], cardHeight),
//       ),
//     );
//   }
//
//   Widget _buildCareDetailItem(BuildContext context, CareItem item, double height) {
//     return GestureDetector(
//       onTap: () {
//         if (item.value.isEmpty || item.value == "N/A") return;
//         _showBeautifulDialog(context, item);
//       },
//       child: Container(
//         height: height,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Flexible(
//               flex: 3,
//               child: Icon(item.icon, color: AppColors.primaryGreen, size: 30),
//             ),
//             const SizedBox(height: 6),
//             Flexible(
//               flex: 2,
//               child: Text(
//                 item.title,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Flexible(
//               flex: 3,
//               child: Text(
//                 item.value.isNotEmpty ? item.value : "N/A",
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                   height: 1.3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// 🌸 Beautiful info dialog
//   void _showBeautifulDialog(BuildContext context, CareItem item) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primaryGreen.withOpacity(0.95),
//                   AppColors.primaryGreen.withOpacity(0.75),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 16,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                   radius: 34,
//                   backgroundColor: Colors.white,
//                   child: Icon(item.icon, size: 38, color: AppColors.primaryGreen),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   item.title,
//                   style: AppTextStyles.bodyLarge.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 20,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
//                 const SizedBox(height: 12),
//                 Text(
//                   item.value,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                     height: 1.6,
//                     fontSize: 15,
//                   ),
//                   textAlign: TextAlign.justify,
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: AppColors.primaryGreen,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       "Close",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// /// Helper model for grid items
// class CareItem {
//   final String title;
//   final String value;
//   final IconData icon;
//   CareItem(this.title, this.value, this.icon);
// }

import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../gemini/model/plant_model.dart';
import 'gradient_card.dart';

class CareDetailsGrid extends StatelessWidget {
  final PlantDetails details;

  const CareDetailsGrid({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final careData = [
      CareItem("Temperature", details.temperatureRange, Icons.thermostat),
      CareItem("Sunlight", details.sunlight, Icons.wb_sunny),
      CareItem("Watering", details.watering, Icons.water_drop),
      CareItem("Repotting", details.repotting, Icons.auto_fix_high),
      CareItem("Fertilizing", details.fertilizing, Icons.spa),
      CareItem("Pests", details.pests, Icons.bug_report),
    ];

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Better responsive breakpoints
    int crossAxisCount;
    double childAspectRatio;
    double iconSize;
    double titleFontSize;
    double valueFontSize;
    double horizontalPadding;
    double verticalPadding;
    double spacing;

    if (width < 340) {
      // Tiny screens
      crossAxisCount = 1;
      childAspectRatio = 2.8;
      iconSize = 26;
      titleFontSize = 13;
      valueFontSize = 11;
      horizontalPadding = 10;
      verticalPadding = 10;
      spacing = 10;
    } else if (width < 360) {
      // Very small screens
      crossAxisCount = 1;
      childAspectRatio = 2.6;
      iconSize = 28;
      titleFontSize = 14;
      valueFontSize = 12;
      horizontalPadding = 10;
      verticalPadding = 10;
      spacing = 10;
    } else if (width < 600) {
      // Small to medium phones
      crossAxisCount = 2;
      childAspectRatio = 1.5;
      iconSize = 28;
      titleFontSize = 13;
      valueFontSize = 11;
      horizontalPadding = 12;
      verticalPadding = 12;
      spacing = 12;
    } else if (width < 900) {
      // Large phones and small tablets
      crossAxisCount = 2;
      childAspectRatio = 1.6;
      iconSize = 34;
      titleFontSize = 15;
      valueFontSize = 13;
      horizontalPadding = 14;
      verticalPadding = 14;
      spacing = 14;
    } else {
      // Tablets and larger
      crossAxisCount = 3;
      childAspectRatio = 1.4;
      iconSize = 36;
      titleFontSize = 16;
      valueFontSize = 14;
      horizontalPadding = 16;
      verticalPadding = 16;
      spacing = 16;
    }

    return GradientCard(
      child: GridView.builder(
        itemCount: careData.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) => _buildCareDetailItem(
          context,
          careData[index],
          iconSize,
          titleFontSize,
          valueFontSize,
          horizontalPadding,
          verticalPadding,
        ),
      ),
    );
  }

  Widget _buildCareDetailItem(
      BuildContext context,
      CareItem item,
      double iconSize,
      double titleFontSize,
      double valueFontSize,
      double horizontalPadding,
      double verticalPadding,
      ) {
    return GestureDetector(
      onTap: () {
        if (item.value.isEmpty || item.value == "N/A") return;
        _showBeautifulDialog(context, item);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: AppColors.primaryGreen,
              size: iconSize,
            ),
            SizedBox(height: verticalPadding * 0.5),
            Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalPadding * 0.3),
            Flexible(
              child: Text(
                item.value.isNotEmpty ? item.value : "N/A",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                  fontSize: valueFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌸 Beautiful info dialog
  void _showBeautifulDialog(BuildContext context, CareItem item) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive dialog sizing
    final horizontalPadding = width < 340 ? 12.0 : width < 360 ? 16.0 : 20.0;
    final contentPadding = width < 340 ? 14.0 : width < 360 ? 16.0 : 20.0;
    final iconRadius = width < 340 ? 28.0 : width < 360 ? 30.0 : 34.0;
    final iconSize = width < 340 ? 32.0 : width < 360 ? 34.0 : 38.0;
    final titleSize = width < 340 ? 17.0 : width < 360 ? 18.0 : 20.0;
    final bodySize = width < 340 ? 13.0 : width < 360 ? 14.0 : 15.0;
    final buttonPadding = width < 360 ? 12.0 : 14.0;
    final buttonFontSize = width < 340 ? 14.0 : width < 360 ? 15.0 : 16.0;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: width < 360 ? width * 0.95 : 500,
              maxHeight: height * 0.7,
            ),
            padding: EdgeInsets.all(contentPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.95),
                  AppColors.primaryGreen.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: iconRadius,
                    backgroundColor: Colors.white,
                    child: Icon(
                      item.icon,
                      size: iconSize,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: contentPadding * 0.8),
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: contentPadding * 0.6),
                  Divider(
                    color: Colors.white.withOpacity(0.3),
                    thickness: 1,
                  ),
                  SizedBox(height: contentPadding * 0.6),
                  Text(
                    item.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                      fontSize: bodySize,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: contentPadding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: buttonPadding,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper model for grid items
class CareItem {
  final String title;
  final String value;
  final IconData icon;
  CareItem(this.title, this.value, this.icon);
}
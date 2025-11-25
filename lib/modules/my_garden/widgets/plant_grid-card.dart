// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../db/model/garden_plant.dart';
// import 'dart:math' as math;
//
// class PlantGridCard extends StatelessWidget {
//   final GardenPlant plant;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;
//   final VoidCallback onManageReminders;
//   final VoidCallback onDelete;
//
//   const PlantGridCard({
//     super.key,
//     required this.plant,
//     required this.onTap,
//     required this.onEdit,
//     required this.onManageReminders,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final isSmall = width < 160;
//         final isMedium = width < 220;
//
//         // 🌿 Smart adaptive scaling
//         double scale(double base, {double min = 10, double max = 22}) {
//           return math.min(math.max(base * (width / 200), min), max);
//         }
//
//         final imageHeight = width * 0.55;
//         final fontSize = scale(14);
//         final typeFontSize = scale(12, min: 9);
//         final buttonFontSize = scale(13, min: 10);
//         final padding = scale(10, min: 6);
//         final buttonVerticalPadding = scale(8, min: 5, max: 10);
//
//         return GestureDetector(
//           onTap: onTap,
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.backgroundWhite,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// 🌿 Image
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: SizedBox(
//                     height: imageHeight,
//                     width: double.infinity,
//                     child: plant.imagePath.isNotEmpty
//                         ? _buildImagePreview(plant.imagePath)
//                         : Container(
//                       color: AppColors.backgroundCard,
//                       alignment: Alignment.center,
//                       child: Icon(
//                         Icons.local_florist,
//                         color: AppColors.primaryGreen,
//                         size: width * 0.25,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 /// 🌱 Info & Button
//                 Padding(
//                   padding: EdgeInsets.all(padding),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Header row
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               plant.name,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyles.bodyMedium.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: fontSize,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.more_vert, color: Colors.black, size: 20),
//                             onPressed: () => _showPlantOptions(context),
//                             constraints: const BoxConstraints(),
//                             padding: EdgeInsets.zero,
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 4),
//
//                       /// Type + Health
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               plant.type,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyles.caption.copyWith(
//                                 color: AppColors.textSecondary,
//                                 fontSize: typeFontSize,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Flexible(
//                             flex: 0,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: _getHealthColor(plant.health),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 _getHealthStatus(plant.health),
//                                 style: AppTextStyles.caption.copyWith(
//                                   color: AppColors.textOnPrimary,
//                                   fontSize: typeFontSize * 0.9,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: width * 0.04),
//
//                       /// 🔔 Set Reminder Button
//                       ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: 36,
//                           maxHeight: isSmall ? 38 : 48,
//                         ),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: onManageReminders,
//                             icon: Icon(
//                               Icons.alarm,
//                               size: width * 0.07,
//                               color: Colors.white,
//                             ),
//                             label: Flexible(
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   'Set Reminder',
//                                   style: AppTextStyles.bodyMedium.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: buttonFontSize,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primaryGreen,
//                               padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   static Color _getHealthColor(int health) {
//     if (health >= 80) return Colors.green;
//     if (health >= 50) return Colors.orange;
//     return Colors.red;
//   }
//
//   static String _getHealthStatus(int health) {
//     if (health >= 80) return 'Healthy';
//     if (health >= 50) return 'Normal';
//     return 'Need Care';
//   }
//
//   Widget _buildImagePreview(String path) {
//     final isNetwork = path.startsWith('http');
//     return isNetwork
//         ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
//         : (File(path).existsSync()
//         ? Image.file(File(path), fit: BoxFit.cover)
//         : _buildPlaceholder());
//   }
//
//   Widget _buildPlaceholder() => Container(
//     color: Colors.grey.shade300,
//     alignment: Alignment.center,
//     child: const Icon(Icons.local_florist, color: Colors.green),
//   );
//
//   void _showPlantOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.edit, color: Colors.green),
//               title: const Text('Edit Plant'),
//               onTap: () {
//                 Navigator.pop(context);
//                 onEdit();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.notifications, color: Colors.green),
//               title: const Text('Set Reminders'),
//               onTap: () {
//                 Navigator.pop(context);
//                 onManageReminders();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete Plant'),
//               onTap: () {
//                 Navigator.pop(context);
//                 onDelete();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import 'dart:math' as math;

class PlantGridCard extends StatelessWidget {
  final GardenPlant plant;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onManageReminders;
  final VoidCallback onDelete;

  const PlantGridCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onEdit,
    required this.onManageReminders,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 160;
        final isMedium = width < 220;

        // 🌿 Smart adaptive scaling
        double scale(double base, {double min = 10, double max = 22}) {
          return math.min(math.max(base * (width / 200), min), max);
        }

        final imageHeight = width * 0.52; // Reduced from 0.55
        final fontSize = scale(14);
        final typeFontSize = scale(12, min: 9);
        final buttonFontSize = scale(12, min: 10); // Reduced from 13
        final padding = scale(10, min: 6);
        final buttonVerticalPadding = scale(7, min: 5, max: 9); // Reduced from 8

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🌿 Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: plant.imagePath.isNotEmpty
                        ? _buildImagePreview(plant.imagePath)
                        : Container(
                      color: AppColors.backgroundCard,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_florist,
                        color: AppColors.primaryGreen,
                        size: width * 0.25,
                      ),
                    ),
                  ),
                ),

                /// 🌱 Info & Button - Use Flexible to prevent overflow
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSize,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.black, size: 18),
                              onPressed: () => _showPlantOptions(context),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        /// Type + Health
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plant.type,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: typeFontSize,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              flex: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getHealthColor(plant.health),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getHealthStatus(plant.health),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontSize: typeFontSize * 0.85,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: width * 0.03),

                        /// 🔔 Set Reminder Button
                        SizedBox(
                          width: double.infinity,
                          height: isSmall ? 34 : 38, // Fixed height
                          child: ElevatedButton.icon(
                            onPressed: onManageReminders,
                            icon: Icon(
                              Icons.alarm,
                              size: width * 0.065,
                              color: Colors.white,
                            ),
                            label: Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Set Reminder',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: buttonFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: EdgeInsets.symmetric(
                                vertical: buttonVerticalPadding,
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: Size.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _getHealthColor(int health) {
    if (health >= 80) return Colors.green;
    if (health >= 50) return Colors.orange;
    return Colors.red;
  }

  static String _getHealthStatus(int health) {
    if (health >= 80) return 'Healthy';
    if (health >= 50) return 'Normal';
    return 'Need Care';
  }

  Widget _buildImagePreview(String path) {
    final isNetwork = path.startsWith('http');
    return isNetwork
        ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
        : (File(path).existsSync()
        ? Image.file(File(path), fit: BoxFit.cover)
        : _buildPlaceholder());
  }

  Widget _buildPlaceholder() => Container(
    color: Colors.grey.shade300,
    alignment: Alignment.center,
    child: const Icon(Icons.local_florist, color: Colors.green),
  );

  void _showPlantOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edit Plant'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text('Set Reminders'),
              onTap: () {
                Navigator.pop(context);
                onManageReminders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Plant'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';

class PlantListCard extends StatelessWidget {
  final GardenPlant plant;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onManageReminders;
  final VoidCallback onDelete;

  const PlantListCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onEdit,
    required this.onManageReminders,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive scaling
        final isSmall = width < 340;
        final imageSize = width * 0.24; // dynamic image sizing
        final fontSize = isSmall ? 13.0 : 15.0;
        final captionSize = isSmall ? 11.0 : 13.0;
        final padding = isSmall ? 10.0 : 16.0;
        final buttonFont = isSmall ? 12.0 : 14.0;
        final buttonPadding = isSmall ? 6.0 : 10.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🌿 Row with Image + Info + Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant Image/Icon
                    ClipRRect(
                      borderRadius:  BorderRadius.circular(16),
                      child: SizedBox(
                        height: imageSize,
                        width: imageSize,
                        child: plant.imagePath.isNotEmpty
                            ?_buildImagePreview(plant.imagePath)
                            : Container(
                          color: AppColors.backgroundCard,
                          child: Icon(
                            Icons.local_florist,
                            color: AppColors.primaryGreen,
                            size: width * 0.2,
                          ),
                        ),
                      ),
                    ),



                    SizedBox(width: isSmall ? 8 : 12),

                    // Plant Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            plant.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: fontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plant.type,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: captionSize,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.health_and_safety,
                                  size: 12, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                '${plant.health}% Health',
                                style: AppTextStyles.caption.copyWith(
                                  color: _getHealthColor(plant.health),
                                  fontSize: captionSize,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmall ? 10 : 14),

                          /// 🔔 Set Reminder Button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onManageReminders,
                                icon: Icon(Icons.alarm, size: isSmall ? 14 : 18),
                                label: Text(
                                  'Set Reminder',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: buttonFont,
                                      color: Colors.white
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: AppColors.textOnPrimary,
                                  padding:
                                  EdgeInsets.symmetric(vertical: buttonPadding),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status + Menu
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getHealthColor(plant.health),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getHealthStatus(plant.health),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: captionSize,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.black, size: 20),
                          onPressed: () => _showPlantOptions(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🖼️ Build image preview supporting both network & file images
  Widget _buildImagePreview(String imageUrlOrPath) {
    final isNetworkImage = imageUrlOrPath.startsWith('http') ||
        imageUrlOrPath.startsWith('https');

    if (isNetworkImage) {
      return Image.network(
        imageUrlOrPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (File(imageUrlOrPath).existsSync()) {
      return Image.file(
        File(imageUrlOrPath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  /// 🌸 Placeholder when image fails
  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_florist, color: Colors.green),
    );
  }

  // Bottom Sheet
  void _showPlantOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: Text('Edit Plant', style: AppTextStyles.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title:
              Text('Set Reminders', style: AppTextStyles.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                onManageReminders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Plant',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.error),
              ),
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

  static String _getHealthStatus(int health) {
    if (health >= 80) return 'Healthy';
    if (health > 50 && health < 80  ) return 'Normal';
    return 'Need Care';
  }

  static Color _getHealthColor(int health) {
    if (health >= 80) return Colors.green;
    if (health >= 50 && health < 80) return Colors.orange;
    return Colors.red;
  }

}

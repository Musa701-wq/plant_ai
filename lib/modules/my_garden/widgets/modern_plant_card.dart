import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import '../provider/garden_provider.dart';

class ModernPlantCard extends StatelessWidget {
  final GardenPlant? plant;

  const ModernPlantCard({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gardenProvider = Provider.of<GardenProvider>(context);
    final plants = gardenProvider.plants;
    final selectedPlant = gardenProvider.selectedPlant ?? plant;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌿 Dropdown Section
          DropdownButtonHideUnderline(
            child: DropdownButton<GardenPlant>(
              isExpanded: true,
              value: selectedPlant,
              dropdownColor: Colors.white,
              hint: Row(
                children: [
                  const Icon(Icons.local_florist, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Select Plant',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.green,
                size: 28,
              ),
              menuMaxHeight: MediaQuery.of(context).size.height * 0.5, // 👈 limit dropdown height
              itemHeight: null, // 👈 allow variable height items
              items: plants.map((p) {
                return DropdownMenuItem<GardenPlant>(
                  value: p,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5, // 👈 prevent row overflow
                    ),
                      child: _buildPlantRow(context, p)),
                );
              }).toList(),
              onChanged: (GardenPlant? newPlant) {
                if (newPlant != null) {
                  gardenProvider.selectPlant(newPlant);
                }
              },
              selectedItemBuilder: (context) {
                return plants.map((p) {
                  return _buildPlantRow(context, p);
                }).toList();
              },
            ),
          ),

          const SizedBox(height: 16),

          // ❤️ Health section only if a plant is selected
          if (selectedPlant != null)
            _buildHealthSection(screenWidth, selectedPlant.health)
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please select a plant to view details',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 🌿 The plant dropdown row (image + name + type)
  Widget _buildPlantRow(BuildContext context, GardenPlant plant) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Image
          Container(
            width: screenWidth * 0.10,
            height: screenWidth * 0.10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: plant.imagePath.isNotEmpty
                  ? _buildImagePreview(plant.imagePath)
                  : _buildPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: screenWidth < 350 ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth < 350 ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❤️ Health info row (separate section)
  Widget _buildHealthSection(double screenWidth, int health) {
    final color = _getHealthColor(health);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Health Status:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '$health%',
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth < 350 ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // 🌿 Image preview
  Widget _buildImagePreview(String imageUrlOrPath) {
    final isNetworkImage = imageUrlOrPath.startsWith('http');
    if (isNetworkImage) {
      return Image.network(
        imageUrlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (File(imageUrlOrPath).existsSync()) {
      return Image.file(
        File(imageUrlOrPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.local_florist, color: Colors.green),
    );
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../my_garden/widgets/add_plant_form_sheet.dart';
import '../../my_garden/db/database/garden_db.dart';
import '../provider/scan_provider.dart';

class AddToGardenButton extends StatelessWidget {
  final bool isFromHistory;
  final dynamic scannedPlant; // Your plant model type if defined
  final String? imagePath;

  const AddToGardenButton({
    Key? key,
    required this.isFromHistory,
    this.scannedPlant,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ScanProvider>();
    final plant = provider.plantResult;

    return Center(
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.secondaryGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              final String? plantName = isFromHistory
                  ? scannedPlant?.name
                  : plant?.name;

              if (plantName == null || plantName.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("⚠️ No valid plant data found."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // ✅ DUPLICATE CHECK
              final allPlants = GardenDB.getAllPlants();
              final alreadyExists = allPlants.any(
                    (p) => p.name.toLowerCase().trim() ==
                    plantName.toLowerCase().trim(),
              );

              if (alreadyExists) {
                // 🌿 Show message instead of opening form
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text("‘$plantName’ is already in your garden!"),
                      ],
                    ),
                    backgroundColor: Colors.orangeAccent,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                return;
              }

              // ✅ Not a duplicate — proceed as before
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  // 🪴 Case 1: Adding from history
                  if (isFromHistory && scannedPlant != null) {
                    return AddPlantFormSheet(
                      plantName: scannedPlant.name ?? "Unknown",
                      imageUrl: scannedPlant.imagePath ?? '',
                      description: scannedPlant.about ?? '',
                      scanId: scannedPlant.id,
                    );
                  }
                  // 🤖 Case 2: Adding new AI-identified plant
                  else if (plant != null) {
                    final imagePathToUse = imagePath ?? '';
                    return AddPlantFormSheet(
                      plantName: plant.name,
                      imageUrl: imagePathToUse,
                      description: plant.about.isNotEmpty
                          ? plant.about
                          : 'No description available.',
                      scanId: provider.lastScannedPlant?.id?.toString() ?? '',
                    );
                  }
                  // ⚠️ Case 3: No valid plant data
                  else {
                    return _buildNoPlantDataSheet();
                  }
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.energy_savings_leaf,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Add to My Garden",
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fallback sheet when no data exists
  Widget _buildNoPlantDataSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            "No plant data available to add.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

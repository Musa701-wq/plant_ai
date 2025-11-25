import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';

class StatsSection extends StatelessWidget {
  final List<GardenPlant> plants;

  const StatsSection({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    final totalPlants = plants.length;
    final healthyPlants = plants.where((plant) => plant.health >= 80).length;
    final needsAttention = plants.where((plant) => plant.health < 50).length;
    final normalPlants = plants.where((plant) => plant.health < 80 && plant.health >= 50).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(
            count: '$totalPlants',
            label: 'Total Plants',
            icon: Icons.eco,
          ),
          StatItem(
            count: '$healthyPlants',
            label: 'Healthy',
            icon: Icons.health_and_safety,
          ),
          StatItem(
            count: '$normalPlants',
            label: 'Normal',
            icon: Icons.health_and_safety,
          ),
          StatItem(
            count: '$needsAttention',
            label: 'Need Care',
            icon: Icons.warning_amber,
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const StatItem({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

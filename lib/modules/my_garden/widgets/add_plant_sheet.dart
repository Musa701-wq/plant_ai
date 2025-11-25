import 'package:flutter/material.dart';
import '../../../config/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class AddNewPlantSheet extends StatelessWidget {
  const AddNewPlantSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Add New Plant",
            style: AppTextStyles.headlineLarge
                .copyWith(color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 20),

          // Option 1: Search by name
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: const Icon(Icons.search, color: AppColors.primaryGreen),
            ),
            title: Text("Discover Plants by Category", style: AppTextStyles.headlineSmall),
            subtitle: Text(
              "Find a plant by typing its name",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          const Divider(height: 0),

          // Option 2: Scan plant
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
            ),
            title: Text("Scan Plant", style: AppTextStyles.headlineSmall),
            subtitle: Text(
              "Identify your plant using the camera",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.scan);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

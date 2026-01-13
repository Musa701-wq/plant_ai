import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import '../screen/SettingsPage.dart';

class HeaderSection extends StatelessWidget {
  final List<GardenPlant> plants;

  const HeaderSection({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    final needsWater = plants
        .where((p) =>
        p.reminders.any((r) =>
        r.isActive &&
            r.nextReminderDateTime != null &&
            r.nextReminderDateTime!
                .isBefore(DateTime.now().add(const Duration(days: 1)))))
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Plant Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                color: AppColors.textOnPrimary,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Garden',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Track and care for your plants',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // 👉 Settings Button (added)
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColors.textOnPrimary,
                size: 26,
              ),
              onPressed: () {
                // TODO: add navigation
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

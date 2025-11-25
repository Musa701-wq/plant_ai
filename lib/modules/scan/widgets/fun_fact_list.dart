import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import 'gradient_card.dart';

class FunFactsList extends StatelessWidget {
  final List<String> funFacts;

  const FunFactsList({
    Key? key,
    required this.funFacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (funFacts.isEmpty) {
      return GradientCard(
        child: Center(
          child: Text(
            "No fun facts available",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GradientCard(
      child: Column(
        children: funFacts.asMap().entries.map((entry) {
          final index = entry.key;
          final fact = entry.value;

          return Container(
            margin: EdgeInsets.only(
              bottom: index == funFacts.length - 1 ? 0 : 12,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌼 Icon Circle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppColors.accentYellow,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                // 📜 Fun Fact Text
                Expanded(
                  child: Text(
                    fact,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

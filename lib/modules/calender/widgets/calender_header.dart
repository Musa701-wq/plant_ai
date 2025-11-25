import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_style.dart';

class CalendarHeader extends StatelessWidget {
  final double screenWidth;
  final int reminderCount;
  final String activeFilter;
  final Function(String) onFilterChanged;

  const CalendarHeader({
    super.key,
    required this.screenWidth,
    required this.reminderCount,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.textOnPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant Care Calendar',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Never forget to care for your plants',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatsChip(reminderCount),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications, size: 16, color: AppColors.textOnPrimary),
          const SizedBox(width: 4),
          Text(
            '$count Reminders',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ["Today", "This Week", "All Reminders", "Completed",];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map((label) => _buildFilterChip(label, activeFilter == label))
            .toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Chip(
          backgroundColor: isActive
              ? AppColors.accentYellow
              : AppColors.textOnPrimary.withOpacity(0.2),
          label: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

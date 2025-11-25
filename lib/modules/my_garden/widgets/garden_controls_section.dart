import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class GardenControlsSection extends StatelessWidget {
  final String selectedFilter;
  final int selectedView;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int> onViewChanged;

  const GardenControlsSection({
    super.key,
    required this.selectedFilter,
    required this.selectedView,
    required this.onFilterChanged,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Filter Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  isExpanded: true,
                  items: ['All', 'Indoor', 'Outdoor',]
                      .map((filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(filter, style: AppTextStyles.bodyMedium),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onFilterChanged(value);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // View Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                _buildViewToggleButton(Icons.grid_view, 0),
                _buildViewToggleButton(Icons.list, 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, int index) {
    final isSelected = selectedView == index;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
        onPressed: () => onViewChanged(index),
      ),
    );
  }
}

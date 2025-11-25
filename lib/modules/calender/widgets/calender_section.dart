import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_style.dart';
import '../../my_garden/db/model/garden_plant.dart';
import '../provider/calender_provider.dart';

class CalendarSection extends StatelessWidget {
  final double screenWidth;
  final bool isSmallScreen;
  final CalendarProvider calendarProvider;
  final List<PlantReminder> reminders;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(DateTime, List<PlantReminder>) onDateTap;

  const CalendarSection({
    super.key,
    required this.screenWidth,
    required this.isSmallScreen,
    required this.calendarProvider,
    required this.reminders,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Top Month Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: Icon(Icons.chevron_left, color: AppColors.primaryGreen),
              ),
              Text(
                _getMonthYear(selectedDate),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: Icon(Icons.chevron_right, color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekDaysHeader(isSmallScreen),
          const SizedBox(height: 8),
          _buildCalendarGrid(context),
        ],
      ),
    );
  }

  // Weekday titles
  Widget _buildWeekDaysHeader(bool isSmallScreen) {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: weekDays
          .map(
            (day) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // Calendar Grid
  Widget _buildCalendarGrid(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final startingWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: isSmallScreen ? 0.8 : 1.0,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final day = index - startingWeekday + 1;
        final isCurrentMonth = day > 0 && day <= daysInMonth;

        final dateForCell = DateTime(
          selectedDate.year,
          selectedDate.month,
          day > 0 ? day : 1,
        );

        final isToday = isCurrentMonth &&
            day == DateTime.now().day &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.year == DateTime.now().year;

        // Get reminders for this date
        final dateReminders = reminders.where((r) => _isReminderOnDate(r, dateForCell)).toList();

        // Unique plant IDs for this date
        final uniquePlantIds = dateReminders.map((r) => r.plantId).toSet().toList();
        final hasReminders = uniquePlantIds.isNotEmpty;

        return GestureDetector(
          onTap: isCurrentMonth && hasReminders
              ? () => onDateTap(dateForCell, dateReminders)
              : null,
          child: _buildCalendarDay(
            day: isCurrentMonth ? day : null,
            isToday: isToday,
            hasReminders: hasReminders,
            plantCount: uniquePlantIds.length,
          ),
        );
      },
    );
  }

  // Calendar Day Cell
  Widget _buildCalendarDay({
    int? day,
    bool isToday = false,
    bool hasReminders = false,
    int plantCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryGreen : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day != null ? day.toString() : '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isToday ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          if (hasReminders && day != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                plantCount > 3 ? 3 : plantCount,
                    (index) => Container(
                  margin: const EdgeInsets.only(top: 2, right: 2),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _getDotColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helper Functions ---
  String _getMonthYear(DateTime date) => '${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  bool _isReminderOnDate(PlantReminder reminder, DateTime date) {
    // Include active reminders with scheduled dates
    if (reminder.isActive && reminder.nextReminderDateTime != null) {
      final reminderDate = DateTime(
        reminder.nextReminderDateTime!.year,
        reminder.nextReminderDateTime!.month,
        reminder.nextReminderDateTime!.day,
      );
      final compareDate = DateTime(date.year, date.month, date.day);
      return reminderDate.isAtSameMomentAs(compareDate);
    }
    
    // Include completed reminders that were completed on this date
    if (!reminder.isActive && reminder.lastCompletedDate != null) {
      final completedDate = DateTime(
        reminder.lastCompletedDate!.year,
        reminder.lastCompletedDate!.month,
        reminder.lastCompletedDate!.day,
      );
      final compareDate = DateTime(date.year, date.month, date.day);
      return completedDate.isAtSameMomentAs(compareDate);
    }
    
    return false;
  }

  Color _getDotColor(int index) {
    final colors = [
      AppColors.accentOrange,
      AppColors.primaryGreen,
      AppColors.accentYellow,
    ];
    return colors[index % colors.length];
  }
}

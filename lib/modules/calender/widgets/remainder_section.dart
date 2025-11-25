import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_style.dart';
import '../../my_garden/db/model/garden_plant.dart';
import '../../my_garden/provider/garden_provider.dart';


class ReminderSection extends StatelessWidget {
  final String activeFilter;
  final List<PlantReminder> filteredReminders;
  final GardenProvider gardenProvider;
  final Function(PlantReminder) onShowDetails;

  const ReminderSection({
    super.key,
    required this.activeFilter,
    required this.filteredReminders,
    required this.gardenProvider,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Text(
                '$activeFilter Reminders',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  filteredReminders.length.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reminder List
          if (filteredReminders.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true, // 👈 makes it work inside scroll view
              physics: const NeverScrollableScrollPhysics(), // disable inner scroll
              itemCount: filteredReminders.length,
              itemBuilder: (context, index) {
                return _buildReminderCard(
                  context,
                  filteredReminders[index],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No $activeFilter Reminders',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add reminders to keep your plants\nhealthy and happy!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, PlantReminder reminder) {
    final displayDt = _reminderDateTimeForDisplay(reminder);
    final repeatLabel = '${reminder.repeatInterval} ${reminder.repeatType}';

    return GestureDetector(
      onTap: () => onShowDetails(reminder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: reminder.isActive ? AppColors.backgroundWhite : AppColors.backgroundCard.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: reminder.isActive
                    ? AppColors.success
                    : AppColors.accentOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: reminder.isActive 
                    ? AppColors.backgroundCard
                    : AppColors.backgroundCard.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.eco,
                  color: reminder.isActive ? AppColors.primaryGreen : AppColors.textHint, 
                  size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.plantName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: reminder.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                      decoration: reminder.isActive
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminder.task,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: reminder.isActive ? AppColors.textSecondary : AppColors.textHint,
                      decoration: reminder.isActive
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.jm().format(displayDt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      if (!reminder.isActive) ...[  
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            gardenProvider.updateReminderStatus(
                              reminder.plantId,
                              reminder.id,
                              true,
                            ).then((_) {
                              // Force rebuild to show updated status
                              gardenProvider.notifyListeners();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 12,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reactivate',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.repeat,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        repeatLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await gardenProvider.updateReminderStatus(
                      reminder.plantId,
                      reminder.id,
                      !reminder.isActive,
                    );
                  },
                  icon: Icon(
                    reminder.isActive ? Icons.check_circle : Icons.refresh,
                    color: reminder.isActive
                        ? AppColors.success
                        : AppColors.textHint,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await gardenProvider.deleteReminder(
                      reminder.plantId,
                      reminder.id,
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _reminderDateTimeForDisplay(PlantReminder r) {
    try {
      if (r.time.year <= 0) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
      } else {
        return r.time;
      }
    } catch (_) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
    }
  }
}

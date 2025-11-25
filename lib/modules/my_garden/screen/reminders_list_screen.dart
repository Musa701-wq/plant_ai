// lib/modules/my_garden/screen/reminders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import '../provider/garden_provider.dart';
import '../helper/plant_reminder_utils.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  bool _showCompleted = false;
  bool _showActive = true;
  String _taskFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("All Reminders"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSummary(),
          Expanded(
            child: Consumer<GardenProvider>(
              builder: (context, provider, _) {
                return FutureBuilder<List<PlantReminder>>(
                  future: provider.getFilteredReminders(
                    showCompleted: _showCompleted ? true : null,
                    showActive: _showActive ? true : null,
                    taskFilter: _taskFilter.isNotEmpty ? _taskFilter : null,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }

                    final reminders = snapshot.data ?? [];

                    if (reminders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reminders found',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or add some reminders',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        return _buildReminderCard(context, provider, reminders[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary() {
    final activeFilters = <String>[];
    if (_showCompleted) activeFilters.add('Completed');
    if (_showActive) activeFilters.add('Active');
    if (_taskFilter.isNotEmpty) activeFilters.add(_taskFilter);

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryGreen.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filters: ${activeFilters.join(', ')}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, GardenProvider provider, PlantReminder reminder) {
    final isCompleted = reminder.isAllRoundsCompleted;
    final isOverdue = reminder.nextReminderDateTime?.isBefore(DateTime.now()) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? Colors.green.shade200
                : isOverdue
                    ? Colors.red.shade200
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTaskColor(reminder.task).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reminder.task,
                      style: AppTextStyles.caption.copyWith(
                        color: _getTaskColor(reminder.task),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20)
                  else if (!reminder.isActive)
                    Icon(Icons.pause_circle_outline, color: AppColors.textHint, size: 20)
                  else if (isOverdue)
                    Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                ],
              ),
              
              const SizedBox(height: 8),

              // Plant Name and Progress
              Text(
                reminder.plantName,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                reminder.completionStatus,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),

              if (!isCompleted && reminder.isActive) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      reminder.timeUntilNext(),
                      style: AppTextStyles.caption.copyWith(
                        color: isOverdue ? Colors.red.shade600 : AppColors.textHint,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],

              if (reminder.nextReminderDateTime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy - h:mm a').format(reminder.nextReminderDateTime!),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  if (!isCompleted && reminder.isActive) ...[
                    ElevatedButton.icon(
                      onPressed: () => _completeReminder(provider, reminder),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  if (isCompleted) ...[
                    OutlinedButton.icon(
                      onPressed: () => _resetReminder(provider, reminder),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Restart'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  OutlinedButton.icon(
                    onPressed: () => _toggleReminderStatus(provider, reminder),
                    icon: Icon(
                      reminder.isActive ? Icons.pause : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(reminder.isActive ? 'Pause' : 'Resume'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: reminder.isActive ? Colors.orange : AppColors.primaryGreen,
                      side: BorderSide(
                        color: reminder.isActive ? Colors.orange : AppColors.primaryGreen,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () => _deleteReminder(provider, reminder),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTaskColor(String task) {
    switch (task.toLowerCase()) {
      case 'watering': return Colors.blue.shade600;
      case 'fertilizing': return Colors.orange.shade600;
      case 'misting': return Colors.cyan.shade600;
      case 'rotating': return Colors.purple.shade600;
      default: return AppColors.primaryGreen;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reminders'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Show Active'),
                value: _showActive,
                onChanged: (value) => setDialogState(() => _showActive = value ?? true),
              ),
              CheckboxListTile(
                title: const Text('Show Completed'),
                value: _showCompleted,
                onChanged: (value) => setDialogState(() => _showCompleted = value ?? false),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Task Filter',
                  hintText: 'e.g., Watering, Fertilizing',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setDialogState(() => _taskFilter = value),
                controller: TextEditingController(text: _taskFilter),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _showCompleted = false;
      _showActive = true;
      _taskFilter = '';
    });
  }

  void _completeReminder(GardenProvider provider, PlantReminder reminder) async {
    try {
      await provider.completeReminder(reminder.plantId, reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder.task} completed! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetReminder(GardenProvider provider, PlantReminder reminder) async {
    try {
      await provider.resetReminder(reminder.plantId, reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder.task} reminder restarted! 🔄'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleReminderStatus(GardenProvider provider, PlantReminder reminder) async {
    try {
      await provider.updateReminderStatus(reminder.plantId, reminder.id, !reminder.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${reminder.task} reminder ${!reminder.isActive ? 'resumed' : 'paused'}',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteReminder(GardenProvider provider, PlantReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete the ${reminder.task} reminder for ${reminder.plantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deleteReminder(reminder.plantId, reminder.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${reminder.task} reminder deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting reminder: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

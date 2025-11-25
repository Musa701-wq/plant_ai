import 'dart:async';
import 'package:flutter/material.dart';
import '../../my_garden/db/model/garden_plant.dart';
import '../../my_garden/provider/garden_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final GardenProvider gardenProvider;
  StreamSubscription? _reminderSub;

  CalendarProvider({required this.gardenProvider});

  // --- UI state ---
  String _activeFilter = "Today";
  DateTime _selectedDate = DateTime.now();
  bool _showCompletedReminders = false;

  List<PlantReminder> _allReminders = [];
  bool _isLoading = true;

  // --- Getters ---
  String get activeFilter => _activeFilter;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get showCompletedReminders => _showCompletedReminders;
  List<PlantReminder> get allReminders => _allReminders;

  List<PlantReminder> get filteredReminders =>
      _filterReminders(_allReminders, _activeFilter);

  // --- Initialization ---
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Initial load
    _allReminders = await gardenProvider.getAllReminders();
    _isLoading = false;
    notifyListeners();

    // 🔄 Live updates (auto-refresh UI when Hive box changes)
    _reminderSub?.cancel();
    _reminderSub = gardenProvider.remindersStream.listen((reminders) {
      _allReminders = reminders;
      notifyListeners();
    });
  }

  // --- Cleanup ---
  @override
  void dispose() {
    _reminderSub?.cancel();
    super.dispose();
  }

  // --- Filter Change ---
  void changeFilter(String newFilter) {
    if (newFilter == _activeFilter) return;
    _activeFilter = newFilter;
    notifyListeners();
  }

  // --- Month Navigation ---
  void previousMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    notifyListeners();
  }

  // --- Refresh Data from GardenProvider (manual fallback) ---
  Future<void> refreshReminders() async {
    _allReminders = await gardenProvider.getAllReminders();
    notifyListeners();
  }

  // --- Toggle completed reminders visibility ---
  void toggleShowCompletedReminders() {
    _showCompletedReminders = !_showCompletedReminders;
    notifyListeners();
  }

  // --- Complete reminder from calendar ---
  Future<void> completeReminderFromCalendar(PlantReminder reminder) async {
    try {
      await gardenProvider.completeReminder(
        reminder.plantId,
        reminder.id,
        completedAt: DateTime.now(),
      );
      await refreshReminders();
    } catch (e) {
      debugPrint('[CalendarProvider] Error completing reminder: $e');
      rethrow;
    }
  }

  // --- Reactivate reminder from calendar ---
  Future<void> reactivateReminderFromCalendar(PlantReminder reminder) async {
    try {
      await gardenProvider.updateReminderStatus(
        reminder.plantId,
        reminder.id,
        true,
      );
      await refreshReminders();
    } catch (e) {
      debugPrint('[CalendarProvider] Error reactivating reminder: $e');
      rethrow;
    }
  }

  // --- Filtering Logic ---
  List<PlantReminder> _filterReminders(
      List<PlantReminder> reminders, String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case "Today":
        return reminders.where((r) {
          if (!r.isActive || r.nextReminderDateTime == null) return false;
          final reminderDate = DateTime(
            r.nextReminderDateTime!.year,
            r.nextReminderDateTime!.month,
            r.nextReminderDateTime!.day,
          );
          return reminderDate == today;
        }).toList();

    // 🧹 Removed “Upcoming” — unnecessary

      case "This Week":
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return reminders.where((r) {
          if (!r.isActive || r.nextReminderDateTime == null) return false;
          return r.nextReminderDateTime!.isAfter(startOfWeek) &&
              r.nextReminderDateTime!.isBefore(endOfWeek);
        }).toList();

      case "All Reminders":
        return reminders.where((r) => r.isActive).toList();

      case "Completed":
        return reminders.where(
              (r) => !r.isActive || (r.isAllRoundsCompleted ?? false),
        ).toList();

      default:
        return reminders.where((r) => r.isActive).toList();
    }
  }
}

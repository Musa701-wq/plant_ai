// lib/providers/garden_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../services/notification/notification_service.dart';
import '../db/model/garden_plant.dart';
import '../helper/plant_reminder_utils.dart';

class GardenProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  Box<GardenPlant>? _plantsBox;
  bool isSaving = false;

  /// Ensure Hive box is open before any action
  Future<void> _ensureBox() async {
    if (_plantsBox != null && _plantsBox!.isOpen) return;

    if (!Hive.isBoxOpen('garden_plants')) {
      _plantsBox = await Hive.openBox<GardenPlant>('garden_plants');
    } else {
      _plantsBox = Hive.box<GardenPlant>('garden_plants');
    }
  }

  List<GardenPlant> get plants => _plantsBox?.values.toList() ?? [];

  Future<void> init() async {
    await _ensureBox();
    await _updatePastReminders();
    notifyListeners();
  }

  String generateId() => _uuid.v4();

  /// --------------------------
  // 🌱 CRUD: Plants
  /// --------------------------

  Future<String?> addPlant(GardenPlant plant) async {
    await _ensureBox();
    // 🧠 Prevent duplicates
    final exists = _plantsBox!.values.any(
          (p) => p.name.trim().toLowerCase() == plant.name.trim().toLowerCase(),
    );

    if (exists) {
      debugPrint("⚠️ Duplicate plant detected: ${plant.name}");
      return "duplicate";
    }
    await _plantsBox!.put(plant.id, plant);
    debugPrint('[GardenProvider] addPlant -> saved plant ${plant.id}');
    notifyListeners();
  }

  Future<void> deletePlant(String id) async {
    await _ensureBox();
    await _plantsBox!.delete(id);
    debugPrint('[GardenProvider] deletePlant -> removed plant $id');
    notifyListeners();
  }

  /// --------------------------
  // ⏰ CRUD: Reminders
  /// --------------------------

  /// ✅ Add a new reminder (save immediately, schedule notifications asynchronously)
  Future<void> addReminder(String plantId, PlantReminder reminder) async {
    await _ensureBox();
    isSaving = true;
    notifyListeners();

    try {
      final plant = _plantsBox?.get(plantId);
      if (plant == null) {
        debugPrint('[GardenProvider] addReminder -> plant not found: $plantId');
        return;
      }

      // 1️⃣ Compute nextReminderDateTime (centralized)
      final updatedReminder = reminder.updatedNextReminder();
      // 2️⃣ Save immediately with placeholder notificationIds to avoid UI blocking
      final placeholder = updatedReminder.copyWith(notificationIds: <int>[]);
      final updatedReminders = List<PlantReminder>.from(plant.reminders)..add(placeholder);
      plant.reminders = updatedReminders;
      await plant.save();

      debugPrint('[GardenProvider] addReminder -> saved reminder ${placeholder.id} (placeholder). next: ${placeholder.nextReminderDateTime}');
      notifyListeners();

      // 3️⃣ Schedule notifications asynchronously (do not block UI)
      unawaited(_asyncScheduleAndSave(plantId, placeholder));
    } catch (e, st) {
      debugPrint('[GardenProvider] addReminder ERROR: $e\n$st');
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // database: schedule then update the saved reminder with notification ids
  Future<void> _asyncScheduleAndSave(String plantId, PlantReminder placeholder) async {
    try {
      debugPrint('[GardenProvider] scheduling notifications for reminder ${placeholder.id} (async)...');
      // ensure NotificationService initialized
      await NotificationService.instance.init();

      // Schedule next occurrences (this can take some time)
      List<int>? ids;
      try {
        ids = await NotificationService.instance.scheduleMultipleOccurrences(placeholder);
      } catch (e, st) {
        debugPrint('[GardenProvider] scheduling failed for ${placeholder.id}: $e\n$st');
        ids = <int>[];
      }

      // Update the saved reminder in the Hive box
      await _ensureBox();
      final plant = _plantsBox?.get(plantId);
      if (plant == null) {
        debugPrint('[GardenProvider] _asyncScheduleAndSave -> plant removed before scheduling: $plantId');
        return;
      }

      final index = plant.reminders.indexWhere((r) => r.id == placeholder.id);
      if (index == -1) {
        debugPrint('[GardenProvider] _asyncScheduleAndSave -> reminder not found in plant ${plantId}');
        return;
      }

      final updated = plant.reminders[index].copyWith(notificationIds: ids);
      plant.reminders[index] = updated;
      await plant.save();

      debugPrint('[GardenProvider] _asyncScheduleAndSave -> reminder ${placeholder.id} updated with notificationIds: $ids');
      notifyListeners();
    } catch (e, st) {
      debugPrint('[GardenProvider] _asyncScheduleAndSave ERROR: $e\n$st');
    }
  }

  /// ✅ Update existing reminder
  Future<void> updateReminder(String plantId, PlantReminder updatedReminder) async {
    await _ensureBox();
    final plant = _plantsBox?.get(plantId);
    if (plant == null) {
      debugPrint('[GardenProvider] updateReminder -> plant not found: $plantId');
      return;
    }

    final index = plant.reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index == -1) {
      debugPrint('[GardenProvider] updateReminder -> reminder not found: ${updatedReminder.id}');
      return;
    }

    debugPrint('[GardenProvider] updateReminder -> canceling old notifications for ${updatedReminder.id}');
    // Cancel old notifications (synchronous await)
    await NotificationService.instance.cancelReminderNotifications(plant.reminders[index]);

    // Immediately update saved reminder with recomputed next and placeholder ids to prevent UI freeze
    final recomputed = updatedReminder.updatedNextReminder();
    final placeholder = recomputed.copyWith(notificationIds: <int>[]);
    plant.reminders[index] = placeholder;
    await plant.save();
    debugPrint('[GardenProvider] updateReminder -> saved placeholder for ${placeholder.id}. next: ${placeholder.nextReminderDateTime}');
    notifyListeners();

    // Schedule asynchronously and update saved entry
    unawaited(_asyncScheduleAndUpdate(plantId, placeholder));
  }

  Future<void> _asyncScheduleAndUpdate(String plantId, PlantReminder reminder) async {
    try {
      debugPrint('[GardenProvider] async re-schedule for ${reminder.id}');
      await NotificationService.instance.init();
      List<int>? ids;
      try {
        ids = await NotificationService.instance.scheduleMultipleOccurrences(reminder);
      } catch (e, st) {
        debugPrint('[GardenProvider] scheduleMultipleOccurrences error (update): $e\n$st');
        ids = <int>[];
      }

      await _ensureBox();
      final plant = _plantsBox?.get(plantId);
      if (plant == null) return;

      final index = plant.reminders.indexWhere((r) => r.id == reminder.id);
      if (index == -1) return;

      plant.reminders[index] = plant.reminders[index].copyWith(notificationIds: ids);
      await plant.save();

      debugPrint('[GardenProvider] _asyncScheduleAndUpdate -> reminder ${reminder.id} updated with ids: $ids');
      notifyListeners();
    } catch (e, st) {
      debugPrint('[GardenProvider] _asyncScheduleAndUpdate ERROR: $e\n$st');
    }
  }

  /// ✅ Delete reminder
  Future<void> deleteReminder(String plantId, String reminderId) async {
    await _ensureBox();
    final plant = _plantsBox?.get(plantId);
    if (plant == null) {
      debugPrint('[GardenProvider] deleteReminder -> plant not found: $plantId');
      return;
    }

    final reminder = plant.reminders.firstWhere(
          (r) => r.id == reminderId,
      orElse: () => throw Exception('Reminder not found'),
    );

    debugPrint('[GardenProvider] deleteReminder -> canceling notifications for $reminderId');
    await NotificationService.instance.cancelReminderNotifications(reminder);

    plant.reminders.removeWhere((r) => r.id == reminderId);
    await plant.save();
    debugPrint('[GardenProvider] deleteReminder -> removed reminder $reminderId from plant $plantId');
    notifyListeners();
  }

  /// ✅ Enable / disable reminder
  Future<void> updateReminderStatus(String plantId, String reminderId, bool isActive) async {
    await _ensureBox();
    final plant = _plantsBox?.get(plantId);
    if (plant == null) {
      debugPrint('[GardenProvider] updateReminderStatus -> plant not found: $plantId');
      return;
    }

    final index = plant.reminders.indexWhere((r) => r.id == reminderId);
    if (index == -1) {
      debugPrint('[GardenProvider] updateReminderStatus -> reminder not found: $reminderId');
      return;
    }

    final reminder = plant.reminders[index];

    if (!isActive) {
      debugPrint('[GardenProvider] updateReminderStatus -> disabling reminder $reminderId and cancelling notifications');
      await NotificationService.instance.cancelReminderNotifications(reminder);
      plant.reminders[index] = reminder.copyWith(isActive: false, notificationIds: []);
    } else {
      debugPrint('[GardenProvider] updateReminderStatus -> enabling reminder $reminderId and scheduling');
      final recomputed = reminder.copyWith(isActive: true).updatedNextReminder();
      // Save placeholder then schedule async
      plant.reminders[index] = recomputed.copyWith(notificationIds: <int>[]);
      await plant.save();
      unawaited(_asyncScheduleAndUpdate(plantId, recomputed));
    }

    await plant.save();
    notifyListeners();
  }

  /// 🎯 Mark reminder as completed for current round
  Future<void> completeReminder(String plantId, String reminderId, {DateTime? completedAt}) async {
    await _ensureBox();
    final plant = _plantsBox?.get(plantId);
    if (plant == null) {
      debugPrint('[GardenProvider] completeReminder -> plant not found: $plantId');
      return;
    }

    final index = plant.reminders.indexWhere((r) => r.id == reminderId);
    if (index == -1) {
      debugPrint('[GardenProvider] completeReminder -> reminder not found: $reminderId');
      return;
    }

    final reminder = plant.reminders[index];
    debugPrint('[GardenProvider] completeReminder -> marking ${reminder.task} as completed for plant ${plant.name}');

    // Cancel current notifications first
    await NotificationService.instance.cancelReminderNotifications(reminder);

    // Get the next reminder after completion (with auto-rescheduling logic)
    final nextReminder = reminder.getNextAfterCompletion(completedAt: completedAt);
    
    if (nextReminder == null) {
      debugPrint('[GardenProvider] completeReminder -> all rounds completed, removing reminder');
      plant.reminders.removeAt(index);
    } else if (!nextReminder.isActive) {
      debugPrint('[GardenProvider] completeReminder -> all rounds completed, deactivating reminder');
      plant.reminders[index] = nextReminder;
    } else {
      debugPrint('[GardenProvider] completeReminder -> scheduling next occurrence');
      // Save the updated reminder with placeholder notification IDs
      plant.reminders[index] = nextReminder.copyWith(notificationIds: <int>[]);
      await plant.save();
      notifyListeners();
      
      // Schedule notifications for the next occurrence asynchronously
      unawaited(_asyncScheduleAndUpdate(plantId, nextReminder));
      return; // Early return to avoid duplicate save/notify
    }

    await plant.save();
    notifyListeners();
  }

  /// 🔄 Reset a completed reminder to start over
  Future<void> resetReminder(String plantId, String reminderId) async {
    await _ensureBox();
    final plant = _plantsBox?.get(plantId);
    if (plant == null) {
      debugPrint('[GardenProvider] resetReminder -> plant not found: $plantId');
      return;
    }

    final index = plant.reminders.indexWhere((r) => r.id == reminderId);
    if (index == -1) {
      debugPrint('[GardenProvider] resetReminder -> reminder not found: $reminderId');
      return;
    }

    final reminder = plant.reminders[index];
    debugPrint('[GardenProvider] resetReminder -> resetting ${reminder.task} for plant ${plant.name}');

    // Cancel old notifications
    await NotificationService.instance.cancelReminderNotifications(reminder);

    // Reset the reminder to active state
    final resetReminder = reminder.resetToActive();
    plant.reminders[index] = resetReminder.copyWith(notificationIds: <int>[]);
    await plant.save();
    notifyListeners();

    // Schedule new notifications asynchronously
    unawaited(_asyncScheduleAndUpdate(plantId, resetReminder));
  }

  /// 📊 Get reminders filtered by completion status
  Future<List<PlantReminder>> getFilteredReminders({
    bool? showCompleted,
    bool? showActive,
    String? taskFilter,
  }) async {
    await _ensureBox();
    final allReminders = await getAllReminders();

    return allReminders.where((reminder) {
      // Filter by completion status
      if (showCompleted != null) {
        final isCompleted = reminder.isAllRoundsCompleted;
        if (showCompleted && !isCompleted) return false;
        if (!showCompleted && isCompleted) return false;
      }

      // Filter by active status
      if (showActive != null) {
        if (showActive && !reminder.isActive) return false;
        if (!showActive && reminder.isActive) return false;
      }

      // Filter by task type
      if (taskFilter != null && taskFilter.isNotEmpty) {
        if (!reminder.task.toLowerCase().contains(taskFilter.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// --------------------------
  // 📅 Aggregation / Auto-updates
  /// --------------------------

  /// Get all reminders across all plants
  Future<List<PlantReminder>> getAllReminders() async {
    await _ensureBox();
    await _updatePastReminders();

    final allPlants = _plantsBox?.values.toList() ?? [];
    final allReminders = <PlantReminder>[];

    for (var plant in allPlants) {
      for (var reminder in plant.reminders) {
        reminder.plantName = plant.name;
        allReminders.add(reminder);
      }
    }

    allReminders.sort((a, b) {
      final aDate = a.nextReminderDateTime ?? a.time;
      final bDate = b.nextReminderDateTime ?? b.time;
      return aDate.compareTo(bDate);
    });
    return allReminders;
  }

  /// Auto-update nextReminderDateTime if outdated
  Future<void> _updatePastReminders() async {
    await _ensureBox();
    final now = DateTime.now();
    bool hasUpdates = false;

    for (var plant in plants) {
      bool updated = false;

      for (var i = 0; i < plant.reminders.length; i++) {
        final r = plant.reminders[i];
        if (!r.isActive) continue;

        final next = r.nextOccurrence(from: now);
        final stored = r.nextReminderDateTime;

        if (stored == null || !stored.isAtSameMomentAs(next)) {
          plant.reminders[i] = r.copyWith(
            time: next,
            nextReminderDateTime: next,
          );
          updated = true;
        }
      }

      if (updated) {
        await plant.save();
        hasUpdates = true;
      }
    }

    if (hasUpdates) notifyListeners();
  }

  /// -------------------------
  // 🌱 Reminder Form State
  /// -------------------------
  String? selectedTask;
  String? repeatType;
  int? repeatInterval;
  TimeOfDay? selectedTime;
  int? selectedRounds;
  String? selectedPrevFertilizingLabel;
  DateTime? selectedPrevFertilizingDate;
  DateTime? _upcomingReminderDate;

  DateTime? get upcomingReminderDate => _upcomingReminderDate;

  bool get isFormValid =>
      selectedTask != null &&
          repeatType != null &&
          repeatInterval != null &&
          selectedTime != null &&
          (selectedTask == "Fertilizing" ? selectedPrevFertilizingLabel != null : true);

  void selectTask(String task) {
    selectedTask = task;
    _recalculateUpcomingReminder();
  }

  void setRepeat(String type, int? interval) {
    repeatType = type;
    repeatInterval = interval;
    _recalculateUpcomingReminder();
  }

  void setTime(TimeOfDay time) {
    selectedTime = time;
    _recalculateUpcomingReminder();
  }

  void setRounds(int rounds) {
    selectedRounds = rounds;
    notifyListeners();
  }

  void setPreviousFertilizing(String label, DateTime date) {
    selectedPrevFertilizingLabel = label;
    selectedPrevFertilizingDate = date;
    _recalculateUpcomingReminder();
  }

  void _recalculateUpcomingReminder() {
    if (selectedTask == null || repeatType == null || repeatInterval == null) {
      _upcomingReminderDate = null;
      notifyListeners();
      return;
    }

    final time = selectedTime ?? const TimeOfDay(hour: 8, minute: 0);
    final prevDate = selectedPrevFertilizingDate ?? DateTime.now();
    final prevLabel = selectedPrevFertilizingLabel ?? "Today";

    final reminder = PlantReminder(
      id: generateId(),
      task: selectedTask!,
      frequency: "$repeatInterval ${repeatType!.toLowerCase()}",
      isActive: true,
      repeatType: repeatType!,
      repeatInterval: repeatInterval!,
      time: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      ),
      previousFertilizingLabel:
      selectedTask == "Fertilizing" ? prevLabel : null,
      previousFertilizingDate:
      selectedTask == "Fertilizing" ? prevDate : null,
      plantId: "",
      plantName: "",
    );

    _upcomingReminderDate = reminder.calculateNextReminder();
    notifyListeners();
  }

  // inside GardenProvider
  Stream<List<PlantReminder>> get remindersStream async* {
    yield await getAllReminders();
    yield* Hive.box<GardenPlant>('garden_plants').watch().asyncMap((_) async {
      return await getAllReminders();
    });
  }


  void resetReminderForm() {
    selectedTask = null;
    repeatType = null;
    repeatInterval = null;
    selectedTime = null;
    selectedRounds = null;
    selectedPrevFertilizingLabel = null;
    selectedPrevFertilizingDate = null;
    _upcomingReminderDate = null;
    notifyListeners();
  }

  // --------------------------
// 🌿 UI State Helpers
// --------------------------

  GardenPlant? _selectedPlant;
  GardenPlant? get selectedPlant => _selectedPlant;

  /// Set currently selected plant for reminder dropdown
  void selectPlant(GardenPlant plant) {
    _selectedPlant = plant;
    notifyListeners();
  }

  /// Optional helper to clear selection
  void clearSelectedPlant() {
    _selectedPlant = null;
    notifyListeners();
  }
}

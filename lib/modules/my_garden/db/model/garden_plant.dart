import 'package:hive/hive.dart';

import '../../../scan/db/model/scanned_plant.dart';
import '../../../scan/gemini/model/plant_model.dart';
part 'garden_plant.g.dart';

@HiveType(typeId: 1)
class GardenPlant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // indoor, outdoor, etc.

  @HiveField(3)
  String imagePath; // local file path OR base64 string

  @HiveField(4)
  DateTime addedDate;

  @HiveField(5)
  int health;

  @HiveField(6)
  List<PlantReminder> reminders;

  // NEW: optional link to ScannedPlant id
  @HiveField(7)
  final String? scanId;

  // 🆕 NEW: locally cached plant details
  @HiveField(8)
  ScannedPlant? cachedPlantDetails;

  GardenPlant({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.addedDate,
    required this.health,
    required this.reminders,
    this.scanId,
    this.cachedPlantDetails,
  });
}

@HiveType(typeId: 2)
class PlantReminder {
  @HiveField(0)
  String task; // e.g. watering, fertilizing, misting, rotating

  @HiveField(1)
  String frequency; // legacy field (keep for backward compatibility)

  @HiveField(2)
  bool isActive;

  // 🆕 New Fields (do not rename existing ones)
  @HiveField(3)
  String id; // unique reminder id

  @HiveField(4)
  String repeatType; // 'day', 'week', 'month'

  @HiveField(5)
  int repeatInterval; // e.g. every 2 days

  @HiveField(6)
  DateTime time; // exact reminder time with AM/PM

  @HiveField(7)
  String? previousFertilizingLabel; // e.g. 'Today', '1 week ago'

  @HiveField(8)
  DateTime? previousFertilizingDate; // actual computed date

  @HiveField(9)
  List<int>? notificationIds; // placeholder for local notification link

  // 🆕 Added Fields
  @HiveField(10)
  String plantId; // which plant this reminder belongs to

  @HiveField(11)
  String plantName; // store the real plant name for easy display

  @HiveField(12)
  bool isCompleted; // to track completion status of the task

  // 🆕 Added Field
  @HiveField(13)
  DateTime? nextReminderDateTime;

  // 🆕 Completion Tracking Fields
  @HiveField(14)
  int totalRounds; // Total number of rounds user wants for this reminder

  @HiveField(15)
  int completedRounds; // Number of rounds completed so far

  @HiveField(16)
  List<DateTime>? completedDates; // Dates when each round was completed

  @HiveField(17)
  DateTime? lastCompletedDate; // Last completion date for easy access

  PlantReminder({
    required this.task,
    required this.frequency,
    required this.isActive,
    required this.id,
    required this.repeatType,
    required this.repeatInterval,
    required this.time,
    this.previousFertilizingLabel,
    this.previousFertilizingDate,
    this.notificationIds,
    required this.plantId,
    required this.plantName,
    this.isCompleted = false,
    this.nextReminderDateTime,
    this.totalRounds = 1, // Default to 1 round (infinite until user stops)
    this.completedRounds = 0,
    this.completedDates,
    this.lastCompletedDate,
  });

  // Convenience getter to simplify your calendar comparisons
  DateTime get dateTimeUtc => time.toUtc();


  // 🧮 Helper function to calculate next reminder
  DateTime calculateNextReminder() {
    DateTime baseDate = previousFertilizingDate ?? DateTime.now();
    switch (repeatType) {
      case 'day':
      case 'days':
        return baseDate.add(Duration(days: repeatInterval));
      case 'weeks':
      case 'week':
        return baseDate.add(Duration(days: 7 * repeatInterval));
      case 'month':
      case 'months':
        return DateTime(
          baseDate.year,
          baseDate.month + repeatInterval,
          baseDate.day,
          time.hour,
          time.minute,
        );
      default:
        return baseDate;
    }
  }

  // 📊 Completion tracking helpers
  bool get isAllRoundsCompleted => totalRounds > 0 && completedRounds >= totalRounds;
  bool get isInfiniteRounds => totalRounds <= 0; // 0 or negative means infinite
  int get remainingRounds => isInfiniteRounds ? -1 : (totalRounds - completedRounds);
  double get completionProgress => totalRounds <= 0 ? 0.0 : (completedRounds / totalRounds);
  
  // 📅 Check if reminder should auto-reschedule (not all rounds complete)
  bool get shouldAutoReschedule => isInfiniteRounds || !isAllRoundsCompleted;
}

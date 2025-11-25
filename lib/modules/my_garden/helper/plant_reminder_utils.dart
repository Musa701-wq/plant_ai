// lib/modules/my_garden/database/plant_reminder_utils.dart

import 'package:flutter/foundation.dart';
import '../db/model/garden_plant.dart';

enum RepeatUnit { days, weeks, months }

extension RepeatUnitExt on RepeatUnit {
  String toStorage() => toString().split('.').last;

  static RepeatUnit fromString(String s) {
    s = s.toLowerCase();
    if (s.startsWith('day')) return RepeatUnit.days;
    if (s.startsWith('week')) return RepeatUnit.weeks;
    return RepeatUnit.months;
  }
}

extension PlantReminderUtils on PlantReminder {
  PlantReminder copyWith({
    String? task,
    String? frequency,
    bool? isActive,
    String? id,
    String? repeatType,
    int? repeatInterval,
    DateTime? time,
    String? previousFertilizingLabel,
    DateTime? previousFertilizingDate,
    List<int>? notificationIds,
    String? plantId,
    String? plantName,
    bool? isCompleted,
    DateTime? nextReminderDateTime,
    int? totalRounds,
    int? completedRounds,
    List<DateTime>? completedDates,
    DateTime? lastCompletedDate,
  }) {
    return PlantReminder(
      task: task ?? this.task,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      id: id ?? this.id,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      time: time ?? this.time,
      previousFertilizingLabel: previousFertilizingLabel ?? this.previousFertilizingLabel,
      previousFertilizingDate: previousFertilizingDate ?? this.previousFertilizingDate,
      notificationIds: notificationIds ?? this.notificationIds,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      isCompleted: isCompleted ?? this.isCompleted,
      nextReminderDateTime: nextReminderDateTime ?? this.nextReminderDateTime,
      totalRounds: totalRounds ?? this.totalRounds,
      completedRounds: completedRounds ?? this.completedRounds,
      completedDates: completedDates ?? this.completedDates,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  /// --- Core centralized function ---
  /// Returns the next reminder datetime after [from].
  DateTime nextOccurrence({DateTime? from}) {
    final now = from ?? DateTime.now();
    final RepeatUnit unit = RepeatUnitExt.fromString(repeatType);
    DateTime base;

    // Fertilizing uses previousFertilizingDate if available
    if (task.toLowerCase() == 'fertilizing' && previousFertilizingDate != null) {
      base = previousFertilizingDate!;
    } else {
      base = time;
    }

    // Normalize to same time of day with proper time handling
    DateTime candidate = DateTime(base.year, base.month, base.day, time.hour, time.minute);
    
    // Handle edge case where base time is malformed (e.g., year <= 1970)
    if (base.year <= 1970) {
      final today = DateTime.now();
      candidate = DateTime(today.year, today.month, today.day, time.hour, time.minute);
    }

    // Safety counter to prevent infinite loops
    int safetyCounter = 0;
    const maxIterations = 366; // Maximum reasonable iterations for a year

    switch (unit) {
      case RepeatUnit.days:
        while (!candidate.isAfter(now) && safetyCounter < maxIterations) {
          candidate = candidate.add(Duration(days: repeatInterval));
          safetyCounter++;
        }
        break;

      case RepeatUnit.weeks:
        while (!candidate.isAfter(now) && safetyCounter < maxIterations) {
          candidate = candidate.add(Duration(days: 7 * repeatInterval));
          safetyCounter++;
        }
        break;

      case RepeatUnit.months:
        while (!candidate.isAfter(now) && safetyCounter < maxIterations) {
          try {
            final newMonth = candidate.month + repeatInterval;
            final year = candidate.year + (newMonth - 1) ~/ 12;
            final month = ((newMonth - 1) % 12) + 1;
            final day = candidate.day.clamp(1, DateTime(year, month + 1, 0).day);
            candidate = DateTime(year, month, day, candidate.hour, candidate.minute);
          } catch (e) {
            // Fallback to adding days if month calculation fails
            candidate = candidate.add(Duration(days: 30 * repeatInterval));
          }
          safetyCounter++;
        }
        break;
    }

    // Final safety check - if we've hit the limit, add a reasonable fallback
    if (safetyCounter >= maxIterations) {
      debugPrint('[PlantReminderUtils] Safety limit reached for nextOccurrence, using fallback');
      candidate = now.add(Duration(days: repeatInterval));
    }

    // Ensure result is always in the future
    if (!candidate.isAfter(now)) {
      candidate = now.add(Duration(minutes: 1));
    }

    return candidate;
  }

  /// Shortcut: compute & return a new reminder with updated nextReminderDateTime
  PlantReminder updatedNextReminder({DateTime? from}) {
    final next = nextOccurrence(from: from);
    return copyWith(nextReminderDateTime: next, time: next);
  }

  /// 🎯 Mark this reminder as completed for the current round
  PlantReminder markCompleted({DateTime? completedAt}) {
    final completedDate = completedAt ?? DateTime.now();
    final updatedCompletedDates = List<DateTime>.from(completedDates ?? [])..add(completedDate);
    
    return copyWith(
      completedRounds: completedRounds + 1,
      completedDates: updatedCompletedDates,
      lastCompletedDate: completedDate,
      // For fertilizing tasks, update the previousFertilizingDate to today
      previousFertilizingDate: task.toLowerCase() == 'fertilizing' ? completedDate : previousFertilizingDate,
      previousFertilizingLabel: task.toLowerCase() == 'fertilizing' ? 'Today' : previousFertilizingLabel,
    );
  }

  /// 🔄 Get next scheduled reminder after completion (with auto-rescheduling logic)
  PlantReminder? getNextAfterCompletion({DateTime? completedAt}) {
    final completed = markCompleted(completedAt: completedAt);
    
    // If all rounds are completed, return null (no more reminders)
    if (completed.isAllRoundsCompleted) {
      return completed.copyWith(isActive: false); // Deactivate the reminder
    }
    
    // Auto-reschedule for the next occurrence
    final next = completed.updatedNextReminder(from: completedAt);
    return next.copyWith(
      isCompleted: false, // Reset completion status for the next round
      notificationIds: <int>[], // Clear old notification IDs (will be rescheduled)
    );
  }

  /// 🔄 Reset a completed reminder to start over (useful for rescheduling)
  PlantReminder resetToActive() {
    return copyWith(
      isCompleted: false,
      isActive: true,
      completedRounds: 0,
      completedDates: <DateTime>[],
      lastCompletedDate: null,
      notificationIds: <int>[],
    ).updatedNextReminder();
  }

  /// 📊 Get completion statistics as a readable string
  String get completionStatus {
    if (isInfiniteRounds) {
      return completedRounds > 0 
          ? '$completedRounds completed (Infinite)'
          : 'Not started (Infinite)';
    }
    return '$completedRounds/$totalRounds completed';
  }

  /// ⏰ Get time until next reminder (human readable)
  String timeUntilNext({DateTime? from}) {
    final now = from ?? DateTime.now();
    final next = nextReminderDateTime ?? nextOccurrence(from: now);
    final diff = next.difference(now);
    
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 0) return 'In ${diff.inDays} days';
    if (diff.inHours > 0) return 'In ${diff.inHours} hours';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes} minutes';
    return 'Now';
  }
}

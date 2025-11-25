// lib/services/notification/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../modules/my_garden/db/model/garden_plant.dart';
import '../../modules/my_garden/helper/plant_reminder_utils.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _androidChannelId = 'plant_reminder_channel';
  static const String _androidChannelName = 'Plant Reminders';

  Future<void> init() async {
    if (_initialized) {
      debugPrint('[NotiService] Already initialized');
      return;
    }

    debugPrint('────────────────────────────');
    debugPrint('[NotiService] Initializing NotificationService...');
    debugPrint('────────────────────────────');

    // ---------- Timezone Setup ----------
    tzdata.initializeTimeZones();

    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      debugPrint('[NotiService] Raw timezone info: $tzInfo (${tzInfo.runtimeType})');

      String zone;
      if (tzInfo is String) {
        zone = tzInfo;
      } else if (tzInfo is TimezoneInfo) {
        // ✅ FIX: correct property name
        zone = tzInfo.identifier;
      } else {
        zone = tzInfo.toString();
      }

      const fallbackMap = {
        'PKT': 'Asia/Karachi',
        'IST': 'Asia/Kolkata',
        'PST': 'America/Los_Angeles',
        'EST': 'America/New_York',
        'CST': 'America/Chicago',
        'MST': 'America/Denver',
        'GMT': 'Europe/London',
        'UTC': 'Etc/UTC',
      };

      final validZone = fallbackMap[zone] ?? zone;
      debugPrint('[NotiService] Resolved timezone: $zone → $validZone');

      try {
        tz.setLocalLocation(tz.getLocation(validZone));
        debugPrint('[NotiService] ✅ Timezone set: $validZone');
      } catch (err) {
        debugPrint('[NotiService] ⚠️ Invalid TZ "$validZone", fallback to UTC: $err');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e, st) {
      debugPrint('[NotiService] ❌ Timezone initialization failed: $e\n$st');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // ---------- Plugin Initialization ----------
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[NotiService] 🔔 Notification response: ${response.actionId} | payload: ${response.payload}');
        _handleNotificationResponse(response);
      },
    );


    // ---------- Android Permissions ----------
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ✅ Request notification permission for Android 13+
    final granted = await androidPlugin?.requestNotificationsPermission();
    debugPrint('[NotiService] Android notification permission granted: $granted');

    // ✅ Create notification channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Reminders for plants (water, fertilize, rotate, etc.)',
        importance: Importance.max,
      ),
    );

    // ---------- iOS / macOS Permissions ----------
    await plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true, 
          badge: true, 
          sound: true,
        );

    await plugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
    debugPrint('[NotiService] ✅ Initialization complete.');

  }

  int _baseId(String reminderId) => reminderId.hashCode & 0x7fffffff;

  /// Checks if exact alarms are allowed on this device (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) {
        debugPrint('[NotiService] 🤖 Not Android platform, assuming exact alarms allowed');
        return true;
      }

      // Check if we can schedule exact alarms
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      debugPrint('[NotiService] 🔍 Can schedule exact alarms: $canSchedule');
      
      return canSchedule ?? false;
    } catch (e) {
      debugPrint('[NotiService] ⚠️ Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Requests exact alarm permission from the user (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    try {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) {
        debugPrint('[NotiService] 🤖 Not Android platform, no permission needed');
        return;
      }

      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      
      if (canSchedule == false) {
        debugPrint('[NotiService] 🚨 Exact alarms not allowed - requesting permission...');
        await androidPlugin.requestExactAlarmsPermission();
        
        // For MIUI devices, show additional guidance
        await _showMIUIGuidanceIfNeeded();
      } else {
        debugPrint('[NotiService] ✅ Exact alarm permission already granted or not needed');
      }
    } catch (e) {
      debugPrint('[NotiService] ⚠️ Error requesting exact alarm permission: $e');
    }
  }

  /// Show MIUI-specific guidance if needed
  Future<void> _showMIUIGuidanceIfNeeded() async {
    try {
      // This would typically show a dialog or system notification with MIUI setup instructions
      debugPrint('[NotiService] 📱 Consider showing MIUI setup guidance');
      // In a real implementation, you might want to trigger a callback to show UI guidance
    } catch (e) {
      debugPrint('[NotiService] Error showing MIUI guidance: $e');
    }
  }

  /// Schedules only the NEXT 4 upcoming notifications across future occurrences.
  /// Rules per occurrence:
  /// 1. One day before at same time
  /// 2. 6 hours before reminder time
  /// 3. 1 hour before reminder time
  /// 4. 10 minutes before (urgent)
  /// We keep rolling forward across occurrences until we have 4 future notifications.
  Future<List<int>> scheduleMultipleOccurrences(
      PlantReminder r, {
        int occurrences = 3, // kept for API compatibility (ignored by new logic)
      }) async {
    debugPrint('────────────────────────────');
    debugPrint('[NotiService] Scheduling ${r.task} reminder for "${r.plantName}" (${r.id})');
    debugPrint('────────────────────────────');

    if (!_initialized) await init();

    // Proactively request exact alarm permission (Android 12+). This improves reliability.
    try {
      final canExact = await canScheduleExactAlarms();
      if (!canExact) {
        await requestExactAlarmPermission();
      }
    } catch (_) {/* best effort */}

    final scheduledIds = <int>[];
    final now = DateTime.now();
    var from = now;

    // We will collect up to 4 future notification times across occurrences.
    final tzLocal = tz.local;
    final tzNow = tz.TZDateTime.from(now, tzLocal);

    // Guard to avoid infinite loops in case of misconfigured recurrence
    int safetyGuard = 0;

    try {
      while (scheduledIds.length < 4 && safetyGuard < 12) {
        final next = r.nextOccurrence(from: from);
        final idx = safetyGuard; // synthetic index for ID disambiguation
        debugPrint('[NotiService] → nextOccurrence[$idx]: $next (now: $now)');

        // If the computed occurrence is still behind, move forward
        if (next.isBefore(now)) {
          debugPrint('[NotiService] Skipping past occurrence: $next');
          from = next.add(const Duration(seconds: 1));
          safetyGuard++;
          continue;
        }

        // Build the four times for this occurrence and schedule only those in the future,
        // stopping once we reach a total of 4 overall.
        final tzOcc = tz.TZDateTime.from(next, tzLocal);
        final times = _buildNotificationTimesForOccurrence(tzOcc);

        for (final nt in times) {
          if (scheduledIds.length >= 4) break;

          final t = nt['time'] as tz.TZDateTime;
          final type = nt['type'] as String;
          final offset = nt['offset'] as int;

          if (!t.isAfter(tzNow)) {
            debugPrint('[NotiService] Skipping past time: $t ($type)');
            continue;
          }

          final id = _baseId(r.id) + (idx * 10) + offset; // Unique ID per occurrence-like index
          final ok = await _scheduleOneNotification(
            r: r,
            id: id,
            when: t,
            type: type,
            occurrence: next,
          );
          if (ok) scheduledIds.add(id);
        }

        from = next.add(const Duration(seconds: 1));
        safetyGuard++;
      }

      final pending = await plugin.pendingNotificationRequests();
      debugPrint('[NotiService] ✅ Total scheduled: ${scheduledIds.length}');
      debugPrint('[NotiService] 🔎 Pending notifications: ${pending.length}');
    } catch (e, st) {
      debugPrint('[NotiService] ❌ scheduleMultipleOccurrences error: $e\n$st');
    }

    return scheduledIds;
  }

  /// Schedules exactly 4 notifications for a single reminder occurrence:
  /// 1. One day before at same time
  /// 2. 6 hours before reminder time  
  /// 3. 1 hour before reminder time
  /// 4. 10 minutes before (with special urgent styling)
  // Build the 4 times for one occurrence
  List<Map<String, Object>> _buildNotificationTimesForOccurrence(tz.TZDateTime tzOcc) {
    final oneDayBefore = tzOcc.subtract(const Duration(days: 1));
    final sixHoursBefore = tzOcc.subtract(const Duration(hours: 6));
    final oneHourBefore = tzOcc.subtract(const Duration(hours: 1));
    final tenMinutesBefore = tzOcc.subtract(const Duration(minutes: 10));

    return [
      {'time': oneDayBefore, 'type': 'day_before', 'offset': 1},
      {'time': sixHoursBefore, 'type': 'six_hours', 'offset': 2},
      {'time': oneHourBefore, 'type': 'one_hour', 'offset': 3},
      {'time': tenMinutesBefore, 'type': 'urgent', 'offset': 4},
    ];
  }

  // Schedule a single notification instance
  Future<bool> _scheduleOneNotification({
    required PlantReminder r,
    required int id,
    required tz.TZDateTime when,
    required String type,
    required DateTime occurrence,
  }) async {
    final tzLocal = tz.local;
    final tzNow = tz.TZDateTime.now(tzLocal);
    final tzOcc = tz.TZDateTime.from(occurrence, tzLocal);

    if (!when.isAfter(tzNow)) {
      debugPrint('[NotiService] Skipping past time: $when ($type)');
      return false;
    }

    debugPrint('[NotiService] Preparing single reminder time for $tzOcc → $when ($type)');

    final (title, body, details) = _getNotificationContent(r, type);
    final payload = jsonEncode({
      'reminderId': r.id,
      'plantId': r.plantId,
      'task': r.task,
      'type': type,
      'occurrence': occurrence.toIso8601String(),
    });

    final ok = await _scheduleNotificationWithFallback(
      id: id,
      title: title,
      body: body,
      time: when,
      details: details,
      payload: payload,
      type: type,
    );

    if (ok) {
      debugPrint('[NotiService] ✅ Scheduled [$type] [id:$id] → $when');
    }

    return ok;
  }

  /// Schedules a notification with fallback from exact to inexact alarms
  Future<bool> _scheduleNotificationWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime time,
    required NotificationDetails details,
    required String payload,
    required String type,
  }) async {
    try {
      // First, try to schedule with exact timing
      await plugin.zonedSchedule(
        id,
        title,
        body,
        time,
        details,
        //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      
      return true; // Exact scheduling succeeded
    } catch (e) {
      // Check if the error is about exact alarms not being permitted
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('[NotiService] ⚠️ Exact alarms not permitted for $type, trying inexact...');
        
        try {
          // Fall back to inexact scheduling
          await plugin.zonedSchedule(
            id,
            title,
            body,
            time,
            details,
            //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            androidScheduleMode: AndroidScheduleMode.inexact,
            payload: payload,
          );
          
          debugPrint('[NotiService] ✅ Scheduled with INEXACT timing [$type] [id:$id] → $time');
          return true; // Inexact scheduling succeeded
        } catch (fallbackError) {
          debugPrint('[NotiService] ❌ Both exact and inexact scheduling failed for $type: $fallbackError');
          return false;
        }
      } else {
        debugPrint('[NotiService] ❌ Schedule error for $type at $time: $e');
        return false;
      }
    }
  }

  /// Returns notification content based on the notification type
  (String, String, NotificationDetails) _getNotificationContent(PlantReminder r, String type) {
    final taskLower = r.task.toLowerCase();
    final plantName = r.plantName;
    
    switch (type) {
      case 'day_before':
        return (
          '🌱 Tomorrow: ${r.task} Reminder',
          'Don\'t forget to $taskLower your $plantName tomorrow!',
          NotificationDetails(
            android: const AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: Color(0xFF4CAF50), // Green
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'plant_reminders',
            ),
          ),
        );
      case 'six_hours':
        return (
          '⏰ ${r.task} in 6 hours',
          'Time to prepare - $taskLower your $plantName in 6 hours',
          NotificationDetails(
            android: const AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.high,
              priority: Priority.high,
              color: Color(0xFF2196F3), // Blue
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'plant_reminders',
            ),
          ),
        );
      case 'one_hour':
        return (
          '🚨 ${r.task} in 1 hour!',
          'Get ready - time to $taskLower your $plantName soon!',
          NotificationDetails(
            android: const AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.high,
              priority: Priority.high,
              color: Color(0xFFFF9800), // Orange
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'plant_reminders',
            ),
          ),
        );
      case 'urgent':
        return (
          '⚡ URGENT: ${r.task} in 10 minutes!',
          'Only 10 minutes left! Time to $taskLower your $plantName NOW!',
          NotificationDetails(
            android: const AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.max,
              priority: Priority.max,
              color: Color(0xFFF44336), // Red
              playSound: true,
              enableVibration: true,
              actions: [
                AndroidNotificationAction(
                  'mark_done',
                  'Mark as Done ✅',
                  showsUserInterface: false,
                ),
                AndroidNotificationAction(
                  'snooze',
                  'Snooze 30min ⏰',
                  showsUserInterface: false,
                ),
              ],
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'plant_reminders',
            ),
          ),
        );
      default:
        return (
          '${r.task} Reminder',
          'Time to $taskLower your $plantName',
          NotificationDetails(
            android: const AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'plant_reminders',
            ),
          ),
        );
    }
  }

  Future<void> cancelReminderNotifications(PlantReminder reminder) async {
    if (reminder.notificationIds == null) return;
    for (final id in reminder.notificationIds!) {
      await plugin.cancel(id);
      debugPrint('[NotiService] 🗑️ Cancelled notification id $id');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingRequests() =>
      plugin.pendingNotificationRequests();

  Future<void> cancelAll() async {
    await plugin.cancelAll();
    debugPrint('[NotiService] 🧩 All notifications cleared');
  }

  /// Handle notification actions (mark_done, snooze, etc.)
  void _handleNotificationResponse(NotificationResponse response) {
    try {
      if (response.payload == null) {
        debugPrint('[NotiService] No payload in notification response');
        return;
      }

      final payload = jsonDecode(response.payload!);
      final reminderId = payload['reminderId'] as String?;
      final plantId = payload['plantId'] as String?;
      final actionId = response.actionId;

      debugPrint('[NotiService] Handling action: $actionId for reminder: $reminderId');

      if (reminderId == null || plantId == null) {
        debugPrint('[NotiService] Missing reminderId or plantId in payload');
        return;
      }

      switch (actionId) {
        case 'mark_done':
          _handleMarkDone(plantId, reminderId);
          break;
        case 'snooze':
          _handleSnooze(plantId, reminderId);
          break;
        default:
          // Regular notification tap - could open the app to specific screen
          debugPrint('[NotiService] Regular notification tap');
          break;
      }
    } catch (e, st) {
      debugPrint('[NotiService] ❌ Error handling notification response: $e\n$st');
    }
  }

  /// Mark reminder as done through notification action
  void _handleMarkDone(String plantId, String reminderId) {
    debugPrint('[NotiService] 🎯 Marking reminder $reminderId as done');
    // This would typically call back to the GardenProvider
    // For now, we'll use a simple callback system
    onReminderCompleted?.call(plantId, reminderId);
    
    // Show a completion confirmation
    plugin.show(
      999999, // Temporary ID for confirmation
      '✅ Task Completed!',
      'Great job! Your plant care task has been marked as done.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: Color(0xFF4CAF50),
          autoCancel: true,
          timeoutAfter: 3000, // Auto-dismiss after 3 seconds
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Snooze reminder for 30 minutes
  void _handleSnooze(String plantId, String reminderId) async {
    debugPrint('[NotiService] ⏰ Snoozing reminder $reminderId for 30 minutes');
    
    final snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30));
    
    // Schedule a snooze notification with fallback
    await _scheduleNotificationWithFallback(
      id: 999998,
      title: '⏰ Snooze Reminder',
      body: 'Your plant care reminder is ready again!',
      time: snoozeTime,
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFFF9800),
          actions: [
            AndroidNotificationAction(
              'mark_done',
              'Mark as Done ✅',
              showsUserInterface: false,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        'reminderId': reminderId,
        'plantId': plantId,
        'type': 'snooze',
      }),
      type: 'snooze',
    );

    // Show snooze confirmation
    plugin.show(
      999997,
      '⏰ Snoozed for 30 minutes',
      'We\'ll remind you again in 30 minutes.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.low,
          priority: Priority.low,
          color: Color(0xFF2196F3),
          autoCancel: true,
          timeoutAfter: 3000,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Callback for when reminder is completed via notification
  Function(String plantId, String reminderId)? onReminderCompleted;

  /// Set the callback for reminder completion
  void setReminderCompletedCallback(Function(String plantId, String reminderId) callback) {
    onReminderCompleted = callback;
  }
}

// lib/services/notification/notification_debug_helper.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationDebugHelper {
  static NotificationDebugHelper? _instance;
  static NotificationDebugHelper get instance => _instance ??= NotificationDebugHelper._();
  NotificationDebugHelper._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get comprehensive device and notification system information
  Future<Map<String, dynamic>> getSystemInfo() async {
    final info = <String, dynamic>{};
    
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        info['platform'] = 'Android';
        info['model'] = androidInfo.model;
        info['manufacturer'] = androidInfo.manufacturer;
        info['brand'] = androidInfo.brand;
        info['version'] = androidInfo.version.release;
        info['sdkInt'] = androidInfo.version.sdkInt;
        info['isPhysicalDevice'] = androidInfo.isPhysicalDevice;
        
        // Check for custom ROMs that might affect notifications
        final customRomIndicators = [
          'MIUI', 'ColorOS', 'FunTouchOS', 'OxygenOS', 'OneUI', 
          'EMUI', 'HarmonyOS', 'realmeUI', 'OriginOS'
        ];
        
        final systemName = '${androidInfo.manufacturer} ${androidInfo.brand}';
        info['likelyCustomROM'] = customRomIndicators.any(
          (indicator) => systemName.toUpperCase().contains(indicator.toUpperCase())
        );
        
        // Special handling for known problematic manufacturers
        if (androidInfo.manufacturer.toLowerCase().contains('xiaomi') ||
            androidInfo.brand.toLowerCase().contains('redmi')) {
          info['deviceWarnings'] = [
            'MIUI detected: Enable AutoStart and disable battery optimization',
            'Go to Settings > Apps > Manage Apps > AI Tree Plant > Other permissions > Display pop-up windows',
            'Settings > Battery & performance > Battery optimization > AI Tree Plant > Don\'t optimize'
          ];
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info['platform'] = 'iOS';
        info['model'] = iosInfo.model;
        info['systemName'] = iosInfo.systemName;
        info['systemVersion'] = iosInfo.systemVersion;
        info['isPhysicalDevice'] = iosInfo.isPhysicalDevice;
      }
      
      info['timezone'] = tz.local.name;
      info['currentTime'] = DateTime.now().toIso8601String();
      
    } catch (e) {
      info['error'] = 'Failed to get device info: $e';
    }
    
    return info;
  }

  /// Check notification permissions and settings
  Future<Map<String, dynamic>> checkNotificationPermissions() async {
    final result = <String, dynamic>{};
    
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          result['notificationPermission'] = await androidPlugin.areNotificationsEnabled() ?? false;
          result['canScheduleExact'] = await androidPlugin.canScheduleExactNotifications() ?? false;
          result['batteryOptimizationDisabled'] = await _checkBatteryOptimization();
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS permission checks would go here
        result['notificationPermission'] = true; // Placeholder
      }
      
      final pendingNotifications = await plugin.pendingNotificationRequests();
      result['pendingNotifications'] = pendingNotifications.length;
      result['pendingDetails'] = pendingNotifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'payload': n.payload,
      }).toList();
      
    } catch (e) {
      result['error'] = 'Failed to check permissions: $e';
    }
    
    return result;
  }

  /// Test immediate notification
  Future<bool> sendTestNotification({
    String title = '🧪 Test Notification',
    String body = 'This is a test notification to verify your settings work correctly.',
  }) async {
    try {
      debugPrint('[NotificationDebug] Sending test notification...');
      
      final plugin = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for testing notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: Color(0xFF4CAF50),
        playSound: true,
        enableVibration: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await plugin.show(
        999999,
        title,
        body,
        details,
        payload: jsonEncode({
          'type': 'test',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      debugPrint('[NotificationDebug] ✅ Test notification sent successfully');
      return true;
    } catch (e, st) {
      debugPrint('[NotificationDebug] ❌ Failed to send test notification: $e\n$st');
      return false;
    }
  }

  /// Test scheduled notification (1 minute from now)
  Future<bool> sendTestScheduledNotification() async {
    try {
      debugPrint('[NotificationDebug] Scheduling test notification for 1 minute from now...');
      
      final plugin = FlutterLocalNotificationsPlugin();
      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
      
      const androidDetails = AndroidNotificationDetails(
        'test_scheduled_channel',
        'Test Scheduled Notifications',
        channelDescription: 'Channel for testing scheduled notifications',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF2196F3),
        playSound: true,
        enableVibration: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await plugin.zonedSchedule(
        999998,
        '⏰ Scheduled Test Notification',
        'This scheduled notification was set 1 minute ago. If you see this, scheduling works!',
        scheduledDate,
        details,
        //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode({
          'type': 'test_scheduled',
          'scheduledFor': scheduledDate.toIso8601String(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      debugPrint('[NotificationDebug] ✅ Test scheduled notification set for: $scheduledDate');
      return true;
    } catch (e, st) {
      debugPrint('[NotificationDebug] ❌ Failed to schedule test notification: $e\n$st');
      return false;
    }
  }

  /// Check if battery optimization is disabled (Android)
  Future<bool> _checkBatteryOptimization() async {
    try {
      const platform = MethodChannel('notification_debug');
      final result = await platform.invokeMethod('checkBatteryOptimization');
      return result == true;
    } catch (e) {
      debugPrint('[NotificationDebug] Could not check battery optimization: $e');
      return false; // Assume it's enabled (problematic)
    }
  }

  /// Generate comprehensive diagnostic report
  Future<String> generateDiagnosticReport() async {
    final report = StringBuffer();
    report.writeln('=== AI Tree Plant - Notification Diagnostic Report ===');
    report.writeln('Generated: ${DateTime.now()}');
    report.writeln();

    // System Info
    report.writeln('--- DEVICE INFORMATION ---');
    final systemInfo = await getSystemInfo();
    systemInfo.forEach((key, value) {
      if (value is List) {
        report.writeln('$key:');
        for (var item in value) {
          report.writeln('  • $item');
        }
      } else {
        report.writeln('$key: $value');
      }
    });
    report.writeln();

    // Permission Info
    report.writeln('--- NOTIFICATION PERMISSIONS ---');
    final permissionInfo = await checkNotificationPermissions();
    permissionInfo.forEach((key, value) {
      if (key == 'pendingDetails') {
        report.writeln('Pending notification details:');
        if (value is List && value.isNotEmpty) {
          for (var notification in value) {
            report.writeln('  • ID ${notification['id']}: ${notification['title']}');
          }
        } else {
          report.writeln('  • None');
        }
      } else {
        report.writeln('$key: $value');
      }
    });
    report.writeln();

    // Recommendations
    report.writeln('--- RECOMMENDATIONS ---');
    if (systemInfo.containsKey('deviceWarnings')) {
      report.writeln('Device-specific recommendations:');
      for (var warning in systemInfo['deviceWarnings']) {
        report.writeln('• $warning');
      }
    }

    if (permissionInfo['notificationPermission'] == false) {
      report.writeln('• Enable notification permissions in Settings');
    }

    if (permissionInfo['canScheduleExact'] == false) {
      report.writeln('• Enable "Allow setting alarms and reminders" in App permissions');
    }

    report.writeln();
    report.writeln('--- TROUBLESHOOTING STEPS ---');
    report.writeln('1. Test immediate notification using the "Send Test Notification" button');
    report.writeln('2. Test scheduled notification using the "Schedule Test Notification" button');
    report.writeln('3. If notifications don\'t appear, check:');
    report.writeln('   • App notification permissions in device Settings');
    report.writeln('   • Battery optimization settings (disable for this app)');
    report.writeln('   • Do Not Disturb mode');
    report.writeln('   • Background app restrictions');
    report.writeln('4. For MIUI devices: Enable AutoStart and disable battery optimization');
    report.writeln('5. Try restarting the app and device after changing settings');

    return report.toString();
  }

  /// Clear all test notifications
  Future<void> clearTestNotifications() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(999999); // Test immediate
      await plugin.cancel(999998); // Test scheduled
      debugPrint('[NotificationDebug] ✅ Test notifications cleared');
    } catch (e) {
      debugPrint('[NotificationDebug] ❌ Failed to clear test notifications: $e');
    }
  }

  /// Get all pending notification requests with details
  Future<List<Map<String, dynamic>>> getPendingNotificationDetails() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      final pending = await plugin.pendingNotificationRequests();
      
      return pending.map((notification) {
        return {
          'id': notification.id,
          'title': notification.title ?? 'No title',
          'body': notification.body ?? 'No body',
          'payload': notification.payload ?? 'No payload',
        };
      }).toList();
    } catch (e) {
      debugPrint('[NotificationDebug] ❌ Failed to get pending notifications: $e');
      return [];
    }
  }
}

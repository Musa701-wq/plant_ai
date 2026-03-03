import 'package:firebase_analytics/firebase_analytics.dart';

/// ✅ Simple Google Analytics Service
/// Tracks user navigation from different sources
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ==================== MY GARDEN CLICKS ====================

  /// Track when user clicks "My Garden" from Navbar
  static Future<void> trackMyGardenNavbar() async {
    await _analytics.logEvent(
      name: 'my_garden_click',
      parameters: {
        'source': 'navbar',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track when user clicks "My Garden" from Home Screen Card
  static Future<void> trackMyGardenHomeCard() async {
    await _analytics.logEvent(
      name: 'my_garden_click',
      parameters: {
        'source': 'home_card',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== SCAN CLICKS ====================

  /// Track when user clicks "Scan" from Navbar/FAB
  static Future<void> trackScanNavbar() async {
    await _analytics.logEvent(
      name: 'scan_click',
      parameters: {
        'source': 'navbar_fab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track when user clicks "Scan/Identify" from Home Screen Card
  static Future<void> trackScanHomeCard() async {
    await _analytics.logEvent(
      name: 'scan_click',
      parameters: {
        'source': 'home_card',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== CALENDAR CLICKS ====================

  /// Track when user clicks "Calendar" from Navbar
  static Future<void> trackCalendarNavbar() async {
    await _analytics.logEvent(
      name: 'calendar_click',
      parameters: {
        'source': 'navbar',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track when user clicks "Calendar" from Home Screen Card
  static Future<void> trackCalendarHomeCard() async {
    await _analytics.logEvent(
      name: 'calendar_click',
      parameters: {
        'source': 'home_card',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== ASK AI CLICKS ====================

  /// Track when user clicks "Ask AI" from Navbar
  static Future<void> trackAskAiNavbar() async {
    await _analytics.logEvent(
      name: 'ask_ai_click',
      parameters: {
        'source': 'navbar',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track when user clicks "Ask AI" from Home Screen Card
  static Future<void> trackAskAiHomeCard() async {
    await _analytics.logEvent(
      name: 'ask_ai_click',
      parameters: {
        'source': 'home_card',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
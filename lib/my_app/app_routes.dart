import 'package:flutter/material.dart';

import '../modules/ask_ai/screen/ask_ai_screen.dart';
import '../modules/calender/screen/calender_screen.dart';
import '../modules/home/screen/home_screen.dart';
import '../modules/home/screen/CommunityPage.dart';
import '../modules/my_garden/screen/my_garden_screen.dart';
import '../modules/navigator/main_navigator.dart';
import '../modules/scan/screen/recent_scan_screen.dart';
import '../modules/scan/screen/result_screen.dart';
import '../modules/scan/screen/scan_screen.dart';
import '../modules/search/screen/search_screen.dart';
import '../modules/subscription/screen/subscription_screen.dart';
import '../modules/onboarding/screen/onboarding_screen.dart';
import '../modules/scan/screen/pest_scan_screen.dart';
import '../modules/scan/screen/pest_result_screen.dart';

class AppRoutes {
  // ✅ Add the missing main route
  static const String main = '/';
  static const String home = '/home';
  static const String askAi = '/ask-ai';
  static const String scan = '/scan';
  static const String calendar = '/calendar';
  static const String myGarden = '/my-garden';
  static const String community = '/community';
  static const String result = '/result';
  static const String search = '/search';
  static const String recentScans = '/recent-scans';
  static const String onboarding = '/onboarding';
  static const String pestScan = '/pest-scan';
  static const String pestResult = '/pest-result';
  //static const String subscription = '/subscription';

  // Centralized route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigator());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case pestScan:
        return MaterialPageRoute(builder: (_) => const PestScanScreen());
      case pestResult:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PestResultScreen(imagePath: args['imagePath']),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case askAi:
        return MaterialPageRoute(builder: (_) => const AskAiScreen());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case myGarden:
        return MaterialPageRoute(builder: (_) => const MyGardenScreen());
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      // case subscription:
      //   return MaterialPageRoute(builder: (_) => const AppleSubscriptionScreen());
      case recentScans:
        return MaterialPageRoute(builder: (_) => const RecentScansScreen());
      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            imagePath: args['imagePath'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
          const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
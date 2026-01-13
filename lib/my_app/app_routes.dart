import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modules/ask_ai/screen/ask_ai_screen.dart';
import '../modules/calender/screen/calender_screen.dart';
import '../modules/home/screen/home_screen.dart';
import '../modules/my_garden/screen/my_garden_screen.dart';
import '../modules/navigator/main_navigator.dart';
import '../modules/scan/screen/recent_scan_screen.dart';
import '../modules/scan/screen/result_screen.dart';
import '../modules/scan/screen/scan_screen.dart';
import '../modules/search/screen/search_screen.dart';
import '../modules/subscription/screen/subscription_screen.dart';

class AppRoutes {
  // ✅ Add the missing main route
  static const String main = '/';
  static const String home = '/home';
  static const String askAi = '/ask-ai';
  static const String scan = '/scan';
  static const String calendar = '/calendar';
  static const String myGarden = '/my-garden';
  static const String result = '/result';
  static const String search = '/search';
  static const String recentScans = '/recent-scans';
  //static const String subscription = '/subscription';

  // Centralized route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigator());
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
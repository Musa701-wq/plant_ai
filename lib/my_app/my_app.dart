import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:untitled/Auth/auth_state.dart';
import 'package:untitled/services/ads/AdsProvider.dart';
import 'app_routes.dart';
import '../modules/ask_ai/provider/ask_ai_provider.dart';
import '../modules/calender/provider/calender_provider.dart';
import '../modules/my_garden/provider/SettingsProvider.dart';
import '../modules/my_garden/provider/garden_provider.dart';
import '../modules/my_garden/services/CreditManager.dart';
import '../modules/navigator/main_navigator.dart';
import '../modules/scan/gemini/repo/plant_repo.dart';
import '../modules/scan/gemini/services/gemini_api_service.dart';
import '../modules/scan/provider/scan_provider.dart';
import '../modules/search/provider/search_provider.dart';
import '../utils/app_colors.dart';
import 'app_state_provider.dart';

class MyApp extends StatelessWidget {
  final GardenProvider gardenProvider;
  final CalendarProvider calendarProvider;
  final ScanProvider scanProvider;
  final AskAiProvider askAiProvider;
  final SearchProvider searchProvider;
  final CreditManager creditManager;
  final AdProvider adProvider;
  final AuthState authState;
  final bool showOnboarding; // ✅ ADD THIS

  const MyApp({
    super.key,
    required this.gardenProvider,
    required this.calendarProvider,
    required this.scanProvider,
    required this.askAiProvider,
    required this.searchProvider,
    required this.creditManager,
    required this.adProvider,
    required this.authState,
    required this.showOnboarding, // ✅ ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider.value(value: authState), // ✅ Use the passed authState
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // ✅ Credit Manager and Ad Provider
        ChangeNotifierProvider.value(value: creditManager),
        ChangeNotifierProvider.value(value: adProvider),

        // These are already initialized → use .value
        ChangeNotifierProvider.value(value: gardenProvider),
        ChangeNotifierProvider.value(value: calendarProvider),
        ChangeNotifierProvider.value(value: scanProvider),
        ChangeNotifierProvider.value(value: askAiProvider),
        ChangeNotifierProvider.value(value: searchProvider),
      ],
      child: MaterialApp(
        title: 'Plant Identifier AI',
        theme: ThemeData(
          primaryColor: AppColors.primaryGreen,
          scaffoldBackgroundColor: AppColors.backgroundLight,
          fontFamily: 'SF Pro',
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.backgroundWhite,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: AppColors.textHint,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        initialRoute: showOnboarding ? AppRoutes.onboarding : AppRoutes.main,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}




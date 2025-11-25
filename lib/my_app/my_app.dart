import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:untitled/services/ads/AdsProvider.dart';
import '../config/app_routes.dart';
import '../modules/ask_ai/provider/ask_ai_provider.dart';
import '../modules/calender/provider/calender_provider.dart';
import '../modules/my_garden/provider/garden_provider.dart';
import '../modules/navigator/main_navigator.dart';
import '../modules/scan/gemini/repo/plant_repo.dart';
import '../modules/scan/gemini/services/gemini_api_service.dart';
import '../modules/scan/provider/scan_provider.dart';
import '../modules/search/provider/search_provider.dart';
import '../utils/app_colors.dart';
import 'app_state_provider.dart';

// class MyApp extends StatelessWidget {
//   final GardenProvider? gardenProvider;
//   const MyApp({super.key,  this.gardenProvider});
//
//   @override
//   Widget build(BuildContext context) {
//
//     String geminiKey = dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND";
//
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AppStateProvider()),
//         ChangeNotifierProvider(create: (_) => AdProvider()),
//         //ChangeNotifierProvider(create: (_) => GardenProvider()..init()),
//         ChangeNotifierProvider.value(value: gardenProvider!),
//         ChangeNotifierProvider(
//           create: (_) => ScanProvider(
//             PlantRepository(
//               GeminiApiService(geminiKey),
//             ),
//           ),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => AskAiProvider(
//             ChatRepository(
//               GeminiChatApiService(geminiKey),
//             ),
//           ),
//         ),
//         ChangeNotifierProvider(create: (_) => CalendarProvider(gardenProvider: gardenProvider!)..init()),
//         ChangeNotifierProvider(create: (_) => SearchProvider(SearchRepository(SearchApiService()))),
//       ],
//       child: MaterialApp(
//         title: 'Plant Identifier AI',
//         theme: ThemeData(
//           primaryColor: AppColors.primaryGreen,
//           scaffoldBackgroundColor: AppColors.backgroundLight,
//           fontFamily: 'SF Pro',
//           // Make sure to include this font in pubspec.yaml
//           bottomNavigationBarTheme: BottomNavigationBarThemeData(
//             backgroundColor: AppColors.backgroundWhite,
//             selectedItemColor: AppColors.primaryGreen,
//             unselectedItemColor: AppColors.textHint,
//             type: BottomNavigationBarType.fixed,
//           ),
//         ),
//         initialRoute: AppRoutes.main,
//         onGenerateRoute: AppRoutes.generateRoute,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

/*class MyApp extends StatelessWidget {
  final GardenProvider? gardenProvider;
  const MyApp({super.key, this.gardenProvider});

  @override
  Widget build(BuildContext context) {

    String geminiKey = dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND";

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        //ChangeNotifierProvider(create: (_) => AdProvider()),

        // 👇 Use existing instance from main.dart
        ChangeNotifierProvider.value(value: gardenProvider!),

        ChangeNotifierProvider(
          create: (_) => ScanProvider(
            PlantRepository(
              GeminiApiService(geminiKey),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AskAiProvider(
            ChatRepository(
              GeminiChatApiService(geminiKey),
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => CalendarProvider(gardenProvider: gardenProvider!)..init(),
        ),

        ChangeNotifierProvider(
          create: (_) => SearchProvider(SearchRepository(SearchApiService())),
        ),
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
        initialRoute: AppRoutes.main,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}*/

class MyApp extends StatelessWidget {
  final GardenProvider gardenProvider;
  final CalendarProvider calendarProvider;
  final ScanProvider scanProvider;
  final AskAiProvider askAiProvider;
  final SearchProvider searchProvider;

  const MyApp({
    super.key,
    required this.gardenProvider,
    required this.calendarProvider,
    required this.scanProvider,
    required this.askAiProvider,
    required this.searchProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),

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
        initialRoute: AppRoutes.main,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

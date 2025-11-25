import 'dart:ui';

//import 'package:ai_tree_plant/services/ads/ads_service.dart';
//import 'package:ai_tree_plant/services/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:untitled/services/notification/notification_service.dart';
import 'modules/ask_ai/provider/ask_ai_provider.dart';
import 'modules/ask_ai/repo/chat_repo.dart';
import 'modules/ask_ai/services/chat_api_service.dart';
import 'modules/calender/provider/calender_provider.dart';
import 'modules/my_garden/db/database/garden_db.dart';
import 'modules/my_garden/provider/garden_provider.dart';
import 'modules/scan/db/database/scan_db.dart';
import 'modules/scan/gemini/repo/plant_repo.dart';
import 'modules/scan/gemini/services/gemini_api_service.dart';
import 'modules/scan/provider/scan_provider.dart';
import 'modules/search/provider/search_provider.dart';
import 'modules/search/repo/search_repo.dart';
import 'modules/search/services/search_api_service.dart';
import 'my_app/my_app.dart';

//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // ✅ Load environment variables
//   await dotenv.load(fileName: ".env");
//
//   // ✅ Initialize Hive
//   await Hive.initFlutter();
//   await GardenDB.init();
//   await ScanDB.init();   // init scan DB
//
//   // Initialize Google Mobile Ads SDK
//   await MobileAds.instance.initialize();
//   AdService.instance.loadInterstitial();
//
//   // ✅ Initialize provider manually before runApp
//   final gardenProvider = GardenProvider();
//   await gardenProvider.init();
//   await NotificationService.instance.init();
//
//   // 🔗 Connect notification actions to provider
//   NotificationService.instance.setReminderCompletedCallback(
//     (plantId, reminderId) async {
//       try {
//         await gardenProvider.completeReminder(plantId, reminderId);
//         debugPrint('[Main] Reminder $reminderId completed via notification');
//       } catch (e) {
//         debugPrint('[Main] Error completing reminder via notification: $e');
//       }
//     },
//   );
//
//   runApp(MyApp(gardenProvider: gardenProvider));
// }

///import 'package:ai_tree_plant/services/ads/ads_service.dart';
//import 'package:ai_tree_plant/services/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'modules/my_garden/db/database/garden_db.dart';
import 'modules/my_garden/provider/garden_provider.dart';
import 'modules/scan/db/database/scan_db.dart';
import 'my_app/my_app.dart';

// Future<void> main() async {
//   // ✅ CRITICAL: Ensure Flutter binding is initialized FIRST
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try {
//     debugPrint('[Main] 🚀 Starting app initialization...');
//
//     // ✅ Load environment variables
//     await dotenv.load(fileName: ".env");
//     debugPrint('[Main] ✅ Environment variables loaded');
//
//     // ✅ Initialize Hive - now the custom channel is registered
//     await Hive.initFlutter('ai_tree_plant_db');
//     debugPrint('[Main] ✅ Hive initialized successfully');
//
//     await GardenDB.init();
//     debugPrint('[Main] ✅ GardenDB initialized');
//
//     await ScanDB.init();
//     debugPrint('[Main] ✅ ScanDB initialized');
//
//     // Initialize Google Mobile Ads SDK
//     // await MobileAds.instance.initialize();
//     // AdService.instance.loadInterstitial();
//     // debugPrint('[Main] ✅ Ads initialized');
//
//     // ✅ Initialize provider manually before runApp
//     final gardenProvider = GardenProvider();
//     await gardenProvider.init();
//     debugPrint('[Main] ✅ GardenProvider initialized');
//
//     await NotificationService.instance.init();
//     debugPrint('[Main] ✅ NotificationService initialized');
//
//     // 🔗 Connect notification actions to provider
//     NotificationService.instance.setReminderCompletedCallback(
//           (plantId, reminderId) async {
//         try {
//           await gardenProvider.completeReminder(plantId, reminderId);
//           debugPrint('[Main] ✅ Reminder $reminderId completed via notification');
//         } catch (e) {
//           debugPrint('[Main] ❌ Error completing reminder via notification: $e');
//         }
//       },
//     );
//
//     debugPrint('[Main] 🎉 All initializations complete! Starting app...');
//     runApp(MyApp(gardenProvider: gardenProvider));
//
//   } catch (e, stackTrace) {
//     debugPrint('[Main] ❌ FATAL ERROR during initialization:');
//     debugPrint('[Main] Error: $e');
//     debugPrint('[Main] Stack trace: $stackTrace');
//
//     // Show error screen with detailed information
//     runApp(MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 60),
//                   const Icon(
//                     Icons.error_outline,
//                     size: 80,
//                     color: Colors.red,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Initialization Error',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Error Details:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           e.toString(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         const Text(
//                           'Stack Trace:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           stackTrace.toString(),
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.black54,
//                             fontFamily: 'Courier',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       SystemNavigator.pop();
//                     },
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Restart App'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'If this persists, please reinstall the app',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ));
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  final Stopwatch startupTimer = Stopwatch()..start();
  debugPrint("⏳ [Startup] App launch started...");

  // ---------------- Crash Logging ----------------
  FlutterError.onError = (details) {
    debugPrint("🔥 [FlutterError] ${details.exception}");
    debugPrint(details.stack.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("🔥 [PlatformError] $error");
    debugPrint(stack.toString());
    return true;
  };
  // ------------------------------------------------


  try {
    debugPrint("⏱ [Startup] Loading .env...");
    final t1 = DateTime.now().millisecondsSinceEpoch;

    await dotenv.load(fileName: ".env");

    debugPrint("✅ [.env loaded in ${DateTime.now().millisecondsSinceEpoch - t1}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Initializing Hive...");
    final tHive = DateTime.now().millisecondsSinceEpoch;

    await Hive.initFlutter('ai_tree_plant_db');

    debugPrint("✅ [Hive ready in ${DateTime.now().millisecondsSinceEpoch - tHive}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Opening GardenDB...");
    final tGdb = DateTime.now().millisecondsSinceEpoch;

    await GardenDB.init();

    debugPrint("✅ [GardenDB ready in ${DateTime.now().millisecondsSinceEpoch - tGdb}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Opening ScanDB...");
    final tSdb = DateTime.now().millisecondsSinceEpoch;

    await ScanDB.init();

    debugPrint("✅ [ScanDB ready in ${DateTime.now().millisecondsSinceEpoch - tSdb}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Initializing GardenProvider...");
    final tGp = DateTime.now().millisecondsSinceEpoch;

    final gardenProvider = GardenProvider();
    await gardenProvider.init();

    debugPrint("✅ [GardenProvider ready in ${DateTime.now().millisecondsSinceEpoch - tGp}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Initializing CalendarProvider...");
    final tCp = DateTime.now().millisecondsSinceEpoch;

    final calendarProvider = CalendarProvider(gardenProvider: gardenProvider);
    await calendarProvider.init();

    debugPrint("✅ [CalendarProvider ready in ${DateTime.now().millisecondsSinceEpoch - tCp}ms]");

    // ---------------------------------------------------------
    debugPrint("⏱ [Startup] Initializing NotificationService...");
    final tNoti = DateTime.now().millisecondsSinceEpoch;

    await NotificationService.instance.init();

    debugPrint("✅ [NotificationService ready in ${DateTime.now().millisecondsSinceEpoch - tNoti}ms]");

    // ---------------------------------------------------------

    debugPrint("🎉 [Startup] All systems ready in ${startupTimer.elapsedMilliseconds}ms!");

    runApp(
      MyApp(
        gardenProvider: gardenProvider,
        calendarProvider: calendarProvider,
        scanProvider: ScanProvider(
          PlantRepository(
            GeminiApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND"),
          ),
        ),
        askAiProvider: AskAiProvider(
          ChatRepository(
            GeminiChatApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND"),
          ),
        ),
        searchProvider: SearchProvider(SearchRepository(SearchApiService())),
      ),
    );

  } catch (e, stack) {
    debugPrint("❌ [Startup Crash] $e");
    debugPrint(stack.toString());

    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Startup Error:\n$e"),
        ),
      ),
    ));
  }
}



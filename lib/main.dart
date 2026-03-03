import 'dart:io';
import 'dart:ui';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:untitled/services/ads/AdsProvider.dart';
import 'Auth/auth_state.dart';
import 'firebase_options.dart';
import 'modules/my_garden/services/CreditManager.dart';
import 'modules/my_garden/services/IAPManager.dart';
import 'services/notification/notification_service.dart';
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
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Stopwatch startupTimer = Stopwatch()..start();
  debugPrint("⏳ [Startup] App launch started...");

  // Crash Logging
  FlutterError.onError = (details) {
    debugPrint("🔥 [FlutterError] ${details.exception}");
    debugPrint(details.stack.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("🔥 [PlatformError] $error");
    debugPrint(stack.toString());
    return true;
  };

  try {
    // Initialize Firebase
    debugPrint("⏱ [Startup] Initializing Firebase...");
    final tFb = DateTime.now().millisecondsSinceEpoch;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // 4️⃣ Log a test event so device appears in DebugView
    await analytics.logEvent(name: 'debug_view_test');
    print('📊 Logged debug_view_test event for DebugView');

    debugPrint("✅ [Firebase ready in ${DateTime.now().millisecondsSinceEpoch - tFb}ms]");

    // Request App Tracking Transparency permission
    debugPrint("⏱ [Startup] Requesting ATT permission...");
    final tAtt = DateTime.now().millisecondsSinceEpoch;

    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint("✅ [ATT Status: $status in ${DateTime.now().millisecondsSinceEpoch - tAtt}ms]");
    }

    // NOW initialize Mobile Ads
    debugPrint("⏱ [Startup] Initializing Mobile Ads...");
    final tAds = DateTime.now().millisecondsSinceEpoch;

    await MobileAds.instance.initialize();

    debugPrint("✅ [Mobile Ads ready in ${DateTime.now().millisecondsSinceEpoch - tAds}ms]");

    // Load .env
    debugPrint("⏱ [Startup] Loading .env...");
    final t1 = DateTime.now().millisecondsSinceEpoch;

    await dotenv.load(fileName: ".env");

    debugPrint("✅ [.env loaded in ${DateTime.now().millisecondsSinceEpoch - t1}ms]");

    // Initialize Hive
    debugPrint("⏱ [Startup] Initializing Hive...");
    final tHive = DateTime.now().millisecondsSinceEpoch;

    await Hive.initFlutter('ai_tree_plant_db');

    debugPrint("✅ [Hive ready in ${DateTime.now().millisecondsSinceEpoch - tHive}ms]");

    // Initialize Databases
    debugPrint("⏱ [Startup] Opening GardenDB...");
    final tGdb = DateTime.now().millisecondsSinceEpoch;

    await GardenDB.init();

    debugPrint("✅ [GardenDB ready in ${DateTime.now().millisecondsSinceEpoch - tGdb}ms]");

    debugPrint("⏱ [Startup] Opening ScanDB...");
    final tSdb = DateTime.now().millisecondsSinceEpoch;

    await ScanDB.init();

    debugPrint("✅ [ScanDB ready in ${DateTime.now().millisecondsSinceEpoch - tSdb}ms]");

    // Initialize Providers
    debugPrint("⏱ [Startup] Initializing GardenProvider...");
    final tGp = DateTime.now().millisecondsSinceEpoch;

    final gardenProvider = GardenProvider();
    await gardenProvider.init();

    debugPrint("✅ [GardenProvider ready in ${DateTime.now().millisecondsSinceEpoch - tGp}ms]");

    debugPrint("⏱ [Startup] Initializing CalendarProvider...");
    final tCp = DateTime.now().millisecondsSinceEpoch;

    final calendarProvider = CalendarProvider(gardenProvider: gardenProvider);
    await calendarProvider.init();

    debugPrint("✅ [CalendarProvider ready in ${DateTime.now().millisecondsSinceEpoch - tCp}ms]");

    // ✅ Initialize Credit Manager
    debugPrint("⏱ [Startup] Initializing CreditManager...");
    final tCm = DateTime.now().millisecondsSinceEpoch;

    final creditManager = CreditManager();
    await creditManager.init();

    debugPrint("✅ [CreditManager ready in ${DateTime.now().millisecondsSinceEpoch - tCm}ms]");

    // ✅ Initialize AuthState and connect with CreditManager
    debugPrint("⏱ [Startup] Initializing AuthState...");
    final tAuth = DateTime.now().millisecondsSinceEpoch;

    final authState = AuthState();
    // Connect AuthState with CreditManager for automatic credit refresh
    authState.onUserSignedIn = (String uid) {
      debugPrint("🔄 [Startup] User signed in - refreshing credits");
      creditManager.syncCredits();
    };

    debugPrint("✅ [AuthState ready in ${DateTime.now().millisecondsSinceEpoch - tAuth}ms]");

    // ✅ Initialize Ad Provider with Credit Manager
    debugPrint("⏱ [Startup] Initializing AdProvider...");
    final tAp = DateTime.now().millisecondsSinceEpoch;

    final adProvider = AdProvider(creditManager: creditManager);

    // Preload rewarded ad
    adProvider.preloadAd(AdType.rewardedAd);

    debugPrint("✅ [AdProvider ready in ${DateTime.now().millisecondsSinceEpoch - tAp}ms]");

    // ✅ Initialize IAP Manager
    debugPrint("⏱ [Startup] Initializing IAP Manager...");
    final tIap = DateTime.now().millisecondsSinceEpoch;

    final iapManager = IAPManager();
    await iapManager.init(creditManager);

    debugPrint("✅ [IAP Manager ready in ${DateTime.now().millisecondsSinceEpoch - tIap}ms]");

    // Initialize Notification Service
    debugPrint("⏱ [Startup] Initializing NotificationService...");
    final tNoti = DateTime.now().millisecondsSinceEpoch;

    await NotificationService.instance.init();

    debugPrint("✅ [NotificationService ready in ${DateTime.now().millisecondsSinceEpoch - tNoti}ms]");

    debugPrint("🎉 [Startup] All systems ready in ${startupTimer.elapsedMilliseconds}ms!");

    // Create other providers
    final scanProvider = ScanProvider(
      PlantRepository(
        GeminiApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND"),
      ),
    );

    final askAiProvider = AskAiProvider(
      ChatRepository(
        GeminiChatApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND"),
      ),
    );


    final searchProvider = SearchProvider(SearchRepository(SearchApiService()));

    // ✅ Run app with all providers
    runApp(
      MyApp(
        gardenProvider: gardenProvider,
        calendarProvider: calendarProvider,
        scanProvider: scanProvider,
        askAiProvider: askAiProvider,
        searchProvider: searchProvider,
        creditManager: creditManager,
        adProvider: adProvider,
        authState: authState, // Pass authState
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



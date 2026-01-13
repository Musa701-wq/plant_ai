import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart' hide AppleAuth;
import '../../../Auth/google_auth.dart' as authService;
import '../../../Auth/google_sign_out.dart';
import '../../../main.dart';
import '../../../my_app/app_routes.dart';
import '../../../my_app/app_state_provider.dart';
import '../../../services/ads/AdsProvider.dart';
import '../../../services/ads/ads_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../calender/provider/calender_provider.dart';
import '../../my_garden/db/database/garden_db.dart';
import '../../my_garden/screen/set_reminder_screen.dart';
import '../../scan/db/database/scan_db.dart';
import '../widgets/water_calc_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Broadcast streams to allow multiple listeners
  late Stream<int> _scanCountStream;
  late Stream<int> _gardenCountStream;

  bool _isSigningIn = false;

  void _showGlobalLoading() {
    setState(() {
      _isSigningIn = true;
    });
  }

  void _hideGlobalLoading() {
    if (mounted) {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Convert streams to broadcast streams to allow multiple listeners
    _scanCountStream = ScanDB.watchTotalCount().asBroadcastStream();
    _gardenCountStream = GardenDB.watchTotalCount().asBroadcastStream();

    // Preload native ads when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();
      adProvider.preloadAd(AdType.homeAd1, adSize: TemplateType.small);
      adProvider.preloadAd(AdType.homeAd2, adSize: TemplateType.small);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final calendarProvider = context.watch<CalendarProvider>();

    // Responsive scaling helpers
    double fontScale(double value) => value * (screenWidth / 375).clamp(0.75, 1.15);
    double heightScale(double value) => value * (screenHeight / 812).clamp(0.75, 1.2);
    double widthScale(double value) => value * (screenWidth / 375).clamp(0.8, 1.15);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryGreen, // Android
        statusBarIconBrightness: Brightness.light, // Android icons (white)
        statusBarBrightness: Brightness.dark, // iOS text (white)
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Fixed and properly collapsing App Bar
            _buildResponsiveSliverAppBar(
              context,
              fontScale,
              heightScale,
              widthScale,
            ),

            // Main Content
            SliverPadding(
              padding: EdgeInsets.only(
                left: widthScale(16),
                right: widthScale(16),
                top: heightScale(16),
                bottom: heightScale(24),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Section
                  _buildModernStatsSection(
                    fontScale,
                    heightScale,
                    calendarProvider,
                    screenWidth,
                    widthScale,
                  ),
                  SizedBox(height: heightScale(10)),

                  // // First Native Ad (homeAd1) - Before Quick Actions
                  _buildNativeAd(
                    context,
                    AdType.homeAd1,
                    widthScale,
                    heightScale,
                  ),
                  //SizedBox(height: heightScale(5)),

                  // Quick Actions
                  _buildModernQuickActions(
                    fontScale,
                    heightScale,
                    context,
                    screenWidth,
                    widthScale,
                  ),
                  SizedBox(height: heightScale(10)),

                  // // Second Native Ad (homeAd2) - Before Care Tools
                  _buildNativeAd(
                    context,
                    AdType.homeAd2,
                    widthScale,
                    heightScale,
                  ),
                  // SizedBox(height: heightScale(0)),

                  // Care Tools Section Header
                  Text(
                    'Care Tools',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: fontScale(18),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: heightScale(12)),

                  // Care Tools Horizontal List
                  _buildModernCareToolsSection(
                    context,
                    fontScale,
                    heightScale,
                    screenWidth,
                    widthScale,
                  ),
                  SizedBox(height: heightScale(30)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- NATIVE AD WIDGET ----------
  Widget _buildNativeAd(
    BuildContext context,
    AdType adType,
    double Function(double) widthScale,
    double Function(double) heightScale,
  ) {
    final adProvider = context.watch<AdProvider>();
    final isAdLoaded = adType == AdType.homeAd1
        ? adProvider.isHomeAd1
        : adProvider.isHomeAd2;
    final nativeAd = adType == AdType.homeAd1
        ? adProvider.homeAd1
        : adProvider.homeAd2;

    if (!isAdLoaded || nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 130, // Minimum 120dp + padding for AdMob requirements
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AdWidget(ad: nativeAd),
      ),
    );
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning, Green Thumb! 👋';
    if (hour >= 12 && hour < 17) return 'Good Afternoon, Green Thumb! 🌼';
    if (hour >= 17 && hour < 21) return 'Good Evening, Green Thumb! 🌿';
    return 'Good Night, Green Thumb! 🌙';
  }

  String getGreetingShort() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning 👋';
    if (hour >= 12 && hour < 17) return 'Good Afternoon 🌼';
    if (hour >= 17 && hour < 21) return 'Good Evening 🌿';
    return 'Good Night 🌙';
  }

  // ---------- RESPONSIVE SLIVER APP BAR ----------
  Widget _buildResponsiveSliverAppBar(
    BuildContext context,
    double Function(double) scale,
    double Function(double) heightScale,
    double Function(double) widthScale,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final expandedHeight = isSmallScreen ? 160.0 : 180.0;
    final authState = Provider.of<AuthState>(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final top = constraints.biggest.height;
          final isCollapsed =
              top <= kToolbarHeight + MediaQuery.of(context).padding.top + 20;

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: EdgeInsets.only(
              left: widthScale(20),
              bottom: scale(14),
              right: widthScale(20),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'PlantEye AI',
                      style: TextStyle(
                        fontSize: scale(18),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  //_buildModernProBadge(context, authState, scale, isSmall: true),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.secondaryGreen,
                    AppColors.primaryGreen.withOpacity(0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    widthScale(20),
                    scale(12),
                    widthScale(20),
                    scale(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: scale(isSmallScreen ? 38 : 42),
                                height: scale(isSmallScreen ? 38 : 42),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.eco,
                                  color: Colors.white,
                                  size: scale(isSmallScreen ? 20 : 22),
                                ),
                              ),
                              SizedBox(width: scale(10)),
                              Text(
                                'PlantEye AI',
                                style: TextStyle(
                                  fontSize: scale(isSmallScreen ? 20 : 22),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          //_buildModernProBadge(context, authState, scale),
                        ],
                      ),

                      SizedBox(height: heightScale(isSmallScreen ? 14 : 18)),

                      // Greeting
                      Text(
                        isSmallScreen
                            ? getGreetingShort()
                            : getGreetingMessage(),
                        style: TextStyle(
                          fontSize: scale(isSmallScreen ? 16 : 18),
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: scale(4)),
                      Text(
                        'Ready to explore nature today?',
                        style: TextStyle(
                          fontSize: scale(isSmallScreen ? 12 : 13),
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Future<bool> showSignInDialog(BuildContext context) async {
  //   final result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (dialogContext) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         backgroundColor: const Color(0xFFF5F5FF),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 "Sign In to Continue",
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.black87,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Please sign in with your Google or Apple account to continue.',
  //                 style: const TextStyle(fontSize: 14, color: Colors.black54),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // Google Sign In Button
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: OutlinedButton.icon(
  //                   style: OutlinedButton.styleFrom(
  //                     padding: const EdgeInsets.symmetric(vertical: 14),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     side: const BorderSide(color: Colors.transparent),
  //                     backgroundColor: Colors.white,
  //                     shadowColor: Colors.black12,
  //                     elevation: 1,
  //                   ),
  //                   onPressed: () async {
  //                     // Close dialog first
  //                    // Navigator.of(dialogContext).pop(true);
  //
  //                     // Now handle sign-in in the parent context
  //                     await _handleGoogleSignIn(context);
  //                     //await authService.signInWithGoogle();
  //                   },
  //                   icon: const Icon(
  //                     Icons.golf_course_outlined,
  //                     color: Colors.black54,
  //                     size: 18,
  //                   ),
  //                   label: Text(
  //                     "Sign in with Google",
  //                     style: const TextStyle(
  //                       color: Colors.black87,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //
  //               // Apple Sign In Button
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton.icon(
  //                   style: ElevatedButton.styleFrom(
  //                     padding: const EdgeInsets.symmetric(vertical: 14),
  //                     backgroundColor: Colors.black,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                   onPressed: () async {
  //                     // Close dialog first
  //                     Navigator.of(dialogContext).pop(true);
  //
  //                     // Now handle sign-in in the parent context
  //                     await _handleAppleSignIn(context);
  //                   },
  //                   icon: const Icon(
  //                     Icons.apple_outlined,
  //                     color: Colors.white,
  //                     size: 20,
  //                   ),
  //                   label: Text(
  //                     "Sign in with Apple",
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(dialogContext).pop(false);
  //                 },
  //                 child: Text(
  //                   "Cancel",
  //                   style: const TextStyle(color: Colors.black54, fontSize: 14),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   return result ?? false;
  // }

  // // Replace your existing _handleGoogleSignIn and _handleAppleSignIn methods with these:
  // // Updated _handleGoogleSignIn with navigation to home
  //
  //   Future<void> _handleGoogleSignIn(BuildContext context) async {
  //     debugPrint("🔵 [HomeScreen] Google sign-in handler called");
  //
  //     // if (!context.mounted) {
  //     //   debugPrint("⚠️ [HomeScreen] Context not mounted, aborting");
  //     //   return;
  //     // }
  //
  //     //final scaffoldMessenger = ScaffoldMessenger.of(context);
  //
  //     // // Show loading
  //     // scaffoldMessenger.showSnackBar(
  //     //   const SnackBar(
  //     //     content: Row(
  //     //       children: [
  //     //         SizedBox(
  //     //           width: 20,
  //     //           height: 20,
  //     //           child: CircularProgressIndicator(
  //     //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //     //             strokeWidth: 2,
  //     //           ),
  //     //         ),
  //     //         SizedBox(width: 12),
  //     //         Text("Signing in with Google..."),
  //     //       ],
  //     //     ),
  //     //     backgroundColor: Color(0xFF4285F4),
  //     //     duration: Duration(seconds: 30),
  //     //   ),
  //     // );
  //
  //     try {
  //       final userCredential = await authService.signInWithGoogle();
  //
  //       if (!context.mounted) {
  //         debugPrint("⚠️ [HomeScreen] Context lost after sign-in");
  //         return;
  //       }
  //
  //       //scaffoldMessenger.hideCurrentSnackBar();
  //
  //       if (userCredential != null && userCredential.user != null) {
  //         debugPrint("✅ [HomeScreen] Google sign-in successful");
  //
  //
  //         // AuthState will auto-update via FirebaseAuth listener
  //         //final authState = Provider.of<AuthState>(context, listen: false);
  //
  //         // Force a check (optional, listener should handle it)
  //        // debugPrint("📢 [HomeScreen] Current auth state: ${authState.isUserSignedIn}");
  //
  //         // // Show success message
  //         // scaffoldMessenger.showSnackBar(
  //         //   SnackBar(
  //         //     content: Row(
  //         //       children: [
  //         //         const Icon(Icons.check_circle, color: Colors.white),
  //         //         const SizedBox(width: 8),
  //         //         Expanded(
  //         //           child: Text(
  //         //             "Welcome, ${userCredential.user!.displayName ?? 'User'}!",
  //         //           ),
  //         //         ),
  //         //       ],
  //         //     ),
  //         //     backgroundColor: Colors.green,
  //         //     duration: const Duration(seconds: 2),
  //         //   ),
  //         // );
  //
  //         // Navigate to Home Screen (refresh current screen)
  //         debugPrint("🏠 [HomeScreen] Navigating to home screen...");
  //
  //         // Option 1: Stay on current screen (just refresh)
  //         if (mounted) {
  //           // // Switch to home tab (index 0)
  //           // Navigator.pushReplacementNamed(context, AppRoutes.home);
  //           // setState(() {
  //           //   debugPrint("🔄 [HomeScreen] Refreshing UI after sign-in");
  //           // });
  //           Navigator.of(context).pop();
  //           Navigator.of(context).pushNamed(AppRoutes.home);
  //           setState(() {
  //
  //           });
  //         }
  //
  //         // Option 2: If you want to navigate to a specific route
  //         // Navigator.pushReplacementNamed(context, AppRoutes.home);
  //
  //         // Option 3: If using tab navigation, switch to home tab
  //         // context.read<AppStateProvider>().changeTab(0);
  //
  //       } else {
  //         debugPrint("⚠️ [HomeScreen] Google sign-in returned null");
  //         // scaffoldMessenger.showSnackBar(
  //         //   const SnackBar(
  //         //     content: Text("Sign in cancelled or failed"),
  //         //     backgroundColor: Colors.orange,
  //         //     duration: Duration(seconds: 2),
  //         //   ),
  //         // );
  //       }
  //     } catch (e) {
  //       debugPrint("❌ [HomeScreen] Google sign-in error: $e");
  //
  //       if (!context.mounted) return;
  //      /// scaffoldMessenger.hideCurrentSnackBar();
  //      //  scaffoldMessenger.showSnackBar(
  //      //    SnackBar(
  //      //      content: Text('Error: ${e.toString()}'),
  //      //      backgroundColor: Colors.red,
  //      //      duration: const Duration(seconds: 3),
  //      //    ),
  //      //  );
  //     }
  //   }
  //
  // // Updated _handleAppleSignIn with navigation to home
  // // In your HomeScreen, replace _handleAppleSignIn method with this:
  //
  //   Future<void> _handleAppleSignIn(BuildContext context) async {
  //     debugPrint("🍎 [HomeScreen] Apple sign-in handler called");
  //
  //     if (!context.mounted) {
  //       debugPrint("⚠️ [HomeScreen] Context not mounted, aborting");
  //       return;
  //     }
  //
  //     final scaffoldMessenger = ScaffoldMessenger.of(context);
  //
  //     // Show loading
  //     scaffoldMessenger.showSnackBar(
  //       const SnackBar(
  //         content: Row(
  //           children: [
  //             SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                 strokeWidth: 2,
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Text("Signing in with Apple..."),
  //           ],
  //         ),
  //         backgroundColor: Colors.black,
  //         duration: Duration(seconds: 30),
  //       ),
  //     );
  //
  //     try {
  //       // IMPORTANT: Check if Apple Sign-In is available first
  //       final isAvailable = await SignInWithApple.isAvailable();
  //
  //       if (!isAvailable) {
  //         throw Exception('Apple Sign-In is not available on this device. Please update to iOS 13 or later.');
  //       }
  //
  //       final user = await AppleAuth.signInWithApple();
  //
  //       if (!context.mounted) {
  //         debugPrint("⚠️ [HomeScreen] Context lost after sign-in");
  //         return;
  //       }
  //
  //       scaffoldMessenger.hideCurrentSnackBar();
  //
  //       if (user != null) {
  //         debugPrint("✅ [HomeScreen] Apple sign-in successful");
  //
  //         // Show success message
  //         scaffoldMessenger.showSnackBar(
  //           SnackBar(
  //             content: Row(
  //               children: [
  //                 const Icon(Icons.check_circle, color: Colors.white),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     user.displayName != null
  //                         ? "Welcome, ${user.displayName}!"
  //                         : "Welcome! Signed in successfully",
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             backgroundColor: Colors.green,
  //             duration: const Duration(seconds: 2),
  //           ),
  //         );
  //
  //         // Refresh UI
  //         if (mounted) {
  //           setState(() {
  //             debugPrint("🔄 [HomeScreen] Refreshing UI after sign-in");
  //           });
  //         }
  //
  //       } else {
  //         debugPrint("⚠️ [HomeScreen] Apple sign-in returned null");
  //         scaffoldMessenger.showSnackBar(
  //           const SnackBar(
  //             content: Row(
  //               children: [
  //                 Icon(Icons.info_outline, color: Colors.white),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text("Sign in was cancelled. Please try again."),
  //                 ),
  //               ],
  //             ),
  //             backgroundColor: Colors.orange,
  //             duration: Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }
  //       // on AppleSignInException catch (e) {
  //     //   debugPrint("❌ [HomeScreen] Apple sign-in error: ${e.code}");
  //     //
  //     //   if (!context.mounted) return;
  //     //   scaffoldMessenger.hideCurrentSnackBar();
  //     //
  //     //   String userMessage = e.message;
  //     //
  //     //   // Add helpful hints for common errors
  //     //   if (e.code == 'PLATFORM_NOT_SUPPORTED') {
  //     //     userMessage = 'Apple Sign-In is only available on iOS 13+ devices.';
  //     //   } else if (e.code == 'NOT_AVAILABLE') {
  //     //     userMessage = 'Apple Sign-In is not available. Please update your iOS to 13.0 or later.';
  //     //   } else if (e.code == 'failed') {
  //     //     userMessage = 'Configuration error. Please ensure:\n'
  //     //         '1. "Sign in with Apple" capability is added in Xcode\n'
  //     //         '2. App is configured in Apple Developer Portal\n'
  //     //         '3. Service ID is created and configured\n'
  //     //         '4. Apple provider is enabled in Firebase Console';
  //     //   }
  //     //
  //     //   scaffoldMessenger.showSnackBar(
  //     //     SnackBar(
  //     //       content: Column(
  //     //         mainAxisSize: MainAxisSize.min,
  //     //         crossAxisAlignment: CrossAxisAlignment.start,
  //     //         children: [
  //     //           const Row(
  //     //             children: [
  //     //               Icon(Icons.error_outline, color: Colors.white),
  //     //               SizedBox(width: 8),
  //     //               Text(
  //     //                 "Sign-in Error",
  //     //                 style: TextStyle(fontWeight: FontWeight.bold),
  //     //               ),
  //     //             ],
  //     //           ),
  //     //           const SizedBox(height: 8),
  //     //           Text(userMessage),
  //     //         ],
  //     //       ),
  //     //       backgroundColor: Colors.red,
  //     //       duration: const Duration(seconds: 7),
  //     //       action: SnackBarAction(
  //     //         label: 'Dismiss',
  //     //         textColor: Colors.white,
  //     //         onPressed: () {},
  //     //       ),
  //     //     ),
  //     //   );
  //     // }
  //     catch (e) {
  //       debugPrint("❌ [HomeScreen] Unexpected error: $e");
  //
  //       if (!context.mounted) return;
  //       scaffoldMessenger.hideCurrentSnackBar();
  //
  //       scaffoldMessenger.showSnackBar(
  //         SnackBar(
  //           content: Text("Unexpected error: ${e.toString()}"),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   }

  // ---------- MODERN STATS SECTION ----------
/*

  Widget _buildModernStatsSection(
    double Function(double) scale,
    double Function(double) heightScale,
    CalendarProvider provider,
    double screenWidth,
    double Function(double) widthScale,
  ) {
    final allReminders = provider.allReminders.length;
    final isSmallScreen = screenWidth < 360;
    final isTinyScreen = screenWidth < 340;

    return Container(
      padding: EdgeInsets.all(scale(isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isSmallScreen ? 'Overview' : 'Plant Overview',
                  style: TextStyle(
                    fontSize: scale(isSmallScreen ? 15 : 17),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scale(10),
                  vertical: scale(5),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    fontSize: scale(10),
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scale(isSmallScreen ? 14 : 18)),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: _scanCountStream,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildModernStatItem(
                      count.toString(),
                      isTinyScreen ? 'Identified' : 'Plants\nIdentified',
                      Icons.search_rounded,
                      AppColors.primaryGreen,
                      scale,
                      isSmallScreen,
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _gardenCountStream,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildModernStatItem(
                      count.toString(),
                      isTinyScreen ? 'Garden' : 'In My\nGarden',
                      Icons.eco_rounded,
                      AppColors.secondaryGreen,
                      scale,
                      isSmallScreen,
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildModernStatItem(
                  allReminders.toString(),
                  isTinyScreen ? 'Reminders' : 'Total\nReminders',
                  Icons.notifications_active_rounded,
                  AppColors.accentOrange,
                  scale,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
*/
// ---------- MODERN STATS SECTION ----------

  Widget _buildModernStatsSection(
      double Function(double) scale,
      double Function(double) heightScale,
      CalendarProvider provider,
      double screenWidth,
      double Function(double) widthScale,
      ) {
    final allReminders = provider.allReminders.length;
    final isSmallScreen = screenWidth < 360;
    final isTinyScreen = screenWidth < 340;

    return InkWell(
      onTap: () {
        // My Garden screen par navigate karo (tab index 4)
        context.read<AppStateProvider>().changeTab(4);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(scale(isSmallScreen ? 16 : 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        isSmallScreen ? 'Overview' : 'Plant Overview',
                        style: TextStyle(
                          fontSize: scale(isSmallScreen ? 15 : 17),
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: scale(8)),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: scale(12),
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scale(10),
                    vertical: scale(5),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Click to View',
                    style: TextStyle(
                      fontSize: scale(10),
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scale(isSmallScreen ? 14 : 18)),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _scanCountStream,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildModernStatItem(
                        count.toString(),
                        isTinyScreen ? 'Identified' : 'Plants\nIdentified',
                        Icons.search_rounded,
                        AppColors.primaryGreen,
                        scale,
                        isSmallScreen,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _gardenCountStream,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildModernStatItem(
                        count.toString(),
                        isTinyScreen ? 'Garden' : 'In My\nGarden',
                        Icons.eco_rounded,
                        AppColors.secondaryGreen,
                        scale,
                        isSmallScreen,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildModernStatItem(
                    allReminders.toString(),
                    isTinyScreen ? 'Reminders' : 'Total\nReminders',
                    Icons.notifications_active_rounded,
                    AppColors.accentOrange,
                    scale,
                    isSmallScreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 /* Widget _buildModernStatItem(
    String count,
    String label,
    IconData icon,
    Color color,
    double Function(double) scale,
    bool isSmallScreen,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: scale(isSmallScreen ? 44 : 50),
          height: scale(isSmallScreen ? 44 : 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: scale(isSmallScreen ? 20 : 24),
          ),
        ),
        SizedBox(height: scale(10)),
        Text(
          count,
          style: TextStyle(
            fontSize: scale(isSmallScreen ? 20 : 24),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: scale(4)),
        SizedBox(
          width: scale(70),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scale(isSmallScreen ? 9 : 10),
              color: AppColors.textSecondary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
*/
  Widget _buildModernStatItem(
      String count,
      String label,
      IconData icon,
      Color color,
      double Function(double) scale,
      bool isSmallScreen,
      {VoidCallback? onTap} // ✅ Add optional onTap parameter
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: scale(isSmallScreen ? 44 : 50),
            height: scale(isSmallScreen ? 44 : 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: scale(isSmallScreen ? 20 : 24),
            ),
          ),
          SizedBox(height: scale(10)),
          Text(
            count,
            style: TextStyle(
              fontSize: scale(isSmallScreen ? 20 : 24),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: scale(4)),
          SizedBox(
            width: scale(70),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: scale(isSmallScreen ? 9 : 10),
                color: AppColors.textSecondary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  // ---------- MODERN QUICK ACTIONS ----------
  Widget _buildModernQuickActions(
    double Function(double) scale,
    double Function(double) heightScale,
    BuildContext context,
    double screenWidth,
    double Function(double) widthScale,
  ) {
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: scale(isSmallScreen ? 16 : 18),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: scale(0)),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: scale(12),
          mainAxisSpacing: scale(12),
          childAspectRatio: isSmallScreen ? 1.05 : 1.15,
          children: [
            _buildModernActionCard(
              'Plant Identify',
              Icons.camera_alt_rounded,
              AppColors.primaryGreen,
              'Scan & Identify',
              scale,
              isSmallScreen,
              () => Navigator.pushNamed(context, AppRoutes.scan),
            ),
            _buildModernActionCard(
              'Ask AI',
              Icons.auto_awesome_rounded,
              const Color(0xFFFF6B35),
              'Get Advice',
              scale,
              isSmallScreen,
              () => context.read<AppStateProvider>().changeTab(1),
            ),
            _buildModernActionCard(
              'My Garden',
              Icons.eco_rounded,
              AppColors.secondaryGreen,
              'View Plants',
              scale,
              isSmallScreen,
              () => context.read<AppStateProvider>().changeTab(4),
            ),
            _buildModernActionCard(
              'Calendar',
              Icons.calendar_month_rounded,
              AppColors.accentOrange,
              'Care Schedule',
              scale,
              isSmallScreen,
              () => context.read<AppStateProvider>().changeTab(3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernActionCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    double Function(double) scale,
    bool isSmallScreen,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        padding: EdgeInsets.all(scale(isSmallScreen ? 12 : 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(scale(isSmallScreen ? 8 : 12)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: scale(isSmallScreen ? 22 : 24),
              ),
            ),
            SizedBox(height: scale(isSmallScreen ? 10 : 12)),
            Text(
              title,
              style: TextStyle(
                fontSize: scale(isSmallScreen ? 13 : 14),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: scale(2)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: scale(isSmallScreen ? 10 : 11),
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CARE TOOLS ----------
  Widget _buildModernCareToolsSection(
    BuildContext context,
    double Function(double) scale,
    double Function(double) heightScale,
    double screenWidth,
    double Function(double) widthScale,
  ) {
    final isSmallScreen = screenWidth < 360;

    return SizedBox(
      height: heightScale(isSmallScreen ? 160 : 175),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildModernToolCard(
            'Recent Scans',
            Icons.photo_library_rounded,
            'View scan history',
            AppColors.primaryGreen,
            scale,
            isSmallScreen,
            () => Navigator.pushNamed(context, AppRoutes.recentScans),
          ),
          _buildModernToolCard(
            'Set Reminders',
            Icons.notifications_active_rounded,
            'Create schedules',
            AppColors.accentOrange,
            scale,
            isSmallScreen,
                () {
              context.read<AppStateProvider>().changeTab(4);
            },
          ),
          _buildModernToolCard(
            'Water Calculator',
            Icons.water_drop_rounded,
            'Calculate needs',
            AppColors.secondaryGreen,
            scale,
            isSmallScreen,
            () => _showWaterCalculator(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModernToolCard(
    String title,
    IconData icon,
    String description,
    Color color,
    double Function(double) scale,
    bool isSmallScreen,
    VoidCallback onTap,
  ) {
    return Container(
      width: scale(isSmallScreen ? 145 : 155),
      margin: EdgeInsets.only(right: scale(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(scale(isSmallScreen ? 14 : 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(scale(isSmallScreen ? 12 : 14)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: scale(isSmallScreen ? 24 : 26),
                  color: color,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: scale(isSmallScreen ? 13 : 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: scale(4)),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: scale(isSmallScreen ? 10 : 11),
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helper ----------
  //void _showProSubscription(BuildContext context) => Navigator.pushNamed(context, AppRoutes.subscription);

  void _showWaterCalculator(BuildContext context) async {
    //await AdService.instance.showInterstitialAndWait();
    WaterCalcSheetLauncher.show(context);
  }
}

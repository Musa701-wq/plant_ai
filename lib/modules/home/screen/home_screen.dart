import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import '../../my_garden/services/PromoPurchaseScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart' hide AppleAuth;
import '../../../Auth/google_auth.dart' as authService;
import '../../../Auth/google_sign_out.dart';
import '../../../google_analytics.dart';
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
import '../../ask_ai/screen/ask_ai_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    _scanCountStream = ScanDB.watchTotalCount().asBroadcastStream();
    _gardenCountStream = GardenDB.watchTotalCount().asBroadcastStream();

    // ✅ Preload only ONE native ad (homeAd1) instead of two
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();
      adProvider.preloadAd(AdType.homeAd1, adSize: TemplateType.small);
      // ❌ Removed: adProvider.preloadAd(AdType.homeAd2, adSize: TemplateType.small);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final calendarProvider = context.watch<CalendarProvider>();

    double fontScale(double value) => value * (screenWidth / 375).clamp(0.75, 1.15);
    double heightScale(double value) => value * (screenHeight / 812).clamp(0.75, 1.2);
    double widthScale(double value) => value * (screenWidth / 375).clamp(0.8, 1.15);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'ask_ai_home_fab',
          onPressed: () {
            AnalyticsService.trackAskAiHomeCard();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AskAiScreen()),
            );
          },
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.auto_awesome_rounded, size: 20),
          label: const Text(
            'Ask AI',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildResponsiveSliverAppBar(
              context,
              fontScale,
              heightScale,
              widthScale,
            ),

            SliverPadding(
              padding: EdgeInsets.only(
                left: widthScale(16),
                right: widthScale(16),
                top: heightScale(16),
                bottom: heightScale(24),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Promo Marquee
                  _buildPromoMarquee(context, widthScale, heightScale),
                  SizedBox(height: heightScale(16)),

                  // Stats Section
                  _buildModernStatsSection(
                    fontScale,
                    heightScale,
                    calendarProvider,
                    screenWidth,
                    widthScale,
                  ),
                  SizedBox(height: heightScale(10)),

                  // ✅ Single Native Ad - Before Quick Actions
                  _buildNativeAd(
                    context,
                    AdType.homeAd1,
                    widthScale,
                    heightScale,
                  ),

                  // Quick Actions
                  _buildModernQuickActions(
                    fontScale,
                    heightScale,
                    context,
                    screenWidth,
                    widthScale,
                  ),
                  SizedBox(height: heightScale(10)),

                  // ❌ Removed: Second Native Ad (homeAd2)

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

  Widget _buildPromoMarquee(BuildContext context, double Function(double) widthScale, double Function(double) heightScale) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PromoPurchaseScreen()),
        );
      },
      child: Container(
        height: heightScale(45),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800), // AppColors.accentOrange (or similar) to attract attention
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Marquee(
            text: '🌟 Special Offer: Unlock 250 Credits Now! Tap here to grab the Starter Pack! 🌟   ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 30.0,
            velocity: 40.0,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
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
      height: 130,
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
                        ],
                      ),

                      SizedBox(height: heightScale(isSmallScreen ? 14 : 18)),

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
        context.read<AppStateProvider>().changeTab(3);
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

  Widget _buildModernStatItem(
      String count,
      String label,
      IconData icon,
      Color color,
      double Function(double) scale,
      bool isSmallScreen,
      {VoidCallback? onTap}
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
/*
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
*/
          children: [
            _buildModernActionCard(
              'Plant Identify',
              Icons.camera_alt_rounded,
              AppColors.primaryGreen,
              'Scan & Identify',
              scale,
              isSmallScreen,
                  () {
                AnalyticsService.trackScanHomeCard(); // ✅ Click only
                Navigator.pushNamed(context, AppRoutes.scan);
              },
            ),
            _buildModernActionCard(
              'Ask AI',
              Icons.auto_awesome_rounded,
              const Color(0xFFFF6B35),
              'Get Advice',
              scale,
              isSmallScreen,
                  () {
                AnalyticsService.trackAskAiHomeCard();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AskAiScreen()),
                );
              },
            ),
            _buildModernActionCard(
              'My Garden',
              Icons.eco_rounded,
              AppColors.secondaryGreen,
              'View Plants',
              scale,
              isSmallScreen,
                  () {
                AnalyticsService.trackMyGardenHomeCard();
                context.read<AppStateProvider>().changeTab(3); // My Garden (tab 3)
              },
            ),
            _buildModernActionCard(
              'Calendar',
              Icons.calendar_month_rounded,
              AppColors.accentOrange,
              'Care Schedule',
              scale,
              isSmallScreen,
                  () {
                AnalyticsService.trackCalendarHomeCard();
                context.read<AppStateProvider>().changeTab(2);
              },
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
          _buildModernToolCard(
            'Pest Doctor',
            Icons.bug_report_rounded,
            'Identify & treat',
            const Color(0xFFD32F2F),
            scale,
            isSmallScreen,
                () => Navigator.pushNamed(context, AppRoutes.pestScan),
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

  void _showWaterCalculator(BuildContext context) async {
    WaterCalcSheetLauncher.show(context);
  }
}
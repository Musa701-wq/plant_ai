// // lib/screens/main_navigator.dart
// import 'package:ai_tree_plant/modules/my_garden/screen/my_garden_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../config/app_routes.dart';
// import '../../my_app/app_state_provider.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_text_style.dart';
// import '../ask_ai/screen/ask_ai_screen.dart';
// import '../calender/screen/calender_screen.dart';
// import '../home/screen/home_screen.dart';
//
// class MainNavigator extends StatefulWidget {
//   const MainNavigator({super.key});
//
//   @override
//   State<MainNavigator> createState() => _MainNavigatorState();
// }
//
// class _MainNavigatorState extends State<MainNavigator> {
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const AskAiScreen(),
//     const SizedBox.shrink(), // Placeholder for camera tab
//     const CalendarScreen(),
//     const MyGardenScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppStateProvider>(
//
//       builder: (context, appState, child) {
//
//         return Scaffold(
//           resizeToAvoidBottomInset: false, // 👈 prevents FAB from moving
//           body: IndexedStack(index: appState.currentIndex, children: _screens),
//           bottomNavigationBar: _buildBottomNavigationBar(appState),
//           floatingActionButton: _buildCameraFAB(appState),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,
//         );
//       },
//     );
//   }
//
//   Widget _buildBottomNavigationBar(AppStateProvider appState) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: appState.currentIndex == 2
//             ? 0
//             : appState.currentIndex > 2
//             ? appState.currentIndex - 1
//             : appState.currentIndex,
//         onTap: (index) {
//           // Adjust index for camera tab
//           final adjustedIndex = index >= 2 ? index + 1 : index;
//           appState.changeTab(adjustedIndex);
//         },
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppColors.backgroundWhite,
//         selectedItemColor: AppColors.primaryGreen,
//         unselectedItemColor: AppColors.textHint,
//         selectedLabelStyle: AppTextStyles.caption.copyWith(
//           fontWeight: FontWeight.w600,
//         ),
//         unselectedLabelStyle: AppTextStyles.caption,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined, size: 24),
//             activeIcon: Icon(Icons.home_filled, size: 24),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline, size: 24),
//             activeIcon: Icon(Icons.chat_bubble, size: 24),
//             label: 'Ask AI',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined, size: 24),
//             activeIcon: Icon(Icons.calendar_today, size: 24),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.eco_outlined, size: 24),
//             activeIcon: Icon(Icons.eco, size: 24),
//             label: 'My Garden',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCameraFAB(AppStateProvider appState) {
//     return Container(
//       // margin: const EdgeInsets.only(bottom: 15),margin
//       child: FloatingActionButton(
//         onPressed: () {
//           // Navigate to camera screen
//           Navigator.pushNamed(context, AppRoutes.scan);
//         },
//         backgroundColor: AppColors.primaryGreen,
//         foregroundColor: AppColors.backgroundWhite,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//           side: BorderSide(color: AppColors.backgroundWhite, width: 2),
//         ),
//         child: const Icon(Icons.camera_alt_rounded, size: 28),
//       ),
//     );
//   }
// }


// lib/screens/main_navigator.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../my_app/app_state_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_style.dart';
import '../ask_ai/screen/ask_ai_screen.dart';
import '../calender/screen/calender_screen.dart';
import '../home/screen/home_screen.dart';

// class MainNavigator extends StatefulWidget {
//   const MainNavigator({super.key});
//
//   @override
//   State<MainNavigator> createState() => _MainNavigatorState();
// }
//
// class _MainNavigatorState extends State<MainNavigator> {
//   final List<Widget> _screens = const [
//     HomeScreen(),         // 0
//     AskAiScreen(),        // 1
//     SizedBox.shrink(),    // 2 (camera placeholder — not a tab)
//     CalendarScreen(),     // 3
//     MyGardenScreen(),     // 4
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppStateProvider>(
//       builder: (context, appState, child) {
//         /// 👇 Prevent crash & stop black screen
//         int safeIndex = appState.currentIndex;
//         if (safeIndex < 0 || safeIndex >= _screens.length) {
//           safeIndex = 0;
//         }
//
//         return Scaffold(
//           resizeToAvoidBottomInset: false,
//           body: IndexedStack(
//             index: safeIndex,
//             children: _screens,
//           ),
//           bottomNavigationBar: _buildBottomNavigationBar(appState),
//           floatingActionButton: _buildCameraFAB(appState),
//           floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         );
//       },
//     );
//   }
//
//   Widget _buildBottomNavigationBar(AppStateProvider appState) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         /// 👇 Adjust index so FAB slot (index 2) is skipped
//         currentIndex: appState.currentIndex == 2
//             ? 0
//             : appState.currentIndex > 2
//             ? appState.currentIndex - 1
//             : appState.currentIndex,
//         onTap: (index) {
//           final adjustedIndex = index >= 2 ? index + 1 : index;
//           appState.changeTab(adjustedIndex);
//         },
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppColors.backgroundWhite,
//         selectedItemColor: AppColors.primaryGreen,
//         unselectedItemColor: AppColors.textHint,
//         selectedLabelStyle: AppTextStyles.caption.copyWith(
//           fontWeight: FontWeight.w600,
//         ),
//         unselectedLabelStyle: AppTextStyles.caption,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined, size: 24),
//             activeIcon: Icon(Icons.home_filled, size: 24),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline, size: 24),
//             activeIcon: Icon(Icons.chat_bubble, size: 24),
//             label: 'Ask AI',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined, size: 24),
//             activeIcon: Icon(Icons.calendar_today, size: 24),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.eco_outlined, size: 24),
//             activeIcon: Icon(Icons.eco, size: 24),
//             label: 'My Garden',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCameraFAB(AppStateProvider appState) {
//     return FloatingActionButton(
//       onPressed: () => Navigator.pushNamed(context, AppRoutes.scan),
//       backgroundColor: AppColors.primaryGreen,
//       foregroundColor: AppColors.backgroundWhite,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30),
//         side: BorderSide(color: AppColors.backgroundWhite, width: 2),
//       ),
//       child: const Icon(Icons.camera_alt_rounded, size: 28),
//     );
//   }
// }

// lib/screens/main_navigator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_garden/screen/my_garden_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  @override
  void initState() {
    super.initState();
    debugPrint('[MainNavigator] 🏗️ initState called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[MainNavigator] 🎨 Building MainNavigator');

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        int currentIndex = appState.currentIndex;
        debugPrint('[MainNavigator] 📱 Current navigation index: $currentIndex');

        // 🔥 SAFE SCREEN LOADING with error catching
        Widget currentScreen;
        try {
          switch (currentIndex) {
            case 0:
            // 🔥 Try HomeScreen with error boundary
              currentScreen = _buildScreenWithErrorBoundary(
                    () => const HomeScreen(),
                'Home',
                Colors.green,
                Icons.home,
              );
              break;
            case 1:
              currentScreen = _buildScreenWithErrorBoundary(
                    () => const AskAiScreen(),
                'Ask AI',
                Colors.orange,
                Icons.chat,
              );
              break;
            case 2:
              currentScreen = _buildTestScreen('Camera', Colors.blue, Icons.camera);
              break;
            case 3:
              currentScreen = _buildScreenWithErrorBoundary(
                    () => const CalendarScreen(),
                'Calendar',
                Colors.purple,
                Icons.calendar_today,
              );
              break;
            case 4:
              currentScreen = _buildScreenWithErrorBoundary(
                    () => const MyGardenScreen(),
                'Garden',
                Colors.lightGreen,
                Icons.eco,
              );
              break;
            default:
              currentScreen = _buildTestScreen('Home', Colors.green, Icons.home);
          }
          debugPrint('[MainNavigator] ✅ Screen built successfully');
        } catch (e, stackTrace) {
          debugPrint('[MainNavigator] ❌ Error building screen: $e');
          debugPrint('[MainNavigator] Stack: $stackTrace');
          currentScreen = _buildErrorScreen(e.toString());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: currentScreen,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(appState),
          floatingActionButton: _buildCameraFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  // 🔥 NEW: Error boundary wrapper for screens
  Widget _buildScreenWithErrorBoundary(
      Widget Function() builder,
      String screenName,
      Color color,
      IconData icon,
      ) {
    try {
      debugPrint('[MainNavigator] 🏗️ Building $screenName...');
      return builder();
    } catch (e, stackTrace) {
      debugPrint('[MainNavigator] ❌ $screenName failed to build: $e');
      debugPrint('[MainNavigator] Stack: $stackTrace');

      // Fallback to test screen if real screen fails
      return Container(
        color: Colors.red[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '$screenName Error',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Go back to test screen
                  setState(() {});
                },
                child: const Text('Use Test Screen'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTestScreen(String title, Color color, IconData icon) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Working! ✅',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title screen is responding!'),
                    backgroundColor: color,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Test Button',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Screen Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {}); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppStateProvider appState) {
    int selectedIndex = appState.currentIndex;

    // Adjust for camera slot
    if (selectedIndex == 2) {
      selectedIndex = 0;
    } else if (selectedIndex > 2) {
      selectedIndex = selectedIndex - 1;
    }

    // Safety check
    if (selectedIndex < 0 || selectedIndex > 3) {
      selectedIndex = 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          int targetIndex = index >= 2 ? index + 1 : index;
          debugPrint('[MainNavigator] 🔘 BottomNav tapped: $index -> $targetIndex');
          appState.changeTab(targetIndex);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            activeIcon: Icon(Icons.chat_bubble, size: 24),
            label: 'Ask AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 24),
            activeIcon: Icon(Icons.calendar_today, size: 24),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined, size: 24),
            activeIcon: Icon(Icons.eco, size: 24),
            label: 'My Garden',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFAB() {
    return FloatingActionButton(
      onPressed: () {
        debugPrint('[MainNavigator] 📷 Camera FAB pressed');
        // Navigate to ScanScreen
        Navigator.pushNamed(context, AppRoutes.scan);
      },
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.camera_alt, size: 28),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:untitled/modules/my_garden/screen/set_reminder_screen.dart';
// import '../../../services/ads/AdsProvider.dart';
// import '../../../services/ads/ads_service.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../../ask_ai/repo/chat_repo.dart';
// import '../../ask_ai/services/chat_api_service.dart';
// import '../../scan/db/database/scan_db.dart';
// import '../../scan/screen/result_screen.dart';
// import '../db/database/garden_db.dart';
// import '../db/model/garden_plant.dart';
// import '../provider/plant_detail_provider.dart';
// import '../widgets/add_plant_sheet.dart';
// import '../widgets/garden_controls_section.dart';
// import '../widgets/garden_header.dart';
// import '../widgets/plant_grid-card.dart';
// import '../widgets/plant_list_card.dart';
// import '../widgets/stats_section.dart';
//
// class MyGardenScreen extends StatefulWidget {
//   const MyGardenScreen({super.key});
//
//   @override
//   State<MyGardenScreen> createState() => _MyGardenScreenState();
// }
//
// class _MyGardenScreenState extends State<MyGardenScreen> {
//   final List<GardenPlant> _plants = [];
//
//   int _selectedView = 0; // 0: Grid, 1: List
//   String _selectedFilter = 'All';
//
//   // Responsive helper methods
//   double _getResponsivePadding(double screenWidth) {
//     if (screenWidth > 600) return 20;
//     if (screenWidth > 400) return 16;
//     return 12;
//   }
//
//   int _getGridCrossAxisCount(double screenWidth) {
//     if (screenWidth > 900) return 4;
//     if (screenWidth > 600) return 3;
//     return 2;
//   }
//
//   double _getGridSpacing(double screenWidth) {
//     if (screenWidth > 600) return 16;
//     return 12;
//   }
//
//   double _getChildAspectRatio(double screenWidth) {
//     if (screenWidth > 600) return 0.85;
//     return 0.8;
//   }
//
//   double _getFabSize(double screenWidth) {
//     if (screenWidth > 600) return 64;
//     return 56;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     AdService.instance.loadRewarded();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final adProvider = context.read<AdProvider>();
//       adProvider.preloadAd(AdType.myGardenAd, adSize: TemplateType.small);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final horizontalPadding = _getResponsivePadding(screenWidth);
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: ValueListenableBuilder(
//         valueListenable: Hive.box<GardenPlant>('garden_plants').listenable(),
//         builder: (context, Box<GardenPlant> box, _) {
//           final allPlants = box.values.toList();
//           final filteredPlants = _filterPlants(allPlants);
//
//           return Column(
//             children: [
//               // Fixed Header Section
//               HeaderSection(plants: allPlants),
//
//               // Scrollable Content Below
//               Expanded(
//                 child: CustomScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   slivers: [
//                     // Stats Overview
//                     SliverToBoxAdapter(
//                       child: StatsSection(plants: allPlants),
//                     ),
//
//                     // Filter and View Controls
//                     SliverToBoxAdapter(
//                       child: GardenControlsSection(
//                         selectedFilter: _selectedFilter,
//                         selectedView: _selectedView,
//                         onFilterChanged: (filter) {
//                           setState(() {
//                             _selectedFilter = filter;
//                           });
//                         },
//                         onViewChanged: (viewIndex) {
//                           setState(() {
//                             _selectedView = viewIndex;
//                           });
//                         },
//                       ),
//                     ),
//
//                     // My Garden Native Ad
//                     SliverToBoxAdapter(
//                       child: _buildMyGardenNativeAd(context, screenWidth),
//                     ),
//
//                     // Plants Grid/List
//                     SliverPadding(
//                       padding: EdgeInsets.fromLTRB(
//                         horizontalPadding, 4,
//                         horizontalPadding, 4,
//                       ),
//                       sliver: filteredPlants.isEmpty
//                           ? SliverFillRemaining(
//                         hasScrollBody: false,
//                         child: _buildEmptyGardenState(screenWidth),
//                       )
//                           : _selectedView == 0
//                           ? _buildPlantsGridSliver(filteredPlants, screenWidth)
//                           : _buildPlantsListSliver(filteredPlants, screenWidth),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: _buildResponsiveFAB(screenWidth),
//     );
//   }
//
//   Widget _buildResponsiveFAB(double screenWidth) {
//     final fabSize = _getFabSize(screenWidth);
//     final iconSize = screenWidth > 600 ? 32.0 : 28.0;
//
//     return SizedBox(
//       width: fabSize,
//       height: fabSize,
//       child: FloatingActionButton(
//         heroTag: null,
//         onPressed: _addNewPlant,
//         backgroundColor: AppColors.primaryGreen,
//         foregroundColor: AppColors.textOnPrimary,
//         child: Icon(Icons.add, size: iconSize),
//       ),
//     );
//   }
//
//   Widget _buildMyGardenNativeAd(BuildContext context, double screenWidth) {
//     final adProvider = context.watch<AdProvider>();
//     final isAdLoaded = adProvider.isMyGardenAd;
//     final nativeAd = adProvider.myGardenAd;
//
//     if (!isAdLoaded || nativeAd == null) {
//       return const SizedBox.shrink();
//     }
//
//     final adHeight = screenWidth > 600 ? 140.0 : 130.0;
//     final horizontalPadding = screenWidth > 600 ? 8.0 : 4.0;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
//       child: Container(
//         height: adHeight,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: AdWidget(ad: nativeAd),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlantsGridSliver(List<GardenPlant> plants, double screenWidth) {
//     return SliverGrid(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: _getGridCrossAxisCount(screenWidth),
//         crossAxisSpacing: _getGridSpacing(screenWidth),
//         mainAxisSpacing: _getGridSpacing(screenWidth),
//         childAspectRatio: _getChildAspectRatio(screenWidth),
//       ),
//       delegate: SliverChildBuilderDelegate(
//             (context, index) {
//           final plant = plants[index];
//           return PlantGridCard(
//             plant: plant,
//             onTap: () => _showPlantDetails(plant),
//             onEdit: () => _editPlant(plant),
//             onManageReminders: () => _manageReminders(plant),
//             onDelete: () => _deletePlant(plant.id),
//           );
//         },
//         childCount: plants.length,
//       ),
//     );
//   }
//
//   Widget _buildPlantsListSliver(List<GardenPlant> plants, double screenWidth) {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//             (context, index) {
//           final plant = plants[index];
//           return PlantListCard(
//             plant: plant,
//             onTap: () => _showPlantDetails(plant),
//             onEdit: () => _editPlant(plant),
//             onManageReminders: () => _manageReminders(plant),
//             onDelete: () => _deletePlant(plant.id),
//           );
//         },
//         childCount: plants.length,
//       ),
//     );
//   }
//
//   Widget _buildPlantsGrid(List<GardenPlant> plants, double screenWidth) {
//     return GridView.builder(
//       physics: const BouncingScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: _getGridCrossAxisCount(screenWidth),
//         crossAxisSpacing: _getGridSpacing(screenWidth),
//         mainAxisSpacing: _getGridSpacing(screenWidth),
//         childAspectRatio: _getChildAspectRatio(screenWidth),
//       ),
//       itemCount: plants.length,
//       itemBuilder: (context, index) {
//         final plant = plants[index];
//         return PlantGridCard(
//           plant: plant,
//           onTap: () => _showPlantDetails(plant),
//           onEdit: () => _editPlant(plant),
//           onManageReminders: () => _manageReminders(plant),
//           onDelete: () => _deletePlant(plant.id),
//         );
//       },
//     );
//   }
//
//   Widget _buildPlantsList(List<GardenPlant> plants, double screenWidth) {
//     return ListView.builder(
//       physics: const BouncingScrollPhysics(),
//       itemCount: plants.length,
//       itemBuilder: (context, index) {
//         final plant = plants[index];
//         return PlantListCard(
//           plant: plant,
//           onTap: () => _showPlantDetails(plant),
//           onEdit: () => _editPlant(plant),
//           onManageReminders: () => _manageReminders(plant),
//           onDelete: () => _deletePlant(plant.id),
//         );
//       },
//     );
//   }
//
//   Widget _buildEmptyGardenState(double screenWidth) {
//     final iconSize = screenWidth > 600 ? 80.0 : 64.0;
//     final spacing = screenWidth > 600 ? 24.0 : 20.0;
//     final titleSize = screenWidth > 600 ? 22.0 : 18.0;
//     final bodySize = screenWidth > 600 ? 16.0 : 14.0;
//     final buttonPadding = screenWidth > 600
//         ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
//         : const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(screenWidth)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(screenWidth > 600 ? 32 : 24),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundCard,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.eco_outlined,
//                 size: iconSize,
//                 color: AppColors.textHint,
//               ),
//             ),
//             SizedBox(height: spacing),
//             Text(
//               'Your Garden is Empty',
//               style: AppTextStyles.headlineSmall.copyWith(
//                 color: AppColors.textPrimary,
//                 fontSize: titleSize,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add your first plant to start tracking\nand caring for your green friends!',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//                 fontSize: bodySize,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: spacing),
//             ElevatedButton(
//               onPressed: _addNewPlant,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryGreen,
//                 foregroundColor: AppColors.textOnPrimary,
//                 padding: buttonPadding,
//               ),
//               child: Text(
//                 'Add First Plant',
//                 style: AppTextStyles.button.copyWith(
//                   fontSize: screenWidth > 600 ? 16 : 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addNewPlant() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => const AddNewPlantSheet(),
//     );
//   }
//
//   List<GardenPlant> _filterPlants(List<GardenPlant> allPlants) {
//     switch (_selectedFilter) {
//       case 'Need Water':
//         return allPlants
//             .where((plant) => plant.reminders.any((reminder) =>
//         reminder.isActive &&
//             reminder.nextReminderDateTime != null &&
//             reminder.nextReminderDateTime!
//                 .isBefore(DateTime.now().add(const Duration(days: 1)))))
//             .toList();
//       case 'Indoor':
//         return allPlants
//             .where((plant) => plant.type.toLowerCase().contains('indoor'))
//             .toList();
//       case 'Outdoor':
//         return allPlants
//             .where((plant) => plant.type.toLowerCase().contains('outdoor'))
//             .toList();
//       default:
//         return allPlants;
//     }
//   }
//
//   // void _showPlantDetails(GardenPlant plant) async {
//   //   final linkedScanId = plant.scanId;
//   //   if (linkedScanId != null && linkedScanId.isNotEmpty) {
//   //     final scanned = ScanDB.getScan(linkedScanId);
//   //     if (scanned != null) {
//   //       await AdService.instance.showRewardedAndWait(
//   //         onReward: () {
//   //           print("✅ User earned reward!");
//   //           Navigator.push(
//   //             context,
//   //             MaterialPageRoute(
//   //               builder: (_) => ResultScreen(scannedPlant: scanned),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //       return;
//   //     }
//   //   }
//   //
//   //   await AdService.instance.showRewardedAndWait(
//   //     onReward: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (_) => ResultScreen(
//   //             isFromGarden: true,
//   //             imagePath: plant.imagePath,
//   //             plantDetails: null,
//   //             scannedPlant: null,
//   //             plantName: plant.name,
//   //           ),
//   //         ),
//   //       );
//   //       print("✅ User earned reward!");
//   //     },
//   //   );
//   // }
//
//   void _showPlantDetails(GardenPlant plant) async {
//     final linkedScanId = plant.scanId;
//
//     // // Try to show rewarded ad first
//     // final adShown = await AdService.instance.showRewardedAndWait(
//     //   onReward: () {
//     //     print("✅ User earned reward!");
//     //   },
//     // );
//
//     // Navigate regardless of ad result
//     if (linkedScanId != null && linkedScanId.isNotEmpty) {
//       final scanned = ScanDB.getScan(linkedScanId);
//       if (scanned != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ResultScreen(scannedPlant: scanned),
//           ),
//         );
//         return;
//       }
//     }
//
//     // Navigate to ResultScreen with garden plant data
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ResultScreen(
//           isFromGarden: true,
//           imagePath: plant.imagePath,
//           plantDetails: null,
//           scannedPlant: null,
//           plantName: plant.name,
//         ),
//       ),
//     );
//   }
//
//   void _editPlant(GardenPlant plant) {
//     // Placeholder for edit plant functionality
//   }
//
//   void _manageReminders(GardenPlant plant) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SetReminderScreen(plant: plant),
//       ),
//     );
//   }
//
//   void _deletePlant(String id) {
//     GardenDB.deletePlant(id);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled/modules/my_garden/screen/set_reminder_screen.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart';
import '../../../Auth/google_auth.dart';
import '../../../services/ads/AdsProvider.dart';
import '../../../services/ads/ads_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../ask_ai/repo/chat_repo.dart';
import '../../ask_ai/services/chat_api_service.dart';
import '../../scan/db/database/scan_db.dart';
import '../../scan/screen/result_screen.dart';
import '../db/database/garden_db.dart';
import '../db/model/garden_plant.dart';
import '../provider/plant_detail_provider.dart';
import '../widgets/add_plant_sheet.dart';
import '../widgets/garden_controls_section.dart';
import '../widgets/garden_header.dart';
import '../widgets/plant_grid-card.dart';
import '../widgets/plant_list_card.dart';
import '../widgets/stats_section.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  final List<GardenPlant> _plants = [];

  int _selectedView = 0; // 0: Grid, 1: List
  String _selectedFilter = 'All';

  // Responsive helper methods
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 600) return 20;
    if (screenWidth > 400) return 16;
    return 12;
  }

  int _getGridCrossAxisCount(double screenWidth) {
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  double _getGridSpacing(double screenWidth) {
    if (screenWidth > 600) return 16;
    return 12;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 600) return 0.85;
    return 0.8;
  }

  double _getFabSize(double screenWidth) {
    if (screenWidth > 600) return 64;
    return 56;
  }

  @override
  void initState() {
    super.initState();
    AdService.instance.loadRewarded();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = context.read<AdProvider>();
      adProvider.preloadAd(AdType.myGardenAd, adSize: TemplateType.small);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    // Check if user is signed in
    if (!authState.isUserSignedIn) {
      return _buildSignInRequiredScreen(context);
    }

    // User is signed in, show garden interface
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = _getResponsivePadding(screenWidth);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<GardenPlant>('garden_plants').listenable(),
        builder: (context, Box<GardenPlant> box, _) {
          final allPlants = box.values.toList();
          final filteredPlants = _filterPlants(allPlants);

          return Column(
            children: [
              // Fixed Header Section
              HeaderSection(plants: allPlants),

              // Scrollable Content Below
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Stats Overview
                    SliverToBoxAdapter(
                      child: StatsSection(plants: allPlants),
                    ),

                    // Filter and View Controls
                    SliverToBoxAdapter(
                      child: GardenControlsSection(
                        selectedFilter: _selectedFilter,
                        selectedView: _selectedView,
                        onFilterChanged: (filter) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        onViewChanged: (viewIndex) {
                          setState(() {
                            _selectedView = viewIndex;
                          });
                        },
                      ),
                    ),

                    // My Garden Native Ad
                    SliverToBoxAdapter(
                      child: _buildMyGardenNativeAd(context, screenWidth),
                    ),

                    // Plants Grid/List
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 4,
                        horizontalPadding, 4,
                      ),
                      sliver: filteredPlants.isEmpty
                          ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyGardenState(screenWidth),
                      )
                          : _selectedView == 0
                          ? _buildPlantsGridSliver(filteredPlants, screenWidth)
                          : _buildPlantsListSliver(filteredPlants, screenWidth),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildResponsiveFAB(screenWidth),
    );
  }

  // NEW: Sign-in required screen for My Garden
  Widget _buildSignInRequiredScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Garden Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.2),
                        AppColors.secondaryGreen.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.yard,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'My Garden',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Sign in to manage your personal plant collection',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Features List
                _buildFeatureItem(
                  icon: Icons.collections,
                  title: 'Plant Collection',
                  description: 'Organize and track all your plants in one place',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.camera_alt,
                  title: 'Photo Gallery',
                  description: 'Document your plants\' growth with photos',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.trending_up,
                  title: 'Growth Tracking',
                  description: 'Monitor health and progress over time',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.notifications_active,
                  title: 'Care Reminders',
                  description: 'Set custom reminders for watering and fertilizing',
                ),
                const SizedBox(height: 40),

                // Sign-in Buttons
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    //await signInWithGoogleUI(context);
                    await GoogleAuth.signInWithGoogleUI(context);
                  },
                  //onPressed: () => signInWithGoogle(),
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    await AppleAuth.signInWithAppleUI(context);
                  },
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),

                // Privacy Note
                Text(
                  'Your garden data syncs across all devices',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveFAB(double screenWidth) {
    final fabSize = _getFabSize(screenWidth);
    final iconSize = screenWidth > 600 ? 32.0 : 28.0;

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: _addNewPlant,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        child: Icon(Icons.add, size: iconSize),
      ),
    );
  }

  Widget _buildMyGardenNativeAd(BuildContext context, double screenWidth) {
    final adProvider = context.watch<AdProvider>();
    final isAdLoaded = adProvider.isMyGardenAd;
    final nativeAd = adProvider.myGardenAd;

    if (!isAdLoaded || nativeAd == null) {
      return const SizedBox.shrink();
    }

    final adHeight = screenWidth > 600 ? 140.0 : 130.0;
    final horizontalPadding = screenWidth > 600 ? 8.0 : 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      child: Container(
        height: adHeight,
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
      ),
    );
  }

  Widget _buildPlantsGridSliver(List<GardenPlant> plants, double screenWidth) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(screenWidth),
        crossAxisSpacing: _getGridSpacing(screenWidth),
        mainAxisSpacing: _getGridSpacing(screenWidth),
        childAspectRatio: _getChildAspectRatio(screenWidth),
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final plant = plants[index];
          return PlantGridCard(
            plant: plant,
            onTap: () => _showPlantDetails(plant),
            onEdit: () => _editPlant(plant),
            onManageReminders: () => _manageReminders(plant),
            onDelete: () => _deletePlant(plant.id),
          );
        },
        childCount: plants.length,
      ),
    );
  }

  Widget _buildPlantsListSliver(List<GardenPlant> plants, double screenWidth) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final plant = plants[index];
          return PlantListCard(
            plant: plant,
            onTap: () => _showPlantDetails(plant),
            onEdit: () => _editPlant(plant),
            onManageReminders: () => _manageReminders(plant),
            onDelete: () => _deletePlant(plant.id),
          );
        },
        childCount: plants.length,
      ),
    );
  }

  Widget _buildPlantsGrid(List<GardenPlant> plants, double screenWidth) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(screenWidth),
        crossAxisSpacing: _getGridSpacing(screenWidth),
        mainAxisSpacing: _getGridSpacing(screenWidth),
        childAspectRatio: _getChildAspectRatio(screenWidth),
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantGridCard(
          plant: plant,
          onTap: () => _showPlantDetails(plant),
          onEdit: () => _editPlant(plant),
          onManageReminders: () => _manageReminders(plant),
          onDelete: () => _deletePlant(plant.id),
        );
      },
    );
  }

  Widget _buildPlantsList(List<GardenPlant> plants, double screenWidth) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantListCard(
          plant: plant,
          onTap: () => _showPlantDetails(plant),
          onEdit: () => _editPlant(plant),
          onManageReminders: () => _manageReminders(plant),
          onDelete: () => _deletePlant(plant.id),
        );
      },
    );
  }

  Widget _buildEmptyGardenState(double screenWidth) {
    final iconSize = screenWidth > 600 ? 80.0 : 64.0;
    final spacing = screenWidth > 600 ? 24.0 : 20.0;
    final titleSize = screenWidth > 600 ? 22.0 : 18.0;
    final bodySize = screenWidth > 600 ? 16.0 : 14.0;
    final buttonPadding = screenWidth > 600
        ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(screenWidth)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth > 600 ? 32 : 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_outlined,
                size: iconSize,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              'Your Garden is Empty',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: titleSize,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first plant to start tracking\nand caring for your green friends!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: bodySize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing),
            ElevatedButton(
              onPressed: _addNewPlant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textOnPrimary,
                padding: buttonPadding,
              ),
              child: Text(
                'Add First Plant',
                style: AppTextStyles.button.copyWith(
                  fontSize: screenWidth > 600 ? 16 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewPlant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddNewPlantSheet(),
    );
  }

  List<GardenPlant> _filterPlants(List<GardenPlant> allPlants) {
    switch (_selectedFilter) {
      case 'Need Water':
        return allPlants
            .where((plant) => plant.reminders.any((reminder) =>
        reminder.isActive &&
            reminder.nextReminderDateTime != null &&
            reminder.nextReminderDateTime!
                .isBefore(DateTime.now().add(const Duration(days: 1)))))
            .toList();
      case 'Indoor':
        return allPlants
            .where((plant) => plant.type.toLowerCase().contains('indoor'))
            .toList();
      case 'Outdoor':
        return allPlants
            .where((plant) => plant.type.toLowerCase().contains('outdoor'))
            .toList();
      default:
        return allPlants;
    }
  }

  void _showPlantDetails(GardenPlant plant) async {
    final linkedScanId = plant.scanId;

    // Navigate regardless of ad result
    if (linkedScanId != null && linkedScanId.isNotEmpty) {
      final scanned = ScanDB.getScan(linkedScanId);
      if (scanned != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(scannedPlant: scanned),
          ),
        );
        return;
      }
    }

    // Navigate to ResultScreen with garden plant data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          isFromGarden: true,
          imagePath: plant.imagePath,
          plantDetails: null,
          scannedPlant: null,
          plantName: plant.name,
        ),
      ),
    );
  }

  void _editPlant(GardenPlant plant) {
    // Placeholder for edit plant functionality
  }

  void _manageReminders(GardenPlant plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderScreen(plant: plant),
      ),
    );
  }

  void _deletePlant(String id) {
    GardenDB.deletePlant(id);
  }
}

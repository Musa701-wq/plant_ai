// // lib/modules/search/screens/category_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import '../../../config/app_routes.dart';
// import '../../../my_app/app_state_provider.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../../my_garden/widgets/add_plant_form_sheet.dart';
// import '../provider/search_provider.dart';
//
// class CategoryScreen extends StatefulWidget {
//   final String category;
//
//   const CategoryScreen({super.key, required this.category});
//
//   @override
//   State<CategoryScreen> createState() => _CategoryScreenState();
// }
//
// class _CategoryScreenState extends State<CategoryScreen> {
//   late ScrollController _scrollController;
//   int _currentPage = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController()..addListener(_onScroll);
//
//     /// Load first page of category plants (via Pexels API)
//     Future.microtask(() {
//       final provider = context.read<SearchProvider>();
//       provider.clearResults(); // 🔹 ensures old data gone instantly
//       provider.fetchByCategory(widget.category, page: _currentPage);
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   /// Detect when we reach the bottom -> load next page
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       final provider = context.read<SearchProvider>();
//       if (!provider.isLoading && provider.hasMore) {
//         _currentPage++;
//         provider.fetchByCategory(widget.category, page: _currentPage);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     final isSmallScreen = width < 360;
//     final cardHeight = isSmallScreen ? height * 0.18 : height * 0.15;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: AppBar(
//         title: Text(
//           widget.category,
//           style: AppTextStyles.headlineSmall.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: AppColors.primaryGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Consumer<SearchProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading && provider.results.isEmpty) {
//             return _buildLoadingState();
//           }
//
//           if (provider.errorMessage != null && provider.results.isEmpty) {
//             return _buildErrorState(provider.errorMessage!);
//           }
//
//           if (provider.results.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           final items = provider.processedResults;
//           if (items.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           return RefreshIndicator(
//             onRefresh: () async{
//               final provider = context.read<SearchProvider>();
//               provider.clearCacheFor(widget.category);
//               await provider.fetchByCategory(widget.category, page: 1);
//             },
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//               itemCount: items.length + (provider.isLoading ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index >= items.length) {
//                   return _buildLoadMoreIndicator(provider);
//                 }
//
//                 final processed = items[index];
//                 return _buildPlantCard(
//                   processed,
//                   cardHeight,
//                   isSmallScreen,
//                   context,
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: Colors.red.shade400,
//               size: 48,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Unable to load plants",
//               style: AppTextStyles.bodyLarge.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 context.read<SearchProvider>().fetchByCategory(widget.category);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryGreen,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Try Again"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               color: Colors.grey.shade400,
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "No plants found",
//               style: AppTextStyles.headlineSmall.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "We couldn't find any plants in the ${widget.category} category",
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadMoreIndicator(SearchProvider provider) {
//     if (!provider.hasMore) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Center(
//           child: Text(
//             "No more plants to load",
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textHint,
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlantCard(
//       ProcessedPlant processed,
//       double cardHeight,
//       bool isSmallScreen,
//       BuildContext context,
//       ) {
//     final plant = processed.raw;
//     final plantName = processed.shortName.isNotEmpty
//         ? processed.shortName
//         : 'Unknown Plant';
//
//     return Container(
//       height: cardHeight,
//       margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Image Container - Square with full height
//           Container(
//             width: cardHeight, // Square container (height = width)
//             height: cardHeight,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 bottomLeft: Radius.circular(20),
//               ),
//               color: Colors.grey.shade200,
//             ),
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 bottomLeft: Radius.circular(20),
//               ),
//               child: plant.imageUrl != null
//                   ? Image.network(
//                 plant.imageUrl!,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     color: Colors.grey.shade200,
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded /
//                             loadingProgress.expectedTotalBytes!
//                             : null,
//                         valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
//                       ),
//                     ),
//                   );
//                 },
//                 errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
//               )
//                   : _buildImagePlaceholder(),
//             ),
//           ),
//
//           // Content Area
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Plant Info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           plantName,
//                           style: AppTextStyles.bodyLarge.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.textPrimary,
//                             fontSize: isSmallScreen ? 16 : 18,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 6),
//                         Expanded(
//                           child: Text(
//                             plant.description ?? 'Beautiful plant from the ${widget.category} category',
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: AppColors.textSecondary,
//                               fontSize: isSmallScreen ? 12 : 14,
//                             ),
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Add to Garden Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         _showAddToGardenSheet(context, processed);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryGreen,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(
//                           vertical: isSmallScreen ? 6 : 8,
//                           horizontal: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           final screenWidth = MediaQuery.of(context).size.width;
//
//                           // 📱 Dynamically scale text size based on screen width
//                           double textScale = screenWidth / 400; // 400 is base width for scaling
//                           double fontSize = 12 * textScale;
//                           if (fontSize < 9) fontSize = 9; // prevent too small
//                           if (fontSize > 13) fontSize = 13; // prevent too large
//
//                           return FittedBox(
//                             fit: BoxFit.scaleDown,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.add_circle_outline,
//                                   size: isSmallScreen ? 14 : 16,
//                                 ),
//                                 SizedBox(width: isSmallScreen ? 5 : 7),
//                                 Text(
//                                   "Add to My Garden",
//                                   style: AppTextStyles.bodyMedium.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                     fontSize: fontSize,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),                    ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImagePlaceholder() {
//     return Container(
//       color: Colors.grey.shade200,
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.local_florist,
//               color: Colors.grey,
//               size: 40,
//             ),
//             SizedBox(height: 4),
//             Text(
//               "No Image",
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAddToGardenSheet(BuildContext context, ProcessedPlant processed) async{
//     final plant = processed.raw;
//
//     final result = await showModalBottomSheet<Map<String, dynamic>?>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => AddPlantFormSheet(
//         plantName: processed.shortName.isNotEmpty
//             ? processed.shortName
//             : 'Unknown Plant',
//         imageUrl: plant.imageUrl ?? '',
//         description: plant.description,
//       ),
//     );
//
//     // ✅ When sheet closes, check if user added a plant
//     if (result != null && result['status'] == 'added') {
//       _showSuccessSnackbar(context, result['name']);
//     }
//   }
//
//   void _showSuccessSnackbar(BuildContext context, String plantName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 '$plantName added to your garden! 🌱',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.primaryGreen,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         action: SnackBarAction(
//           label: 'View Garden',
//           textColor: Colors.white,
//           onPressed: () {
//             Provider.of<AppStateProvider>(context, listen: false).changeTab(4);
//
//             // ✅ Navigate cleanly to My Garden
//             Navigator.of(context).popUntil((route) => route.isFirst);
//           },
//         ),
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }
//
//
//   Widget _buildLoadingState() {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     final isSmallScreen = width < 360;
//     final cardHeight = isSmallScreen ? height * 0.21 : height * 0.18;
//
//     // show 6 shimmer tiles
//     return ListView.builder(
//       padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Container(
//           height: cardHeight,
//           margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // left shimmer box (image area)
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   bottomLeft: Radius.circular(20),
//                 ),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey.shade300,
//                   highlightColor: Colors.grey.shade100,
//                   child: Container(
//                     width: cardHeight,
//                     height: cardHeight,
//                     color: Colors.grey.shade300,
//                   ),
//                 ),
//               ),
//
//               // right content area shimmer
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Title and description skeleton
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Shimmer.fromColors(
//                               baseColor: Colors.grey.shade300,
//                               highlightColor: Colors.grey.shade100,
//                               child: Container(
//                                 height: 16,
//                                 width: width * 0.4,
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Shimmer.fromColors(
//                               baseColor: Colors.grey.shade300,
//                               highlightColor: Colors.grey.shade100,
//                               child: Container(
//                                 height: 12,
//                                 width: width * 0.6,
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Shimmer.fromColors(
//                               baseColor: Colors.grey.shade300,
//                               highlightColor: Colors.grey.shade100,
//                               child: Container(
//                                 height: 12,
//                                 width: width * 0.5,
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Button skeleton
//                       Shimmer.fromColors(
//                         baseColor: Colors.grey.shade300,
//                         highlightColor: Colors.grey.shade100,
//                         child: Container(
//                           height: isSmallScreen ? 32 : 38,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// lib/modules/search/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/app_routes.dart';
import '../../../my_app/app_state_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../my_garden/widgets/add_plant_form_sheet.dart';
import '../provider/search_provider.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late ScrollController _scrollController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    /// Load first page of category plants (via Pexels API)
    Future.microtask(() {
      final provider = context.read<SearchProvider>();
      provider.clearResults(); // 🔹 ensures old data gone instantly
      provider.fetchByCategory(widget.category, page: _currentPage);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Detect when we reach the bottom -> load next page
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<SearchProvider>();
      if (!provider.isLoading && provider.hasMore) {
        _currentPage++;
        provider.fetchByCategory(widget.category, page: _currentPage);
      }
    }
  }

  // 📱 Responsive breakpoints and sizing helper
  ResponsiveConfig _getResponsiveConfig(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Define breakpoints
    final isExtraSmall = width < 340;  // Very small phones
    final isSmall = width < 375;       // Small phones
    final isMedium = width < 414;      // Medium phones
    final isLarge = width < 768;       // Large phones
    final isTablet = width >= 768;     // Tablets and above

    return ResponsiveConfig(
      width: width,
      height: height,
      isExtraSmall: isExtraSmall,
      isSmall: isSmall,
      isMedium: isMedium,
      isLarge: isLarge,
      isTablet: isTablet,
      // Card dimensions
      cardHeight: isExtraSmall ? height * 0.20 :
      isSmall ? height * 0.20 :
      isMedium ? height * 0.22 :
      isLarge ? height * 0.16 :
      height * 0.22,  // Tablets need more height
      // Padding
      screenPadding: isExtraSmall ? 8.0 :
      isSmall ? 12.0 :
      isMedium ? 14.0 :
      isTablet ? 24.0 : 16.0,
      cardMargin: isExtraSmall ? 8.0 :
      isSmall ? 10.0 :
      isTablet ? 20.0 : 14.0,
      cardPadding: isExtraSmall ? 10.0 :
      isSmall ? 12.0 :
      isTablet ? 20.0 : 16.0,
      // Typography sizes
      titleSize: isExtraSmall ? 15.0 :
      isSmall ? 16.0 :
      isMedium ? 17.0 :
      isTablet ? 22.0 : 18.0,
      descriptionSize: isExtraSmall ? 11.0 :
      isSmall ? 12.0 :
      isMedium ? 13.0 :
      isTablet ? 16.0 : 14.0,
      buttonTextSize: isExtraSmall ? 10.0 :
      isSmall ? 11.0 :
      isMedium ? 12.0 :
      isTablet ? 15.0 : 13.0,
      iconSize: isExtraSmall ? 14.0 :
      isSmall ? 15.0 :
      isTablet ? 20.0 : 16.0,
      // Button dimensions
      buttonVerticalPadding: isExtraSmall ? 6.0 :
      isSmall ? 7.0 :
      isTablet ? 12.0 : 8.0,
      buttonHorizontalPadding: isExtraSmall ? 10.0 :
      isSmall ? 12.0 :
      isTablet ? 20.0 : 16.0,
      buttonIconSpacing: isExtraSmall ? 4.0 :
      isSmall ? 5.0 :
      isTablet ? 8.0 : 6.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getResponsiveConfig(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: AppTextStyles.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: config.isTablet ? 24 :
            config.isSmall ? 18 : 20,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.results.isEmpty) {
            return _buildLoadingState(config);
          }

          if (provider.errorMessage != null && provider.results.isEmpty) {
            return _buildErrorState(provider.errorMessage!, config);
          }

          if (provider.results.isEmpty) {
            return _buildEmptyState(config);
          }

          final items = provider.processedResults;
          if (items.isEmpty) {
            return _buildEmptyState(config);
          }

          return RefreshIndicator(
            onRefresh: () async {
              final provider = context.read<SearchProvider>();
              provider.clearCacheFor(widget.category);
              await provider.fetchByCategory(widget.category, page: 1);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(config.screenPadding),
              itemCount: items.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return _buildLoadMoreIndicator(provider, config);
                }

                final processed = items[index];
                return _buildPlantCard(processed, config, context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error, ResponsiveConfig config) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(config.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: config.isTablet ? 64 :
              config.isSmall ? 40 : 48,
            ),
            SizedBox(height: config.isTablet ? 20 : 16),
            Text(
              "Unable to load plants",
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: config.isTablet ? 20 :
                config.isSmall ? 16 : 18,
              ),
            ),
            SizedBox(height: config.isTablet ? 12 : 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: config.descriptionSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: config.isTablet ? 24 : 20),
            ElevatedButton(
              onPressed: () {
                context.read<SearchProvider>().fetchByCategory(widget.category);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: config.buttonVerticalPadding + 2,
                  horizontal: config.buttonHorizontalPadding + 8,
                ),
              ),
              child: Text(
                "Try Again",
                style: TextStyle(fontSize: config.buttonTextSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveConfig config) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(config.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey.shade400,
              size: config.isTablet ? 80 :
              config.isSmall ? 56 : 64,
            ),
            SizedBox(height: config.isTablet ? 20 : 16),
            Text(
              "No plants found",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: config.isTablet ? 22 :
                config.isSmall ? 18 : 20,
              ),
            ),
            SizedBox(height: config.isTablet ? 12 : 8),
            Text(
              "We couldn't find any plants in the ${widget.category} category",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: config.descriptionSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(SearchProvider provider, ResponsiveConfig config) {
    if (!provider.hasMore) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: config.isTablet ? 24 : 20,
        ),
        child: Center(
          child: Text(
            "No more plants to load",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: config.isSmall ? 11 :
              config.isTablet ? 14 : 12,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: config.isTablet ? 24 : 20,
      ),
      child: Center(
        child: SizedBox(
          width: config.isTablet ? 32 : 24,
          height: config.isTablet ? 32 : 24,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard(
      ProcessedPlant processed,
      ResponsiveConfig config,
      BuildContext context,
      ) {
    final plant = processed.raw;
    final plantName = processed.shortName.isNotEmpty
        ? processed.shortName
        : 'Unknown Plant';

    return Container(
      height: config.cardHeight,
      margin: EdgeInsets.only(bottom: config.cardMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(config.isTablet ? 24 : 20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: config.isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Container - Square with full height
          Container(
            width: config.cardHeight,
            height: config.cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(config.isTablet ? 24 : 20),
                bottomLeft: Radius.circular(config.isTablet ? 24 : 20),
              ),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(config.isTablet ? 24 : 20),
                bottomLeft: Radius.circular(config.isTablet ? 24 : 20),
              ),
              child: plant.imageUrl != null
                  ? Image.network(
                plant.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: SizedBox(
                        width: config.isTablet ? 32 : 24,
                        height: config.isTablet ? 32 : 24,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(config),
              )
                  : _buildImagePlaceholder(config),
            ),
          ),

          // Content Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(config.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plant Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plantName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: config.titleSize,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: config.isExtraSmall ? 4 : 6),
                        Expanded(
                          child: Text(
                            plant.description ??
                                'Beautiful plant from the ${widget.category} category',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: config.descriptionSize,
                              height: 1.3,
                            ),
                            maxLines: config.isExtraSmall ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: config.isExtraSmall ? 6 : 8),

                  // Add to Garden Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddToGardenSheet(context, processed);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: config.buttonVerticalPadding,
                          horizontal: config.buttonHorizontalPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            config.isTablet ? 14 : 12,
                          ),
                        ),
                        elevation: 2,
                        minimumSize: Size(
                          0,
                          config.isExtraSmall ? 32 :
                          config.isTablet ? 44 : 36,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: config.iconSize,
                            ),
                            SizedBox(width: config.buttonIconSpacing),
                            Text(
                              "Add to My Garden",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: config.buttonTextSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ResponsiveConfig config) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              color: Colors.grey,
              size: config.isTablet ? 48 :
              config.isSmall ? 32 : 40,
            ),
            SizedBox(height: config.isExtraSmall ? 2 : 4),
            Text(
              "No Image",
              style: TextStyle(
                color: Colors.grey,
                fontSize: config.isTablet ? 14 :
                config.isSmall ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToGardenSheet(BuildContext context, ProcessedPlant processed) async {
    final plant = processed.raw;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPlantFormSheet(
        plantName: processed.shortName.isNotEmpty
            ? processed.shortName
            : 'Unknown Plant',
        imageUrl: plant.imageUrl ?? '',
        description: plant.description,
      ),
    );

    // ✅ When sheet closes, check if user added a plant
    if (result != null && result['status'] == 'added') {
      _showSuccessSnackbar(context, result['name']);
    }
  }

  void _showSuccessSnackbar(BuildContext context, String plantName) {
    final config = _getResponsiveConfig(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: config.iconSize,
            ),
            SizedBox(width: config.isTablet ? 16 : 12),
            Expanded(
              child: Text(
                '$plantName added to your garden! 🌱',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: config.descriptionSize),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(config.screenPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.isTablet ? 12 : 8),
        ),
        action: SnackBarAction(
          label: 'View Garden',
          textColor: Colors.white,
          onPressed: () {
            Provider.of<AppStateProvider>(context, listen: false).changeTab(4);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildLoadingState(ResponsiveConfig config) {
    return ListView.builder(
      padding: EdgeInsets.all(config.screenPadding),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: config.cardHeight,
          margin: EdgeInsets.only(bottom: config.cardMargin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(config.isTablet ? 24 : 20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left shimmer box (image area)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(config.isTablet ? 24 : 20),
                  bottomLeft: Radius.circular(config.isTablet ? 24 : 20),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: config.cardHeight,
                    height: config.cardHeight,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),

              // Right content area shimmer
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(config.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and description skeleton
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: config.titleSize,
                                width: config.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(height: config.isExtraSmall ? 8 : 10),
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: config.descriptionSize,
                                width: config.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(height: config.isExtraSmall ? 6 : 8),
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: config.descriptionSize,
                                width: config.width * 0.5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: config.isExtraSmall ? 6 : 8),

                      // Button skeleton
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: config.isExtraSmall ? 32 :
                          config.isTablet ? 44 : 36,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(
                              config.isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 📱 Responsive configuration class
class ResponsiveConfig {
  final double width;
  final double height;
  final bool isExtraSmall;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;
  final bool isTablet;
  final double cardHeight;
  final double screenPadding;
  final double cardMargin;
  final double cardPadding;
  final double titleSize;
  final double descriptionSize;
  final double buttonTextSize;
  final double iconSize;
  final double buttonVerticalPadding;
  final double buttonHorizontalPadding;
  final double buttonIconSpacing;

  ResponsiveConfig({
    required this.width,
    required this.height,
    required this.isExtraSmall,
    required this.isSmall,
    required this.isMedium,
    required this.isLarge,
    required this.isTablet,
    required this.cardHeight,
    required this.screenPadding,
    required this.cardMargin,
    required this.cardPadding,
    required this.titleSize,
    required this.descriptionSize,
    required this.buttonTextSize,
    required this.iconSize,
    required this.buttonVerticalPadding,
    required this.buttonHorizontalPadding,
    required this.buttonIconSpacing,
  });
}
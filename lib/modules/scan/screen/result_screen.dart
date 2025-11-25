// // lib/modules/scan/screen/result_screen.dart
// import 'dart:io';
// import 'package:ai_tree_plant/modules/scan/widgets/add_to_garden_button.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/care_detail_grid.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/error_state.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/fun_fact_list.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/gradient_card.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/loading_state.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/modern_faq_list.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/modern_section.dart';
// import 'package:ai_tree_plant/modules/scan/widgets/plant_header_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:provider/provider.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../../ask_ai/repo/chat_repo.dart';
// import '../../ask_ai/services/chat_api_service.dart';
// import '../../my_garden/db/database/garden_db.dart';
// import '../db/database/scan_db.dart';
// import '../db/model/scanned_plant.dart';
// import '../provider/scan_provider.dart';
// import '../../scan/gemini/model/plant_model.dart'; // PlantModel for API result
//
// class ResultScreen extends StatefulWidget {
//   /// One of:
//   /// - scannedPlant (history mode)
//   final String? imagePath;
//   final ScannedPlant? scannedPlant;
//   final PlantModel? plantDetails;
//   final bool isFromGarden;
//   final String? plantName;
//
//
//   const ResultScreen({
//     super.key,
//     this.imagePath,
//     this.scannedPlant,
//     this.plantDetails,
//     this.isFromGarden = false,
//     this.plantName,
//   });
//
//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   // Modes
//   bool get hasScanned => widget.scannedPlant != null;
//   bool get hasPlantDetails => widget.plantDetails != null;
//   bool get isHistoryMode => hasScanned;
//   bool get isFromGarden => widget.isFromGarden;
//   late final ScanProvider _scanProvider; // store reference safely
//
//
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Defer logic until after build so Provider is available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scanProvider = Provider.of<ScanProvider>(context, listen: false); // ✅ safe here
//
//       if (hasScanned) {
//         // 1) History mode: populate provider from scanned item
//         _scanProvider.setPlantFromScanned(widget.scannedPlant!);
//         if (widget.scannedPlant!.imagePath != null && widget.scannedPlant!.imagePath!.isNotEmpty) {
//           _scanProvider.plantResult?.imagePath = widget.scannedPlant!.imagePath;
//         }
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//
//       if (hasPlantDetails) {
//         // 2) Name-based API result (MyGarden flow)
//         _scanProvider.setPlantFromPlantModel(widget.plantDetails!);
//         if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
//           _scanProvider.plantResult?.imagePath = widget.imagePath;
//         }
//
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // 3️⃣ 🌿 From My Garden — no details yet → fetch via API
//       if (widget.isFromGarden && widget.plantName != null) {
//         _fetchDetailsFromGarden(widget.plantName!);
//         return;
//       }
//
//
//       // 3) Fallback: image-based identification (existing flow)
//       _identifyPlant();
//     });
//   }
//
//   Future<void> _fetchDetailsFromGarden(String plantName) async {
//     try {
//       final provider = Provider.of<ScanProvider>(context, listen: false);
//       final allPlants = GardenDB.getAllPlants();
//
//       // ✅ Check if plant already cached locally
//       final cachedPlant = allPlants
//           .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
//           .firstOrNull;
//
//       if (cachedPlant != null && cachedPlant.cachedPlantDetails != null) {
//         debugPrint("🌿 Using cached details for $plantName");
//         provider.setPlantFromPlantModel(cachedPlant.cachedPlantDetails!.toPlantModel());
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // 🧠 Otherwise, fetch from API
//       debugPrint("🌱 Fetching new details for $plantName");
//       final apiService = GeminiChatApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND");
//       final repository = ChatRepository(apiService);
//
//       final details = await repository.getPlantDetailsByName(plantName);
//       provider.setPlantFromPlantModel(details);
//
//       // 🧩 Cache locally in GardenDB for next time
//       final scannedPlant = ScannedPlant.fromPlantModel(details, imagePath: widget.imagePath);
//       final plantEntry = allPlants
//           .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
//           .firstOrNull;
//
//       if (plantEntry != null) {
//         await GardenDB.savePlantDetails(plantEntry.id, scannedPlant);
//       }
//
//       setState(() => _isLoading = false);
//     } catch (e) {
//       debugPrint("❌ Error fetching garden details: $e");
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//
//   @override
//   void dispose() {
//     // 🟢 Safely clean up resources without triggering provider rebuilds
//     try {
//       _scanProvider.disposeCamera();
//       _scanProvider.clearTemporaryStateSilently();
//       // Prevent notifying listeners during disposal
//       // ✅ if this result came from camera/image (not from history or garden)
//
//
//     } catch (e) {
//       debugPrint("Dispose error: $e");
//     }
//
//     super.dispose();
//   }
//
//   void _showSaveConfirmation() {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 12),
//             const Text('Plant saved to your collection!'),
//           ],
//         ),
//         backgroundColor: AppColors.primaryGreen,
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
//
//   Future<void> _identifyPlant() async {
//     final provider = Provider.of<ScanProvider>(context, listen: false);
//     final path = widget.imagePath;
//
//     if (path == null || path.isEmpty) {
//       setState(() {
//         _error = "No image provided for identification.";
//         _isLoading = false;
//       });
//       return;
//     }
//
//     provider.setSelectedImage(File(path));
//     await provider.identifyPlant();
//     setState(() {
//       _isLoading = false;
//       _error = provider.error;
//     });
//
//     // attach image path to plantResult so it will be rendered in header
//     if (provider.plantResult != null) {
//       provider.plantResult!.imagePath = path;
//     }
//
//     if (provider.error == null && provider.plantResult != null) {
//       final identifiedPlant = provider.plantResult!;
//       debugPrint("🌱 Identified plant: ${identifiedPlant.name}");
//
//       // ✅ Run background save (no UI snackbar)
//       Future.microtask(() async {
//         try {
//           final exists = ScanDB.scanExistsByName(identifiedPlant.name);
//           if (exists) {
//             debugPrint("⚠️ Duplicate detected: '${identifiedPlant.name}' already exists. Skipping save.");
//             return;
//           }
//
//           final scannedPlant = ScannedPlant.fromPlantModel(
//             identifiedPlant,
//             imagePath: path,
//           );
//
//           await ScanDB.addScan(scannedPlant);
//           debugPrint("💾 [Background Save] Added new scan for: ${identifiedPlant.name}");
//         } catch (dbError, st) {
//           debugPrint("❌ [Background Save Error]: $dbError\n$st");
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ScanProvider>(context);
//     final plant = provider.plantResult;
//
//     // determine heroImage path preference:
//     // 1) plant.imagePath (if provider has it), 2) widget.imagePath (passed explicitly),
//     // 3) provider.selectedImage.path, 4) scannedPlant.imagePath
//     String? heroImagePath = plant?.imagePath ??
//         widget.imagePath ??
//         provider.selectedImage?.path ??
//         widget.scannedPlant?.imagePath;
//
//     return WillPopScope(
//       onWillPop: () async {
//         final cameFromCamera = widget.imagePath != null &&
//             !hasScanned &&
//             !isFromGarden &&
//             !hasPlantDetails;
//
//         if (cameFromCamera) {
//           Navigator.of(context).popUntil((route) => route.isFirst);
//           return false; // prevent normal pop
//         }
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundLight,
//         body: _isLoading
//             ? LoadingStateWidget()
//             : _error != null
//             ? ErrorStateWidget(message: _error)
//             : plant == null
//             ? ErrorStateWidget(message: "No plant details available.")
//             : CustomScrollView(
//           slivers: [
//             // Modern Hero AppBar
//             SliverAppBar(
//               expandedHeight: 300,
//               pinned: true,
//               backgroundColor: AppColors.primaryGreen,
//               iconTheme: const IconThemeData(color: Colors.white), // 👈 makes back arrow white
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Text(
//                   "Plant Details",
//                   style: AppTextStyles.headlineSmall.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 4,
//                         offset: const Offset(1, 1),
//                       ),
//                     ],
//                   ),
//                 ),
//                 background: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Plant Image (safe loading)
//                     _buildPlantImage(heroImagePath),
//                     // Gradient Overlay
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                           stops: const [0.4, 1.0],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Content Sections
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ModernSection(
//                       title: "Name",
//                       icon: Icons.energy_savings_leaf_outlined,
//                       child: PlantHeaderCard(plant: plant),
//                     ),
//                     const SizedBox(height: 24),
//                     // 🌿 About Section
//                     ModernSection(
//                       title: "About",
//                       icon: Icons.info_outline,
//                       child: GradientCard(
//                         child: Text(
//                           plant.about.isNotEmpty ? plant.about : "No information available.",
//                           style: AppTextStyles.bodyMedium.copyWith(
//                             color: AppColors.textPrimary,
//                             height: 1.6,
//                           ),
//                           textAlign: TextAlign.justify,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // 🌤 Care Details Section
//                     ModernSection(
//                       title: "Care Details",
//                       icon: Icons.psychology_outlined,
//                       child: CareDetailsGrid(details: plant.details),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // ⚠ Common Problems Section
//                     ModernSection(
//                       title: "Common Problems",
//                       icon: Icons.warning_amber_outlined,
//                       child: GradientCard(
//                         child: Text(
//                           plant.commonProblems.isNotEmpty ? plant.commonProblems : "No common problems found.",
//                           style: AppTextStyles.bodyMedium.copyWith(
//                             color: AppColors.textPrimary,
//                             height: 1.6,
//                           ),
//                           textAlign: TextAlign.justify,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // ❓ FAQs Section
//                     if (plant.faqs.isNotEmpty) ...[
//                       ModernSection(
//                         title: "Frequently Asked Questions",
//                         icon: Icons.help_outline,
//                         child: ModernFAQList(faqs: plant.faqs),
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//
//                     // 🌸 Fun Facts Section
//                     ModernSection(
//                       title: "Fun Facts",
//                       icon: Icons.emoji_nature_outlined,
//                       child: FunFactsList(funFacts: plant.funFacts),
//                     ),
//
//                     const SizedBox(height: 32),
//
//                     // Add to Garden OR Disabled message when already in garden:
//                     if (isFromGarden)
//                     // Disabled style (already saved to garden)
//                       Container(
//                         width: double.infinity,
//                         height: 60,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Text(
//                           "Already in My Garden",
//                           style: AppTextStyles.bodyLarge.copyWith(
//                             color: Colors.grey.shade800,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       )
//                     else
//                     // Show existing AddToGardenButton widget (active)
//                       AddToGardenButton(
//                         isFromHistory: isHistoryMode,
//                         scannedPlant: widget.scannedPlant,
//                         imagePath: widget.imagePath ?? heroImagePath,
//                       ),
//
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🌿 Universal Plant Image Loader
//   Widget _buildPlantImage(String? path) {
//     if (path == null || path.isEmpty) {
//       return Container(
//         color: Colors.grey.shade300,
//         child: const Center(
//           child: Icon(Icons.image_not_supported, size: 60, color: Colors.white),
//         ),
//       );
//     }
//
//     final isNetwork = path.startsWith('http://') || path.startsWith('https://');
//
//     return isNetwork
//         ? Image.network(
//       path,
//       fit: BoxFit.cover,
//       loadingBuilder: (context, child, progress) {
//         if (progress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             value: progress.expectedTotalBytes != null
//                 ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => Container(
//         color: Colors.grey.shade300,
//         child: const Center(
//           child: Icon(Icons.broken_image, size: 60, color: Colors.white),
//         ),
//       ),
//     )
//         : Image.file(
//       File(path),
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Container(
//         color: Colors.grey.shade300,
//         child: const Center(
//           child: Icon(Icons.broken_image, size: 60, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
// }


// lib/modules/scan/screen/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../services/ads/AdsProvider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../ask_ai/repo/chat_repo.dart';
import '../../ask_ai/services/chat_api_service.dart';
import '../../my_garden/db/database/garden_db.dart';
import '../db/database/scan_db.dart';
import '../db/model/scanned_plant.dart';
import '../provider/scan_provider.dart';
import '../../scan/gemini/model/plant_model.dart';
import '../widgets/add_to_garden_button.dart';
import '../widgets/care_detail_grid.dart';
import '../widgets/error_state.dart';
import '../widgets/fun_fact_list.dart';
import '../widgets/gradient_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/modern_faq_list.dart';
import '../widgets/modern_section.dart';
import '../widgets/plant_header_card.dart'; // PlantModel for API result

class ResultScreen extends StatefulWidget {
  /// One of:
  /// - scannedPlant (history mode)
  final String? imagePath;
  final ScannedPlant? scannedPlant;
  final PlantModel? plantDetails;
  final bool isFromGarden;
  final String? plantName;

  const ResultScreen({
    super.key,
    this.imagePath,
    this.scannedPlant,
    this.plantDetails,
    this.isFromGarden = false,
    this.plantName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Modes
  bool get hasScanned => widget.scannedPlant != null;
  bool get hasPlantDetails => widget.plantDetails != null;
  bool get isHistoryMode => hasScanned;
  bool get isFromGarden => widget.isFromGarden;
  late final ScanProvider _scanProvider; // store reference safely

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    //Defer logic until after build so Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanProvider = Provider.of<ScanProvider>(context, listen: false); // ✅ safe here

      // Preload native ad
      final adProvider = context.read<AdProvider>();
      adProvider.preloadAd(AdType.discoverPlantDetailAd, adSize: TemplateType.small);

      if (hasScanned) {
        // 1) History mode: populate provider from scanned item
        _scanProvider.setPlantFromScanned(widget.scannedPlant!);
        if (widget.scannedPlant!.imagePath != null && widget.scannedPlant!.imagePath!.isNotEmpty) {
          _scanProvider.plantResult?.imagePath = widget.scannedPlant!.imagePath;
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (hasPlantDetails) {
        // 2) Name-based API result (MyGarden flow)
        _scanProvider.setPlantFromPlantModel(widget.plantDetails!);
        if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
          _scanProvider.plantResult?.imagePath = widget.imagePath;
        }

        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 3️⃣ 🌿 From My Garden — no details yet → fetch via API
      if (widget.isFromGarden && widget.plantName != null) {
        _fetchDetailsFromGarden(widget.plantName!);
        return;
      }

      // 3) Fallback: image-based identification (existing flow)
      _identifyPlant();
    });
  }

  Future<void> _fetchDetailsFromGarden(String plantName) async {
    try {
      final provider = Provider.of<ScanProvider>(context, listen: false);
      final allPlants = GardenDB.getAllPlants();

      // ✅ Check if plant already cached locally
      final cachedPlant = allPlants
          .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
          .firstOrNull;

      if (cachedPlant != null && cachedPlant.cachedPlantDetails != null) {
        debugPrint("🌿 Using cached details for $plantName");
        provider.setPlantFromPlantModel(cachedPlant.cachedPlantDetails!.toPlantModel());
        setState(() => _isLoading = false);
        return;
      }

      // 🧠 Otherwise, fetch from API
      debugPrint("🌱 Fetching new details for $plantName");
      final apiService = GeminiChatApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND");
      final repository = ChatRepository(apiService);

      final details = await repository.getPlantDetailsByName(plantName);
      provider.setPlantFromPlantModel(details);

      // 🧩 Cache locally in GardenDB for next time
      final scannedPlant = ScannedPlant.fromPlantModel(details, imagePath: widget.imagePath);
      final plantEntry = allPlants
          .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
          .firstOrNull;

      if (plantEntry != null) {
        await GardenDB.savePlantDetails(plantEntry.id, scannedPlant);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("❌ Error fetching garden details: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 🟢 Safely clean up resources without triggering provider rebuilds
    try {
      _scanProvider.disposeCamera();
      _scanProvider.clearTemporaryStateSilently();
      // Prevent notifying listeners during disposal
      // ✅ if this result came from camera/image (not from history or garden)
    } catch (e) {
      debugPrint("Dispose error: $e");
    }

    super.dispose();
  }

  void _showSaveConfirmation() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Plant saved to your collection!'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _identifyPlant() async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    final path = widget.imagePath;

    if (path == null || path.isEmpty) {
      setState(() {
        _error = "No image provided for identification.";
        _isLoading = false;
      });
      return;
    }

    provider.setSelectedImage(File(path));
    await provider.identifyPlant();
    setState(() {
      _isLoading = false;
      _error = provider.error;
    });

    // attach image path to plantResult so it will be rendered in header
    if (provider.plantResult != null) {
      provider.plantResult!.imagePath = path;
    }

    if (provider.error == null && provider.plantResult != null) {
      final identifiedPlant = provider.plantResult!;
      debugPrint("🌱 Identified plant: ${identifiedPlant.name}");

      // ✅ Run background save (no UI snackbar)
      Future.microtask(() async {
        try {
          final exists = ScanDB.scanExistsByName(identifiedPlant.name);
          if (exists) {
            debugPrint("⚠️ Duplicate detected: '${identifiedPlant.name}' already exists. Skipping save.");
            return;
          }

          final scannedPlant = ScannedPlant.fromPlantModel(
            identifiedPlant,
            imagePath: path,
          );

          await ScanDB.addScan(scannedPlant);
          debugPrint("💾 [Background Save] Added new scan for: ${identifiedPlant.name}");
        } catch (dbError, st) {
          debugPrint("❌ [Background Save Error]: $dbError\n$st");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    final plant = provider.plantResult;

    // determine heroImage path preference:
    // 1) plant.imagePath (if provider has it), 2) widget.imagePath (passed explicitly),
    // 3) provider.selectedImage.path, 4) scannedPlant.imagePath
    String? heroImagePath = plant?.imagePath ??
        widget.imagePath ??
        provider.selectedImage?.path ??
        widget.scannedPlant?.imagePath;

    return WillPopScope(
      onWillPop: () async {
        final cameFromCamera = widget.imagePath != null &&
            !hasScanned &&
            !isFromGarden &&
            !hasPlantDetails;

        if (cameFromCamera) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false; // prevent normal pop
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: _isLoading
            ? LoadingStateWidget()
            : _error != null
            ? ErrorStateWidget(message: _error)
            : plant == null
            ? ErrorStateWidget(message: "No plant details available.")
            : CustomScrollView(
          slivers: [
            // Modern Hero AppBar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              iconTheme: const IconThemeData(color: Colors.white), // 👈 makes back arrow white
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Plant Details",
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Plant Image (safe loading)
                    _buildPlantImage(heroImagePath),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Sections
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModernSection(
                      title: "Name",
                      icon: Icons.energy_savings_leaf_outlined,
                      child: PlantHeaderCard(plant: plant),
                    ),
                    const SizedBox(height: 10),

                    // Native Ad - Before About Section
                    _buildPlantDetailNativeAd(context),

                    // 🌿 About Section
                    ModernSection(
                      title: "About",
                      icon: Icons.info_outline,
                      child: GradientCard(
                        child: Text(
                          plant.about.isNotEmpty ? plant.about : "No information available.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🌤 Care Details Section
                    ModernSection(
                      title: "Care Details",
                      icon: Icons.psychology_outlined,
                      child: CareDetailsGrid(details: plant.details),
                    ),

                    const SizedBox(height: 24),

                    // ⚠ Common Problems Section
                    ModernSection(
                      title: "Common Problems",
                      icon: Icons.warning_amber_outlined,
                      child: GradientCard(
                        child: Text(
                          plant.commonProblems.isNotEmpty ? plant.commonProblems : "No common problems found.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ❓ FAQs Section
                    if (plant.faqs.isNotEmpty) ...[
                      ModernSection(
                        title: "Frequently Asked Questions",
                        icon: Icons.help_outline,
                        child: ModernFAQList(faqs: plant.faqs),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 🌸 Fun Facts Section
                    ModernSection(
                      title: "Fun Facts",
                      icon: Icons.emoji_nature_outlined,
                      child: FunFactsList(funFacts: plant.funFacts),
                    ),

                    const SizedBox(height: 32),

                    // Add to Garden OR Disabled message when already in garden:
                    if (isFromGarden)
                    // Disabled style (already saved to garden)
                      Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Already in My Garden",
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                    // Show existing AddToGardenButton widget (active)
                      AddToGardenButton(
                        isFromHistory: isHistoryMode,
                        scannedPlant: widget.scannedPlant,
                        imagePath: widget.imagePath ?? heroImagePath,
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- PLANT DETAIL NATIVE AD WIDGET ----------
  Widget _buildPlantDetailNativeAd(BuildContext context) {
    final adProvider = context.watch<AdProvider>();
    final isAdLoaded = adProvider.isDiscoverPlantDetailAd;
    final nativeAd = adProvider.discoverPlantDetailAd;

    if (!isAdLoaded || nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
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
      ),
    );
  }

  //🌿 Universal Plant Image Loader
  Widget _buildPlantImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.white),
        ),
      );
    }

    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    return isNetwork
        ? Image.network(
      path,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                : null,
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.white),
        ),
      ),
    )
        : Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.white),
        ),
      ),
    );
  }
}
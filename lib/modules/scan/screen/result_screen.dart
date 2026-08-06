import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../services/ads/AdsProvider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../ask_ai/repo/chat_repo.dart';
import '../../ask_ai/services/chat_api_service.dart';
import '../../my_garden/db/database/garden_db.dart';
import '../../my_garden/services/CreditManager.dart';
import '../../my_garden/services/CreditsPurchaseScreen.dart';
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
import '../widgets/plant_header_card.dart';

class ResultScreen extends StatefulWidget {
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
  bool get hasScanned => widget.scannedPlant != null;
  bool get hasPlantDetails => widget.plantDetails != null;
  bool get isHistoryMode => hasScanned;
  bool get isFromGarden => widget.isFromGarden;
  late final ScanProvider _scanProvider;

  bool _isLoading = true;
  String? _error;
  bool _creditsDeducted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanProvider = Provider.of<ScanProvider>(context, listen: false);

      final adProvider = context.read<AdProvider>();
      adProvider.preloadAd(AdType.discoverPlantDetailAd, adSize: TemplateType.small);

      if (hasScanned) {
        _scanProvider.setPlantFromScanned(widget.scannedPlant!);
        if (widget.scannedPlant!.imagePath != null && widget.scannedPlant!.imagePath!.isNotEmpty) {
          _scanProvider.plantResult?.imagePath = widget.scannedPlant!.imagePath;
        }
        setState(() {
          _isLoading = false;
        });
        debugPrint("📜 [ResultScreen] Loading from history - NO credit deduction");
        return;
      }

      if (hasPlantDetails) {
        _scanProvider.setPlantFromPlantModel(widget.plantDetails!);
        if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
          _scanProvider.plantResult?.imagePath = widget.imagePath;
        }

        setState(() {
          _isLoading = false;
        });
        debugPrint("🌿 [ResultScreen] Loading from garden - NO credit deduction");
        return;
      }

      if (widget.isFromGarden && widget.plantName != null) {
        _fetchDetailsFromGarden(widget.plantName!);
        return;
      }

      _identifyPlant();
    });
  }

  Future<void> _deductCreditsIfNeeded() async {
    if (_creditsDeducted) return;
    
    final creditManager = context.read<CreditManager>();
    final deducted = await creditManager.deductCredits(5, reason: 'identify_plant_result');
    if (deducted) {
      _creditsDeducted = true;
      debugPrint("✅ [ResultScreen] Successfully deducted 5 credits");
    } else {
      debugPrint("❌ [ResultScreen] Failed to deduct credits");
    }
  }

  void _showInsufficientCreditsDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Credits'),
        content: const Text(
          'You need 5 credits to view plant details. Purchase more credits or watch an ad to earn credits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreditsPurchaseScreen()),
              );
            },
            child: const Text('Get Credits'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchDetailsFromGarden(String plantName) async {
    try {
      final provider = Provider.of<ScanProvider>(context, listen: false);
      final allPlants = GardenDB.getAllPlants();

      final cachedPlant = allPlants
          .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
          .firstOrNull;

      if (cachedPlant != null && cachedPlant.cachedPlantDetails != null) {
        debugPrint("🌿 Using cached details for $plantName");
        provider.setPlantFromPlantModel(cachedPlant.cachedPlantDetails!.toPlantModel());
        setState(() => _isLoading = false);
        debugPrint("💾 [ResultScreen] Using cached data - NO credit deduction");
        return;
      }

      final creditManager = context.read<CreditManager>();
      if (!creditManager.hasEnoughCredits(5)) { 
        debugPrint("⚠️ [ResultScreen] Insufficient credits - Aborting fetch");
        setState(() {
          _isLoading = false;
          _error = "You need 5 credits to view plant details.";
        });
        _showInsufficientCreditsDialog();
        return;
      }

      debugPrint("🌱 Fetching new details for $plantName");
      final apiService = GeminiChatApiService(dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND");
      final repository = ChatRepository(apiService);

      final details = await repository.getPlantDetailsByName(plantName);
      provider.setPlantFromPlantModel(details);

      String? finalPath = widget.imagePath;
      if (finalPath != null && !finalPath.startsWith('http')) {
        final permanentFile = await provider.saveImagePermanently(File(finalPath));
        finalPath = permanentFile.path;
      }

      final scannedPlant = ScannedPlant.fromPlantModel(details, imagePath: finalPath);
      final plantEntry = allPlants
          .where((p) => p.name.toLowerCase() == plantName.toLowerCase())
          .firstOrNull;

      if (plantEntry != null) {
        await GardenDB.savePlantDetails(plantEntry.id, scannedPlant);
      }

      // 📤 [Community Upload] Push to community if enabled
      try {
        final isNetwork = (widget.imagePath ?? "").startsWith('http');
        await provider.pushToCommunity(
          context,
          details.name,
          "plant",
          isNetwork ? null : (widget.imagePath != null ? File(widget.imagePath!) : null),
          description: details.about,
          existingImageUrl: isNetwork ? widget.imagePath : null,
        );
      } catch (ce) {
        debugPrint("⚠️ Community post failed in ResultScreen (_fetch): $ce");
      }

      setState(() => _isLoading = false);
      debugPrint("🆕 [ResultScreen] Fetched new data from API - Deducting credits");
      _deductCreditsIfNeeded();
    } catch (e) {
      debugPrint("❌ Error fetching garden details: $e");
      setState(() {
        // ✅ User-friendly error message
        _error = "Unable to load plant details. Please check your internet connection and try again.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    try {
      _scanProvider.disposeCamera();
      _scanProvider.clearTemporaryStateSilently();
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

    final creditManager = context.read<CreditManager>();
    if (!creditManager.hasEnoughCredits(5)) {
      debugPrint("⚠️ [ResultScreen] Insufficient credits - Aborting plant identification");
      setState(() {
        _isLoading = false;
        _error = "You need 5 credits to identify this plant.";
      });
      _showInsufficientCreditsDialog();
      return;
    }

    provider.setSelectedImage(File(path));
    await provider.identifyPlant(context);

    setState(() {
      _isLoading = false;
      // ✅ Show user-friendly error message
      _error = provider.error != null
          ? "Unable to identify plant. Please try again with a clearer image."
          : null;
    });

    if (provider.error == null && provider.plantResult != null) {
      final identifiedPlant = provider.plantResult!;
      debugPrint("🌱 Identified plant: ${identifiedPlant.name}");

      _deductCreditsIfNeeded();

      Future.microtask(() async {
        try {
          final exists = ScanDB.scanExistsByName(identifiedPlant.name);
          if (exists) {
            debugPrint("⚠️ Duplicate detected: '${identifiedPlant.name}' already exists. Skipping save.");
            return;
          }

          final scannedPlant = ScannedPlant.fromPlantModel(
            identifiedPlant,
            imagePath: identifiedPlant.imagePath ?? path,
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
          return false;
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
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              iconTheme: const IconThemeData(color: Colors.white),
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
                    _buildPlantImage(heroImagePath),
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

                    _buildPlantDetailNativeAd(context),

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

                    ModernSection(
                      title: "Care Details",
                      icon: Icons.psychology_outlined,
                      child: CareDetailsGrid(details: plant.details),
                    ),

                    const SizedBox(height: 24),

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

                    if (plant.faqs.isNotEmpty) ...[
                      ModernSection(
                        title: "Frequently Asked Questions",
                        icon: Icons.help_outline,
                        child: ModernFAQList(faqs: plant.faqs),
                      ),
                      const SizedBox(height: 24),
                    ],

                    ModernSection(
                      title: "Fun Facts",
                      icon: Icons.emoji_nature_outlined,
                      child: FunFactsList(funFacts: plant.funFacts),
                    ),

                    const SizedBox(height: 32),

                    if (isFromGarden)
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
                      AddToGardenButton(
                        isFromHistory: isHistoryMode,
                        scannedPlant: widget.scannedPlant,
                        imagePath: widget.imagePath ?? heroImagePath,
                      ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Disclaimer: This plant data is AI-generated for informational purposes. Always verify important care requirements.",
                              style: TextStyle(fontSize: 12, color: Colors.orange[800], height: 1.4),
                            ),
                          ),
                        ],
                      ),
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
      ),
    );
  }

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

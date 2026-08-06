import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../provider/scan_provider.dart';
import '../widgets/gradient_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/modern_section.dart';
import '../widgets/error_state.dart';

class PestResultScreen extends StatefulWidget {
  final String imagePath;

  const PestResultScreen({super.key, required this.imagePath});

  @override
  State<PestResultScreen> createState() => _PestResultScreenState();
}

class _PestResultScreenState extends State<PestResultScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _identifyPest();
    });
  }

  Future<void> _identifyPest() async {
    final provider = Provider.of<ScanProvider>(context, listen: false);

    // ✅ Ensure the gallery/camera image is set in provider before identification
    debugPrint('🐛 [PestResultScreen] Setting image: ${widget.imagePath}');
    provider.setSelectedImage(File(widget.imagePath));

    await provider.identifyPest(context);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = provider.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final pest = provider.pestResult;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isLoading
          ? const LoadingStateWidget()
          : _error != null
              ? ErrorStateWidget(message: _error)
              : pest == null
                  ? const ErrorStateWidget(message: "No pest details available.")
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          backgroundColor: const Color(0xFFD32F2F),
                          iconTheme: const IconThemeData(color: Colors.white),
                          flexibleSpace: FlexibleSpaceBar(
                            title: const Text(
                              "Diagnosis Result",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(widget.imagePath), fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
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
                                // Pest Header
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD32F2F).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.bug_report, color: Color(0xFFD32F2F), size: 32),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pest.name,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFD32F2F),
                                              ),
                                            ),
                                            Text(
                                              pest.scientificName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // About Section
                                ModernSection(
                                  title: "What is it?",
                                  icon: Icons.info_outline,
                                  child: GradientCard(
                                    child: Text(
                                      pest.description,
                                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Symptoms Section
                                ModernSection(
                                  title: "Symptoms",
                                  icon: Icons.visibility_outlined,
                                  child: GradientCard(
                                    child: Text(
                                      pest.symptoms,
                                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Organic Treatment Section
                                ModernSection(
                                  title: "Organic Treatments",
                                  icon: Icons.eco_outlined,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "Natural Solutions",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          pest.organicTreatment,
                                          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Prevention Section
                                ModernSection(
                                  title: "Prevention",
                                  icon: Icons.shield_outlined,
                                  child: GradientCard(
                                    child: Text(
                                      pest.prevention,
                                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                
                                // Back to Home
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: const Text(
                                      'Back to Home',
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
                                          "Disclaimer: This analysis and treatment advice is AI-generated for informational purposes. Always exercise caution and consult a professional for critical plant care.",
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
    );
  }
}

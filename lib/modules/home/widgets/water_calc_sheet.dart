import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../ask_ai/repo/chat_repo.dart';
import '../../ask_ai/services/chat_api_service.dart';
import '../../my_garden/provider/garden_provider.dart';
import '../../my_garden/db/model/garden_plant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../provider/water_calculator_provider.dart';

class WaterCalcSheetLauncher {
  static void show(BuildContext context) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "NOT_FOUND";
    final apiService = GeminiChatApiService(apiKey);
    final repo = ChatRepository(apiService);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => WaterCalculationProvider(repo),
        child: const FractionallySizedBox(
          heightFactor: 0.85,
          child: _WaterCalcSheet(),
        ),
      ),
    );
  }
}

class _WaterCalcSheet extends StatelessWidget {
  const _WaterCalcSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaterCalculationProvider>();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundWhite.withOpacity(0.95),
                AppColors.backgroundLight.withOpacity(0.98),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Custom Handle
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Water Calculator",
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Get personalized watering recommendations",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress Indicator
              _buildModernProgress(context, provider),
              const SizedBox(height: 24),

              // Content
              Expanded(child: _buildStepContent(context, provider)),
              const SizedBox(height: 20),

              // Footer Buttons
              _buildModernFooter(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernProgress(BuildContext context, WaterCalculationProvider p) {
    final index = p.step.index;
    final total = WaterCalcStep.values.length;

    return Column(
      children: [
        // Step Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: WaterCalcStep.values.map((step) {
            final stepIndex = step.index;
            final isActive = stepIndex <= index;
            final isCurrent = stepIndex == index;

            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGreen
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 3,
                    ) : null,
                  ),
                  child: Center(
                    child: isActive
                        ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                        : Text(
                      '${stepIndex + 1}',
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepLabel(step),
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.primaryGreen : Colors.grey.shade500,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Progress Bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 500),
            alignment: Alignment.centerLeft,
            widthFactor: (index + 1) / total,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    Colors.green.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStepLabel(WaterCalcStep step) {
    switch (step) {
      case WaterCalcStep.selectPlant:
        return 'Plant';
      case WaterCalcStep.location:
        return 'Location';
      case WaterCalcStep.humidity:
        return 'Humidity';
      case WaterCalcStep.temperature:
        return 'Temperature';
      case WaterCalcStep.result:
        return 'Result';
    }
  }

  Widget _buildStepContent(BuildContext context, WaterCalculationProvider p) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Align(
        alignment:  Alignment.topCenter,
          child: _buildStepWidget(context, p)),
    );
  }

  Widget _buildStepWidget(BuildContext context, WaterCalculationProvider p) {
    switch (p.step) {
      case WaterCalcStep.selectPlant:
        return _SelectPlantStep(key: const ValueKey('select_plant'));
      case WaterCalcStep.location:
        return _LocationStep(key: const ValueKey('location'));
      case WaterCalcStep.humidity:
        return _HumidityStep(key: const ValueKey('humidity'));
      case WaterCalcStep.temperature:
        return _TemperatureStep(key: const ValueKey('temperature'));
      case WaterCalcStep.result:
        return _ResultStep(key: const ValueKey('result'));
    }
  }

  Widget _buildModernFooter(BuildContext context, WaterCalculationProvider p) {
    final bool isNextDisabled = p.isLoading ||
        (p.step == WaterCalcStep.selectPlant && p.selectedPlantId == null);

    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (p.step != WaterCalcStep.selectPlant)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: p.isLoading ? null : p.previous,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          if (p.step != WaterCalcStep.selectPlant) const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isNextDisabled
                    ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                )
                    : LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    Colors.green.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isNextDisabled
                    ? null
                    : [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isNextDisabled
                      ? null
                      : () => _handleNextAction(context, p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (p.isLoading)
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            p.step == WaterCalcStep.temperature
                                ? Icons.calculate_outlined
                                : Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _getButtonText(p),
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText(WaterCalculationProvider p) {
    if (p.isLoading) return 'Calculating...';
    if (p.step == WaterCalcStep.temperature) return 'Calculate';
    if (p.step == WaterCalcStep.result) return 'Done';
    return 'Next';
  }

  void _handleNextAction(BuildContext context, WaterCalculationProvider p) {
    if (p.step == WaterCalcStep.result) {
      Navigator.pop(context);
      return;
    }

    if (p.step == WaterCalcStep.temperature) {
      p.calculate().then((_) {
        if (p.error != null &&
            (p.error!.toLowerCase().contains("not found") ||
                p.error!.toLowerCase().contains("insufficient"))) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Sorry, plant name not recognized. Try another one."),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
      return;
    }

    p.next();
  }
}

/// ------------------ Modern Step Widgets ------------------

class _SelectPlantStep extends StatelessWidget {
  const _SelectPlantStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gardenProvider = Provider.of<GardenProvider>(context);
    final plants = gardenProvider.plants;
    final wc = context.watch<WaterCalculationProvider>();

    if (plants.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header Image
        _buildStepHeader(
          'assets/water_calc/select.jpeg',
          'Choose Your Plant',
          'Select a plant from your garden to calculate watering needs',
        ),
        const SizedBox(height: 24),

        // Plants Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: plants.length,
            itemBuilder: (_, i) => _buildPlantCard(plants[i], wc),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_florist, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "No Plants Yet",
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add plants to your garden first",
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(GardenPlant plant, WaterCalculationProvider wc) {
    final isSelected = wc.selectedPlantId == plant.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => wc.setPlant(plant.id, plant.name),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plant Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPlantImage(plant),
                  ),
                ),
                const SizedBox(height: 8),

                // Plant Name
                Text(
                  plant.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Plant Type
                Text(
                  plant.type,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.8) : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Selection Indicator
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantImage(GardenPlant plant) {
    if (plant.imagePath.isEmpty) {
      return Icon(Icons.local_florist, color: Colors.grey.shade400, size: 24);
    }

    if (plant.imagePath.startsWith('http')) {
      return Image.network(
        plant.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    } else {
      return Image.file(
        File(plant.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    }
  }

  Widget _buildImageError() {
    return Icon(Icons.broken_image, color: Colors.grey.shade400, size: 24);
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WaterCalculationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStepHeader(
            'assets/water_calc/location.jpeg',
            'Plant Location',
            'Where is your plant located? This affects watering frequency',
          ),
          const SizedBox(height: 32),

          // Location Cards
          Row(
            children: [
              Expanded(
                child: _buildLocationCard(
                  'Indoor',
                  Icons.home_outlined,
                  'Inside your home',
                  wc.location == 'Indoor',
                      () => wc.setLocation('Indoor'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLocationCard(
                  'Outdoor',
                  Icons.yard_outlined,
                  'Outside in garden',
                  wc.location == 'Outdoor',
                      () => wc.setLocation('Outdoor'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
      String title,
      IconData icon,
      String subtitle,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.8) : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HumidityStep extends StatelessWidget {
  const _HumidityStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WaterCalculationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStepHeader(
            'assets/water_calc/humidity.jpeg',
            'Ambient Humidity',
            'Adjust the humidity level around your plant',
          ),
          const SizedBox(height: 32),

          // Humidity Level Cards
          _buildHumidityLevels(wc),
          const SizedBox(height: 32),

          // Slider
          _buildHumiditySlider(wc),
        ],
      ),
    );
  }

  Widget _buildHumidityLevels(WaterCalculationProvider wc) {
    final levels = [
      {'label': 'Low', 'value': 30, 'icon': Icons.water_drop_outlined},
      {'label': 'Medium', 'value': 55, 'icon': Icons.water_drop},
      {'label': 'High', 'value': 80, 'icon': Icons.water_drop_rounded},
    ];

    return Row(
      children: levels.map((level) {
        final isSelected = _isHumidityLevelSelected(wc.humidity, level['value'] as int);
        return Expanded(
          child: _buildHumidityLevelCard(level, isSelected, wc),
        );
      }).toList(),
    );
  }

  bool _isHumidityLevelSelected(double currentHumidity, int levelValue) {
    if (levelValue == 30) return currentHumidity <= 40;
    if (levelValue == 55) return currentHumidity > 40 && currentHumidity < 70;
    return currentHumidity >= 70;
  }

  Widget _buildHumidityLevelCard(
      Map<String, dynamic> level,
      bool isSelected,
      WaterCalculationProvider wc,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => wc.setHumidity(level['value'].toDouble()),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(
                    level['icon'] as IconData,
                    color: isSelected ? AppColors.primaryGreen : Colors.grey.shade500,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level['label'] as String,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryGreen : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHumiditySlider(WaterCalculationProvider wc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Humidity Level',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${wc.humidity.round()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: wc.humidity,
            min: 10,
            max: 100,
            divisions: 90,
            onChanged: wc.setHumidity,
            activeColor: AppColors.primaryGreen,
            inactiveColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10%', style: AppTextStyles.caption),
              Text('100%', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemperatureStep extends StatelessWidget {
  const _TemperatureStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WaterCalculationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStepHeader(
            'assets/water_calc/temprature.jpeg',
            'Temperature',
            'Set the current temperature around your plant',
          ),
          const SizedBox(height: 32),

          // Temperature Unit Toggle
          _buildTemperatureUnitToggle(wc),
          const SizedBox(height: 32),

          // Temperature Slider
          _buildTemperatureSlider(wc),
        ],
      ),
    );
  }

  Widget _buildTemperatureUnitToggle(WaterCalculationProvider wc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitButton('°C', 'C', wc),
          _buildUnitButton('°F', 'F', wc),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, String unit, WaterCalculationProvider wc) {
    final isSelected = wc.tempUnit == unit;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => wc.setTempUnit(unit),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryGreen : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureSlider(WaterCalculationProvider wc) {
    final isCelsius = wc.tempUnit == "C";
    final minTemp = isCelsius ? 0 : 32;
    final maxTemp = isCelsius ? 40 : 104;
    final currentTemp = wc.temperature.clamp(minTemp.toDouble(), maxTemp.toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTemperatureColor(currentTemp, isCelsius).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentTemp.round()}${wc.tempUnit}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getTemperatureColor(currentTemp, isCelsius),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: currentTemp,
            min: minTemp.toDouble(),
            max: maxTemp.toDouble(),
            divisions: (maxTemp - minTemp),
            onChanged: wc.setTemperature,
            activeColor: _getTemperatureColor(currentTemp, isCelsius),
            inactiveColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$minTemp${wc.tempUnit}', style: AppTextStyles.caption),
              Text('$maxTemp${wc.tempUnit}', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp, bool isCelsius) {
    final effectiveTemp = isCelsius ? temp : (temp - 32) * 5/9;

    if (effectiveTemp < 15) return Colors.blue;
    if (effectiveTemp < 25) return AppColors.primaryGreen;
    if (effectiveTemp < 30) return Colors.orange;
    return Colors.red;
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WaterCalculationProvider>();

    if (wc.isLoading) {
      return _buildLoadingState();
    }

    if (wc.error != null) {
      return _buildErrorState(wc.error!);
    }

    if (wc.result == null) {
      return _buildEmptyResultState();
    }

    return _buildResultContent(wc);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Calculating...",
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Getting personalized watering recommendations",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 40, color: Colors.red.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "Calculation Failed",
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.water_drop, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "No Results",
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try calculating again",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(WaterCalculationProvider wc) {
    final data = wc.result!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStepHeader(
            'assets/water_calc/result.jpeg',
            'Watering Plan',
            'Personalized recommendations for your plant',
          ),
          const SizedBox(height: 24),

          // Result Cards
          _buildResultCard(
            Icons.water_drop,
            'Water Amount',
            '${data['water_amount_ml'] ?? 'N/A'}',
            Colors.blue.shade50,
            Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildResultCard(
            Icons.schedule,
            'Frequency',
            '${data['watering_frequency'] ?? 'N/A'}',
            Colors.green.shade50,
            Colors.green,
          ),
          const SizedBox(height: 12),

          _buildResultCard(
            Icons.tips_and_updates,
            'Best Time',
            '${data['best_time'] ?? 'N/A'}',
            Colors.orange.shade50,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          // 🌿 Extra: adjustments
          Text("Environmental Adjustments", style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          _buildAdjustmentItem("Low Humidity", data['adjustments']?['if_low_humidity']),
          _buildAdjustmentItem("High Humidity", data['adjustments']?['if_high_humidity']),
          _buildAdjustmentItem("Low Temperature", data['adjustments']?['if_low_temperature']),
          _buildAdjustmentItem("High Temperature", data['adjustments']?['if_high_temperature']),

          const SizedBox(height: 20,),
          // 🌿 Tips section
          Text("Tips", style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          ...List.generate(
            (data['tips'] as List?)?.length ?? 0,
                (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      (data['tips']?[i] ?? '').toString(),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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

  Widget _buildResultCard(
      IconData icon,
      String title,
      String value,
      Color backgroundColor,
      Color iconColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: backgroundColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAdjustmentItem(String label, String? advice) {
  if (advice == null || advice.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.tune, size: 18, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label: $advice",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}


// Helper method for step headers
Widget _buildStepHeader(String imagePath, String title, String subtitle) {
  return Column(
    children: [
      Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
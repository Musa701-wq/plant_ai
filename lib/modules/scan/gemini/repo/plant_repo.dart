// lib/modules/scan/gemini/repositories/plant_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/plant_model.dart';
import '../model/pest_model.dart';
import '../services/gemini_api_service.dart';

class PlantRepository {
  final GeminiApiService apiService;

  PlantRepository(this.apiService);

  /// Identify a plant from the image using Gemini API.
  /// Returns a structured [PlantModel] ready for display.
  Future<PlantModel> identifyPlant(File imageFile) async {
    try {
      debugPrint("📤 [PlantRepository] Sending image to Gemini for identification...");
      final plant = await apiService.identifyPlant(imageFile);

      debugPrint("✅ [PlantRepository] Successfully identified plant: ${plant.name}");
      return plant;
    } catch (e, st) {
      debugPrint("❌ [PlantRepository] Identification failed: $e\n$st");
      rethrow;
    }
  }

  /// Identify a pest from the image using Gemini API.
  Future<PestModel> identifyPest(File imageFile) async {
    try {
      debugPrint("📤 [PlantRepository] Sending image to Gemini for pest identification...");
      final pest = await apiService.identifyPest(imageFile);

      debugPrint("✅ [PlantRepository] Successfully identified pest: ${pest.name}");
      return pest;
    } catch (e, st) {
      debugPrint("❌ [PlantRepository] Pest identification failed: $e\n$st");
      rethrow;
    }
  }
}

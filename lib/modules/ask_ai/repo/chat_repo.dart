// lib/services/gemini/repo/chat_repository.dart
import '../../scan/gemini/model/plant_model.dart';
import '../services/chat_api_service.dart';
class ChatRepository {
  final GeminiChatApiService apiService;

  ChatRepository(this.apiService);

  /// Get AI response with context (last few messages)
  Future<String> getAiResponse(List<Map<String, dynamic>> messages) async {
    return await apiService.sendMessageWithContext(messages);
  }

  /// 🌿 NEW: Get plant details by name
  Future<PlantModel> getPlantDetailsByName(String plantName) async {
    return await apiService.fetchPlantDetailsByName(plantName);
  }

  /// 🌊 NEW: get watering plan
  Future<Map<String, dynamic>> getWateringPlan({
    required String plantName,
    required String location,
    required double humidityPercent,
    required double temperature,
    required String tempUnit,
  }) async {
    return await apiService.fetchWateringPlan(
      plantName: plantName,
      location: location,
      humidityPercent: humidityPercent,
      temperature: temperature,
      tempUnit: tempUnit,
    );
  }

}

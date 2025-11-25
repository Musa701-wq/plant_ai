// lib/modules/my_garden/provider/plant_details_provider.dart
import 'package:flutter/foundation.dart';
import '../../../modules/scan/gemini/model/plant_model.dart';
import '../../ask_ai/repo/chat_repo.dart';

class PlantDetailsProvider extends ChangeNotifier {
  final ChatRepository repository;

  PlantDetailsProvider(this.repository);

  bool _isLoading = false;
  PlantModel? _plantDetails;
  String? _error;

  bool get isLoading => _isLoading;
  PlantModel? get plantDetails => _plantDetails;
  String? get error => _error;

  Future<void> fetchPlantDetails(String plantName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("🌿 Fetching plant details for: $plantName");
      _plantDetails = await repository.getPlantDetailsByName(plantName);
      debugPrint("✅ Plant details fetched: ${_plantDetails?.name}");
    } catch (e) {
      debugPrint("❌ Error fetching plant details: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

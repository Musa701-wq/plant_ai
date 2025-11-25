import 'package:flutter/foundation.dart';
import '../../ask_ai/repo/chat_repo.dart';

enum WaterCalcStep { selectPlant, location, humidity, temperature, result }

class WaterCalculationProvider extends ChangeNotifier {
  final ChatRepository repository;

  WaterCalculationProvider(this.repository);

  WaterCalcStep step = WaterCalcStep.selectPlant;

  // input state
  String? selectedPlantId;
  String? selectedPlantName;
  String location = "Indoor";
  double humidity = 50.0;
  double temperature = 22.0;
  String tempUnit = "C";

  // runtime state
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? result;

  // navigation helpers
  void goToStep(WaterCalcStep s) {
    step = s;
    notifyListeners();
  }

  void next() {
    if (step.index < WaterCalcStep.values.length - 1) {
      step = WaterCalcStep.values[step.index + 1];
      notifyListeners();
    }
  }

  void previous() {
    if (step.index > 0) {
      step = WaterCalcStep.values[step.index - 1];
      notifyListeners();
    }
  }

  void setPlant(String id, String name) {
    selectedPlantId = id;
    selectedPlantName = name;
    notifyListeners();
  }

  void setLocation(String loc) {
    location = loc;
    notifyListeners();
  }

  void setHumidity(double h) {
    humidity = h;
    notifyListeners();
  }

  void setTemperature(double t) {
    temperature = t;
    notifyListeners();
  }

  void setTempUnit(String u) {
    if (u == tempUnit) return;

    if (u == "F") {
      // Convert °C → °F
      temperature = (temperature * 9 / 5) + 32;
    } else {
      // Convert °F → °C
      temperature = (temperature - 32) * 5 / 9;
    }

    // Clamp value within range to avoid slider assertion
    if (u == "C") {
      if (temperature < 0) temperature = 0;
      if (temperature > 40) temperature = 40;
    } else {
      if (temperature < 32) temperature = 32;
      if (temperature > 104) temperature = 104;
    }

    tempUnit = u;
    notifyListeners();
  }


  Future<void> calculate() async {
    if (selectedPlantName == null) {
      error = "Please select a plant.";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    result = null;
    notifyListeners();

    try {
      final res = await repository.getWateringPlan(
        plantName: selectedPlantName!,
        location: location,
        humidityPercent: humidity,
        temperature: temperature,
        tempUnit: tempUnit,
      );

      result = res;
      step = WaterCalcStep.result;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

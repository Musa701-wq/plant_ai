import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../scan/db/model/scanned_plant.dart';
import '../../../scan/gemini/model/plant_model.dart';
import '../model/garden_plant.dart';

class GardenDB {
  static const String _plantBoxName = "garden_plants";

  static Future<void> init() async {
    Hive.registerAdapter(GardenPlantAdapter());
    Hive.registerAdapter(PlantReminderAdapter());


    // 🆕 Register PlantModel Adapters
    Hive.registerAdapter(ScannedPlantAdapter());
    Hive.registerAdapter(PlantDetailsHiveAdapter());
    Hive.registerAdapter(FAQItemHiveAdapter());

    await Hive.openBox<GardenPlant>(_plantBoxName);
  }

  static Box<GardenPlant> _box() => Hive.box<GardenPlant>(_plantBoxName);

  /// Add new plant
  static Future<GardenPlant?> addPlant({
    required String name,
    required String type,
    required String imagePath,
    required DateTime addedDate,
    required int health,
    List<PlantReminder> reminders = const [],
    String? scanId,
    PlantModel? cachedDetails, // 🆕 optional local details

  }) async {
    // 🧠 Prevent duplicate by name
    if (plantExists(name)) {
      debugPrint("⚠️ Duplicate plant detected in GardenDB: $name");
      return null; // Return null if duplicate
    }

    final plant = GardenPlant(
      id: const Uuid().v4(),
      name: name,
      type: type,
      imagePath: imagePath,
      addedDate: addedDate,
      health: health,
      reminders: reminders,
      scanId: scanId, // <-- store link
    );

    await _box().put(plant.id, plant);
    debugPrint("✅ Plant added successfully: ${plant.name}");
    return plant;
  }

  /// Check if a plant already exists by (case-insensitive) name
  static bool plantExists(String name) {
    return getAllPlants().any(
          (p) => p.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }


  /// Update existing plant
  static Future<void> updatePlant(GardenPlant plant) async {
    await _box().put(plant.id, plant);
  }

  /// Delete plant
  static Future<void> deletePlant(String id) async {
    await _box().delete(id);
  }

  /// Get all plants
  static List<GardenPlant> getAllPlants() {
    return _box().values.toList();
  }

  /// Watch for changes (live updates)
  static Stream<List<GardenPlant>> watchPlants() {
    return _box().watch().map((event) => getAllPlants());
  }

  /// Get single plant
  static GardenPlant? getPlant(String id) {
    return _box().get(id);
  }


  /// ✅ Watch total plant count (auto-updating)
  static Stream<int> watchTotalCount() async* {
    yield _box().length; // emit initial count
    yield* _box().watch().map((_) => _box().length);
  }

  /// Clear all plants
  static Future<void> clearAll() async {
    await _box().clear();
  }

  /// Get all reminders from all plants (flattened)
  static List<PlantReminder> getAllReminders() {
    return getAllPlants()
        .expand((p) => p.reminders)
        .toList()
      ..sort((a, b) {
        final aDate = a.nextReminderDateTime ?? a.time;
        final bDate = b.nextReminderDateTime ?? b.time;
        return aDate.compareTo(bDate);
      });
  }

  /// Stream all reminders live
  static Stream<List<PlantReminder>> watchAllReminders() {
    return _box().watch().map((_) => getAllReminders());
  }

  /// Save or update local details for a specific plant
  static Future<void> savePlantDetails(String plantId, ScannedPlant details) async {
    final plant = getPlant(plantId);
    if (plant != null) {
      plant.cachedPlantDetails = details;
      await plant.save();
    }
  }


}

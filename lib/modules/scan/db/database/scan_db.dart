// lib/modules/scan/local/scan_db.dart
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../model/scanned_plant.dart';

class ScanDB {
  static const String _scanBoxName = 'scanned_plants';

  static Future<void> init() async {
    // Register adapters (only once)
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ScannedPlantAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(PlantDetailsHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(FAQItemHiveAdapter());
    }

    if (!Hive.isBoxOpen(_scanBoxName)) {
      await Hive.openBox<ScannedPlant>(_scanBoxName);
    }
  }

  static Box<ScannedPlant> _box() => Hive.box<ScannedPlant>(_scanBoxName);

  /// Add a scan record (ScannedPlant)
  static Future<ScannedPlant?> addScan(ScannedPlant scan) async {
    if (scan.name != null && scanExistsByName(scan.name!)) {
      debugPrint("⚠️ Duplicate scan detected in ScanDB: ${scan.name}");
      return null;
    }
    await _box().put(scan.id, scan);
    return scan;
  }

  static bool scanExistsByName(String name) {
    return getAllScans(descending: false).any(
          (p) => (p.name ?? '').trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  /// Convenience: Add from PlantModel with optional image path
  static Future<ScannedPlant?> addFromPlantModel(ScannedPlant scan) async {
    if (scan.name != null && scanExistsByName(scan.name!)) {
      debugPrint("⚠️ Duplicate scan detected in ScanDB: ${scan.name}");
      return null;
    }
    // same as addScan, kept for clarity
    await _box().put(scan.id, scan);
    return scan;
  }

  /// Get all scans (most recent first)
  static List<ScannedPlant> getAllScans({bool descending = true}) {
    final values = _box().values.toList();
    if (descending) values.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return values;
  }

  /// Get single scan
  static ScannedPlant? getScan(String id) => _box().get(id);

  /// Delete
  static Future<void> deleteScan(String id) async => await _box().delete(id);

  /// Clear all scans
  static Future<void> clearAll() async => await _box().clear();

  /// Watch scans as stream
  static Stream<List<ScannedPlant>> watchScans() async*{
    yield getAllScans();
    yield* _box().watch().map((_) => getAllScans());
  }

  /// ✅ Watch total number of scans (auto updates)
  static Stream<int> watchTotalCount() async* {
    yield _box().length; // Initial count
    yield* _box().watch().map((_) => _box().length);
  }

  /// Simple getter (non-reactive)
  static int get totalCount => _box().length;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../gemini/model/plant_model.dart';
import '../gemini/repo/plant_repo.dart';
import '../db/database/scan_db.dart';
import '../db/model/scanned_plant.dart';

class ScanProvider with ChangeNotifier {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;
  ScannedPlant? _lastScannedPlant; // ✅ newly added

  File? _selectedImage;
  bool _isLoading = false;
  String? _error;

  final PlantRepository plantRepo;
  ScanProvider(this.plantRepo);

  ScannedPlant? get lastScannedPlant => _lastScannedPlant;
  PlantModel? _plantResult;
  PlantModel? get plantResult => _plantResult;

  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize camera
  Future<void> initCamera() async {
    if (_isInitialized) return; // prevent double init
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint("📷 Initializing cameras...");
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception("No cameras available");
      }

      _selectedCameraIndex = 0;
      await _setupCamera(_cameras![_selectedCameraIndex]);

      _isInitialized = true;
      debugPrint("✅ Camera initialized successfully");
    } catch (e, st) {
      _error = "Failed to initialize camera: $e";
      debugPrint("❌ Camera init error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _setupCamera(CameraDescription description) async {
    try {
      debugPrint("🎥 Setting up camera: ${description.name}");

      // Dispose old controller before new
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      _cameraController = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;

      debugPrint("✅ Camera ready: ${description.name}");
    } catch (e, st) {
      _error = "Failed to setup camera: $e";
      debugPrint("❌ Setup camera error: $e\n$st");
      _isInitialized = false;
    }
    notifyListeners();
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras!.length;

    debugPrint("🔄 Switching to camera index $_selectedCameraIndex");
    await _setupCamera(_cameras![_selectedCameraIndex]);
  }

  /// Toggle flash
  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
        debugPrint("💡 Flash OFF");
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        _isFlashOn = true;
        debugPrint("💡 Flash ON");
      }
    } catch (e, st) {
      _error = "Failed to toggle flash: $e";
      debugPrint("❌ Flash toggle error: $e\n$st");
    }
    notifyListeners();
  }

  /// Capture image
  Future<void> captureImage(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _error = "Camera not initialized";
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint("📸 Capturing image...");
      final image = await _cameraController!.takePicture();
      _selectedImage = File(image.path);

      // ✅ Turn off camera to free resources
      await _cameraController?.dispose();
      _cameraController = null;
      _isInitialized = false;

      debugPrint("✅ Image captured at: ${image.path}");
    } catch (e, st) {
      _error = "Failed to capture image: $e";
      debugPrint("❌ Capture error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick image
  Future<void> pickImageFromGallery(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);

        // ✅ Turn off camera
        await _cameraController?.dispose();
        _cameraController = null;
        _isInitialized = false;

        debugPrint("✅ Image selected: ${pickedFile.path}");
      }
    } catch (e, st) {
      _error = "Failed to pick image: $e";
      debugPrint("❌ Gallery error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear preview → restart camera
  Future<void> clearSelectedImage() async {
    _selectedImage = null;
    notifyListeners();
    await initCamera();
  }

  /// Prepare for identification - just returns the image path
  String? prepareForIdentification() {
    if (_selectedImage == null) {
      _error = "No image selected.";
      notifyListeners();
      return null;
    }
    
    return _selectedImage!.path;
  }
  
  /// Identify plant - API call only, no navigation
  Future<void> identifyPlant() async {
    if (_selectedImage == null) {
      _error = "No image selected.";
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint("🌿 Sending image to Gemini for identification...");

      // 🔍 Ask Gemini to identify the plant
      final result = await plantRepo.identifyPlant(_selectedImage!);

      // 🧠 Validate the Gemini response
      if (result.name.toLowerCase().contains("error") ||
          result.name.isEmpty ||
          result.name == "Unknown Plant") {
        _error = "Couldn't identify a plant in this image. Please try another one.";
        debugPrint("⚠️ Invalid identification result: $result");
        return;
      }

      // ✅ Set result for the UI
      _plantResult = result;
      _lastScannedPlant = ScannedPlant.fromPlantModel(result, imagePath: _selectedImage?.path);
      debugPrint("✅ Plant identified: ${result.name}");

    } catch (e, st) {
      _error = "Identification failed: $e";
      debugPrint("❌ Plant identification error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPlantFromScanned(ScannedPlant scanned) {
    _plantResult = scanned.toPlantModel();
    _selectedImage = File(scanned.imagePath!);
    _error = null;
    notifyListeners();
  }

  void setSelectedImage(File file) {
    _selectedImage = file;
    notifyListeners();
  }

  /// Properly dispose the camera and turn off flash if needed
  Future<void> disposeCamera() async {
    try {
      if (_cameraController != null) {
        if (_isFlashOn) {
          await _cameraController!.setFlashMode(FlashMode.off);
          _isFlashOn = false;
        }
        await _cameraController!.dispose();
        _cameraController = null;
        _isInitialized = false;
        debugPrint("📴 Camera disposed safely.");
      }
    } catch (e) {
      debugPrint("⚠️ Error while disposing camera: $e");
    }
  }

  // inside ScanProvider (if not present)
  void setPlantFromPlantModel(PlantModel model) {
    _plantResult = model;
    // if your PlantModel doesn't have imagePath field, consider adding it.
    notifyListeners();
  }



  /// Clear temporary capture data (like selected image)
  void clearTemporaryState() {
    _selectedImage = null;
    _error = null;
    _isLoading = false;
    _plantResult = null;
    notifyListeners();
  }

  void clearTemporaryStateSilently() {
    _selectedImage = null;
    _error = null;
    _isLoading = false;
    _plantResult = null;
    // ❌ no notifyListeners() here
  }

  @override
  void dispose() {
    debugPrint("🛑 Disposing ScanProvider...");
    _cameraController?.dispose();
    _selectedImage = null;
    _cameraController = null;
    debugPrint("🛑 Disposing ScanProvider (with camera cleanup)...");
    disposeCamera();
    _isInitialized = false;
    super.dispose();
  }
}

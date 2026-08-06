import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/s3_service.dart';
import '../../my_garden/provider/SettingsProvider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../gemini/model/plant_model.dart';
import '../gemini/model/pest_model.dart';
import '../gemini/repo/plant_repo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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

  PlantModel? _plantResult;
  ScannedPlant? get lastScannedPlant => _lastScannedPlant;
  PlantModel? get plantResult => _plantResult;

  PestModel? _pestResult;
  PestModel? get pestResult => _pestResult;

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
  Future<void> identifyPlant(BuildContext context) async {
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

      final imageToUpload = _selectedImage!; // 📸 Capture reference early

      // 🔍 Ask Gemini to identify the plant
      final result = await plantRepo.identifyPlant(imageToUpload);

      // 🧠 Validate the Gemini response
      if (result.name.toLowerCase().contains("error") ||
          result.name.isEmpty ||
          result.name == "Unknown Plant") {
        _error = "Couldn't identify a plant in this image. Please try another one.";
        debugPrint("⚠️ Invalid identification result: $result");
        return;
      }

      // ✅ Save image permanently before creating ScannedPlant
      final permanentFile = await saveImagePermanently(imageToUpload);
      final permanentPath = permanentFile.path;

      // ✅ Set result for the UI
      _plantResult = result;
      _plantResult?.imagePath = permanentPath; // Update model path
      
      _lastScannedPlant = ScannedPlant.fromPlantModel(result, imagePath: permanentPath);
      debugPrint("✅ Plant identified: ${result.name} (Permanent path: $permanentPath)");

      // 📤 Community Upload logic — using captured reference
      debugPrint('📤 [identifyPlant] Triggering community upload...');
      await pushToCommunity(context, result.name, "plant", permanentFile, description: result.about);

    } catch (e, st) {
      _error = "Identification failed: $e";
      debugPrint("❌ Plant identification error: $e\n$st");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save image permanently to application documents directory
  Future<File> saveImagePermanently(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = p.basename(imageFile.path);
      // Create a unique name to avoid collisions if same filename is reused by picker
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final permanentPath = p.join(directory.path, 'scans', '${timestamp}_$name');
      
      // Ensure directory exists
      final saveDir = Directory(p.dirname(permanentPath));
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final permanentFile = await imageFile.copy(permanentPath);
      debugPrint("💾 Image saved permanently to: ${permanentFile.path}");
      return permanentFile;
    } catch (e) {
      debugPrint("❌ Failed to save image permanently: $e");
      return imageFile; // Fallback to original path if copy fails
    }
  }

  /// Identify pest - API call only
  Future<void> identifyPest(BuildContext context) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🐛 [identifyPest] Called');
    debugPrint('   _selectedImage: ${_selectedImage?.path ?? "NULL"}');
    debugPrint('════════════════════════════════════════');

    if (_selectedImage == null) {
      _error = "No image selected.";
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint("🐛 [identifyPest] Sending image to Gemini...");

      final imageToUpload = _selectedImage!; // 📸 Capture reference early

      final result = await plantRepo.identifyPest(imageToUpload);

      debugPrint('✅ [identifyPest] Gemini result: ${result.name}');

      if (result.name.toLowerCase().contains("error") || result.name.isEmpty) {
        _error = "Couldn't identify any pest in this image. Please try another one.";
        debugPrint('⚠️ [identifyPest] Invalid result — aborting community upload');
        return;
      }

      _pestResult = result;
      debugPrint("✅ Pest identified: ${result.name}");

      // 📤 Community Upload logic — using captured reference
      debugPrint('📤 [identifyPest] Triggering community upload...');
      await pushToCommunity(context, result.name, "pest", imageToUpload, description: result.description);

    } catch (e, st) {
      _error = "Pest identification failed: $e";
      debugPrint("❌ Pest identification error: $e\n$st");
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
    _pestResult = null;
    notifyListeners();
  }

  void clearTemporaryStateSilently() {
    _selectedImage = null;
    _error = null;
    _isLoading = false;
    _plantResult = null;
    _pestResult = null;
    // ❌ no notifyListeners() here
  }

  /// Handle community upload if enabled
  Future<void> pushToCommunity(
    BuildContext context, 
    String itemName, 
    String type, 
    File? imageFile, {
    String? description,
    String? existingImageUrl,
  }) async {
    try {
      debugPrint('════════════════════════════════════════');
      debugPrint('🌐 [CommunityUpload] Triggered for "$itemName" ($type)');

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      debugPrint('   Toggle ON: ${settingsProvider.communityUploadEnabled}');

      if (!settingsProvider.communityUploadEnabled) {
        debugPrint('   ⏭️ Skipped: user has community upload DISABLED');
        debugPrint('════════════════════════════════════════');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('   ❌ No logged-in user — aborting');
        debugPrint('════════════════════════════════════════');
        return;
      }

      debugPrint('   👤 User: ${user.email} (${user.uid})');
      debugPrint('   📁 Image: ${imageFile?.path ?? "NONE"}');
      debugPrint('   🔗 Existing URL: ${existingImageUrl ?? "NONE"}');
      debugPrint('════════════════════════════════════════');

      String? finalImageUrl = existingImageUrl;
      
      // If no existing URL, we must have a file to upload
      if (finalImageUrl == null && imageFile != null) {
        finalImageUrl = await S3Service.uploadImage(imageFile);
      }

      if (finalImageUrl != null) {
        debugPrint('💾 [CommunityUpload] Saving to Firestore community_images...');
        await FirebaseFirestore.instance.collection('community_images').add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonymous',
          'userEmail': user.email ?? '',
          'imageUrl': finalImageUrl,
          'itemName': itemName,
          'type': type,
          'description': description ?? '',
          'timestamp': FieldValue.serverTimestamp(),
          'likes': [], // Initialize with empty likes list
        });
        debugPrint('✅ [CommunityUpload] Saved successfully!');
      } else {
        debugPrint('⚠️ [CommunityUpload] S3 upload returned null — Firestore NOT updated');
      }
    } catch (e) {
      debugPrint('❌ [CommunityUpload] Error: $e');
    }
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

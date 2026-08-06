// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Auth/SharedPreferencesService.dart';
// import '../../../Auth/UserFirestoreService.dart';
// import '../../../Auth/google_auth.dart';
// import '../../../Auth/google_sign_out.dart';
//
// /// Provider class that handles all business logic for Settings/Profile
// class SettingsProvider extends ChangeNotifier {
//   // State variables
//   bool _isLoading = true;
//   String? _profileImageBase64;
//   String _displayName = 'User';
//   String _email = 'No email';
//   String _accountType = 'FREE ACCOUNT';
//
//   // Getters
//   bool get isLoading => _isLoading;
//   String? get profileImageBase64 => _profileImageBase64;
//   String get displayName => _displayName;
//   String get email => _email;
//   String get accountType => _accountType;
//
//   /// Load user data from SharedPreferences and Firestore
//   Future<void> loadUserData() async {
//     try {
//       debugPrint("📖 [SettingsProvider] Loading user data...");
//       _isLoading = true;
//       notifyListeners();
//
//       // Get current user
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (user == null) {
//         debugPrint("⚠️ [SettingsProvider] No user signed in");
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//
//       // Load from SharedPreferences first (faster)
//       final localData = await SharedPreferencesService.getUserData();
//
//       if (localData != null) {
//         debugPrint("✅ [SettingsProvider] Loaded data from SharedPreferences");
//         _displayName = localData['displayName'] ?? user.displayName ?? 'User';
//         _email = localData['email'] ?? user.email ?? 'No email';
//         _profileImageBase64 = localData['photoBase64']?.isNotEmpty == true
//             ? localData['photoBase64']
//             : null;
//         notifyListeners();
//       }
//
//       // Also load from Firestore (for sync)
//       final firestoreData = await UserFirestoreService.getUserFromFirestore(user.uid);
//
//       if (firestoreData != null) {
//         debugPrint("✅ [SettingsProvider] Loaded data from Firestore");
//         _displayName = firestoreData['displayName'] ?? user.displayName ?? 'User';
//         _email = firestoreData['email'] ?? user.email ?? 'No email';
//
//         // Update base64 image if available
//         if (firestoreData['photoBase64']?.isNotEmpty == true) {
//           _profileImageBase64 = firestoreData['photoBase64'];
//         }
//         notifyListeners();
//       }
//
//       // Fallback to Firebase Auth data
//       if (_displayName == 'User' && user.displayName != null) {
//         _displayName = user.displayName!;
//       }
//       if (_email == 'No email' && user.email != null) {
//         _email = user.email!;
//       }
//
//       // Check account type
//       final providers = user.providerData.map((e) => e.providerId).toList();
//       _accountType = providers.contains('google.com') || providers.contains('apple.com')
//           ? 'SIGNED IN ACCOUNT'
//           : 'FREE ACCOUNT';
//
//       debugPrint("✅ [SettingsProvider] User data loaded successfully");
//       debugPrint("   - Name: $_displayName");
//       debugPrint("   - Email: $_email");
//       debugPrint("   - Account Type: $_accountType");
//       debugPrint("   - Has Profile Image: ${_profileImageBase64 != null}");
//
//     } catch (e) {
//       debugPrint("❌ [SettingsProvider] Error loading user data: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Pick and upload image from camera or gallery
//   Future<String?> pickAndUploadImage(ImageSource source) async {
//     try {
//       debugPrint("📷 [Image Upload] Starting image pick from ${source.name}");
//
//       final ImagePicker picker = ImagePicker();
//
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );
//
//       if (image == null) {
//         debugPrint("ℹ️ [Image Upload] No image selected");
//         return null;
//       }
//
//       debugPrint("✅ [Image Upload] Image selected: ${image.path}");
//
//       final bytes = await image.readAsBytes();
//       final base64Image = base64Encode(bytes);
//
//       // Check image size (1MB limit)
//       if (base64Image.length > 1048487) {
//         return 'IMAGE_TOO_LARGE';
//       }
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         return 'NO_USER';
//       }
//
//       // Update Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({
//         'photoBase64': base64Image,
//         'photoUpdatedAt': FieldValue.serverTimestamp(),
//       });
//
//       // Update SharedPreferences
//       await SharedPreferencesService.updatePhotoBase64(base64Image);
//
//       // Update state
//       _profileImageBase64 = base64Image;
//       notifyListeners();
//
//       debugPrint("✅ [Image Upload] Successfully uploaded image");
//       return 'SUCCESS';
//
//     } catch (e) {
//       debugPrint("❌ [Image Upload] Error: $e");
//       return 'ERROR: ${e.toString()}';
//     }
//   }
//
//   /// Update display name
//   Future<String?> updateDisplayName(String newName) async {
//     try {
//       if (newName.trim().isEmpty) {
//         return 'Name cannot be empty';
//       }
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         return 'No user signed in';
//       }
//
//       // Update Firebase Auth
//       await user.updateDisplayName(newName);
//       await user.reload();
//
//       // Update Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({
//         'displayName': newName,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       // Update SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_name', newName);
//
//       // Update state
//       _displayName = newName;
//       notifyListeners();
//
//       debugPrint("✅ [Update Name] Successfully updated display name");
//       return null; // null means success
//
//     } catch (e) {
//       debugPrint("❌ [Update Name] Error: $e");
//       return 'Failed to update name: ${e.toString()}';
//     }
//   }
//
//   /// Remove profile picture
//   Future<String?> removeProfilePicture() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         return 'No user signed in';
//       }
//
//       // Update Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({
//         'photoBase64': '',
//         'photoUpdatedAt': FieldValue.serverTimestamp(),
//       });
//
//       // Update SharedPreferences
//       await SharedPreferencesService.updatePhotoBase64('');
//
//       // Update state
//       _profileImageBase64 = null;
//       notifyListeners();
//
//       debugPrint("✅ [Remove Photo] Successfully removed profile picture");
//       return null; // null means success
//
//     } catch (e) {
//       debugPrint("❌ [Remove Photo] Error: $e");
//       return 'Failed to remove photo: ${e.toString()}';
//     }
//   }
//
//   /// Handle Sign Out
//   Future<void> signOut(BuildContext context) async {
//     try {
//       final success = await GoogleAuth.signOut();;
//       return success;
//     } catch (e) {
//       debugPrint("❌ [Sign Out] Error: $e");
//       //return false;
//     }
//   }
//
//   /// Handle Delete Account
//   Future<String?> deleteAccount() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         return 'No user signed in';
//       }
//
//       // Delete from Firestore
//       await UserFirestoreService.deleteUserFromFirestore(user.uid);
//
//       // Clear local data
//       await SharedPreferencesService.clearUserData();
//
//       // Delete Firebase Auth account
//       await user.delete();
//
//       debugPrint("✅ [Delete Account] Successfully deleted account");
//       return null; // null means success
//
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'requires-recent-login') {
//         // User needs to re-authenticate
//         await FirebaseAuth.instance.signOut();
//         return 'REQUIRES_RECENT_LOGIN';
//       }
//       return 'Firebase error: ${e.message}';
//     } catch (e) {
//       debugPrint("❌ [Delete Account] Error: $e");
//       return 'Failed to delete account: ${e.toString()}';
//     }
//   }
//
//   /// Refresh user data
//   Future<void> refresh() async {
//     await loadUserData();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Auth/SharedPreferencesService.dart';
import '../../../Auth/UserFirestoreService.dart';
import '../../../Auth/google_auth.dart';

/// Provider class that handles all business logic for Settings/Profile
class SettingsProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = true;
  String? _profileImageBase64;
  String _displayName = 'User';
  String _email = 'No email';
  String _accountType = 'FREE ACCOUNT';
  bool _communityUploadEnabled = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get profileImageBase64 => _profileImageBase64;
  String get displayName => _displayName;
  String get email => _email;
  String get accountType => _accountType;
  bool get communityUploadEnabled => _communityUploadEnabled;

  /// Load user data from SharedPreferences and Firestore
  Future<void> loadUserData() async {
    try {
      debugPrint("📖 [SettingsProvider] Loading user data...");
      _isLoading = true;
      notifyListeners();

      // Get current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("⚠️ [SettingsProvider] No user signed in");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load from SharedPreferences first (faster)
      final localData = await SharedPreferencesService.getUserData();

      if (localData != null) {
        debugPrint("✅ [SettingsProvider] Loaded data from SharedPreferences");
        _displayName = localData['displayName'] ?? user.displayName ?? 'User';
        _email = localData['email'] ?? user.email ?? 'No email';
        _profileImageBase64 = localData['photoBase64']?.isNotEmpty == true
            ? localData['photoBase64']
            : null;
        notifyListeners();
      }

      // Also load from Firestore (for sync)
      final firestoreData = await UserFirestoreService.getUserFromFirestore(user.uid);

      if (firestoreData != null) {
        debugPrint("✅ [SettingsProvider] Loaded data from Firestore");
        _displayName = firestoreData['displayName'] ?? user.displayName ?? 'User';
        _email = firestoreData['email'] ?? user.email ?? 'No email';

        // Update base64 image if available
        if (firestoreData['photoBase64']?.isNotEmpty == true) {
          _profileImageBase64 = firestoreData['photoBase64'];
        }
        notifyListeners();
      }

      // Fallback to Firebase Auth data
      if (_displayName == 'User' && user.displayName != null) {
        _displayName = user.displayName!;
      }
      if (_email == 'No email' && user.email != null) {
        _email = user.email!;
      }

      // Check account type
      final providers = user.providerData.map((e) => e.providerId).toList();
      _accountType = providers.contains('google.com') || providers.contains('apple.com')
          ? 'SIGNED IN ACCOUNT'
          : 'FREE ACCOUNT';

      // Load community upload setting
      _communityUploadEnabled = await SharedPreferencesService.isCommunityUploadEnabled();
      
      if (firestoreData != null && firestoreData.containsKey('communityUploadEnabled')) {
        _communityUploadEnabled = firestoreData['communityUploadEnabled'] ?? true;
        // Sync to local
        await SharedPreferencesService.setCommunityUploadEnabled(_communityUploadEnabled);
      }

      debugPrint("✅ [SettingsProvider] User data loaded successfully");
      debugPrint("   - Name: $_displayName");
      debugPrint("   - Email: $_email");
      debugPrint("   - Account Type: $_accountType");
      debugPrint("   - Has Profile Image: ${_profileImageBase64 != null}");

    } catch (e) {
      debugPrint("❌ [SettingsProvider] Error loading user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick and upload image from camera or gallery
  Future<String?> pickAndUploadImage(ImageSource source) async {
    try {
      debugPrint("📷 [Image Upload] Starting image pick from ${source.name}");

      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint("ℹ️ [Image Upload] No image selected");
        return null;
      }

      debugPrint("✅ [Image Upload] Image selected: ${image.path}");

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Check image size (1MB limit)
      if (base64Image.length > 1048487) {
        return 'IMAGE_TOO_LARGE';
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'NO_USER';
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'photoBase64': base64Image,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Update SharedPreferences
      await SharedPreferencesService.updatePhotoBase64(base64Image);

      // Update state
      _profileImageBase64 = base64Image;
      notifyListeners();

      debugPrint("✅ [Image Upload] Successfully uploaded image");
      return 'SUCCESS';

    } catch (e) {
      debugPrint("❌ [Image Upload] Error: $e");
      return 'ERROR: ${e.toString()}';
    }
  }

  /// Update display name
  Future<String?> updateDisplayName(String newName) async {
    try {
      if (newName.trim().isEmpty) {
        return 'Name cannot be empty';
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'No user signed in';
      }

      // Update Firebase Auth
      await user.updateDisplayName(newName);
      await user.reload();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);

      // Update state
      _displayName = newName;
      notifyListeners();

      debugPrint("✅ [Update Name] Successfully updated display name");
      return null; // null means success

    } catch (e) {
      debugPrint("❌ [Update Name] Error: $e");
      return 'Failed to update name: ${e.toString()}';
    }
  }

  /// Remove profile picture
  Future<String?> removeProfilePicture() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'No user signed in';
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'photoBase64': '',
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Update SharedPreferences
      await SharedPreferencesService.updatePhotoBase64('');

      // Update state
      _profileImageBase64 = null;
      notifyListeners();

      debugPrint("✅ [Remove Photo] Successfully removed profile picture");
      return null; // null means success

    } catch (e) {
      debugPrint("❌ [Remove Photo] Error: $e");
      return 'Failed to remove photo: ${e.toString()}';
    }
  }

  /// Handle Sign Out - Returns true on success, false on failure
  Future<bool> signOut() async {
    try {
      debugPrint("🚪 [Sign Out] Starting sign-out process...");

      // Get current user's provider
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final providers = user.providerData.map((e) => e.providerId).toList();
        debugPrint("🚪 [Sign Out] User providers: $providers");

        // Sign out from Google if applicable
        if (providers.contains('google.com')) {
          debugPrint("🔵 [Sign Out] Signing out from Google...");
          await GoogleAuth.signOut();
        }

        // Sign out from Apple if applicable (you can add AppleAuth here)
        // if (providers.contains('apple.com')) {
        //   debugPrint("🍎 [Sign Out] Signing out from Apple...");
        //   await AppleAuth.signOut();
        // }
      }

      // Sign out from Firebase
      debugPrint("🔥 [Sign Out] Signing out from Firebase...");
      await FirebaseAuth.instance.signOut();

      // Clear local data
      debugPrint("💾 [Sign Out] Clearing local data...");
      await SharedPreferencesService.clearUserData();

      // Reset provider state
      _displayName = "Guest";
      _email = "No email";
      _profileImageBase64 = null;
      _accountType = "FREE ACCOUNT";
      notifyListeners();

      debugPrint("✅ [Sign Out] Sign-out completed successfully");
      return true;

    } catch (e, stack) {
      debugPrint("❌ [Sign Out] Error: $e");
      debugPrint("Stack: $stack");
      return false;
    }
  }

  /// Handle Delete Account
  Future<String?> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'No user signed in';
      }

      // Delete from Firestore
      await UserFirestoreService.deleteUserFromFirestore(user.uid);

      // Clear local data
      await SharedPreferencesService.clearUserData();

      // Delete Firebase Auth account
      await user.delete();

      debugPrint("✅ [Delete Account] Successfully deleted account");
      return null; // null means success

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // User needs to re-authenticate
        await FirebaseAuth.instance.signOut();
        return 'REQUIRES_RECENT_LOGIN';
      }
      return 'Firebase error: ${e.message}';
    } catch (e) {
      debugPrint("❌ [Delete Account] Error: $e");
      return 'Failed to delete account: ${e.toString()}';
    }
  }

  /// Refresh user data
  Future<void> refresh() async {
    await loadUserData();
  }

  /// Toggle community upload
  Future<void> toggleCommunityUpload(bool enabled) async {
    try {
      _communityUploadEnabled = enabled;
      notifyListeners();

      // Update SharedPreferences
      await SharedPreferencesService.setCommunityUploadEnabled(enabled);

      // Update Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserFirestoreService.updateUserCommunityUpload(user.uid, enabled);
      }
      
      debugPrint("✅ [SettingsProvider] Community upload toggled to: $enabled");
    } catch (e) {
      debugPrint("❌ [SettingsProvider] Error toggling community upload: $e");
    }
  }
}
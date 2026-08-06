import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Keys for storing data
  static const String _keyIsSignedIn = 'is_signed_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyPhotoURL = 'photo_url';
  static const String _keyPhotoBase64 = 'photo_base64';
  static const String _keyEmailVerified = 'email_verified';
  static const String _keyProviders = 'providers';
  static const String _keyLastSignIn = 'last_sign_in';
  static const String _keyShowOnboarding = 'show_onboarding';
  static const String _keyCommunityUploadEnabled = 'community_upload_enabled';

  /// Save user data to SharedPreferences after sign-in
  static Future<bool> saveUserData(User user, {String? photoBase64}) async {
    try {
      debugPrint("💾 [SharedPreferences] Saving user data...");

      final prefs = await SharedPreferences.getInstance();

      // Save all user data
      await prefs.setBool(_keyIsSignedIn, true);
      await prefs.setString(_keyUserId, user.uid);
      await prefs.setString(_keyUserEmail, user.email ?? '');
      await prefs.setString(_keyUserName, user.displayName ?? '');
      await prefs.setString(_keyPhotoURL, user.photoURL ?? '');
      await prefs.setString(_keyPhotoBase64, photoBase64 ?? '');
      await prefs.setBool(_keyEmailVerified, user.emailVerified);
      await prefs.setString(_keyLastSignIn, DateTime.now().toIso8601String());
      
      // Initialize community upload to true by default if not set
      if (prefs.getBool(_keyCommunityUploadEnabled) == null) {
        await prefs.setBool(_keyCommunityUploadEnabled, true);
      }

      // Save providers as JSON string
      final providers = user.providerData.map((info) => info.providerId).toList();
      await prefs.setString(_keyProviders, jsonEncode(providers));

      debugPrint("✅ [SharedPreferences] User data saved successfully");
      debugPrint("   - UID: ${user.uid}");
      debugPrint("   - Email: ${user.email}");
      debugPrint("   - Name: ${user.displayName}");
      debugPrint("   - Has Base64 Photo: ${photoBase64?.isNotEmpty ?? false}");

      return true;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error saving user data: $e");
      return false;
    }
  }

  /// Check if user is signed in (from local storage)
  static Future<bool> isUserSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSignedIn = prefs.getBool(_keyIsSignedIn) ?? false;
      debugPrint("📖 [SharedPreferences] User signed in status: $isSignedIn");
      return isSignedIn;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error checking sign-in status: $e");
      return false;
    }
  }

  /// Get user ID from local storage
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting user ID: $e");
      return null;
    }
  }

  /// Get user email from local storage
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting user email: $e");
      return null;
    }
  }

  /// Get user display name from local storage
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting user name: $e");
      return null;
    }
  }

  /// Get photo URL from local storage
  static Future<String?> getPhotoURL() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPhotoURL);
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting photo URL: $e");
      return null;
    }
  }

  /// Get base64 photo from local storage
  static Future<String?> getPhotoBase64() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPhotoBase64);
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting photo base64: $e");
      return null;
    }
  }

  /// Get email verified status from local storage
  static Future<bool> isEmailVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyEmailVerified) ?? false;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting email verified status: $e");
      return false;
    }
  }

  /// Get providers list from local storage
  static Future<List<String>> getProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providersJson = prefs.getString(_keyProviders);

      if (providersJson != null && providersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(providersJson);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting providers: $e");
      return [];
    }
  }

  /// Get complete user data as Map
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!(prefs.getBool(_keyIsSignedIn) ?? false)) {
        debugPrint("ℹ️ [SharedPreferences] User not signed in");
        return null;
      }

      final providersJson = prefs.getString(_keyProviders) ?? '[]';
      List<String> providers = [];

      try {
        final List<dynamic> decoded = jsonDecode(providersJson);
        providers = decoded.cast<String>();
      } catch (e) {
        debugPrint("⚠️ [SharedPreferences] Error parsing providers: $e");
      }

      return {
        'uid': prefs.getString(_keyUserId) ?? '',
        'email': prefs.getString(_keyUserEmail) ?? '',
        'displayName': prefs.getString(_keyUserName) ?? '',
        'photoURL': prefs.getString(_keyPhotoURL) ?? '',
        'photoBase64': prefs.getString(_keyPhotoBase64) ?? '',
        'emailVerified': prefs.getBool(_keyEmailVerified) ?? false,
        'providers': providers,
        'lastSignIn': prefs.getString(_keyLastSignIn) ?? '',
        'communityUploadEnabled': prefs.getBool(_keyCommunityUploadEnabled) ?? true,
      };
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error getting user data: $e");
      return null;
    }
  }

  /// Clear all user data from SharedPreferences (call on sign-out)
  static Future<bool> clearUserData() async {
    try {
      debugPrint("🗑️ [SharedPreferences] Clearing user data...");

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyIsSignedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyPhotoURL);
      await prefs.remove(_keyPhotoBase64);
      await prefs.remove(_keyEmailVerified);
      await prefs.remove(_keyProviders);
      await prefs.remove(_keyLastSignIn);
      await prefs.remove(_keyCommunityUploadEnabled);

      debugPrint("✅ [SharedPreferences] User data cleared successfully");
      return true;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error clearing user data: $e");
      return false;
    }
  }

  /// Update photo base64 in SharedPreferences
  static Future<bool> updatePhotoBase64(String photoBase64) async {
    try {
      debugPrint("🖼️ [SharedPreferences] Updating photo base64...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPhotoBase64, photoBase64);
      debugPrint("✅ [SharedPreferences] Photo base64 updated");
      return true;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error updating photo base64: $e");
      return false;
    }
  }

  /// Update last sign-in time
  static Future<bool> updateLastSignIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSignIn, DateTime.now().toIso8601String());
      debugPrint("✅ [SharedPreferences] Last sign-in updated");
      return true;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error updating last sign-in: $e");
      return false;
    }
  }

  /// Check if onboarding should be shown (default: true)
  static Future<bool> shouldShowOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyShowOnboarding) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Mark onboarding as seen
  static Future<void> setOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShowOnboarding, false);
      debugPrint("✅ [SharedPreferences] Onboarding marked as seen");
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error setting onboarding seen: $e");
    }
  }

  /// Get community upload toggle state
  static Future<bool> isCommunityUploadEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyCommunityUploadEnabled) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Set community upload toggle state
  static Future<bool> setCommunityUploadEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCommunityUploadEnabled, enabled);
      debugPrint("✅ [SharedPreferences] Community upload toggle updated: $enabled");
      return true;
    } catch (e) {
      debugPrint("❌ [SharedPreferences] Error updating community upload toggle: $e");
      return false;
    }
  }
}
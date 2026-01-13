import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SharedPreferencesService.dart';

class UserFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const int _initialCredits = 30; // Initial credits for new users

  /// Convert image URL to base64 string
  static Future<String?> _convertImageUrlToBase64(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint("⚠️ [Image Conversion] No image URL provided");
      return null;
    }

    try {
      debugPrint("🖼️ [Image Conversion] Downloading image from: $imageUrl");

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);
        debugPrint("✅ [Image Conversion] Image converted to base64 (${base64Image.length} characters)");
        return base64Image;
      } else {
        debugPrint("❌ [Image Conversion] Failed to download image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ [Image Conversion] Error converting image: $e");
      return null;
    }
  }

  /// Save or update user data in Firestore AND SharedPreferences
  static Future<bool> saveUserToFirestore(User user) async {
    try {
      debugPrint("💾 [Firestore] Saving user data...");
      debugPrint("   - UID: ${user.uid}");
      debugPrint("   - Email: ${user.email}");
      debugPrint("   - Display Name: ${user.displayName}");
      debugPrint("   - Photo URL: ${user.photoURL}");

      // Check if user already exists
      final docRef = _firestore.collection(_usersCollection).doc(user.uid);
      final docSnapshot = await docRef.get();
      final isNewUser = !docSnapshot.exists;

      debugPrint("   - Is New User: $isNewUser");

      // Convert photo URL to base64 if available
      String? base64Image;
      if (user.photoURL != null) {
        base64Image = await _convertImageUrlToBase64(user.photoURL);
      }

      // Prepare base user data
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'photoBase64': base64Image ?? '',
        'emailVerified': user.emailVerified,
        'lastSignIn': FieldValue.serverTimestamp(),
        'providers': user.providerData.map((info) => info.providerId).toList(),
      };

      // Add initial credits and timestamps for new users
      if (isNewUser) {
        debugPrint("🎁 [Firestore] New user - assigning $_initialCredits initial credits");
        userData['credits'] = _initialCredits;
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['creditTransactions'] = [
          {
            'amount': _initialCredits,
            'balance': _initialCredits,
            'reason': 'initial_signup',
            'timestamp': DateTime.now().toIso8601String(),
          }
        ];
      } else {
        debugPrint("👋 [Firestore] Existing user - updating profile only");
      }

      debugPrint("💾 [Firestore] User data prepared:");
      debugPrint("   - Has base64 image: ${base64Image != null}");
      debugPrint("   - Providers: ${userData['providers']}");
      if (isNewUser) {
        debugPrint("   - Initial Credits: $_initialCredits");
      }

      // Save to Firestore (merge to update existing or create new)
      await docRef.set(userData, SetOptions(merge: true));

      debugPrint("✅ [Firestore] User data saved successfully");

      // ✨ SAVE TO SHARED PREFERENCES ✨
      debugPrint("💾 [SharedPreferences] Saving user data locally...");
      final savedLocally = await SharedPreferencesService.saveUserData(
        user,
        photoBase64: base64Image,
      );

      if (savedLocally) {
        debugPrint("✅ [SharedPreferences] User data saved locally");
      } else {
        debugPrint("⚠️ [SharedPreferences] Failed to save user data locally");
      }

      return true;

    } on FirebaseException catch (e) {
      debugPrint("❌ [Firestore] FirebaseException:");
      debugPrint("   - Code: ${e.code}");
      debugPrint("   - Message: ${e.message}");
      return false;

    } catch (e) {
      debugPrint("❌ [Firestore] Unexpected error: $e");
      return false;
    }
  }

  /// Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserFromFirestore(String uid) async {
    try {
      debugPrint("📖 [Firestore] Fetching user data for UID: $uid");

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        debugPrint("✅ [Firestore] User data found");
        final data = doc.data();
        debugPrint("   - Credits: ${data?['credits'] ?? 0}");
        return data;
      } else {
        debugPrint("⚠️ [Firestore] User data not found");
        return null;
      }

    } catch (e) {
      debugPrint("❌ [Firestore] Error fetching user: $e");
      return null;
    }
  }

  /// Update last sign-in time
  static Future<void> updateLastSignIn(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'lastSignIn': FieldValue.serverTimestamp()});

      debugPrint("✅ [Firestore] Last sign-in updated");

      // Also update in SharedPreferences
      await SharedPreferencesService.updateLastSignIn();

    } catch (e) {
      debugPrint("⚠️ [Firestore] Failed to update last sign-in: $e");
    }
  }

  /// Get user credits from Firestore
  static Future<int> getUserCredits(String uid) async {
    try {
      debugPrint("💰 [Firestore] Fetching credits for UID: $uid");

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        final credits = doc.data()?['credits'] ?? 0;
        debugPrint("✅ [Firestore] Credits found: $credits");
        return credits;
      } else {
        debugPrint("⚠️ [Firestore] User not found - returning 0 credits");
        return 0;
      }

    } catch (e) {
      debugPrint("❌ [Firestore] Error fetching credits: $e");
      return 0;
    }
  }

  /// Update user credits in Firestore
  static Future<bool> updateUserCredits(
      String uid,
      int newBalance, {
        String reason = 'update',
        int? change,
      }) async {
    try {
      debugPrint("💾 [Firestore] Updating credits for UID: $uid");
      debugPrint("   - New Balance: $newBalance");
      debugPrint("   - Reason: $reason");

      final userRef = _firestore.collection(_usersCollection).doc(uid);

      await userRef.update({
        'credits': newBalance,
        'lastCreditUpdate': FieldValue.serverTimestamp(),
        'creditTransactions': FieldValue.arrayUnion([
          {
            'amount': change ?? newBalance,
            'balance': newBalance,
            'reason': reason,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      debugPrint("✅ [Firestore] Credits updated successfully");
      return true;

    } catch (e) {
      debugPrint("❌ [Firestore] Error updating credits: $e");
      return false;
    }
  }

  /// Delete user data from Firestore
  static Future<bool> deleteUserFromFirestore(String uid) async {
    try {
      debugPrint("🗑️ [Firestore] Deleting user data for UID: $uid");

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();

      debugPrint("✅ [Firestore] User data deleted successfully");
      return true;

    } catch (e) {
      debugPrint("❌ [Firestore] Error deleting user: $e");
      return false;
    }
  }

  /// Stream user data changes (including credits)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserData(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots();
  }

  /// Get credit transaction history
  static Future<List<Map<String, dynamic>>> getCreditHistory(String uid) async {
    try {
      debugPrint("📜 [Firestore] Fetching credit history for UID: $uid");

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        final transactions = doc.data()?['creditTransactions'] as List<dynamic>? ?? [];
        debugPrint("✅ [Firestore] Found ${transactions.length} transactions");
        return transactions.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      debugPrint("❌ [Firestore] Error fetching credit history: $e");
      return [];
    }
  }
}
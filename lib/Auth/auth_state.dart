import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'UserFirestoreService.dart';

class AuthState with ChangeNotifier {
  bool _isUserSignedIn = false;
  User? _user;
  String? _lastError;
  Map<String, dynamic>? _firestoreUserData;

  // Callback for when user signs in (to trigger credit refresh)
  Function(String uid)? onUserSignedIn;

  AuthState() {
    debugPrint("🔐 [AuthState] Initializing...");

    // Initialize auth state
    _user = FirebaseAuth.instance.currentUser;
    _isUserSignedIn = _user != null;

    if (_user != null) {
      debugPrint("✅ [AuthState] User already signed in:");
      debugPrint("   - UID: ${_user!.uid}");
      debugPrint("   - Email: ${_user!.email ?? 'No email'}");
      debugPrint("   - Display Name: ${_user!.displayName ?? 'No name'}");
      debugPrint("   - Provider: ${_user!.providerData.map((e) => e.providerId).join(', ')}");

      // Load Firestore data for existing user
      _loadFirestoreData(_user!.uid);

      // Trigger credit refresh
      onUserSignedIn?.call(_user!.uid);
    } else {
      debugPrint("ℹ️ [AuthState] No user currently signed in");
    }

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen(
          (User? user) {
        debugPrint("🔄 [AuthState] Auth state changed:");

        if (user != null) {
          debugPrint("✅ [AuthState] User signed in:");
          debugPrint("   - UID: ${user.uid}");
          debugPrint("   - Email: ${user.email ?? 'No email'}");
          debugPrint("   - Display Name: ${user.displayName ?? 'No name'}");
          debugPrint("   - Provider: ${user.providerData.map((e) => e.providerId).join(', ')}");
          debugPrint("   - Email Verified: ${user.emailVerified}");

          // Update last sign-in time in Firestore
          UserFirestoreService.updateLastSignIn(user.uid);

          // Load Firestore data
          _loadFirestoreData(user.uid);

          // Trigger credit refresh
          onUserSignedIn?.call(user.uid);
        } else {
          debugPrint("ℹ️ [AuthState] User signed out");
          _firestoreUserData = null;
        }

        final wasSignedIn = _isUserSignedIn;
        _user = user;
        _isUserSignedIn = user != null;

        // Only notify if state actually changed
        if (wasSignedIn != _isUserSignedIn) {
          debugPrint("📢 [AuthState] Notifying listeners - Sign-in state changed: $wasSignedIn -> $_isUserSignedIn");
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint("❌ [AuthState] Auth state change error: $error");
        _lastError = error.toString();
        notifyListeners();
      },
    );
  }

  /// Load user data from Firestore
  Future<void> _loadFirestoreData(String uid) async {
    try {
      debugPrint("📖 [AuthState] Loading Firestore data for UID: $uid");
      _firestoreUserData = await UserFirestoreService.getUserFromFirestore(uid);

      if (_firestoreUserData != null) {
        debugPrint("✅ [AuthState] Firestore data loaded successfully");
        debugPrint("   - Has base64 image: ${_firestoreUserData!['photoBase64']?.isNotEmpty ?? false}");
        debugPrint("   - Credits: ${_firestoreUserData!['credits'] ?? 0}");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ [AuthState] Failed to load Firestore data: $e");
    }
  }

  bool get isUserSignedIn => _isUserSignedIn;
  User? get user => _user;
  String? get lastError => _lastError;
  Map<String, dynamic>? get firestoreUserData => _firestoreUserData;

  /// Get base64 encoded profile picture from Firestore
  String? get profilePictureBase64 {
    return _firestoreUserData?['photoBase64'];
  }

  /// Get display name from Firestore or Firebase Auth
  String get displayName {
    // Try Firestore first, then Firebase Auth, then fallback
    return _firestoreUserData?['displayName'] ??
        _user?.displayName ??
        _user?.email?.split('@')[0] ??
        'User';
  }

  /// Get email from Firestore or Firebase Auth
  String? get email {
    return _firestoreUserData?['email'] ?? _user?.email;
  }

  /// Get credits from Firestore
  int get credits {
    return _firestoreUserData?['credits'] ?? 0;
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void signOut() {
    debugPrint("🔓 [AuthState] Manual sign out called");
    _user = null;
    _isUserSignedIn = false;
    _firestoreUserData = null;
    notifyListeners();
  }

  // Helper method to get user display info
  String getUserDisplayName() {
    return displayName;
  }

  // Helper method to check if user is signed in with specific provider
  bool isSignedInWithProvider(String providerId) {
    if (_user == null) return false;
    return _user!.providerData.any((info) => info.providerId == providerId);
  }

  /// Refresh Firestore data manually
  Future<void> refreshFirestoreData() async {
    if (_user != null) {
      await _loadFirestoreData(_user!.uid);
    }
  }
}
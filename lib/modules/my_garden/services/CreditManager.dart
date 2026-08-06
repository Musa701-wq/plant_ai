import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditManager extends ChangeNotifier {
  static const String _creditKey = 'user_credits';
  static const String _firstLaunchKey = 'first_launch';
  static const String _lastSyncKey = 'last_credit_sync';
  static const int _initialCredits = 10;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _credits = 0;
  bool _isLoading = true;

  int get credits => _credits;
  bool get isLoading => _isLoading;

  /// Initialize credit manager - Fetch from Firestore
  Future<void> init() async {
    try {
      debugPrint("💳 [CreditManager] Initializing...");
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;

      if (user != null) {
        debugPrint("👤 [CreditManager] User logged in: ${user.uid}");
        // Fetch credits from Firestore
        await _fetchCreditsFromFirestore(user.uid);
      } else {
        debugPrint("⚠️ [CreditManager] No user logged in - using local storage");
        // Fallback to local storage if not logged in
        await _loadLocalCredits();
      }

      // Listen to auth state changes to refresh credits
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          debugPrint("🔄 [CreditManager] Auth state changed - refreshing credits");
          _fetchCreditsFromFirestore(user.uid);
        } else {
          debugPrint("🔄 [CreditManager] User signed out - resetting credits");
          _credits = 0;
          notifyListeners();
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Init error: $e");
      _credits = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch credits from Firestore
  Future<void> _fetchCreditsFromFirestore(String uid) async {
    try {
      debugPrint("📖 [CreditManager] Fetching credits from Firestore for UID: $uid");

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final firestoreCredits = data?['credits'] ?? 0;

        // Update UI immediately
        _credits = firestoreCredits;
        _isLoading = false;
        notifyListeners();

        debugPrint("✅ [CreditManager] Credits loaded from Firestore: $_credits");

        // Save to local storage for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_creditKey, _credits);
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      } else {
        debugPrint("🎁 [CreditManager] New user - initializing with $_initialCredits credits");
        // New user - give initial credits
        _credits = _initialCredits;
        await _updateFirestoreCredits(uid, _initialCredits, reason: 'initial_signup');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Error fetching from Firestore: $e");
      // Fallback to local storage
      await _loadLocalCredits();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load credits from local storage (fallback)
  Future<void> _loadLocalCredits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _credits = prefs.getInt(_creditKey) ?? 0;
      debugPrint("💰 [CreditManager] Loaded credits from local storage: $_credits");
    } catch (e) {
      debugPrint("❌ [CreditManager] Error loading local credits: $e");
      _credits = 0;
    }
  }

  /// Update credits in Firestore
  Future<bool> _updateFirestoreCredits(
      String uid,
      int newBalance, {
        String reason = 'update',
        int? change,
      }) async {
    try {
      debugPrint("💾 [CreditManager] Updating Firestore credits...");
      debugPrint("   - UID: $uid");
      debugPrint("   - New Balance: $newBalance");
      debugPrint("   - Reason: $reason");
      if (change != null) {
        debugPrint("   - Change: ${change > 0 ? '+' : ''}$change");
      }

      final userRef = _firestore.collection('users').doc(uid);

      // Update credits and transaction history
      await userRef.set({
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
      }, SetOptions(merge: true));

      debugPrint("✅ [CreditManager] Firestore updated successfully");

      // Also update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, newBalance);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Error updating Firestore: $e");
      return false;
    }
  }

  /// Add credits
  Future<bool> addCredits(int amount, {String reason = 'purchase'}) async {
    try {
      debugPrint("➕ [CreditManager] Adding $amount credits (reason: $reason)");

      final user = _auth.currentUser;
      final newBalance = _credits + amount;

      if (user != null) {
        // Update in Firestore
        final success = await _updateFirestoreCredits(
          user.uid,
          newBalance,
          reason: reason,
          change: amount,
        );

        if (!success) {
          debugPrint("⚠️ [CreditManager] Firestore update failed, updating locally only");
        }
      }

      // Update local state
      _credits = newBalance;

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, _credits);

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Add credits error: $e");
      return false;
    }
  }

  /// Deduct credits
  Future<bool> deductCredits(int amount, {String reason = 'usage'}) async {
    try {

      if (_credits < amount) {
        debugPrint("⚠️ [CreditManager] Insufficient credits. Need: $amount, Have: $_credits");
        return false;
      }

      debugPrint("➖ [CreditManager] Deducting $amount credits (reason: $reason)");

      final user = _auth.currentUser;
      final newBalance = _credits - amount;

      if (user != null) {
        // Update in Firestore
        final success = await _updateFirestoreCredits(
          user.uid,
          newBalance,
          reason: reason,
          change: -amount,
        );

        if (!success) {
          debugPrint("⚠️ [CreditManager] Firestore update failed, updating locally only");
        }
      }

      // Update local state
      _credits = newBalance;

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, _credits);

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Deduct credits error: $e");
      return false;
    }
  }



  /// Sync credits from Firestore (manual refresh)
  Future<void> syncCredits() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        debugPrint("🔄 [CreditManager] Syncing credits from Firestore...");
        await _fetchCreditsFromFirestore(user.uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Sync error: $e");
    }
  }

  /// Check if user has enough credits
  bool hasEnoughCredits(int required) {
    return _credits >= required;
  }



  /// Get initial credits amount
  static int get initialCredits => _initialCredits;

  /// Reset credits (for testing)
  Future<void> resetCredits() async {
    try {
      debugPrint("🔄 [CreditManager] Resetting credits");

      final user = _auth.currentUser;
      if (user != null) {
        await _updateFirestoreCredits(user.uid, 0, reason: 'reset');
      }

      _credits = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, 0);
      await prefs.remove(_lastSyncKey);

      notifyListeners();
      debugPrint("✅ [CreditManager] Credits reset successfully");
    } catch (e) {
      debugPrint("❌ [CreditManager] Reset error: $e");
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncTime = prefs.getString(_lastSyncKey);
      if (syncTime != null) {
        return DateTime.parse(syncTime);
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Error getting last sync time: $e");
    }
    return null;
  }
}
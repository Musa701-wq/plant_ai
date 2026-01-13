import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'UserFirestoreService.dart';

class GoogleAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google - Enhanced with Firestore + SharedPreferences
  static Future<User?> signInWithGoogle() async {
    try {
      debugPrint("🔵 [Google Sign-In] Starting sign-in process...");
      debugPrint("🔵 [Google Sign-In] Requesting Google account...");

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("⚠️ [Google Sign-In] User cancelled sign-in");
        return null;
      }

      debugPrint("✅ [Google Sign-In] Google account selected");
      debugPrint("   - User ID: ${googleUser.id}");
      debugPrint("   - Email: ${googleUser.email}");
      debugPrint("   - Display Name: ${googleUser.displayName ?? 'Not provided'}");
      debugPrint("   - Photo URL: ${googleUser.photoUrl ?? 'None'}");

      // Obtain the auth details from the request
      debugPrint("🔵 [Google Sign-In] Obtaining authentication details...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint("✅ [Google Sign-In] Authentication details received");
      debugPrint("   - Access Token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
      debugPrint("   - ID Token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("🔥 [Firebase] Signing in with Google credential...");
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        debugPrint("✅ [Google Sign-In] Firebase sign-in successful!");
        debugPrint("   - UID: ${userCredential.user!.uid}");
        debugPrint("   - Email: ${userCredential.user!.email ?? 'No email'}");
        debugPrint("   - Display Name: ${userCredential.user!.displayName ?? 'No name'}");
        debugPrint("   - Photo URL: ${userCredential.user!.photoURL ?? 'None'}");
        debugPrint("   - Email Verified: ${userCredential.user!.emailVerified}");
        debugPrint("   - Is New User: ${userCredential.additionalUserInfo?.isNewUser ?? false}");

        // ✨ SAVE USER DATA TO FIRESTORE + SHAREDPREFERENCES ✨
        debugPrint("💾 [Google Sign-In] Saving user data to Firestore + Local Storage...");

        final saved = await UserFirestoreService.saveUserToFirestore(userCredential.user!);

        if (saved) {
          debugPrint("✅ [Google Sign-In] User data saved successfully");
          debugPrint("   ✓ Firestore: Saved");
          debugPrint("   ✓ SharedPreferences: Saved");
          debugPrint("   ✓ Premium features: UNLOCKED");
        } else {
          debugPrint("⚠️ [Google Sign-In] Failed to save user data");
        }

        // Check provider data
        debugPrint("   - Providers:");
        for (var info in userCredential.user!.providerData) {
          debugPrint("     • ${info.providerId} (${info.email ?? 'No email'})");
        }

        // Check additional user info
        if (userCredential.additionalUserInfo != null) {
          debugPrint("   - Profile Info:");
          debugPrint("     • Is New User: ${userCredential.additionalUserInfo!.isNewUser}");
          debugPrint("     • Provider ID: ${userCredential.additionalUserInfo!.providerId}");

          if (userCredential.additionalUserInfo!.isNewUser) {
            debugPrint("🎉 [Google Sign-In] Welcome new user!");
          } else {
            debugPrint("👋 [Google Sign-In] Welcome back!");
          }
        }

        debugPrint("✅ [Google Sign-In] Sign-in process completed successfully");
        return userCredential.user;
      } else {
        debugPrint("⚠️ [Google Sign-In] User credential is null");
        return null;
      }

    } on FirebaseAuthException catch (e) {
      debugPrint("❌ [Google Sign-In] FirebaseAuthException:");
      debugPrint("   - Code: ${e.code}");
      debugPrint("   - Message: ${e.message}");

      switch (e.code) {
        case 'account-exists-with-different-credential':
          debugPrint("   → Account exists with different credential");
          debugPrint("   → User should sign in with their original provider");
          break;
        case 'invalid-credential':
          debugPrint("   → Invalid credential provided");
          break;
        case 'operation-not-allowed':
          debugPrint("   → Google Sign-In not enabled in Firebase Console");
          break;
        case 'user-disabled':
          debugPrint("   → User account has been disabled");
          break;
        case 'network-request-failed':
          debugPrint("   → Network request failed");
          break;
        default:
          debugPrint("   → Unhandled error code: ${e.code}");
      }

      rethrow;

    } catch (e, stackTrace) {
      debugPrint("❌ [Google Sign-In] Unexpected error:");
      debugPrint("   - Type: ${e.runtimeType}");
      debugPrint("   - Error: $e");
      debugPrint("   - Stack Trace: $stackTrace");
      return null;

    } finally {
      debugPrint("🔵 [Google Sign-In] Sign-in process completed");
      debugPrint("=" * 60);
    }
  }

  /// Google Sign-In with UI feedback (for use in widgets)
  static Future<bool> signInWithGoogleUI(BuildContext context) async {
    debugPrint("🔵 [Google Sign-In UI] Starting sign-in with UI feedback...");

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Signing in with Google...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final user = await signInWithGoogle();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (user != null) {
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Signed in as ${user.email ?? user.displayName ?? 'Google User'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        debugPrint("✅ [Google Sign-In UI] Sign-in successful with UI feedback");
        return true;
      } else {
        debugPrint("⚠️ [Google Sign-In UI] Sign-in returned null");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         const Row(
        //           children: [
        //             Icon(Icons.error_outline, color: Colors.white),
        //             SizedBox(width: 8),
        //             Text(
        //               'Sign-In Failed',
        //               style: TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 16,
        //               ),
        //             ),
        //           ],
        //         ),
        //         const SizedBox(height: 4),
        //         Text(
        //           _getFirebaseErrorMessage(e.code),
        //           style: const TextStyle(fontSize: 14),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.red,
        //     duration: const Duration(seconds: 4),
        //     behavior: SnackBarBehavior.floating,
        //   ),
        // );
      }

      debugPrint("❌ [Google Sign-In UI] Sign-in failed with UI feedback");
      return false;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show generic error
      if (context.mounted) {
        debugPrint("An unexpected error occurred: ${e.toString()}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Row(
        //       children: [
        //         const Icon(Icons.error_outline, color: Colors.white),
        //         const SizedBox(width: 12),
        //         Expanded(
        //           child: Text(
        //             'An unexpected error occurred: ${e.toString()}',
        //             style: const TextStyle(fontSize: 14),
        //           ),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.red,
        //     duration: const Duration(seconds: 4),
        //     behavior: SnackBarBehavior.floating,
        //   ),
        // );
      }

      debugPrint("❌ [Google Sign-In UI] Unexpected error with UI feedback");
      return false;
    }
  }

  /// Sign out from Google and Firebase
  static Future<void> signOut() async {
    try {
      debugPrint("🔵 [Google Sign-Out] Signing out...");

      // Sign out from Google
      await _googleSignIn.signOut();
      debugPrint("✅ [Google Sign-Out] Signed out from Google");

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      debugPrint("✅ [Google Sign-Out] Signed out from Firebase");

    } catch (e) {
      debugPrint("❌ [Google Sign-Out] Error signing out: $e");
      rethrow;
    }
  }

  /// Disconnect Google account (revokes access)
  static Future<void> disconnect() async {
    try {
      debugPrint("🔵 [Google Disconnect] Disconnecting Google account...");
      await _googleSignIn.disconnect();
      debugPrint("✅ [Google Disconnect] Google account disconnected");
    } catch (e) {
      debugPrint("❌ [Google Disconnect] Error disconnecting: $e");
      rethrow;
    }
  }

  /// Check if user is currently signed in with Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user (if any)
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Helper: Get user-friendly error messages for Firebase errors
  static String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'account-exists-with-different-credential':
        return 'This email is already associated with another sign-in method. Please use your original sign-in method.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid or has expired. Please try again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      default:
        return 'Sign-in failed. Please try again or contact support.';
    }
  }
}
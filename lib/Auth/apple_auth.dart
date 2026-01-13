import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'UserFirestoreService.dart';

class AppleAuth {
  /// Sign in with Apple - Enhanced with Firestore + SharedPreferences
  static Future<User?> signInWithApple() async {
    try {
      debugPrint("🍎 [Apple Sign-In] Starting sign-in process...");
      debugPrint("🍎 [Apple Sign-In] Requesting Apple ID credentials...");

      // Request Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint("✅ [Apple Sign-In] Apple credential received");
      debugPrint("   - User ID: ${credential.userIdentifier ?? 'None'}");
      debugPrint("   - Email: ${credential.email ?? 'Not provided'}");
      debugPrint("   - Given Name: ${credential.givenName ?? 'Not provided'}");
      debugPrint("   - Family Name: ${credential.familyName ?? 'Not provided'}");
      debugPrint("   - Authorization Code: ${credential.authorizationCode.isNotEmpty ? 'Present' : 'Missing'}");
      debugPrint("   - Identity Token: ${credential.identityToken != null ? 'Present' : 'Missing'}");

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      debugPrint("🔥 [Firebase] Signing in with Apple credential...");
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        debugPrint("✅ [Apple Sign-In] Firebase sign-in successful!");
        debugPrint("   - UID: ${userCredential.user!.uid}");
        debugPrint("   - Email: ${userCredential.user!.email ?? 'No email'}");
        debugPrint("   - Display Name: ${userCredential.user!.displayName ?? 'No name'}");
        debugPrint("   - Photo URL: ${userCredential.user!.photoURL ?? 'None'}");
        debugPrint("   - Email Verified: ${userCredential.user!.emailVerified}");
        debugPrint("   - Is New User: ${userCredential.additionalUserInfo?.isNewUser ?? false}");

        // Update display name if provided by Apple (only for new users)
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          final fullName = _buildFullName(credential.givenName, credential.familyName);
          if (fullName != null && fullName.isNotEmpty) {
            debugPrint("📝 [Apple Sign-In] Updating display name: $fullName");
            try {
              await userCredential.user!.updateDisplayName(fullName);
              await userCredential.user!.reload();
              final updatedUser = FirebaseAuth.instance.currentUser;
              debugPrint("✅ [Apple Sign-In] Display name updated successfully");

              // Use updated user for saving
              if (updatedUser != null) {
                debugPrint("   - New Display Name: ${updatedUser.displayName}");
              }
            } catch (e) {
              debugPrint("⚠️ [Apple Sign-In] Failed to update display name: $e");
            }
          } else {
            debugPrint("ℹ️ [Apple Sign-In] No name provided by Apple");
          }
        }

        // ✨ SAVE USER DATA TO FIRESTORE + SHAREDPREFERENCES ✨
        debugPrint("💾 [Apple Sign-In] Saving user data to Firestore + Local Storage...");

        // Get the latest user object (in case display name was updated)
        final currentUser = FirebaseAuth.instance.currentUser;
        final userToSave = currentUser ?? userCredential.user!;

        final saved = await UserFirestoreService.saveUserToFirestore(userToSave);

        if (saved) {
          debugPrint("✅ [Apple Sign-In] User data saved successfully");
          debugPrint("   ✓ Firestore: Saved");
          debugPrint("   ✓ SharedPreferences: Saved");
          debugPrint("   ✓ Premium features: UNLOCKED");
        } else {
          debugPrint("⚠️ [Apple Sign-In] Failed to save user data");
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
            debugPrint("🎉 [Apple Sign-In] Welcome new user!");
          } else {
            debugPrint("👋 [Apple Sign-In] Welcome back!");
          }
        }

        debugPrint("✅ [Apple Sign-In] Sign-in process completed successfully");
        return userCredential.user;
      } else {
        debugPrint("⚠️ [Apple Sign-In] User credential is null");
        return null;
      }

    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint("❌ [Apple Sign-In] SignInWithAppleAuthorizationException:");
      debugPrint("   - Code: ${e.code}");
      debugPrint("   - Message: ${e.message}");

      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          debugPrint("   → User cancelled sign-in");
          break;
        case AuthorizationErrorCode.failed:
          debugPrint("   → Authorization failed");
          break;
        case AuthorizationErrorCode.invalidResponse:
          debugPrint("   → Invalid response from Apple");
          break;
        case AuthorizationErrorCode.notHandled:
          debugPrint("   → Request not handled");
          break;
        case AuthorizationErrorCode.unknown:
          debugPrint("   → Unknown error occurred");
          break;
        case AuthorizationErrorCode.notInteractive:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.credentialExport:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.credentialImport:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.matchedExcludedCredential:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      return null;

    } on FirebaseAuthException catch (e) {
      debugPrint("❌ [Apple Sign-In] FirebaseAuthException:");
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
          debugPrint("   → Apple Sign-In not enabled in Firebase Console");
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
      debugPrint("❌ [Apple Sign-In] Unexpected error:");
      debugPrint("   - Type: ${e.runtimeType}");
      debugPrint("   - Error: $e");
      debugPrint("   - Stack Trace: $stackTrace");
      return null;

    } finally {
      debugPrint("🍎 [Apple Sign-In] Sign-in process completed");
      debugPrint("=" * 60);
    }
  }

  /// Apple Sign-In with UI feedback (for use in widgets)
  static Future<bool> signInWithAppleUI(BuildContext context) async {
    debugPrint("🍎 [Apple Sign-In UI] Starting sign-in with UI feedback...");

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
                    'Signing in with Apple...',
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
      final user = await signInWithApple();

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
                          'Signed in as ${user.email ?? user.displayName ?? 'Apple User'}',
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

        debugPrint("✅ [Apple Sign-In UI] Sign-in successful with UI feedback");
        return true;
      } else {
        debugPrint("⚠️ [Apple Sign-In UI] Sign-in returned null");
        return false;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Don't show error for user cancellation
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint("ℹ️ [Apple Sign-In UI] User cancelled sign-in");
        return false;
      }

      // Show error message
      if (context.mounted) {
        debugPrint("Sign-In Failed $_getAppleErrorMessage(e.code)");
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
        //           _getAppleErrorMessage(e.code),
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

      debugPrint("❌ [Apple Sign-In UI] Sign-in failed with UI feedback");
      return false;
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        debugPrint("Sign-In Failed $_getAppleErrorMessage(e.code)");
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
        //           _getAppleErrorMessage(e.code),
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

      debugPrint("❌ [Apple Sign-In UI] Sign-in failed with UI feedback");
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

      debugPrint("❌ [Apple Sign-In UI] Unexpected error with UI feedback");
      return false;
    }
  }

  /// Sign out from Firebase (Apple doesn't need separate sign out)
  static Future<void> signOut() async {
    try {
      debugPrint("🍎 [Apple Sign-Out] Signing out from Firebase...");
      await FirebaseAuth.instance.signOut();
      debugPrint("✅ [Apple Sign-Out] User signed out from Firebase");
    } catch (e) {
      debugPrint("❌ [Apple Sign-Out] Error signing out: $e");
      rethrow;
    }
  }

  /// Helper: Build full name from given and family names
  static String? _buildFullName(String? givenName, String? familyName) {
    if (givenName == null && familyName == null) return null;

    final parts = <String>[];
    if (givenName != null && givenName.isNotEmpty) parts.add(givenName);
    if (familyName != null && familyName.isNotEmpty) parts.add(familyName);

    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Helper: Get user-friendly error messages for Apple errors
  static String _getAppleErrorMessage(AuthorizationErrorCode code) {
    switch (code) {
      case AuthorizationErrorCode.canceled:
        return 'Sign-in was cancelled.';
      case AuthorizationErrorCode.failed:
        return 'Sign-in failed. Please try again.';
      case AuthorizationErrorCode.invalidResponse:
        return 'Invalid response from Apple. Please try again.';
      case AuthorizationErrorCode.notHandled:
        return 'Sign-in request was not handled. Please try again.';
      case AuthorizationErrorCode.unknown:
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  /// Helper: Get user-friendly error messages for Firebase errors
  static String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'account-exists-with-different-credential':
        return 'This email is already associated with another sign-in method. Please use your original sign-in method.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid or has expired. Please try again.';
      case 'operation-not-allowed':
        return 'Apple sign-in is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Sign-in failed. Please try again or contact support.';
    }
  }
}
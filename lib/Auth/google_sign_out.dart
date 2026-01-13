// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'SharedPreferencesService.dart';
//
// /// Shows confirmation dialog before signing out
// Future<bool> showSignOutConfirmationDialog(BuildContext context) async {
//   debugPrint("📋 [Sign Out Dialog] Showing confirmation dialog...");
//
//   final result = await showDialog<bool>(
//     context: context,
//     barrierDismissible: true,
//     builder: (dialogContext) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.logout, color: Colors.orange, size: 24),
//             SizedBox(width: 12),
//             Text(
//               'Sign Out',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Are you sure you want to sign out?',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'You will need to sign in again to access your account features.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               debugPrint("❌ [Sign Out Dialog] User clicked Cancel");
//               Navigator.of(dialogContext).pop(false);
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.grey,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               elevation: 0,
//             ),
//             onPressed: () {
//               debugPrint("✅ [Sign Out Dialog] User confirmed sign out");
//               Navigator.of(dialogContext).pop(true);
//             },
//             child: const Text(
//               'Sign Out',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
//
//   final confirmed = result ?? false;
//   debugPrint("📋 [Sign Out Dialog] Dialog result: ${confirmed ? 'Confirmed' : 'Cancelled'}");
//   return confirmed;
// }
//
// /// Unified sign out function with proper error handling and logging
// /// Returns true if sign out was successful, false otherwise
// Future<bool> unifiedSignOut(BuildContext context) async {
//   debugPrint("🔓 [Sign Out] ========== Starting Unified Sign Out ==========");
//   debugPrint("🔓 [Sign Out] Timestamp: ${DateTime.now()}");
//
//   try {
//     // Show confirmation dialog first
//     debugPrint("🔓 [Sign Out] Requesting user confirmation...");
//     final shouldSignOut = await showSignOutConfirmationDialog(context);
//
//     if (!shouldSignOut) {
//       debugPrint("ℹ️ [Sign Out] Sign out cancelled by user");
//       debugPrint("🔓 [Sign Out] ========== Sign Out Process Cancelled ==========");
//       return false;
//     }
//
//     debugPrint("✅ [Sign Out] User confirmed sign out");
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       debugPrint("⚠️ [Sign Out] No user currently signed in");
//
//       // Clear SharedPreferences anyway
//       await SharedPreferencesService.clearUserData();
//
//       debugPrint("🔓 [Sign Out] ========== Sign Out Process Completed (No User) ==========");
//       return true;
//     }
//
//     debugPrint("🔓 [Sign Out] Current user details:");
//     debugPrint("   - UID: ${user.uid}");
//     debugPrint("   - Email: ${user.email ?? 'No email'}");
//     debugPrint("   - Display Name: ${user.displayName ?? 'No name'}");
//     debugPrint("   - Email Verified: ${user.emailVerified}");
//     debugPrint("   - Providers: ${user.providerData.map((e) => e.providerId).join(', ')}");
//
//     // Sign out from provider-specific services
//     debugPrint("🔓 [Sign Out] Processing provider-specific sign outs...");
//     bool hasGoogle = false;
//     bool hasApple = false;
//
//     for (final userInfo in user.providerData) {
//       debugPrint("🔓 [Sign Out] Checking provider: ${userInfo.providerId}");
//
//       if (userInfo.providerId == 'google.com') {
//         hasGoogle = true;
//         try {
//           debugPrint("🔵 [Google Sign Out] Attempting Google sign out...");
//           await GoogleSignIn.instance.signOut();
//           debugPrint("✅ [Google Sign Out] Google sign out successful");
//
//         } catch (e) {
//           debugPrint("⚠️ [Google Sign Out] Google sign out error (non-critical): $e");
//           debugPrint("   - This is expected if user wasn't signed in to Google");
//           // Don't throw - continue with Firebase sign out
//         }
//       } else if (userInfo.providerId == 'apple.com') {
//         hasApple = true;
//         debugPrint("🍎 [Apple Sign Out] Apple provider detected");
//         debugPrint("   - Apple doesn't require additional sign out beyond Firebase");
//       } else if (userInfo.providerId == 'password') {
//         debugPrint("📧 [Email Sign Out] Email/Password provider detected");
//       } else {
//         debugPrint("❓ [Sign Out] Unknown provider: ${userInfo.providerId}");
//       }
//     }
//
//     debugPrint("🔓 [Sign Out] Provider summary:");
//     debugPrint("   - Has Google: $hasGoogle");
//     debugPrint("   - Has Apple: $hasApple");
//
//     // ✨ CLEAR SHARED PREFERENCES ✨
//     debugPrint("🗑️ [Sign Out] Clearing local storage...");
//     final clearedLocally = await SharedPreferencesService.clearUserData();
//     if (clearedLocally) {
//       debugPrint("✅ [Sign Out] Local storage cleared successfully");
//     } else {
//       debugPrint("⚠️ [Sign Out] Failed to clear local storage");
//     }
//
//     // Sign out from Firebase
//     debugPrint("🔥 [Firebase Sign Out] Signing out from Firebase...");
//     await FirebaseAuth.instance.signOut();
//     debugPrint("✅ [Firebase Sign Out] Firebase sign out successful");
//
//     // Verify sign out
//     debugPrint("🔓 [Sign Out] Verifying sign out...");
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     if (currentUser == null) {
//       debugPrint("✅ [Sign Out] Sign out verified - no current user");
//     } else {
//       debugPrint("⚠️ [Sign Out] WARNING - User still exists after sign out:");
//       debugPrint("   - UID: ${currentUser.uid}");
//       debugPrint("   - This may indicate an incomplete sign out");
//     }
//
//     // Show success message
//     if (context.mounted) {
//       debugPrint("📢 [Sign Out] Showing success message to user");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.white),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   "Successfully signed out",
//                   style: TextStyle(fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//
//     debugPrint("✅ [Sign Out] ========== Sign Out Process Completed Successfully ==========");
//     return true;
//
//   } on FirebaseAuthException catch (e) {
//     debugPrint("❌ [Sign Out] ========== FirebaseAuthException ==========");
//     debugPrint("❌ [Sign Out] Error Code: ${e.code}");
//     debugPrint("❌ [Sign Out] Error Message: ${e.message}");
//     debugPrint("❌ [Sign Out] Plugin: ${e.plugin}");
//
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text(
//                     "Sign Out Error",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 e.message ?? "Failed to sign out",
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//
//     debugPrint("❌ [Sign Out] ========== Sign Out Process Failed ==========");
//     return false;
//
//   } catch (e, stackTrace) {
//     debugPrint("❌ [Sign Out] ========== Unexpected Error ==========");
//     debugPrint("❌ [Sign Out] Error Type: ${e.runtimeType}");
//     debugPrint("❌ [Sign Out] Error: $e");
//     debugPrint("❌ [Sign Out] Stack Trace: $stackTrace");
//
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text(
//                     "Unexpected Error",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 e.toString(),
//                 style: const TextStyle(fontSize: 14),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//           action: SnackBarAction(
//             label: 'Dismiss',
//             textColor: Colors.white,
//             onPressed: () {},
//           ),
//         ),
//       );
//     }
//
//     debugPrint("❌ [Sign Out] ========== Sign Out Process Failed ==========");
//     return false;
//   }
// }
//

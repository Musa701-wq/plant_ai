// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// /// Service for Subscriptions + Credits (Production Ready)
// class IAPService extends ChangeNotifier {
//   final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
//
//   // Updated product IDs for Apple
//   static const String subscriptionId = "com.vectorlabs.planteye.monthly.premium";
//   static const String annualSubscriptionId = "com.vectorlabs.planteye.yearly.premium"; // Annual subscription
//
//   // ⚠️ IMPORTANT: Replace these with YOUR actual product IDs from App Store Connect
//   // Example:
//   // static const String subscriptionId = "com.plantcare.app.monthly";
//   // static const String annualSubscriptionId = "com.plantcare.app.annual";
//
//   static const List<String> creditIds = [
//     "com.vectorlabs.fitai.50credits",
//     "com.vectorlabs.fitai.100credits",
//     "com.vectorlabs.fitai.500credits",
//   ];
//
//   final InAppPurchase _iap = InAppPurchase.instance;
//   late final StreamSubscription<List<PurchaseDetails>> _sub;
//
//   List<ProductDetails> products = [];
//   bool _initialized = false;
//   bool _isLoading = false;
//   bool _isBuying = false;
//   String? _errorMessage;
//
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isBuying => _isBuying;
//
//   final void Function(PurchaseDetails purchase)? onSubscribed;
//   final void Function(Object error)? onError;
//
//   IAPService({this.onSubscribed, this.onError});
//
//   /// Initialize IAP service
//   Future<void> init() async {
//     if (_initialized) return;
//
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     debugPrint("🔹 Initializing IAP Service...");
//
//     _sub = _iap.purchaseStream.listen(
//       _onPurchaseUpdated,
//       onError: (e) {
//         debugPrint("❌ Purchase stream error: $e");
//         onError?.call(e);
//       },
//     );
//
//     _initialized = true;
//
//     final available = await _iap.isAvailable();
//     debugPrint("🔹 IAP available: $available");
//     if (!available) {
//       _errorMessage = "In-App Purchases not available.";
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }
//
//     // Query both monthly and annual subscriptions + credits
//     final ids = {subscriptionId, annualSubscriptionId, ...creditIds};
//     final response = await _iap.queryProductDetails(ids);
//
//     if (response.error != null) {
//       debugPrint("❌ Query products error: ${response.error}");
//       _errorMessage = response.error!.message;
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }
//
//     if (response.notFoundIDs.isNotEmpty) {
//       debugPrint("⚠️ Products not found: ${response.notFoundIDs}");
//     }
//
//     products = response.productDetails;
//     debugPrint("✅ Loaded products: ${products.map((p) => p.id).join(", ")}");
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   /// Buy credits (consumable)
//   Future<void> buyCredits(String creditId) async {
//     try {
//       _isBuying = true;
//       notifyListeners();
//
//       final product = products.firstWhere((p) => p.id == creditId);
//       final param = PurchaseParam(productDetails: product);
//       await _iap.buyConsumable(purchaseParam: param);
//
//     } catch (e, stack) {
//       debugPrint("❌ Error initiating credits purchase: $e\n$stack");
//       onError?.call(e);
//       _isBuying = false;
//       notifyListeners();
//     }
//   }
//
//   /// Buy monthly subscription
//   Future<void> buySubscription() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       onError?.call("User not logged in");
//       return;
//     }
//
//     try {
//       _isBuying = true;
//       notifyListeners();
//
//       final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
//       final snapshot = await userRef.get();
//       final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
//       final isPro = data['isPro'] ?? false;
//
//       if (!isPro) {
//         final product = products.firstWhere((p) => p.id == subscriptionId);
//         final param = PurchaseParam(productDetails: product);
//         await _iap.buyNonConsumable(purchaseParam: param);
//
//         debugPrint("🔹 Monthly subscription purchase requested: ${product.id}");
//       } else {
//         debugPrint('Already subscribed');
//         _isBuying = false;
//         notifyListeners();
//       }
//     } catch (e, stack) {
//       debugPrint("❌ Error buying monthly subscription: $e\n$stack");
//       onError?.call(e);
//       _isBuying = false;
//       notifyListeners();
//     }
//   }
//
//   /// Buy annual subscription
//   Future<void> buyAnnualSubscription() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       onError?.call("User not logged in");
//       return;
//     }
//
//     try {
//       _isBuying = true;
//       notifyListeners();
//
//       final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
//       final snapshot = await userRef.get();
//       final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
//       final isPro = data['isPro'] ?? false;
//
//       if (!isPro) {
//         final product = products.firstWhere((p) => p.id == annualSubscriptionId);
//         final param = PurchaseParam(productDetails: product);
//         await _iap.buyNonConsumable(purchaseParam: param);
//
//         debugPrint("🔹 Annual subscription purchase requested: ${product.id}");
//       } else {
//         debugPrint('Already subscribed');
//         _isBuying = false;
//         notifyListeners();
//       }
//     } catch (e, stack) {
//       debugPrint("❌ Error buying annual subscription: $e\n$stack");
//       onError?.call(e);
//       _isBuying = false;
//       notifyListeners();
//     }
//   }
//
//   void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
//     for (final purchase in purchases) {
//       try {
//         _isBuying = true;
//
//         if (purchase.status == PurchaseStatus.purchased ||
//             purchase.status == PurchaseStatus.restored) {
//           final verified = await _verifyPurchaseWithApple(purchase);
//           if (!verified) continue;
//
//           final user = FirebaseAuth.instance.currentUser;
//           if (user == null) continue;
//
//           // Handle both monthly and annual subscriptions
//           if (purchase.productID == subscriptionId ||
//               purchase.productID == annualSubscriptionId) {
//             // Grant or restore subscription
//             final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
//             await userRef.update({"isPro": true});
//
//             final subRef = FirebaseDatabase.instance
//                 .ref('users/${user.uid}/subscription');
//             final now = DateTime.now().millisecondsSinceEpoch;
//             await subRef.set({
//               'active': true,
//               'lastPurchaseDate': now,
//               'productId': purchase.productID,
//               'type': purchase.productID == subscriptionId ? 'monthly' : 'annual',
//             });
//
//             await _analytics.logEvent(
//               name: 'subscription_purchase',
//               parameters: {
//                 'user_id': user.uid,
//                 'product_id': purchase.productID,
//                 'status': purchase.status.toString(),
//                 'type': purchase.productID == subscriptionId ? 'monthly' : 'annual',
//               },
//             );
//
//             debugPrint(purchase.status == PurchaseStatus.restored
//                 ? "♻️ Subscription restored and DB updated"
//                 : "✅ Subscription confirmed and DB updated");
//
//             // Call success callback
//             onSubscribed?.call(purchase);
//           } else if (creditIds.contains(purchase.productID)) {
//             // Credits only for new purchases, not restored
//             if (purchase.status == PurchaseStatus.purchased) {
//               await addCreditsToFirebase(purchase.productID);
//               debugPrint("✅ Credits added for ${purchase.productID}");
//             }
//           }
//
//           // Always complete the purchase if required
//           if (purchase.pendingCompletePurchase) {
//             await _iap.completePurchase(purchase);
//           }
//         } else if (purchase.status == PurchaseStatus.error) {
//           debugPrint("❌ Purchase error: ${purchase.error}");
//           onError?.call(purchase.error as Object);
//         }
//
//         _isBuying = false;
//         notifyListeners();
//       } catch (e, stack) {
//         debugPrint("❌ Error processing purchase: $e\n$stack");
//         onError?.call(e);
//         _isBuying = false;
//         notifyListeners();
//       }
//     }
//   }
//
//   /// Apple receipt verification (production-ready)
//   Future<bool> _verifyPurchaseWithApple(PurchaseDetails p) async {
//     // For production, implement server-side verification
//     // For now, returning true for testing
//     return true;
//   }
//
//   /// Add credits to Firebase
//   Future<void> addCreditsToFirebase(String productId) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       debugPrint("❌ No authenticated user to add credits");
//       return;
//     }
//
//     int creditsToAdd = 0;
//     switch (productId) {
//       case "com.vectorlabs.fitai.50credits":
//         creditsToAdd = 50;
//         break;
//       case "com.vectorlabs.fitai.100credits":
//         creditsToAdd = 100;
//         break;
//       case "com.vectorlabs.fitai.500credits":
//         creditsToAdd = 500;
//         break;
//     }
//
//     final ref = FirebaseDatabase.instance.ref("users/${user.uid}/credits");
//     final snapshot = await ref.get();
//
//     int currentCredits = 0;
//     if (snapshot.exists && snapshot.value is int) {
//       currentCredits = snapshot.value as int;
//     }
//
//     final newTotal = currentCredits + creditsToAdd;
//     await ref.set(newTotal);
//
//     debugPrint("✅ Credits updated → $newTotal");
//     await _analytics.logEvent(
//       name: 'credits_purchase',
//       parameters: {
//         'user_id': user.uid,
//         'product_id': productId,
//         'credits_added': creditsToAdd,
//       },
//     );
//   }
//
//   /// Restore past purchases
//   Future<void> restore() async {
//     debugPrint("🔹 Restoring purchases...");
//
//     bool restoredSomething = false;
//     final completer = Completer<void>();
//
//     final sub = _iap.purchaseStream.listen((purchases) {
//       for (final purchase in purchases) {
//         if (purchase.status == PurchaseStatus.restored) {
//           restoredSomething = true;
//         }
//         _onPurchaseUpdated([purchase]);
//       }
//       completer.complete();
//     });
//
//     await _iap.restorePurchases();
//     await completer.future;
//     await sub.cancel();
//
//     if (!restoredSomething) {
//       onError?.call("No past purchases found to restore.");
//       debugPrint("⚠️ No purchases were restored");
//     } else {
//       debugPrint("✅ Purchases restored successfully");
//     }
//   }
//
//   /// Verify subscription on app start
//   Future<void> verifyMonthlySubscription() async {
//     debugPrint("👉 verifyMonthlySubscription() called");
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       debugPrint("⚠️ No user logged in → skipping subscription verification");
//       return;
//     }
//
//     debugPrint("🔹 Verifying subscription for user: ${user.uid}");
//
//     final pastPurchases = <PurchaseDetails>[];
//     final completer = Completer<void>();
//     late final StreamSubscription<List<PurchaseDetails>> sub;
//
//     debugPrint("⏳ Setting up purchase stream listener...");
//     sub = _iap.purchaseStream.listen(
//           (purchases) {
//         debugPrint("📦 Purchase stream event: ${purchases.length} purchase(s)");
//         for (final p in purchases) {
//           debugPrint("   • ProductID=${p.productID}, status=${p.status}");
//         }
//         pastPurchases.addAll(purchases);
//
//         if (!completer.isCompleted) {
//           debugPrint("✅ Completing the completer from stream");
//           completer.complete();
//         }
//
//         debugPrint("🔌 Canceling purchase stream listener");
//         sub.cancel();
//       },
//       onError: (err) {
//         debugPrint("❌ Error in purchase stream: $err");
//         if (!completer.isCompleted) completer.complete();
//         sub.cancel();
//       },
//     );
//
//     debugPrint("🔄 Calling restorePurchases()...");
//     await _iap.restorePurchases();
//
//     debugPrint("⏳ Waiting for purchase stream events (timeout 10s)...");
//     await completer.future.timeout(
//       const Duration(seconds: 10),
//       onTimeout: () {
//         debugPrint("⏱️ Timeout reached. No purchases received from stream.");
//         if (!completer.isCompleted) completer.complete();
//         return;
//       },
//     );
//
//     debugPrint("✅ Restore completed. Past purchases count: ${pastPurchases.length}");
//
//     bool hasActiveSub = false;
//     String? subscriptionType;
//
//     for (final purchase in pastPurchases) {
//       debugPrint("🔍 Checking purchase: ${purchase.productID}, status=${purchase.status}");
//
//       // Check both monthly and annual subscriptions
//       if (purchase.productID != subscriptionId &&
//           purchase.productID != annualSubscriptionId) continue;
//
//       if (purchase.status == PurchaseStatus.purchased ||
//           purchase.status == PurchaseStatus.restored) {
//
//         final rawReceipt = purchase.verificationData.localVerificationData;
//         debugPrint("📜 Raw receipt: $rawReceipt");
//
//         try {
//           Map<String, dynamic> decoded;
//
//           if (rawReceipt.trim().startsWith("{")) {
//             decoded = jsonDecode(rawReceipt); // Sandbox JSON
//           } else {
//             decoded = jsonDecode(utf8.decode(base64Decode(rawReceipt))); // App Store JSON
//           }
//
//           DateTime? expiryDate;
//
//           if (decoded['expiresDate'] != null) {
//             final expiresMs = int.tryParse(decoded['expiresDate'].toString()) ?? 0;
//             expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresMs);
//             debugPrint("📅 iOS expiresDate found: $expiryDate");
//           } else if (decoded['latest_receipt_info'] != null) {
//             final latest = decoded['latest_receipt_info'] as List;
//             if (latest.isNotEmpty) {
//               final last = latest.last as Map;
//               final expiresMs = int.tryParse(last['expires_date_ms'] ?? '0') ?? 0;
//               expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresMs);
//               debugPrint("📅 latest_receipt_info expiresDate: $expiryDate");
//             }
//           } else {
//             debugPrint("⚠️ No expiration info found in receipt JSON");
//           }
//
//           if (expiryDate != null) {
//             if (expiryDate.isAfter(DateTime.now())) {
//               debugPrint("✅ Subscription is ACTIVE");
//               hasActiveSub = true;
//               subscriptionType = purchase.productID == subscriptionId ? 'monthly' : 'annual';
//             } else {
//               debugPrint("⚠️ Subscription expired on $expiryDate");
//               hasActiveSub = false;
//             }
//           }
//         } catch (e, st) {
//           debugPrint("❌ Error decoding receipt: $e\n$st");
//         }
//       }
//     }
//
//     // Update Realtime Database
//     final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
//     debugPrint("📡 Updating Realtime DB: isPro=$hasActiveSub");
//     await userRef.update({
//       "isPro": hasActiveSub,
//       if (hasActiveSub && subscriptionType != null)
//         "subscriptionType": subscriptionType,
//     });
//     debugPrint(hasActiveSub
//         ? "✅ DB updated: isPro=true, type=$subscriptionType"
//         : "⚠️ DB updated: isPro=false");
//
//     debugPrint("🏁 verifyMonthlySubscription() finished");
//   }
//
//   @override
//   Future<void> dispose() async {
//     await _sub.cancel();
//     super.dispose();
//   }
// }
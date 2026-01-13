import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'CreditManager.dart';

 /// ya bilkul thk ha aur jo last wala ha wo improvment ha lakin usy check karna ka purchase aur restore thk kaam kar raha ka ni
class IAPManager {
  static final IAPManager _instance = IAPManager._internal();
  factory IAPManager() => _instance;
  IAPManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;
  CreditManager? _creditManager;

  // Track restored purchases
  final Set<String> _processedTransactionIds = {};
  Completer<RestoreResult>? _restoreCompleter;

  bool get isAvailable => _available;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  /// Product IDs - REPLACE WITH YOUR ACTUAL APP STORE PRODUCT IDs
  static const Map<String, int> productCredits = {
    'com.vectorlabs.planteye.starter.pack': 250,
    'com.vectorlabs.planteye.basic.pack': 1000,
    'com.vectorlabs.planteye.pro.pack': 2500,
    'com.vectorlabs.planteye.enterprise.pack': 5000,
  };

  static const Set<String> _productIds = {
    'com.vectorlabs.planteye.starter.pack',
    'com.vectorlabs.planteye.basic.pack',
    'com.vectorlabs.planteye.pro.pack',
    'com.vectorlabs.planteye.enterprise.pack',
  };

  /// Initialize IAP
  Future<void> init(CreditManager creditManager) async {
    try {
      debugPrint("🛒 [IAP] Initializing In-App Purchase...");

      _creditManager = creditManager;

      // Check availability first
      _available = await _iap.isAvailable();

      if (!_available) {
        debugPrint("⚠️ [IAP] In-App Purchase not available");
        return;
      }

      debugPrint("✅ [IAP] In-App Purchase is available");

      // Set up purchase stream BEFORE anything else
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
            (purchases) => _handlePurchaseUpdates(purchases, creditManager),
        onDone: () {
          debugPrint("🔚 [IAP] Purchase stream closed");
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint("❌ [IAP] Stream error: $error");
        },
      );

      // Load products
      await loadProducts();

      // Handle pending purchases on iOS
      if (Platform.isIOS) {
        await _handlePendingIOSTransactions();
      }

      debugPrint("🎉 [IAP] Initialization complete");
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Init error: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  /// Handle pending iOS transactions
  Future<void> _handlePendingIOSTransactions() async {
    try {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      debugPrint("🔍 [IAP] Found ${transactions.length} pending iOS transactions");

      for (var transaction in transactions) {
        debugPrint("   - Transaction: ${transaction.payment.productIdentifier} - State: ${transaction.transactionState}");

        final transactionId = transaction.transactionIdentifier ?? '';

        // Skip if already processed
        if (transactionId.isNotEmpty && _processedTransactionIds.contains(transactionId)) {
          debugPrint("⏭️ [IAP] Transaction already processed, finishing...");
          await paymentWrapper.finishTransaction(transaction);
          continue;
        }

        // Only finish completed or restored transactions
        if (transaction.transactionState == SKPaymentTransactionStateWrapper.purchased ||
            transaction.transactionState == SKPaymentTransactionStateWrapper.restored) {

          // Award credits if not already awarded
          if (_creditManager != null && transaction.payment.productIdentifier.isNotEmpty) {
            final credits = productCredits[transaction.payment.productIdentifier] ?? 0;
            if (credits > 0) {
              await _creditManager!.addCredits(
                credits,
                reason: 'iap_pending_${transaction.payment.productIdentifier}',
              );
              debugPrint("✅ [IAP] Awarded $credits credits for pending transaction");

              // Mark as processed
              if (transactionId.isNotEmpty) {
                _processedTransactionIds.add(transactionId);
              }
            }
          }

          await paymentWrapper.finishTransaction(transaction);
          debugPrint("✅ [IAP] Finished pending transaction: ${transaction.payment.productIdentifier}");
        } else if (transaction.transactionState == SKPaymentTransactionStateWrapper.failed) {
          await paymentWrapper.finishTransaction(transaction);
          debugPrint("🗑️ [IAP] Cleaned up failed transaction");
        }
      }
    } catch (e) {
      debugPrint("❌ [IAP] Error handling pending transactions: $e");
    }
  }

  /// Load products from App Store
  Future<void> loadProducts() async {
    try {
      debugPrint("📦 [IAP] Loading products...");
      _isLoading = true;

      final response = await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        debugPrint("❌ [IAP] Load products error: ${response.error}");
        _isLoading = false;
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("⚠️ [IAP] Products not found: ${response.notFoundIDs}");
      }

      _products = response.productDetails;
      _isLoading = false;

      debugPrint("✅ [IAP] Loaded ${_products.length} products");
      for (var product in _products) {
        debugPrint("   - ${product.id}: ${product.price}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Load products error: $e");
      debugPrint("Stack trace: $stackTrace");
      _isLoading = false;
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      debugPrint("💳 [IAP] Initiating purchase: ${product.id}");

      // Verify purchase stream is active
      if (_subscription == null || _subscription!.isPaused) {
        debugPrint("⚠️ [IAP] Purchase stream not active, reinitializing...");
        if (_creditManager != null) {
          await init(_creditManager!);
        }
      }

      final purchaseParam = PurchaseParam(productDetails: product);

      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      debugPrint("💳 [IAP] Purchase initiated: $result");
      return result;
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Purchase error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  /// Restore purchases with proper completion handling
  Future<RestoreResult> restorePurchases(CreditManager creditManager) async {
    try {
      debugPrint("🔄 [IAP] Restoring purchases...");

      // Ensure purchase stream is active
      if (_subscription == null) {
        await init(creditManager);
      }

      // Create a completer to track restoration completion
      _restoreCompleter = Completer<RestoreResult>();

      // Start the restore
      await _iap.restorePurchases();
      debugPrint("✅ [IAP] Restore initiated, waiting for completion...");

      // Wait for restoration to complete (with timeout)
      final result = await _restoreCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint("⏱️ [IAP] Restore timeout - assuming no purchases to restore");
          return RestoreResult(success: true, creditsRestored: 0);
        },
      );

      _restoreCompleter = null;
      return result;

    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Restore error: $e");
      debugPrint("Stack trace: $stackTrace");
      _restoreCompleter?.completeError(e);
      _restoreCompleter = null;
      rethrow;
    }
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases,
      CreditManager creditManager,
      ) async {

    int totalCreditsRestored = 0;
    bool hasRestoredPurchases = false;
    bool allRestoresProcessed = true;

    for (var purchase in purchases) {
      debugPrint("🔔 [IAP] Purchase update: ${purchase.productID} - ${purchase.status}");

      try {
        // Generate a unique transaction ID for tracking
        final transactionId = purchase.purchaseID ?? '${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';

        if (purchase.status == PurchaseStatus.pending) {
          debugPrint("⏳ [IAP] Purchase pending: ${purchase.productID}");
          allRestoresProcessed = false;

        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint("❌ [IAP] Purchase failed: ${purchase.productID}");
          debugPrint("   Error: ${purchase.error}");

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {

          hasRestoredPurchases = purchase.status == PurchaseStatus.restored;

          debugPrint("✅ [IAP] Purchase ${purchase.status == PurchaseStatus.restored ? 'restored' : 'successful'}: ${purchase.productID}");

          // Check if already processed
          if (_processedTransactionIds.contains(transactionId)) {
            debugPrint("⏭️ [IAP] Transaction already processed: $transactionId");

            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            continue;
          }

          // Verify purchase receipt
          final isValid = await _verifyPurchase(purchase);

          if (isValid) {
            final credits = productCredits[purchase.productID] ?? 0;

            if (credits > 0) {
              debugPrint("💰 [IAP] Awarding $credits credits for ${purchase.productID}");

              final success = await creditManager.addCredits(
                credits,
                reason: purchase.status == PurchaseStatus.restored
                    ? 'iap_restored_${purchase.productID}'
                    : 'iap_${purchase.productID}',
              );

              if (success) {
                debugPrint("✅ [IAP] Successfully added $credits credits");
                _processedTransactionIds.add(transactionId);

                if (purchase.status == PurchaseStatus.restored) {
                  totalCreditsRestored += credits;
                }
              } else {
                debugPrint("⚠️ [IAP] Failed to add credits");
                allRestoresProcessed = false;
              }
            }
          } else {
            debugPrint("❌ [IAP] Purchase verification failed: ${purchase.productID}");
            allRestoresProcessed = false;
          }

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
            debugPrint("✅ [IAP] Purchase completed: ${purchase.productID}");
          }
        }
      } catch (e, stackTrace) {
        debugPrint("❌ [IAP] Error processing purchase ${purchase.productID}: $e");
        debugPrint("Stack trace: $stackTrace");
        allRestoresProcessed = false;

        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (completeError) {
            debugPrint("❌ [IAP] Error completing purchase: $completeError");
          }
        }
      }
    }

    // Complete the restore operation if one is in progress
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      // Give a small delay to ensure all purchases are processed
      await Future.delayed(const Duration(milliseconds: 500));

      _restoreCompleter!.complete(RestoreResult(
        success: allRestoresProcessed,
        creditsRestored: totalCreditsRestored,
      ));
    }
  }

  /// Verify purchase receipt
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      debugPrint("🔐 [IAP] Verifying purchase: ${purchase.productID}");

      if (purchase.verificationData.localVerificationData.isEmpty) {
        debugPrint("❌ [IAP] No receipt data found");
        return false;
      }

      if (Platform.isIOS) {
        final receiptData = purchase.verificationData.localVerificationData;
        debugPrint("📄 [IAP] iOS receipt length: ${receiptData.length} chars");
        return receiptData.isNotEmpty;
      }

      if (Platform.isAndroid) {
        return purchase.verificationData.serverVerificationData.isNotEmpty;
      }

      debugPrint("⚠️ [IAP] Unknown platform for verification");
      return false;

    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Verification error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  /// Dispose
  void dispose() {
    debugPrint("🗑️ [IAP] Disposing IAP Manager");
    _subscription?.cancel();
    _subscription = null;
    _creditManager = null;
    _restoreCompleter?.completeError(Exception('IAP Manager disposed'));
    _restoreCompleter = null;
    _processedTransactionIds.clear();
  }
}

/// Result of restore purchases operation
class RestoreResult {
  final bool success;
  final int creditsRestored;

  RestoreResult({
    required this.success,
    required this.creditsRestored,
  });
}
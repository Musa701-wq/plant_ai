// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class AppleSubscriptionScreen extends StatefulWidget {
//   const AppleSubscriptionScreen({super.key});
//
//   @override
//   State<AppleSubscriptionScreen> createState() => _AppleSubscriptionScreenState();
// }
//
// class _AppleSubscriptionScreenState extends State<AppleSubscriptionScreen> {
//   final List<SubscriptionTier> _subscriptionTiers = [
//     SubscriptionTier(
//       name: "Premium",
//       price: "\$4.99",
//       period: "per month",
//       description: "Full access to all features",
//       isPopular: true,
//       features: [
//         "Ads Free Experience",
//         "Unlimited plant identification",
//         "Advanced care reminders",
//         "Water Calculation",
//         "Premium plant library",
//         "Priority support",
//       ],
//     ),
//     SubscriptionTier(
//       name: "Annual Pro",
//       price: "\$39.99",
//       period: "per year",
//       description: "Best value - Save 33%",
//       isPopular: false,
//       features: [
//         "Ads Free Experience",
//         "Unlimited plant identification",
//         "Advanced care reminders",
//         "Water Calculation",
//         "All Premium features",
//         "Yearly savings",
//         "Offline access",
//         "Early access to new features",
//       ],
//     ),
//   ];
//
//   int _selectedTierIndex = 0;
//   bool _isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmall = size.width < 360;
//     final isTablet = size.width > 600;
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C), Color(0xFF2E8B57)],
//             ),
//           ),
//           child: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 double basePadding = constraints.maxWidth * 0.05;
//                 return Column(
//                   children: [
//                     _buildHeader(isSmall, isTablet),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: EdgeInsets.all(basePadding),
//                         child: Column(
//                           children: [
//                             _buildFeatureHighlights(isTablet),
//                             SizedBox(height: isTablet ? 40 : 28),
//                             _buildSubscriptionCards(isSmall, isTablet),
//                             SizedBox(height: isTablet ? 32 : 24),
//                             _buildFeaturesList(),
//                             SizedBox(height: isTablet ? 40 : 28),
//                             _buildActionButtons(isTablet),
//                             const SizedBox(height: 24),
//                             _buildLegalText(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(bool isSmall, bool isTablet) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text(
//                   "PRO",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Unlock Premium Features",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: isTablet ? 34 : (isSmall ? 22 : 28),
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Take your plant care to the next level with advanced features and unlimited access",
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: isSmall ? 14 : 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFeatureHighlights(bool isTablet) {
//     final iconSize = isTablet ? 60.0 : 48.0;
//     final textSize = isTablet ? 14.0 : 12.0;
//
//     final features = [
//       {"icon": Icons.auto_awesome, "label": "Identification"},
//       {"icon": Icons.health_and_safety, "label": "Water Calc"},
//       {"icon": Icons.schedule, "label": "Smart Care"},
//       {"icon": Icons.offline_bolt, "label": "Offline"},
//     ];
//
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: features.map((f) {
//           return Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   width: iconSize,
//                   height: iconSize,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(f["icon"] as IconData, color: Colors.white, size: isTablet ? 30 : 24),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   f["label"] as String,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.white, fontSize: textSize, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildSubscriptionCards(bool isSmall, bool isTablet) {
//     return Column(
//       children: _subscriptionTiers.asMap().entries.map((entry) {
//         final index = entry.key;
//         final tier = entry.value;
//         final isSelected = index == _selectedTierIndex;
//
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? const LinearGradient(
//                 colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               )
//                   : LinearGradient(
//                 colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
//                 width: isSelected ? 2 : 1,
//               ),
//               boxShadow: isSelected
//                   ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
//                   : [],
//             ),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: () => setState(() => _selectedTierIndex = index),
//               child: Padding(
//                 padding: EdgeInsets.all(isTablet ? 24 : 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (tier.isPopular)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.amber,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text(
//                           "MOST POPULAR",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     if (tier.isPopular) const SizedBox(height: 12),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(tier.name,
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: isTablet ? 22 : 20,
//                                       fontWeight: FontWeight.bold)),
//                               Text(tier.description,
//                                   style: TextStyle(
//                                       color: Colors.white.withOpacity(0.8),
//                                       fontSize: isSmall ? 12 : 14)),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(tier.price,
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: isTablet ? 26 : 22,
//                                     fontWeight: FontWeight.bold)),
//                             Text(tier.period,
//                                 style: TextStyle(
//                                     color: Colors.white.withOpacity(0.8),
//                                     fontSize: isSmall ? 12 : 14)),
//                           ],
//                         ),
//                         if (isSelected)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10, top: 6),
//                             child: Icon(Icons.check_circle, color: Colors.white, size: isTablet ? 28 : 22),
//                           ),
//                       ],
//                     ),
//                     if (!tier.isPopular) ...[
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.amber.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(color: Colors.amber.withOpacity(0.3)),
//                         ),
//                         child: const Text(
//                           "Save 33% compared to monthly",
//                           style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildFeaturesList() {
//     final selectedTier = _subscriptionTiers[_selectedTierIndex];
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("What's included:",
//               style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 16),
//           Column(
//             children: selectedTier.features
//                 .map((feature) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.check, color: Colors.green, size: 16),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       feature,
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.9),
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//             ))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(bool isTablet) {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: isTablet ? 64 : 56,
//           child: ElevatedButton(
//             onPressed: _isLoading ? null : _handleSubscribe,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.black,
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             child: _isLoading
//                 ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.green)
//                 : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
//                   child: const Icon(Icons.apple, color: Colors.white, size: 16),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text("Continue with Apple Pay",
//                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           width: double.infinity,
//           height: isTablet ? 56 : 50,
//           child: TextButton(
//             onPressed: _isLoading ? null : _handleRestorePurchase,
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: BorderSide(color: Colors.white.withOpacity(0.3)),
//               ),
//             ),
//             child: const Text("Restore Purchase",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLegalText() {
//     return Column(
//       children: [
//         Text(
//           "Payment will be charged to your Apple ID account at confirmation of purchase. "
//               "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
//           style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.4),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(
//               onPressed: _showPrivacyPolicy,
//               child: Text("Privacy Policy",
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline)),
//             ),
//             Container(
//               width: 4,
//               height: 4,
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
//             ),
//             TextButton(
//               onPressed: _showTermsOfService,
//               child: Text("Terms of Service",
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Future<void> _handleSubscribe() async {
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(seconds: 2));
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: const [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text("Subscription activated successfully!")]),
//       backgroundColor: Colors.green,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ));
//     Navigator.pop(context);
//   }
//
//   Future<void> _handleRestorePurchase() async {
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(seconds: 1));
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: const [Icon(Icons.restore, color: Colors.white), SizedBox(width: 8), Text("Purchase restored successfully!")]),
//       backgroundColor: Colors.blue,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ));
//   }
//
//   void _showPrivacyPolicy() {}
//   void _showTermsOfService() {}
// }
//
// class SubscriptionTier {
//   final String name;
//   final String price;
//   final String period;
//   final String description;
//   final bool isPopular;
//   final List<String> features;
//   SubscriptionTier({
//     required this.name,
//     required this.price,
//     required this.period,
//     required this.description,
//     required this.isPopular,
//     required this.features,
//   });
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class AppleSubscriptionScreen extends StatefulWidget {
  const AppleSubscriptionScreen({super.key});

  @override
  State<AppleSubscriptionScreen> createState() => _AppleSubscriptionScreenState();
}

class _AppleSubscriptionScreenState extends State<AppleSubscriptionScreen> {
  // In-App Purchase instance
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - MUST match your App Store Connect configuration
  static const String monthlyProductId = 'com.yourapp.premium.monthly';
  static const String yearlyProductId = 'com.yourapp.premium.yearly';

  // Available products from App Store
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _loading = true;

  final List<SubscriptionTier> _subscriptionTiers = [
    SubscriptionTier(
      name: "Premium",
      price: "\$4.99", // This will be replaced with real price
      period: "per month",
      description: "Full access to all features",
      isPopular: true,
      productId: monthlyProductId,
      features: [
        "Ads Free Experience",
        "Unlimited plant identification",
        "Advanced care reminders",
        "Water Calculation",
        "Premium plant library",
        "Priority support",
      ],
    ),
    SubscriptionTier(
      name: "Annual Pro",
      price: "\$39.99", // This will be replaced with real price
      period: "per year",
      description: "Best value - Save 33%",
      isPopular: false,
      productId: yearlyProductId,
      features: [
        "Ads Free Experience",
        "Unlimited plant identification",
        "Advanced care reminders",
        "Water Calculation",
        "All Premium features",
        "Yearly savings",
        "Offline access",
        "Early access to new features",
      ],
    ),
  ];

  int _selectedTierIndex = 0;
  bool _isLoading = false;
  Set<String> _purchasedProductIds = {};

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Initialize In-App Purchases
  Future<void> _initializeIAP() async {
    // Check if IAP is available
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _isAvailable = false;
        _loading = false;
      });
      _showError('Store not available. Please try again later.');
      return;
    }

    // iOS-specific setup for StoreKit
    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => _showError('Purchase error: $error'),
    );

    // Load products from App Store
    await _loadProducts();

    // Restore previous purchases
    await _restorePurchases(silent: true);

    setState(() {
      _isAvailable = available;
      _loading = false;
    });
  }

  // Load products from App Store
  Future<void> _loadProducts() async {
    final Set<String> productIds = {monthlyProductId, yearlyProductId};

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        _showError('Failed to load products: ${response.error!.message}');
        return;
      }

      setState(() {
        _products = response.productDetails;
        // Update prices in subscription tiers
        for (var product in _products) {
          final index = _subscriptionTiers.indexWhere((tier) => tier.productId == product.id);
          if (index != -1) {
            _subscriptionTiers[index].price = product.price;
          }
        }
      });
    } catch (e) {
      _showError('Error loading products: $e');
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndDeliverProduct(purchaseDetails);
        }

        // Mark purchase as completed
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Verify and deliver product
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // TODO: Verify purchase on your backend server
    // This is a critical security step!

    // For now, we'll just mark it as purchased
    setState(() {
      _purchasedProductIds.add(purchaseDetails.productID);
      _isLoading = false;
    });

    if (purchaseDetails.status == PurchaseStatus.purchased) {
      _showSuccess('Subscription activated successfully!');
      // Wait a moment before closing
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } else if (purchaseDetails.status == PurchaseStatus.restored) {
      _showSuccess('Purchase restored successfully!');
    }
  }

  // Handle purchase button
  Future<void> _handleSubscribe() async {
    if (_isLoading) return;

    final selectedTier = _subscriptionTiers[_selectedTierIndex];
    final product = _products.firstWhere(
          (p) => p.id == selectedTier.productId,
      orElse: () => throw Exception('Product not found'),
    );

    setState(() => _isLoading = true);

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // For subscriptions, use buyNonConsumable (auto-renewable subscriptions)
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to initiate purchase: $e');
    }
  }

  // Restore purchases
  Future<void> _restorePurchases({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      await _inAppPurchase.restorePurchases();

      if (!silent) {
        setState(() => _isLoading = false);
        if (_purchasedProductIds.isEmpty) {
          _showInfo('No previous purchases found');
        }
      }
    } catch (e) {
      if (!silent) {
        setState(() => _isLoading = false);
        _showError('Failed to restore purchases: $e');
      }
    }
  }

  void _showPendingUI() {
    setState(() => _isLoading = true);
  }

  void _handleError(IAPError error) {
    setState(() => _isLoading = false);
    _showError(error.message);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isTablet = size.width > 600;

    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C), Color(0xFF2E8B57)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (!_isAvailable) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C), Color(0xFF2E8B57)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Store not available',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please try again later',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C), Color(0xFF2E8B57)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double basePadding = constraints.maxWidth * 0.05;
                return Column(
                  children: [
                    _buildHeader(isSmall, isTablet),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(basePadding),
                        child: Column(
                          children: [
                            _buildFeatureHighlights(isTablet),
                            SizedBox(height: isTablet ? 40 : 28),
                            _buildSubscriptionCards(isSmall, isTablet),
                            SizedBox(height: isTablet ? 32 : 24),
                            _buildFeaturesList(),
                            SizedBox(height: isTablet ? 40 : 28),
                            _buildActionButtons(isTablet),
                            const SizedBox(height: 24),
                            _buildLegalText(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Unlock Premium Features",
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 34 : (isSmall ? 22 : 28),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Take your plant care to the next level with advanced features and unlimited access",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmall ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(bool isTablet) {
    final iconSize = isTablet ? 60.0 : 48.0;
    final textSize = isTablet ? 14.0 : 12.0;

    final features = [
      {"icon": Icons.auto_awesome, "label": "Identification"},
      {"icon": Icons.health_and_safety, "label": "Water Calc"},
      {"icon": Icons.schedule, "label": "Smart Care"},
      {"icon": Icons.offline_bolt, "label": "Offline"},
    ];

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((f) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(f["icon"] as IconData, color: Colors.white, size: isTablet ? 30 : 24),
                ),
                const SizedBox(height: 8),
                Text(
                  f["label"] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: textSize, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionCards(bool isSmall, bool isTablet) {
    return Column(
      children: _subscriptionTiers.asMap().entries.map((entry) {
        final index = entry.key;
        final tier = entry.value;
        final isSelected = index == _selectedTierIndex;
        final isPurchased = _purchasedProductIds.contains(tier.productId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
                  : [],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _selectedTierIndex = index),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (tier.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "MOST POPULAR",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (isPurchased) ...[
                          if (tier.isPopular) const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              "ACTIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (tier.isPopular || isPurchased) const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tier.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 22 : 20,
                                      fontWeight: FontWeight.bold)),
                              Text(tier.description,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: isSmall ? 12 : 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(tier.price,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 26 : 22,
                                    fontWeight: FontWeight.bold)),
                            Text(tier.period,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: isSmall ? 12 : 14)),
                          ],
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 6),
                            child: Icon(Icons.check_circle, color: Colors.white, size: isTablet ? 28 : 22),
                          ),
                      ],
                    ),
                    if (!tier.isPopular) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: const Text(
                          "Save 33% compared to monthly",
                          style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesList() {
    final selectedTier = _subscriptionTiers[_selectedTierIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's included:",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Column(
            children: selectedTier.features
                .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.green, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isTablet ? 64 : 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.green)
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.apple, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text("Continue with Apple Pay",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 50,
          child: TextButton(
            onPressed: _isLoading ? null : () => _restorePurchases(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: const Text("Restore Purchase",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalText() {
    return Column(
      children: [
        Text(
          "Payment will be charged to your Apple ID account at confirmation of purchase. "
              "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _showPrivacyPolicy,
              child: Text("Privacy Policy",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline)),
            ),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
            ),
            TextButton(
              onPressed: _showTermsOfService,
              child: Text("Terms of Service",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ],
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Implement privacy policy display
  }

  void _showTermsOfService() {
    // TODO: Implement terms of service display
  }
}

// Payment Queue Delegate for iOS
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

class SubscriptionTier {
  final String name;
  String price; // Made mutable to update from App Store
  final String period;
  final String description;
  final bool isPopular;
  final String productId; // Added product ID
  final List<String> features;

  SubscriptionTier({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.isPopular,
    required this.productId,
    required this.features,
  });
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:provider/provider.dart';
// import 'IAPService.dart';
//
// class AppleSubscriptionScreen extends StatefulWidget {
//   const AppleSubscriptionScreen({super.key});
//
//   @override
//   State<AppleSubscriptionScreen> createState() => _AppleSubscriptionScreenState();
// }
//
// class _AppleSubscriptionScreenState extends State<AppleSubscriptionScreen> {
//   late final IAPService _iap;
//   int _selectedTierIndex = 0;
//   bool _isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _iap = IAPService(
//       onSubscribed: (purchaseDetails) async {
//         debugPrint("✅ Subscription successful: ${purchaseDetails.productID}");
//         _showSuccessMessage("Subscription activated successfully!");
//         // Navigate back or update UI
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) Navigator.pop(context);
//       },
//       onError: (error) {
//         debugPrint("❌ Subscription error: $error");
//         _showErrorDialog(_mapPurchaseError(error));
//       },
//     );
//     _iap.init();
//   }
//
//   String _mapPurchaseError(dynamic error) {
//     final errorStr = error.toString().toLowerCase();
//     if (errorStr.contains("canceled") || errorStr.contains("user_cancelled")) {
//       return "Purchase was canceled. You can try again anytime.";
//     } else if (errorStr.contains("network") || errorStr.contains("connection")) {
//       return "Network error. Please check your connection and try again.";
//     } else if (errorStr.contains("payment")) {
//       return "Payment failed. Please verify your payment method.";
//     } else if (errorStr.contains("item already owned")) {
//       return "You already own this subscription. Try restoring purchases.";
//     }
//     return "An error occurred. Please try again.";
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Purchase Failed"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSuccessMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 8),
//             Text(message),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   Future<void> _handleSubscribe() async {
//     if (_isProcessing) return;
//
//     final products = _iap.products;
//     if (products.isEmpty) {
//       _showErrorDialog("No subscription products available. Please try again.");
//       return;
//     }
//
//     // Get selected product based on index
//     final selectedTier = _selectedTierIndex == 0
//         ? IAPService.subscriptionId  // Monthly
//         : IAPService.annualSubscriptionId;  // Annual
//
//     debugPrint("🛒 Attempting to purchase: $selectedTier (index: $_selectedTierIndex)");
//
//     final selectedProduct = products.cast<ProductDetails?>().firstWhere(
//           (p) => p?.id == selectedTier,
//       orElse: () => null,
//     );
//
//     if (selectedProduct == null) {
//       _showErrorDialog(
//           "Selected subscription ($selectedTier) is not available yet. "
//               "Please make sure it's set up in App Store Connect and approved."
//       );
//       return;
//     }
//
//     setState(() => _isProcessing = true);
//
//     try {
//       // Call appropriate purchase method based on selected product
//       if (_selectedTierIndex == 0) {
//         debugPrint("💳 Purchasing Monthly subscription...");
//         await _iap.buySubscription();  // Monthly
//       } else {
//         debugPrint("💳 Purchasing Annual subscription...");
//         await _iap.buyAnnualSubscription();  // Annual
//       }
//     } catch (e) {
//       setState(() => _isProcessing = false);
//       _showErrorDialog(_mapPurchaseError(e));
//     }
//   }
//
//   Future<void> _handleRestorePurchase() async {
//     if (_isProcessing) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       await _iap.restore();
//       _showSuccessMessage("Purchases restored successfully!");
//     } catch (e) {
//       _showErrorDialog("Failed to restore purchases. Please try again.");
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _iap.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: _iap,
//       child: Consumer<IAPService>(
//         builder: (_, iap, __) {
//           return AnnotatedRegion<SystemUiOverlayStyle>(
//             value: SystemUiOverlayStyle.light,
//             child: Scaffold(
//               body: Stack(
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C), Color(0xFF2E8B57)],
//                       ),
//                     ),
//                     child: SafeArea(
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           return _buildContent(iap, constraints);
//                         },
//                       ),
//                     ),
//                   ),
//                   // Loading overlay
//                   if (_isProcessing || iap.isBuying)
//                     Container(
//                       color: Colors.black54,
//                       child: const Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CircularProgressIndicator(color: Colors.white),
//                             SizedBox(height: 16),
//                             Text(
//                               "Processing purchase...",
//                               style: TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildContent(IAPService iap, BoxConstraints constraints) {
//     double basePadding = constraints.maxWidth * 0.05;
//     final size = MediaQuery.of(context).size;
//     final isSmall = size.width < 360;
//     final isTablet = size.width > 600;
//
//     // Loading state
//     if (iap.isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 16),
//             Text(
//               "Loading subscription options...",
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // Error state
//     if (iap.errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 64, color: Colors.white),
//               const SizedBox(height: 16),
//               Text(
//                 iap.errorMessage!,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () => iap.init(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.green,
//                 ),
//                 child: const Text("Try Again"),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         _buildHeader(isSmall, isTablet),
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(basePadding),
//             child: Column(
//               children: [
//                 _buildFeatureHighlights(isTablet),
//                 SizedBox(height: isTablet ? 40 : 28),
//                 _buildSubscriptionCards(isSmall, isTablet, iap),
//                 SizedBox(height: isTablet ? 32 : 24),
//                 _buildFeaturesList(),
//                 SizedBox(height: isTablet ? 40 : 28),
//                 _buildActionButtons(isTablet),
//                 const SizedBox(height: 24),
//                 _buildLegalText(),
//               ],
//             ),
//           ),
//         ),
//       ],
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
//   Widget _buildSubscriptionCards(bool isSmall, bool isTablet, IAPService iap) {
//     // Get actual product details from IAP service
//     final products = iap.products;
//
//     debugPrint("🔍 Total products loaded: ${products.length}");
//     for (var p in products) {
//       debugPrint("   • Product: ${p.id} - ${p.title} - ${p.price}");
//     }
//
//     // Find monthly subscription product
//     final monthlyProduct = products.cast<ProductDetails?>().firstWhere(
//           (p) => p?.id == IAPService.subscriptionId,
//       orElse: () => null,
//     );
//
//     debugPrint("📦 Monthly Product: ${monthlyProduct?.id ?? 'NOT FOUND'}");
//
//     // Find annual subscription product (if exists)
//     final annualProduct = products.cast<ProductDetails?>().firstWhere(
//           (p) => p?.id == IAPService.annualSubscriptionId,
//       orElse: () => null,
//     );
//
//     debugPrint("📦 Annual Product: ${annualProduct?.id ?? 'NOT FOUND'}");
//
//     final List<SubscriptionTier> subscriptionTiers = [
//       // Always show monthly
//       SubscriptionTier(
//         name: "Monthly Premium",
//         price: monthlyProduct?.price ?? "\$4.99",
//         period: "per month",
//         description: "Full access to all features",
//         isPopular: annualProduct == null, // Monthly is popular if no annual
//         productId: IAPService.subscriptionId,
//         features: [
//           "Ads Free Experience",
//           "Unlimited plant identification",
//           "Advanced care reminders",
//           "Water Calculation",
//           "Premium plant library",
//           "Priority support",
//         ],
//       ),
//       // Always show annual (even if not found in App Store)
//       SubscriptionTier(
//         name: "Annual Pro",
//         price: annualProduct?.price ?? "\$39.99",
//         period: "per year",
//         description: "Best value - Save 33%",
//         isPopular: true, // Annual is usually the popular option
//         productId: IAPService.annualSubscriptionId,
//         features: [
//           "Ads Free Experience",
//           "Unlimited plant identification",
//           "Advanced care reminders",
//           "Water Calculation",
//           "All Premium features",
//           "Yearly savings",
//           "Offline access",
//           "Early access to new features",
//         ],
//       ),
//     ];
//
//     return Column(
//       children: subscriptionTiers.asMap().entries.map((entry) {
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
//                         const SizedBox(width: 12),
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
//     final features = [
//       "Ads Free Experience",
//       "Unlimited plant identification",
//       "Advanced care reminders",
//       "Water Calculation",
//       "Premium plant library",
//       "Priority support",
//     ];
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
//             children: features
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
//             onPressed: _isProcessing ? null : _handleSubscribe,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.black,
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             child: _isProcessing
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
//             onPressed: _isProcessing ? null : _handleRestorePurchase,
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
//               onPressed: () {},
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
//               onPressed: () {},
//               child: Text("Terms of Service",
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class SubscriptionTier {
//   final String name;
//   final String price;
//   final String period;
//   final String description;
//   final bool isPopular;
//   final String productId;  // Product ID for IAP
//   final List<String> features;
//
//   SubscriptionTier({
//     required this.name,
//     required this.price,
//     required this.period,
//     required this.description,
//     required this.isPopular,
//     required this.productId,
//     required this.features,
//   });
// }

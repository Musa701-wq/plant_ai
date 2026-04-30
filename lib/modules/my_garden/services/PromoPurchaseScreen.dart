import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'CreditManager.dart';
import 'IAPManager.dart';

class PromoPurchaseScreen extends StatefulWidget {
  const PromoPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PromoPurchaseScreen> createState() => _PromoPurchaseScreenState();
}

class _PromoPurchaseScreenState extends State<PromoPurchaseScreen> {
  final IAPManager _iapManager = IAPManager();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _currentPurchasingProductId;

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  Future<void> _initIAP() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final creditManager = context.read<CreditManager>();
      await _iapManager.init(creditManager);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load purchases. Please try again.";
        });
      }
    }
  }

  Future<void> _handlePurchase(ProductDetails product) async {
    if (_isPurchasing) return;
    setState(() {
      _isPurchasing = true;
      _currentPurchasingProductId = product.id;
      _errorMessage = null;
    });

    try {
      final creditsBefore = context.read<CreditManager>().credits;
      final success = await _iapManager.purchaseProduct(product);

      if (!success && mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          final creditsAfter = context.read<CreditManager>().credits;
          final creditsAdded = creditsAfter - creditsBefore;
          setState(() {
            _isPurchasing = false;
            _currentPurchasingProductId = null;
          });
          if (creditsAdded > 0) _showPurchaseSuccessDialog(creditsAdded);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _currentPurchasingProductId = null;
        });
      }
    }
  }

  void _showPurchaseSuccessDialog(int creditsAdded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                ),
                const SizedBox(height: 24),
                const Text('Purchase Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('+$creditsAdded Credits', style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.of(context).pop(); // close dialog
                       Navigator.of(context).pop(); // close purchase screen
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Awesome!', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _iapManager.products;
    ProductDetails? smallestProduct;

    if (products.isNotEmpty) {
      final sortedProducts = List<ProductDetails>.from(products);
      sortedProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      smallestProduct = sortedProducts.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7), // light grayish-green for a modern feel
      body: Column(
        children: [
          // Upper Part: Visual Banner using Splash Image
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 6), blurRadius: 15)
                ]
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1497250681960-ef046c18fe39?auto=format&fit=crop&w=1000&q=80',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Image.asset('assets/grden.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        top: 10,
                        left: 16,
                        child: CircleAvatar(
                           backgroundColor: Colors.white.withOpacity(0.2),
                           child: IconButton(
                             icon: const Icon(Icons.close, color: Colors.white),
                             onPressed: () => Navigator.pop(context),
                           ),
                        )
                      ),
                      // Text at the bottom of the image
                      const Positioned(
                         bottom: 30,
                         left: 30,
                         right: 30,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text(
                                'PlantEye\nPremium', 
                                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.1)
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Empowering your garden with AI precision.', 
                                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)
                              ),
                           ]
                         )
                      )
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
          
          // Lower Part: Purchase Details
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                  : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pricing Card
                            Container(
                               padding: const EdgeInsets.all(24),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(24),
                                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]
                               ),
                               child: Column(
                                  children: [
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                          const Text('Starter Pack', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF212121))),
                                          Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                             decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                                             child: const Text('Best Value', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13))
                                          )
                                       ]
                                     ),
                                     const SizedBox(height: 20),
                                     Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                           Text('${smallestProduct != null ? IAPManager.productCredits[smallestProduct.id] ?? 250 : 250}', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                                           const Padding(padding: EdgeInsets.only(bottom: 10, left: 8), child: Text('Credits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54))),
                                        ]
                                     ),
                                     const Divider(height: 40, color: Color(0xFFF5F5F5), thickness: 1.5),
                                     _buildFeatureRow(Icons.bolt, 'Instant plant identification'),
                                     const SizedBox(height: 12),
                                     _buildFeatureRow(Icons.healing, 'Expert disease detection'),
                                     const SizedBox(height: 12),
                                     _buildFeatureRow(Icons.all_inclusive, 'Credits never expire'),
                                  ]
                               )
                            ),
                            
                            // Buy Now Button
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: _isPurchasing ? null : () {
                                  if (smallestProduct == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('StoreKit unavailable in simulator. Special offer currently unavailable.')));
                                  } else {
                                    _handlePurchase(smallestProduct);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32), 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 6,
                                  shadowColor: const Color(0xFF2E7D32).withOpacity(0.5)
                                ),
                                child: _isPurchasing && smallestProduct != null && _currentPurchasingProductId == smallestProduct.id
                                    ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                           const Text('Buy Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                           const SizedBox(width: 8),
                                           Text('• ${smallestProduct?.price ?? "\$4.99"}', style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
                                        ]
                                      )
                              ),
                            ),
                            
                            // Maybe Later TextButton
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade500),
                              child: const Text('Not right now, maybe later', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
     return Row(
       children: [
         Icon(icon, color: const Color(0xFF4CAF50), size: 22),
         const SizedBox(width: 12),
         Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500))
       ]
     );
  }
}

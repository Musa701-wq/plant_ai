import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:untitled/modules/my_garden/services/IAPManager.dart';

class InsufficientCreditsDialog extends StatefulWidget {
  const InsufficientCreditsDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const InsufficientCreditsDialog(),
    );
  }

  @override
  State<InsufficientCreditsDialog> createState() => _InsufficientCreditsDialogState();
}

class _InsufficientCreditsDialogState extends State<InsufficientCreditsDialog> {
  final IAPManager _iapManager = IAPManager();
  bool _isPurchasing = false;

  void _handlePurchase(ProductDetails product) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      final success = await _iapManager.purchaseProduct(product);
      if (success && mounted) {
        Navigator.pop(context); // close dialog when purchase is successful
      } else {
        if (mounted) setState(() => _isPurchasing = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isPurchasing = false);
    }
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Professional Icon Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Colors.orange, size: 48),
            ),
            const SizedBox(height: 20),
            
            // Header Text
            const Text(
              'Insufficient Credits',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You need more credits to use this AI feature.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Starter Pack container logic
            if (smallestProduct != null) ...[
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: const Color(0xFFF7F9F7),
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5)
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text('Starter Pack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           const SizedBox(height: 4),
                           Text('${IAPManager.productCredits[smallestProduct.id] ?? 250} Credits', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green, fontSize: 14)),
                        ]
                      ),
                      Text(smallestProduct.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2E7D32))),
                   ]
                 )
              ),
              const SizedBox(height: 24),
              // Buy Now Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPurchasing ? null : () => _handlePurchase(smallestProduct!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isPurchasing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Buy Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ] else ...[
               const Center(child: Text('Packages loading or unavailable', style: TextStyle(color: Colors.grey))),
               const SizedBox(height: 24),
            ],
            
            const SizedBox(height: 12),
            // Maybe Later
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Not right now, maybe later', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }
}

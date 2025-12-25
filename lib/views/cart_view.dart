import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schema_models.dart' as schema;
import '../providers/cart_provider.dart';
import '../constants/colors.dart';
import '../widgets/custom_image.dart';
import 'ship_form.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
        ),
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, cartProvider),
              child: const Text(
                "Clear",
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
        ],
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, cartProvider, items),
      bottomSheet: items.isEmpty
          ? null
          : _buildBottomSheet(context, cartProvider),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Looks like you haven't added\nanything to your cart yet",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Start Shopping",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cartProvider,
    List<schema.CartItem> items,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCartItem(context, cartProvider, item);
      },
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cartProvider,
    schema.CartItem item,
  ) {
    final product = item.product;
    if (product == null) return const SizedBox();

    String? displayImage;
    // Prioritize gallery images from product_images table
    if (product.gallery.isNotEmpty) {
      displayImage = product.gallery.first.url;
      print('🖼️ Cart: Using gallery image: $displayImage');
    } else if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      displayImage = product.imageUrl;
      print('🖼️ Cart: Using imageUrl: $displayImage');
    } else {
      print('🖼️ Cart: No image available for ${product.name}');
      print('   Gallery: ${product.gallery.length} images');
      print('   imageUrl: ${product.imageUrl}');
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => cartProvider.removeFromCart(item.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: displayImage != null
                  ? (displayImage.startsWith('http')
                        ? CustomImage(
                            imageUrl: displayImage,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                            errorWidget: _buildImagePlaceholder(),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              displayImage,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(),
                            ),
                          ))
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.price.toStringAsFixed(0)} EGP",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => cartProvider.decreaseQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.remove, size: 14),
                              ),
                            ),
                            Container(
                              width: 28,
                              alignment: Alignment.center,
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => cartProvider.increaseQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.add, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${(product.price * item.quantity).toStringAsFixed(0)} EGP",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              onPressed: () => cartProvider.removeFromCart(item.id),
              icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Icons.image_outlined, size: 24, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary rows
            _buildSummaryRow(
              "Subtotal",
              "${cartProvider.subtotal.toStringAsFixed(0)} EGP",
            ),
            const SizedBox(height: 6),
            _buildSummaryRow(
              "Tax (14%)",
              "${cartProvider.tax.toStringAsFixed(0)} EGP",
            ),
            const SizedBox(height: 6),
            _buildSummaryRow("Shipping", "Free", isGreen: true),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildSummaryRow(
              "Total",
              "${cartProvider.totalPrice.toStringAsFixed(0)} EGP",
              isTotal: true,
            ),
            const SizedBox(height: 16),
            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShippingDataScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textBlack : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.bold,
            color: isGreen
                ? Colors.green
                : isTotal
                ? AppColors.primaryBlue
                : AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear Cart?"),
        content: const Text("Are you sure you want to remove all items?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }
}

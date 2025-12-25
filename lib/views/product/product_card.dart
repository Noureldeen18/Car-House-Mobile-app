import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schema_models.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/cart_provider.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onPress;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onPress,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final bool isFav = favProvider.isFavorite(product.id);

    // Get display image - check gallery first, then imageUrl
    String? displayImage;
    if (product.gallery.isNotEmpty) {
      displayImage = product.gallery.first.url;
    } else if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      displayImage = product.imageUrl;
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 110,
              child: Stack(
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[100]!, Colors.grey[50]!],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: CustomImage(
                      imageUrl: displayImage,
                      fit: BoxFit.contain,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => favProvider.toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey[400],
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (product.comparePrice != null &&
                      product.comparePrice! > product.price)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "-${(((product.comparePrice! - product.price) / product.comparePrice!) * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title ?? product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Rating Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (product.stock > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "In Stock",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price and Add to Cart Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.comparePrice != null &&
                                  product.comparePrice! > product.price)
                                Text(
                                  "${product.comparePrice!.toStringAsFixed(0)} EGP",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "${product.price.toStringAsFixed(0)} EGP",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add to Cart Button
                        GestureDetector(
                          onTap: product.stock > 0
                              ? () {
                                  cartProvider.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "${product.name} added to cart",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: product.stock > 0
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.secondaryOrange,
                                        Color(0xFFFF8C42),
                                      ],
                                    )
                                  : null,
                              color: product.stock > 0
                                  ? null
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: product.stock > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.secondaryOrange
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              color: product.stock > 0
                                  ? Colors.white
                                  : Colors.grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

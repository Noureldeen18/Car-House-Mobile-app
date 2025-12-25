import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schema_models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_image.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favProvider.isFavorite(product.id);

    // Get all images
    List<String> allImages = product.images;
    if (allImages.isEmpty && product.imageUrl != null) {
      allImages = [product.imageUrl!];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => favProvider.toggleFavorite(product.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? AppColors.errorRed
                        : AppColors.accentGray,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF5F6F8),
                child: Column(
                  children: [
                    // Main image
                    Expanded(
                      child: allImages.isNotEmpty
                          ? _buildImage(allImages[_selectedImageIndex])
                          : _buildPlaceholder(),
                    ),
                    // Image thumbnails
                    if (allImages.length > 1)
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: allImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = _selectedImageIndex == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageIndex = index),
                              child: Container(
                                width: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: _buildImage(allImages[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Product Info
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating - Use Wrap to prevent overflow
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${product.stock} in stock",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: product.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      product.title ?? product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),

                    // Brand & Car Model
                    if (product.brand != null || product.carModel != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product.brand != null) ...[
                            Icon(
                              Icons.business,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.brand!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (product.brand != null && product.carModel != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "•",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          if (product.carModel != null) ...[
                            Icon(
                              Icons.directions_car,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.carModel!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Price
                    Row(
                      children: [
                        Text(
                          "${product.price.toStringAsFixed(0)} EGP",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        if (product.comparePrice != null &&
                            product.comparePrice! > product.price) ...[
                          const SizedBox(width: 10),
                          Text(
                            "${product.comparePrice!.toStringAsFixed(0)} EGP",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Savings badge
                    if (product.comparePrice != null &&
                        product.comparePrice! > product.price) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Save ${(product.comparePrice! - product.price).toStringAsFixed(0)} EGP",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description ?? "No description available.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quantity Selector
                    Row(
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                icon: const Icon(Icons.remove, size: 16),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                              Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (_quantity < product.stock) {
                                    setState(() => _quantity++);
                                  }
                                },
                                icon: const Icon(Icons.add, size: 16),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Add to cart button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    Text(
                      "${(product.price * _quantity).toStringAsFixed(0)} EGP",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              // Add to cart button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: product.stock > 0
                      ? () {
                          cartProvider.addToCart(product, quantity: _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text("$_quantity item(s) added to cart"),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        product.stock > 0 ? "Add to Cart" : "Out of Stock",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CustomImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        errorWidget: _buildPlaceholder(),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Icons.image_outlined, size: 60, color: Colors.grey[400]),
      ),
    );
  }
}

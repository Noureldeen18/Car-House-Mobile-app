import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import 'product/product_details.dart';
import '../constants/colors.dart';
import '../widgets/custom_image.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final favorites = favProvider.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Wishlist",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (favorites.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${favorites.length} items",
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = favorites[index];

                // Get display image - check gallery first, then imageUrl
                String? displayImage;
                if (product.gallery.isNotEmpty) {
                  displayImage = product.gallery.first.url;
                } else if (product.imageUrl != null &&
                    product.imageUrl!.isNotEmpty) {
                  displayImage = product.imageUrl;
                }

                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (_) => favProvider.toggleFavorite(product.id),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetails(product: product),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              child: displayImage != null
                                  ? (displayImage.startsWith('http')
                                        ? CustomImage(
                                            imageUrl: displayImage,
                                            fit: BoxFit.contain,
                                            width: 80,
                                            height: 80,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            errorWidget: _buildPlaceholder(),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.asset(
                                              displayImage,
                                              fit: BoxFit.contain,
                                              width: 80,
                                              height: 80,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildPlaceholder(),
                                            ),
                                          ))
                                  : _buildPlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title ?? product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${product.price.toStringAsFixed(0)} EGP",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Actions
                          Column(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    favProvider.toggleFavorite(product.id),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: AppColors.errorRed,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.accentGray,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No favorites yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start adding products to your wishlist\nby tapping the heart icon",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 30,
        color: Colors.grey[300],
      ),
    );
  }
}

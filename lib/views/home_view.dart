import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/schema_models.dart';
import '../providers/app_data_provider.dart';
import '../providers/cart_provider.dart';
import '../constants/colors.dart';
import '../widgets/custom_image.dart';
import 'product/product_card.dart';
import 'product/product_details.dart';
import 'cart_view.dart';
import 'navBar/ui/Store_view.dart';
import 'service_booking/service_booking_view.dart';
import 'see_more.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final productList = appDataProvider.products;
    final categories = appDataProvider.categories;

    final filteredProducts = searchQuery.isEmpty
        ? productList
        : productList
              .where(
                (p) =>
                    (p.title ?? p.name).toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    (p.category.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    )),
              )
              .toList();

    final topRated = filteredProducts.where((p) => p.rating >= 4.0).toList();
    final popular = filteredProducts.take(10).toList();
    final featured = productList
        .where((p) => p.meta['is_featured'] == true)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: appDataProvider.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      "Loading products...",
                      style: TextStyle(color: AppColors.textDarkGray),
                    ),
                  ],
                ),
              )
            : appDataProvider.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${appDataProvider.error}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => appDataProvider.loadData(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => appDataProvider.loadData(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header with search
                    SliverToBoxAdapter(child: _buildHeader(context)),

                    // Service Banner
                    SliverToBoxAdapter(child: _buildServiceBanner(context)),

                    // Categories
                    if (searchQuery.isEmpty && categories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildCategorySection(context, categories),
                      ),

                    // Search Results or Content
                    if (searchQuery.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildProductSection(
                          "Search Results",
                          filteredProducts,
                          showSeeMore: false,
                        ),
                      )
                    else ...[
                      // Popular Products
                      if (popular.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildProductSection(
                            "Popular Products",
                            popular,
                            onSeeMore: () => _navigateToSeeMore(
                              context,
                              "Popular Products",
                              popular,
                            ),
                          ),
                        ),

                      // Top Rated
                      if (topRated.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildProductSection(
                            "Top Rated",
                            topRated,
                            onSeeMore: () => _navigateToSeeMore(
                              context,
                              "Top Rated",
                              topRated,
                            ),
                          ),
                        ),

                      // Featured
                      if (featured.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildProductSection(
                            "Featured",
                            featured,
                            onSeeMore: () => _navigateToSeeMore(
                              context,
                              "Featured",
                              featured,
                            ),
                          ),
                        ),
                    ],

                    // Empty state
                    if (productList.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: AppColors.accentGray,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No products available",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textDarkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }

  void _navigateToSeeMore(
    BuildContext context,
    String title,
    List<Product> products,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeeMorePage(title: title, products: products),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text and cart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Text(
                    "Car House",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              // Cart button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primaryBlue,
                        size: 26,
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cartProvider.itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search for car parts...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = "");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServiceBookingView()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF0D253F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.build_circle,
                size: 180,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.car_repair,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 80, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Book a Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Professional maintenance",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Book Now",
                        style: TextStyle(
                          color: AppColors.secondaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.secondaryOrange,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    List<Category> categories,
  ) {
    // Icons mapping
    final categoryIcons = {
      'engine': Icons.settings,
      'brakes': Icons.disc_full,
      'suspension': Icons.architecture,
      'lighting': Icons.light,
      'transmission': Icons.miscellaneous_services,
      'exhaust': Icons.air,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoreView()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.secondaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon =
                  categoryIcons[category.slug?.toLowerCase()] ?? Icons.category;

              // Get full name
              String displayName = category.name;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoreView(filterCategory: category.name),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category Image/Icon Container
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child:
                              category.imageUrl != null &&
                                  category.imageUrl!.isNotEmpty
                              ? _buildCategoryImage(category.imageUrl!, icon)
                              : Icon(
                                  icon,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category Name
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            displayName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductSection(
    String title,
    List<Product> products, {
    bool showSeeMore = true,
    VoidCallback? onSeeMore,
  }) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.search_off, size: 48, color: AppColors.accentGray),
            const SizedBox(height: 8),
            const Text(
              "No products found",
              style: TextStyle(color: AppColors.textDarkGray),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              if (showSeeMore)
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetails(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build category image - handles SVG and regular images
  Widget _buildCategoryImage(
    String imageUrl,
    IconData fallbackIcon, {
    bool isWhite = false,
  }) {
    final isSvg = imageUrl.toLowerCase().endsWith('.svg');
    final color = isWhite ? Colors.white : AppColors.primaryBlue;

    if (isSvg) {
      return SvgPicture.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) =>
            Icon(fallbackIcon, color: color, size: 24),
      );
    } else {
      return CustomImage(
        imageUrl: imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorWidget: Icon(fallbackIcon, color: color, size: 24),
      );
    }
  }
}

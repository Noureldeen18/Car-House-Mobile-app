import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/schema_models.dart';
import '../../../constants/colors.dart';
import '../../../providers/cart_provider.dart';
import '../../product/product_card.dart';
import '../../product/product_details.dart';
import '../../cart_view.dart';
import '../../../providers/app_data_provider.dart';

class StoreView extends StatefulWidget {
  final String? filterCategory;

  const StoreView({super.key, this.filterCategory});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  String selectedCategory = "All";
  String selectedSort = "Popular";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final sortOptions = [
    "Popular",
    "Newest",
    "Price: Low",
    "Price: High",
    "Rating",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.filterCategory != null) {
      selectedCategory = widget.filterCategory!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final allProducts = appDataProvider.products;
    final categories = appDataProvider.categories;

    // Build category list
    List<String> categoryNames = ["All", ...categories.map((c) => c.name)];

    // Filter products
    List<Product> filteredProducts = allProducts;

    // Category filter
    if (selectedCategory != "All") {
      filteredProducts = filteredProducts.where((p) {
        final cat = categories.firstWhere(
          (c) => c.name == selectedCategory,
          orElse: () => Category(id: '', name: ''),
        );
        return p.categoryId == cat.id || p.category == selectedCategory;
      }).toList();
    }

    // Search filter
    if (searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where(
            (p) =>
                (p.title ?? p.name).toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (p.description ?? '').toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort
    switch (selectedSort) {
      case "Newest":
        // Sort by name as fallback since we don't have createdAt exposed
        filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "Price: Low":
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Price: High":
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "Rating":
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // Popular - keep original order
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Category chips
            _buildCategoryChips(categoryNames),

            // Sort bar
            _buildSortBar(),

            // Products grid
            Expanded(
              child: appDataProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildProductsGrid(filteredProducts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
        children: [
          Row(
            children: [
              if (widget.filterCategory != null)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (widget.filterCategory != null) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.filterCategory ?? "Store",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
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
          const SizedBox(height: 16),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search products...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = "");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categoryNames) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categoryNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = categoryNames[index];
          final isSelected = selectedCategory == name;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDarkGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Product count
          Consumer<AppDataProvider>(
            builder: (_, provider, __) {
              return Text(
                "${provider.products.length} Products",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              );
            },
          ),
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 13,
                ),
                items: sortOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedSort = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          width: double.infinity,
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
    );
  }
}

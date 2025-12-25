import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/schema_models.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_image.dart';

class OrderDetailsView extends StatefulWidget {
  final Order order;

  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final SupabaseService _service = SupabaseService();
  List<OrderItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    try {
      final items = await _service.getOrderDetails(widget.order.id);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Order #${widget.order.id.substring(0, 8)}",
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Status",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.order.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Placed on ${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Items List
                  const Text(
                    "Order Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      // Get display image - prioritize gallery first
                      String? imageUrl;
                      if (item.product?.gallery.isNotEmpty == true) {
                        imageUrl = item.product!.gallery.first.url;
                        print('🖼️ Order: Using gallery image: $imageUrl');
                      } else if (item.product?.imageUrl != null &&
                          item.product!.imageUrl!.isNotEmpty) {
                        imageUrl = item.product!.imageUrl;
                        print('🖼️ Order: Using imageUrl: $imageUrl');
                      } else {
                        print('🖼️ Order: No image for ${item.title}');
                        print(
                          '   Gallery: ${item.product?.gallery.length ?? 0} images',
                        );
                        print('   imageUrl: ${item.product?.imageUrl}');
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            CustomImage(
                              imageUrl: imageUrl,
                              width: 60,
                              height: 60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title ?? "Unknown Product",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.quantity}x  ${item.unitPrice.toStringAsFixed(0)} EGP",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${item.subtotal.toStringAsFixed(0)} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Payment Summary Logic
                  Builder(
                    builder: (context) {
                      final subtotal = _items.fold(
                        0.0,
                        (sum, item) => sum + item.subtotal,
                      );
                      // Use calculated tax or derive from total?
                      // Let's calculate fresh based on items
                      final tax = subtotal * 0.14;
                      final shipping = 0.0;
                      final total = subtotal + tax + shipping;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Payment Summary",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              "Subtotal",
                              "${subtotal.toStringAsFixed(0)} EGP",
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              "Tax (14%)",
                              "${tax.toStringAsFixed(0)} EGP",
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              "Shipping",
                              "Free",
                              valueColor: Colors.green,
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              "Total",
                              "${total.toStringAsFixed(0)} EGP",
                              isBold: true,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textBlack : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ??
                (isBold ? AppColors.primaryBlue : AppColors.textBlack),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

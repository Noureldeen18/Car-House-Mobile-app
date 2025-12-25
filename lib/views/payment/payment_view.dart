import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_image.dart';
import '../order_sc.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;
  int _selectedPaymentMethod = 0; // 0 = Credit Card, 1 = Cash on Delivery

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Payment",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(2),
              const SizedBox(height: 24),

              // Payment Methods
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPaymentOption(0, "Credit Card", Icons.credit_card),
                  const SizedBox(width: 12),
                  _buildPaymentOption(1, "Cash on Delivery", Icons.money),
                ],
              ),
              const SizedBox(height: 24),

              // Show card form only for Credit Card option
              if (_selectedPaymentMethod == 0) ...[
                // Credit Card Preview
                _buildCardPreview(),
                const SizedBox(height: 24),

                // Card Details
                const Text(
                  "Card Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),

                // Cardholder Name
                _buildTextField(
                  controller: _nameController,
                  label: "Cardholder Name",
                  hint: "Name on card",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),

                // Card Number
                _buildTextField(
                  controller: _cardNumberController,
                  label: "Card Number",
                  hint: "1234 5678 9012 3456",
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 12),

                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _expiryController,
                        label: "Expiry",
                        hint: "MM/YY",
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _cvvController,
                        label: "CVV",
                        hint: "123",
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Security notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your payment information is secure and encrypted",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Cash on Delivery Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.money,
                          color: AppColors.secondaryOrange,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Cash on Delivery",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pay with cash when your order arrives.\nPlease have the exact amount ready.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "No extra fees for cash payment",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Processing..."),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedPaymentMethod == 0
                                  ? Icons.lock
                                  : Icons.check_circle,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPaymentMethod == 0
                                  ? "Pay Now"
                                  : "Place Order",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: [
        _buildProgressStep(1, "Shipping", step >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 2 ? AppColors.primaryBlue : Colors.grey[300],
          ),
        ),
        _buildProgressStep(2, "Payment", step >= 2),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 3 ? AppColors.primaryBlue : Colors.grey[300],
          ),
        ),
        _buildProgressStep(3, "Done", step >= 3),
      ],
    );
  }

  Widget _buildProgressStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primaryBlue : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(int index, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.credit_card, color: Colors.white, size: 32),
                CustomImage(
                  imageUrl:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/MasterCard_Logo.svg/200px-MasterCard_Logo.svg.png',
                  height: 32,
                  width: 50, // Added width to maintain aspect ratio/bounds
                  fit: BoxFit.contain,
                  errorWidget: const Icon(Icons.payment, color: Colors.white),
                ),
              ],
            ),
            Text(
              _cardNumberController.text.isEmpty
                  ? "•••• •••• •••• ••••"
                  : _formatCardNumber(_cardNumberController.text),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CARD HOLDER",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nameController.text.isEmpty
                          ? "YOUR NAME"
                          : _nameController.text.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "EXPIRES",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expiryController.text.isEmpty
                          ? "MM/YY"
                          : _expiryController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (_) => setState(() {}),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accentGray, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  String _formatCardNumber(String text) {
    text = text.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }
    return formatted.padRight(19, '•');
  }

  Future<void> _processPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final supabaseService = SupabaseService();

    // 1. Validate Form (if Credit Card)
    if (_selectedPaymentMethod == 0) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _isProcessing = true);

    try {
      // 2. Prepare Order Data
      final paymentMethod = _selectedPaymentMethod == 0 ? 'card' : 'cod';
      final shippingAddress = {
        'address': '123 Main St', // Retrieve actual address if available
        'city': 'Cairo',
        'phone': _nameController.text.isNotEmpty
            ? 'N/A'
            : 'N/A', // Improve this later
      };

      // 3. Create Order in Supabase
      final orderId = await supabaseService.createOrder(
        totalAmount: cartProvider.totalPrice,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        items: cartProvider.items,
      );

      if (orderId == null) {
        throw Exception("Failed to create order");
      }

      print('✅ Order Created: $orderId');

      // 4. Clear Cart
      await cartProvider.clearCart();

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OrderPlacedSuccess()),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

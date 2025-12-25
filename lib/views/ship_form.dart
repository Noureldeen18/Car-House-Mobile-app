import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'payment/payment_view.dart';

class ShippingDataScreen extends StatefulWidget {
  const ShippingDataScreen({super.key});

  @override
  State<ShippingDataScreen> createState() => _ShippingDataScreenState();
}

class _ShippingDataScreenState extends State<ShippingDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  int _selectedDeliveryOption = 0;

  final List<Map<String, dynamic>> _deliveryOptions = [
    {
      'title': 'Standard Delivery',
      'subtitle': '5-7 business days',
      'price': 'Free',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'title': 'Express Delivery',
      'subtitle': '2-3 business days',
      'price': '50 EGP',
      'icon': Icons.rocket_launch_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
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
          "Shipping Details",
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
              _buildProgressIndicator(1),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle("Contact Information", Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter your phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Shipping Address
              _buildSectionTitle(
                "Shipping Address",
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: "Street Address",
                hint: "Enter your street address",
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _cityController,
                label: "City",
                hint: "Enter your city",
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 24),

              // Delivery Options
              _buildSectionTitle(
                "Delivery Method",
                Icons.local_shipping_outlined,
              ),
              const SizedBox(height: 12),
              ...List.generate(_deliveryOptions.length, (index) {
                final option = _deliveryOptions[index];
                final isSelected = _selectedDeliveryOption == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDeliveryOption = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            option['icon'],
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.textBlack,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                option['subtitle'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          option['price'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: option['price'] == 'Free'
                                ? Colors.green
                                : AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitForm,
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
                        "Continue to Payment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? "This field is required" : null,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentView()),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../models/schema_models.dart';

class ServiceBookingView extends StatefulWidget {
  const ServiceBookingView({super.key});

  @override
  State<ServiceBookingView> createState() => _ServiceBookingViewState();
}

class _ServiceBookingViewState extends State<ServiceBookingView> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  bool _isLoadingServices = true;

  List<ServiceType> _serviceTypes = [];
  List<ServiceTypeProduct> _currentServiceProducts = [];
  int _selectedServiceIndex = 0;
  bool _isLoadingProducts = false;

  // Icon mapping for service types
  final Map<String, IconData> _iconMapping = {
    '🛢️': Icons.oil_barrel,
    '🔧': Icons.build,
    '⚙️': Icons.settings,
    '🚗': Icons.car_repair,
    '💡': Icons.lightbulb,
    '🔍': Icons.search,
  };

  // ==================== Price Calculations ====================

  /// Get the base price of the selected service
  double get _serviceBasePrice {
    if (_serviceTypes.isEmpty) return 0;
    return _serviceTypes[_selectedServiceIndex].basePrice ?? 0;
  }

  /// Calculate subtotal of all spare parts included in the service
  double get _partsSubtotal {
    double total = 0;
    for (final item in _currentServiceProducts) {
      if (item.product != null) {
        total += item.product!.price * item.quantity;
      }
    }
    return total;
  }

  /// Calculate the overall subtotal (service + parts)
  double get _subtotal => _serviceBasePrice + _partsSubtotal;

  /// Calculate 14% tax
  double get _tax => _subtotal * 0.14;

  /// Calculate the total price including tax
  double get _totalPrice => _subtotal + _tax;

  // ==============================================================

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    try {
      final types = await SupabaseService().getServiceTypes();
      if (mounted) {
        setState(() {
          _serviceTypes = types;
          _isLoadingServices = false;
        });

        if (types.isNotEmpty) {
          _loadProductsForService(types[0].id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingServices = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _loadProductsForService(String serviceTypeId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
      _currentServiceProducts = [];
    });

    try {
      final products = await SupabaseService().getServiceProducts(
        serviceTypeId,
      );
      if (mounted) {
        setState(() {
          _currentServiceProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
        print("Error loading service products: $e");
      }
    }
  }

  @override
  void dispose() {
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_serviceTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No service types available'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledDateTime = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final selectedService = _serviceTypes[_selectedServiceIndex];

      await SupabaseService().createBooking(
        serviceTypeId: selectedService.id,
        serviceTypeName: selectedService.name,
        vehicleInfo: {
          'make': _vehicleMakeController.text,
          'model': _vehicleModelController.text,
          'year': _vehicleYearController.text,
        },
        scheduledDate: scheduledDateTime,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    if (_serviceTypes.isEmpty) return;

    final selectedService = _serviceTypes[_selectedServiceIndex];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Your ${selectedService.name} service has been scheduled.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
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
          "Book a Service",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingServices
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: 16),
                  Text(
                    "Loading services...",
                    style: TextStyle(color: AppColors.textDarkGray),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Type Selection
                    _buildSectionTitle("Select Service"),
                    _buildServiceTypeGrid(),

                    // Service Products (Parts)
                    if (_currentServiceProducts.isNotEmpty ||
                        _isLoadingProducts) ...[
                      _buildSectionTitle("Included Parts"),
                      _buildServiceProductsSection(),
                    ],

                    // Date & Time
                    _buildSectionTitle("Schedule"),
                    _buildDateTimeSection(),

                    // Vehicle Info
                    _buildSectionTitle("Vehicle Information"),
                    _buildVehicleInfoSection(),

                    // Notes
                    _buildSectionTitle("Additional Notes"),
                    _buildNotesSection(),

                    // Price Summary Section
                    _buildSectionTitle("Price Summary"),
                    _buildPriceSummarySection(),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Confirm Booking",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
      ),
    );
  }

  IconData _getIconForService(String? iconEmoji) {
    if (iconEmoji == null) return Icons.build;
    return _iconMapping[iconEmoji] ?? Icons.build;
  }

  Widget _buildServiceTypeGrid() {
    if (_serviceTypes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            "No services available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _serviceTypes.length,
      itemBuilder: (context, index) {
        final service = _serviceTypes[index];
        final isSelected = _selectedServiceIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedServiceIndex = index);
            _loadProductsForService(service.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey[200]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForService(service.icon),
                  size: 32,
                  color: isSelected ? Colors.white : AppColors.primaryBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.basePrice != null
                      ? "${service.basePrice!.toStringAsFixed(0)} EGP"
                      : "Contact us",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : AppColors.secondaryOrange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceProductsSection() {
    if (_isLoadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (_currentServiceProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140, // Height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _currentServiceProducts.length,
        itemBuilder: (context, index) {
          final item = _currentServiceProducts[index];
          final product = item.product;

          if (product == null) return const SizedBox.shrink();

          return Container(
            width: 120, // Card width
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.build_circle,
                              color: AppColors.primaryBlue,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item.quantity}x",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (product.price > 0)
                            Text(
                              "${product.price.toStringAsFixed(0)} EGP",
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _scheduledDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            "${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Time
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _scheduledTime,
                );
                if (time != null) setState(() => _scheduledTime = time);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          _scheduledTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _vehicleMakeController,
                  label: "Make",
                  hint: "e.g., Toyota",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _vehicleModelController,
                  label: "Model",
                  hint: "e.g., Camry",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _vehicleYearController,
            label: "Year",
            hint: "e.g., 2020",
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Any special requests or notes...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFF5F6F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        children: [
          // Service Fee
          if (_serviceBasePrice > 0)
            _buildPriceSummaryRow(
              "Service Fee",
              "${_serviceBasePrice.toStringAsFixed(0)} EGP",
            ),

          // Spare Parts (if any)
          if (_partsSubtotal > 0) ...[
            const SizedBox(height: 8),
            _buildPriceSummaryRow(
              "Spare Parts (${_currentServiceProducts.length} items)",
              "${_partsSubtotal.toStringAsFixed(0)} EGP",
            ),
          ],

          const SizedBox(height: 8),
          _buildPriceSummaryRow(
            "Subtotal",
            "${_subtotal.toStringAsFixed(0)} EGP",
          ),

          const SizedBox(height: 8),
          _buildPriceSummaryRow("Tax (14%)", "${_tax.toStringAsFixed(0)} EGP"),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          _buildPriceSummaryRow(
            "Total",
            "${_totalPrice.toStringAsFixed(0)} EGP",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textBlack : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryBlue : AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}

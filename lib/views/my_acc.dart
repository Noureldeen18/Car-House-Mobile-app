import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../services/supabase_service.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends State<MyAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final SupabaseService _service = SupabaseService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    try {
      final profile = await _service.getProfile();
      final user = _service.currentUser;

      if (mounted) {
        setState(() {
          _nameController.text = profile?.fullName ?? '';
          _phoneController.text = profile?.phone ?? '';
          _emailController.text = user?.email ?? '';
          _avatarUrl = profile?.avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final user = _service.currentUser;
      if (user == null) throw Exception("User not logged in");

      final file = File(pickedFile.path);
      final url = await _service.uploadProfileImage(file, user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = url;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile picture updated"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading image: $e"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveAccountData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Update profile in Supabase
      await _service.updateProfile(
        fullName: _nameController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Profile updated successfully"),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          "My Account",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image Section
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _avatarUrl != null
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                              child: _avatarUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
                          ),
                          if (_isUploading)
                            const Positioned.fill(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile section
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Full Name
                          _buildLabel("Full Name"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter your name"
                                : null,
                            decoration: _inputDecoration(
                              "Enter your full name",
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Phone
                          _buildLabel("Phone Number"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              "Enter your phone number",
                              Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email (read-only)
                          _buildLabel("Email"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: _inputDecoration(
                              "Email address",
                              Icons.email_outlined,
                            ).copyWith(fillColor: Colors.grey[100]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAccountData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
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
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 16,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textBlack,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: AppColors.accentGray),
      filled: true,
      fillColor: const Color(0xFFF5F6F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

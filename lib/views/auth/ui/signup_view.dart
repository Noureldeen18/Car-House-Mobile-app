import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../providers/supabase_auth_provider.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Header
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join us and start shopping",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Form
              const SignUpForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureText = true;
  bool _confirmObscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<SupabaseAuthProvider>(
      context,
      listen: false,
    );

    final error = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Account created successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          const Text(
            "Full Name",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
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

          // Email
          const Text(
            "Email",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              if (!value.contains('@')) {
                return "Please enter a valid email";
              }
              return null;
            },
            decoration: _inputDecoration(
              "Enter your email",
              Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Password
          const Text(
            "Password",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a password";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
            decoration:
                _inputDecoration(
                  "Create a password",
                  Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.accentGray,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  ),
                ),
          ),
          const SizedBox(height: 20),

          // Confirm Password
          const Text(
            "Confirm Password",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            obscureText: _confirmObscureText,
            validator: (value) => value == null || value.isEmpty
                ? "Please confirm your password"
                : null,
            decoration:
                _inputDecoration(
                  "Confirm your password",
                  Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmObscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.accentGray,
                    ),
                    onPressed: () {
                      setState(
                        () => _confirmObscureText = !_confirmObscureText,
                      );
                    },
                  ),
                ),
          ),
          const SizedBox(height: 32),

          // Sign Up button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                  : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.grey[600]),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

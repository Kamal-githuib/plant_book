// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/authentication/login_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class SignUpButton extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignUpButton({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  bool _isLoading = false;

  Future<void> _handleSignUp(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);

    // Input validation first
    if (widget.nameController.text.isEmpty ||
        widget.usernameController.text.isEmpty ||
        widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty ||
        widget.confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.passwordController.text !=
        widget.confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user via AuthProvider
      final result = await auth.signUp(
        widget.emailController.text.trim(),
        widget.passwordController.text.trim(),
      );

      if (result != null && result != true) {
        // signUp() returned an error message string
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Save user data using provider (document id = email)
      userProvider.setUserData(
        name: widget.nameController.text.trim(),
        username: widget.usernameController.text.trim(),
        email: widget.emailController.text.trim(),
      );
      await userProvider.saveUserDataToFirestore();

      // Navigate to login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleSignUp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.lightGray,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: responsive.fontSize(18, 24),
                  color: AppTheme.lightGray,
                ),
              ),
      ),
    );
  }
}

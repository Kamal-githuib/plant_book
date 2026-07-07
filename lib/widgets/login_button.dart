// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:plant_book/components/bottom_nav_bar.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class LoginButton extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context); // Access the AuthProvider
    final responsive = Responsive(context); // Responsive Screens
    return SizedBox(
      width: double.infinity, // Full width button
      child: ElevatedButton(
        onPressed:
            _isLoading // If loading, disable the button
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });

                final result = await auth.login(
                  widget.emailController.text.trim(),
                  widget.passwordController.text.trim(),
                );

                setState(() {
                  _isLoading = false;
                });

                // Check if the input fields are empty
                if (widget.emailController.text.isEmpty &&
                    widget.passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email and password.'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (widget.emailController.text.isEmpty) {
                  // Check if email is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email.'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (widget.passwordController.text.isEmpty) {
                  // Check if password is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your password.'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                else if (result != null) {
                  // If login fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your email or password is incorrect.'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BottomNavigation(),
                    ), // If login is successful, navigate to the TopBar page on successful login
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Your account has been logged in successfully!',
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isLoading // If loading, show a CircularProgressIndicator
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.lightGray,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                // If not loading, show the text 'Login'
                'Login',
                style: TextStyle(
                  fontSize: responsive.fontSize(18, 24),
                  color: AppTheme.lightGray,
                ),
              ),
      ),
    );
  }
}

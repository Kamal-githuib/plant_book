import 'package:flutter/material.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/firebase/firebase_auth.dart';
import 'package:plant_book/ui/root_page.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
      Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all fields.')),
          );
          return;
        }

        try {
          // Call the Login function from the Authentication class
          await Authentication().Login(email: email, password: password);

          // Navigate to the RootPage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RootPage()),
          );
        } catch (e) {
          // Display the error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: const Center(
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/components/bottom_nav_bar.dart';
import 'package:plant_book/screens/authentication/login_screen.dart';


class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to authentication state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // While waiting for the authentication state
          return const Center(child: CircularProgressIndicator()); // Show a loading indicator
        }
        if (snapshot.hasData) {
          // User is signed in
          return BottomNavigation();
        }
        // User is not signed in
        return const LoginPage();
      },
    );
  }
}
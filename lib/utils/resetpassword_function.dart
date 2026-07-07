import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final TextEditingController emailController = TextEditingController();

Future<void> sendPasswordReset(BuildContext context) async {
  final String email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your email.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset link sent! Check your email.'),
        backgroundColor: Colors.green,
      ),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Firebase Error: ${e.message}'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
  emailController.clear();
}

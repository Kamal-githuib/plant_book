// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  final _isLoading = false;
  bool get isLoading => _isLoading;

  // Email and Password Sign Up
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Email and Password Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
  try {
    await _auth.signOut();
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    // Firebase-specific exception
    print("FirebaseAuth Error during logout: ${e.message}");
    throw Exception("Logout failed: ${e.message}");
  } catch (e) {
    // Any other exception
    print("Unknown error during logout: $e");
    throw Exception("Logout failed: $e");
  }
}

}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_book/firebase/utils/exceptions.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> Signup({
    required String email,
    required String fullname,
    required String username,
    required String bio,
    required String password,
    required String passwordConfirm,
    String? profile,
  }) async {
    // Validate passwords match
    if (password != passwordConfirm) {
      throw exceptions('Passwords do not match.');
    }

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload profile image to Firebase Storage (optional)
      // String profileImageUrl = '';
      // if (profile.path.isNotEmpty) {
      //   Implement Firebase Storage upload here
      //   Example:
      //   final ref = FirebaseStorage.instance
      //       .ref()
      //       .child('profile_images/${userCredential.user!.uid}');
      //   await ref.putFile(profile);
      //   profileImageUrl = await ref.getDownloadURL();
      // }

      // Save user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullname': fullname,
        'username': username,
        'bio': bio,
        'profileImageUrl': profile,
        'password' : password,
        'confirmpassword' : passwordConfirm,
        'createdAt': DateTime.now(),
      });
    } on FirebaseAuthException catch (e) {
      throw exceptions(e.message ?? 'Authentication error');
    }
  }
   // Login Method
  Future<User?> Login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the authenticated user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw exceptions(e.message ?? 'Authentication error');
    }
  }

  // Logout Method (optional)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User (optional)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

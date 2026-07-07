// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/services/cloudinary_service.dart';

class PostsDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> uploadPostData({
    required String caption,
    required File image,
    required String? profileImageUrl,
    required String username,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final cloudinaryService = CloudinaryService();
      final imageUrl = await cloudinaryService.uploadFile(image);

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image upload failed"),
            backgroundColor: Colors.red,
          ),
        );
        _isSaving = false;
        notifyListeners();
        return;
      }

      final postRef = _firestore.collection('posts').doc();
      await postRef.set({
        'postId': postRef.id, // store postId inside document
        'caption': caption,
        // 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userEmail': user.email,
        'username': username,
        'profileImageUrl': profileImageUrl, // Placeholder for profile image URL
        'imageUrl': imageUrl['url'], // 👈 Use the uploaded image URL
        'publicId': imageUrl['public_id'], // 👈 Store public_id for deletion
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Post uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving post: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    _isSaving = false;
    notifyListeners();
  }

  // 🗑️ Delete post
  Future<void> deletePost({
    required String postId,
    required BuildContext context,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post not found ❌"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = docSnapshot.data();
      final publicId = data?['publicId'];

      if (publicId != null && publicId.isNotEmpty) {
        final cloudinaryService = CloudinaryService();
        await cloudinaryService.deleteImage(publicId);
      }

      await _firestore.collection('posts').doc(postId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Post deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting post: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

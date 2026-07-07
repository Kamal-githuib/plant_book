// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  bool _isPosting = false;
  bool get isPosting => _isPosting;

  Future<void> addComment({
    required String postId,
    required String text,
    required String username,
    required String? profileImageUrl,
  }) async {
    if (user == null || text.trim().isEmpty) return;

    try {
      _isPosting = true;
      notifyListeners();

      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc();

      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(postId);

        // ✅ Add comment
        transaction.set(commentRef, {
          'text': text.trim(),
          'userEmail': user!.email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
          'profileImageUrl': profileImageUrl ?? '', // Use user's profile image URL
        });

        // ✅ Increment comment count
        transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
      });

      _isPosting = false;
      notifyListeners();
    } catch (e) {
      _isPosting = false;
      debugPrint("Error adding comment: $e");
      notifyListeners();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🗑 Optional: delete comment and decrease counter
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(postId);
        final commentRef = _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId);

        transaction.delete(commentRef);
        transaction.update(postRef, {'commentCount': FieldValue.increment(-1)});
      });
    } catch (e) {
      debugPrint("Error deleting comment: $e");
    }
  }

   /// Report a post
  Future<void> reportPost({
    required String postId,
    required Map<String, dynamic> postData,
    required String reason,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'reported by': user!.email, 
        'postId': postId,
        'postData': postData,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Post reported successfully");
    } catch (e) {
      debugPrint("⚠️ Error reporting post: $e");
      rethrow;
    }
  }
}

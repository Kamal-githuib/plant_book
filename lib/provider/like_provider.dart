import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LikeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  final Map<String, bool> _likedPosts = {};
  final Map<String, bool> _dislikedPosts = {};

  final Map<String, int> _likeCounts = {};
  final Map<String, int> _dislikeCounts = {};

  bool isLiked(String postId) => _likedPosts[postId] ?? false;
  bool isDisliked(String postId) => _dislikedPosts[postId] ?? false;

  int likeCount(String postId) => _likeCounts[postId] ?? 0;
  int dislikeCount(String postId) => _dislikeCounts[postId] ?? 0;

  // 🔄 Fetch like/dislike state from Firestore for a specific post
  Future<void> fetchPostLikeState(String postId) async {
    if (user == null) return;

    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final dislikedBy = List<String>.from(data['dislikedBy'] ?? []);

        _likedPosts[postId] = likedBy.contains(user!.email);
        _dislikedPosts[postId] = dislikedBy.contains(user!.email);

        // store counts
        _likeCounts[postId] = likedBy.length;
        _dislikeCounts[postId] = dislikedBy.length;

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching like state: $e");
    }
  }

  // 👍 Like a post
  Future<void> likePost(String postId, String userEmail) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likedBy': FieldValue.arrayUnion([userEmail]),
        'dislikedBy': FieldValue.arrayRemove([userEmail]),
      });

      _likedPosts[postId] = true;
      _dislikedPosts[postId] = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error liking post: $e");
    }
  }

  // 👎 Dislike a post
  Future<void> dislikePost(String postId, String userEmail) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'dislikedBy': FieldValue.arrayUnion([userEmail]),
        'likedBy': FieldValue.arrayRemove([userEmail]),
      });

      _dislikedPosts[postId] = true;
      _likedPosts[postId] = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error disliking post: $e");
    }
  }

  // 🔘 Toggle Like button logic
  Future<void> toggleLike(String postId) async {
    if (user == null || user!.email == null) return;
    final userEmail = user!.email!;

    final alreadyLiked = _likedPosts[postId] ?? false;

    if (alreadyLiked) {
      // 👇 Remove like
      await _firestore.collection('posts').doc(postId).update({
        'likedBy': FieldValue.arrayRemove([userEmail]),
      });
      _likedPosts[postId] = false;
    } else {
      // 👇 Add like
      await likePost(postId, userEmail);
    }

    notifyListeners();
  }

  // 🔘 Toggle Dislike button logic
  Future<void> toggleDislike(String postId) async {
    if (user == null || user!.email == null) return;
    final userEmail = user!.email!;

    final alreadyDisliked = _dislikedPosts[postId] ?? false;

    if (alreadyDisliked) {
      // 👇 Remove dislike
      await _firestore.collection('posts').doc(postId).update({
        'dislikedBy': FieldValue.arrayRemove([userEmail]),
      });
      _dislikedPosts[postId] = false;
    } else {
      // 👇 Add dislike
      await dislikePost(postId, userEmail);
    }

    notifyListeners();
  }
}

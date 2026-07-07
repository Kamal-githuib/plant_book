import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_book/services/cloudinary_service.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _username = '';
  String _email = '';
  String? _imageUrl;
  String _bio = '';
  String? _publicId;

  // Getters
  String get name => _name;
  String get username => _username;
  String get email => _email;
  String? get imageUrl => _imageUrl;
  String? get publicId => _publicId;
  String get bio => _bio;

  // Check if data is loaded
  bool get isUserDataLoaded => _email.isNotEmpty;

  /// ✅ Set user data locally
  void setUserData({
    required String name,
    required String username,
    required String email,
    String? bio,
    String? imageUrl,
    String? publicId,
  }) {
    _name = name;
    _username = username;
    _email = email;
    _bio = bio ?? '';
    _imageUrl = imageUrl;
    _publicId = publicId;
    notifyListeners();
  }

  // 🖼️ Profile Image
  File? _imageFile;
  File? get imageFile => _imageFile;

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();

  /// ✅ Pick Image (Camera or Gallery)
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();

      // Automatically upload and save after picking
      await uploadAndSaveProfileImage(_imageFile!);
    }
  }

  /// ✅ Upload profile image to Cloudinary and save to Firestore
  Future<void> uploadAndSaveProfileImage(File file) async {
    try {
      // 🧩 Upload to Cloudinary
      final uploadData = await _cloudinary.uploadFile(file);

      if (uploadData != null) {
        final url = uploadData['url'];
        final publicId = uploadData['public_id'];

        // Delete old image (optional, if it exists)
        if (_publicId != null && _publicId!.isNotEmpty) {
          await _cloudinary.deleteImage(_publicId!);
        }

        _imageUrl = url;
        _publicId = publicId;
        notifyListeners();

        // 🧩 Save URL and publicId in Firestore
        await _firestore.collection('users').doc(_email).set({
          'imageUrl': _imageUrl,
          'publicId': _publicId,
        }, SetOptions(merge: true));

        final postsSnapshot = await _firestore
            .collection('posts')
            .where('userEmail', isEqualTo: _email)
            .get();

        for (var doc in postsSnapshot.docs) {
          await doc.reference.update({'profileImageUrl': _imageUrl});
        }
        final commentsSnapshot = await _firestore
            .collectionGroup("comments")
            .where('userEmail', isEqualTo: _email)
            .get();

        final batch = _firestore.batch();

        for (var doc in commentsSnapshot.docs) {
          batch.update(doc.reference, {'profileImageUrl': _imageUrl});
        }

        await batch.commit();

        // 🧩 Update profile image inside all chats’ `profileImages` map
        final chatsSnapshot = await _firestore
            .collection('chats')
            .where('users', arrayContains: _email)
            .get();

        for (var chatDoc in chatsSnapshot.docs) {
          final chatData = chatDoc.data();

          // Get the profileImages map (if not exists, create one)
          final Map<String, dynamic> profileImages = Map<String, dynamic>.from(
            chatData['profileImages'] ?? {},
          );

          // Update this user’s image only
          profileImages[_email] = _imageUrl;

          await chatDoc.reference.update({'profileImages': profileImages});
        }

        debugPrint("✅ Profile image updated everywhere successfully!");
      }
    } catch (e) {
      debugPrint("⚠️ Error uploading profile image: $e");
      notifyListeners();
    }
  }

  /// ✅ Save user data to Firestore (document ID = user email)
  Future<void> saveUserDataToFirestore() async {
    try {
      await _firestore.collection('users').doc(_email).set({
        'name': _name,
        'username': _username,
        'email': _email,
        'imageUrl': _imageUrl,
        'publicId': _publicId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  /// ✅ Fetch current user data from Firestore
  Future<void> fetchUserDataFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        debugPrint("No logged-in user found");
        return;
      }

      final doc = await _firestore.collection('users').doc(user.email).get();

      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? '';
        _username = data['username'] ?? '';
        _email = data['email'] ?? '';
        _bio = data['bio'] ?? '';
        _imageUrl = data['imageUrl'];
        _publicId = data['publicId'];
        notifyListeners();
      } else {
        debugPrint("User document not found in Firestore.");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  /// ✅ Clear user data on logout
  void clearUserData() {
    _name = '';
    _username = '';
    _email = '';
    _imageUrl = null;
    _publicId = null;
    notifyListeners();
  }

  /// ✅ Update username
 Future<void> updateUsername(String newUsername) async {
  try {
    if (_email.isEmpty) {
      throw Exception("No email found for the current user.");
    }

    newUsername = newUsername.trim();

    if (newUsername.isEmpty) {
      throw Exception("Username cannot be empty.");
    }

    // 🔹 Check if username already exists for another user
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: newUsername)
        .get();

    if (usernameQuery.docs.isNotEmpty &&
        usernameQuery.docs.any((doc) => doc.id != _email)) {
      throw Exception("Username '$newUsername' is already taken.");
    }

    // 🔹 Update local state
    _username = newUsername;
    notifyListeners();

    // 🔹 Update in users collection
    await _firestore.collection('users').doc(_email).set({
      'username': newUsername,
    }, SetOptions(merge: true));

    // 🔹 Update username in all user's posts
    final postsSnapshot = await _firestore
        .collection('posts')
        .where('userEmail', isEqualTo: _email)
        .get();

    if (postsSnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in postsSnapshot.docs) {
        batch.update(doc.reference, {'username': newUsername});
      }
      await batch.commit();
      debugPrint("✅ Updated username in all posts");
    }

    // 🔹 Update username in all comments made by user
    final commentSnapshot = await _firestore
        .collectionGroup('comments')
        .where('userEmail', isEqualTo: _email)
        .get();

    if (commentSnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in commentSnapshot.docs) {
        batch.update(doc.reference, {'username': newUsername});
      }
      await batch.commit();
      debugPrint("✅ Updated username in all comments");
    }

    debugPrint("🎉 Username updated successfully everywhere!");
  } catch (e) {
    debugPrint("❌ Error updating username: $e");
    // Re-throw the exception so the UI can catch it and show a Snackbar
    throw e;
  }
}


  /// ✅ Update name
  Future<void> updateName(String newName) async {
    try {
      _name = newName;
      notifyListeners();
      await _firestore.collection('users').doc(_email).set({
        'name': newName,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating name: $e");
    }
  }

  /// ✅ Update bio
  Future<void> updateBio(String newBio) async {
    try {
      _bio = newBio;
      notifyListeners();
      await _firestore.collection('users').doc(_email).set({
        'bio': newBio,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating bio: $e");
    }
  }

  /// ✅ Update password (Firebase Auth)
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No logged-in user");

      await user.updatePassword(newPassword);
      debugPrint("✅ Password updated successfully!");
    } catch (e) {
      debugPrint("Error updating password: $e");
      rethrow;
    }
  }
}

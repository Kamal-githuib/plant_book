// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant_book/services/cloudinary_service.dart';

class PlantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String? selectedCity;
  String? selectedCountry;

  /// ✅ Upload image to Cloudinary and save plant data to Firestore
  Future<void> savePlantData({
    required String name,
    required String description,
    required String contact,
    required String category,
    required String amount,
    required String username,
    required String? profileImage,
    required File image,
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
      // ✅ Upload image to Cloudinary
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

      // ✅ Save plant data to Firestore
      await _firestore.collection('plants').add({
        'name': name,
        'description': description,
        'contact': contact,
        'category': category,
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
        'userEmail': user.email,
        'profileImage': profileImage ?? '',
        'username': username, // 👈 Add username here
        'imageUrl': imageUrl['url'], // 👈 Use the uploaded image URL
        'publicId': imageUrl['public_id'], // 👈 Store public_id for deletion
        'city': selectedCity ?? '', // ✅ Add this
        'country': selectedCountry ?? '', // ✅ Add this
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🌿 Plant added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving plant: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    _isSaving = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set location from dropdown
  void setLocation({required String city, required String country}) {
    selectedCity = city;
    selectedCountry = country;
    notifyListeners();
  }

  /// Clear selected location
  void clearLocation() {
    selectedCity = null;
    selectedCountry = null;
    notifyListeners();
  }

  /// Fetch city suggestions from Nominatim API
  Future<List<Map<String, String>>> fetchCities(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?city=$query&format=json&limit=10',
    );
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'PlantBookApp', // Nominatim requires a User-Agent
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Map<String, String>>((item) {
        final displayName = item['display_name'] ?? '';
        final parts = displayName.split(',');
        final city = parts.isNotEmpty ? parts[0].trim() : '';
        final country = parts.length > 1 ? parts.last.trim() : '';
        return {'city': city, 'country': country};
      }).toList();
    }
    return [];
  }

  /// ✅ Real-time stream of all plants
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchPlants() {
    Query<Map<String, dynamic>> query = _firestore.collection('plants');
    if (_selectedCategory == 'All') {
      return query.snapshots();
    } else {
      return query
          .where('category', isEqualTo: _selectedCategory)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  /// 🗑️ Delete a plant by its Firestore document ID
  Future<void> deletePlant({
    required String plantId,
    required BuildContext context,
  }) async {
    try {
      // ✅ Step 1: Fetch document to get the Cloudinary publicId
      final docSnapshot = await _firestore
          .collection('plants')
          .doc(plantId)
          .get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Plant not found ❌"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = docSnapshot.data();
      final publicId = data?['publicId'];

      // ✅ Step 2: Delete the image from Cloudinary
      if (publicId != null && publicId.isNotEmpty) {
        final cloudinaryService = CloudinaryService();
        await cloudinaryService.deleteImage(publicId);
      }

      // ✅ Step 3: Delete the Firestore document
      await _firestore.collection('plants').doc(plantId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Plant deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting plant: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

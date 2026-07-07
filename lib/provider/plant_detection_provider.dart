import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlantDetectionProvider with ChangeNotifier {
  final String _plantIdApiKey = 'JTortcKVSHCKlIsQKCLnSGH1dUW0AGINVBwLMyjAJeVg5NKmNy';
  final String _trefleApiToken = 'usr-tR_bZUkMyveo20vdbfL0pzO9roFNAYQAKJE06-R_qEg';

  bool _isLoading = false;
  File? _image;
  String? _plantName;
  String? _species;
  String? _family;
  String? _genus;
  String? _plantImage;
  String? _error;

  bool get isLoading => _isLoading;
  File? get image => _image;
  String? get plantName => _plantName;
  String? get species => _species;
  String? get family => _family;
  String? get genus => _genus;
  String? get plantImage => _plantImage;
  String? get error => _error;

  void setImage(File img) {
    _image = img;
    notifyListeners();
  }

  /// Main function: identify plant by image
  Future<void> identifyPlant(File img) async {
    _isLoading = true;
    _image = img;
    _plantName = null;
    _species = null;
    _family = null;
    _genus = null;
    _plantImage = null;
    _error = null;
    notifyListeners();

    try {
      final plantName = await _getPlantNameFromPlantId(img);
      if (plantName != null) {
        await _getPlantDetailsFromTrefle(plantName);
      } else {
        _error = 'Plant.id could not identify the plant.';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Step 1: Send image to Plant.id API
  Future<String?> _getPlantNameFromPlantId(File image) async {
    final bytes = await image.readAsBytes();
    final response = await http.post(
      Uri.parse('https://api.plant.id/v2/identify'),
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': _plantIdApiKey,
      },
      body: jsonEncode({
        'images': [base64Encode(bytes)],
        'organs': ['leaf', 'flower'],
      }),
    );

    final data = jsonDecode(response.body);
    if (data['suggestions'] != null && data['suggestions'].isNotEmpty) {
      return data['suggestions'][0]['plant_name'];
    }
    return null;
  }

  /// Step 2: Fetch plant details from Trefle API
  Future<void> _getPlantDetailsFromTrefle(String query) async {
    final url = Uri.parse(
        'https://trefle.io/api/v1/plants/search?token=$_trefleApiToken&q=$query');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['data'] != null && data['data'].isNotEmpty) {
      final plant = data['data'][0];
      _plantName = plant['common_name'] ?? query;
      _species = plant['scientific_name'] ?? 'Unknown';
      _family = plant['family'] ?? 'Unknown';
      _genus = plant['genus'] ?? 'Unknown';
      _plantImage = plant['image_url'] ?? '';
    } else {
      _error = 'No results found in Trefle.';
    }
  }
}

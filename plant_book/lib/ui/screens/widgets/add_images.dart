import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_book/constants.dart';

class AddPhotoPage extends StatefulWidget {
  const AddPhotoPage({super.key});

  @override
  _AddPhotoPageState createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<AddPhotoPage> {
  File? _imageFile; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  // Function to pick image from the gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Function to capture image using the camera
  Future<void> _captureImageFromCamera() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display selected image
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.image,
                    size: 200,
                    color: Colors.grey,
                  ),
            const SizedBox(height: 20),
            // Buttons for Gallery and Camera
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: Icon(
                Icons.photo_library,
                color: Constants.primaryColor,
              ),
              label: Text(
                'Pick from Gallery',
                style: TextStyle(color: Constants.primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _captureImageFromCamera,
              icon: Icon(
                Icons.camera_alt,
                color: Constants.primaryColor,
              ),
              label: Text(
                'Capture from Camera',
                style: TextStyle(color: Constants.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

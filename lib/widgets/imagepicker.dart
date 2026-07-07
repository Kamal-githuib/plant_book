// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_book/styles/apptheme.dart';

class PlantImagePicker extends StatefulWidget {
  final Function(File) onImagePicked;

  const PlantImagePicker({super.key, required this.onImagePicked});

  @override
  State<PlantImagePicker> createState() => _PlantImagePickerState();
}

class _PlantImagePickerState extends State<PlantImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _pickedImage = File(image.path));
      widget.onImagePicked(_pickedImage!);
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      backgroundColor: AppTheme.darkGray,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.green),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.green),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: _pickedImage == null
                ? Container(
                    color: AppTheme.green.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.image, color: AppTheme.green, size: 48),
                    ),
                  )
                : Image.file(_pickedImage!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

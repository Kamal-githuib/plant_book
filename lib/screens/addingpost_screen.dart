import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/textfield.dart';
import 'package:plant_book/widgets/imagepicker.dart';
import 'package:plant_book/widgets/uploadpost_button.dart';

class AddingPostScreen extends StatefulWidget {
  const AddingPostScreen({super.key});

  @override
  State<AddingPostScreen> createState() => _AddingPostScreenState();
}

class _AddingPostScreenState extends State<AddingPostScreen> {
  final TextEditingController captionController = TextEditingController();

  File? selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Upload Post',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.green,
                  ),
                ),
                const SizedBox(height: 20),
                PlantImagePicker(
                  onImagePicked: (file) {
                    setState(() => selectedImage = file);
                  },
                ),
                const SizedBox(height: 15),

                // Caption
                CustomTextField(
                  controller: captionController,
                  hint: 'Caption',
                  obscure: false,
                  icon: Icons.text_fields,
                ),
                const SizedBox(height: 30),
                // Upload Button
                UploadPostButton(
                  captionController: captionController,
                  selectedImage: selectedImage,
                  onSuccess: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

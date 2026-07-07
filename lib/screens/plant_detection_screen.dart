// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_book/provider/plant_detection_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class PlantDetectionScreen extends StatelessWidget {
  const PlantDetectionScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final provider = Provider.of<PlantDetectionProvider>(
        context,
        listen: false,
      );
      await provider.identifyPlant(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        title: const Text(
          'Plant Identifier',
          style: TextStyle(
            color: AppTheme.lightGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.green,
      ),
      body: Consumer<PlantDetectionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Card(
                    color: AppTheme.darkGray,
                    elevation: 20,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          Container(
                            height: 280,
                            width: 280,
                            color: AppTheme.darkGray,
                            child: provider.image != null
                                ? Image.file(provider.image!, fit: BoxFit.fill)
                                : const Icon(
                                    Icons.image,
                                    size: 100,
                                    color: AppTheme.lightGray,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          if (provider.isLoading)
                            const CircularProgressIndicator()
                          else if (provider.error != null)
                            Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                            )
                          else if (provider.plantName != null)
                            Column(
                              children: [
                                Text(
                                  "Plant name ${provider.plantName!}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Species: ${provider.species ?? 'Unknown'}",
                                  style: TextStyle(
                                    color: AppTheme.lightGray,
                                    fontSize: responsive.fontSize(14, 20),
                                  ),
                                ),
                                Text(
                                  "Family: ${provider.family ?? 'Unknown'}",
                                  style: TextStyle(
                                    color: AppTheme.lightGray,
                                    fontSize: responsive.fontSize(14, 20),
                                  ),
                                ),
                                Text(
                                  "Genus: ${provider.genus ?? 'Unknown'}",
                                  style: TextStyle(
                                    color: AppTheme.lightGray,
                                    fontSize: responsive.fontSize(14, 20),
                                  ),
                                ),
                                if (provider.plantImage != null &&
                                    provider.plantImage!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.network(
                                      provider.plantImage!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickImage(context, ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 40,
                      ),
                    ),
                    child: Text(
                      "Take a Photo",
                      style: TextStyle(
                        fontSize: responsive.fontSize(18, 24),
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 40,
                      ),
                    ),
                    child: Text(
                      "Pick from Gallery",
                      style: TextStyle(
                        fontSize: responsive.fontSize(18, 24),
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

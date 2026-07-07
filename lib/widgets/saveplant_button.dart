import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_book/provider/plantdata_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class SavePlantButton extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController contactController;
  final TextEditingController amountController;
  final String? selectedCategory;
  final File? selectedImage;
  final VoidCallback onSuccess;

  const SavePlantButton({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.contactController,
    required this.amountController,
    required this.selectedCategory,
    required this.selectedImage,
    required this.onSuccess,
  });

  @override
  State<SavePlantButton> createState() => _SavePlantButtonState();
}

class _SavePlantButtonState extends State<SavePlantButton> {
  Future<void> _savePlantData() async {
    final name = widget.nameController.text.trim();
    final description = widget.descriptionController.text.trim();
    final contact = widget.contactController.text.trim();
    final category = widget.selectedCategory;
    final amount = widget.amountController.text.trim();
    final image = widget.selectedImage;


    if (name.isEmpty ||
        description.isEmpty ||
        contact.isEmpty ||
        category == null ||
        image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
      final userData = Provider.of<UserDataProvider>(context);
    final username = userData.username;
    final profileImage = userData.imageUrl ?? '';
    await plantProvider.savePlantData(
      name: name,
      description: description,
      contact: contact,
      category: category,
      amount: amount,
      username: username,
      profileImage: profileImage,
      image: image,
      context: context,
      onSuccess: widget.onSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<PlantProvider>().isSaving;

    return ElevatedButton(
      onPressed: isSaving ? null : () => _savePlantData(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.green,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isSaving
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppTheme.lightGray,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              'Save Plant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
    );
  }
}

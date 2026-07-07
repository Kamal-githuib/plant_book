// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/textfield.dart';
import 'package:plant_book/widgets/imagepicker.dart';
import 'package:plant_book/widgets/location_selector.dart';
import 'package:plant_book/widgets/saveplant_button.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  File? selectedImage;
  String? selectedCategory;

  final List<String> categories = ['Flower', 'Plant', 'Tree'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: const Text(
                    'Donate Your Plant',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.green,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PlantImagePicker(
                  onImagePicked: (file) {
                    setState(() => selectedImage = file);
                  },
                ),
                const SizedBox(height: 20),

                // 🌱 Name field
                CustomTextField(
                  controller: nameController,
                  hint: 'Name',
                  obscure: false,
                  icon: Icons.eco,
                ),
                const SizedBox(height: 15),

                // 🌼 Description
                CustomTextField(
                  controller: descriptionController,
                  hint: 'Description',
                  obscure: false,
                  icon: Icons.description,
                ),
                const SizedBox(height: 15),

                // 📞 Contact
                CustomTextField(
                  controller: contactController,
                  hint: 'Contact',
                  obscure: false,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 15),

                // Amount
                CustomTextField(
                  controller: amountController,
                  hint: 'Amount',
                  obscure: false,
                  icon: Icons.money,
                ),
                const SizedBox(height: 15),

                // 🌻 Category dropdown
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(20),
                  dropdownColor: AppTheme.darkGray,
                  style: const TextStyle(color: AppTheme.lightGray),
                  decoration: const InputDecoration(
                    hintText: 'Select Category',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.category, color: AppTheme.green),
                  ),
                  value: selectedCategory,
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value),
                ),
                const SizedBox(height: 15),

                LocationSelector(),
                const SizedBox(height: 30),

                // 💾 Save Button
                Center(
                  child: SavePlantButton(
                    nameController: nameController,
                    descriptionController: descriptionController,
                    contactController: contactController,
                    selectedCategory: selectedCategory,
                    amountController: amountController,
                    selectedImage: selectedImage,
                    onSuccess: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

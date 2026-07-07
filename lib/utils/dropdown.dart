import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.category, color: AppTheme.green),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.green),
                  isExpanded: true,
                  hint: const Text(
                    "Select Category",
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: ['Flower', 'Plant', 'Tree'].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (item) => onChanged(item),
                  dropdownColor: AppTheme.darkGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/provider/plantdata_provider.dart';
import 'package:plant_book/screens/plantdetail.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class PlantAdoptionPage extends StatelessWidget {
  const PlantAdoptionPage({super.key});
  final List<String> plantTypes = const ['All', 'Flower', 'Tree', 'Plant'];
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final plantProvider = Provider.of<PlantProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        title: Text(
          "Plant Adoption",
          style: TextStyle(
            color: AppTheme.lightGray,
            fontWeight: FontWeight.bold,
            fontSize: responsive.fontSize(22, 26),
          ),
        ),
        backgroundColor: AppTheme.green,
      ),

      // ✅ Real-time plant list with filtering
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 🌱 Plant Categories
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 50.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plantTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final category = plantTypes[index];
                final isSelected = category == plantProvider.selectedCategory;

                return GestureDetector(
                  onTap: () => plantProvider.setCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.green.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.green
                            : AppTheme.lightGrayBlue.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w300,
                          color: isSelected
                              ? AppTheme.green
                              : AppTheme.lightGray,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 📋 Plant List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: Provider.of<PlantProvider>(
                context,
                listen: false,
              ).fetchPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No plants available 🌱",
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                  );
                }

                final plants = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final doc = plants[index];
                    final plant = doc.data();
                    final plantId =
                        doc.id; //  This is the Firestore document ID

                    return Card(
                      color: AppTheme.darkGray,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 10,
                      child: Row(
                        children: [
                          // 🌿 Plant Image
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              image: plant['imageUrl'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(plant['imageUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: plant['imageUrl'] == null
                                ? Icon(
                                    Icons.local_florist,
                                    color: AppTheme.lightGrayBlue,
                                    size: responsive.isTablet ? 60 : 40,
                                  )
                                : null,
                          ),

                          // 📝 Plant Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plant['name'] ?? "Unknown",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.lightGray,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Category: ${plant['category'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.lightGrayBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Price: \$${plant['amount'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.lightGray,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlantDetail(
                                              plantData: plant,
                                              plantId: plantId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "View Details",
                                        style: TextStyle(
                                          fontSize: responsive.fontSize(12, 16),
                                          color: AppTheme.lightGrayBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

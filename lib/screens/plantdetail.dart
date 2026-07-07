// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/provider/plantdata_provider.dart';
import 'package:plant_book/screens/chating_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class PlantDetail extends StatelessWidget {
  final Map<String, dynamic> plantData;
  final String plantId;

  const PlantDetail({
    super.key,
    required this.plantData,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final userEmail = auth.user?.email ?? '';
    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
    final userProfileImage = plantData['profileImage'] ?? '';
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      body: Stack(
        children: [
          // 🔙 Top Actions
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plantData['name'] ?? "Unknown Plant",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
              ],
            ),
          ),

          // 🌿 Plant Details Section
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            bottom: 100,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPlantImage(plantData['imageUrl']),
                  const SizedBox(height: 20),
                  Text(
                    "Posted by: ${plantData['username']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Price: \$${plantData['amount']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Location: ${plantData['city'] ?? 'N/A'}, ${plantData['country'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Contact: ${plantData['contact'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    plantData['description'] ??
                        "No description available for this plant.",
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      height: 1.5,
                      fontSize: 18,
                      color: AppTheme.lightGrayBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 💬 Bottom Message Button for other users and delete button for owner
      bottomNavigationBar: (plantData['userEmail'] == userEmail)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                onPressed: () async {
                  // 🗑️ Delete Plant Post
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.darkGray,
                      title: const Text(
                        'Delete Plant',
                        style: TextStyle(color: AppTheme.lightGray),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this plant?',
                        style: TextStyle(color: AppTheme.lightGray),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await plantProvider.deletePlant(
                      plantId: plantId, // 👈 Use document ID
                      context: context,
                    );
                    Navigator.pop(context); // go back after deleting
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Delete Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  // 🔗 Optional: Navigate to chat page later
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        receiverEmail: plantData['userEmail'],
                        receiverName: plantData['username'] ?? 'Unknown',
                        receiverProfileImage: userProfileImage,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Direct Message",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  // 🌱 Dynamic Image Loader
  Widget _buildPlantImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppTheme.darkGray,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightGray,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: imageUrl == null || imageUrl.isEmpty
              ? Container(
                  color: Colors.green.withOpacity(0.2),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.green, size: 48),
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.green.withOpacity(0.2),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

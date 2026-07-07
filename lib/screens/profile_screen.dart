// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_book/components/drawer.dart';
import 'package:plant_book/components/post_card.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/plantdetail.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/widgets/counter_widget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = Provider.of<UserDataProvider>(context);
    // final responsive = Responsive(context);

    // Fetch user data if not already loaded
    if (!userData.isUserDataLoaded) {
      userData.fetchUserDataFromFirestore();
    }

    final userEmail = auth.user?.email ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.darkGray,
        appBar: AppBar(
          title: Text(
            "Profile",
            style: const TextStyle(
              color: AppTheme.lightGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.green,
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // 👤 Profile Header
            Container(
              color: AppTheme.darkGray,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.green,
                        backgroundImage: userData.imageFile != null
                            ? FileImage(userData.imageFile!) as ImageProvider
                            : (userData.imageUrl != null &&
                                  userData.imageUrl!.isNotEmpty)
                            ? NetworkImage(userData.imageUrl!)
                            : null,
                        child:
                            (userData.imageFile == null &&
                                (userData.imageUrl == null ||
                                    userData.imageUrl!.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.lightGray,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final choice =
                                await showModalBottomSheet<ImageSource>(
                                  backgroundColor: AppTheme.darkGray,
                                  context: context,
                                  builder: (_) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.camera_alt,
                                            color: AppTheme.green,
                                          ),
                                          title: Text(
                                            'Camera',
                                            style: TextStyle(
                                              color: AppTheme.lightGray,
                                            ),
                                          ),
                                          onTap: () => Navigator.pop(
                                            context,
                                            ImageSource.camera,
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            Icons.photo_library,
                                            color: AppTheme.green,
                                          ),
                                          title: Text(
                                            'Gallery',
                                            style: TextStyle(
                                              color: AppTheme.lightGray,
                                            ),
                                          ),
                                          onTap: () => Navigator.pop(
                                            context,
                                            ImageSource.gallery,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                            if (choice != null) {
                              await userData.pickImage(choice);
                            }
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme
                                  .green, // background for the plus icon
                              border: Border.all(
                                color:
                                    Colors.white, // white border for contrast
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData.name.isNotEmpty
                              ? userData.name
                              : "Loading...",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.lightGray,
                          ),
                        ),
                        Text(
                          userData.bio.isNotEmpty
                              ? userData.bio
                              : "Plant Lover 🌱",
                          style: TextStyle(color: AppTheme.lightGrayBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 📊 Counters (Posts & Plants)
                  Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .where('userEmail', isEqualTo: userEmail)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final postCount = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return buildCounter("Posts", postCount);
                        },
                      ),
                      // const SizedBox(width: 40),
                      SizedBox(
                        height: 25,
                        child: VerticalDivider(
                          color: AppTheme.gray,
                          thickness: 1,
                          width: 20, // spacing between items
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('plants')
                            .where('userEmail', isEqualTo: userEmail)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final plantCount = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return buildCounter("Plants", plantCount);
                        },
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),

            // 🔖 Tabs
            Container(
              color: AppTheme.green,
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "Posts"),
                  Tab(text: "Plants"),
                ],
              ),
            ),

            // 📂 Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // 🌿 POSTS TAB
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userEmail', isEqualTo: userEmail)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.green,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No posts yet 🌱",
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        );
                      }

                      final posts = snapshot.data!.docs.map((doc) {
                        final data = doc.data();
                        return {
                          'id': doc.id,
                          'username': data['username'] ?? 'Anonymous',
                          'title': data['caption'] ?? '',
                          'time': (data['createdAt'] as Timestamp?)?.toDate(),
                          'profileImageUrl': data['profileImageUrl'] ?? '',

                          'imageUrl': data['imageUrl'] ?? '',
                          'comments': data['comments'] ?? [],
                          'userEmail': data['userEmail'] ?? '',
                        };
                      }).toList();

                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(post: post, postId: post['id']);
                        },
                      );
                    },
                  ),

                  // 🌱 PLANTS TAB
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('plants')
                        .where('userEmail', isEqualTo: userEmail)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.green,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final plants = snapshot.data?.docs ?? [];
                      if (plants.isEmpty) {
                        return const Center(
                          child: Text(
                            "No plants available 🌿",
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          final plant =
                              plants[index].data() as Map<String, dynamic>;
                          final doc = plants[index];
                          // final plant = doc.data();
                          final plantId =
                              doc.id; // 👈 This is the Firestore document ID
                          return GestureDetector(
                            onTap: () {
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
                            child: Card(
                              color: AppTheme.darkGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: plant['imageUrl'] != null
                                          ? Image.network(
                                              plant['imageUrl'],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: Colors.green.withOpacity(
                                                0.2,
                                              ),
                                              child: const Icon(
                                                Icons.local_florist,
                                                color: AppTheme.lightGrayBlue,
                                                size: 50,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      plant['name'] ?? "Unknown",
                                      style: const TextStyle(
                                        color: AppTheme.lightGray,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

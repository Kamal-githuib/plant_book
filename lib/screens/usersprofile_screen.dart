// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_book/components/post_card.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/chating_screen.dart';
import 'package:plant_book/screens/plantdetail.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/widgets/counter_widget.dart';
import 'package:provider/provider.dart';

class OtherUserProfilePage extends StatelessWidget {
  final String otherUserEmail; //  Email of the user to view
  final String otherUsername; //  Optional, can fetch from Firestore too

  const OtherUserProfilePage({
    super.key,
    required this.otherUserEmail,
    required this.otherUsername,
  });

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.darkGray,
        appBar: AppBar(
          title: Text(
            otherUsername,
            style: const TextStyle(
              color: AppTheme.lightGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.green,
        ),
        body: Column(
          children: [
            // 👤 Profile Header
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserEmail)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.green),
                    ),
                  );
                }

                final data = snapshot.data!.data() ?? {};
                final name = data['name'] ?? 'Unknown';
                final bio = data['bio'] ?? 'Plant Lover 🌱';
                final imageUrl = data['imageUrl'] ?? '';

                return Container(
                  color: AppTheme.darkGray,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 👤 Profile Picture
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.green,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppTheme.lightGray,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),

                          // 👤 Name and bio
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                                Text(
                                  bio,
                                  style: TextStyle(
                                    color: AppTheme.lightGrayBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 📊 Counters (Posts & Plants)
                          Row(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where(
                                      'userEmail',
                                      isEqualTo: otherUserEmail,
                                    )
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
                                    .where(
                                      'userEmail',
                                      isEqualTo: otherUserEmail,
                                    )
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

                      const SizedBox(height: 20),

                      // 💬 Direct Message Button (Full Width)
                      if (userData.email != otherUserEmail)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    receiverEmail: otherUserEmail,
                                    receiverName: otherUsername,
                                    receiverProfileImage: imageUrl,
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
                    ],
                  ),
                );
              },
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
                        .where('userEmail', isEqualTo: otherUserEmail)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.green,
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

                      if (posts.isEmpty) {
                        return const Center(
                          child: Text(
                            "No posts yet 🌱",
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        );
                      }

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
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('plants')
                        .where('userEmail', isEqualTo: otherUserEmail)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.green,
                          ),
                        );
                      }

                      final plants = snapshot.data!.docs;
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
                          final plant = plants[index].data();
                          final doc = plants[index];
                          // final plant = doc.data();
                          final plantId =
                              doc.id; // 👈 This is the Firestore document ID
                          return GestureDetector(
                            onTap: () {
                              // Navigate to plant detail page if needed
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

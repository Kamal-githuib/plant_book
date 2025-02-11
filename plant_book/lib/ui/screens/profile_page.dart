import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/ui/screens/reminder_page.dart';
import 'package:plant_book/ui/screens/signin_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference postsRef =
      FirebaseFirestore.instance.collection('communityPosts');

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      // Fetch user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.userId).get();

      if (!userDoc.exists) {
        throw Exception("User not found.");
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          // More options icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: Colors.white), // Three vertical dots
            onSelected: (String value) {},
            itemBuilder: (BuildContext context) {
              return [
                // Menu items
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Text('Settings'),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlantReminderPage()),
                    );
                  },
                  value: 'Reminder',
                  child: const Text('Reminder'),
                ),
                PopupMenuItem<String>(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  value: 'Logout',
                  child: const Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile data available."));
          }

          final userData = snapshot.data!;

          return Column(
            children: [
              // Profile Content
              _buildProfileContent(userData),

              // Posts Section
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      postsRef.orderBy('time', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No posts available.'));
                    }

                    final posts = snapshot.data!.docs.where((post) {
                      return post['username'] ==
                          userData['username']; // Filter condition
                    }).toList();

                    if (posts.isEmpty) {
                      return const Center(
                          child: Text('No posts available for this user.'));
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostCard(context, post);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    Uint8List? profileImageBytes;

    // Decode Base64 Image
    if (userData['profileImageUrl'] != null &&
        userData['profileImageUrl'].isNotEmpty) {
      profileImageBytes = base64Decode(userData['profileImageUrl']);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Picture and Stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey,
                  backgroundImage: profileImageBytes != null
                      ? MemoryImage(profileImageBytes) // Display Decoded Image
                      : const AssetImage('assets/images/person.png')
                          as ImageProvider, // Default Image
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("24", "Posts"),
                      _buildStatColumn("1.2K", "Followers"),
                      _buildStatColumn("356", "Following"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // User Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['username'],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['fullname'],
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['bio'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, QueryDocumentSnapshot post) {
    final String username = post['username'] ?? 'Anonymous';
    final Timestamp time = post['time'] ?? Timestamp.now();
    final String title = post['title'] ?? 'No Title';
    final String? imageBase64 = post['imageUrl'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Post Title
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTimestamp(time),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Post Content
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Post Image (if available)
            if (imageBase64 != null && imageBase64.isNotEmpty)
              Container(
                width: double.infinity, // Full width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(imageBase64)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Adjust based on your image ratio
                  child: Container(), // Placeholder to maintain aspect ratio
                ),
              ),
            const SizedBox(height: 10),

            // Interaction Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_outline, color: Colors.grey),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 5),
                    const Text("120", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 5),
                    const Text("45", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp time) {
    final DateTime date = time.toDate();
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

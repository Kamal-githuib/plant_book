import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/ui/screens/message_page.dart';

class CommunityPage extends StatelessWidget {
  final CollectionReference postsRef =
      FirebaseFirestore.instance.collection('communityPosts');

  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/PlantBook_logo.jpg'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10), // Space between logo and text
            const Text(
              'Community',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.messenger,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessagePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsRef.orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(context, post);
            },
          );
        },
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
}

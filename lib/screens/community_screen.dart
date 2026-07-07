import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/components/post_card.dart';
import 'package:plant_book/provider/postdata_provider.dart';
import 'package:plant_book/screens/chatbot_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Community',
                      style: TextStyle(
                        color: AppTheme.lightGray,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.fontSize(22, 28),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightGrayBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBotPage()),
                );
              },
              label: Text(
                'PlantBook AI',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.fontSize(14, 18),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ FutureBuilder to fetch posts from Firestore
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: Provider.of<PostsDataProvider>(
          context,
          listen: false,
        ).getAllPosts(),
        builder: (context, snapshot) {
          // 🔄 Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.green),
            );
          }

          // ❌ Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading posts 😢",
                style: TextStyle(color: AppTheme.lightGray),
              ),
            );
          }

          // 📭 Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No posts available 🌱",
                style: TextStyle(color: AppTheme.lightGray),
              ),
            );
          }

          // ✅ Build posts list
          final posts = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'username': data['username'] ?? 'Anonymous',
              'title': data['caption'] ?? '',
              'time': (data['createdAt'] as Timestamp?)?.toDate(),
              'imageUrl': data['imageUrl'] ?? '',
              'comments': data['comments'] ?? [],
              'profileImageUrl': data['profileImageUrl'] ?? '',
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
    );
  }
}

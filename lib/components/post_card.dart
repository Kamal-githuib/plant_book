// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, deprecated_member_use, depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:plant_book/provider/postdata_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/usersprofile_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/like_comment_row.dart';
import 'package:plant_book/utils/report.dart';
import 'package:plant_book/utils/time_format.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;
  const PostCard({super.key, required this.post, required this.postId});

  @override
  Widget build(BuildContext context) {
    final String postId = post['id'];
    final String username = post['username'] ?? 'Anonymous';
    final DateTime time = post['time'] ?? DateTime.now();
    final String title = post['title'] ?? 'No Title';
    final String? image = post['imageUrl'];
    final String? profileImageUrl = post['profileImageUrl'];
    final String userEmail = post['userEmail'] ?? '';

    final userData = Provider.of<UserDataProvider>(context);
    final currentUsername = userData.username;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightGray,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Profile + Username + Time + Report
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.gray,
                  backgroundImage:
                      (profileImageUrl != null && profileImageUrl.isNotEmpty)
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: (profileImageUrl == null || profileImageUrl.isEmpty)
                      ? Icon(Icons.person, color: AppTheme.lightGray, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (userEmail.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtherUserProfilePage(
                                  otherUserEmail: userEmail.trim(),
                                  otherUsername: username,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightGray,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        TimeFormatter.format(time),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGrayBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                username == currentUsername
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppTheme.darkGray,
                              title: const Text(
                                'Delete Post',
                                style: TextStyle(color: AppTheme.lightGray),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this post?',
                                style: TextStyle(color: AppTheme.lightGray),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                            await Provider.of<PostsDataProvider>(
                              context,
                              listen: false,
                            ).deletePost(postId: postId, context: context);
                          }
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.flag, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ReportDialog(post: post),
                          );
                        },
                      ),
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),

            const SizedBox(height: 10),

            // Post Image (if available)
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.network(image, fit: BoxFit.cover),
                ),
              ),

            const SizedBox(height: 10),

            // Actions: Like/Dislike + Comments
            Row(
              children: [
                LikeCommentRow(
                  postId: postId,
                  comments: post['comments'] ?? [],
                ),
                const Spacer(),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: AppTheme.lightGray),
                    onPressed: () async {
                      final caption = title;
                      final usernameText = 'Posted by $username';
                      final imageUrl = image ?? '';

                      try {
                        if (imageUrl.isNotEmpty) {
                          // 🖼 Download image temporarily
                          final response = await http.get(Uri.parse(imageUrl));
                          final tempDir = await getTemporaryDirectory();
                          final file = File('${tempDir.path}/shared_image.jpg');
                          await file.writeAsBytes(response.bodyBytes);

                          // 📤 Share the image file with caption text
                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text:
                                '$usernameText\n\n"$caption"\n\nShared via PlantBook',
                          );
                        } else {
                          // 📤 If no image, share text only
                          await Share.share(
                            '$usernameText\n\n"$caption"\n\nShared via PlantBook',
                          );
                        }
                      } catch (e) {
                        debugPrint('❌ Error sharing post: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to share post')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

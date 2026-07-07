import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/components/comments.dart';
import 'package:plant_book/provider/like_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeCommentRow extends StatelessWidget {
  final String postId;
  final List<dynamic> comments;

  const LikeCommentRow({
    super.key,
    required this.postId,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final likeProvider = Provider.of<LikeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    // If not logged in, don't show anything
    if (user == null) return const SizedBox.shrink();

    // Fetch Firestore like/dislike state & counts once
    likeProvider.fetchPostLikeState(postId);

    final bool isLiked = likeProvider.isLiked(postId);
    final bool isDisliked = likeProvider.isDisliked(postId);

    final int likeCount = likeProvider.likeCount(postId);
    final int dislikeCount = likeProvider.dislikeCount(postId);

    return Row(
      children: [
        // 👍 Like & 👎 Dislike Row with counts
        Row(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Colors.green : AppTheme.lightGray,
                  ),
                  onPressed: () async {
                    await likeProvider.toggleLike(postId);
                  },
                ),
                Text(
                  '$likeCount',
                  style: const TextStyle(
                    color: AppTheme.lightGrayBlue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isDisliked
                        ? Icons.thumb_down_alt
                        : Icons.thumb_down_alt_outlined,
                    color: isDisliked ? Colors.red : AppTheme.lightGray,
                  ),
                  onPressed: () async {
                    await likeProvider.toggleDislike(postId);
                  },
                ),
                Text(
                  '$dislikeCount',
                  style: const TextStyle(
                    color: AppTheme.lightGrayBlue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // 💬 Comments
            IconButton(
              icon: const Icon(
                Icons.comment_outlined,
                color: AppTheme.lightGray,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => CommentsScreen(postId: postId),
                );
              },
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox();
                }
                final count = snapshot.data!.data()?['commentCount'] ?? 0;
                return Text(
                  '$count',
                  style: const TextStyle(
                    color: AppTheme.lightGrayBlue,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

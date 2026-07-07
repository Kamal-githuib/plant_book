import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/provider/comment&report_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;

  CommentsScreen({super.key, required this.postId});

  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(
      context,
      listen: false,
    );
    final userData = Provider.of<UserDataProvider>(context);
    final username = userData.username;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: AppTheme.darkGray,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Total Comments: ',
                  style: TextStyle(
                    color: AppTheme.lightGray,
                    fontWeight: FontWeight.bold,
                  ),
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
                        color: AppTheme.lightGray,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // 🔹 Real-time comment stream
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: commentProvider.getComments(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No comments yet',
                    style: TextStyle(color: AppTheme.lightGrayBlue),
                  );
                }

                final comments = snapshot.data!.docs;

                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index].data();
                      return ListTile(
                        leading:
                            (comment['profileImageUrl'] != null &&
                                comment['profileImageUrl'].isNotEmpty)
                            ? CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  comment['profileImageUrl'],
                                ),
                              )
                            : const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                        title: Text(
                          comment['username'] ?? 'Unknown',
                          style: const TextStyle(
                            color: AppTheme.lightGray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          comment['text'] ?? '',
                          style: const TextStyle(color: AppTheme.lightGrayBlue),
                        ),
                        // 🔹 Delete Button (only for comment owner)
                        trailing: username == comment['username']
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: AppTheme.darkGray,
                                      title: Text(
                                        'Delete Comment',
                                        style: TextStyle(
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this comment?',
                                        style: TextStyle(
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: AppTheme.lightGray,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await commentProvider.deleteComment(
                                      postId: postId,
                                      commentId: comments[index].id,
                                    );
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 🔹 Add comment input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    cursorColor: AppTheme.lightGray,
                    style: const TextStyle(color: AppTheme.lightGray),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: AppTheme.lightGrayBlue),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.lightGray),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppTheme.lightGray,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.lightGray),
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;

                      await commentProvider.addComment(
                        postId: postId,
                        text: _commentController.text.trim(),
                        username: username,
                        profileImageUrl:
                            userData.imageUrl, //  profile image URL
                      );

                      _commentController.clear();
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

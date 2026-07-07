// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/provider/chat_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/chating_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/time_format.dart';
import 'package:provider/provider.dart';

class MessageBoardPage extends StatelessWidget {
  const MessageBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userData = Provider.of<UserDataProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppTheme.lightGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.green,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatProvider.getUserChats(userData.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.green),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Start a conversation about a plant!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final otherUserEmail = users.firstWhere(
                (email) => email != currentUser.email,
              );

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserEmail)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  final otherUserName = userData?['name'] ?? 'Unknown';
                  final lastMessage = chat['lastMessage'] ?? '';
                  final updatedAt = (chat['updatedAt'] as Timestamp?)?.toDate();
                  final profileImages =
                      chat['profileImages'] as Map<String, dynamic>? ?? {};
                  final otherUserImage = profileImages[otherUserEmail] ?? '';
                  return Card(
                    color: AppTheme.darkGray,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          (otherUserImage != null && otherUserImage.isNotEmpty)
                          ? CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(otherUserImage),
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
                        otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.lightGray,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightGrayBlue,
                        ),
                      ),
                      trailing: Text(
                        TimeFormatter.messageFormat(updatedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGrayBlue,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              receiverEmail: otherUserEmail,
                              receiverName: otherUserName,
                              receiverProfileImage: otherUserImage,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

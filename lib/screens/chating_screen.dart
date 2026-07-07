// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_book/provider/chat_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverName;
  final String? receiverProfileImage;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverProfileImage,
  });

  final TextEditingController _controller = TextEditingController();

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time); // hh = 12-hour, a = AM/PM
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userData = Provider.of<UserDataProvider>(context);

    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatId = chatProvider.generateChatId(
      currentUser.email!,
      receiverEmail,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        title: Text(
          receiverName,
          style: const TextStyle(
            color: AppTheme.lightGray,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.green,
      ),
      body: Column(
        children: [
          // 🔥 Real-time messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatProvider.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  );
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Say hi 👋",
                      style: TextStyle(color: AppTheme.lightGrayBlue),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];
                    final isMe = data['sender'] == currentUser.email;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppTheme.green.withOpacity(0.9)
                                      : AppTheme.lightGray.withOpacity(0.9),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe
                                        ? const Radius.circular(16)
                                        : const Radius.circular(4),
                                    bottomRight: isMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data['text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isMe
                                            ? AppTheme.lightGray
                                            : AppTheme.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(
                                            (data['timestamp'] as Timestamp?)
                                                    ?.toDate() ??
                                                DateTime.now(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isMe
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        if (isMe)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                            ),
                                            child: Icon(
                                              data['status'] == 'sent'
                                                  ? Icons.check
                                                  : data['status'] == 'failed'
                                                  ? Icons.error_outline
                                                  : Icons.access_time,
                                              size: 12,
                                              color: data['status'] == 'failed'
                                                  ? Colors.redAccent
                                                  : Colors.white70,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
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
          ),

          // 📝 Message input
          _buildMessageInput(
            chatProvider,
            chatId,
            currentUser.email!,
            userData.imageUrl!,
            receiverProfileImage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    ChatProvider chatProvider,
    String chatId,
    String senderEmail,
    String? senderProfileImage,
    String? receiverProfileImage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
        color: AppTheme.darkGray,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: AppTheme.lightGray),
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: "Type a message",
                hintStyle: TextStyle(color: AppTheme.lightGrayBlue),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.green),
            onPressed: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              _controller.clear(); // ✅ Clear immediately for a smoother UI

              await chatProvider.sendMessage(
                chatId: chatId,
                senderEmail: senderEmail,
                receiverEmail: receiverEmail,
                text: text,
                senderProfileImage: senderProfileImage,
                receiverProfileImage: receiverProfileImage,
              );
            },
          ),
        ],
      ),
    );
  }
}

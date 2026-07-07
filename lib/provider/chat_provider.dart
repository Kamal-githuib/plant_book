// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  /// ✅ Generate chatId (sorted combination of emails)
  String generateChatId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return users.join('_');
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderEmail,
    required String receiverEmail,
    required String text,
    required String? senderProfileImage,
    required String? receiverProfileImage,
  }) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'text': text,
      'sender': senderEmail,
      'receiver': receiverEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sending', // default state
    };

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // ✅ Update status to "sent" only after successful write
      await docRef.update({'status': 'sent'});

      // 2️⃣ Update chat metadata
      await _firestore.collection('chats').doc(chatId).set({
        'users': [senderEmail, receiverEmail],
        'lastMessage': text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImages': {
          senderEmail: senderProfileImage,
          receiverEmail: receiverProfileImage,
        },
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      // ❌ If error (e.g. no internet), keep it as "sending" or "failed"
      debugPrint("Error sending message: $e");
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'text': text,
            'sender': senderEmail,
            'receiver': receiverEmail,
            'timestamp': Timestamp.now(),
            'status': 'failed',
          });
      notifyListeners();
    }
  }

  /// Fetch messages
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// ✅ Fetch user’s all chats (for chat list or notifications)
  Stream<List<Map<String, dynamic>>> getUserChats(String userEmail) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userEmail)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'chatId': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// 🔹 Delete chat only for the current user (like WhatsApp "Delete for me")
  Future<void> deleteChatForMe(String chatId, String userEmail) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deletedBy': FieldValue.arrayUnion([userEmail]),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting chat for $userEmail: $e');
    }
  }

  /// 🔹 Delete chat for everyone (optional - removes chat + all messages)
  Future<void> deleteChatForEveryone(String chatId) async {
    try {
      final batch = _firestore.batch();

      // Delete all messages in this chat
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var msg in messages.docs) {
        batch.delete(msg.reference);
      }

      // Delete chat itself
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting chat for everyone: $e');
    }
  }
}

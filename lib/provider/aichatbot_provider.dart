import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatBotProvider with ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🧠 Groq API Key (replace with your key)
  final String _apiKey =
      "YOUR_API_KEY_HERE";

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;

  // 🔹 Load messages from Firestore
  Future<void> loadMessages() async {
    final email = _auth.currentUser?.email;
    if (email == null) return;

    final snapshot = await _firestore
        .collection('ai_chats')
        .doc(email)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    _messages.clear();
    for (var doc in snapshot.docs) {
      _messages.add({'role': doc['role'], 'content': doc['content']});
    }
    notifyListeners();
  }

  // 🔹 Send user message + get AI reply
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    final email = _auth.currentUser?.email;
    if (email == null) return;

    final userMsg = {'role': 'user', 'content': userMessage.trim()};
    _messages.add(userMsg);
    notifyListeners();

    await _saveMessage(email, userMsg);

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful plant care assistant.",
            },
            ..._messages.map(
              (m) => {"role": m["role"], "content": m["content"]},
            ),
          ],
          "temperature": 0.7,
          "max_tokens": 512,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data["choices"]?[0]?["message"]?["content"] ??
            "I'm sorry, I couldn’t generate a response.";

        _messages.add({'role': 'assistant', 'content': reply});
        notifyListeners();

        await _saveMessage(email, {'role': 'assistant', 'content': reply});
      } else {
        debugPrint("Groq API error: ${response.body}");
        _messages.add({'role': 'system', 'content': 'Error: ${response.body}'});
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Exception: $e");
      _messages.add({'role': 'system', 'content': 'Error: $e'});
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Save message to Firestore
  Future<void> _saveMessage(String email, Map<String, String> message) async {
    await _firestore
        .collection('ai_chats')
        .doc(email)
        .collection('messages')
        .add({
          'role': message['role'],
          'content': message['content'],
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}

import 'package:flutter/material.dart';
import 'package:plant_book/constants.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String image;

  const ChatPage({super.key, required this.name, required this.image});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({
        'text': text,
        'isSentByMe': true,
        'time': DateTime.now(),
      });
    });

    // Simulate bot response after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': _getBotResponse(text),
          'isSentByMe': false,
          'time': DateTime.now(),
        });
      });
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _messageController.clear();
  }

  String _getBotResponse(String text) {
    if (text.toLowerCase().contains('hi') || text.toLowerCase().contains('hello')) {
      return 'Hello! How are you doing';
    } else if (text.toLowerCase().contains('I am good')) {
      return 'Nice to hear.';
    } else if (text.toLowerCase().contains('sun')) {
      return 'Plants generally need 6 hours of sunlight daily. Some prefer indirect light.';
    }
    return 'I\'m here to help with plant care advice! Ask me anything about ${widget.name}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name,
        style: const TextStyle(fontSize: 24, color: Colors.white),),
        backgroundColor: Constants.primaryColor,
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(widget.image),
                ),
                const SizedBox(width: 16),
                Text(
                  "Chat with ${widget.name}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isSentByMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: message['isSentByMe']
                          ? Colors.green[100]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${message['time'].hour}:${message['time'].minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.green[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green[700],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
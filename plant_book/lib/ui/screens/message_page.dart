import 'package:flutter/material.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/ui/screens/chat_page.dart';
import 'package:plant_book/ui/screens/chatbot_ai_page.dart';

class MessagePage extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'name': 'Muhammad Kamal',
      'message': 'Uploaded file',
      'time': 'Sun',
      'image': 'assets/images/kamal.jpeg',
    },
    {
      'name': 'Malik Faizan Ali',
      'message': 'Here is another tutorial, if you...',
      'time': '23 Mar',
      'image': 'assets/images/faizan.jpeg',
    },
    {
      'name': 'Shayan Habib',
      'message': 'Hello!',
      'time': '19 Mar',
      'image': 'assets/profile3.png',
    },
    {
      'name': 'Uzair Inayat',
      'message': 'I\'m going to give a...',
      'time': '01 Feb',
      'image': 'assets/images/uzair.jpg',
    },
    {
      'name': 'Sohaib',
      'message': 'Some pics are attached...',
      'time': '01 Feb',
      'image': 'assets/images/sohaib.jpeg',
    },
    {
      'name': 'Abdullah Mirza',
      'message': 'allcityhr@gmail.com',
      'time': '08:43',
      'image': 'assets/profile6.png',
    },
    {
      'name': 'Haris Waleed',
      'message': 'Will do, super, thank you 😊',
      'time': 'Tue',
      'image': 'assets/images/haris.jpg',
    },
  ];

  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "RECENT",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: items.length + 1, // +1 for AI Chatbot
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // AI Chatbot Card
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 2,
                    color: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[800],
                        child: const Icon(
                          Icons.spa, // Plant-themed icon
                          color: Colors.white,
                        ),
                      ),
                      title: const Text(
                        'PlantBook Ai ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: const Text('Ask me anything about plants!'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatBotPage()),
                        );
                      },
                    ),
                  );
                }

                final item = items[index - 1]; // Adjust index
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(item['image']!),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      item['message']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      item['time']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            name: item['name']!,
                            image: item['image']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

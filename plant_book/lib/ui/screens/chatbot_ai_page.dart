import 'package:flutter/material.dart';
import 'package:plant_book/constants.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'message': text});
        messages.add({'sender': 'bot', 'message': getBotResponse(text)});
      });
      _controller.clear();
    }
  }

  String getBotResponse(String text) {
    if (text.toLowerCase().contains('water')) {
      return 'Most plants need watering once a week. Make sure the soil is moist but not soggy.';
    } else if (text.toLowerCase().contains('sunlight')) {
      return 'Plants generally need 6 hours of sunlight daily. Some plants thrive in indirect light.';
    } else if (text.toLowerCase().contains('soil')) {
      return 'Use well-draining soil for most plants. Adding compost can improve soil quality.';
    } else if (text.toLowerCase().contains('fertilizer')) {
      return 'Fertilize your plants every 4-6 weeks during the growing season. Use a balanced fertilizer.';
    } else if (text.toLowerCase().contains('prune')) {
      return 'Prune your plants to remove dead or overgrown branches. This encourages healthy growth.';
    } else if (text.toLowerCase().contains('pests')) {
      return 'For pests, try using neem oil or insecticidal soap. Regularly check the undersides of leaves.';
    } else if (text.toLowerCase().contains('repot')) {
      return 'Repot your plant when it outgrows its current pot. Choose a pot that is 2 inches larger in diameter.';
    } else if (text.toLowerCase().contains('humidity')) {
      return 'Tropical plants prefer high humidity. You can use a humidifier or mist the leaves regularly.';
    } else if (text.toLowerCase().contains('temperature')) {
      return 'Most houseplants prefer temperatures between 65-75°F (18-24°C). Avoid sudden temperature changes.';
    } else if (text.toLowerCase().contains('propagate')) {
      return 'You can propagate plants using cuttings, division, or seeds. Make sure to use clean tools.';
    } else if (text.toLowerCase().contains('wilting')) {
      return 'Wilting can be a sign of overwatering or underwatering. Check the soil moisture and adjust accordingly.';
    } else if (text.toLowerCase().contains('yellow leaves')) {
      return 'Yellow leaves can indicate overwatering, nutrient deficiency, or poor drainage. Check the soil and adjust care.';
    } else if (text.toLowerCase().contains('brown tips')) {
      return 'Brown tips on leaves can be caused by low humidity, over-fertilizing, or inconsistent watering.';
    } else if (text.toLowerCase().contains('flowering')) {
      return 'To encourage flowering, ensure your plant gets enough light and nutrients. Deadhead spent blooms regularly.';
    } else if (text.toLowerCase().contains('succulent')) {
      return 'Succulents need well-draining soil and infrequent watering. They thrive in bright, indirect light.';
    } else if (text.toLowerCase().contains('cactus')) {
      return 'Cacti require minimal watering and plenty of sunlight. Water only when the soil is completely dry.';
    } else if (text.toLowerCase().contains('herbs')) {
      return 'Herbs like basil, mint, and parsley need plenty of sunlight and regular watering. Harvest regularly to promote growth.';
    } else if (text.toLowerCase().contains('orchid')) {
      return 'Orchids need indirect light and high humidity. Water them once a week and ensure good air circulation.';
    } else if (text.toLowerCase().contains('fern')) {
      return 'Ferns prefer indirect light and high humidity. Keep the soil consistently moist but not waterlogged.';
    } else {
      return 'I am here to help! Ask me about plant care, watering, sunlight, soil, or any other plant-related topic.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PlantBook AI Chatbot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Constants.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[200] : Colors.blue[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['message']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Ask something...'),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Constants.primaryColor,
                  ),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

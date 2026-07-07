import 'package:flutter/material.dart';
import 'package:plant_book/provider/aichatbot_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final ScrollController scrollController = ScrollController();
    // String formatTime(DateTime time) {
    //   return DateFormat('hh:mm a').format(time); // hh = 12-hour, a = AM/PM
    // }

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: const Text(
          "PlantBook Ai",
          style: TextStyle(
            color: AppTheme.lightGray,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<ChatBotProvider>(
          builder: (context, provider, _) {
            final chatMessages = provider.messages;

            // Auto-scroll on message update
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        chatMessages.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= chatMessages.length) {
                        // AI typing indicator
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final message = chatMessages[index];
                      final isAssistant = message["role"] == 'assistant';
                      final isLatestAssistant =
                          isAssistant && index == chatMessages.length - 1;

                      // Get formatted timestamp
                      // final timestamp = formatTime(
                      //   (message['timestamp'] as Timestamp).toDate(),
                      // );

                      return Align(
                        alignment: isAssistant
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isAssistant
                                ? Colors.grey[200]
                                : Colors.lightGreen[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // message content
                              isLatestAssistant
                                  ? DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.darkGray,
                                      ),
                                      child: AnimatedTextKit(
                                        isRepeatingAnimation: false,
                                        repeatForever: false,
                                        totalRepeatCount: 1,
                                        animatedTexts: [
                                          TyperAnimatedText(
                                            message["content"] ?? '',
                                            speed: const Duration(
                                              milliseconds: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      message["content"] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.darkGray,
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              // timestamp
                              // Text(
                              //   timestamp,
                              //   style: const TextStyle(
                              //     fontSize: 12,
                              //     color: AppTheme.darkGray,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: AppTheme.lightGray),
                          cursorColor: AppTheme.lightGray,
                          decoration: InputDecoration(
                            hintText: "Ask about plants...",
                            hintStyle: const TextStyle(
                              color: AppTheme.lightGrayBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppTheme.lightGray,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) {
                            if (text.trim().isEmpty) return;
                            provider.sendMessage(text.trim());
                            controller.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppTheme.green,
                        radius: 24,
                        child: provider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: AppTheme.lightGray,
                                ),
                                onPressed: () {
                                  if (controller.text.trim().isEmpty) return;
                                  provider.sendMessage(controller.text.trim());
                                  controller.clear();
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

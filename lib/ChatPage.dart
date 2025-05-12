import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart'; // For time formatting

// Define your model message class
class ModelMessage {
  final bool isPrompt; // True for user prompt, False for bot response
  final String message;
  final DateTime time;

  ModelMessage({required this.isPrompt, required this.message, required this.time});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController promptController = TextEditingController();
  static const apiKey = "AIzaSyAj9V18yZriNZ1Q8A9Cuy_N6aVMdWcasJY"; // Replace with your valid API key
  final model = GenerativeModel(model: "gpt-3.5-turbo", apiKey: apiKey); // Using a valid model
  final List<ModelMessage> messages = [];

  // Send user message and receive bot response
  Future<void> sendMessage() async {
    final message = promptController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      // Add user prompt to the chat list
      messages.add(
        ModelMessage(isPrompt: true, message: message, time: DateTime.now()),
      );
    });

    promptController.clear(); // Clear the input box

    final content = [Content.text(message)];

    try {
      // Get the bot response
      final response = await model.generateContent(content);

      setState(() {
        // Add bot response to the chat list
        messages.add(
          ModelMessage(
            isPrompt: false,
            message: response.text ?? "No response",
            time: DateTime.now(),
          ),
        );
      });
    } catch (error) {
      setState(() {
        messages.add(
          ModelMessage(
            isPrompt: false,
            message: "Error: $error",
            time: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Bot'),
      ),
      body: Column(
        children: [
          // Display chat history (user and bot messages)
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          // Input text field and send button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promptController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    radius: 29,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Display each message
  Widget _buildMessage(ModelMessage message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      alignment: message.isPrompt ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isPrompt
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: message.isPrompt ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              message.message,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('hh:mm a').format(message.time),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

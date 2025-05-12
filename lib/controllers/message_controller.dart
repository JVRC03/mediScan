import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTypeing = false.obs;

  // Function to send the message (including data passed from native)
  Future<void> sendMessage(String message, {bool isUser = true}) async {
    // Add user message to the messages list
    messages.add(
      {
        'text': message,
        'isUser': isUser,
        'time': DateFormat('hh:mm a').format(DateTime.now()),
      },
    );

    // Simulate typing status
    if (isUser) {
      responseText.value = "Thinking...";
      isTypeing.value = true;
      update();
    }

    // If it's a user message, send it to the API for a response
    if (isUser) {
      try {
        // Build conversation history
        String conversationHistory = _buildConversationHistory();

        // Append the new user message
        conversationHistory += "\nUser: $message\nBot:";

        // Send conversation history to the API
        String reply = await GoogleApiService.getApiResponse(conversationHistory);

        // Add the AI response to the messages list
        responseText.value = reply;
        messages.add(
          {
            'text': reply,
            'isUser': false,
            'time': DateFormat('hh:mm a').format(DateTime.now()),
          },
        );
      } catch (e) {
        responseText.value = "Failed to get response.";
        messages.add({
          'text': "Error: $e",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now()),
        });
      } finally {
        isTypeing.value = false;
        update();
      }
    }
  }

  // Function to send the initial data (native data) as a message
  void sendInitialDataMessage(String data) {
    messages.add(
      {
        'text': data,
        'isUser': false,
        'time': DateFormat('hh:mm a').format(DateTime.now()),
      },
    );
    update();
  }

  // Private helper function to build conversation history
  String _buildConversationHistory() {
    String history = "";
    // You can limit history to last few messages if needed
    var recentMessages = messages.length > 10 ? messages.sublist(messages.length - 10) : messages;

    for (var message in recentMessages) {
      if (message['isUser'] == true) {
        history += "User: ${message['text']}\n";
      } else {
        history += "Bot: ${message['text']}\n";
      }
    }
    return history.trim();
  }
}

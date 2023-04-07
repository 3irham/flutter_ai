import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ChatGPTService {
  static final String apiUrl = "https://api.chatgpt.com/send-message";

  static Future<String> sendMessage(String message) async {
    final response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["message"];
    } else {
      throw Exception("Failed to send message");
    }
  }
}




class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<String> chatHistory = [];

  void _sendMessage() async {
    String message = messageController.text;
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add("You: $message");
      });

      String response = await ChatGPTService.sendMessage(message);

      setState(() {
        chatHistory.add("ChatGPT: $response");
      });
    }
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with ChatGPT"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(chatHistory[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your message here"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Send"),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  static const String apiUrl =
      "https://api.openai.com/v1/engines/davinci-codex/completions";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer $apikey" // You can get your API key from https://beta.openai.com/
          },
          body: jsonEncode(
              {"prompt": message, "temperature": 0.5, "max_tokens": 60}));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["choices"][0]["text"].toString();
      } else {
        throw Exception("Failed to send message: ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

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

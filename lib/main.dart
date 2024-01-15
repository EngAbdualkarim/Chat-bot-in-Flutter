import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  String apiKey = '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';
  Future<void> _sendMessage(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add("You: $text");
      });

      final response = await http.post(
        Uri.parse(
            'https://api.openai.com/v1/chat/completions'), // Replace with your endpoint
        headers: {
          'Authorization': 'Bearer  ${apiKey}', // Replace with your API key
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            "model": "text-davinci-003",
            "prompt": _controller.text,
            "max_tokens": 250,
            "temperature": 0,
            "top_p": 1,
          },
        ),
      );

      final responseBody = json.decode(response.body);

      // Check if responseBody and the required fields are not null
      if (responseBody != null &&
          responseBody['choices'] != null &&
          responseBody['choices'].isNotEmpty &&
          responseBody['choices'][0]['text'] != null) {
        final reply = responseBody['choices'][0]['text'].trim();

        setState(() {
          _messages.add("ChatGPT: $reply");
        });
      } else {
        // Handle the error appropriately. For now, just print to console
        print('Error in API response: $responseBody');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatGPT"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

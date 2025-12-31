import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/message_bubble.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, DateTime? time})
    : time = time ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [
    Message(
      text:
          'Halo! Saya adalah kamu, AI yang memahami Anda. Apa yang ingin Anda diskusikan?',
      isUser: false,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  void _sendMessage(String text) async {
    print('Starting _sendMessage'); // Debug
    if (text.trim().isEmpty) return;
    Future.delayed(Duration.zero, () {
      setState(() {
        _messages.add(Message(text: text.trim(), isUser: true));
        _isSending = true;
      });
    });
    _controller.clear();
    // _scrollToBottom(); // Temporary disable
    print('Before await _getAiResponse'); // Debug

    try {
      final response = await _getAiResponse(text);
      print('After await _getAiResponse'); // Debug
      if (mounted) {
        Future.delayed(Duration.zero, () {
          setState(() {
            _messages.add(Message(text: response, isUser: false));
            _isSending = false;
          });
        });
        // _scrollToBottom(); // Temporary disable
      }
    } catch (error) {
      print('Error in _sendMessage: $error'); // Debug print
      if (mounted) {
        Future.delayed(Duration.zero, () {
          setState(() {
            _messages.add(
              Message(text: 'Maaf, terjadi kesalahan: $error', isUser: false),
            );
            _isSending = false;
          });
        });
        // _scrollToBottom(); // Temporary disable
      }
    }
    print('End of _sendMessage'); // Debug
  }

  Future<String> _getAiResponse(String prompt) async {
    try {
      const apiKey =
          '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'; // OpenRouter API key
      const url = 'https://openrouter.ai/api/v1/chat/completions';
      print('Sending request to OpenRouter...');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
              'HTTP-Referer': 'https://your-app.com', // Optional
              'X-Title': 'Ainya Chat App', // Optional
            },
            body: jsonEncode({
              'model': 'meta-llama/llama-3.1-8b-instruct', // Free model
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Anda adalah AI yang dikatakan "Saya adalah kamu", yang sangat empati dan memahami pengguna secara mendalam.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim();
        print('Response content: $content');
        return content;
      } else {
        print('API Error: ${response.body}');
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saya adalah kamu'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: MessageBubble(
                        text: msg.text,
                        isUser: msg.isUser,
                        time: msg.time,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Container(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.indigo, Colors.purple],
                        ),
                      ),
                      child: IconButton(
                        icon: _isSending
                            ? const Icon(
                                Icons.hourglass_empty,
                                color: Colors.white,
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isSending
                            ? null
                            : () => _sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

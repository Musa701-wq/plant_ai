// lib/modules/ask_ai/provider/ask_ai_provider.dart
import 'package:flutter/material.dart';
import '../repo/chat_repo.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toApiFormat() {
    return {
      "role": isUser ? "user" : "model",
      "parts": [
        {"text": text}
      ]
    };
  }
}

class AskAiProvider extends ChangeNotifier {
  final ChatRepository repository;

  AskAiProvider(this.repository);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Set loading
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare last 5 messages (context)
      final contextMessages = _messages
          .takeLast(5) // extension method added below
          .map((m) => m.toApiFormat())
          .toList();

      // Get AI response
      final aiResponse = await repository.getAiResponse(contextMessages);

      // Add AI response
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "⚠️ Error: ${e.toString()}",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// 🔧 Extension for taking last N items from a list
extension TakeLastExtension<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - (n < length ? n : length));
}

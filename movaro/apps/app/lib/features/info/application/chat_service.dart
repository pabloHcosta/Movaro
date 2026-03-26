import 'dart:async';
import 'dart:developer' as dev;

import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';

/// The answer source returned by the backend orchestrator.
enum ChatAnswerSource { appData, ai, unknown }

/// A single message in the conversation history.
///
/// Mirrors [ChatMessage] from [GeminiChatService] for UI compatibility.
typedef BackendChatMessage = ChatMessage;

/// Result of a single call to [ChatService.ask].
class ChatServiceAnswer {
  const ChatServiceAnswer({
    required this.text,
    required this.source,
    required this.confidence,
  });

  final String text;
  final ChatAnswerSource source;
  final double confidence;
}

class ChatStarterPrompt {
  const ChatStarterPrompt({
    required this.key,
    required this.label,
    required this.message,
  });

  final String key;
  final String label;
  final String message;
}

class ChatStarterPrompts {
  const ChatStarterPrompts({
    required this.categories,
    required this.chips,
  });

  final List<ChatStarterPrompt> categories;
  final List<ChatStarterPrompt> chips;
}

/// Backend-mediated chat service.
///
/// Calls `POST /v1/chat/ask` on the Movaro API. The backend orchestrator
/// handles intent detection, structured resolver lookup (city, cost, docs,
/// plan), and Gemini fallback — so no Gemini API key is needed in the app.
///
/// Exposes a [Stream<String>] interface identical to [GeminiChatService.sendMessage]
/// so the existing chat UI works without changes.
class ChatService {
  ChatService({
    required NetworkClient networkClient,
    required String originCountry,
    required String destinationCountry,
    required String locale,
    this.recommendedCityId,
    this.currentPhase,
    this.migrationGoal,
    this.planTimeline,
    this.completedItemIds = const [],
  }) : _client = networkClient,
       _originCountry = originCountry,
       _destinationCountry = destinationCountry,
       _locale = locale;

  final NetworkClient _client;
  final String _originCountry;
  final String _destinationCountry;
  final String _locale;
  final String? recommendedCityId;
  final String? currentPhase;
  final String? migrationGoal;
  final String? planTimeline;
  final List<String> completedItemIds;

  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Send a message and stream the response character by character for a
  /// typewriter effect. Matches the [GeminiChatService.sendMessage] signature.
  Stream<String> sendMessage(String userMessage) async* {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    _history.add(
      ChatMessage(role: 'user', text: trimmed, timestamp: DateTime.now()),
    );

    dev.log(
      '[ChatService] ask: "${trimmed.substring(0, trimmed.length.clamp(0, 60))}"',
    );

    ChatServiceAnswer answer;
    try {
      answer = await _ask(trimmed);
    } catch (e) {
      dev.log('[ChatService] error: $e');
      const errorText = 'Não consegui processar sua pergunta. Tente novamente.';
      _history.add(
        ChatMessage(
          role: 'assistant',
          text: errorText,
          timestamp: DateTime.now(),
        ),
      );
      yield errorText;
      return;
    }

    _history.add(
      ChatMessage(
        role: 'assistant',
        text: answer.text,
        timestamp: DateTime.now(),
      ),
    );

    // Stream character by character for typewriter effect
    const chunkSize = 4;
    for (var i = 0; i < answer.text.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, answer.text.length);
      yield answer.text.substring(i, end);
      await Future<void>.delayed(const Duration(milliseconds: 12));
    }
  }

  void clearHistory() => _history.clear();

  Future<ChatServiceAnswer> _ask(String message) async {
    final body = <String, dynamic>{
      'message': message,
      'originCountry': _originCountry,
      'destinationCountry': _destinationCountry,
      'locale': _locale,
      if (recommendedCityId != null) 'recommendedCityId': recommendedCityId,
      if (currentPhase != null) 'currentPhase': currentPhase,
      if (migrationGoal != null) 'migrationGoal': migrationGoal,
      if (planTimeline != null) 'planTimeline': planTimeline,
      if (completedItemIds.isNotEmpty) 'completedItemIds': completedItemIds,
      if (_history.length > 1)
        'history': _history
            .take(_history.length - 1) // exclude the message we just added
            .take(10) // max 10 history items
            .map((m) => {'role': m.role, 'text': m.text})
            .toList(),
    };

    final data = await _client.postJsonMap('/v1/chat/ask', body);

    final text = data['answer'] as String? ?? '';
    final sourceRaw = data['source'] as String? ?? '';
    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

    final source = switch (sourceRaw) {
      'app_data' => ChatAnswerSource.appData,
      'ai' => ChatAnswerSource.ai,
      _ => ChatAnswerSource.unknown,
    };

    return ChatServiceAnswer(
      text: text,
      source: source,
      confidence: confidence,
    );
  }

  Future<ChatStarterPrompts> fetchStarterPrompts() async {
    final data = await _client.postJsonMap('/v1/chat/prompts', {
      'originCountry': _originCountry,
      'destinationCountry': _destinationCountry,
      'locale': _locale,
    });

    List<ChatStarterPrompt> parseItems(String key) {
      final raw = data[key];
      if (raw is! List) {
        return const [];
      }

      return raw
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => ChatStarterPrompt(
              key: item['key'] as String? ?? '',
              label: item['label'] as String? ?? '',
              message: item['message'] as String? ?? '',
            ),
          )
          .where((item) => item.label.isNotEmpty && item.message.isNotEmpty)
          .toList(growable: false);
    }

    return ChatStarterPrompts(
      categories: parseItems('categories'),
      chips: parseItems('chips'),
    );
  }
}

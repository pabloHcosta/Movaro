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
/// Calls `POST /api/v1/chat/ask` on the Movaro API. The backend orchestrator
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

    final data = await _client.postJsonMap('/api/v1/chat/ask', body);

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
    try {
      final data = await _client.postJsonMap('/api/v1/chat/prompts', {
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

      final prompts = ChatStarterPrompts(
        categories: parseItems('categories'),
        chips: parseItems('chips'),
      );
      if (prompts.categories.isNotEmpty || prompts.chips.isNotEmpty) {
        return prompts;
      }
    } catch (e) {
      dev.log('[ChatService] starter prompts fallback: $e');
    }

    return _buildFallbackStarterPrompts();
  }

  ChatStarterPrompts _buildFallbackStarterPrompts() {
    final destinationLabel = _destinationCountry.trim().isNotEmpty
        ? _destinationCountry.trim()
        : (_locale == 'es'
              ? 'tu destino'
              : _locale == 'en'
              ? 'your destination'
              : 'seu destino');
    final localDocPrompt = _firstLocalDocumentPrompt();

    return ChatStarterPrompts(
      categories: [
        ChatStarterPrompt(
          key: 'documents',
          label: _locale == 'es'
              ? 'Documentos'
              : _locale == 'en'
              ? 'Documents'
              : 'Documentos',
          message: _locale == 'es'
              ? '¿Qué documentos necesito para migrar a $destinationLabel? Explica visa y $localDocPrompt.'
              : _locale == 'en'
              ? 'What documents do I need to move to $destinationLabel? Explain visas and $localDocPrompt.'
              : 'Quais documentos preciso para migrar para $destinationLabel? Explique visto e $localDocPrompt.',
        ),
        ChatStarterPrompt(
          key: 'costs',
          label: _locale == 'es'
              ? 'Costos'
              : _locale == 'en'
              ? 'Costs'
              : 'Custos',
          message: _locale == 'es'
              ? '¿Cuánto cuesta mudarse? Dame una visión general de los costos.'
              : _locale == 'en'
              ? 'How much does it cost to move? Give me a cost overview.'
              : 'Quanto custa se mudar? Me dê uma visão geral dos custos.',
        ),
        ChatStarterPrompt(
          key: 'activities',
          label: _locale == 'es'
              ? 'Qué hacer'
              : _locale == 'en'
              ? 'What to do'
              : 'O que fazer',
          message: _locale == 'es'
              ? '¿Qué debo saber sobre la vida en la ciudad destino?'
              : _locale == 'en'
              ? 'What should I know about life in the destination city?'
              : 'O que devo saber sobre a vida na cidade destino?',
        ),
        ChatStarterPrompt(
          key: 'stay',
          label: _locale == 'es'
              ? 'Dónde quedarse'
              : _locale == 'en'
              ? 'Where to stay'
              : 'Onde ficar',
          message: _locale == 'es'
              ? '¿Cómo encontrar vivienda en $destinationLabel? Consejos para alquilar.'
              : _locale == 'en'
              ? 'How do I find housing in $destinationLabel? Renting tips.'
              : 'Como encontrar moradia em $destinationLabel? Dicas para alugar.',
        ),
      ],
      chips: [
        ChatStarterPrompt(
          key: 'visa',
          label: _locale == 'es'
              ? '¿Necesito visa?'
              : _locale == 'en'
              ? 'Do I need a visa?'
              : 'Preciso de visto?',
          message: _locale == 'es'
              ? '¿Necesito visa?'
              : _locale == 'en'
              ? 'Do I need a visa?'
              : 'Preciso de visto?',
        ),
        ChatStarterPrompt(
          key: 'best_time',
          label: _locale == 'es'
              ? '¿Mejor época para ir?'
              : _locale == 'en'
              ? 'Best time to go?'
              : 'Melhor época pra ir?',
          message: _locale == 'es'
              ? '¿Mejor época para ir?'
              : _locale == 'en'
              ? 'Best time to go?'
              : 'Melhor época pra ir?',
        ),
        ChatStarterPrompt(
          key: 'first_local_document',
          label: localDocPrompt,
          message: localDocPrompt,
        ),
      ],
    );
  }

  String _firstLocalDocumentPrompt() {
    final normalized = _destinationCountry.toLowerCase().trim();
    if (normalized == 'brasil' || normalized == 'brazil') {
      if (_locale == 'es') return '¿Cómo obtener mi CPF?';
      if (_locale == 'en') return 'How do I get my CPF?';
      return 'Como tirar o CPF?';
    }

    if (_locale == 'es') return '¿Cuál es mi primer documento local?';
    if (_locale == 'en') return 'What is my first local document?';
    return 'Qual é meu primeiro documento local?';
  }
}

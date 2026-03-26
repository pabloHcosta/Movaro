import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:movaro_app/app/localization/generated/app_localizations.dart';
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

  AppLocalizations get _l10n => lookupAppLocalizations(Locale(_locale));

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
      final errorText = _l10n.chatServiceErrorProcessingQuestion;
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
    final l10n = _l10n;
    final destinationLabel = _destinationCountry.trim().isNotEmpty
        ? _destinationCountry.trim()
        : l10n.chatFallbackDestination;
    final localDocPrompt = _firstLocalDocumentPrompt();

    return ChatStarterPrompts(
      categories: [
        ChatStarterPrompt(
          key: 'documents',
          label: l10n.homeAssistantCategoryDocuments,
          message: l10n.chatFallbackMessageDocuments(
            destinationLabel,
            localDocPrompt,
          ),
        ),
        ChatStarterPrompt(
          key: 'costs',
          label: l10n.homeAssistantCategoryCosts,
          message: l10n.chatFallbackMessageCosts,
        ),
        ChatStarterPrompt(
          key: 'activities',
          label: l10n.homeAssistantCategoryActivities,
          message: l10n.chatFallbackMessageActivities,
        ),
        ChatStarterPrompt(
          key: 'stay',
          label: l10n.homeAssistantCategoryStay,
          message: l10n.chatFallbackMessageStay(destinationLabel),
        ),
      ],
      chips: [
        ChatStarterPrompt(
          key: 'visa',
          label: l10n.assistantEntryQuickVisa,
          message: l10n.assistantEntryQuickVisa,
        ),
        ChatStarterPrompt(
          key: 'best_time',
          label: l10n.assistantEntryQuickBestTime,
          message: l10n.assistantEntryQuickBestTime,
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
      return _l10n.chatFallbackFirstLocalDocumentBrazil;
    }

    return _l10n.chatFallbackFirstLocalDocumentDefault;
  }
}

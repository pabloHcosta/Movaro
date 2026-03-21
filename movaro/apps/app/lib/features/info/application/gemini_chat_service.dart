import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A chat message in the conversation.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    text: json['text'] as String,
    timestamp: json['ts'] != null
        ? DateTime.tryParse(json['ts'] as String)
        : null,
  );

  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    if (timestamp != null) 'ts': timestamp!.toIso8601String(),
  };
}

/// Localized error messages for the chat service.
class ChatErrorMessages {
  const ChatErrorMessages({
    required this.notInitialized,
    required this.rateLimit,
    required this.apiLimit,
    required this.generic,
  });

  final String notInitialized;
  final String rateLimit;
  final String apiLimit;
  final String generic;
}

/// Gemini-powered chat service with:
/// - Response caching in SharedPreferences
/// - Rate limiting for the free tier
/// - RAG-style context injection from curated content
class GeminiChatService {
  GeminiChatService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;
  GenerativeModel? _model;
  ChatSession? _chat;
  final List<ChatMessage> _history = [];
  final Map<String, String> _responseCache = {};
  ChatErrorMessages _errorMessages = const ChatErrorMessages(
    notInitialized: 'Service not initialized.',
    rateLimit: 'Rate limit reached.',
    apiLimit: 'API limit reached.',
    generic: 'Error processing request.',
  );

  // Rate limiting: max 9 requests per minute (free tier = 10 RPM)
  final List<DateTime> _requestTimestamps = [];
  static const _maxRpm = 9;

  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Initialize with curated documentation content for RAG context.
  void initialize({
    required String curatedContent,
    required String originCountry,
    required String destinationCountry,
    required String locale,
    required ChatErrorMessages errorMessages,
  }) {
    _errorMessages = errorMessages;

    // System prompt instructs Gemini in the user's language
    final langInstruction = switch (locale) {
      'pt' => 'Responda sempre em português brasileiro.',
      'es' => 'Responda siempre en español.',
      _ => 'Always respond in English.',
    };

    // The system prompt is an internal instruction to the AI model —
    // it is not user-facing UI text, so it uses a fixed multilingual format
    // that the LLM understands regardless of the user's locale.
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are the migration assistant for the Movaro app. '
        'The user is planning to move from $originCountry to $destinationCountry. '
        '$langInstruction '
        'Answer concisely, practically, and in a friendly tone. '
        'Use ONLY information from the provided reference context below. '
        'If the question cannot be answered from the context, clearly state that '
        'you do not have that information and suggest consulting official sources. '
        'NEVER fabricate data, laws, deadlines, or values. '
        'Keep answers short (max 3 paragraphs). '
        'Use bullet points when listing steps or requirements.\n\n'
        '--- REFERENCE CONTEXT ---\n'
        '$curatedContent\n'
        '--- END OF CONTEXT ---',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 512,
      ),
    );

    _chat = _model!.startChat();
    _loadCache();
  }

  /// Send a message and get a streamed response.
  Stream<String> sendMessage(String userMessage) async* {
    if (_model == null || _chat == null) {
      yield _errorMessages.notInitialized;
      return;
    }

    _history.add(ChatMessage(
      role: 'user',
      text: userMessage,
      timestamp: DateTime.now(),
    ));

    // Check cache first
    final cacheKey = _normalizeCacheKey(userMessage);
    final cached = _responseCache[cacheKey];
    if (cached != null) {
      _history.add(ChatMessage(
        role: 'assistant',
        text: cached,
        timestamp: DateTime.now(),
      ));
      yield cached;
      return;
    }

    // Rate limiting
    final canProceed = await _waitForRateLimit();
    if (!canProceed) {
      final msg = _errorMessages.rateLimit;
      _history.add(ChatMessage(
        role: 'assistant',
        text: msg,
        timestamp: DateTime.now(),
      ));
      yield msg;
      return;
    }

    // Call Gemini with streaming
    try {
      final buffer = StringBuffer();
      final stream = _chat!.sendMessageStream(
        Content.text(userMessage),
      );

      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
          yield text;
        }
      }

      final fullResponse = buffer.toString();
      if (fullResponse.isNotEmpty) {
        _history.add(ChatMessage(
          role: 'assistant',
          text: fullResponse,
          timestamp: DateTime.now(),
        ));

        _responseCache[cacheKey] = fullResponse;
        _saveCache();
      }
    } on GenerativeAIException catch (e) {
      final errorMsg = e.message.contains('429') ||
              e.message.contains('RESOURCE_EXHAUSTED')
          ? _errorMessages.apiLimit
          : _errorMessages.generic;
      _history.add(ChatMessage(
        role: 'assistant',
        text: errorMsg,
        timestamp: DateTime.now(),
      ));
      yield errorMsg;
    }
  }

  /// Clear chat history (but keep cache).
  void clearHistory() {
    _history.clear();
    _chat = _model?.startChat();
  }

  // --- Rate limiting ---

  Future<bool> _waitForRateLimit() async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((t) => t.isBefore(oneMinuteAgo));

    if (_requestTimestamps.length >= _maxRpm) {
      final oldest = _requestTimestamps.first;
      final wait = oldest.add(const Duration(minutes: 1)).difference(now);
      if (wait.isNegative) {
        _requestTimestamps.add(now);
        return true;
      }
      if (wait.inSeconds > 30) {
        return false;
      }
      await Future<void>.delayed(wait + const Duration(milliseconds: 200));
    }

    _requestTimestamps.add(DateTime.now());
    return true;
  }

  // --- Caching ---

  static const _cacheKey = 'gemini_response_cache';

  String _normalizeCacheKey(String query) {
    return query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _responseCache.addAll(
          map.map((k, v) => MapEntry(k, v as String)),
        );
      }
    } catch (_) {
      // Ignore cache load errors
    }
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_responseCache.length > 50) {
        final keys = _responseCache.keys.toList();
        for (var i = 0; i < keys.length - 50; i++) {
          _responseCache.remove(keys[i]);
        }
      }
      await prefs.setString(_cacheKey, jsonEncode(_responseCache));
    } catch (_) {
      // Ignore cache save errors
    }
  }
}

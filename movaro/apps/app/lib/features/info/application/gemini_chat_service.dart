import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A chat message in the conversation.
class ChatMessage {
  const ChatMessage({required this.role, required this.text, this.timestamp});

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

/// Snapshot of the user's current migration state, injected into the system
/// prompt so the assistant can give personalised, context-aware responses.
class UserMigrationContext {
  const UserMigrationContext({
    this.journeyState = 'not_started',
    this.migrationGoal,
    this.highlightedCity,
    this.currentPhase,
    this.currentItemTitle,
    this.completedItemIds = const [],
    this.completedCount = 0,
    this.totalItems = 0,
    this.progressPercent = 0,
    this.planTimeline,
  });

  /// One of: not_started | origin_selected | destination_selected |
  /// questionnaire_in_progress | plan_generated | copilot_active
  final String journeyState;

  /// e.g. 'work', 'study', 'retire', 'family'
  final String? migrationGoal;

  /// Human-readable city name from the current plan context.
  final String? highlightedCity;

  /// Current copilot phase: preparation | documents | housing | work | arrival
  final String? currentPhase;

  /// Title of the current pending guide item.
  final String? currentItemTitle;

  /// IDs of all completed guide items.
  final List<String> completedItemIds;

  final int completedCount;
  final int totalItems;
  final int progressPercent;

  /// e.g. '3_months', '6_months', '1_year'
  final String? planTimeline;
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
    UserMigrationContext userContext = const UserMigrationContext(),
  }) {
    _errorMessages = errorMessages;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        _buildSystemPrompt(
          originCountry: originCountry,
          destinationCountry: destinationCountry,
          locale: locale,
          curatedContent: curatedContent,
          userContext: userContext,
        ),
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
    dev.log(
      '[GeminiChat] sendMessage: "${userMessage.substring(0, userMessage.length.clamp(0, 60))}"',
    );
    if (_model == null || _chat == null) {
      dev.log('[GeminiChat] ✗ model/chat is null — not initialized');
      yield _errorMessages.notInitialized;
      return;
    }

    _history.add(
      ChatMessage(role: 'user', text: userMessage, timestamp: DateTime.now()),
    );

    // Check cache first
    final cacheKey = _normalizeCacheKey(userMessage);
    final cached = _responseCache[cacheKey];
    if (cached != null) {
      _history.add(
        ChatMessage(role: 'assistant', text: cached, timestamp: DateTime.now()),
      );
      yield cached;
      return;
    }

    // Rate limiting
    final canProceed = await _waitForRateLimit();
    if (!canProceed) {
      final msg = _errorMessages.rateLimit;
      _history.add(
        ChatMessage(role: 'assistant', text: msg, timestamp: DateTime.now()),
      );
      yield msg;
      return;
    }

    // Call Gemini with streaming
    try {
      final buffer = StringBuffer();
      final stream = _chat!.sendMessageStream(Content.text(userMessage));

      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
          yield text;
        }
      }

      final fullResponse = buffer.toString();
      if (fullResponse.isNotEmpty) {
        _history.add(
          ChatMessage(
            role: 'assistant',
            text: fullResponse,
            timestamp: DateTime.now(),
          ),
        );

        _responseCache[cacheKey] = fullResponse;
        _saveCache();
      }
    } on GenerativeAIException catch (e) {
      dev.log('[GeminiChat] ✗ GenerativeAIException: ${e.message}');
      final errorMsg =
          e.message.contains('429') || e.message.contains('RESOURCE_EXHAUSTED')
          ? _errorMessages.apiLimit
          : _errorMessages.generic;
      _history.add(
        ChatMessage(
          role: 'assistant',
          text: errorMsg,
          timestamp: DateTime.now(),
        ),
      );
      yield errorMsg;
    } catch (e) {
      dev.log('[GeminiChat] ✗ Unexpected error: $e');
      final errorMsg = _errorMessages.generic;
      _history.add(
        ChatMessage(
          role: 'assistant',
          text: errorMsg,
          timestamp: DateTime.now(),
        ),
      );
      yield errorMsg;
    }
  }

  /// Clear chat history (but keep cache).
  void clearHistory() {
    _history.clear();
    _chat = _model?.startChat();
  }

  // --- System prompt ---

  static String _buildSystemPrompt({
    required String originCountry,
    required String destinationCountry,
    required String locale,
    required String curatedContent,
    required UserMigrationContext userContext,
  }) {
    final corridor =
        '${_capitalize(originCountry)} → ${_capitalize(destinationCountry)}';

    return '''
=== MOVARO AI ASSISTANT — SYSTEM PROMPT ===

<identity>
You are the Movaro Assistant — an in-app guide that helps users plan and execute their international migration. You are NOT a general-purpose chatbot. You exist inside the Movaro app and your sole purpose is to help users navigate the migration process.
</identity>

<language_rules>
- ALWAYS respond in the same language the user writes in.
- Supported languages: Português Brasileiro, Español, English.
- If the language cannot be identified, respond in English.
- Never mix languages in a single response.
- Use natural, conversational tone in all languages.
</language_rules>

<tone_and_style>
- Be warm, practical, and direct — like a friend who already went through the migration process.
- Keep responses SHORT: 2-4 paragraphs maximum unless the user explicitly asks for detail.
- Use bullet points only when listing steps or documents.
- Avoid bureaucratic jargon — always explain complex terms simply.
- Never lecture. Guide.
- Use emoji sparingly (1-2 per message max, only when it aids clarity).
- Never start every response with "Claro!" / "¡Claro!" / "Sure!" — vary your openings.
- Never end every response with a question — only ask when you genuinely need clarification.
</tone_and_style>

<scope_definition>
YOU CAN help with:
- Migration processes between supported countries
- Documentation requirements (visas, permits, CPF, residency)
- Cost of living and financial planning for migration
- City comparison and destination selection
- Housing, work, healthcare, and adaptation in the destination country
- How to use the Movaro app (features, navigation, next steps)
- Questions about the user's migration plan and copilot guide

YOU CANNOT help with:
- Politics, elections, political figures, or political opinions
- General topics unrelated to migration (sports, entertainment, technology, etc.)
- Countries or corridors not yet supported by the app
- Legal advice (you can share general info but must disclaim you are not a lawyer)
- Medical advice
- Financial investment advice

ACTIVE CORRIDOR: $corridor
SUPPORTED_CORRIDORS: $corridor
</scope_definition>

<out_of_scope_responses>
When the user asks about something outside your scope:

For unsupported topics:
- PT: "Esse assunto está fora do que posso te ajudar aqui no Movaro. Posso te ajudar com algo sobre sua mudança?"
- ES: "Ese tema está fuera de lo que puedo ayudarte aquí en Movaro. ¿Puedo ayudarte con algo sobre tu mudanza?"
- EN: "That topic is outside what I can help with in Movaro. Can I help you with something about your move?"

For unsupported countries/corridors:
- PT: "No momento, esse corredor ainda não está disponível no Movaro. Estamos trabalhando para expandir! O corredor disponível agora é: $corridor."
- ES: "Por el momento, ese corredor aún no está disponible en Movaro. ¡Estamos trabajando para expandirnos! El corredor disponible ahora es: $corridor."
- EN: "That corridor is not available in Movaro yet. We are working on expanding! The available corridor is: $corridor."

For political topics:
- Decline without engaging. Do not offer opinions, summaries, or "balanced views."
</out_of_scope_responses>

<source_of_truth>
APP DATA is the source of truth. Rules — NO EXCEPTIONS:

1. When app data is available for a topic, use ONLY that data. Do not supplement, modify, or contradict it with your own knowledge.
2. When app data is NOT available for a topic:
   a. If it is a general migration concept (what is a visa, how embassies work): you may answer using general knowledge BUT flag it clearly.
   b. If it is a specific fact (cost, deadline, requirement, phone number, address): DO NOT guess. Say you do not have that information.
3. NEVER invent:
   - Specific costs or prices
   - Deadlines or processing times
   - Document requirements
   - Phone numbers, addresses, or URLs
   - Names of offices or institutions
   - Legal requirements or rules
4. When uncertain, use safe language:
   - PT: "Segundo os dados do app..." / "Essa informação pode variar. Vale verificar na seção do app."
   - ES: "Según los datos de la app..." / "Esta información puede variar."
   - EN: "According to the app's data..." / "This may vary — I recommend checking the app."
5. NEVER say "based on my knowledge" or "I think" for factual claims. Either cite the app data or disclaim.
</source_of_truth>

<product_consistency>
Only reference features that ACTUALLY exist in the app:
- Journey Setup (origin/destination selection)
- Migration Questionnaire
- Migration Plan Result (with a highlighted city and alternatives)
- Copilot / Guia — step-by-step guide with phases: preparation → documents → housing → work → arrival
- Explore — city catalog and comparison
- Info / Documentation guides
- Favorites — saved cities
- This assistant chat

NEVER suggest features that do not exist (e.g., "book a flight," "connect with a lawyer," "schedule a call," "link your bank account").

If the user asks for something the app does not support yet:
- PT: "Essa funcionalidade ainda não está disponível no Movaro, mas é algo que estamos considerando!"
- ES: "Esa funcionalidad aún no está disponible en Movaro, ¡pero es algo que estamos considerando!"
- EN: "That feature is not available in Movaro yet, but it is something we are considering!"
</product_consistency>

<corridor_specific_knowledge>
ACTIVE CORRIDOR: $corridor

Key context for Argentina → Brasil:
- CPF (Cadastro de Pessoa Física) is the most critical first step for Argentines in Brazil. Without it, almost nothing works (bank account, lease, etc.).
- MERCOSUL agreement facilitates residency but still requires a bureaucratic process.
- VITEM V is the common work visa type.
- Diploma recognition (revalidação) through MEC/REVALIDA is lengthy, especially for healthcare professionals.
- ARS→BRL exchange rate is volatile; cost data may need periodic verification.
- Common destination cities: São Paulo, Florianópolis, Curitiba, Rio de Janeiro.

This context helps you interpret and discuss the app data accurately. Always defer to specific app data when available.
</corridor_specific_knowledge>

<response_format>
Structure responses for mobile readability:
1. Lead with the answer or most important information.
2. Add context or explanation only if needed.
3. End with a clear next step within the app when relevant.

NEVER use walls of text. NEVER repeat information already obvious from context.
</response_format>

<safety_and_disclaimers>
1. Legal: "As informações no Movaro são orientativas. Para questões legais, consulte um advogado especializado em imigração."
2. Medical: Do not provide health advice. Direct to local health authorities.
3. Financial: Share app data on costs but disclaim values are estimates.
4. Emergency: If user mentions danger or crisis, provide local emergency numbers and encourage seeking immediate help.
</safety_and_disclaimers>

USER CORRIDOR: $corridor
USER LANGUAGE INSTRUCTION: ${_langInstruction(locale)}

${_buildContextSection(userContext)}

${curatedContent.isNotEmpty ? '--- APP DATA (source of truth) ---\n$curatedContent\n--- END OF APP DATA ---' : ''}

=== END OF SYSTEM PROMPT ===''';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _langInstruction(String locale) => switch (locale) {
    'pt' =>
      'ALWAYS respond in Português Brasileiro, regardless of what language the system prompt is written in.',
    'es' =>
      'ALWAYS respond in Español, regardless of what language the system prompt is written in.',
    _ =>
      'ALWAYS respond in English, regardless of what language the system prompt is written in.',
  };

  static String _buildContextSection(UserMigrationContext ctx) {
    final lines = StringBuffer();
    lines.writeln('<user_context>');
    lines.writeln('journey_state: ${ctx.journeyState}');

    if (ctx.migrationGoal != null) {
      lines.writeln('migration_goal: ${ctx.migrationGoal}');
    }
    if (ctx.highlightedCity != null) {
      lines.writeln('current_plan_city: ${ctx.highlightedCity}');
    }
    if (ctx.planTimeline != null) {
      lines.writeln('plan_timeline: ${ctx.planTimeline}');
    }
    if (ctx.currentPhase != null) {
      lines.writeln('current_phase: ${ctx.currentPhase}');
    }
    if (ctx.currentItemTitle != null) {
      lines.writeln('current_pending_item: ${ctx.currentItemTitle}');
    }
    if (ctx.totalItems > 0) {
      lines.writeln(
        'progress: ${ctx.completedCount}/${ctx.totalItems} items completed (${ctx.progressPercent}%)',
      );
    }
    if (ctx.completedItemIds.isNotEmpty) {
      lines.writeln('completed_item_ids: ${ctx.completedItemIds.join(', ')}');
    }
    lines.writeln('</user_context>');

    lines.writeln();
    lines.writeln('<context_rules>');

    switch (ctx.journeyState) {
      case 'not_started':
        lines.writeln(
          'The user has not started their journey. Guide them to open Journey Setup in the app.',
        );
      case 'origin_selected':
        lines.writeln(
          'The user selected their origin but has not chosen a destination yet. Help them explore destination options.',
        );
      case 'destination_selected':
      case 'questionnaire_in_progress':
        lines.writeln(
          'The user is setting up their plan. Encourage them to complete the Migration Questionnaire to unlock a more organized guide.',
        );
      case 'plan_generated':
        lines.writeln(
          'The user has a generated plan centered on "${ctx.highlightedCity ?? "unknown"}". '
          'They may still be comparing options. Help them understand the tradeoffs and explore their plan.',
        );
      case 'copilot_active':
        final city = ctx.highlightedCity ?? 'their destination';
        final phase = ctx.currentPhase ?? 'preparation';
        lines.writeln(
          'The user is actively following their copilot guide for $city. '
          'Current phase: $phase. '
          '${ctx.currentItemTitle != null ? 'The next pending item is: "${ctx.currentItemTitle}". ' : ''}'
          'When relevant, reference their current phase and common next steps. '
          'Do NOT list items they have already completed (IDs listed above).',
        );
      default:
        break;
    }

    lines.writeln(
      'NEVER mention context field names (journey_state, current_phase, etc.) to the user. '
      'Say "your plan" not "your plan_generated object". '
      'If context is partially missing, work with what you have.',
    );
    lines.writeln('</context_rules>');

    return lines.toString();
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
        _responseCache.addAll(map.map((k, v) => MapEntry(k, v as String)));
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

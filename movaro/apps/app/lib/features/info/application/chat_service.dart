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
  const ChatStarterPrompts({required this.categories, required this.chips});

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
    this.highlightedCityId,
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
  final String? highlightedCityId;
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

    String answerText;
    try {
      final answer = await _ask(trimmed);
      answerText = _sanitizeWellFormedUtf16(answer.text);
      if (answerText.trim().isEmpty) {
        // Backend reached but returned nothing usable — degrade gracefully.
        answerText = localFallbackAnswer(trimmed, _locale);
      }
    } catch (e) {
      // The live assistant is unreachable (network, validation, or backend
      // failure). Never dead-end the user: answer locally with curated
      // guidance and a pointer to the in-app Guides.
      dev.log('[ChatService] ask failed, using local fallback: $e');
      answerText = localFallbackAnswer(trimmed, _locale);
    }

    _history.add(
      ChatMessage(
        role: 'assistant',
        text: answerText,
        timestamp: DateTime.now(),
      ),
    );

    // Stream Unicode-safe chunks for the typewriter effect.
    final scalarValues = answerText.runes.toList(growable: false);
    const chunkSize = 4;
    for (var i = 0; i < scalarValues.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, scalarValues.length);
      yield String.fromCharCodes(scalarValues.sublist(i, end));
      await Future<void>.delayed(const Duration(milliseconds: 12));
    }
  }

  void clearHistory() => _history.clear();

  Future<ChatServiceAnswer> _ask(String message) async {
    final body = <String, dynamic>{
      'message': message,
      // Default to the validated corridor so the request never fails backend
      // validation when the journey context is not set yet.
      'originCountry': _originCountry.trim().isEmpty ? 'argentina' : _originCountry,
      'destinationCountry': _destinationCountry.trim().isEmpty
          ? 'brasil'
          : _destinationCountry,
      'locale': _locale,
      if (highlightedCityId != null) 'highlightedCityId': highlightedCityId,
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

    final text = _sanitizeWellFormedUtf16(data['answer'] as String? ?? '');
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

  static String _sanitizeWellFormedUtf16(String input) {
    if (input.isEmpty) return input;

    final units = input.codeUnits;
    final sanitized = <int>[];

    for (var i = 0; i < units.length; i++) {
      final unit = units[i];

      if (_isHighSurrogate(unit)) {
        if (i + 1 < units.length && _isLowSurrogate(units[i + 1])) {
          sanitized
            ..add(unit)
            ..add(units[i + 1]);
          i++;
          continue;
        }

        sanitized.add(_replacementCharacter);
        continue;
      }

      if (_isLowSurrogate(unit)) {
        sanitized.add(_replacementCharacter);
        continue;
      }

      sanitized.add(unit);
    }

    return String.fromCharCodes(sanitized);
  }

  static bool _isHighSurrogate(int codeUnit) =>
      codeUnit >= 0xD800 && codeUnit <= 0xDBFF;

  static bool _isLowSurrogate(int codeUnit) =>
      codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;

  static const int _replacementCharacter = 0xFFFD;

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

  /// Curated, on-device answer used when the live assistant cannot be reached
  /// (network, validation, or backend failure) or returns nothing usable.
  /// Keeps the assistant helpful instead of dead-ending the user and points to
  /// the in-app Guides. [locale] is a 2-letter code ('es' | 'pt' | 'en').
  static String localFallbackAnswer(String message, String locale) {
    final m = _normalizeMessage(message);
    bool has(List<String> kws) => kws.any(m.contains);

    if (has(['cpf', 'documento', 'document', 'rne', 'rnm', 'crnm', 'pasaporte', 'passaporte', 'passport'])) {
      return _tr(
        locale,
        es: 'Según fuentes oficiales, el CPF normalmente se tramita gratis (Correios, Banco do Brasil o Caixa, o en un consulado de Brasil) y suele ser lo primero que piden para banco, alquiler y trabajo. Te oriento por acá: abrí Guías › Documentos y confirmá el procedimiento en gov.br.',
        pt: 'Segundo as fontes oficiais, o CPF normalmente é gratuito (Correios, Banco do Brasil ou Caixa, ou num consulado do Brasil) e costuma ser o primeiro pedido para banco, aluguel e trabalho. Posso te orientar: abra Guias › Documentos e confirme o procedimento no gov.br.',
        en: 'According to official sources, the CPF is usually free (Correios, Banco do Brasil or Caixa, or at a Brazilian consulate) and is typically the first thing required for bank, rent and work. I can point you there: open Guides › Documents and confirm the procedure on gov.br.',
      );
    }
    if (has(['residencia', 'residencia', 'residency', 'mercosur', 'mercosul', 'visto', 'visa', 'radicar', 'radicacion'])) {
      return _tr(
        locale,
        es: 'Como argentino, normalmente entrás por el Acuerdo Mercosur y suele haber un plazo de 90 días desde el ingreso para iniciar la residencia temporaria en la Polícia Federal. Te oriento en Guías › Documentos; confirmá requisitos y plazos en gov.br / Polícia Federal.',
        pt: 'Como argentino, você normalmente entra pelo Acordo Mercosul e costuma haver um prazo de 90 dias da entrada para iniciar a residência temporária na Polícia Federal. Te oriento em Guias › Documentos; confirme requisitos e prazos no gov.br / Polícia Federal.',
        en: 'As an Argentine you usually enter under the Mercosur Agreement, and there is typically a 90-day window from entry to start temporary residency at the Federal Police. I can point you in Guides › Documents; confirm requirements and deadlines on gov.br / Federal Police.',
      );
    }
    if (has(['banco', 'conta', 'cuenta', 'bank', 'nubank', 'pix'])) {
      return _tr(
        locale,
        es: 'Para abrir una cuenta, normalmente piden CPF y comprobante de domicilio; los bancos digitales (Nubank, Inter, C6) suelen ser más simples para recién llegados. Te oriento en Guías › Documentos; confirmá las condiciones con cada banco.',
        pt: 'Para abrir conta, normalmente pedem CPF e comprovante de endereço; os bancos digitais (Nubank, Inter, C6) costumam ser mais simples para recém-chegados. Te oriento em Guias › Documentos; confirme as condições com cada banco.',
        en: 'To open an account, banks usually ask for a CPF and proof of address; digital banks (Nubank, Inter, C6) tend to be simplest for newcomers. I can point you in Guides › Documents; confirm the conditions with each bank.',
      );
    }
    if (has(['alquiler', 'aluguel', 'rent', 'vivienda', 'moradia', 'fiador', 'housing'])) {
      return _tr(
        locale,
        es: 'Para alquilar, suele haber opciones con seguro de alquiler o depósito en lugar de garante, y portales como QuintoAndar. Te oriento en Guías › Vivienda; confirmá las condiciones con la inmobiliaria.',
        pt: 'Para alugar, costuma haver opções com seguro-fiança ou depósito no lugar de fiador, e portais como QuintoAndar. Te oriento em Guias › Moradia; confirme as condições com a imobiliária.',
        en: 'To rent, there are usually rental-insurance or deposit options instead of a guarantor, and portals like QuintoAndar. I can point you in Guides › Housing; confirm the conditions with the rental agency.',
      );
    }
    if (has(['costo', 'custo', 'cost', 'salario', 'sueldo', 'presupuesto', 'orcamento', 'plata', 'dinero'])) {
      return _tr(
        locale,
        es: 'Los costos varían por ciudad. En cada ciudad hay una comparación de referencia entre el costo de vida típico y el salario medio (es referencia, no asesoría). Andá a Explorar y elegí una ciudad.',
        pt: 'Os custos variam por cidade. Em cada cidade há uma comparação de referência entre o custo de vida típico e o salário médio (é referência, não aconselhamento). Vá em Explorar e escolha uma cidade.',
        en: 'Costs vary by city. Each city shows a reference comparison between the typical cost of living and the average salary (a reference, not advice). Go to Explore and pick a city.',
      );
    }
    if (has(['sus', 'salud', 'saude', 'health', 'medico', 'hospital'])) {
      return _tr(
        locale,
        es: 'Según fuentes oficiales, el SUS es gratuito y universal, también para inmigrantes; para usarlo suele pedirse el Cartão SUS. Te oriento en Guías › Salud; confirmá en gov.br o en la unidad de salud.',
        pt: 'Segundo as fontes oficiais, o SUS é gratuito e universal, inclusive para imigrantes; para usar costuma-se tirar o Cartão SUS. Te oriento em Guias › Saúde; confirme no gov.br ou na unidade de saúde.',
        en: 'According to official sources, SUS is free and universal, including for immigrants; you usually get a SUS card to use it. I can point you in Guides › Health; confirm on gov.br or at the health unit.',
      );
    }
    if (has(['portugues', 'portuguese', 'idioma', 'language', 'hablar', 'falar'])) {
      return _tr(
        locale,
        es: 'El portugués es la barrera nº1. Tenés frases prácticas en "Portugués esencial" para usar en el banco, la inmobiliaria, la Polícia Federal o el hospital.',
        pt: 'O português é a barreira nº1. Há frases prontas em "Português essencial" para usar no banco, na imobiliária, na Polícia Federal ou no hospital.',
        en: 'Portuguese is the #1 barrier. There are ready-to-use phrases in “Essential Portuguese” for the bank, rental office, Federal Police or hospital.',
      );
    }

    return _tr(
      locale,
      es: 'No pude conectar con el asistente en vivo ahora. Te oriento mientras tanto: abrí las Guías (CPF, residencia Mercosur, banco, vivienda, salud, conducir, costos), con enlaces a fuentes oficiales. O probá de nuevo en un momento.',
      pt: 'Não consegui conectar com o assistente ao vivo agora. Te oriento enquanto isso: abra as Guias (CPF, residência Mercosul, banco, moradia, saúde, direção, custos), com links para fontes oficiais. Ou tente de novo em instantes.',
      en: 'I could not reach the live assistant right now. Meanwhile, I can point you to the Guides (CPF, Mercosur residency, bank, housing, health, driving, costs), with links to official sources. Or try again in a moment.',
    );
  }

  static String _tr(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) return es;
    if (l.startsWith('en')) return en;
    return pt;
  }

  static String _normalizeMessage(String value) {
    const accents = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a',
      'é': 'e', 'ê': 'e',
      'í': 'i',
      'ó': 'o', 'ô': 'o', 'õ': 'o',
      'ú': 'u', 'ç': 'c', 'ñ': 'n',
    };
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    return buffer.toString();
  }
}

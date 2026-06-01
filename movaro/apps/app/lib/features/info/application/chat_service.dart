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
        es: 'Para sacar el CPF siendo argentino podés hacerlo gratis en una agencia de Correios, Banco do Brasil o Caixa con tu DNI/pasaporte — o incluso desde Argentina, en un consulado de Brasil. Es el primer documento que vas a necesitar para casi todo (banco, alquiler, trabajo). Abrí la pestaña Guías › Documentos para el paso a paso.',
        pt: 'Para tirar o CPF sendo argentino, dá para fazer de graça numa agência dos Correios, Banco do Brasil ou Caixa com seu DNI/passaporte — ou até da Argentina, num consulado do Brasil. É o primeiro documento que você precisa para quase tudo (banco, aluguel, trabalho). Abra a aba Guias › Documentos para o passo a passo.',
        en: 'To get your CPF as an Argentine, you can do it for free at a Correios, Banco do Brasil or Caixa branch with your DNI/passport — or even from Argentina at a Brazilian consulate. It is the first document you need for almost everything (bank, rent, work). Open Guides › Documents for the step-by-step.',
      );
    }
    if (has(['residencia', 'residencia', 'residency', 'mercosur', 'mercosul', 'visto', 'visa', 'radicar', 'radicacion'])) {
      return _tr(
        locale,
        es: 'Como argentino entrás por el Acuerdo Mercosur: tenés hasta 90 días desde el ingreso para iniciar la residencia temporaria (hasta 2 años, después convertible en permanente) en la Polícia Federal. Llevá pasaporte/DNI, certificado de antecedentes y comprobantes. Mirá Guías › Documentos y trámites.',
        pt: 'Como argentino você entra pelo Acordo Mercosul: tem até 90 dias da entrada para iniciar a residência temporária (até 2 anos, depois convertível em permanente) na Polícia Federal. Leve passaporte/DNI, certidão de antecedentes e comprovantes. Veja Guias › Documentos.',
        en: 'As an Argentine you enter under the Mercosur Agreement: you have up to 90 days from entry to start temporary residency (up to 2 years, later convertible to permanent) at the Federal Police. Bring passport/DNI, criminal-record certificate and proof documents. See Guides › Documents.',
      );
    }
    if (has(['banco', 'conta', 'cuenta', 'bank', 'nubank', 'pix'])) {
      return _tr(
        locale,
        es: 'Para abrir una cuenta bancaria necesitás CPF y comprobante de domicilio. Los bancos digitales (Nubank, Inter, C6) suelen ser los más fáciles para recién llegados y permiten Pix. Mirá Guías › Documentos.',
        pt: 'Para abrir conta bancária você precisa de CPF e comprovante de endereço. Os bancos digitais (Nubank, Inter, C6) costumam ser os mais fáceis para recém-chegados e já têm Pix. Veja Guias › Documentos.',
        en: 'To open a bank account you need a CPF and proof of address. Digital banks (Nubank, Inter, C6) are usually easiest for newcomers and support Pix. See Guides › Documents.',
      );
    }
    if (has(['alquiler', 'aluguel', 'rent', 'vivienda', 'moradia', 'fiador', 'housing'])) {
      return _tr(
        locale,
        es: 'Para alquilar sin fiador, buscá opciones con seguro-fiança o depósito y portales como QuintoAndar o Zap. Conviene arrancar con algo temporario los primeros días. Mirá Guías › Vivienda y llegada.',
        pt: 'Para alugar sem fiador, procure opções com seguro-fiança ou depósito e portais como QuintoAndar ou Zap. Vale começar com algo temporário nos primeiros dias. Veja Guias › Moradia e chegada.',
        en: 'To rent without a guarantor, look for rental-insurance or deposit options and portals like QuintoAndar or Zap. Start with something temporary for the first days. See Guides › Housing and arrival.',
      );
    }
    if (has(['costo', 'custo', 'cost', 'salario', 'sueldo', 'presupuesto', 'orcamento', 'plata', 'dinero'])) {
      return _tr(
        locale,
        es: 'Los costos varían mucho por ciudad. En la ficha de cada ciudad tenés "¿Se puede vivir con el sueldo de acá?", donde podés comparar el costo de vida típico con tu propio sueldo. Andá a Explorar y elegí una ciudad.',
        pt: 'Os custos variam muito por cidade. Na ficha de cada cidade há "Dá pra viver com o salário daqui?", onde você compara o custo de vida típico com o seu próprio salário. Vá em Explorar e escolha uma cidade.',
        en: 'Costs vary a lot by city. Each city page has "Can you live on the local salary?", where you can compare the typical cost of living with your own income. Go to Explore and pick a city.',
      );
    }
    if (has(['sus', 'salud', 'saude', 'health', 'medico', 'hospital'])) {
      return _tr(
        locale,
        es: 'La salud pública (SUS) es gratuita y universal, también para inmigrantes. Para usarla conviene sacar el Cartão SUS en una unidad de salud con un documento y comprobante de domicilio. Mirá Guías › Salud.',
        pt: 'A saúde pública (SUS) é gratuita e universal, inclusive para imigrantes. Para usar, vale tirar o Cartão SUS numa unidade de saúde com documento e comprovante de endereço. Veja Guias › Saúde.',
        en: 'Public health (SUS) is free and universal, including for immigrants. To use it, get your SUS card at a health unit with an ID and proof of address. See Guides › Health.',
      );
    }
    if (has(['portugues', 'portuguese', 'idioma', 'language', 'hablar', 'falar'])) {
      return _tr(
        locale,
        es: 'El portugués es la barrera nº1 para trabajo y trámites. Enfocate en frases prácticas: en cada paso de las Guías hay frases en portugués para usar en el banco, la inmobiliaria o el hospital.',
        pt: 'O português é a barreira nº1 para trabalho e burocracia. Foque em frases práticas: em cada passo das Guias há frases em português para usar no banco, na imobiliária ou no hospital.',
        en: 'Portuguese is the #1 barrier for work and paperwork. Focus on practical phrases: each step in the Guides includes Portuguese phrases to use at the bank, rental office or hospital.',
      );
    }

    return _tr(
      locale,
      es: 'Ahora no pude conectar con el asistente en vivo. Mientras tanto, abrí la pestaña Guías para CPF, residencia Mercosur, banco, vivienda, salud (SUS), conducir y costos — con fuentes oficiales. O probá de nuevo en un momento.',
      pt: 'Agora não consegui conectar com o assistente ao vivo. Enquanto isso, abra a aba Guias para CPF, residência Mercosul, banco, moradia, saúde (SUS), direção e custos — com fontes oficiais. Ou tente de novo em instantes.',
      en: 'I could not reach the live assistant right now. Meanwhile, open the Guides tab for CPF, Mercosur residency, bank, housing, health (SUS), driving and costs — with official sources. Or try again in a moment.',
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

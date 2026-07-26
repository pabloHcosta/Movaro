import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/domain/entities/chat_message.dart';

/// The answer source returned by the backend orchestrator.
enum ChatAnswerSource { appData, ai, unknown }

/// A single message in the conversation history.
///
/// Compatibility alias kept for existing presentation code.
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
/// By default, answers come from the deterministic on-device knowledge base.
/// This keeps the assistant useful offline and prevents a migration or legal
/// answer from changing with a generative model. Remote structured knowledge
/// can be enabled explicitly, but generative AI is not required.
///
/// Exposes a streaming interface so the existing chat UI keeps its typewriter
/// interaction without depending on a generative model.
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
    this.useRemoteKnowledge = false,
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
  final bool useRemoteKnowledge;

  final List<ChatMessage> _history = [];

  AppLocalizations get _l10n => lookupAppLocalizations(Locale(_locale));

  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Send a message and stream the response character by character for a
  /// typewriter effect.
  Stream<String> sendMessage(String userMessage) async* {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    _history.add(
      ChatMessage(role: 'user', text: trimmed, timestamp: DateTime.now()),
    );

    dev.log(
      '[ChatService] ask: "${trimmed.substring(0, trimmed.length.clamp(0, 60))}"',
    );

    var answerText = _enrichLocalAnswer(
      trimmed,
      localFallbackAnswer(trimmed, _locale),
    );
    if (useRemoteKnowledge) {
      try {
        final answer = await _ask(trimmed);
        final remoteText = _sanitizeWellFormedUtf16(answer.text);
        if (answer.source == ChatAnswerSource.appData &&
            answer.confidence >= 0.72 &&
            remoteText.trim().isNotEmpty) {
          answerText = remoteText;
        }
      } catch (e) {
        dev.log('[ChatService] structured knowledge unavailable: $e');
      }
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

  String _enrichLocalAnswer(String message, String answer) {
    final normalized = _normalizeMessage(message);
    final source = _officialSourceFor(normalized);
    final contextParts = <String>[
      if (highlightedCityId != null && highlightedCityId!.trim().isNotEmpty)
        _tr(
          _locale,
          pt: 'cidade do plano: ${_humanizeCityId(highlightedCityId!)}',
          es: 'ciudad del plan: ${_humanizeCityId(highlightedCityId!)}',
          en: 'plan city: ${_humanizeCityId(highlightedCityId!)}',
        ),
      if (currentPhase != null && currentPhase!.trim().isNotEmpty)
        _tr(
          _locale,
          pt: 'fase atual: ${currentPhase!}',
          es: 'fase actual: ${currentPhase!}',
          en: 'current phase: ${currentPhase!}',
        ),
    ];
    final contextLine = contextParts.isEmpty
        ? ''
        : '\n\n${_tr(_locale, pt: 'Contexto usado', es: 'Contexto usado', en: 'Context used')}: ${contextParts.join(' · ')}.';
    final sourceLine = source == null
        ? ''
        : '\n\n${_tr(_locale, pt: 'Fonte oficial', es: 'Fuente oficial', en: 'Official source')}: $source';
    return '$answer$contextLine$sourceLine';
  }

  static String _humanizeCityId(String value) {
    final words = value
        .replaceAll(
          RegExp(
            r'-(?:ac|al|ap|am|ba|ce|df|es|go|ma|mt|ms|mg|pa|pb|pr|pe|pi|rj|rn|rs|ro|rr|sc|sp|se|to)$',
          ),
          '',
        )
        .split('-');
    return words
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String? _officialSourceFor(String message) {
    if (_containsAny(message, [
      'residencia',
      'residency',
      'mercosur',
      'mercosul',
      'visto',
      'visa',
    ])) {
      return 'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia';
    }
    if (_containsAny(message, [
      'cpf',
      'documento',
      'document',
      'rnm',
      'passport',
      'passaporte',
    ])) {
      return 'https://www.gov.br/receitafederal/pt-br/assuntos/meu-cpf/inscricao-no-cpf';
    }
    if (_containsAny(message, [
      'medicamento',
      'remedio',
      'medicacion',
      'medicine',
      'receta',
    ])) {
      return 'https://www.gov.br/anvisa/pt-br/assuntos/medicamentos/controlados/medicamentos-em-viagens-internacionais';
    }
    if (_containsAny(message, [
      'mascota',
      'pet',
      'perro',
      'gato',
      'cachorro',
      'dog',
      'cat',
    ])) {
      return 'https://www.gov.br/agricultura/pt-br/assuntos/vigilancia-agropecuaria/animais-estimacao/entrar-no-brasil';
    }
    if (_containsAny(message, [
      'sus',
      'salud',
      'saude',
      'health',
      'hospital',
    ])) {
      return 'https://www.gov.br/saude/pt-br/composicao/saps/equidade-em-saude/saude-de-migrantes-refugiados-e-apatridas';
    }
    if (_containsAny(message, [
      'impuesto',
      'imposto',
      'tax',
      'receita',
      'renda exterior',
      'mei',
    ])) {
      return 'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda';
    }
    return null;
  }

  Future<ChatServiceAnswer> _ask(String message) async {
    final body = <String, dynamic>{
      'message': message,
      // Default to the validated corridor so the request never fails backend
      // validation when the journey context is not set yet.
      'originCountry': _originCountry.trim().isEmpty
          ? 'argentina'
          : _originCountry,
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

    return localStarterPrompts();
  }

  ChatStarterPrompts localStarterPrompts() {
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
    bool has(List<String> kws) => _containsAny(m, kws);

    if (has([
      'cpf',
      'documento',
      'document',
      'rne',
      'rnm',
      'crnm',
      'pasaporte',
      'passaporte',
      'passport',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: el CPF puede solicitarse por los canales oficiales en Brasil o en el exterior. El servicio público es gratuito; unidades asociadas pueden cobrar la tarifa publicada. Para DNI o pasaporte, confirmá el documento aceptado según tu forma de ingreso. Abrí Guías › Documentos y verificá la fuente oficial vigente.',
        pt: 'Guia Movaro sem IA: o CPF pode ser solicitado pelos canais oficiais no Brasil ou no exterior. O serviço público é gratuito; unidades conveniadas podem cobrar a tarifa publicada. Para DNI ou passaporte, confirme o documento aceito conforme sua forma de entrada. Abra Guias › Documentos e verifique a fonte oficial vigente.',
        en: 'Movaro guidance without AI: CPF can be requested through official channels in Brazil or abroad. The public service is free; partner units may charge the published fee. For DNI or passport, confirm what your entry method accepts. Open Guides › Documents and verify the current official source.',
      );
    }
    if (has([
      'residencia',
      'residencia',
      'residency',
      'mercosur',
      'mercosul',
      'visto',
      'visa',
      'radicar',
      'radicacion',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: si sos argentino y cumplís los requisitos, el acuerdo bilateral Brasil–Argentina prevé una ruta de residencia permanente. La estadía como visitante y el pedido de residencia son temas distintos; no usamos 90 días como plazo universal para solicitarla. Abrí Guías › Documentos y confirmá tu elegibilidad en la Policía Federal.',
        pt: 'Guia Movaro sem IA: se você é argentino e cumpre os requisitos, o acordo bilateral Brasil–Argentina prevê uma rota de residência permanente. A estada como visitante e o pedido de residência são assuntos diferentes; não usamos 90 dias como prazo universal para solicitá-la. Abra Guias › Documentos e confirme sua elegibilidade na Polícia Federal.',
        en: 'Movaro guidance without AI: eligible Argentine nationals may use the Brazil–Argentina bilateral route to permanent residence. Visitor stay and residence are separate matters; we do not treat 90 days as a universal filing deadline. Open Guides › Documents and confirm eligibility with Federal Police.',
      );
    }
    if (has(['banco', 'conta', 'cuenta', 'bank', 'nubank', 'pix'])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: cada banco define sus documentos y hace su propio análisis. CPF, identificación migratoria y comprobante de domicilio suelen ser relevantes, pero no garantizan aprobación. Compará tarifas, Pix, atención y requisitos en Guías › Dinero, sin asumir que una marca aceptará tu caso.',
        pt: 'Guia Movaro sem IA: cada banco define seus documentos e faz sua própria análise. CPF, identificação migratória e comprovante de endereço costumam ser relevantes, mas não garantem aprovação. Compare tarifas, Pix, atendimento e requisitos em Guias › Dinheiro, sem presumir que uma marca aceitará seu caso.',
        en: 'Movaro guidance without AI: each bank sets its documents and performs its own review. CPF, migration ID, and proof of address are often relevant but do not guarantee approval. Compare fees, Pix, support, and requirements in Guides › Money without assuming a specific bank will accept your case.',
      );
    }
    if (has([
      'alquiler',
      'aluguel',
      'rent',
      'vivienda',
      'moradia',
      'fiador',
      'housing',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: el propietario puede pedir una garantía prevista en la ley, pero no debe acumular más de una en el mismo contrato; el depósito en dinero tiene límite legal. Leé el contrato, no pagues antes de verificar inmueble y titular, y abrí Guías › Vivienda para la fuente oficial.',
        pt: 'Guia Movaro sem IA: o locador pode pedir uma garantia prevista em lei, mas não deve acumular mais de uma no mesmo contrato; a caução em dinheiro tem limite legal. Leia o contrato, não pague antes de verificar imóvel e titular, e abra Guias › Moradia para a fonte oficial.',
        en: 'Movaro guidance without AI: a landlord may request one legally permitted guarantee but should not stack multiple guarantees in one contract; cash deposits have a legal cap. Read the contract, verify property and owner before paying, and open Guides › Housing for the official source.',
      );
    }
    if (has([
      'costo',
      'custo',
      'cost',
      'salario',
      'sueldo',
      'presupuesto',
      'orcamento',
      'plata',
      'dinero',
    ])) {
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
        es: 'Guía Movaro sin IA: migrantes pueden acceder al SUS; una urgencia no debe esperar a que tengas CPF o Tarjeta SUS. Para seguimiento, buscá la UBS de tu zona y confirmá los documentos locales. Abrí Guías › Salud. En emergencia: SAMU 192.',
        pt: 'Guia Movaro sem IA: migrantes podem acessar o SUS; uma urgência não deve esperar CPF ou Cartão SUS. Para acompanhamento, procure a UBS da sua região e confirme os documentos locais. Abra Guias › Saúde. Em emergência: SAMU 192.',
        en: 'Movaro guidance without AI: migrants can access SUS; urgent care should not wait for a CPF or SUS card. For ongoing care, find your local UBS and confirm local documents. Open Guides › Health. In an emergency call SAMU 192.',
      );
    }
    if (has([
      'medicamento',
      'remedio',
      'medicacion',
      'medicine',
      'prescription',
      'receta',
      'controlado',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: para viajar con medicamentos, llevá receta y documentación médica compatible con la cantidad. Los controlados tienen orientación específica de Anvisa. Abrí Guías › Medicamentos antes de embarcar.',
        pt: 'Guia Movaro sem IA: para viajar com medicamentos, leve receita e documentação médica compatível com a quantidade. Controlados têm orientação específica da Anvisa. Abra Guias › Medicamentos antes de embarcar.',
        en: 'Movaro guidance without AI: carry a prescription and medical documentation matching the quantity. Controlled medicines have specific Anvisa guidance. Open Guides › Medicines before travel.',
      );
    }
    if (has(['mascota', 'pet', 'perro', 'gato', 'cachorro', 'dog', 'cat'])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: perros y gatos deben cumplir requisitos sanitarios vigentes y también las reglas de la aerolínea. Abrí Guías › Viajar con mascota y confirmá todo antes de emitir el pasaje.',
        pt: 'Guia Movaro sem IA: cães e gatos precisam cumprir requisitos sanitários vigentes e também as regras da transportadora. Abra Guias › Viajar com pet e confirme tudo antes de emitir a passagem.',
        en: 'Movaro guidance without AI: dogs and cats must meet current health requirements and carrier rules. Open Guides › Traveling with a pet and confirm everything before ticketing.',
      );
    }
    if (has([
      'impuesto',
      'imposto',
      'tax',
      'afip',
      'receita',
      'renta',
      'renda exterior',
      'mei',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: residencia fiscal, ingresos de Argentina y MEI son temas distintos. Abrir MEI no regulariza automáticamente ingresos del exterior. Revisá Guías › Impuestos y, si tenés ingresos o patrimonio en ambos países, buscá un contador internacional.',
        pt: 'Guia Movaro sem IA: residência fiscal, renda da Argentina e MEI são assuntos diferentes. Abrir MEI não regulariza automaticamente renda do exterior. Veja Guias › Impostos e, se houver renda ou patrimônio nos dois países, procure contador internacional.',
        en: 'Movaro guidance without AI: tax residence, Argentine income, and MEI are separate matters. Opening MEI does not automatically settle foreign income. See Guides › Taxes and seek cross-border accounting advice if you have income or assets in both countries.',
      );
    }
    if (has([
      'escuela',
      'escola',
      'hijo',
      'filho',
      'nino',
      'crianca',
      'school',
      'child',
      'familia',
    ])) {
      return _tr(
        locale,
        es: 'Guía Movaro sin IA: niños y adolescentes migrantes tienen derecho a matrícula. Buscá la Secretaría de Educación local, llevá los documentos disponibles y pedí orientación formal si falta alguno. Abrí Guías › Familia.',
        pt: 'Guia Movaro sem IA: crianças e adolescentes migrantes têm direito à matrícula. Procure a Secretaria de Educação local, leve os documentos disponíveis e peça orientação formal se faltar algum. Abra Guias › Família.',
        en: 'Movaro guidance without AI: migrant children and adolescents have a right to school enrollment. Contact the local Education Department, bring available documents, and request formal guidance if one is missing. Open Guides › Family.',
      );
    }
    if (has([
      'portugues',
      'portuguese',
      'idioma',
      'language',
      'hablar',
      'falar',
    ])) {
      return _tr(
        locale,
        es: 'El portugués es la barrera nº1. Tenés frases prácticas en "Portugués esencial" para usar en el banco, la inmobiliaria, la Polícia Federal o el hospital.',
        pt: 'O português é a barreira nº1. Há frases prontas em "Português essencial" para usar no banco, na imobiliária, na Polícia Federal ou no hospital.',
        en: 'Portuguese is the #1 barrier. There are ready-to-use phrases in “Essential Portuguese” for the bank, rental office, Federal Police or hospital.',
      );
    }

    return _tr(
      locale,
      es: 'Guía Movaro sin IA: puedo orientarte con contenido revisado sobre residencia, CPF, vivienda, salud, dinero, impuestos, familia, mascotas y medicamentos. Escribí uno de esos temas o abrí Guías; para una decisión legal, médica o fiscal, confirmá siempre la fuente oficial o un profesional.',
      pt: 'Guia Movaro sem IA: posso orientar com conteúdo revisado sobre residência, CPF, moradia, saúde, dinheiro, impostos, família, pets e medicamentos. Escreva um desses temas ou abra Guias; para uma decisão jurídica, médica ou fiscal, confirme sempre a fonte oficial ou um profissional.',
      en: 'Movaro guidance without AI: I can help with reviewed content on residence, CPF, housing, health, money, taxes, family, pets, and medicines. Type one of those topics or open Guides; for legal, medical, or tax decisions, always confirm the official source or a professional.',
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
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    return buffer.toString();
  }

  static bool _containsAny(String message, List<String> keywords) {
    if (keywords.any(message.contains)) return true;
    final words = message
        .split(RegExp(r'[^a-z0-9]+'))
        .where((word) => word.length >= 4)
        .toList(growable: false);
    for (final keyword in keywords) {
      if (keyword.contains(' ') || keyword.length < 4) continue;
      for (final word in words) {
        if ((word.length - keyword.length).abs() <= 1 &&
            _editDistanceAtMostOne(word, keyword)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _editDistanceAtMostOne(String a, String b) {
    if (a == b) return true;
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0;
    var j = 0;
    var edits = 0;
    while (i < a.length && j < b.length) {
      if (a.codeUnitAt(i) == b.codeUnitAt(j)) {
        i++;
        j++;
        continue;
      }
      edits++;
      if (edits > 1) return false;
      if (a.length > b.length) {
        i++;
      } else if (b.length > a.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
    return edits + (a.length - i) + (b.length - j) <= 1;
  }
}

class QuickGuideQuestion {
  const QuickGuideQuestion({
    required this.id,
    required this.topic,
    required this.pt,
    required this.es,
    required this.en,
    this.aliases = const [],
  });

  final String id;
  final String topic;
  final String pt;
  final String es;
  final String en;
  final List<String> aliases;

  String questionFor(String languageCode) => switch (languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };

  String topicFor(String languageCode) => switch (topic) {
    'documents' => switch (languageCode) {
      'es' => 'Documentos',
      'en' => 'Documents',
      _ => 'Documentos',
    },
    'education' => switch (languageCode) {
      'es' => 'Educación',
      'en' => 'Education',
      _ => 'Educação',
    },
    'housing' => switch (languageCode) {
      'es' => 'Vivienda',
      'en' => 'Housing',
      _ => 'Moradia',
    },
    'work' => switch (languageCode) {
      'es' => 'Trabajo',
      'en' => 'Work',
      _ => 'Trabalho',
    },
    'money' => switch (languageCode) {
      'es' => 'Dinero',
      'en' => 'Money',
      _ => 'Dinheiro',
    },
    'health' => switch (languageCode) {
      'es' => 'Salud',
      'en' => 'Health',
      _ => 'Saúde',
    },
    'family' => switch (languageCode) {
      'es' => 'Familia',
      'en' => 'Family',
      _ => 'Família',
    },
    'arrival' => switch (languageCode) {
      'es' => 'Llegada',
      'en' => 'Arrival',
      _ => 'Chegada',
    },
    'rights' => switch (languageCode) {
      'es' => 'Derechos',
      'en' => 'Rights',
      _ => 'Direitos',
    },
    _ => switch (languageCode) {
      'es' => 'Orientación',
      'en' => 'Guidance',
      _ => 'Orientação',
    },
  };
}

class QuickGuideQuestionCatalog {
  const QuickGuideQuestionCatalog._();

  static const questions = <QuickGuideQuestion>[
    QuickGuideQuestion(
      id: 'documents.cpf',
      topic: 'documents',
      pt: 'Como faço o CPF?',
      es: '¿Cómo tramito el CPF?',
      en: 'How do I get a CPF?',
      aliases: ['cadastro fiscal', 'tax id', 'sacar cpf', 'obter cpf'],
    ),
    QuickGuideQuestion(
      id: 'documents.residence',
      topic: 'documents',
      pt: 'Como solicito autorização de residência?',
      es: '¿Cómo solicito la autorización de residencia?',
      en: 'How do I apply for residence authorization?',
      aliases: ['mercosul', 'mercosur', 'regularização', 'visa', 'visto'],
    ),
    QuickGuideQuestion(
      id: 'documents.differences',
      topic: 'documents',
      pt: 'Qual é a diferença entre CPF, protocolo e CRNM?',
      es: '¿Cuál es la diferencia entre CPF, protocolo y CRNM?',
      en: 'What is the difference between CPF, protocol, and CRNM?',
      aliases: ['rne', 'registro migratório', 'documentos estrangeiro'],
    ),
    QuickGuideQuestion(
      id: 'documents.travel',
      topic: 'documents',
      pt: 'Posso viajar com protocolo de residência?',
      es: '¿Puedo viajar con el protocolo de residencia?',
      en: 'Can I travel with a residence protocol?',
      aliases: ['sair do brasil', 'reingresso', 'viajar sem crnm'],
    ),
    QuickGuideQuestion(
      id: 'documents.delayed',
      topic: 'documents',
      pt: 'Meu processo de residência está parado. Como destravo?',
      es: 'Mi trámite de residencia está demorado. ¿Cómo lo destrabo?',
      en: 'My residence process is stalled. How do I unblock it?',
      aliases: ['atraso crnm', 'documento não chegou', 'proceso demorado'],
    ),
    QuickGuideQuestion(
      id: 'documents.dependencies',
      topic: 'documents',
      pt: 'Documentos, endereço e banco se bloqueiam. Por onde começo?',
      es: 'Documentos, domicilio y banco se bloquean. ¿Por dónde empiezo?',
      en: 'Documents, address, and banking block one another. Where do I start?',
      aliases: ['ordem documentos', 'tudo depende', 'por onde começar'],
    ),
    QuickGuideQuestion(
      id: 'education.school',
      topic: 'education',
      pt: 'Como matriculo meu filho na escola pública?',
      es: '¿Cómo inscribo a mi hijo en la escuela pública?',
      en: 'How do I enroll my child in public school?',
      aliases: ['matrícula escolar', 'educação básica', 'vacante escolar'],
    ),
    QuickGuideQuestion(
      id: 'education.missing_documents',
      topic: 'education',
      pt: 'A escola pode recusar matrícula por falta de documentos?',
      es: '¿La escuela puede rechazar la matrícula por falta de documentos?',
      en: 'Can a school refuse enrollment because documents are missing?',
      aliases: ['sem histórico escolar', 'sin documentos', 'criança migrante'],
    ),
    QuickGuideQuestion(
      id: 'education.diploma',
      topic: 'education',
      pt: 'Como valido um diploma estrangeiro no Brasil?',
      es: '¿Cómo valido un título extranjero en Brasil?',
      en: 'How do I validate a foreign diploma in Brazil?',
      aliases: [
        'revalidação',
        'revalidacion',
        'diploma argentino',
        'carolina bori',
      ],
    ),
    QuickGuideQuestion(
      id: 'education.university',
      topic: 'education',
      pt: 'Como uma pessoa estrangeira entra na universidade?',
      es: '¿Cómo ingresa una persona extranjera a la universidad?',
      en: 'How can a foreign national enter university?',
      aliases: ['sisu', 'vestibular', 'faculdade', 'universidad'],
    ),
    QuickGuideQuestion(
      id: 'housing.guarantees',
      topic: 'housing',
      pt: 'Quais garantias podem pedir no aluguel?',
      es: '¿Qué garantías pueden pedir para alquilar?',
      en: 'Which guarantees can a landlord request?',
      aliases: [
        'fiador',
        'caução',
        'seguro fiança',
        'alugar sem garantia',
        'guarantor rental guarantee',
      ],
    ),
    QuickGuideQuestion(
      id: 'housing.before_signing',
      topic: 'housing',
      pt: 'O que verifico antes de assinar um contrato de aluguel?',
      es: '¿Qué reviso antes de firmar un contrato de alquiler?',
      en: 'What should I check before signing a rental agreement?',
      aliases: ['vistoria', 'contrato imóvel', 'locador', 'inquilino'],
    ),
    QuickGuideQuestion(
      id: 'housing.early_termination',
      topic: 'housing',
      pt: 'Como saio do aluguel antes do fim do contrato?',
      es: '¿Cómo salgo del alquiler antes del plazo?',
      en: 'How do I leave a rental before the agreement ends?',
      aliases: ['multa aluguel', 'rescisão', 'rescisión', 'entregar imóvel'],
    ),
    QuickGuideQuestion(
      id: 'housing.scam',
      topic: 'housing',
      pt: 'Como identifico sinais de golpe em aluguel ou vaga?',
      es: '¿Cómo identifico señales de estafa en alquiler o empleo?',
      en: 'How do I identify scam signs in a rental or job offer?',
      aliases: ['fraude', 'anúncio falso', 'estafa', 'pagar antecipado'],
    ),
    QuickGuideQuestion(
      id: 'work.formal',
      topic: 'work',
      pt: 'O que preciso para trabalhar formalmente?',
      es: '¿Qué necesito para trabajar formalmente?',
      en: 'What do I need for formal employment?',
      aliases: ['carteira de trabalho', 'ctps', 'emprego registrado'],
    ),
    QuickGuideQuestion(
      id: 'work.models',
      topic: 'work',
      pt: 'Posso trabalhar como CLT, MEI ou remoto?',
      es: '¿Puedo trabajar como CLT, MEI o de forma remota?',
      en: 'Can I work under CLT, as MEI, or remotely?',
      aliases: ['autônomo', 'freelancer', 'empresa', 'trabalho remoto'],
    ),
    QuickGuideQuestion(
      id: 'work.search',
      topic: 'work',
      pt: 'Como procuro trabalho no Brasil?',
      es: '¿Cómo busco trabajo en Brasil?',
      en: 'How do I look for work in Brazil?',
      aliases: ['vaga', 'currículo', 'linkedin', 'emprego'],
    ),
    QuickGuideQuestion(
      id: 'work.exploitation',
      topic: 'rights',
      pt: 'Onde denuncio exploração ou abuso no trabalho?',
      es: '¿Dónde denuncio explotación o abuso laboral?',
      en: 'Where do I report exploitation or abuse at work?',
      aliases: ['trabalho escravo', 'assédio', 'denúncia trabalhista'],
    ),
    QuickGuideQuestion(
      id: 'money.reserve',
      topic: 'money',
      pt: 'Quanto devo reservar para os primeiros 30, 60 ou 90 dias?',
      es: '¿Cuánto debo reservar para los primeros 30, 60 o 90 días?',
      en: 'How much should I reserve for the first 30, 60, or 90 days?',
      aliases: ['reserva de emergência', 'primeiros meses', 'economia'],
    ),
    QuickGuideQuestion(
      id: 'money.budget',
      topic: 'money',
      pt: 'Como calculo meu custo mensal no Brasil?',
      es: '¿Cómo calculo mi costo mensual en Brasil?',
      en: 'How do I calculate my monthly cost in Brazil?',
      aliases: ['orçamento', 'custo de vida', 'gastos mensais'],
    ),
    QuickGuideQuestion(
      id: 'money.bank_refusal',
      topic: 'money',
      pt: 'O banco recusou minha conta. Como resolvo?',
      es: 'El banco rechazó mi cuenta. ¿Cómo lo resuelvo?',
      en: 'The bank refused my account. How do I resolve it?',
      aliases: ['abrir conta', 'conta sem crnm', 'banco estrangeiro'],
    ),
    QuickGuideQuestion(
      id: 'money.pix',
      topic: 'money',
      pt: 'Como consigo usar Pix sem CRNM?',
      es: '¿Cómo puedo usar Pix sin CRNM?',
      en: 'How can I use Pix without a CRNM?',
      aliases: ['pix estrangeiro', 'conta digital', 'cpf banco'],
    ),
    QuickGuideQuestion(
      id: 'money.remittance',
      topic: 'money',
      pt: 'Como envio dinheiro da Argentina para o Brasil?',
      es: '¿Cómo envío dinero de Argentina a Brasil?',
      en: 'How do I send money from Argentina to Brazil?',
      aliases: ['remessa internacional', 'câmbio', 'transferência'],
    ),
    QuickGuideQuestion(
      id: 'money.tax',
      topic: 'money',
      pt: 'Quando viro residente fiscal e como declaro renda do exterior?',
      es: '¿Cuándo paso a ser residente fiscal y cómo declaro ingresos del exterior?',
      en: 'When do I become a tax resident and report foreign income?',
      aliases: ['imposto de renda', 'receita federal', 'bens no exterior'],
    ),
    QuickGuideQuestion(
      id: 'health.sus',
      topic: 'health',
      pt: 'Como uma pessoa estrangeira acessa o SUS?',
      es: '¿Cómo accede una persona extranjera al SUS?',
      en: 'How can a foreign national access SUS?',
      aliases: ['ubs', 'cartão sus', 'hospital público', 'saúde pública'],
    ),
    QuickGuideQuestion(
      id: 'health.treatment',
      topic: 'health',
      pt: 'Como continuo um tratamento médico no Brasil?',
      es: '¿Cómo continúo un tratamiento médico en Brasil?',
      en: 'How do I continue medical treatment in Brazil?',
      aliases: ['doença crônica', 'receita médica', 'acompanhamento'],
    ),
    QuickGuideQuestion(
      id: 'health.medicine',
      topic: 'health',
      pt: 'Como levo medicamento controlado para o Brasil?',
      es: '¿Cómo llevo un medicamento controlado a Brasil?',
      en: 'How do I bring controlled medicine to Brazil?',
      aliases: ['remédio', 'anvisa', 'receita controlada', 'aduana'],
    ),
    QuickGuideQuestion(
      id: 'health.vaccination',
      topic: 'health',
      pt: 'Como atualizo minhas vacinas no Brasil?',
      es: '¿Cómo actualizo mis vacunas en Brasil?',
      en: 'How do I update my vaccinations in Brazil?',
      aliases: ['carteira vacinação', 'imunização', 'vacunación'],
    ),
    QuickGuideQuestion(
      id: 'health.prenatal',
      topic: 'health',
      pt: 'Como começo o pré-natal no Brasil?',
      es: '¿Cómo empiezo el prenatal en Brasil?',
      en: 'How do I start prenatal care in Brazil?',
      aliases: ['gravidez', 'gestante', 'embarazo', 'maternidade'],
    ),
    QuickGuideQuestion(
      id: 'health.mental',
      topic: 'health',
      pt: 'Como acesso atendimento de saúde mental?',
      es: '¿Cómo accedo a atención de salud mental?',
      en: 'How do I access mental healthcare?',
      aliases: ['caps', 'psicólogo', 'psiquiatra', 'crise emocional'],
    ),
    QuickGuideQuestion(
      id: 'family.documents',
      topic: 'family',
      pt: 'Como organizo residência, escola e documentos da minha família?',
      es: '¿Cómo organizo residencia, escuela y documentos de mi familia?',
      en: 'How do I organize residence, school, and family documents?',
      aliases: ['reunião familiar', 'dependente', 'filhos', 'cônjuge'],
    ),
    QuickGuideQuestion(
      id: 'arrival.pets',
      topic: 'arrival',
      pt: 'Como levo meu cachorro ou gato para o Brasil?',
      es: '¿Cómo llevo mi perro o gato a Brasil?',
      en: 'How do I bring my dog or cat to Brazil?',
      aliases: ['pet', 'mascota', 'certificado veterinário', 'vigiagro'],
    ),
    QuickGuideQuestion(
      id: 'arrival.customs',
      topic: 'arrival',
      pt: 'O que declaro na fronteira ao levar bagagem e bens?',
      es: '¿Qué declaro en la frontera al llevar equipaje y bienes?',
      en: 'What do I declare at the border when bringing baggage and goods?',
      aliases: ['alfândega', 'aduana', 'mudança internacional', 'bagagem'],
    ),
    QuickGuideQuestion(
      id: 'arrival.utilities',
      topic: 'arrival',
      pt: 'Como ativo telefone, internet, água e energia?',
      es: '¿Cómo activo teléfono, internet, agua y energía?',
      en: 'How do I activate phone, internet, water, and electricity?',
      aliases: ['chip', 'sim', 'conta de luz', 'comprovante endereço'],
    ),
    QuickGuideQuestion(
      id: 'rights.protection',
      topic: 'rights',
      pt: 'Onde encontro proteção ou assistência jurídica e social?',
      es: '¿Dónde encuentro protección o asistencia jurídica y social?',
      en: 'Where can I find protection or legal and social assistance?',
      aliases: ['xenofobia', 'violência', 'defensoria', 'assistência social'],
    ),
    QuickGuideQuestion(
      id: 'rights.consumer',
      topic: 'rights',
      pt: 'Como faço uma reclamação contra uma empresa?',
      es: '¿Cómo hago un reclamo contra una empresa?',
      en: 'How do I file a complaint against a company?',
      aliases: ['procon', 'consumidor.gov', 'cobrança indevida', 'ouvidoria'],
    ),
    QuickGuideQuestion(
      id: 'rights.pension',
      topic: 'rights',
      pt: 'Como funciona a previdência entre Brasil e Argentina?',
      es: '¿Cómo funciona la previsión entre Brasil y Argentina?',
      en: 'How does social security work between Brazil and Argentina?',
      aliases: ['aposentadoria', 'jubilación', 'inss', 'acordo previdenciário'],
    ),
    QuickGuideQuestion(
      id: 'rights.naturalization',
      topic: 'rights',
      pt: 'Como funciona a naturalização brasileira?',
      es: '¿Cómo funciona la naturalización brasileña?',
      en: 'How does Brazilian naturalization work?',
      aliases: ['cidadania', 'nacionalidade', 'ciudadanía'],
    ),
    QuickGuideQuestion(
      id: 'arrival.driving',
      topic: 'arrival',
      pt: 'Posso dirigir com habilitação estrangeira ou trocar pela CNH?',
      es: '¿Puedo conducir con licencia extranjera o cambiarla por la CNH?',
      en: 'Can I drive with a foreign licence or exchange it for a CNH?',
      aliases: ['carteira motorista', 'licencia argentina', 'detran'],
    ),
    QuickGuideQuestion(
      id: 'arrival.flight',
      topic: 'arrival',
      pt: 'O que confiro antes de comprar um voo para o Brasil?',
      es: '¿Qué reviso antes de comprar un vuelo a Brasil?',
      en: 'What should I check before buying a flight to Brazil?',
      aliases: ['passagem aérea', 'aeroporto', 'bagagem voo', 'pasaje'],
    ),
  ];

  static List<QuickGuideQuestion> search(
    String query, {
    required String languageCode,
    int limit = 5,
  }) {
    final normalizedQuery = _normalize(query);
    final queryTokens = _tokens(normalizedQuery);
    if (normalizedQuery.length < 2 || queryTokens.isEmpty) return const [];

    final ranked = <({QuickGuideQuestion question, double score})>[];
    for (final question in questions) {
      final localized = _normalize(question.questionFor(languageCode));
      final candidates = <String>{
        localized,
        _normalize(question.pt),
        _normalize(question.es),
        _normalize(question.en),
        ...question.aliases.map(_normalize),
      };
      candidates.add(candidates.join(' '));
      var bestScore = 0.0;
      for (final candidate in candidates) {
        final candidateTokens = _tokens(candidate);
        var score = candidate == normalizedQuery
            ? 100.0
            : candidate.contains(normalizedQuery)
            ? 30.0 + normalizedQuery.length * 0.15
            : 0.0;
        var matchedTokens = 0;
        for (final token in queryTokens) {
          var tokenScore = 0.0;
          for (final candidateToken in candidateTokens) {
            if (candidateToken == token) {
              tokenScore = 8;
              break;
            }
            if (candidateToken.startsWith(token) ||
                token.startsWith(candidateToken)) {
              tokenScore = tokenScore < 5 ? 5 : tokenScore;
              continue;
            }
            final tolerance = token.length >= 7 ? 2 : 1;
            if (token.length >= 4 &&
                candidateToken.length >= 4 &&
                _editDistance(token, candidateToken) <= tolerance) {
              tokenScore = tokenScore < 3 ? 3 : tokenScore;
            }
          }
          if (tokenScore > 0) matchedTokens += 1;
          score += tokenScore;
        }
        final coverage = matchedTokens / queryTokens.length;
        score += coverage * 12;
        if (coverage < 0.34) score *= 0.45;
        if (score > bestScore) bestScore = score;
      }
      if (bestScore >= 8) ranked.add((question: question, score: bestScore));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.question
          .questionFor(languageCode)
          .compareTo(b.question.questionFor(languageCode));
    });
    return ranked
        .take(limit)
        .map((item) => item.question)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    var normalized = value.toLowerCase();
    replacements.forEach(
      (character, replacement) =>
          normalized = normalized.replaceAll(character, replacement),
    );
    return normalized
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> _tokens(String value) {
    const stopWords = {
      'a',
      'as',
      'como',
      'da',
      'de',
      'do',
      'e',
      'em',
      'eu',
      'faco',
      'fazer',
      'faz',
      'fazendo',
      'tenho',
      'nao',
      'mas',
      'meu',
      'na',
      'no',
      'o',
      'os',
      'para',
      'por',
      'quero',
      'que',
      'el',
      'la',
      'los',
      'las',
      'mi',
      'quiero',
      'tengo',
      'pero',
      'un',
      'una',
      'y',
      'how',
      'what',
      'the',
      'to',
      'i',
      'my',
      'want',
      'have',
      'but',
      'in',
      'for',
    };
    return value
        .split(' ')
        .where((token) => token.length > 1 && !stopWords.contains(token))
        .toList(growable: false);
  }

  static int _editDistance(String left, String right) {
    if (left == right) return 0;
    if (left.isEmpty) return right.length;
    if (right.isEmpty) return left.length;
    var previous = List<int>.generate(right.length + 1, (index) => index);
    for (var row = 1; row <= left.length; row += 1) {
      final current = List<int>.filled(right.length + 1, 0)..[0] = row;
      for (var column = 1; column <= right.length; column += 1) {
        final substitutionCost =
            left.codeUnitAt(row - 1) == right.codeUnitAt(column - 1) ? 0 : 1;
        current[column] = _min3(
          current[column - 1] + 1,
          previous[column] + 1,
          previous[column - 1] + substitutionCost,
        );
      }
      previous = current;
    }
    return previous[right.length];
  }

  static int _min3(int first, int second, int third) {
    final firstPair = first < second ? first : second;
    return firstPair < third ? firstPair : third;
  }
}

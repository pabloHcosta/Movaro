enum ProposalKind { housing, job, publicService }

enum ProposalSafetyLevel { noStrongSignal, caution, stopAndVerify }

enum ProposalSafetySignalCode {
  advancePayment,
  pressure,
  credentialRequest,
  personalDataRequest,
  housingWithoutVerification,
  housingBelowMarket,
  jobFee,
  jobEasyMoney,
  unofficialPublicChannel,
}

class ProposalSafetySignal {
  const ProposalSafetySignal({
    required this.code,
    required this.weight,
    this.critical = false,
  });

  final ProposalSafetySignalCode code;
  final int weight;
  final bool critical;
}

class ProposalSafetyAnalysis {
  const ProposalSafetyAnalysis({
    required this.kind,
    required this.level,
    required this.signals,
  });

  final ProposalKind kind;
  final ProposalSafetyLevel level;
  final List<ProposalSafetySignal> signals;
}

class ProposalSafetyAnalyzer {
  const ProposalSafetyAnalyzer._();

  static ProposalSafetyAnalysis analyze({
    required ProposalKind kind,
    required String content,
  }) {
    final normalized = _normalize(content);
    final signals = <ProposalSafetySignal>[];

    void addIf(
      bool matches,
      ProposalSafetySignalCode code, {
      required int weight,
      bool critical = false,
    }) {
      if (matches && !signals.any((signal) => signal.code == code)) {
        signals.add(
          ProposalSafetySignal(code: code, weight: weight, critical: critical),
        );
      }
    }

    addIf(
      _containsAny(normalized, const [
        'pix antecipado',
        'deposito antecipado',
        'transferencia antecipada',
        'pague antes',
        'pagar antes',
        'send payment first',
        'pay before',
        'advance payment',
        'payment in advance',
        'pix in advance',
        'send a pix',
        'pago por adelantado',
        'transferencia por adelantado',
        'reserva por pix',
        'sinal agora',
      ]),
      ProposalSafetySignalCode.advancePayment,
      weight: 3,
      critical: true,
    );
    addIf(
      _containsAny(normalized, const [
        'pague agora',
        'so hoje',
        'ultima chance',
        'decida agora',
        'urgente',
        'imediatamente',
        'agora ou perde',
        'pay now',
        'today only',
        'last chance',
        'act now',
        'decide now',
        'or lose',
        'paga ahora',
        'solo hoy',
        'ultima oportunidad',
      ]),
      ProposalSafetySignalCode.pressure,
      weight: 1,
    );
    addIf(
      _containsAny(normalized, const [
        'senha gov.br',
        'senha do gov.br',
        'codigo de verificacao',
        'codigo recebido por sms',
        'token bancario',
        'codigo do whatsapp',
        'verification code',
        'sms code',
        'bank token',
        'contrasena gov.br',
        'codigo de verificacion',
      ]),
      ProposalSafetySignalCode.credentialRequest,
      weight: 4,
      critical: true,
    );
    addIf(
      _containsAny(normalized, const [
        'foto do cartao',
        'dados bancarios',
        'numero do cartao',
        'selfie com documento',
        'bank details',
        'card number',
        'selfie with your document',
        'datos bancarios',
        'numero de tarjeta',
        'selfie con documento',
      ]),
      ProposalSafetySignalCode.personalDataRequest,
      weight: 2,
    );

    switch (kind) {
      case ProposalKind.housing:
        addIf(
          _containsAny(normalized, const [
            'sem visita',
            'nao pode visitar',
            'nao precisa de contrato',
            'chaves depois do pagamento',
            'proprietario esta no exterior',
            'sem videochamada',
            'without a visit',
            'no viewing',
            'keys after payment',
            'owner is abroad',
            'sin visita',
            'llaves despues del pago',
            'propietario esta en el exterior',
          ]),
          ProposalSafetySignalCode.housingWithoutVerification,
          weight: 3,
          critical: true,
        );
        addIf(
          _containsAny(normalized, const [
            'muito abaixo do mercado',
            'abaixo do mercado',
            'metade do preco',
            'too good to be true',
            'below market',
            'half price',
            'muy por debajo del mercado',
            'mitad de precio',
          ]),
          ProposalSafetySignalCode.housingBelowMarket,
          weight: 2,
        );
        break;
      case ProposalKind.job:
        addIf(
          _containsAny(normalized, const [
            'taxa de inscricao',
            'taxa para comecar',
            'pague o curso',
            'compre o kit',
            'pague o treinamento',
            'fee to apply',
            'pay for training',
            'buy the kit',
            'application fee',
            'tasa de inscripcion',
            'paga el curso',
            'compra el kit',
          ]),
          ProposalSafetySignalCode.jobFee,
          weight: 4,
          critical: true,
        );
        addIf(
          _containsAny(normalized, const [
            'dinheiro facil',
            'ganho garantido',
            'renda garantida',
            'tarefas simples',
            'curtir videos',
            'avaliar produtos',
            'easy money',
            'guaranteed income',
            'simple tasks',
            'like videos',
            'dinero facil',
            'ingreso garantizado',
            'tareas simples',
          ]),
          ProposalSafetySignalCode.jobEasyMoney,
          weight: 2,
        );
        break;
      case ProposalKind.publicService:
        final mentionsGovernment = _containsAny(normalized, const [
          'gov.br',
          'receita federal',
          'policia federal',
          'detran',
          'cpf',
          'rnm',
          'crnm',
          'sus',
        ]);
        final asksInformalPayment = _containsAny(normalized, const [
          'pix',
          'qr code',
          'link de pagamento',
          'whatsapp',
          'taxa administrativa',
          'payment link',
          'administrative fee',
          'enlace de pago',
          'tasa administrativa',
        ]);
        addIf(
          mentionsGovernment && asksInformalPayment,
          ProposalSafetySignalCode.unofficialPublicChannel,
          weight: 4,
          critical: true,
        );
        break;
    }

    final score = signals.fold<int>(
      0,
      (total, signal) => total + signal.weight,
    );
    final level = signals.any((signal) => signal.critical) || score >= 4
        ? ProposalSafetyLevel.stopAndVerify
        : score > 0
        ? ProposalSafetyLevel.caution
        : ProposalSafetyLevel.noStrongSignal;

    return ProposalSafetyAnalysis(
      kind: kind,
      level: level,
      signals: List.unmodifiable(signals),
    );
  }

  static bool _containsAny(String value, List<String> terms) {
    return terms.any(value.contains);
  }

  static String _normalize(String value) {
    const replacements = <String, String>{
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
    replacements.forEach((source, target) {
      normalized = normalized.replaceAll(source, target);
    });
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

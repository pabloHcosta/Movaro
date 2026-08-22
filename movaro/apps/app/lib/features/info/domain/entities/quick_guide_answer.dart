enum QuickGuideCoverage {
  confirmed,
  conditional,
  needsContext,
  partial,
  notCovered,
}

enum QuickGuideClaimStatus { verified, conditional, unsupported }

enum QuickGuideFreshness { current, expired, notAvailable }

class QuickGuideSource {
  const QuickGuideSource({
    required this.title,
    required this.publisher,
    required this.url,
    required this.checkedAt,
    this.id = '',
    this.validUntil,
    this.scope = '',
    this.jurisdiction = '',
  });

  final String id;
  final String title;
  final String publisher;
  final String url;
  final String checkedAt;
  final String? validUntil;
  final String scope;
  final String jurisdiction;

  factory QuickGuideSource.fromJson(Map<String, dynamic> json) {
    return QuickGuideSource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      url: json['url'] as String? ?? '',
      checkedAt: json['checkedAt'] as String? ?? '',
      validUntil: json['validUntil'] as String?,
      scope: json['scope'] as String? ?? '',
      jurisdiction: json['jurisdiction'] as String? ?? '',
    );
  }
}

class QuickGuideClaim {
  const QuickGuideClaim({
    required this.id,
    required this.text,
    required this.evidenceIds,
    required this.status,
  });

  final String id;
  final String text;
  final List<String> evidenceIds;
  final QuickGuideClaimStatus status;

  factory QuickGuideClaim.fromJson(Map<String, dynamic> json) {
    return QuickGuideClaim(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      evidenceIds: (json['evidenceIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      status: switch (json['status']) {
        'verified' => QuickGuideClaimStatus.verified,
        'conditional' => QuickGuideClaimStatus.conditional,
        _ => QuickGuideClaimStatus.unsupported,
      },
    );
  }
}

class QuickGuideTrust {
  const QuickGuideTrust({
    required this.reason,
    required this.evidenceCoverage,
    required this.freshness,
  });

  final String reason;
  final double evidenceCoverage;
  final QuickGuideFreshness freshness;

  factory QuickGuideTrust.fromJson(Map<String, dynamic> json) {
    return QuickGuideTrust(
      reason: json['reason'] as String? ?? '',
      evidenceCoverage: (json['evidenceCoverage'] as num?)?.toDouble() ?? 0,
      freshness: switch (json['freshness']) {
        'current' => QuickGuideFreshness.current,
        'expired' => QuickGuideFreshness.expired,
        _ => QuickGuideFreshness.notAvailable,
      },
    );
  }
}

class QuickGuideSection {
  const QuickGuideSection({
    required this.intentId,
    required this.topic,
    required this.title,
    required this.answer,
    required this.coverage,
    required this.claimIds,
  });

  final String intentId;
  final String topic;
  final String title;
  final String answer;
  final QuickGuideCoverage coverage;
  final List<String> claimIds;

  factory QuickGuideSection.fromJson(Map<String, dynamic> json) {
    return QuickGuideSection(
      intentId: json['intentId'] as String? ?? '',
      topic: json['topic'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      coverage: QuickGuideAnswer.parseCoverage(json['coverage']),
      claimIds: (json['claimIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class QuickGuideStep {
  const QuickGuideStep({required this.id, required this.label});

  final String id;
  final String label;

  factory QuickGuideStep.fromJson(Map<String, dynamic> json) {
    return QuickGuideStep(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class QuickGuideFollowUpOption {
  const QuickGuideFollowUpOption({required this.value, required this.label});

  final String value;
  final String label;

  factory QuickGuideFollowUpOption.fromJson(Map<String, dynamic> json) {
    return QuickGuideFollowUpOption(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class QuickGuideFollowUpQuestion {
  const QuickGuideFollowUpQuestion({
    required this.id,
    required this.contextKey,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String contextKey;
  final String prompt;
  final List<QuickGuideFollowUpOption> options;

  factory QuickGuideFollowUpQuestion.fromJson(Map<String, dynamic> json) {
    return QuickGuideFollowUpQuestion(
      id: json['id'] as String? ?? '',
      contextKey: json['contextKey'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideFollowUpOption.fromJson)
          .where((option) => option.value.isNotEmpty && option.label.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class QuickGuideAction {
  const QuickGuideAction({
    required this.type,
    required this.target,
    required this.label,
  });

  final String type;
  final String target;
  final String label;

  factory QuickGuideAction.fromJson(Map<String, dynamic> json) {
    return QuickGuideAction(
      type: json['type'] as String? ?? '',
      target: json['target'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class QuickGuideContext {
  const QuickGuideContext({
    required this.originCountry,
    required this.destinationCountry,
    this.cityId,
  });

  final String originCountry;
  final String destinationCountry;
  final String? cityId;

  factory QuickGuideContext.fromJson(Map<String, dynamic> json) {
    return QuickGuideContext(
      originCountry: json['originCountry'] as String? ?? '',
      destinationCountry: json['destinationCountry'] as String? ?? '',
      cityId: json['cityId'] as String?,
    );
  }
}

class QuickGuideRecoverySuggestion {
  const QuickGuideRecoverySuggestion({
    required this.id,
    required this.topic,
    required this.question,
  });

  final String id;
  final String topic;
  final String question;

  factory QuickGuideRecoverySuggestion.fromJson(Map<String, dynamic> json) {
    return QuickGuideRecoverySuggestion(
      id: json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? 'general',
      question: json['question'] as String? ?? '',
    );
  }
}

class QuickGuideRecovery {
  const QuickGuideRecovery({
    required this.reason,
    required this.message,
    required this.suggestions,
  });

  final String reason;
  final String message;
  final List<QuickGuideRecoverySuggestion> suggestions;

  factory QuickGuideRecovery.fromJson(Map<String, dynamic> json) {
    return QuickGuideRecovery(
      reason: json['reason'] as String? ?? '',
      message: json['message'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideRecoverySuggestion.fromJson)
          .where((item) => item.id.isNotEmpty && item.question.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class QuickGuideAnswer {
  const QuickGuideAnswer({
    required this.entryId,
    required this.topic,
    required this.question,
    required this.answer,
    required this.coverage,
    required this.context,
    required this.actions,
    required this.caveats,
    required this.sources,
    this.resolutionId = '',
    this.coverageReason = '',
    this.claims = const [],
    this.resolvedIntents = const [],
    this.sections = const [],
    this.steps = const [],
    this.nextSteps = const [],
    this.fallbackPath = const [],
    this.decisionTitle,
    this.followUpQuestion,
    this.contextMissing = const [],
    this.trust = const QuickGuideTrust(
      reason: '',
      evidenceCoverage: 0,
      freshness: QuickGuideFreshness.notAvailable,
    ),
    this.reviewedAt,
    this.expiresAt,
    this.editorialOwner,
    this.contentVersion,
    this.answerMode = 'direct',
    this.riskLevel = 'low',
    this.jurisdiction,
    this.offline = false,
    this.recovery,
  });

  final String resolutionId;
  final String entryId;
  final String topic;
  final String question;
  final String answer;
  final String answerMode;
  final String riskLevel;
  final String? jurisdiction;
  final QuickGuideCoverage coverage;
  final String coverageReason;
  final QuickGuideContext context;
  final List<String> contextMissing;
  final List<String> resolvedIntents;
  final List<QuickGuideSection> sections;
  final List<QuickGuideClaim> claims;
  final List<QuickGuideStep> steps;
  final List<String> nextSteps;
  final List<String> fallbackPath;
  final String? decisionTitle;
  final QuickGuideFollowUpQuestion? followUpQuestion;
  final List<QuickGuideAction> actions;
  final List<String> caveats;
  final List<QuickGuideSource> sources;
  final QuickGuideTrust trust;
  final String? reviewedAt;
  final String? expiresAt;
  final String? editorialOwner;
  final String? contentVersion;
  final bool offline;
  final QuickGuideRecovery? recovery;

  String get feedbackKey => resolutionId.isEmpty ? entryId : resolutionId;

  bool get hasCurrentEvidence =>
      (coverage == QuickGuideCoverage.confirmed ||
          coverage == QuickGuideCoverage.conditional ||
          coverage == QuickGuideCoverage.needsContext) &&
      trust.freshness == QuickGuideFreshness.current &&
      claims.isNotEmpty;

  factory QuickGuideAnswer.fromJson(Map<String, dynamic> json) {
    final evidenceJson = json['evidence'] ?? json['sources'];
    final trustJson = json['trust'];
    final contextJson = json['context'];
    final coverage = parseCoverage(json['coverage']);
    final coverageReason =
        json['coverageReason'] as String? ??
        (trustJson is Map<String, dynamic>
            ? trustJson['reason'] as String? ?? ''
            : '');
    return QuickGuideAnswer(
      resolutionId: json['resolutionId'] as String? ?? '',
      entryId: json['entryId'] as String? ?? '',
      topic: json['topic'] as String? ?? 'general',
      question: json['question'] as String? ?? '',
      answer:
          json['directAnswer'] as String? ?? json['answer'] as String? ?? '',
      answerMode: json['answerMode'] as String? ?? 'direct',
      riskLevel: json['riskLevel'] as String? ?? 'low',
      jurisdiction: json['jurisdiction'] as String?,
      coverage: coverage,
      coverageReason: coverageReason,
      reviewedAt: json['reviewedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      editorialOwner: json['editorialOwner'] as String?,
      contentVersion: json['contentVersion'] as String?,
      context: QuickGuideContext.fromJson(
        contextJson is Map<String, dynamic> ? contextJson : const {},
      ),
      contextMissing: (json['contextMissing'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      resolvedIntents: (json['resolvedIntents'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideSection.fromJson)
          .where((section) => section.answer.isNotEmpty)
          .toList(growable: false),
      claims: (json['claims'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideClaim.fromJson)
          .where((claim) => claim.text.isNotEmpty)
          .toList(growable: false),
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideStep.fromJson)
          .where((step) => step.label.isNotEmpty)
          .toList(growable: false),
      nextSteps: (json['nextSteps'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .where((step) => step.trim().isNotEmpty)
          .toList(growable: false),
      fallbackPath: (json['fallbackPath'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .where((step) => step.trim().isNotEmpty)
          .toList(growable: false),
      decisionTitle: json['decisionTitle'] as String?,
      followUpQuestion: switch (json['followUpQuestion']) {
        final Map<String, dynamic> value => QuickGuideFollowUpQuestion.fromJson(
          value,
        ),
        _ => null,
      },
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideAction.fromJson)
          .where((action) => action.label.isNotEmpty)
          .toList(growable: false),
      caveats: (json['caveats'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
      sources: (evidenceJson as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuickGuideSource.fromJson)
          .where((source) => source.url.isNotEmpty)
          .toList(growable: false),
      trust: QuickGuideTrust.fromJson(
        trustJson is Map<String, dynamic>
            ? trustJson
            : {
                'reason': coverageReason,
                'evidenceCoverage': 0,
                'freshness': 'not_available',
              },
      ),
      recovery: switch (json['recovery']) {
        final Map<String, dynamic> value => QuickGuideRecovery.fromJson(value),
        _ => null,
      },
    );
  }

  static QuickGuideCoverage parseCoverage(dynamic value) {
    return switch (value) {
      'confirmed' => QuickGuideCoverage.confirmed,
      'conditional' => QuickGuideCoverage.conditional,
      'needs_context' => QuickGuideCoverage.needsContext,
      'partial' => QuickGuideCoverage.partial,
      // Legacy responses never become fully confirmed without claim evidence.
      'reviewed' => QuickGuideCoverage.conditional,
      _ => QuickGuideCoverage.notCovered,
    };
  }
}

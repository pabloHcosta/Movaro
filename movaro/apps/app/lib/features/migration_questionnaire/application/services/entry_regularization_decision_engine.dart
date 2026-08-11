enum BrazilEntrySituation {
  notEntered,
  enteredWithProof,
  enteredWithoutProof,
  unsure,
}

enum BrazilEntryDocument { physicalDni, passport, neither }

enum BrazilStayIntent { visitOnly, liveInBrazil, unsure }

class EntryRegularizationProfile {
  const EntryRegularizationProfile({
    this.isArgentineNational,
    this.entrySituation,
    this.entryDocument,
    this.stayIntent,
    this.completedActionIds = const <String>{},
  });

  final bool? isArgentineNational;
  final BrazilEntrySituation? entrySituation;
  final BrazilEntryDocument? entryDocument;
  final BrazilStayIntent? stayIntent;
  final Set<String> completedActionIds;

  bool get isComplete =>
      isArgentineNational != null &&
      entrySituation != null &&
      entryDocument != null &&
      stayIntent != null;

  bool get canUseBilateralAgreement =>
      isArgentineNational == true &&
      stayIntent == BrazilStayIntent.liveInBrazil;

  List<String> get requiredActionIds {
    if (!isComplete) return const <String>[];
    return <String>[
      entryDocument == BrazilEntryDocument.neither
          ? 'resolve_travel_document'
          : 'check_travel_document',
      switch (entrySituation!) {
        BrazilEntrySituation.notEntered => 'plan_registered_entry',
        BrazilEntrySituation.enteredWithProof => 'store_entry_proof',
        BrazilEntrySituation.enteredWithoutProof => 'recover_entry_proof',
        BrazilEntrySituation.unsure => 'confirm_entry_status',
      },
      switch (stayIntent!) {
        BrazilStayIntent.visitOnly => 'confirm_visitor_rules',
        BrazilStayIntent.liveInBrazil when isArgentineNational == true =>
          'confirm_bilateral_route',
        BrazilStayIntent.liveInBrazil => 'find_residence_route',
        BrazilStayIntent.unsure => 'compare_stay_routes',
      },
    ];
  }

  bool get allActionsCompleted =>
      requiredActionIds.isNotEmpty &&
      requiredActionIds.every(completedActionIds.contains);

  EntryRegularizationProfile copyWith({
    bool? isArgentineNational,
    BrazilEntrySituation? entrySituation,
    BrazilEntryDocument? entryDocument,
    BrazilStayIntent? stayIntent,
    Set<String>? completedActionIds,
  }) {
    return EntryRegularizationProfile(
      isArgentineNational: isArgentineNational ?? this.isArgentineNational,
      entrySituation: entrySituation ?? this.entrySituation,
      entryDocument: entryDocument ?? this.entryDocument,
      stayIntent: stayIntent ?? this.stayIntent,
      completedActionIds: completedActionIds ?? this.completedActionIds,
    ).sanitized();
  }

  EntryRegularizationProfile sanitized() {
    return EntryRegularizationProfile(
      isArgentineNational: isArgentineNational,
      entrySituation: entrySituation,
      entryDocument: entryDocument,
      stayIntent: stayIntent,
      completedActionIds: completedActionIds.intersection(
        requiredActionIds.toSet(),
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (isArgentineNational != null) 'isArgentineNational': isArgentineNational,
    if (entrySituation != null) 'entrySituation': entrySituation!.name,
    if (entryDocument != null) 'entryDocument': entryDocument!.name,
    if (stayIntent != null) 'stayIntent': stayIntent!.name,
    'completedActionIds': completedActionIds.toList()..sort(),
  };

  factory EntryRegularizationProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EntryRegularizationProfile();
    T? enumValue<T extends Enum>(List<T> values, Object? raw) {
      if (raw is! String) return null;
      for (final value in values) {
        if (value.name == raw) return value;
      }
      return null;
    }

    return EntryRegularizationProfile(
      isArgentineNational: json['isArgentineNational'] as bool?,
      entrySituation: enumValue(
        BrazilEntrySituation.values,
        json['entrySituation'],
      ),
      entryDocument: enumValue(
        BrazilEntryDocument.values,
        json['entryDocument'],
      ),
      stayIntent: enumValue(BrazilStayIntent.values, json['stayIntent']),
      completedActionIds:
          (json['completedActionIds'] as List?)?.whereType<String>().toSet() ??
          const <String>{},
    ).sanitized();
  }
}

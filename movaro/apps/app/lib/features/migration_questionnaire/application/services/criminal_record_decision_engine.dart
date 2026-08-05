enum CriminalRecordAgeGroup { minor, adult }

enum CriminalRecordProtocolWindow {
  withinThirtyDays,
  oneToThreeMonths,
  moreThanThreeMonths,
  unknown,
}

enum CriminalRecordRoute { exempt, onlineOrInPerson, inPerson }

class CriminalRecordProfile {
  const CriminalRecordProfile({
    this.ageGroup,
    this.hasArgentineDni,
    this.livedOutsideArgentina,
    this.otherCountriesText = '',
    this.protocolWindow,
    this.completedOutcomeIds = const <String>{},
  });

  final CriminalRecordAgeGroup? ageGroup;
  final bool? hasArgentineDni;
  final bool? livedOutsideArgentina;
  final String otherCountriesText;
  final CriminalRecordProtocolWindow? protocolWindow;
  final Set<String> completedOutcomeIds;

  bool get isExempt => ageGroup == CriminalRecordAgeGroup.minor;

  bool get isComplete {
    if (ageGroup == null) return false;
    if (isExempt) return true;
    return hasArgentineDni != null &&
        livedOutsideArgentina != null &&
        (!livedOutsideArgentina! || otherCountries.isNotEmpty) &&
        protocolWindow != null;
  }

  CriminalRecordRoute? get route {
    if (!isComplete) return null;
    if (isExempt) return CriminalRecordRoute.exempt;
    return hasArgentineDni == true
        ? CriminalRecordRoute.onlineOrInPerson
        : CriminalRecordRoute.inPerson;
  }

  List<String> get otherCountries => otherCountriesText
      .split(RegExp(r'[,;\n]'))
      .map((country) => country.trim())
      .where((country) => country.isNotEmpty)
      .toSet()
      .toList(growable: false);

  List<CriminalRecordOutcome> get outcomes {
    if (!isComplete || isExempt) return const <CriminalRecordOutcome>[];
    return <CriminalRecordOutcome>[
      const CriminalRecordOutcome(
        id: 'argentina_requested',
        country: 'Argentina',
        kind: CriminalRecordOutcomeKind.requested,
      ),
      const CriminalRecordOutcome(
        id: 'argentina_received',
        country: 'Argentina',
        kind: CriminalRecordOutcomeKind.receivedAndVerified,
      ),
      for (final country in otherCountries) ...[
        CriminalRecordOutcome(
          id: '${_normalize(country)}_requested',
          country: country,
          kind: CriminalRecordOutcomeKind.requested,
        ),
        CriminalRecordOutcome(
          id: '${_normalize(country)}_received',
          country: country,
          kind: CriminalRecordOutcomeKind.receivedAndVerified,
        ),
      ],
      const CriminalRecordOutcome(
        id: 'pf_requirements_checked',
        country: 'Brasil',
        kind: CriminalRecordOutcomeKind.acceptanceChecked,
      ),
    ];
  }

  bool get allOutcomesCompleted =>
      outcomes.isNotEmpty &&
      outcomes.every((outcome) => completedOutcomeIds.contains(outcome.id));

  CriminalRecordProfile copyWith({
    Object? ageGroup = _noChange,
    Object? hasArgentineDni = _noChange,
    Object? livedOutsideArgentina = _noChange,
    String? otherCountriesText,
    Object? protocolWindow = _noChange,
    Set<String>? completedOutcomeIds,
  }) {
    return CriminalRecordProfile(
      ageGroup: identical(ageGroup, _noChange)
          ? this.ageGroup
          : ageGroup as CriminalRecordAgeGroup?,
      hasArgentineDni: identical(hasArgentineDni, _noChange)
          ? this.hasArgentineDni
          : hasArgentineDni as bool?,
      livedOutsideArgentina: identical(livedOutsideArgentina, _noChange)
          ? this.livedOutsideArgentina
          : livedOutsideArgentina as bool?,
      otherCountriesText: otherCountriesText ?? this.otherCountriesText,
      protocolWindow: identical(protocolWindow, _noChange)
          ? this.protocolWindow
          : protocolWindow as CriminalRecordProtocolWindow?,
      completedOutcomeIds: completedOutcomeIds ?? this.completedOutcomeIds,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ageGroup': ageGroup?.name,
    'hasArgentineDni': hasArgentineDni,
    'livedOutsideArgentina': livedOutsideArgentina,
    'otherCountriesText': otherCountriesText,
    'protocolWindow': protocolWindow?.name,
    'completedOutcomeIds': completedOutcomeIds.toList()..sort(),
  };

  factory CriminalRecordProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CriminalRecordProfile();
    return CriminalRecordProfile(
      ageGroup: _enumByName(CriminalRecordAgeGroup.values, json['ageGroup']),
      hasArgentineDni: json['hasArgentineDni'] as bool?,
      livedOutsideArgentina: json['livedOutsideArgentina'] as bool?,
      otherCountriesText: json['otherCountriesText'] as String? ?? '',
      protocolWindow: _enumByName(
        CriminalRecordProtocolWindow.values,
        json['protocolWindow'],
      ),
      completedOutcomeIds:
          (json['completedOutcomeIds'] as List?)?.whereType<String>().toSet() ??
          const <String>{},
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    return values.cast<T?>().firstWhere(
      (value) => value?.name == raw,
      orElse: () => null,
    );
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

enum CriminalRecordOutcomeKind {
  requested,
  receivedAndVerified,
  acceptanceChecked,
}

class CriminalRecordOutcome {
  const CriminalRecordOutcome({
    required this.id,
    required this.country,
    required this.kind,
  });

  final String id;
  final String country;
  final CriminalRecordOutcomeKind kind;
}

const Object _noChange = Object();

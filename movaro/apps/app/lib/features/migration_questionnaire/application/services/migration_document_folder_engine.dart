import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';

enum MigrationFolderAgeGroup { under18, adult }

class MigrationDocumentFolderProfile {
  const MigrationDocumentFolderProfile({
    this.ageGroup,
    this.identityShowsParentage,
    this.livedOutsideArgentina,
    this.isAlreadyInBrazil,
    this.protocolWindow,
    this.completedActionIds = const <String>{},
  });

  final MigrationFolderAgeGroup? ageGroup;
  final bool? identityShowsParentage;
  final bool? livedOutsideArgentina;
  final bool? isAlreadyInBrazil;
  final CriminalRecordProtocolWindow? protocolWindow;
  final Set<String> completedActionIds;

  bool get isAdult => ageGroup == MigrationFolderAgeGroup.adult;
  bool get needsCountryHistory => isAdult;

  bool get isComplete =>
      ageGroup != null &&
      identityShowsParentage != null &&
      (!needsCountryHistory || livedOutsideArgentina != null) &&
      isAlreadyInBrazil != null &&
      protocolWindow != null;

  List<String> get requiredActionIds {
    if (!isComplete) return const <String>[];
    return <String>[
      'folder_structure',
      'official_route',
      'identity_copy',
      if (identityShowsParentage == false) 'parentage_evidence',
      if (isAdult) 'criminal_records_map',
      if (isAdult && livedOutsideArgentina == true) 'other_countries_map',
      'formalities_review',
      'later_documents_slots',
    ];
  }

  bool get allActionsCompleted =>
      requiredActionIds.isNotEmpty &&
      requiredActionIds.every(completedActionIds.contains);

  MigrationDocumentFolderProfile copyWith({
    MigrationFolderAgeGroup? ageGroup,
    bool? identityShowsParentage,
    bool? livedOutsideArgentina,
    bool? isAlreadyInBrazil,
    CriminalRecordProtocolWindow? protocolWindow,
    Set<String>? completedActionIds,
  }) {
    final nextAgeGroup = ageGroup ?? this.ageGroup;
    return MigrationDocumentFolderProfile(
      ageGroup: nextAgeGroup,
      identityShowsParentage:
          identityShowsParentage ?? this.identityShowsParentage,
      livedOutsideArgentina: nextAgeGroup == MigrationFolderAgeGroup.under18
          ? null
          : livedOutsideArgentina ?? this.livedOutsideArgentina,
      isAlreadyInBrazil: isAlreadyInBrazil ?? this.isAlreadyInBrazil,
      protocolWindow: protocolWindow ?? this.protocolWindow,
      completedActionIds: completedActionIds ?? this.completedActionIds,
    ).sanitized();
  }

  MigrationDocumentFolderProfile sanitized() {
    final validIds = requiredActionIds.toSet();
    return MigrationDocumentFolderProfile(
      ageGroup: ageGroup,
      identityShowsParentage: identityShowsParentage,
      livedOutsideArgentina: needsCountryHistory ? livedOutsideArgentina : null,
      isAlreadyInBrazil: isAlreadyInBrazil,
      protocolWindow: protocolWindow,
      completedActionIds: completedActionIds.intersection(validIds),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (ageGroup != null) 'ageGroup': ageGroup!.name,
    if (identityShowsParentage != null)
      'identityShowsParentage': identityShowsParentage,
    if (livedOutsideArgentina != null)
      'livedOutsideArgentina': livedOutsideArgentina,
    if (isAlreadyInBrazil != null) 'isAlreadyInBrazil': isAlreadyInBrazil,
    if (protocolWindow != null) 'protocolWindow': protocolWindow!.name,
    'completedActionIds': completedActionIds.toList()..sort(),
  };

  factory MigrationDocumentFolderProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MigrationDocumentFolderProfile();
    T? enumValue<T extends Enum>(List<T> values, Object? raw) {
      if (raw is! String) return null;
      for (final value in values) {
        if (value.name == raw) return value;
      }
      return null;
    }

    return MigrationDocumentFolderProfile(
      ageGroup: enumValue(MigrationFolderAgeGroup.values, json['ageGroup']),
      identityShowsParentage: json['identityShowsParentage'] as bool?,
      livedOutsideArgentina: json['livedOutsideArgentina'] as bool?,
      isAlreadyInBrazil: json['isAlreadyInBrazil'] as bool?,
      protocolWindow: enumValue(
        CriminalRecordProtocolWindow.values,
        json['protocolWindow'],
      ),
      completedActionIds:
          (json['completedActionIds'] as List?)?.whereType<String>().toSet() ??
          const <String>{},
    ).sanitized();
  }
}

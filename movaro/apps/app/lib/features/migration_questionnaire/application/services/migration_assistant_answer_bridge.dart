import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/entry_regularization_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_folder_engine.dart';

class ReusedAssistantAnswers<T> {
  const ReusedAssistantAnswers({
    required this.profile,
    this.fieldIds = const <String>{},
  });

  final T profile;
  final Set<String> fieldIds;
}

class MigrationAssistantAnswerBridge {
  const MigrationAssistantAnswerBridge._();

  static const ageGroup = 'ageGroup';
  static const hasArgentineDni = 'hasArgentineDni';
  static const livedOutsideArgentina = 'livedOutsideArgentina';
  static const isAlreadyInBrazil = 'isAlreadyInBrazil';
  static const protocolWindow = 'protocolWindow';

  static ReusedAssistantAnswers<MigrationDocumentFolderProfile>
  resolveDocumentFolder({
    required MigrationDocumentFolderProfile stored,
    required EntryRegularizationProfile entry,
    required CriminalRecordProfile criminal,
  }) {
    final reused = <String>{};
    var age = stored.ageGroup;
    if (age == null && criminal.ageGroup != null) {
      age = criminal.ageGroup == CriminalRecordAgeGroup.minor
          ? MigrationFolderAgeGroup.under18
          : MigrationFolderAgeGroup.adult;
      reused.add(ageGroup);
    }

    var livedOutside = stored.livedOutsideArgentina;
    if (livedOutside == null &&
        age == MigrationFolderAgeGroup.adult &&
        criminal.livedOutsideArgentina != null) {
      livedOutside = criminal.livedOutsideArgentina;
      reused.add(livedOutsideArgentina);
    }

    var window = stored.protocolWindow;
    if (window == null && criminal.protocolWindow != null) {
      window = criminal.protocolWindow;
      reused.add(protocolWindow);
    }

    bool? isInBrazil;
    switch (entry.entrySituation) {
      case BrazilEntrySituation.notEntered:
        isInBrazil = false;
      case BrazilEntrySituation.enteredWithProof ||
          BrazilEntrySituation.enteredWithoutProof:
        isInBrazil = true;
      case BrazilEntrySituation.unsure || null:
        isInBrazil = stored.isAlreadyInBrazil;
    }
    if (entry.entrySituation != null &&
        entry.entrySituation != BrazilEntrySituation.unsure) {
      reused.add(isAlreadyInBrazil);
    }

    var completed = stored.completedActionIds;
    if (stored.isAlreadyInBrazil != null &&
        isInBrazil != stored.isAlreadyInBrazil) {
      completed = completed.difference(const {'later_documents_slots'});
    }

    final resolved = MigrationDocumentFolderProfile(
      ageGroup: age,
      identityShowsParentage: stored.identityShowsParentage,
      livedOutsideArgentina: age == MigrationFolderAgeGroup.under18
          ? null
          : livedOutside,
      isAlreadyInBrazil: isInBrazil,
      protocolWindow: window,
      completedActionIds: completed,
    ).sanitized();
    return ReusedAssistantAnswers(profile: resolved, fieldIds: reused);
  }

  static ReusedAssistantAnswers<CriminalRecordProfile> resolveCriminalRecord({
    required CriminalRecordProfile stored,
    required EntryRegularizationProfile entry,
    required MigrationDocumentFolderProfile folder,
  }) {
    final reused = <String>{};
    var age = stored.ageGroup;
    if (folder.ageGroup != null) {
      age = folder.ageGroup == MigrationFolderAgeGroup.under18
          ? CriminalRecordAgeGroup.minor
          : CriminalRecordAgeGroup.adult;
      reused.add(ageGroup);
    }

    var hasDni = stored.hasArgentineDni;
    if (entry.entryDocument == BrazilEntryDocument.physicalDni) {
      hasDni = true;
      reused.add(hasArgentineDni);
    }

    var livedOutside = stored.livedOutsideArgentina;
    if (folder.livedOutsideArgentina != null) {
      livedOutside = folder.livedOutsideArgentina;
      reused.add(livedOutsideArgentina);
    }

    var window = stored.protocolWindow;
    if (folder.protocolWindow != null) {
      window = folder.protocolWindow;
      reused.add(protocolWindow);
    }

    final structuralAnswerChanged =
        age != stored.ageGroup ||
        hasDni != stored.hasArgentineDni ||
        livedOutside != stored.livedOutsideArgentina ||
        window != stored.protocolWindow;
    return ReusedAssistantAnswers(
      profile: CriminalRecordProfile(
        ageGroup: age,
        hasArgentineDni: hasDni,
        livedOutsideArgentina: livedOutside,
        otherCountriesText: livedOutside == false
            ? ''
            : stored.otherCountriesText,
        protocolWindow: window,
        completedOutcomeIds: structuralAnswerChanged
            ? const <String>{}
            : stored.completedOutcomeIds,
      ),
      fieldIds: reused,
    );
  }
}

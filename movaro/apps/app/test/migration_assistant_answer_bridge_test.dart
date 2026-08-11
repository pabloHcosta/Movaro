import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/entry_regularization_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_assistant_answer_bridge.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_folder_engine.dart';

void main() {
  test('entry status is reused by the document-folder assistant', () {
    final entry = const EntryRegularizationProfile().copyWith(
      isArgentineNational: true,
      entrySituation: BrazilEntrySituation.enteredWithProof,
      entryDocument: BrazilEntryDocument.physicalDni,
      stayIntent: BrazilStayIntent.liveInBrazil,
    );

    final result = MigrationAssistantAnswerBridge.resolveDocumentFolder(
      stored: const MigrationDocumentFolderProfile(),
      entry: entry,
      criminal: const CriminalRecordProfile(),
    );

    expect(result.profile.isAlreadyInBrazil, isTrue);
    expect(
      result.fieldIds,
      contains(MigrationAssistantAnswerBridge.isAlreadyInBrazil),
    );
  });

  test('folder answers remove repeated criminal-record questions', () {
    final folder = const MigrationDocumentFolderProfile().copyWith(
      ageGroup: MigrationFolderAgeGroup.adult,
      identityShowsParentage: true,
      livedOutsideArgentina: false,
      isAlreadyInBrazil: false,
      protocolWindow: CriminalRecordProtocolWindow.oneToThreeMonths,
    );
    final entry = const EntryRegularizationProfile().copyWith(
      isArgentineNational: true,
      entrySituation: BrazilEntrySituation.notEntered,
      entryDocument: BrazilEntryDocument.physicalDni,
      stayIntent: BrazilStayIntent.liveInBrazil,
    );

    final result = MigrationAssistantAnswerBridge.resolveCriminalRecord(
      stored: const CriminalRecordProfile(),
      entry: entry,
      folder: folder,
    );

    expect(result.profile.ageGroup, CriminalRecordAgeGroup.adult);
    expect(result.profile.hasArgentineDni, isTrue);
    expect(result.profile.livedOutsideArgentina, isFalse);
    expect(
      result.profile.protocolWindow,
      CriminalRecordProtocolWindow.oneToThreeMonths,
    );
    expect(result.profile.isComplete, isTrue);
    expect(
      result.fieldIds,
      containsAll({
        MigrationAssistantAnswerBridge.ageGroup,
        MigrationAssistantAnswerBridge.hasArgentineDni,
        MigrationAssistantAnswerBridge.livedOutsideArgentina,
        MigrationAssistantAnswerBridge.protocolWindow,
      }),
    );
  });

  test('changing a shared answer invalidates completed criminal outcomes', () {
    final stored = CriminalRecordProfile(
      ageGroup: CriminalRecordAgeGroup.adult,
      hasArgentineDni: true,
      livedOutsideArgentina: false,
      protocolWindow: CriminalRecordProtocolWindow.withinThirtyDays,
      completedOutcomeIds: const {
        'argentina_requested',
        'argentina_received',
        'pf_requirements_checked',
      },
    );
    final folder = const MigrationDocumentFolderProfile().copyWith(
      ageGroup: MigrationFolderAgeGroup.under18,
      identityShowsParentage: true,
      isAlreadyInBrazil: true,
      protocolWindow: CriminalRecordProtocolWindow.withinThirtyDays,
    );

    final result = MigrationAssistantAnswerBridge.resolveCriminalRecord(
      stored: stored,
      entry: const EntryRegularizationProfile(),
      folder: folder,
    );

    expect(result.profile.isExempt, isTrue);
    expect(result.profile.completedOutcomeIds, isEmpty);
  });
}

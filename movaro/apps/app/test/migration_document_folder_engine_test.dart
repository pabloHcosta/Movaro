import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_folder_engine.dart';

void main() {
  test('minor receives a shorter folder without criminal records', () {
    final profile = const MigrationDocumentFolderProfile().copyWith(
      ageGroup: MigrationFolderAgeGroup.under18,
      identityShowsParentage: true,
      isAlreadyInBrazil: false,
      protocolWindow: CriminalRecordProtocolWindow.oneToThreeMonths,
    );

    expect(profile.isComplete, isTrue);
    expect(profile.requiredActionIds, isNot(contains('criminal_records_map')));
    expect(profile.requiredActionIds, isNot(contains('parentage_evidence')));
  });

  test(
    'adult missing parentage and with other countries gets both actions',
    () {
      final profile = const MigrationDocumentFolderProfile().copyWith(
        ageGroup: MigrationFolderAgeGroup.adult,
        identityShowsParentage: false,
        livedOutsideArgentina: true,
        isAlreadyInBrazil: true,
        protocolWindow: CriminalRecordProtocolWindow.withinThirtyDays,
      );

      expect(profile.isComplete, isTrue);
      expect(
        profile.requiredActionIds,
        containsAll({
          'parentage_evidence',
          'criminal_records_map',
          'other_countries_map',
        }),
      );
    },
  );

  test('changing answers removes completions that no longer apply', () {
    var profile = const MigrationDocumentFolderProfile().copyWith(
      ageGroup: MigrationFolderAgeGroup.adult,
      identityShowsParentage: false,
      livedOutsideArgentina: true,
      isAlreadyInBrazil: true,
      protocolWindow: CriminalRecordProtocolWindow.withinThirtyDays,
    );
    profile = profile.copyWith(
      completedActionIds: profile.requiredActionIds.toSet(),
    );

    profile = profile.copyWith(identityShowsParentage: true);

    expect(profile.completedActionIds, isNot(contains('parentage_evidence')));
    expect(profile.allActionsCompleted, isTrue);
    expect(
      MigrationDocumentFolderProfile.fromJson(profile.toJson()).toJson(),
      profile.toJson(),
    );
  });
}

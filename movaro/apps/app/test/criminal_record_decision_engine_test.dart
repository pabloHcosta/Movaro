import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/criminal_record_decision_engine.dart';

void main() {
  test('minor is exempt without collecting more information', () {
    const profile = CriminalRecordProfile(
      ageGroup: CriminalRecordAgeGroup.minor,
    );

    expect(profile.isComplete, isTrue);
    expect(profile.route, CriminalRecordRoute.exempt);
    expect(profile.outcomes, isEmpty);
  });

  test('adult without Argentine DNI receives the in-person route', () {
    const profile = CriminalRecordProfile(
      ageGroup: CriminalRecordAgeGroup.adult,
      hasArgentineDni: false,
      livedOutsideArgentina: false,
      protocolWindow: CriminalRecordProtocolWindow.withinThirtyDays,
    );

    expect(profile.isComplete, isTrue);
    expect(profile.route, CriminalRecordRoute.inPerson);
    expect(profile.outcomes, hasLength(3));
  });

  test('creates country-specific outcomes and survives persistence', () {
    const profile = CriminalRecordProfile(
      ageGroup: CriminalRecordAgeGroup.adult,
      hasArgentineDni: true,
      livedOutsideArgentina: true,
      otherCountriesText: 'Chile, Uruguai',
      protocolWindow: CriminalRecordProtocolWindow.oneToThreeMonths,
      completedOutcomeIds: {'argentina_requested'},
    );

    final restored = CriminalRecordProfile.fromJson(profile.toJson());

    expect(restored.route, CriminalRecordRoute.onlineOrInPerson);
    expect(restored.otherCountries, ['Chile', 'Uruguai']);
    expect(restored.outcomes, hasLength(7));
    expect(restored.completedOutcomeIds, contains('argentina_requested'));
  });
}

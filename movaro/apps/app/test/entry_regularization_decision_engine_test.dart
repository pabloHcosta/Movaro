import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/entry_regularization_decision_engine.dart';

void main() {
  test('Argentine resident intent receives the bilateral route', () {
    final profile = const EntryRegularizationProfile().copyWith(
      isArgentineNational: true,
      entrySituation: BrazilEntrySituation.notEntered,
      entryDocument: BrazilEntryDocument.physicalDni,
      stayIntent: BrazilStayIntent.liveInBrazil,
    );

    expect(profile.isComplete, isTrue);
    expect(profile.canUseBilateralAgreement, isTrue);
    expect(profile.requiredActionIds, contains('confirm_bilateral_route'));
    expect(profile.requiredActionIds, contains('plan_registered_entry'));
  });

  test('residence route is not inferred from residence in Argentina', () {
    final profile = const EntryRegularizationProfile().copyWith(
      isArgentineNational: false,
      entrySituation: BrazilEntrySituation.enteredWithProof,
      entryDocument: BrazilEntryDocument.passport,
      stayIntent: BrazilStayIntent.liveInBrazil,
    );

    expect(profile.canUseBilateralAgreement, isFalse);
    expect(profile.requiredActionIds, contains('find_residence_route'));
    expect(
      profile.requiredActionIds,
      isNot(contains('confirm_bilateral_route')),
    );
  });

  test('changing an answer removes a completion from the previous route', () {
    var profile = const EntryRegularizationProfile().copyWith(
      isArgentineNational: true,
      entrySituation: BrazilEntrySituation.enteredWithProof,
      entryDocument: BrazilEntryDocument.physicalDni,
      stayIntent: BrazilStayIntent.liveInBrazil,
    );
    profile = profile.copyWith(
      completedActionIds: profile.requiredActionIds.toSet(),
    );

    profile = profile.copyWith(stayIntent: BrazilStayIntent.visitOnly);

    expect(
      profile.completedActionIds,
      isNot(contains('confirm_bilateral_route')),
    );
    expect(profile.requiredActionIds, contains('confirm_visitor_rules'));
    expect(
      EntryRegularizationProfile.fromJson(profile.toJson()).toJson(),
      profile.toJson(),
    );
  });
}

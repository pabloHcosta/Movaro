import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/housing_viability_assessment.dart';

void main() {
  test('incomplete information never produces a viable result', () {
    final result = HousingViabilityAssessor.assess(
      const HousingViabilityProfile(monthlyIncomeBrl: 7000),
    );

    expect(result.level, HousingViabilityLevel.incomplete);
    expect(result.actionKeys, contains('complete_profile'));
  });

  test('identifies access, cash and affordability obstacles', () {
    final result = HousingViabilityAssessor.assess(
      const HousingViabilityProfile(
        reviewedListings: 1,
        monthlyIncomeBrl: 6000,
        monthlyHousingCostBrl: 3000,
        upfrontRequiredBrl: 9000,
        upfrontAvailableBrl: 4000,
        incomeProofStatus: HousingRequirementStatus.pending,
        guaranteeStatus: HousingRequirementStatus.unavailable,
        hasTemporaryFallback: false,
        leaseStatus: HousingLeaseStatus.searching,
      ),
    );

    expect(result.level, HousingViabilityLevel.attention);
    expect(result.upfrontGapBrl, 5000);
    expect(result.housingIncomeRatio, 0.5);
    expect(
      const HousingViabilityProfile(
        reviewedListings: 1,
        monthlyIncomeBrl: 6000,
        monthlyHousingCostBrl: 3000,
        upfrontRequiredBrl: 9000,
        upfrontAvailableBrl: 4000,
        incomeProofStatus: HousingRequirementStatus.pending,
        guaranteeStatus: HousingRequirementStatus.unavailable,
        hasTemporaryFallback: false,
        leaseStatus: HousingLeaseStatus.searching,
      ).hasCompletedOutcome,
      isFalse,
    );
    expect(
      result.actionKeys,
      containsAll(<String>[
        'compare_three_listings',
        'adjust_housing_budget',
        'close_upfront_gap',
        'confirm_income_proof',
        'confirm_rental_guarantee',
        'prepare_temporary_fallback',
        'continue_verified_search',
      ]),
    );
  });

  test('returns viable only when observed access conditions are covered', () {
    final result = HousingViabilityAssessor.assess(
      const HousingViabilityProfile(
        reviewedListings: 3,
        monthlyIncomeBrl: 9000,
        monthlyHousingCostBrl: 2800,
        upfrontRequiredBrl: 7000,
        upfrontAvailableBrl: 9000,
        incomeProofStatus: HousingRequirementStatus.accepted,
        guaranteeStatus: HousingRequirementStatus.accepted,
        hasTemporaryFallback: true,
        leaseStatus: HousingLeaseStatus.signedWithKeys,
      ),
    );

    expect(result.level, HousingViabilityLevel.viable);
    expect(result.upfrontGapBrl, isNull);
    expect(result.actionKeys, isEmpty);
    expect(
      const HousingViabilityProfile(
        reviewedListings: 3,
        monthlyIncomeBrl: 9000,
        monthlyHousingCostBrl: 2800,
        upfrontRequiredBrl: 7000,
        upfrontAvailableBrl: 9000,
        incomeProofStatus: HousingRequirementStatus.accepted,
        guaranteeStatus: HousingRequirementStatus.accepted,
        hasTemporaryFallback: true,
        leaseStatus: HousingLeaseStatus.signedWithKeys,
      ).hasCompletedOutcome,
      isTrue,
    );
  });

  test('serialization rejects invalid persisted amounts and enum values', () {
    final profile = HousingViabilityProfile.fromJson(const {
      'reviewedListings': -2,
      'monthlyIncomeBrl': 0,
      'monthlyHousingCostBrl': 2500,
      'upfrontRequiredBrl': -1,
      'upfrontAvailableBrl': 0,
      'incomeProofStatus': 'other',
      'guaranteeStatus': 'accepted',
      'hasTemporaryFallback': 'yes',
      'leaseStatus': 'searching',
    });

    expect(profile.reviewedListings, 0);
    expect(profile.monthlyIncomeBrl, isNull);
    expect(profile.upfrontRequiredBrl, isNull);
    expect(profile.upfrontAvailableBrl, 0);
    expect(profile.incomeProofStatus, isNull);
    expect(profile.guaranteeStatus, HousingRequirementStatus.accepted);
    expect(profile.hasTemporaryFallback, isNull);
    expect(profile.leaseStatus, HousingLeaseStatus.searching);
  });
}

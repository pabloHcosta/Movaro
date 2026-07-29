import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/explore/application/services/pre_plan_budget_estimator.dart';

void main() {
  group('PrePlanBudgetEstimator', () {
    test('builds a city-neutral estimate from explicit inputs', () {
      const profile = PrePlanBudgetProfile(
        adults: 2,
        children: 1,
        temporaryStayDays: 10,
        plannedMonthlyRentBrl: 2400,
        includePublicTransit: true,
        includePrivateHealth: true,
        hasPet: true,
      );

      final estimate = PrePlanBudgetEstimator.build(profile);

      expect(
        estimate.officialFeesBrl,
        closeTo(PrePlanBudgetEstimator.residenceAndCrnmFeesBrl * 3, 0.01),
      );
      expect(estimate.housingReserveBrl, 10200);
      expect(estimate.temporaryStayBrl, greaterThan(0));
      expect(estimate.optionalServicesBrl, 1700);
      expect(
        estimate.recommendedTotalBrl,
        greaterThan(estimate.essentialTotalBrl),
      );
      expect(estimate.saferTotalBrl, greaterThan(estimate.recommendedTotalBrl));
    });

    test('optional services are excluded unless selected', () {
      final estimate = PrePlanBudgetEstimator.build(
        const PrePlanBudgetProfile(includePrivateHealth: false, hasPet: false),
      );

      expect(estimate.optionalServicesBrl, 0);
      expect(estimate.recommendedTotalBrl, estimate.essentialTotalBrl);
    });

    test('adds only user-provided private education costs', () {
      final publicEstimate = PrePlanBudgetEstimator.build(
        const PrePlanBudgetProfile(children: 2, includeHigherEducation: true),
      );
      final privateEstimate = PrePlanBudgetEstimator.build(
        const PrePlanBudgetProfile(
          children: 2,
          usePrivateSchool: true,
          privateSchoolMonthlyBrlPerChild: 1800,
          includeHigherEducation: true,
          usePrivateHigherEducation: true,
          privateHigherEducationMonthlyBrl: 1400,
        ),
      );

      expect(publicEstimate.educationMonthlyBrl, 0);
      expect(privateEstimate.educationMonthlyBrl, 5000);
      expect(
        privateEstimate.recommendedTotalBrl,
        privateEstimate.essentialTotalBrl +
            privateEstimate.optionalServicesBrl +
            5000,
      );
    });
  });
}

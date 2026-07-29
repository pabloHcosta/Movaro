import 'dart:math' as math;

import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum LandingBudgetScenario { lean, balanced, comfortable }

class LandingBudgetBreakdown {
  const LandingBudgetBreakdown({
    required this.monthlyBaseBrl,
    required this.setupBrl,
    required this.bufferBrl,
    required this.total30DaysBrl,
    required this.total90DaysBrl,
  });

  final int monthlyBaseBrl;
  final int setupBrl;
  final int bufferBrl;
  final int total30DaysBrl;
  final int total90DaysBrl;
}

class LandingBudgetScenarioEstimate {
  const LandingBudgetScenarioEstimate({
    required this.scenario,
    required this.titleKey,
    required this.descriptionKey,
    required this.breakdown,
  });

  final LandingBudgetScenario scenario;
  final String titleKey;
  final String descriptionKey;
  final LandingBudgetBreakdown breakdown;
}

class LandingBudgetEstimate {
  const LandingBudgetEstimate({
    required this.summaryKey,
    required this.cityContext,
    required this.scenarios,
  });

  final String summaryKey;
  final String? cityContext;
  final List<LandingBudgetScenarioEstimate> scenarios;
}

class LandingBudgetEstimator {
  const LandingBudgetEstimator._();

  static LandingBudgetEstimate build({
    required MigrationPlan plan,
    City? explicitPreviewCity,
  }) {
    // A recommended/leading city is still discovery data. Local costs may only
    // enter the executable plan after the user explicitly confirms the city.
    final confirmedCity = plan.isCityConfirmed ? plan.confirmedCity : null;
    final budgetCity = confirmedCity ?? explicitPreviewCity;
    final cityBudget = budgetCity?.budgetSnapshot;
    final householdFactor = _householdFactor(plan);
    final monthlyBase = _resolveMonthlyBase(plan, cityBudget, budgetCity);

    return LandingBudgetEstimate(
      summaryKey: _summaryKey(plan.timeline),
      cityContext: budgetCity?.name,
      scenarios: [
        _scenario(
          scenario: LandingBudgetScenario.lean,
          titleKey: 'landingBudgetLeanTitle',
          descriptionKey: 'landingBudgetLeanBody',
          monthlyBase: _resolveScenarioMonthlyBase(
            LandingBudgetScenario.lean,
            monthlyBase,
            cityBudget,
            householdFactor,
          ),
          setupBase: _resolveSetupBase(
            plan,
            _resolveScenarioMonthlyBase(
              LandingBudgetScenario.lean,
              monthlyBase,
              cityBudget,
              householdFactor,
            ),
            LandingBudgetScenario.lean,
          ),
          bufferBase: _resolveBufferBase(
            plan,
            _resolveScenarioMonthlyBase(
              LandingBudgetScenario.lean,
              monthlyBase,
              cityBudget,
              householdFactor,
            ),
            LandingBudgetScenario.lean,
          ),
        ),
        _scenario(
          scenario: LandingBudgetScenario.balanced,
          titleKey: 'landingBudgetBalancedTitle',
          descriptionKey: 'landingBudgetBalancedBody',
          monthlyBase: monthlyBase,
          setupBase: _resolveSetupBase(
            plan,
            monthlyBase,
            LandingBudgetScenario.balanced,
          ),
          bufferBase: _resolveBufferBase(
            plan,
            monthlyBase,
            LandingBudgetScenario.balanced,
          ),
        ),
        _scenario(
          scenario: LandingBudgetScenario.comfortable,
          titleKey: 'landingBudgetComfortableTitle',
          descriptionKey: 'landingBudgetComfortableBody',
          monthlyBase: _resolveScenarioMonthlyBase(
            LandingBudgetScenario.comfortable,
            monthlyBase,
            cityBudget,
            householdFactor,
          ),
          setupBase: _resolveSetupBase(
            plan,
            _resolveScenarioMonthlyBase(
              LandingBudgetScenario.comfortable,
              monthlyBase,
              cityBudget,
              householdFactor,
            ),
            LandingBudgetScenario.comfortable,
          ),
          bufferBase: _resolveBufferBase(
            plan,
            _resolveScenarioMonthlyBase(
              LandingBudgetScenario.comfortable,
              monthlyBase,
              cityBudget,
              householdFactor,
            ),
            LandingBudgetScenario.comfortable,
          ),
        ),
      ],
    );
  }

  static LandingBudgetScenarioEstimate _scenario({
    required LandingBudgetScenario scenario,
    required String titleKey,
    required String descriptionKey,
    required int monthlyBase,
    required int setupBase,
    required int bufferBase,
  }) {
    return LandingBudgetScenarioEstimate(
      scenario: scenario,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      breakdown: LandingBudgetBreakdown(
        monthlyBaseBrl: monthlyBase,
        setupBrl: setupBase,
        bufferBrl: bufferBase,
        total30DaysBrl: monthlyBase + setupBase + bufferBase,
        total90DaysBrl: (monthlyBase * 3) + setupBase + bufferBase,
      ),
    );
  }

  static int _resolveMonthlyBase(
    MigrationPlan plan,
    CityBudgetSnapshot? cityBudget,
    City? budgetCity,
  ) {
    if (cityBudget != null) {
      return (cityBudget.fairLivingTotal * _householdFactor(plan)).round();
    }

    final city = budgetCity;
    if (city == null) {
      return (3600 * _householdFactor(plan)).round();
    }

    final monthlyFromScores =
        2000 +
        ((100 - city.costOfLivingScore) * 18) +
        ((100 - city.rentScore) * 14);

    final regionalFactor = switch (city.regionName?.toLowerCase()) {
      'sudeste' => 1.08,
      'sul' => 1.02,
      'centro-oeste' => 1.01,
      'nordeste' => 0.93,
      'norte' => 0.95,
      _ => 1.0,
    };

    return (monthlyFromScores * regionalFactor * _householdFactor(plan))
        .round()
        .clamp(2400, 14000);
  }

  static double _householdFactor(MigrationPlan plan) {
    final children = plan.childrenCount ?? 0;
    final adults = switch (plan.travelGroup) {
      'partner' || 'family_kids' => 2,
      _ => 1,
    };
    return (adults + (children * 0.65)).clamp(1, 3.6);
  }

  static int _resolveScenarioMonthlyBase(
    LandingBudgetScenario scenario,
    int balancedMonthlyBase,
    CityBudgetSnapshot? cityBudget,
    double householdFactor,
  ) {
    if (cityBudget == null) {
      return switch (scenario) {
        LandingBudgetScenario.lean => (balancedMonthlyBase * 0.88).round(),
        LandingBudgetScenario.balanced => balancedMonthlyBase,
        LandingBudgetScenario.comfortable =>
          (balancedMonthlyBase * 1.12).round(),
      };
    }

    return switch (scenario) {
      LandingBudgetScenario.lean =>
        ((cityBudget.singlePersonExcludingRent +
                    (cityBudget.planningRentLow * 0.72)) *
                householdFactor)
            .round(),
      LandingBudgetScenario.balanced => cityBudget.fairLivingTotal,
      LandingBudgetScenario.comfortable =>
        ((cityBudget.singlePersonExcludingRent +
                    cityBudget.pricierRent +
                    (cityBudget.monthlyTransportPass * 0.35)) *
                householdFactor)
            .round(),
    };
  }

  static int _resolveSetupBase(
    MigrationPlan plan,
    int monthlyBase,
    LandingBudgetScenario scenario,
  ) {
    final timelineFactor = switch (plan.timeline) {
      'in_0_3m' => 1.0,
      'in_3_6m' => 0.9,
      'in_6_12m' => 0.82,
      'later' || 'undecided' => 0.72,
      _ => 1.0,
    };
    final goalFactor = switch (plan.goal) {
      'entrepreneur' => 1.08,
      'remote_work' => 0.96,
      'study' => 0.88,
      'retire' => 0.86,
      'beach_life' => 0.92,
      _ => 1.0,
    };
    final scenarioFactor = switch (scenario) {
      LandingBudgetScenario.lean => 0.45,
      LandingBudgetScenario.balanced => 0.72,
      LandingBudgetScenario.comfortable => 0.98,
    };

    final estimate = monthlyBase * scenarioFactor * timelineFactor * goalFactor;
    return estimate.round().clamp(900, 6500);
  }

  static int _resolveBufferBase(
    MigrationPlan plan,
    int monthlyBase,
    LandingBudgetScenario scenario,
  ) {
    final riskFactor = switch (plan.timeline) {
      'in_0_3m' => 0.55,
      'in_3_6m' => 0.42,
      'in_6_12m' => 0.34,
      'later' || 'undecided' => 0.26,
      _ => 0.72,
    };
    final languageFactor = switch (plan.goal) {
      'work' => 1.0,
      'entrepreneur' => 1.08,
      'study' => 0.72,
      'retire' => 0.7,
      'beach_life' => 0.76,
      _ => 0.82,
    };
    final scenarioFactor = switch (scenario) {
      LandingBudgetScenario.lean => 0.55,
      LandingBudgetScenario.balanced => 0.9,
      LandingBudgetScenario.comfortable => 1.25,
    };

    final estimate = monthlyBase * riskFactor * languageFactor * scenarioFactor;
    return math.max(500, estimate.round());
  }

  static String _summaryKey(String timeline) {
    switch (timeline) {
      case 'in_0_3m':
        return 'landingBudgetSummaryAsap';
      case 'in_3_6m':
        return 'landingBudgetSummarySixMonths';
      case 'in_6_12m':
        return 'landingBudgetSummaryTwelveMonths';
      case 'later':
      case 'undecided':
      default:
        return 'landingBudgetSummaryResearching';
    }
  }
}

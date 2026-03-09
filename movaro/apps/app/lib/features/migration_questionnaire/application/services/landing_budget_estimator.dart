import 'dart:math' as math;

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

  static LandingBudgetEstimate build({required MigrationPlan plan}) {
    final monthlyBase = _resolveMonthlyBase(plan);
    final setupBase = _resolveSetupBase(plan, monthlyBase);
    final bufferBase = _resolveBufferBase(plan, monthlyBase);

    return LandingBudgetEstimate(
      summaryKey: _summaryKey(plan.timeline),
      cityContext: plan.recommendedCity?.name,
      scenarios: [
        _scenario(
          scenario: LandingBudgetScenario.lean,
          titleKey: 'landingBudgetLeanTitle',
          descriptionKey: 'landingBudgetLeanBody',
          monthlyBase: (monthlyBase * 0.82).round(),
          setupBase: (setupBase * 0.78).round(),
          bufferBase: (bufferBase * 0.72).round(),
        ),
        _scenario(
          scenario: LandingBudgetScenario.balanced,
          titleKey: 'landingBudgetBalancedTitle',
          descriptionKey: 'landingBudgetBalancedBody',
          monthlyBase: monthlyBase,
          setupBase: setupBase,
          bufferBase: bufferBase,
        ),
        _scenario(
          scenario: LandingBudgetScenario.comfortable,
          titleKey: 'landingBudgetComfortableTitle',
          descriptionKey: 'landingBudgetComfortableBody',
          monthlyBase: (monthlyBase * 1.18).round(),
          setupBase: (setupBase * 1.22).round(),
          bufferBase: (bufferBase * 1.28).round(),
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

  static int _resolveMonthlyBase(MigrationPlan plan) {
    final city = plan.recommendedCity;
    if (city == null) {
      return 4200;
    }

    final monthlyFromScores =
        2300 +
        ((100 - city.costOfLivingScore) * 24) +
        ((100 - city.rentScore) * 18);

    final regionalFactor = switch (city.regionName?.toLowerCase()) {
      'sudeste' => 1.10,
      'sul' => 1.03,
      'centro-oeste' => 1.01,
      'nordeste' => 0.95,
      'norte' => 0.97,
      _ => 1.0,
    };

    return (monthlyFromScores * regionalFactor).round().clamp(2800, 6800);
  }

  static int _resolveSetupBase(MigrationPlan plan, int monthlyBase) {
    final city = plan.recommendedCity;
    final rentPressure = city == null ? 1.0 : (1.05 + ((100 - city.rentScore) / 250));
    final timelineFactor = switch (plan.timeline) {
      'asap' => 1.15,
      '6_months' => 1.0,
      '12_months' => 0.92,
      'researching' => 0.88,
      _ => 1.0,
    };
    final goalFactor = switch (plan.goal) {
      'entrepreneur' => 1.18,
      'remote_work' => 1.08,
      'study' => 0.96,
      'retire' => 1.02,
      'beach_life' => 1.07,
      _ => 1.0,
    };

    final estimate = monthlyBase * 1.35 * rentPressure * timelineFactor * goalFactor;
    return estimate.round().clamp(2500, 12000);
  }

  static int _resolveBufferBase(MigrationPlan plan, int monthlyBase) {
    final riskFactor = switch (plan.timeline) {
      'asap' => 0.95,
      '6_months' => 0.78,
      '12_months' => 0.65,
      'researching' => 0.58,
      _ => 0.72,
    };
    final languageFactor = switch (plan.goal) {
      'work' => 1.0,
      'entrepreneur' => 1.05,
      'study' => 0.82,
      'retire' => 0.9,
      'beach_life' => 0.92,
      _ => 0.88,
    };

    final estimate = monthlyBase * riskFactor * languageFactor;
    return math.max(1200, estimate.round());
  }

  static String _summaryKey(String timeline) {
    switch (timeline) {
      case 'asap':
        return 'landingBudgetSummaryAsap';
      case '6_months':
        return 'landingBudgetSummarySixMonths';
      case '12_months':
        return 'landingBudgetSummaryTwelveMonths';
      case 'researching':
      default:
        return 'landingBudgetSummaryResearching';
    }
  }
}

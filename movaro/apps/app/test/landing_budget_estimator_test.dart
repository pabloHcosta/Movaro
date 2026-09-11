import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/features/cities/domain/entities/city.dart';
import 'package:mudavi_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:mudavi_app/features/cities/domain/entities/city_scores.dart';
import 'package:mudavi_app/features/cities/domain/entities/city_source.dart';
import 'package:mudavi_app/features/cities/domain/entities/city_sources.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/landing_budget_estimator.dart';
import 'package:mudavi_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  test('applies the household factor to every city-backed scenario', () {
    final estimate = LandingBudgetEstimator.build(
      plan: const MigrationPlan(
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        goal: 'work',
        timeline: 'in_3_6m',
        travelGroup: 'family_kids',
        childrenCount: 1,
        steps: [],
        highlightedCity: _city,
        isCityConfirmed: true,
      ),
    );

    expect(estimate.householdAdults, 2);
    expect(estimate.householdChildren, 1);
    expect(estimate.householdFactor, 2.65);
    expect(estimate.usesCitySnapshot, isTrue);
    expect(
      estimate.scenarios
          .map((scenario) => scenario.breakdown.monthlyBaseBrl)
          .every((amount) => amount > _budget.fairLivingTotal),
      isTrue,
    );
    expect(
      estimate.scenarios
          .firstWhere(
            (scenario) => scenario.scenario == LandingBudgetScenario.balanced,
          )
          .breakdown
          .monthlyBaseBrl,
      (_budget.fairLivingTotal * 2.65).round(),
    );
  });
}

const _source = CitySource(
  id: 'fixture',
  title: 'Fixture',
  provider: 'Fixture',
  description: 'Fixture',
  isOfficial: false,
  url: null,
  sourceType: 'curated',
);

const _budget = CityBudgetSnapshot(
  cityLabel: 'Curitiba',
  singlePersonExcludingRent: 2000,
  oneBedroomOutsideCentre: 1500,
  oneBedroomCityCentre: 2100,
  averageMonthlyNetSalary: 4000,
  monthlyTransportPass: 250,
  utilities: 350,
  updatedAt: '2026-08-20',
  sourceLabel: 'Fixture',
  sourceUrl: 'https://example.com',
  sourceType: 'curated',
);

const _city = City(
  id: 'curitiba-pr',
  name: 'Curitiba',
  stateCode: 'PR',
  stateName: 'Paraná',
  countryCode: 'BR',
  ibgeCode: 4106902,
  latitude: -25.43,
  longitude: -49.27,
  population: 1770000,
  idhmScore: 0.823,
  idhmReferenceYear: 2010,
  costOfLivingScore: 70,
  rentScore: 68,
  safetyScore: 65,
  argentinaPopularityScore: 60,
  spanishSupportScore: 55,
  jobMarketScore: 75,
  unemploymentRate: 7,
  economicActivityScore: 78,
  topIndustries: ['Tecnologia'],
  mudaviScores: CityScores(
    economical: 70,
    popularForArgentinians: 60,
    languageAdaptation: 55,
    workOpportunity: 75,
    overall: 66,
  ),
  recommendationReasons: [],
  sources: CitySources(
    territorialIdentity: _source,
    population: _source,
    humanDevelopment: _source,
    curatedMetrics: _source,
    ranking: _source,
  ),
  updatedAt: '2026-08-20',
  regionName: 'Sul',
  budgetSnapshot: _budget,
);

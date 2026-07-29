import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/data/models/city_recommendation_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

class _RecordingCitiesRepository implements CitiesRepository {
  _RecordingCitiesRepository(this._cities);

  final List<City> _cities;
  CityRecommendationProfile? lastProfile;

  @override
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  ) async {
    lastProfile = profile;
    return CityRecommendationResult(
      recommendationId: 'recommendation-test-id',
      methodologyVersion: 'city-recommendation-v2.1.0',
      generatedAt: '2026-07-29T12:00:00.000Z',
      catalogSize: _cities.length,
      eligibleCityCount: 3,
      profileCompleteness: 0.91,
      dataCoverage: 0.78,
      appliedHardFilters: profile.constraints,
      unavailableDimensions: const ['climate_warmth'],
      warnings: const ['recommendation_warning_missing_dimensions'],
      recommendations: _cities
          .take(3)
          .indexed
          .map(
            (entry) => RecommendedCity(
              city: entry.$2,
              score: 0.88 - entry.$1 * 0.08,
              dimensions: {
                'affordability': 0.8 - entry.$1 * 0.05,
                'safety': 0.72,
              },
              reasons: const ['plan_reason_budget_fit', 'plan_reason_safety'],
              tradeoffs: const [],
              dataCoverage: 0.78,
              dataUpdatedAt: '2026-07-09',
              freshnessStatus: entry.$1 == 0 ? 'stale' : 'fresh',
              evidence: const [],
            ),
          )
          .toList(growable: false),
      sourceSummary: const [
        CityRecommendationEvidence(
          dimension: 'affordability',
          provider: 'IBGE',
          sourceType: 'official',
          updatedAt: '2026-07-09',
          freshnessStatus: 'fresh',
        ),
        CityRecommendationEvidence(
          dimension: 'transit_infra',
          provider: 'Ipea',
          sourceType: 'official',
          freshnessStatus: 'unknown',
        ),
      ],
      stabilityBand: 'robust',
      reliabilityBand: 'strong',
      scoreSeparationBand: 'clear',
      scenariosEvaluated: 14,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<City> cities;
  late Map<String, dynamic> firstCityJson;

  setUpAll(() async {
    final raw = await rootBundle.loadString(
      'assets/seed/snapshots/cities_br.json',
    );
    final decoded = jsonDecode(raw) as List<dynamic>;
    firstCityJson = decoded.first as Map<String, dynamic>;
    cities = decoded
        .map(
          (item) => CityModel.fromJson(item as Map<String, dynamic>).toEntity(),
        )
        .toList();
  });

  test('parses P2 evaluation metadata from the API contract', () {
    final result = CityRecommendationModel.fromJson(<String, dynamic>{
      'recommendationId': 'api-run-id',
      'methodologyVersion': 'city-recommendation-v2.1.0',
      'generatedAt': '2026-07-29T12:00:00.000Z',
      'catalogSize': 40,
      'eligibleCityCount': 12,
      'profileCompleteness': 0.8,
      'dataCoverage': 0.76,
      'appliedHardFilters': <String>[],
      'unavailableDimensions': <String>[],
      'warnings': <String>[],
      'evaluation': <String, dynamic>{
        'stabilityBand': 'robust',
        'reliabilityBand': 'strong',
        'scoreSeparationBand': 'clear',
        'scenariosEvaluated': 14,
      },
      'recommendations': <Map<String, dynamic>>[
        <String, dynamic>{
          'rank': 1,
          'city': firstCityJson,
          'score': 0.81,
          'dimensions': <String, dynamic>{'safety': 0.8},
          'reasons': <String>['plan_reason_safety'],
          'tradeoffs': <String>[],
          'dataCoverage': 0.76,
          'freshnessStatus': 'fresh',
          'evidence': <Map<String, dynamic>>[],
        },
      ],
      'sourceSummary': <Map<String, dynamic>>[],
    });

    expect(result.recommendationId, 'api-run-id');
    expect(result.stabilityBand, 'robust');
    expect(result.reliabilityBand, 'strong');
    expect(result.scoreSeparationBand, 'clear');
    expect(result.scenariosEvaluated, 14);
    expect(result.recommendations.single.rank, 1);
  });

  test('forwards every ranking signal to the authoritative API', () async {
    final repository = _RecordingCitiesRepository(cities);
    final generator = MigrationPlanGenerator(citiesRepository: repository);

    await generator.generate(
      variant: QuestionnaireVariant.strategic,
      answers: const [
        Answer(questionId: 'origin_country', values: ['argentina']),
        Answer(questionId: 'destination_country', values: ['brasil']),
        Answer(questionId: 'intent', values: ['study']),
        Answer(questionId: 'timeline', values: ['in_6_12m']),
        Answer(questionId: 'funding', values: ['savings']),
        Answer(questionId: 'work_arrangement', values: ['remote']),
        Answer(questionId: 'travel_group', values: ['family_kids']),
        Answer(questionId: 'travel_group_children_count', values: ['2']),
        Answer(questionId: 'available_capital', values: ['medium']),
        Answer(
          questionId: 'priorities',
          values: ['university', 'safety', 'low_cost'],
        ),
        Answer(
          questionId: 'constraints',
          values: ['need_transit', 'avoid_expensive'],
        ),
        Answer(
          questionId: 'support_needs',
          values: ['children_school', 'will_drive'],
        ),
        Answer(questionId: 'origin_latitude', values: ['-32.8895']),
        Answer(questionId: 'origin_longitude', values: ['-68.8458']),
      ],
    );

    final profile = repository.lastProfile!;
    expect(profile.destinationCountryCode, 'BR');
    expect(profile.intent, 'study');
    expect(profile.funding, 'savings');
    expect(profile.workArrangement, 'remote');
    expect(profile.travelGroup, 'family_kids');
    expect(profile.childrenCount, 2);
    expect(profile.availableCapital, 'medium');
    expect(profile.priorities, ['university', 'safety', 'low_cost']);
    expect(profile.constraints, ['need_transit', 'avoid_expensive']);
    expect(profile.supportNeeds, ['children_school', 'will_drive']);
    expect(profile.originLatitude, -32.8895);
    expect(profile.originLongitude, -68.8458);
  });

  test(
    'persists API ordering, dimensions and integrity metadata unchanged',
    () async {
      final repository = _RecordingCitiesRepository(cities);
      final generator = MigrationPlanGenerator(citiesRepository: repository);

      final plan = await generator.generate(
        variant: QuestionnaireVariant.lean,
        answers: const [
          Answer(questionId: 'origin_country', values: ['argentina']),
          Answer(questionId: 'destination_country', values: ['brasil']),
          Answer(questionId: 'intent', values: ['fresh_start']),
          Answer(questionId: 'timeline', values: ['just_exploring']),
          Answer(questionId: 'work_arrangement', values: ['remote']),
          Answer(questionId: 'priorities', values: ['balanced_unsure']),
        ],
      );

      expect(
        plan.candidateCities.map((city) => city.id),
        cities.take(3).map((city) => city.id),
      );
      expect(plan.candidateCityMatchScores[plan.highlightedCity!.id], 0.88);
      expect(plan.candidateCityDimensionScores[plan.highlightedCity!.id], {
        'affordability': 0.8,
        'safety': 0.72,
      });
      expect(plan.candidateCityReasons[plan.highlightedCity!.id], [
        'plan_reason_budget_fit',
        'plan_reason_safety',
      ]);
      expect(
        plan.recommendationMethodologyVersion,
        'city-recommendation-v2.1.0',
      );
      expect(plan.recommendationId, 'recommendation-test-id');
      expect(plan.recommendationGeneratedAt, '2026-07-29T12:00:00.000Z');
      expect(plan.recommendationDataCoverage, 0.78);
      expect(plan.recommendationFreshnessStatus, 'stale');
      expect(plan.recommendationWarnings, [
        'recommendation_warning_missing_dimensions',
      ]);
      expect(plan.recommendationSourceLabels, ['IBGE', 'Ipea']);
      expect(plan.recommendationStabilityBand, 'robust');
      expect(plan.recommendationReliabilityBand, 'strong');
      expect(plan.recommendationScoreSeparationBand, 'clear');
      expect(plan.recommendationScenariosEvaluated, 14);
      expect(plan.workArrangement, 'remote');

      final restored = MigrationPlanModel.fromJson(
        MigrationPlanModel.fromEntity(plan).toJson(),
      ).toEntity();
      expect(restored.recommendationId, 'recommendation-test-id');
      expect(restored.recommendationStabilityBand, 'robust');
      expect(restored.recommendationReliabilityBand, 'strong');
      expect(restored.recommendationScoreSeparationBand, 'clear');
      expect(restored.recommendationScenariosEvaluated, 14);
      expect(restored.workArrangement, 'remote');
    },
  );
}

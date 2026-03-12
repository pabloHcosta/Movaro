import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

void main() {
  group('MigrationPlanGenerator', () {
    final generator = MigrationPlanGenerator(
      citiesRepository: _FakeCitiesRepository(_cities),
    );

    test('maps unsure inputs to explorer with lower confidence', () async {
      final plan = await generator.generate(
        variant: QuestionnaireVariant.lean,
        answers: const [
          Answer(questionId: 'origin_country', values: ['argentina']),
          Answer(questionId: 'destination_country', values: ['brasil']),
          Answer(questionId: 'intent', values: ['explore_unsure']),
          Answer(questionId: 'timeline', values: ['just_exploring']),
          Answer(questionId: 'priorities', values: ['balanced_unsure']),
        ],
      );

      expect(plan.archetypeKey, 'explorer');
      expect(plan.confidence, lessThan(0.5));
      expect(plan.steps, hasLength(3));
      expect(
        plan.steps.first.description,
        'step_desc_choose_base_city_explore',
      );
    });

    test(
      'returns deterministic top city for remote worker preferences',
      () async {
        final plan = await generator.generate(
          variant: QuestionnaireVariant.lean,
          answers: const [
            Answer(questionId: 'origin_country', values: ['argentina']),
            Answer(questionId: 'destination_country', values: ['brasil']),
            Answer(questionId: 'intent', values: ['remote_income']),
            Answer(questionId: 'timeline', values: ['in_3_6m']),
            Answer(questionId: 'priorities', values: ['low_cost', 'safety']),
            Answer(
              questionId: 'constraints',
              values: ['prefer_south', 'need_transit'],
            ),
          ],
        );

        expect(plan.recommendedCity?.id, 'curitiba');
        expect(plan.candidateCities.take(3).map((city) => city.id), [
          'curitiba',
          'porto_alegre',
          'salvador',
        ]);
        expect(plan.cityRecommendationReasons, isNotEmpty);
      },
    );

    test(
      'urgent timeline always includes cpf and execution-oriented steps',
      () async {
        final plan = await generator.generate(
          variant: QuestionnaireVariant.lean,
          answers: const [
            Answer(questionId: 'origin_country', values: ['argentina']),
            Answer(questionId: 'destination_country', values: ['brasil']),
            Answer(questionId: 'intent', values: ['find_job_br']),
            Answer(questionId: 'timeline', values: ['in_0_3m']),
            Answer(
              questionId: 'priorities',
              values: ['job_opportunities', 'transit_infra'],
            ),
          ],
        );

        expect(plan.steps, hasLength(3));
        expect(
          plan.steps.first.description,
          'step_desc_choose_base_city_urgent',
        );
        expect(
          plan.steps.map((step) => step.title),
          contains('step_cpf_start'),
        );
      },
    );

    test(
      'strategic variant stores funding and refines the archetype',
      () async {
        final plan = await generator.generate(
          variant: QuestionnaireVariant.strategic,
          answers: const [
            Answer(questionId: 'origin_country', values: ['argentina']),
            Answer(questionId: 'destination_country', values: ['brasil']),
            Answer(questionId: 'intent', values: ['find_job_br']),
            Answer(questionId: 'funding', values: ['job_offer']),
            Answer(questionId: 'timeline', values: ['in_3_6m']),
            Answer(
              questionId: 'priorities',
              values: ['job_opportunities', 'safety'],
            ),
            Answer(questionId: 'constraints', values: ['need_big_city']),
          ],
        );

        expect(plan.variant, QuestionnaireVariant.strategic);
        expect(plan.funding, 'job_offer');
        expect(plan.archetypeKey, 'job_hunter_with_offer');
        expect(
          plan.steps.first.description,
          'step_desc_choose_base_city_offer',
        );
      },
    );
  });
}

class _FakeCitiesRepository implements CitiesRepository {
  const _FakeCitiesRepository(this.cities);

  final List<City> cities;

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async => cities;

  @override
  Future<City> getCityById(String id) async =>
      cities.firstWhere((city) => city.id == id);

  @override
  Future<CityHighlights> getHighlights() async {
    return CityHighlights(
      mostChosenByArgentinians: cities,
      easiestForSpanishSpeakers: cities,
      mostEconomical: cities,
      bestForWork: cities,
    );
  }

  @override
  Future<CityMethodology> getMethodology() async {
    return const CityMethodology(principles: [], formulas: {}, note: '');
  }

  @override
  Future<CityWeather> getCityWeather(String cityId) async {
    return const CityWeather(
      temperatureCelsius: 24,
      weatherCode: 1,
      isDay: true,
      windSpeedKmh: 11,
      fetchedAt: '2026-03-12T12:00:00Z',
    );
  }

  @override
  Future<List<City>> searchCities(String query) async => cities;
}

const _source = CitySource(
  id: 'source',
  title: 'Source',
  provider: 'Movaro',
  description: 'Mock source',
  isOfficial: true,
  url: null,
);

const _sources = CitySources(
  territorialIdentity: _source,
  population: _source,
  humanDevelopment: _source,
  curatedMetrics: _source,
  ranking: _source,
);

final _cities = <City>[
  City(
    id: 'curitiba',
    name: 'Curitiba',
    stateCode: 'PR',
    stateName: 'Parana',
    countryCode: 'BR',
    ibgeCode: 1,
    latitude: -25.43,
    longitude: -49.27,
    population: 1770000,
    idhmScore: 0.82,
    idhmReferenceYear: 2021,
    costOfLivingScore: 62,
    rentScore: 60,
    safetyScore: 78,
    argentinaPopularityScore: 58,
    spanishSupportScore: 54,
    jobMarketScore: 74,
    unemploymentRate: 6,
    economicActivityScore: 76,
    topIndustries: const ['Tecnologia', 'Servicos'],
    movaroScores: const CityScores(
      economical: 76,
      popularForArgentinians: 68,
      languageAdaptation: 72,
      workOpportunity: 82,
      overall: 84,
    ),
    recommendationReasons: const ['reason'],
    sources: _sources,
    updatedAt: '2026-03-12',
    regionName: 'Sul',
  ),
  City(
    id: 'porto_alegre',
    name: 'Porto Alegre',
    stateCode: 'RS',
    stateName: 'Rio Grande do Sul',
    countryCode: 'BR',
    ibgeCode: 2,
    latitude: -30.03,
    longitude: -51.23,
    population: 1330000,
    idhmScore: 0.81,
    idhmReferenceYear: 2021,
    costOfLivingScore: 60,
    rentScore: 58,
    safetyScore: 70,
    argentinaPopularityScore: 70,
    spanishSupportScore: 62,
    jobMarketScore: 69,
    unemploymentRate: 7,
    economicActivityScore: 71,
    topIndustries: const ['Servicos'],
    movaroScores: const CityScores(
      economical: 73,
      popularForArgentinians: 82,
      languageAdaptation: 74,
      workOpportunity: 75,
      overall: 79,
    ),
    recommendationReasons: const ['reason'],
    sources: _sources,
    updatedAt: '2026-03-12',
    regionName: 'Sul',
  ),
  City(
    id: 'salvador',
    name: 'Salvador',
    stateCode: 'BA',
    stateName: 'Bahia',
    countryCode: 'BR',
    ibgeCode: 3,
    latitude: -12.97,
    longitude: -38.50,
    population: 2410000,
    idhmScore: 0.76,
    idhmReferenceYear: 2021,
    costOfLivingScore: 56,
    rentScore: 55,
    safetyScore: 52,
    argentinaPopularityScore: 55,
    spanishSupportScore: 48,
    jobMarketScore: 63,
    unemploymentRate: 10,
    economicActivityScore: 67,
    topIndustries: const ['Turismo', 'Servicos'],
    movaroScores: const CityScores(
      economical: 69,
      popularForArgentinians: 58,
      languageAdaptation: 61,
      workOpportunity: 66,
      overall: 71,
    ),
    recommendationReasons: const ['reason'],
    sources: _sources,
    updatedAt: '2026-03-12',
    regionName: 'Nordeste',
  ),
];

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/core/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/core/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/question_repository_impl.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MigrationQuestionnaireController strategic flow', () {
    late Directory tempDirectory;
    late JourneyContextController journeyContextController;
    late MigrationQuestionnaireController controller;
    late _InMemoryQuestionnaireFlowDraftStore flowDraftStore;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'movaro_questionnaire_test',
      );
      final catalogRepository = CatalogRepositoryImpl(
        dataSource: SeedCatalogDataSource(),
      );
      journeyContextController = JourneyContextController(
        catalogRepository: catalogRepository,
        store: JourneyPreferencesStore(
          directoryProvider: () async => tempDirectory,
        ),
      );
      await journeyContextController.initialize();
      await journeyContextController.completeJourney(
        originCountryId: 'argentina',
        destinationCountryId: 'brasil',
      );
      flowDraftStore = _InMemoryQuestionnaireFlowDraftStore();

      controller = MigrationQuestionnaireController(
        questionRepository: QuestionRepositoryImpl(
          catalogRepository: catalogRepository,
          journeyContextController: journeyContextController,
        ),
        migrationPlanRepository: LocalMigrationPlanRepository(
          directoryProvider: () async => tempDirectory,
        ),
        planGenerator: MigrationPlanGenerator(
          citiesRepository: const _FakeCitiesRepository(),
        ),
        journeyContextController: journeyContextController,
        flowDraftStore: flowDraftStore,
      );

      await controller.initialize();
      controller.selectVariant(QuestionnaireVariant.strategic);
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('inserts travel group and keeps capital question conditional', () {
      expect(controller.activeQuestions.map((question) => question.id), [
        'origin_country',
        'timeline',
        'travel_group',
        'priorities',
        'constraints',
        'funding',
        'intent',
      ]);

      controller.selectAnswer('funding', 'savings');

      expect(controller.activeQuestions.map((question) => question.id), [
        'origin_country',
        'timeline',
        'travel_group',
        'priorities',
        'constraints',
        'funding',
        'available_capital',
        'intent',
      ]);

      controller.selectAnswer('funding', 'job_offer');

      expect(controller.activeQuestions.map((question) => question.id), [
        'origin_country',
        'timeline',
        'travel_group',
        'priorities',
        'constraints',
        'funding',
        'intent',
      ]);
    });

    test('family with kids requires children count before continuing',
        () async {
      expect(controller.currentQuestion?.id, 'origin_country');
      await controller.goNext();
      expect(controller.currentQuestion?.id, 'timeline');

      controller.selectAnswer('timeline', 'in_3_6m');
      await controller.goNext();
      expect(controller.currentQuestion?.id, 'travel_group');

      controller.selectAnswer('travel_group', 'family_kids');
      expect(controller.canGoNext, isFalse);

      controller.selectAnswer('travel_group_children_count', '3+');
      expect(controller.canGoNext, isTrue);

      controller.selectAnswer('travel_group', 'partner');
      expect(controller.answerFor('travel_group_children_count'), isNull);
    });
  });
}

class _InMemoryQuestionnaireFlowDraftStore
    extends QuestionnaireFlowDraftStore {
  _InMemoryQuestionnaireFlowDraftStore();

  QuestionnaireFlowDraftSnapshot? _snapshot;

  @override
  Future<QuestionnaireFlowDraftSnapshot?> read() async => _snapshot;

  @override
  Future<void> write({
    required List<Answer> answers,
    required int currentIndex,
    required String? selectedVariantId,
    required bool showRefinePrompt,
    required bool isRefineResolved,
    required bool includeConstraints,
  }) async {
    _snapshot = QuestionnaireFlowDraftSnapshot(
      answers: answers,
      currentIndex: currentIndex,
      selectedVariantId: selectedVariantId,
      showRefinePrompt: showRefinePrompt,
      isRefineResolved: isRefineResolved,
      includeConstraints: includeConstraints,
    );
  }

  @override
  Future<void> clear() async {
    _snapshot = null;
  }
}

const _testSource = CitySource(
  id: 'source',
  title: 'Source',
  provider: 'Movaro',
  description: 'Mock source',
  isOfficial: true,
  url: null,
);

const _testSources = CitySources(
  territorialIdentity: _testSource,
  population: _testSource,
  humanDevelopment: _testSource,
  curatedMetrics: _testSource,
  ranking: _testSource,
);

class _FakeCitiesRepository implements CitiesRepository {
  const _FakeCitiesRepository();

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async => const [
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
      topIndustries: ['Tecnologia'],
      movaroScores: CityScores(
        economical: 76,
        popularForArgentinians: 68,
        languageAdaptation: 72,
        workOpportunity: 82,
        overall: 84,
      ),
      recommendationReasons: ['reason'],
      sources: _testSources,
      updatedAt: '2026-03-12',
      regionName: 'Sul',
    ),
  ];

  @override
  Future<City> getCityById(String id) async => (await getCities()).first;

  @override
  Future<CityHighlights> getHighlights() async {
    final cities = await getCities();
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
  Future<List<City>> searchCities(String query) async => getCities();
}

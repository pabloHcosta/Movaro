import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
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

  group('MigrationQuestionnaireController flow variants', () {
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
    });

    tearDown(() async {
      try {
        await tempDirectory.delete(recursive: true);
      } on PathNotFoundException {
        // A background reset may already have removed the isolated directory.
      } on FileSystemException {
        // Background persistence can finish between existsSync and delete.
        // Cleanup is already complete when the directory no longer exists.
        if (tempDirectory.existsSync()) {
          rethrow;
        }
      }
    });

    test('lean flow keeps only the 3 core questions', () {
      controller.selectVariant(QuestionnaireVariant.lean);

      expect(controller.activeQuestions.map((question) => question.id), [
        'intent',
        'timeline',
        'priorities',
      ]);
    });

    test(
      'lean flow asks for origin and generates a plan when the journey is missing',
      () async {
        await journeyContextController.clearJourney();
        await controller.resetFlow();
        await controller.initializeForQuestionnaire();

        expect(controller.activeQuestions.map((question) => question.id), [
          'origin_country',
          'intent',
          'timeline',
          'priorities',
        ]);
        expect(controller.currentQuestion?.id, 'origin_country');

        controller.selectAnswer('origin_country', 'argentina');
        expect(await controller.goNext(), isFalse);
        controller.selectAnswer('intent', 'remote_income');
        expect(await controller.goNext(), isFalse);
        controller.selectAnswer('timeline', 'in_3_6m');
        expect(await controller.goNext(), isFalse);
        controller.setAnswerValues('priorities', ['low_cost', 'safety']);

        expect(await controller.goNext(), isFalse);
        expect(controller.isRefinePromptVisible, isTrue);
        expect(await controller.skipRefine(), isTrue);
        expect(controller.generatedPlan, isNotNull);
        expect(controller.generatedPlan!.id, isNotEmpty);
        expect(controller.generatedPlan!.createdAt, isNotNull);
        expect(journeyContextController.isJourneyReadyForPlanning, isTrue);
      },
    );

    test('quick flow offers and applies explicit profile refinement', () async {
      controller.selectVariant(QuestionnaireVariant.lean);
      controller.selectAnswer('intent', 'fresh_start');
      expect(await controller.goNext(), isFalse);
      controller.selectAnswer('timeline', 'in_3_6m');
      expect(await controller.goNext(), isFalse);
      controller.setAnswerValues('priorities', ['safety', 'low_cost']);

      expect(await controller.goNext(), isFalse);
      expect(controller.isRefinePromptVisible, isTrue);

      controller.acceptRefine();

      expect(controller.selectedVariant, QuestionnaireVariant.strategic);
      expect(controller.currentQuestion?.id, 'travel_group');

      controller.selectAnswer('travel_group', 'family_kids');
      controller.selectAnswer('travel_group_children_count', '2');
      expect(await controller.goNext(), isFalse);
      controller.selectAnswer('work_arrangement', 'local_job');
      expect(await controller.goNext(), isFalse);
      expect(controller.currentQuestion?.id, 'funding');
      controller.selectAnswer('funding', 'job_search');
      expect(await controller.goNext(), isFalse);
      expect(controller.currentQuestion?.id, 'support_needs');
      controller.setAnswerValues('support_needs', [
        'travel_with_pet',
        'continuous_medication',
        'will_drive',
      ]);

      expect(await controller.goNext(), isTrue);
      expect(controller.generatedPlan?.variant, QuestionnaireVariant.strategic);
      expect(controller.generatedPlan?.travelGroup, 'family_kids');
      expect(controller.generatedPlan?.childrenCount, 2);
      expect(controller.generatedPlan?.workArrangement, 'local_job');
      expect(controller.generatedPlan?.funding, 'job_search');
      expect(
        controller.generatedPlan?.selectedConstraints,
        containsAll(['travel_with_pet', 'continuous_medication', 'will_drive']),
      );
    });

    test(
      'strategic refinement starts from contextual needs after core answers',
      () async {
        controller.selectVariant(QuestionnaireVariant.lean);
        controller.selectAnswer('intent', 'explore_unsure');
        controller.selectAnswer('timeline', 'just_exploring');
        controller.setAnswerValues('priorities', ['balanced_unsure']);

        await controller.beginStrategicRefinement();

        expect(controller.activeQuestions.map((question) => question.id), [
          'intent',
          'timeline',
          'travel_group',
          'work_arrangement',
          'funding',
          'priorities',
          'support_needs',
        ]);
        expect(controller.currentQuestion?.id, 'travel_group');
      },
    );

    test('strategic flow keeps capital question conditional', () {
      controller.selectVariant(QuestionnaireVariant.strategic);

      expect(controller.activeQuestions.map((question) => question.id), [
        'intent',
        'timeline',
        'travel_group',
        'work_arrangement',
        'funding',
        'priorities',
        'support_needs',
      ]);

      controller.selectAnswer('funding', 'savings');

      expect(controller.activeQuestions.map((question) => question.id), [
        'intent',
        'timeline',
        'travel_group',
        'work_arrangement',
        'funding',
        'available_capital',
        'priorities',
        'support_needs',
      ]);

      controller.selectAnswer('funding', 'job_offer');

      expect(controller.activeQuestions.map((question) => question.id), [
        'intent',
        'timeline',
        'travel_group',
        'work_arrangement',
        'funding',
        'priorities',
        'support_needs',
      ]);
    });

    test('practical situations are independent multi-select refinements', () {
      final question = controller.questions.firstWhere(
        (item) => item.id == 'support_needs',
      );

      expect(question.type, 'multi_chip');
      expect(question.maxSelections, 3);
      expect(
        question.options.map((option) => option.value),
        orderedEquals([
          'travel_with_pet',
          'continuous_medication',
          'will_drive',
          'no_special_needs',
        ]),
      );
      expect(
        question.options.map((option) => option.value),
        isNot(contains('children_school')),
      );
      expect(
        question.options.map((option) => option.value),
        isNot(contains('foreign_income')),
      );
    });

    test('single parents must provide and retain the children count', () async {
      controller.selectVariant(QuestionnaireVariant.strategic);
      controller.selectAnswer('intent', 'fresh_start');
      expect(await controller.goNext(), isFalse);
      controller.selectAnswer('timeline', 'in_3_6m');
      expect(await controller.goNext(), isFalse);
      expect(controller.currentQuestion?.id, 'travel_group');

      controller.selectAnswer('travel_group', 'solo_parent');
      expect(controller.canGoNext, isFalse);

      controller.selectAnswer('travel_group_children_count', '1');
      expect(controller.canGoNext, isTrue);
      expect(controller.answerFor('travel_group_children_count'), '1');
    });

    test('special-needs none option remains exclusive', () {
      controller.selectVariant(QuestionnaireVariant.strategic);

      expect(
        controller.toggleAnswer('support_needs', 'travel_with_pet'),
        isTrue,
      );
      expect(
        controller.toggleAnswer('support_needs', 'continuous_medication'),
        isTrue,
      );
      expect(controller.toggleAnswer('support_needs', 'will_drive'), isTrue);
      expect(
        controller.answerValuesFor('support_needs'),
        unorderedEquals([
          'travel_with_pet',
          'continuous_medication',
          'will_drive',
        ]),
      );

      expect(
        controller.toggleAnswer('support_needs', 'no_special_needs'),
        isTrue,
      );
      expect(controller.answerValuesFor('support_needs'), ['no_special_needs']);
    });

    test('starting over clears the previously selected city', () async {
      final previousCity = await const _FakeCitiesRepository().getCityById(
        'curitiba',
      );
      controller
        ..setPreferredCity(previousCity)
        ..selectVariant(QuestionnaireVariant.lean)
        ..selectAnswer('intent', 'remote_income');

      expect(controller.preferredCity?.id, 'curitiba');
      expect(controller.answers, isNotEmpty);

      await controller.clearCurrentPlan();

      expect(controller.preferredCity, isNull);
      expect(controller.generatedPlan, isNull);
      expect(
        controller.answers.map((answer) => answer.questionId),
        unorderedEquals(['origin_country', 'destination_country']),
      );
      expect(controller.answerFor('intent'), isNull);
      expect(controller.selectedVariant, isNull);
    });
  });
}

class _InMemoryQuestionnaireFlowDraftStore extends QuestionnaireFlowDraftStore {
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
  sourceType: 'official',
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

  // City-detail payload methods are not exercised by these tests; route any
  // unimplemented repository member to a clear failure instead of breaking
  // compilation when the interface grows.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

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
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  ) async {
    final cities = await getCities();
    return CityRecommendationResult(
      methodologyVersion: 'city-recommendation-v2.0.0-test',
      generatedAt: '2026-07-29T12:00:00.000Z',
      catalogSize: cities.length,
      eligibleCityCount: cities.length,
      profileCompleteness: 0.8,
      dataCoverage: 0.75,
      appliedHardFilters: profile.constraints,
      unavailableDimensions: const [],
      warnings: const [],
      recommendations: [
        RecommendedCity(
          city: cities.first,
          score: 0.82,
          dimensions: const {'affordability': 0.78, 'safety': 0.8},
          reasons: const ['plan_reason_budget_fit'],
          tradeoffs: const [],
          dataCoverage: 0.75,
          freshnessStatus: 'fresh',
          evidence: const [],
        ),
      ],
      sourceSummary: const [],
    );
  }

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

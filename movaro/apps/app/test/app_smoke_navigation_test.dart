import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/bootstrap/app_dependencies.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/exchange_rates/exchange_rates_controller.dart';
import 'package:movaro_app/features/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/core/environment/api_source.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/auth/data/datasources/fake_auth_data_source.dart';
import 'package:movaro_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/city_insights/domain/repositories/city_insight_repository.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/datasources/copilot_exchange_rates_remote_data_source.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/question_repository_impl.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _AppTestHarness harness;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    harness = await _AppTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets(
    'public home supports no-journey entry and cities remain accessible',
    (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        harness.buildApp(initialRoute: AppRoutes.publicHome),
      );
      await _pumpScreen(tester);

      expect(find.text('Plano'), findsNothing);
      expect(
        find.byKey(const ValueKey('home-action-discover')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('home-action-known-city')),
        findsOneWidget,
      );
      expect(find.text('Resolver uma dúvida agora'), findsOneWidget);

      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.cities));
      await _pumpScreen(tester);

      expect(find.byType(TextField), findsWidgets);

      await tester.enterText(find.byType(TextField).first, 'Curitiba');
      await tester.pump(const Duration(milliseconds: 350));
      await _pumpScreen(tester);

      expect(find.text('Curitiba'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('public home discover action confirms the origin city first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final discoverAction = find.byKey(const ValueKey('home-action-discover'));
    await tester.ensureVisible(discoverAction);
    await tester.tap(discoverAction);
    await _pumpScreen(tester);

    expect(find.text('Encontramos sua cidade'), findsOneWidget);
    expect(find.text('San Rafael'), findsOneWidget);
    expect(find.text('Sim, esta é minha cidade'), findsOneWidget);
    expect(find.text('Quero escolher outra'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('public home known-city action confirms the origin city first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final knownCityAction = find.byKey(
      const ValueKey('home-action-known-city'),
    );
    await tester.ensureVisible(knownCityAction);
    await tester.tap(knownCityAction);
    await _pumpScreen(tester);

    expect(find.text('Encontramos sua cidade'), findsOneWidget);
    expect(find.text('San Rafael'), findsOneWidget);
    expect(find.text('Sim, esta é minha cidade'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('city search resolves human-friendly aliases in autocomplete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.citiesSearch),
    );
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'poa');
    await tester.pump();
    await _pumpScreen(tester);

    expect(find.text('Porto Alegre'), findsWidgets);
    expect(find.textContaining('cidades encontradas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('copilot redirects to result reveal until city is confirmed', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.migrationPlanCopilot),
    );
    await _pumpScreen(tester);

    expect(find.text('Ver detalhes da cidade'), findsOneWidget);
    expect(find.text('Comparar com alternativas'), findsOneWidget);
    expect(find.textContaining('Começar preparação com'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('confirmed city turns public home into execution home', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('Ver cidade'), findsOneWidget);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('copilot back falls back to public home when opened as root', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.migrationPlanCopilot),
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('Ver plano completo'), findsOneWidget);

    await tester.tap(
      find.byIcon(Icons.arrow_back_rounded).first,
      warnIfMissed: false,
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('home lets the user cancel replacing the current plan', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await _pumpScreen(tester);
    await tester.tap(find.text('Novo plano'));
    await _pumpScreen(tester);

    expect(find.text('Começar um novo plano'), findsOneWidget);

    await tester.tap(find.text('Cancelar — manter Curitiba'));
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('home lets the user rebuild the current plan', (tester) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await _pumpScreen(tester);
    await tester.tap(find.text('Novo plano'));
    await _pumpScreen(tester);

    await tester.tap(find.text('Sim, começar do zero'));
    await _pumpScreen(tester);

    expect(find.byKey(const ValueKey('home-action-discover')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-action-known-city')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 600));
}

class _AppTestHarness {
  _AppTestHarness({required this.dependencies, required this.tempDirectory});

  final AppDependencies dependencies;
  final Directory tempDirectory;

  AppEnvironment get environment => dependencies.environment;
  AuthController get authController => dependencies.authController;
  CatalogRepositoryImpl get catalogRepository =>
      dependencies.catalogRepository as CatalogRepositoryImpl;
  CitiesController get citiesController => dependencies.citiesController;
  MigrationQuestionnaireController get migrationQuestionnaireController =>
      dependencies.migrationQuestionnaireController;
  CopilotExchangeRatesService get copilotExchangeRatesService =>
      dependencies.copilotExchangeRatesService;
  ApiHealthService get apiHealthService => dependencies.apiHealthService;
  JourneyContextController get journeyContextController =>
      dependencies.journeyContextController;
  LocationController get locationController => dependencies.locationController;
  LocaleController get localeController => dependencies.localeController;
  ThemeController get themeController => dependencies.themeController;

  static Future<_AppTestHarness> create({
    bool seedJourney = true,
    bool initializeQuestionnaire = true,
  }) async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'movaro_app_smoke',
    );
    final environment = AppEnvironment(
      flavor: AppFlavor.development,
      environmentName: 'test',
      apiSource: ApiSource.local,
      apiBaseUrl: 'http://127.0.0.1:3000',
      localApiBaseUrl: 'http://127.0.0.1:3000',
      railwayApiBaseUrl: 'https://movaro-production.up.railway.app',
      appName: 'Movaro Test',
    );
    final catalogRepository = CatalogRepositoryImpl(
      dataSource: SeedCatalogDataSource(),
    );
    final authController = AuthController(
      repository: AuthRepositoryImpl(
        dataSource: FakeAuthDataSource(environment: environment),
      ),
    );
    final journeyContextController = JourneyContextController(
      catalogRepository: catalogRepository,
      store: JourneyPreferencesStore(
        directoryProvider: () async => tempDirectory,
      ),
    );
    final locationController = _FakeLocationController(
      journeyContextController: journeyContextController,
    );
    const citiesRepository = _FakeCitiesRepository();
    final citiesController = _SmokeCitiesController(
      repository: citiesRepository,
    );
    final migrationQuestionnaireController = MigrationQuestionnaireController(
      questionRepository: QuestionRepositoryImpl(
        catalogRepository: catalogRepository,
        journeyContextController: journeyContextController,
      ),
      migrationPlanRepository: LocalMigrationPlanRepository(
        directoryProvider: () async => tempDirectory,
      ),
      planGenerator: MigrationPlanGenerator(citiesRepository: citiesRepository),
      journeyContextController: journeyContextController,
      flowDraftStore: _InMemoryQuestionnaireFlowDraftStore(),
    );
    final copilotExchangeRatesService = _FakeCopilotExchangeRatesService(
      environment: environment,
      store: CopilotExchangeRatesStore(
        directoryProvider: () async => tempDirectory,
      ),
    );
    final apiHealthService = ApiHealthService(environment: environment);
    final cityInsightsController = CityInsightController(
      repository: _FakeCityInsightRepository(),
    );
    final localeController = LocaleController();
    localeController.setLocale(const Locale('pt'));
    final themeController = ThemeController();
    final currencyController = CurrencyController();
    final exchangeRatesController = ExchangeRatesController(
      service: copilotExchangeRatesService,
    );
    final guideFlowMetricsStore = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await guideFlowMetricsStore.initialize();

    await journeyContextController.initialize();
    await journeyContextController.markIntroSeen();
    if (seedJourney) {
      await journeyContextController.completeJourney(
        originCountryId: 'argentina',
        destinationCountryId: 'brasil',
      );
    }
    await authController.initialize();
    if (initializeQuestionnaire) {
      await migrationQuestionnaireController.initialize();
    }

    return _AppTestHarness(
      dependencies: AppDependencies(
        environment: environment,
        authController: authController,
        catalogRepository: catalogRepository,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
        copilotExchangeRatesService: copilotExchangeRatesService,
        apiHealthService: apiHealthService,
        cityInsightsController: cityInsightsController,
        journeyContextController: journeyContextController,
        locationController: locationController,
        localeController: localeController,
        themeController: themeController,
        currencyController: currencyController,
        exchangeRatesController: exchangeRatesController,
        guideFlowMetricsStore: guideFlowMetricsStore,
      ),
      tempDirectory: tempDirectory,
    );
  }

  Widget buildApp({required String initialRoute}) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return LocaleScope(
          controller: localeController,
          child: MaterialApp(
            key: ValueKey(initialRoute),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.themeMode,
            locale: localeController.locale,
            supportedLocales: AppLocalization.supportedLocales,
            localizationsDelegates: AppLocalization.localizationsDelegates,
            onGenerateRoute: AppRouter(
              dependencies: dependencies,
            ).onGenerateRoute,
            initialRoute: initialRoute,
          ),
        );
      },
    );
  }

  Future<void> generateLeanPlan() async {
    migrationQuestionnaireController.selectVariant(QuestionnaireVariant.lean);
    migrationQuestionnaireController.selectAnswer('intent', 'remote_income');
    await migrationQuestionnaireController.goNext();
    migrationQuestionnaireController.selectAnswer('timeline', 'in_3_6m');
    await migrationQuestionnaireController.goNext();
    migrationQuestionnaireController.toggleAnswer('priorities', 'low_cost');
    migrationQuestionnaireController.toggleAnswer('priorities', 'safety');
    await migrationQuestionnaireController.goNext();
  }

  Future<void> dispose() async {
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

class _FakeCitiesRepository implements CitiesRepository {
  const _FakeCitiesRepository();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<CityHighlights> getHighlights() async {
    return const CityHighlights(
      mostChosenByArgentinians: [_curitiba, _portoAlegre],
      easiestForSpanishSpeakers: [_portoAlegre, _curitiba],
      mostEconomical: [_curitiba, _salvador],
      bestForWork: [_curitiba, _portoAlegre],
    );
  }

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async {
    return _allCities;
  }

  @override
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  ) async {
    return CityRecommendationResult(
      methodologyVersion: 'city-recommendation-v2.0.0-test',
      generatedAt: '2026-07-29T12:00:00.000Z',
      catalogSize: _allCities.length,
      eligibleCityCount: _allCities.length,
      profileCompleteness: 0.8,
      dataCoverage: 0.8,
      appliedHardFilters: profile.constraints,
      unavailableDimensions: const [],
      warnings: const [],
      recommendations: _allCities.indexed
          .map(
            (entry) => RecommendedCity(
              city: entry.$2,
              score: 0.88 - entry.$1 * 0.08,
              dimensions: const {'affordability': 0.78, 'safety': 0.8},
              reasons: const ['plan_reason_budget_fit'],
              tradeoffs: const [],
              dataCoverage: 0.8,
              freshnessStatus: 'fresh',
              evidence: const [],
            ),
          )
          .toList(growable: false),
      sourceSummary: const [],
    );
  }

  @override
  Future<City> getCityById(String id) async {
    return _allCities.firstWhere((city) => city.id == id);
  }

  @override
  Future<CityMethodology> getMethodology() async {
    return const CityMethodology(
      principles: ['Dados oficiais', 'Pontuacao comparativa'],
      formulas: {'overall': 'weighted_index'},
      note: 'Test methodology note.',
    );
  }

  @override
  Future<List<City>> searchCities(String query) async {
    return _allCities
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
  Future<TravelRouteInsight?> getCityTravelInsight(
    String cityId, {
    String? originIata,
    String? destIata,
  }) async => null;
}

class _SmokeCitiesController extends CitiesController {
  _SmokeCitiesController({required super.repository});

  @override
  Future<void> prefetchCatalog() async {}

  @override
  Future<void> prefetchExplore() async {}

  @override
  Future<void> prefetchMethodology() async {}
}

class _FakeLocationController extends LocationController {
  _FakeLocationController({required super.journeyContextController});

  @override
  LocationData? get savedLocation => const LocationData(
    cityName: 'San Rafael',
    stateName: 'Mendoza',
    countryName: 'Argentina',
    countryCode: 'AR',
    latitude: -34.61,
    longitude: -68.33,
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> shouldRequestAgain() async => false;

  @override
  Future<bool> shouldShowInlineBanner() async => false;
}

class _InMemoryQuestionnaireFlowDraftStore extends QuestionnaireFlowDraftStore {
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

class _FakeCityInsightRepository implements CityInsightRepository {
  @override
  Future<List<CityInsightEntity>> getCityInsights({
    required String cityId,
    String? goal,
    String? timeline,
    String locale = 'pt',
    bool forceRefresh = false,
  }) async => const [];

  @override
  Future<List<CityInsightExplorePlaceEntity>> getExplorePlaces({
    required String cityId,
    required CityInsightTheme theme,
    String locale = 'pt',
    String? seedPlace,
    bool forceRefresh = false,
  }) async => const [];
}

class _FakeCopilotExchangeRatesService extends CopilotExchangeRatesService {
  _FakeCopilotExchangeRatesService({
    required AppEnvironment environment,
    required super.store,
  }) : super(
         remoteDataSource: CopilotExchangeRatesRemoteDataSource(
           environment: environment,
         ),
       );

  @override
  Future<CopilotExchangeRates?> fetchLatest() async {
    const snapshot = CopilotExchangeRates(
      usdToBrl: 5.1,
      brlToUsd: 0.196,
      brlToArs: 190.0,
      arsToBrl: 0.0052,
      usdToArs: 969.0,
      arsToUsd: 0.00103,
      brlToEur: 0.17,
      brlToClp: 170.0,
      brlToUyu: 7.5,
      brlToCop: 720.0,
      brlToPen: 0.66,
      brlToPyg: 1350.0,
      brlToBob: 1.2,
      fetchedAt: '2026-03-12T12:00:00Z',
      source: 'test',
      sources: ['test'],
    );
    return snapshot;
  }
}

const _source = CitySource(
  id: 'test_source',
  title: 'Test source',
  provider: 'Movaro',
  description: 'Mock source',
  isOfficial: true,
  url: null,
  sourceType: 'official',
);

const _sources = CitySources(
  territorialIdentity: _source,
  population: _source,
  humanDevelopment: _source,
  curatedMetrics: _source,
  ranking: _source,
);

const _curitiba = City(
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
  topIndustries: ['Tecnologia', 'Servicos'],
  movaroScores: CityScores(
    economical: 76,
    popularForArgentinians: 68,
    languageAdaptation: 72,
    workOpportunity: 82,
    overall: 84,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Sul',
);

const _portoAlegre = City(
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
  argentinaPopularityScore: 72,
  spanishSupportScore: 75,
  jobMarketScore: 66,
  unemploymentRate: 6.5,
  economicActivityScore: 71,
  topIndustries: ['Servicos', 'Industria'],
  movaroScores: CityScores(
    economical: 70,
    popularForArgentinians: 80,
    languageAdaptation: 82,
    workOpportunity: 70,
    overall: 78,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Sul',
);

const _salvador = City(
  id: 'salvador',
  name: 'Salvador',
  stateCode: 'BA',
  stateName: 'Bahia',
  countryCode: 'BR',
  ibgeCode: 3,
  latitude: -12.97,
  longitude: -38.5,
  population: 2410000,
  idhmScore: 0.76,
  idhmReferenceYear: 2021,
  costOfLivingScore: 68,
  rentScore: 66,
  safetyScore: 55,
  argentinaPopularityScore: 52,
  spanishSupportScore: 48,
  jobMarketScore: 61,
  unemploymentRate: 9.2,
  economicActivityScore: 64,
  topIndustries: ['Turismo', 'Servicos'],
  movaroScores: CityScores(
    economical: 72,
    popularForArgentinians: 60,
    languageAdaptation: 58,
    workOpportunity: 64,
    overall: 69,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Nordeste',
);

const _allCities = <City>[_curitiba, _portoAlegre, _salvador];

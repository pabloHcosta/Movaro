import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/app.dart';
import 'package:movaro_app/app/bootstrap/app_dependencies.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/data/datasources/city_insights_remote_data_source.dart';
import 'package:movaro_app/features/city_insights/data/repositories/city_insight_repository_impl.dart';
import 'package:movaro_app/features/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/core/supabase/supabase_bootstrap.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/auth/data/datasources/fake_auth_data_source.dart';
import 'package:movaro_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/data/datasources/cities_remote_data_source.dart';
import 'package:movaro_app/features/cities/data/repositories/cities_repository_impl.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/datasources/copilot_exchange_rates_remote_data_source.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/question_repository_impl.dart';

Future<void> bootstrap({required AppFlavor defaultFlavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await buildAppDependencies(defaultFlavor: defaultFlavor);
  runApp(MovaroApp(dependencies: dependencies));
}

Future<AppDependencies> buildAppDependencies({
  required AppFlavor defaultFlavor,
}) async {
  final environment = AppEnvironment.fromDartDefines(
    defaultFlavor: defaultFlavor,
  );
  debugPrint(
    'Movaro API source: ${environment.apiSource.name} '
    '(${environment.apiBaseUrl})',
  );
  await SupabaseBootstrap.initializeIfConfigured(environment);
  final catalogRepository = CatalogRepositoryImpl(
    dataSource: SeedCatalogDataSource(),
  );
  final authRepository = AuthRepositoryImpl(
    dataSource: FakeAuthDataSource(environment: environment),
  );
  final authController = AuthController(repository: authRepository);
  final citiesRepository = CitiesRepositoryImpl(
    remoteDataSource: CitiesRemoteDataSource(environment: environment),
  );
  final cityInsightsController = CityInsightController(
    repository: CityInsightRepositoryImpl(
      remoteDataSource: CityInsightsRemoteDataSource(environment: environment),
    ),
  );
  final apiHealthService = ApiHealthService(environment: environment);
  final journeyPreferencesStore = JourneyPreferencesStore();
  final migrationPlanRepository = LocalMigrationPlanRepository();
  final flowDraftStore = QuestionnaireFlowDraftStore();
  final copilotProgressStore = MigrationCopilotProgressStore();
  final migrationStateSyncService = MigrationStateSyncService(
    enabled: environment.hasSupabaseClientConfig,
    migrationPlanRepository: migrationPlanRepository,
    flowDraftStore: flowDraftStore,
    journeyPreferencesStore: journeyPreferencesStore,
    copilotProgressStore: copilotProgressStore,
  );
  MigrationStateSyncCoordinator.register(migrationStateSyncService);
  await migrationStateSyncService.restoreIfNeeded();
  unawaited(migrationStateSyncService.syncNow());
  final journeyContextController = JourneyContextController(
    catalogRepository: catalogRepository,
    store: journeyPreferencesStore,
  );
  final locationController = LocationController(
    journeyContextController: journeyContextController,
  );
  final citiesController = CitiesController(repository: citiesRepository);
  final migrationQuestionnaireController = MigrationQuestionnaireController(
    questionRepository: QuestionRepositoryImpl(
      catalogRepository: catalogRepository,
      journeyContextController: journeyContextController,
    ),
    migrationPlanRepository: migrationPlanRepository,
    planGenerator: MigrationPlanGenerator(citiesRepository: citiesRepository),
    journeyContextController: journeyContextController,
    flowDraftStore: flowDraftStore,
  );
  final copilotExchangeRatesService = CopilotExchangeRatesService(
    remoteDataSource: CopilotExchangeRatesRemoteDataSource(
      environment: environment,
    ),
  );
  final localeController = LocaleController();
  await localeController.initialize();
  final themeController = ThemeController();
  await themeController.initialize();
  final currencyController = CurrencyController();
  await currencyController.initialize();

  return AppDependencies(
    environment: environment,
    authController: authController,
    catalogRepository: catalogRepository,
    cityInsightsController: cityInsightsController,
    citiesController: citiesController,
    migrationQuestionnaireController: migrationQuestionnaireController,
    copilotExchangeRatesService: copilotExchangeRatesService,
    apiHealthService: apiHealthService,
    journeyContextController: journeyContextController,
    locationController: locationController,
    localeController: localeController,
    themeController: themeController,
    currencyController: currencyController,
  );
}

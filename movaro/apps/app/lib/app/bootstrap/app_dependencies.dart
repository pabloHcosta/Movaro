import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.environment,
    required this.authController,
    required this.catalogRepository,
    required this.cityInsightsController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.copilotExchangeRatesService,
    required this.apiHealthService,
    required this.journeyContextController,
    required this.locationController,
    required this.localeController,
    required this.themeController,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final CatalogRepository catalogRepository;
  final CityInsightController cityInsightsController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final CopilotExchangeRatesService copilotExchangeRatesService;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;
  final LocationController locationController;
  final LocaleController localeController;
  final ThemeController themeController;
}

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';

class MovaroApp extends StatelessWidget {
  const MovaroApp({
    required this.environment,
    required this.authController,
    required this.catalogRepository,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.copilotExchangeRatesService,
    required this.apiHealthService,
    required this.journeyContextController,
    required this.locationController,
    required this.localeController,
    required this.themeController,
    super.key,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final CatalogRepository catalogRepository;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final CopilotExchangeRatesService copilotExchangeRatesService;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;
  final LocationController locationController;
  final LocaleController localeController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([localeController, themeController]),
      builder: (context, _) {
        return LocaleScope(
          controller: localeController,
          child: MaterialApp(
            title: environment.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.themeMode,
            locale: localeController.locale,
            supportedLocales: AppLocalization.supportedLocales,
            localizationsDelegates: AppLocalization.localizationsDelegates,
            localeListResolutionCallback: (locales, _) =>
                AppLocalization.resolveLocales(locales),
            onGenerateTitle: (context) => environment.appName,
            onGenerateRoute: AppRouter(
              environment: environment,
              authController: authController,
              catalogRepository: catalogRepository,
              citiesController: citiesController,
              migrationQuestionnaireController:
                  migrationQuestionnaireController,
              copilotExchangeRatesService: copilotExchangeRatesService,
              apiHealthService: apiHealthService,
              journeyContextController: journeyContextController,
              locationController: locationController,
              localeController: localeController,
              themeController: themeController,
            ).onGenerateRoute,
            initialRoute: AppRoutes.splash,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class MovaroApp extends StatelessWidget {
  const MovaroApp({
    required this.environment,
    required this.authController,
    required this.catalogRepository,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.apiHealthService,
    required this.journeyContextController,
    required this.localeController,
    super.key,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final CatalogRepository catalogRepository;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return LocaleScope(
          controller: localeController,
          child: MaterialApp(
            title: environment.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
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
              apiHealthService: apiHealthService,
              journeyContextController: journeyContextController,
            ).onGenerateRoute,
            initialRoute: AppRoutes.splash,
          ),
        );
      },
    );
  }
}

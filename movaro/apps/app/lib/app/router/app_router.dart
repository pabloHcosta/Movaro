import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/pages/cities_explore_page.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_detail_page.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_search_page.dart';
import 'package:movaro_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/countries_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/pages/home_page.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/pages/favorites_page.dart';
import 'package:movaro_app/features/info/presentation/pages/assistant_page.dart';
// info_brazil_page removed — Info tab now loads AssistantPage
import 'package:movaro_app/features/home/presentation/pages/public_home_page.dart';
import 'package:movaro_app/features/intro/presentation/pages/intro_page.dart';
import 'package:movaro_app/features/journey/presentation/pages/journey_setup_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_result_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_copilot_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_result_reveal_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_save_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/question_page.dart';
import 'package:movaro_app/features/shared/presentation/pages/protected_placeholder_page.dart';
import 'package:movaro_app/features/shared/presentation/pages/app_settings_page.dart';
import 'package:movaro_app/features/splash/presentation/pages/splash_page.dart';
import 'package:movaro_app/app/router/app_routes.dart';

class AppRouter {
  const AppRouter({
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

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.splash;

    if (AppRoutes.privatePaths.contains(routeName) &&
        !authController.isAuthenticated) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.publicHome),
        PublicHomePage(
          journeyContextController: journeyContextController,
          citiesController: citiesController,
          migrationQuestionnaireController: migrationQuestionnaireController,
          locationController: locationController,
          environment: environment,
        ),
      );
    }

    const completeJourneyRequiredPaths = <String>{
      AppRoutes.migrationPlanResult,
      AppRoutes.migrationResultReveal,
      AppRoutes.migrationPlanCopilot,
    };

    if (completeJourneyRequiredPaths.contains(routeName) &&
        !journeyContextController.isJourneyReadyForPlanning) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.publicHome),
        PublicHomePage(
          journeyContextController: journeyContextController,
          citiesController: citiesController,
          migrationQuestionnaireController: migrationQuestionnaireController,
          locationController: locationController,
          environment: environment,
        ),
      );
    }

    if (routeName != AppRoutes.onboarding &&
        routeName != AppRoutes.login &&
        AppRoutes.privatePaths.contains(routeName) &&
        authController.needsOnboarding) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.onboarding),
        OnboardingPage(
          authController: authController,
          catalogRepository: catalogRepository,
          locationController: locationController,
        ),
      );
    }

    if (AppRoutes.isCityDetailRoute(routeName)) {
      final cityId = routeName.replaceFirst('/cities/', '');
      final args = settings.arguments;
      final selectForPlan =
          args is Map<String, dynamic> && args['selectForPlan'] == true;
      final fromMigrationResult =
          args is Map<String, dynamic> && args['fromMigrationResult'] == true;
      unawaited(citiesController.prefetchCityDetail(cityId));
      unawaited(citiesController.prefetchMethodology());
      return _buildRoute(
        settings,
        CityDetailPage(
          cityId: cityId,
          citiesController: citiesController,
          migrationQuestionnaireController: migrationQuestionnaireController,
          locationController: locationController,
          selectForPlan: selectForPlan,
          fromMigrationResult: fromMigrationResult,
        ),
      );
    }

    switch (routeName) {
      case AppRoutes.splash:
        return _buildRoute(
          settings,
          SplashPage(
            environment: environment,
            authController: authController,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
            apiHealthService: apiHealthService,
            journeyContextController: journeyContextController,
            locationController: locationController,
          ),
        );
      case AppRoutes.publicHome:
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          PublicHomePage(
            environment: environment,
            journeyContextController: journeyContextController,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
            locationController: locationController,
          ),
        );
      case AppRoutes.favorites:
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          FavoritesPage(
            journeyContextController: journeyContextController,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.cityComparison:
        final initialCities = settings.arguments is List<City>
            ? settings.arguments! as List<City>
            : const <City>[];
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          CityComparisonScreen(
            initialCities: initialCities,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.intro:
        final isFirstLaunch = settings.arguments == true;
        return _buildRoute(
          settings,
          IntroPage(
            journeyContextController: journeyContextController,
            locationController: locationController,
            isFirstLaunch: isFirstLaunch,
          ),
        );
      case AppRoutes.journeySetup:
        unawaited(catalogRepository.getCountries());
        return _buildRoute(
          settings,
          JourneySetupPage(
            catalogRepository: catalogRepository,
            journeyContextController: journeyContextController,
            locationController: locationController,
          ),
        );
      case AppRoutes.explore:
        unawaited(citiesController.prefetchExplore());
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          CitiesExplorePage(
            citiesController: citiesController,
            journeyContextController: journeyContextController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.info:
        return _buildRoute(
          settings,
          AssistantPage(
            environment: environment,
            journeyContextController: journeyContextController,
            migrationQuestionnaireController: migrationQuestionnaireController,
            citiesController: citiesController,
            exchangeRatesService: copilotExchangeRatesService,
            initialMessage: settings.arguments is String
                ? settings.arguments! as String
                : null,
          ),
        );
      case AppRoutes.documentationGuide:
        final initialSection = settings.arguments is DocumentationGuideSection
            ? settings.arguments! as DocumentationGuideSection
            : null;
        return _buildRoute(
          settings,
          DocumentationGuidePage(
            exchangeRatesService: copilotExchangeRatesService,
            initialSection: initialSection,
            journeyContextController: journeyContextController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.documentationTopic:
        final section = settings.arguments is DocumentationGuideSection
            ? settings.arguments! as DocumentationGuideSection
            : DocumentationGuideSection.documents;
        return _buildRoute(
          settings,
          DocumentationTopicPage(
            section: section,
            exchangeRatesService: copilotExchangeRatesService,
            preferredCurrencyCountryId:
                locationController.fallbackPreferredCountryId(
                  journeyContextController.originCountryId,
                ) ??
                migrationQuestionnaireController.generatedPlan?.originCountry,
          ),
        );
      case AppRoutes.cities:
        unawaited(citiesController.prefetchExplore());
        return _buildRoute(
          settings,
          CitiesExplorePage(
            citiesController: citiesController,
            journeyContextController: journeyContextController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.citiesSearch:
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          CitySearchPage(citiesController: citiesController),
        );
      case AppRoutes.countries:
        unawaited(catalogRepository.getCountries());
        return _buildRoute(
          settings,
          CountriesPage(catalogRepository: catalogRepository),
        );
      case AppRoutes.login:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.publicHome),
          PublicHomePage(
            environment: environment,
            journeyContextController: journeyContextController,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
            locationController: locationController,
          ),
        );
      case AppRoutes.onboarding:
        unawaited(catalogRepository.getCountries());
        return _buildRoute(
          settings,
          OnboardingPage(
            authController: authController,
            catalogRepository: catalogRepository,
            locationController: locationController,
          ),
        );
      case AppRoutes.migrationQuestionnaire:
        return _buildRoute(
          settings,
          QuestionPage(
            controller: migrationQuestionnaireController,
            locationController: locationController,
            citiesController: citiesController,
          ),
        );
      case AppRoutes.locationPermission:
        final args = settings.arguments is LocationPermissionScreenArgs
            ? settings.arguments! as LocationPermissionScreenArgs
            : const LocationPermissionScreenArgs();
        return _buildRoute(
          settings,
          LocationPermissionScreen(
            locationController: locationController,
            args: args,
          ),
        );
      case AppRoutes.settings:
        return _buildRoute(
          settings,
          AppSettingsPage(
            localeController: localeController,
            themeController: themeController,
          ),
        );
      case AppRoutes.migrationPlanResult:
        return _buildRoute(
          settings,
          MigrationPlanResultPage(
            controller: migrationQuestionnaireController,
            citiesController: citiesController,
          ),
        );
      case AppRoutes.migrationResultReveal:
        return _buildRoute(
          settings,
          MigrationResultRevealPage(
            controller: migrationQuestionnaireController,
            citiesController: citiesController,
          ),
        );
      case AppRoutes.migrationPlanCopilot:
        if (migrationQuestionnaireController.generatedPlan?.isCityConfirmed !=
            true) {
          return _buildRoute(
            const RouteSettings(name: AppRoutes.migrationResultReveal),
            MigrationResultRevealPage(
              controller: migrationQuestionnaireController,
              citiesController: citiesController,
            ),
          );
        }
        return _buildRoute(
          settings,
          MigrationPlanCopilotPage(
            controller: migrationQuestionnaireController,
            exchangeRatesService: copilotExchangeRatesService,
            citiesController: citiesController,
            journeyContextController: journeyContextController,
            locationController: locationController,
          ),
        );
      case AppRoutes.authenticatedHome:
        return _buildRoute(
          settings,
          HomePage(
            environment: environment,
            authController: authController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.communityCreate:
        return _buildRoute(
          settings,
          const ProtectedPlaceholderPage(
            type: ProtectedPlaceholderType.communityCreate,
          ),
        );
      case AppRoutes.migrationSave:
        return _buildRoute(
          settings,
          MigrationPlanSavePage(controller: migrationQuestionnaireController),
        );
      default:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.journeySetup),
          JourneySetupPage(
            catalogRepository: catalogRepository,
            journeyContextController: journeyContextController,
            locationController: locationController,
          ),
        );
    }
  }

  Route<void> _buildRoute(RouteSettings settings, Widget child) {
    const primaryNavRoutes = <String>{
      AppRoutes.publicHome,
      AppRoutes.explore,
      AppRoutes.favorites,
      AppRoutes.migrationPlanCopilot,
      AppRoutes.info,
    };

    if (primaryNavRoutes.contains(settings.name)) {
      return PageRouteBuilder<void>(
        settings: settings,
        opaque: false,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
            child: child,
          );
        },
      );
    }

    return MaterialPageRoute<void>(builder: (_) => child, settings: settings);
  }
}

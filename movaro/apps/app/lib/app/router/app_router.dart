import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/bootstrap/app_dependencies.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/pages/cities_explore_page.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_detail_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/countries_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/pages/favorites_page.dart';
import 'package:movaro_app/features/home/presentation/pages/home_page.dart';
import 'package:movaro_app/features/home/presentation/pages/public_home_page.dart';
import 'package:movaro_app/features/info/presentation/pages/assistant_page.dart';
import 'package:movaro_app/features/intro/presentation/pages/intro_page.dart';
import 'package:movaro_app/features/journey/presentation/pages/journey_setup_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_copilot_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_save_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_result_reveal_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/question_page.dart';
import 'package:movaro_app/app/presentation/pages/app_settings_page.dart';
import 'package:movaro_app/app/presentation/pages/protected_placeholder_page.dart';
import 'package:movaro_app/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  const AppRouter({required this.dependencies});

  final AppDependencies dependencies;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.splash;

    if (AppRoutes.privatePaths.contains(routeName) &&
        !dependencies.authController.isAuthenticated) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.publicHome),
        PublicHomePage(
          cityInsightsController: dependencies.cityInsightsController,
          journeyContextController: dependencies.journeyContextController,
          citiesController: dependencies.citiesController,
          migrationQuestionnaireController:
              dependencies.migrationQuestionnaireController,
          locationController: dependencies.locationController,
          environment: dependencies.environment,
          redirectMessage: 'Faça login para acessar essa área.',
        ),
      );
    }

    const completeJourneyRequiredPaths = <String>{
      AppRoutes.migrationPlanResult,
      AppRoutes.migrationResultReveal,
      AppRoutes.migrationPlanCopilot,
    };

    if (completeJourneyRequiredPaths.contains(routeName) &&
        !dependencies.journeyContextController.isJourneyReadyForPlanning) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.publicHome),
        PublicHomePage(
          cityInsightsController: dependencies.cityInsightsController,
          journeyContextController: dependencies.journeyContextController,
          citiesController: dependencies.citiesController,
          migrationQuestionnaireController:
              dependencies.migrationQuestionnaireController,
          locationController: dependencies.locationController,
          environment: dependencies.environment,
          redirectMessage:
              'Complete seu perfil de jornada para acessar essa página.',
        ),
      );
    }

    if (routeName != AppRoutes.onboarding &&
        routeName != AppRoutes.login &&
        AppRoutes.privatePaths.contains(routeName) &&
        dependencies.authController.needsOnboarding) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.onboarding),
        OnboardingPage(
          authController: dependencies.authController,
          catalogRepository: dependencies.catalogRepository,
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
      final validationFlow =
          args is Map<String, dynamic> && args['validationFlow'] == true;
      unawaited(dependencies.citiesController.prefetchCityDetail(cityId));
      unawaited(dependencies.citiesController.prefetchMethodology());
      return _buildRoute(
        settings,
        CityDetailPage(
          cityId: cityId,
          citiesController: dependencies.citiesController,
          cityInsightsController: dependencies.cityInsightsController,
          migrationQuestionnaireController:
              dependencies.migrationQuestionnaireController,
          locationController: dependencies.locationController,
          selectForPlan: selectForPlan,
          fromMigrationResult: fromMigrationResult,
          validationFlow: validationFlow,
        ),
      );
    }

    switch (routeName) {
      case AppRoutes.splash:
        return _buildRoute(
          settings,
          SplashPage(
            environment: dependencies.environment,
            authController: dependencies.authController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            apiHealthService: dependencies.apiHealthService,
            journeyContextController: dependencies.journeyContextController,
            locationController: dependencies.locationController,
          ),
        );
      case AppRoutes.publicHome:
        unawaited(dependencies.citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          PublicHomePage(
            cityInsightsController: dependencies.cityInsightsController,
            environment: dependencies.environment,
            journeyContextController: dependencies.journeyContextController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            locationController: dependencies.locationController,
          ),
        );
      case AppRoutes.favorites:
        unawaited(dependencies.citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          FavoritesPage(
            journeyContextController: dependencies.journeyContextController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
          ),
        );
      case AppRoutes.cityComparison:
        final initialCities = settings.arguments is List<City>
            ? settings.arguments! as List<City>
            : const <City>[];
        unawaited(dependencies.citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          CityComparisonScreen(
            initialCities: initialCities,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
          ),
        );
      case AppRoutes.intro:
        final isFirstLaunch = settings.arguments == true;
        return _buildRoute(
          settings,
          IntroPage(
            journeyContextController: dependencies.journeyContextController,
            isFirstLaunch: isFirstLaunch,
          ),
        );
      case AppRoutes.journeySetup:
        unawaited(dependencies.catalogRepository.getCountries());
        final args = settings.arguments is JourneySetupPageArgs
            ? settings.arguments! as JourneySetupPageArgs
            : const JourneySetupPageArgs();
        return _buildRoute(
          settings,
          JourneySetupPage(
            catalogRepository: dependencies.catalogRepository,
            journeyContextController: dependencies.journeyContextController,
            locationController: dependencies.locationController,
            args: args,
          ),
        );
      case AppRoutes.explore:
      case AppRoutes.cities:
        unawaited(dependencies.citiesController.prefetchExplore());
        if (routeName == AppRoutes.explore) {
          unawaited(dependencies.citiesController.prefetchCatalog());
        }
        return _buildRoute(
          settings,
          CitiesExplorePage(
            citiesController: dependencies.citiesController,
            journeyContextController: dependencies.journeyContextController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            entryMode: CitiesExploreEntryMode.explore,
          ),
        );
      case AppRoutes.info:
        return _buildRoute(
          settings,
          AssistantPage(
            environment: dependencies.environment,
            journeyContextController: dependencies.journeyContextController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            citiesController: dependencies.citiesController,
            exchangeRatesService: dependencies.copilotExchangeRatesService,
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
            environment: dependencies.environment,
            exchangeRatesService: dependencies.copilotExchangeRatesService,
            initialSection: initialSection,
            journeyContextController: dependencies.journeyContextController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
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
            exchangeRatesService: dependencies.copilotExchangeRatesService,
            preferredCurrencyCountryId:
                dependencies.locationController.fallbackPreferredCountryId(
                  dependencies.journeyContextController.originCountryId,
                ) ??
                dependencies
                    .migrationQuestionnaireController
                    .generatedPlan
                    ?.originCountry,
          ),
        );
      case AppRoutes.citiesSearch:
        unawaited(dependencies.citiesController.prefetchCatalog());
        unawaited(dependencies.citiesController.prefetchExplore());
        return _buildRoute(
          settings,
          CitiesExplorePage(
            citiesController: dependencies.citiesController,
            journeyContextController: dependencies.journeyContextController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            entryMode: CitiesExploreEntryMode.validation,
          ),
        );
      case AppRoutes.countries:
        unawaited(dependencies.catalogRepository.getCountries());
        return _buildRoute(
          settings,
          CountriesPage(catalogRepository: dependencies.catalogRepository),
        );
      case AppRoutes.login:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.publicHome),
          PublicHomePage(
            cityInsightsController: dependencies.cityInsightsController,
            environment: dependencies.environment,
            journeyContextController: dependencies.journeyContextController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            locationController: dependencies.locationController,
            redirectMessage: 'Faça login para acessar essa área.',
          ),
        );
      case AppRoutes.onboarding:
        unawaited(dependencies.catalogRepository.getCountries());
        return _buildRoute(
          settings,
          OnboardingPage(
            authController: dependencies.authController,
            catalogRepository: dependencies.catalogRepository,
          ),
        );
      case AppRoutes.migrationQuestionnaire:
        return _buildRoute(
          settings,
          QuestionPage(
            controller: dependencies.migrationQuestionnaireController,
            locationController: dependencies.locationController,
            citiesController: dependencies.citiesController,
          ),
        );
      case AppRoutes.migrationStart:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.publicHome),
          PublicHomePage(
            cityInsightsController: dependencies.cityInsightsController,
            environment: dependencies.environment,
            journeyContextController: dependencies.journeyContextController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            locationController: dependencies.locationController,
          ),
        );
      case AppRoutes.locationPermission:
        final args = settings.arguments is LocationPermissionScreenArgs
            ? settings.arguments! as LocationPermissionScreenArgs
            : const LocationPermissionScreenArgs();
        return _buildRoute(
          settings,
          LocationPermissionScreen(
            locationController: dependencies.locationController,
            args: args,
          ),
        );
      case AppRoutes.settings:
        return _buildRoute(
          settings,
          AppSettingsPage(
            localeController: dependencies.localeController,
            themeController: dependencies.themeController,
          ),
        );
      case AppRoutes.migrationPlanResult:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.migrationResultReveal),
          MigrationResultRevealPage(
            controller: dependencies.migrationQuestionnaireController,
            citiesController: dependencies.citiesController,
          ),
        );
      case AppRoutes.migrationResultReveal:
        return _buildRoute(
          settings,
          MigrationResultRevealPage(
            controller: dependencies.migrationQuestionnaireController,
            citiesController: dependencies.citiesController,
          ),
        );
      case AppRoutes.migrationPlanCopilot:
        final currentPlan =
            dependencies.migrationQuestionnaireController.generatedPlan;
        if (currentPlan == null || !currentPlan.isCityConfirmed) {
          return _buildRoute(
            const RouteSettings(name: AppRoutes.migrationResultReveal),
            MigrationResultRevealPage(
              controller: dependencies.migrationQuestionnaireController,
              citiesController: dependencies.citiesController,
            ),
          );
        }
        return _buildRoute(
          settings,
          MigrationPlanCopilotPage(
            controller: dependencies.migrationQuestionnaireController,
            exchangeRatesService: dependencies.copilotExchangeRatesService,
            citiesController: dependencies.citiesController,
            journeyContextController: dependencies.journeyContextController,
            locationController: dependencies.locationController,
          ),
        );
      case AppRoutes.authenticatedHome:
        return _buildRoute(
          settings,
          HomePage(
            environment: dependencies.environment,
            authController: dependencies.authController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
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
          MigrationPlanSavePage(
            controller: dependencies.migrationQuestionnaireController,
          ),
        );
      default:
        return _buildRoute(
          const RouteSettings(name: AppRoutes.publicHome),
          PublicHomePage(
            cityInsightsController: dependencies.cityInsightsController,
            environment: dependencies.environment,
            journeyContextController: dependencies.journeyContextController,
            citiesController: dependencies.citiesController,
            migrationQuestionnaireController:
                dependencies.migrationQuestionnaireController,
            locationController: dependencies.locationController,
            redirectMessage: 'Página não encontrada.',
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
        transitionsBuilder:
            (context, animation, secondaryAnimation, pageChild) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );

              return FadeTransition(
                opacity: Tween<double>(begin: 0.94, end: 1).animate(curved),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: pageChild,
                ),
              );
            },
      );
    }

    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}

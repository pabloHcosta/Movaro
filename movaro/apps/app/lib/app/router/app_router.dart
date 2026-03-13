import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/auth/presentation/pages/login_page.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/presentation/pages/cities_explore_page.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_detail_page.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_search_page.dart';
import 'package:movaro_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/countries_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/explore/presentation/pages/explore_page.dart';
import 'package:movaro_app/features/home/presentation/pages/home_page.dart';
import 'package:movaro_app/features/home/presentation/pages/favorites_page.dart';
import 'package:movaro_app/features/home/presentation/pages/public_home_page.dart';
import 'package:movaro_app/features/intro/presentation/pages/intro_page.dart';
import 'package:movaro_app/features/journey/presentation/pages/journey_setup_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_result_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_copilot_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/migration_plan_save_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/question_page.dart';
import 'package:movaro_app/features/shared/presentation/pages/protected_placeholder_page.dart';
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
  });

  final AppEnvironment environment;
  final AuthController authController;
  final CatalogRepository catalogRepository;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final CopilotExchangeRatesService copilotExchangeRatesService;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.splash;

    if (AppRoutes.privatePaths.contains(routeName) &&
        !authController.isAuthenticated) {
      authController.rememberPendingRoute(routeName);
      return _buildRoute(
        const RouteSettings(name: AppRoutes.login),
        LoginPage(authController: authController),
      );
    }

    const journeyRequiredPaths = <String>{
      AppRoutes.publicHome,
      AppRoutes.favorites,
      AppRoutes.explore,
      AppRoutes.documentationGuide,
      AppRoutes.cities,
      AppRoutes.citiesSearch,
      AppRoutes.countries,
      AppRoutes.migrationQuestionnaire,
      AppRoutes.migrationPlanResult,
      AppRoutes.migrationPlanCopilot,
    };

    if (journeyRequiredPaths.contains(routeName) &&
        !journeyContextController.hasSelectedJourney) {
      return _buildRoute(
        const RouteSettings(name: AppRoutes.journeySetup),
        JourneySetupPage(
          catalogRepository: catalogRepository,
          journeyContextController: journeyContextController,
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
        ),
      );
    }

    if (AppRoutes.isCityDetailRoute(routeName)) {
      final cityId = routeName.replaceFirst('/cities/', '');
      final args = settings.arguments;
      final selectForPlan =
          args is Map<String, dynamic> && args['selectForPlan'] == true;
      unawaited(citiesController.prefetchCityDetail(cityId));
      unawaited(citiesController.prefetchMethodology());
      return _buildRoute(
        settings,
        CityDetailPage(
          cityId: cityId,
          citiesController: citiesController,
          migrationQuestionnaireController: migrationQuestionnaireController,
          selectForPlan: selectForPlan,
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
          ),
        );
      case AppRoutes.publicHome:
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          PublicHomePage(
            journeyContextController: journeyContextController,
            citiesController: citiesController,
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.favorites:
        unawaited(citiesController.prefetchCatalog());
        return _buildRoute(
          settings,
          FavoritesPage(
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
          ),
        );
      case AppRoutes.explore:
        return _buildRoute(
          settings,
          ExplorePage(
            migrationQuestionnaireController: migrationQuestionnaireController,
          ),
        );
      case AppRoutes.documentationGuide:
        return _buildRoute(
          settings,
          DocumentationGuidePage(
            exchangeRatesService: copilotExchangeRatesService,
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
          ),
        );
      case AppRoutes.cities:
        unawaited(citiesController.prefetchExplore());
        return _buildRoute(
          settings,
          CitiesExplorePage(citiesController: citiesController),
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
        if (authController.isAuthenticated) {
          final nextRoute = authController.resolveRouteAfterLogin();
          return onGenerateRoute(RouteSettings(name: nextRoute));
        }

        return _buildRoute(settings, LoginPage(authController: authController));
      case AppRoutes.onboarding:
        unawaited(catalogRepository.getCountries());
        return _buildRoute(
          settings,
          OnboardingPage(
            authController: authController,
            catalogRepository: catalogRepository,
          ),
        );
      case AppRoutes.migrationQuestionnaire:
        migrationQuestionnaireController.resetFlow();
        return _buildRoute(
          settings,
          QuestionPage(controller: migrationQuestionnaireController),
        );
      case AppRoutes.migrationPlanResult:
        return _buildRoute(
          settings,
          MigrationPlanResultPage(controller: migrationQuestionnaireController),
        );
      case AppRoutes.migrationPlanCopilot:
        if (migrationQuestionnaireController.generatedPlan?.isCityConfirmed !=
            true) {
          return _buildRoute(
            const RouteSettings(name: AppRoutes.migrationPlanResult),
            MigrationPlanResultPage(
              controller: migrationQuestionnaireController,
            ),
          );
        }
        return _buildRoute(
          settings,
          MigrationPlanCopilotPage(
            controller: migrationQuestionnaireController,
            exchangeRatesService: copilotExchangeRatesService,
            citiesController: citiesController,
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
          ),
        );
    }
  }

  Route<void> _buildRoute(RouteSettings settings, Widget child) {
    const primaryNavRoutes = <String>{
      AppRoutes.publicHome,
      AppRoutes.favorites,
      AppRoutes.migrationPlanCopilot,
    };

    if (primaryNavRoutes.contains(settings.name)) {
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final fade = Tween<double>(begin: 0.72, end: 1).animate(curved);
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );
    }

    return MaterialPageRoute<void>(builder: (_) => child, settings: settings);
  }
}

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const intro = '/intro';
  static const journeySetup = '/journey/setup';
  static const publicHome = '/home';
  static const explore = '/explore';
  static const documentationGuide = '/documentation';
  static const documentationTopic = '/documentation/topic';
  static const cities = '/cities';
  static const citiesSearch = '/cities/search';
  static const countries = '/countries';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const migrationQuestionnaire = '/migration/questionnaire';
  static const migrationPlanResult = '/migration/result';
  static const migrationPlanCopilot = '/migration/copilot';
  static const authenticatedHome = '/profile';
  static const communityCreate = '/community/create';
  static const migrationSave = '/migration/save';

  static const publicPaths = <String>{
    splash,
    intro,
    journeySetup,
    publicHome,
    explore,
    documentationGuide,
    documentationTopic,
    cities,
    citiesSearch,
    countries,
    login,
    migrationQuestionnaire,
    migrationPlanResult,
    migrationPlanCopilot,
  };

  static const privatePaths = <String>{
    onboarding,
    authenticatedHome,
    communityCreate,
    migrationSave,
  };

  static String cityDetail(String id) => '/cities/$id';

  static bool isCityDetailRoute(String route) {
    return route.startsWith('/cities/') && route != citiesSearch;
  }
}

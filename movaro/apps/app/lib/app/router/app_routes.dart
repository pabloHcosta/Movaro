class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const intro = '/intro';
  static const journeySetup = '/journey/setup';
  static const publicHome = '/home';
  static const plan = '/plan';
  static const tools = '/tools';
  static const more = '/more';
  static const favorites = '/favorites';
  static const cityComparison = '/favorites/compare';
  static const explore = '/explore';
  static const documentationGuide = '/documentation';
  static const documentationTopic = '/documentation/topic';
  static const info = '/info';
  static const settings = '/settings';
  static const cities = '/cities';
  static const citiesSearch = '/cities/search';
  static const countries = '/countries';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const locationPermission = '/location/permission';
  static const migrationStart = '/migration/start';
  static const migrationQuestionnaire = '/migration/questionnaire';
  static const migrationPlanResult = '/migration/result';
  static const migrationResultReveal = '/migration/result/reveal';
  static const migrationPlanCopilot = '/migration/copilot';
  static const authenticatedHome = '/profile';
  static const communityCreate = '/community/create';
  static const migrationSave = '/migration/save';
  static const phrasebook = '/language/phrasebook';
  static const proposalSafetyCheck = '/tools/safety-check';

  static const publicPaths = <String>{
    splash,
    intro,
    journeySetup,
    publicHome,
    plan,
    tools,
    more,
    favorites,
    cityComparison,
    explore,
    documentationGuide,
    documentationTopic,
    info,
    settings,
    cities,
    citiesSearch,
    countries,
    login,
    locationPermission,
    migrationStart,
    migrationQuestionnaire,
    migrationPlanResult,
    migrationResultReveal,
    migrationPlanCopilot,
    phrasebook,
    proposalSafetyCheck,
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

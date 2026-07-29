// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Movaro';

  @override
  String get homeEnvironmentLabel => 'Current environment';

  @override
  String environmentValue(String environment) {
    return '$environment';
  }

  @override
  String get splashLoadingLabel => 'Preparing your path';

  @override
  String get splashHeroTitle => 'Your next step starts with clarity.';

  @override
  String get splashHeroBody =>
      'Preparing cities, costs, and guidance for your next step.';

  @override
  String get splashInitializingLabel => 'Initializing your experience';

  @override
  String get loadingCountriesLabel => 'Loading countries';

  @override
  String get loadingCitiesCatalogLabel => 'Loading city catalog';

  @override
  String get journeySetupPageTitle => 'Choose your route';

  @override
  String get journeySetupHeroTitle =>
      'Start by defining where you are coming from and where you want to go';

  @override
  String get journeySetupHeroBody =>
      'Movaro uses this choice to shape the right experience for you. Today, the beta is open for Argentina -> Brazil, but the structure is already built to grow globally.';

  @override
  String get journeyOriginTitle => 'Origin country';

  @override
  String get journeyOriginBody =>
      'Choose the country you are leaving from. This helps contextualize language, paperwork, and adaptation.';

  @override
  String get journeyDestinationTitle => 'Destination country';

  @override
  String get journeyDestinationBody =>
      'Choose the country you want to evaluate. The home screen and your plan will reflect that destination.';

  @override
  String get journeySummaryTitle => 'Your current route';

  @override
  String journeySummaryValue(String origin, String destination) {
    return '$origin -> $destination';
  }

  @override
  String get journeySummaryPlaceholder =>
      'Select your origin and destination to continue.';

  @override
  String get journeyAvailabilityNote =>
      'Right now, only the Argentina -> Brazil route is fully available. Other countries are already visible to signal the product’s global direction.';

  @override
  String get journeyContinueAction => 'Continue with this route';

  @override
  String get journeyAvailableNowLabel => 'Available now';

  @override
  String get journeyComingSoonLabel => 'Coming soon';

  @override
  String get journeyChangeAction => 'Change route';

  @override
  String get publicHomeHeadline => 'Plan your move with more clarity';

  @override
  String get publicHomeDescription =>
      'Understand your options in a few steps before deciding what to save.';

  @override
  String get publicHomeScopeBadge => 'Today: Argentina -> Brazil';

  @override
  String get publicHomeFocusedDescription =>
      'Movaro is currently designed for people evaluating a move from Argentina to Brazil. Instead of showing everything at once, it helps you explore useful starting points.';

  @override
  String publicHomeSelectedJourneyDescription(
    String origin,
    String destination,
  ) {
    return 'Movaro will organize your experience for the $origin -> $destination journey. You start with what matters now and go deeper only when it helps.';
  }

  @override
  String get publicHomePrimaryQuestionTitle => 'Start with a useful question';

  @override
  String get publicHomePrimaryQuestionBody =>
      'You can begin with a guided plan, a city comparison, or a quick overview of what the product does.';

  @override
  String get publicHomeTrustFastTitle => 'Fast start';

  @override
  String get publicHomeTrustFastBody =>
      'You can get started without a long form or an initial barrier.';

  @override
  String get publicHomeTrustGuestTitle => 'No login for now';

  @override
  String get publicHomeTrustGuestBody =>
      'Explore as a guest and sign in only when saving becomes useful.';

  @override
  String get publicHomeTrustFocusTitle => 'Clear scope';

  @override
  String get publicHomeTrustFocusBody =>
      'This beta is focused on the Argentina -> Brazil corridor.';

  @override
  String publicHomeTrustSelectedBody(String origin, String destination) {
    return 'Your navigation is now contextualized for $origin -> $destination, without surfacing irrelevant content before you choose.';
  }

  @override
  String get publicHomeFirstStepTitle => 'Choose your first step';

  @override
  String get publicHomeFirstStepBody =>
      'The home screen is here to guide your entry point. Deeper content comes later, inside the path you choose.';

  @override
  String get publicHomeSecondaryTitle => 'Documentation comes later';

  @override
  String get publicHomeSecondaryBody =>
      'The Brazil practical guide is still available, but as support. It makes more sense after you understand whether you want a guided plan or a city comparison.';

  @override
  String get publicHomeSecondaryGenericBody =>
      'When a new destination becomes available, documentation and local details should appear as contextual support, not as noise on the first screen.';

  @override
  String get publicHomeExploreAction => 'Explore more';

  @override
  String get publicHomeQuestionnaireAction => 'Build my plan';

  @override
  String get publicHomeLoginAction => 'Sign in when I need to save';

  @override
  String get publicHomeGuestSectionTitle => 'You can start in guest mode';

  @override
  String get publicHomeGuestSectionBody =>
      'You can explore all of this without signing in. Sign-in only appears when it makes sense to save something personal.';

  @override
  String get publicHomeBetaSectionBody =>
      'This beta already opens what is ready: exploration, practical documentation, and your first plan.';

  @override
  String get publicHomeHowItWorksAction => 'See how it works';

  @override
  String get publicHomeCitiesTitle => 'Discover cities';

  @override
  String get publicHomeCitiesBody =>
      'See suggestions based on cost, work, and popularity among Argentinians.';

  @override
  String get publicHomeCitiesAction => 'See cities';

  @override
  String get publicHomeQuestionsTitle => 'Practical guide';

  @override
  String get publicHomeQuestionsBody =>
      'Open the guide to understand documents, healthcare, housing, and first costs without scattered research.';

  @override
  String get publicHomeQuestionsAction => 'Clear my doubts';

  @override
  String get homeHeroWelcomeDefault => 'Welcome to Movaro';

  @override
  String get homeHeroWelcomeBack => 'Continue where you left off';

  @override
  String homeHeroGreetingMorning(Object name) {
    return 'Good morning, $name';
  }

  @override
  String homeHeroGreetingAfternoon(Object name) {
    return 'Good afternoon, $name';
  }

  @override
  String homeHeroGreetingEvening(Object name) {
    return 'Good evening, $name';
  }

  @override
  String get homeHeroSubtitleNoPlan => 'Plan your move';

  @override
  String get homeHeroSubtitleWithPlan => 'Continue where you left off';

  @override
  String get homeHeroOriginLabel => 'Origin';

  @override
  String get homeHeroDestinationLabel => 'Destination';

  @override
  String get homeHeroNoPlanTitle => 'Your migration plan in 3 steps';

  @override
  String get homeHeroNoPlanBody =>
      'Answer a few quick questions and review cities that may fit your profile.';

  @override
  String get homeHeroStepQuestionnaire => 'Answer quick questions';

  @override
  String get homeHeroStepCity => 'Review possible cities';

  @override
  String get homeHeroStepGuide => 'Execute with guide';

  @override
  String get homeHeroStartAction => 'Build my plan -> takes ~5 min';

  @override
  String get homeHeroPlanActiveBadge => 'Active plan';

  @override
  String get homeHeroSelectedCityEyebrow => 'Your chosen city';

  @override
  String get homeHeroProgressLabel => 'Overall plan progress';

  @override
  String get homeHeroStageMetricLabel => 'STAGE';

  @override
  String get homeHeroStageTotalValue => '5';

  @override
  String get homeHeroCostMetricLabel => 'COST';

  @override
  String get homeHeroClimateMetricLabel => 'CLIMATE';

  @override
  String get homeHeroNextStepLabel => 'NEXT STEP';

  @override
  String get homeHeroContinueAction => 'Continue plan ->';

  @override
  String get homeHeroDiscoverCitiesBody => 'Cost, jobs, and quality of life';

  @override
  String homeHeroDiscoverCitiesBodyWithCity(Object city) {
    return 'See alternatives to $city';
  }

  @override
  String get homeHeroExploreAction => 'Explore ->';

  @override
  String get homeHeroGuideBody => 'Documents and arrival in Brazil';

  @override
  String get homeHeroOpenGuideAction => 'Open guide ->';

  @override
  String get homeHeroOpenShortAction => 'Open ->';

  @override
  String get homeHeroExploreSectionTitle => 'Explore';

  @override
  String get homeHeroPlanCompleteTask => 'Review completed plan';

  @override
  String get publicHomePlanTitle => 'Build my plan';

  @override
  String get publicHomePlanBody =>
      'Answer a few questions and get a clear starter plan with better suggestions.';

  @override
  String get publicHomeJourneyDraftTitle =>
      'Start your plan with your destination already set';

  @override
  String publicHomeJourneyDraftBody(Object destination) {
    return 'You\'re heading toward $destination. Next, answer a few short questions and tell us where you\'re coming from so Movaro can generate the right plan.';
  }

  @override
  String get publicHomeStoriesTitle => 'Read real experiences';

  @override
  String get publicHomeStoriesBody =>
      'Understand what other people are looking for before deciding your next step.';

  @override
  String get publicHomeStoriesAction => 'Explore stories';

  @override
  String get decisionSupportTitle =>
      'Start with the question that matters most';

  @override
  String get decisionSupportBody =>
      'People moving abroad usually want quick first answers about language, cost, paperwork, and work. Movaro should make that obvious.';

  @override
  String get decisionSupportLanguageTitle =>
      'Can I manage daily life there without Portuguese?';

  @override
  String get decisionSupportLanguageBody =>
      'Use the language adaptation signal to find places that feel easier for a Spanish speaker at the beginning.';

  @override
  String get decisionSupportCostTitle => 'Will daily life feel too expensive?';

  @override
  String get decisionSupportCostBody =>
      'Compare cities through cost and rent before going deep into a destination.';

  @override
  String get decisionSupportPaperworkTitle =>
      'What are the first paperwork steps?';

  @override
  String get decisionSupportPaperworkBody =>
      'The guided plan turns uncertainty into a short first checklist instead of a long research spiral.';

  @override
  String get decisionSupportWorkTitle =>
      'Where should I start if I need work or structure?';

  @override
  String get decisionSupportWorkBody =>
      'The questionnaire and city ranking help narrow the search to places with a better early fit.';

  @override
  String get commonNeedsTitle => 'If you still do not know where to start';

  @override
  String get commonNeedsBody =>
      'These are the most useful shortcuts for someone arriving with mixed doubts and wanting clarity before deciding.';

  @override
  String get commonNeedCompareCostTitle =>
      'I want to compare cost and rent first';

  @override
  String get commonNeedCompareCostBody =>
      'Go straight to cities and use cost, rent, language, and work signals as your first read.';

  @override
  String get commonNeedDocumentsTitle =>
      'I need to understand documents before anything else';

  @override
  String get commonNeedDocumentsBody =>
      'The documentation guide summarizes CPF, registration, stay, work, and banking with official sources and simpler language.';

  @override
  String get commonNeedDirectionTitle =>
      'I still do not know which path fits me';

  @override
  String get commonNeedDirectionBody =>
      'The guided plan reduces uncertainty to one first city and a short order of first steps.';

  @override
  String get commonNeedExploreAllTitle =>
      'I want to see everything without getting stuck';

  @override
  String get commonNeedExploreAllBody =>
      'Explore brings cities, documentation, and other paths together in one place.';

  @override
  String get explorePageTitle => 'Explore';

  @override
  String get explorePublicFeaturesTitle => 'Public exploration';

  @override
  String get explorePublicFeaturesDescription =>
      'Discover cities and countries that are visible to every guest user.';

  @override
  String get exploreDocumentationTitle => 'Practical life in Brazil';

  @override
  String get exploreDocumentationDescription =>
      'Understand documents, health, driving, work, and banking in simpler language.';

  @override
  String get exploreDocumentationAction => 'See documentation';

  @override
  String get exploreCitiesAction => 'View cities';

  @override
  String get exploreCountriesAction => 'View countries';

  @override
  String get exploreCommunityTitle => 'Community content';

  @override
  String get exploreCommunityDescription =>
      'Community content remains public, but posting requires authentication.';

  @override
  String get exploreCreatePostAction => 'Create post';

  @override
  String get exploreIntroTitle => 'How to use Movaro';

  @override
  String get exploreIntroDescription =>
      'Before diving into the app, see in under a minute what Movaro helps with and what is already available in this beta.';

  @override
  String get exploreIntroAction => 'Open introduction';

  @override
  String get exploreChecklistTitle => 'Your initial plan';

  @override
  String get exploreChecklistDescription =>
      'Guests can answer a short flow and generate an initial migration plan before signing in.';

  @override
  String get exploreQuestionnaireAction => 'Answer quick questions';

  @override
  String get exploreTrailsEyebrow => 'Three clear paths';

  @override
  String get exploreTrailsTitle => 'Choose the kind of help you need right now';

  @override
  String get exploreTrailsBody =>
      'Instead of showing everything at once, the app now splits the experience into three tracks: decide the city, understand practical bureaucracy, and prepare the move.';

  @override
  String get exploreTrailCitiesTitle => 'Decide the city';

  @override
  String get exploreTrailCitiesBody =>
      'Compare cities and use coast, cost, work, language, and housing signals to see which context fits you better.';

  @override
  String get exploreTrailDocsTitle => 'Understand practical bureaucracy';

  @override
  String get exploreTrailDocsBody =>
      'See rent, SUS, CPF, work, driving, and initial costs in clearer sections with less noise.';

  @override
  String get exploreTrailPrepTitle => 'Prepare the move';

  @override
  String get exploreTrailPrepBodyStart =>
      'If you have not confirmed a city yet, start with the initial plan to organize the decision.';

  @override
  String get exploreTrailPrepBodyReady =>
      'Since you have already confirmed a city, this track focuses on checklist, documents, housing, and arrival.';

  @override
  String get exploreSavePlanAction => 'Save plan';

  @override
  String get exploreUnifiedTitle =>
      'Explore cities, content, and your next move in one place';

  @override
  String get exploreUnifiedBody =>
      'Use this area to reinforce your decision, review the city options that still matter, and open the practical content that matches your route.';

  @override
  String get explorePlanSectionTitle => 'Based on your plan';

  @override
  String get explorePlanSectionBody =>
      'Resume the current plan, reopen the leading city, or jump straight into the most useful guide for your next step.';

  @override
  String get exploreCitiesSectionTitle => 'Discover other cities';

  @override
  String get exploreCitiesSectionBody =>
      'Keep comparing before locking the decision. These cities are strong alternatives for your current route and profile.';

  @override
  String get exploreContentSectionTitle => 'Useful content';

  @override
  String get exploreContentSectionBody =>
      'Open the practical guidance that usually matters next: documents, housing, and work.';

  @override
  String exploreRouteLabel(Object origin, Object destination) {
    return 'Journey: $origin -> $destination';
  }

  @override
  String get cityInsightsSectionTitle => 'Discover more about your new city';

  @override
  String get cityInsightsSectionBody =>
      'Short, curated content to reinforce the decision, picture daily life, and learn something useful without leaving the plan context.';

  @override
  String get cityInsightsShowMoreAction => 'See more';

  @override
  String get cityInsightsRefreshAction => 'Refresh';

  @override
  String get cityInsightsEmptyState => 'There are no fresh city insights yet.';

  @override
  String get cityInsightsExploreAction => 'Explore city';

  @override
  String get cityInsightsTypeLifestyle => 'Lifestyle';

  @override
  String get cityInsightsTypeCost => 'Cost';

  @override
  String get cityInsightsTypeHousing => 'Housing';

  @override
  String get cityInsightsTypeWork => 'Work';

  @override
  String get cityInsightsTypePractical => 'Practical tip';

  @override
  String get cityInsightsTypeMotivation => 'Motivation';

  @override
  String exploreDestinationLabel(Object destination) {
    return 'Destination selected: $destination';
  }

  @override
  String get exploreNoJourneyLabel =>
      'Set a destination to make exploration more relevant.';

  @override
  String get explorePlanEmptyTitle => 'Start a plan before you go deeper';

  @override
  String get explorePlanEmptyBody =>
      'Choose your destination, answer a few questions, and let Movaro turn exploration into a practical direction.';

  @override
  String get explorePlanReadyTitle => 'Your plan is ready to continue';

  @override
  String explorePlanReadyBody(Object city) {
    return '$city is already confirmed. Open your checklist and keep moving through the next actions.';
  }

  @override
  String get explorePlanDraftTitle => 'Your plan still needs a closer review';

  @override
  String get explorePlanDraftBody =>
      'You already have a draft. Reopen the result and review the city options before moving into checklist mode.';

  @override
  String explorePlanDraftBodyWithCity(Object city) {
    return '$city is one of the leading options right now. Reopen the result and compare it again when you are ready.';
  }

  @override
  String get exploreRecommendedCityTitle => 'City to review now';

  @override
  String get exploreRecommendedCityBody =>
      'Open the city details to review cost, quality of life, and fit with your plan.';

  @override
  String get exploreOpenCityAction => 'Open city';

  @override
  String get exploreOpenContentAction => 'Open guide';

  @override
  String get explorePlanDocsBody =>
      'Documents usually unlock the next part of the move faster than more comparison.';

  @override
  String get exploreContentDocumentsBody =>
      'See CPF, registration, banking, and legal stay with less noise and clearer routing.';

  @override
  String get exploreContentHousingBody =>
      'Review rent pressure, guarantees, deposits, and first-landing decisions before choosing a neighborhood.';

  @override
  String get exploreContentWorkBody =>
      'Check work setup, contribution paths, and what to validate before treating income as solved.';

  @override
  String get documentationPageTitle => 'Guide';

  @override
  String get documentationHeroEyebrow => 'Practical guide';

  @override
  String get documentationHeroTitle =>
      'Understand practical life in Brazil with more clarity';

  @override
  String get documentationHeroDescription =>
      'Type a question or choose a topic. Movaro helps you find the right guidance and guide across documents, health, work, housing, mobility, and early costs.';

  @override
  String get documentationFocusTitle => 'Useful for your current journey';

  @override
  String documentationFocusBody(Object origin, Object destination) {
    return 'These categories are the strongest starting point for moving from $origin to $destination.';
  }

  @override
  String documentationFocusBodyDestination(Object destination) {
    return 'These categories are a strong starting point for your route into $destination.';
  }

  @override
  String get documentationFocusBodyDefault =>
      'Open the category that removes the biggest blocker first: documents, housing, or work.';

  @override
  String get documentationHeroStepOneTitle => 'Type a question';

  @override
  String get documentationHeroStepOneBody =>
      'You can search in English, Portuguese, or Spanish.';

  @override
  String get documentationHeroStepTwoTitle => 'Choose a topic';

  @override
  String get documentationHeroStepTwoBody =>
      'Filter by documents, health, work, housing, mobility, and costs.';

  @override
  String get documentationHeroStepThreeTitle => 'Open the right guide';

  @override
  String get documentationHeroStepThreeBody =>
      'Jump into a quick answer or the full block when you need more context.';

  @override
  String get documentationSearchLabel => 'What do you need to understand?';

  @override
  String get documentationSearchHint =>
      'Ex.: can I work with visitor status? / CPF / banco / salud / costs';

  @override
  String get documentationSearchSupport =>
      'You can search in English, Portuguese, or Spanish.';

  @override
  String get documentationSearchPanelTitle => 'Start with search or a topic';

  @override
  String get documentationSearchPanelBody =>
      'Type your question or tap a topic to reach the right block faster.';

  @override
  String get documentationGuideHideNextTime => 'Do not show again';

  @override
  String get documentationGuideStepsLabel => '3 steps';

  @override
  String get documentationGuideDismissAction => 'Not now';

  @override
  String get documentationGuidePrimaryAction => 'Got it';

  @override
  String get documentationGuideModalTitle => 'Use the practical guide faster';

  @override
  String get documentationGuideModalBody =>
      'Choose the country you want to review, search a topic or question, and open the section that removes the next blocker.';

  @override
  String get documentationGuideModalStepCountryTitle => 'Choose the country';

  @override
  String get documentationGuideModalStepCountryBody =>
      'The guide opens with your destination country when available, but you can switch countries at any time.';

  @override
  String get documentationGuideModalStepSearchTitle => 'Search by need';

  @override
  String get documentationGuideModalStepSearchBody =>
      'Type a topic, document, or everyday question to jump to the most relevant section.';

  @override
  String get documentationGuideModalStepOpenTitle => 'Open the section';

  @override
  String get documentationGuideModalStepOpenBody =>
      'Use filters or results to go straight into documents, housing, health, work, driving, or costs.';

  @override
  String get documentationGuideNoPlanTitle => 'No plan selected yet';

  @override
  String documentationGuideNoPlanBody(Object country) {
    return 'You can still use the practical guide. We loaded $country for now, and you can switch countries whenever you need.';
  }

  @override
  String documentationGuideCountryPendingTitle(Object country) {
    return '$country guide is not available yet';
  }

  @override
  String get documentationGuideCountryPendingBody =>
      'Movaro currently has practical guide coverage for Brazil. Choose Brazil to continue browsing the available guidance.';

  @override
  String get documentationGuideUsingPlanLabel => 'From your plan';

  @override
  String get documentationGuideManualCountryLabel => 'Manual country';

  @override
  String get documentationGuideCountryLabel => 'Guide country';

  @override
  String documentationGuideCountryBodyFromPlan(Object country) {
    return 'You are browsing practical content for $country based on your plan destination.';
  }

  @override
  String documentationGuideCountryBodyManual(Object country) {
    return 'Choose the country you want to review. For now, you are viewing practical content for $country.';
  }

  @override
  String documentationSearchResultsCount(int count) {
    return '$count items found';
  }

  @override
  String get documentationSearchResultsHint =>
      'Tap an item to open the topic or jump straight to filtered results.';

  @override
  String get documentationFilterAll => 'All';

  @override
  String get documentationQuickRoutesTitle => 'Topic shortcuts';

  @override
  String get documentationQuickRoutesBody =>
      'Swipe and jump straight into the right block if you already know which topic you want to solve.';

  @override
  String get documentationQuickChoicesTitle => 'Quick choices';

  @override
  String get documentationQuickChoicesBody =>
      'Filter by topic or use ready-made questions to reach the right block faster.';

  @override
  String get documentationResultsTitle => 'Guide results';

  @override
  String get documentationResultsBody =>
      'Start with a quick answer or open the full topic when you need more depth.';

  @override
  String get documentationResultsFilteredBody =>
      'Search mixes quick answers and full topic blocks to shorten the path to the right information.';

  @override
  String get documentationViewMatchesAction => 'View';

  @override
  String get documentationNoResultsTitle => 'Nothing matched that term';

  @override
  String get documentationNoResultsBody =>
      'Try CPF, registration, work, visa, health, rent, or costs.';

  @override
  String get documentationQuickStepCpf => 'CPF';

  @override
  String get documentationQuickStepRegistration => 'Registration';

  @override
  String get documentationQuickStepStay => 'Stay';

  @override
  String get documentationQuickStepWorkBank => 'Work and banking';

  @override
  String get documentationQuickStepCitizenship => 'Naturalization';

  @override
  String get documentationQuickStepHealth => 'Health';

  @override
  String get documentationQuickStepDriving => 'Driving';

  @override
  String get documentationQuickStepWork => 'Work';

  @override
  String get documentationQuickStepRetirement => 'Retirement';

  @override
  String get documentationOfficialSourceLabel => 'Official source';

  @override
  String get documentationPathsTitle =>
      'Start with the question that matters most';

  @override
  String get documentationPathsBody =>
      'Instead of reading everything, pick the area that matters most right now. The rest stays available when you need more depth.';

  @override
  String get documentationHousingArrivalSectionTitle => 'Housing and arrival';

  @override
  String get documentationHousingArrivalSectionBody =>
      'See rent, upfront entry cost, guarantees, soft landing, and how to avoid the first mistakes.';

  @override
  String get documentationNavigatorTitle => 'Where to find each topic';

  @override
  String get documentationNavigatorBody =>
      'Use these blocks to find rent, SUS, work, driving, and costs faster without reading the full page at once.';

  @override
  String get documentationNavigatorHousing => 'Housing and rent';

  @override
  String get documentationNavigatorHealth => 'SUS and health';

  @override
  String get documentationNavigatorWork => 'Work and income';

  @override
  String get documentationNavigatorDriving => 'Driving in Brazil';

  @override
  String get documentationNavigatorCosts => 'Initial costs';

  @override
  String get documentationNavigatorDocuments => 'Core documents';

  @override
  String get documentationPathDocumentsTitle => 'Documents and legal stay';

  @override
  String get documentationPathDocumentsBody =>
      'Argentina → Brazil route checklist: travel ID, CPF, residence, CRNM, and the supporting documents that help you carry out your plan.';

  @override
  String get documentationPathHealthTitle => 'Health in daily life';

  @override
  String get documentationPathHealthBody =>
      'Understand when it makes sense to use SUS, a local health post, a hospital, or a private plan.';

  @override
  String get documentationPathDrivingTitle => 'Driving and mobility';

  @override
  String get documentationPathDrivingBody =>
      'See whether your foreign license helps at the beginning and when you should check with Detran.';

  @override
  String get documentationPathWorkTitle => 'Work and contributions';

  @override
  String get documentationPathWorkBody =>
      'Understand formal employment, PJ work, and how each one connects to public retirement contributions.';

  @override
  String get documentationPathCostsTitle => 'Early costs';

  @override
  String get documentationPathCostsBody =>
      'Read approximate costs in reais, pesos, and dollars without confusing a reference value with a final price.';

  @override
  String get documentationOpenTopicAction => 'Open topic';

  @override
  String get documentationQuickAnswersTitle =>
      'Quick answers for the most common questions';

  @override
  String get documentationQuickAnswersBody =>
      'Before opening every card, start with these short answers. If one already answers your question, you save time.';

  @override
  String get documentationAnswerWorkQuestion =>
      'Can I work with visitor status alone?';

  @override
  String get documentationAnswerWorkAnswer =>
      'No. Formal work requires a compatible migration status and regular registration.';

  @override
  String get documentationAnswerTravelDocQuestion =>
      'Do I need a passport to travel from Argentina to Brazil?';

  @override
  String get documentationAnswerTravelDocAnswer =>
      'Not necessarily. Argentine citizens can travel to Brazil with a valid physical DNI in good condition and with a photo that clearly identifies the holder. A proof of document renewal or issuance is not enough.';

  @override
  String get documentationAnswerCpfQuestion =>
      'Does CPF alone solve banking and contracts?';

  @override
  String get documentationAnswerCpfAnswer =>
      'No. CPF helps a lot, but it usually does not replace a regular migration document.';

  @override
  String get documentationAnswerRegistrationQuestion =>
      'Is migration registration completed immediately?';

  @override
  String get documentationAnswerRegistrationAnswer =>
      'No. The protocol already matters while the CRNM is being issued, so the process does not depend on an instant card.';

  @override
  String get documentationAnswerStayQuestion =>
      'Is staying longer as a visitor the same as living regularly?';

  @override
  String get documentationAnswerStayAnswer =>
      'No. For someone who plans to live in Brazil, regular residence is usually the right path.';

  @override
  String get documentationAnswerSusQuestion =>
      'Can a foreign national use SUS?';

  @override
  String get documentationAnswerSusAnswer =>
      'Yes. SUS is universal in Brazil, and the Ministry of Health explicitly reaffirms access for foreign nationals.';

  @override
  String get documentationAnswerSusCardQuestion =>
      'Do I need a SUS card or CPF before getting care?';

  @override
  String get documentationAnswerSusCardAnswer =>
      'Not necessarily. Registration helps with follow-up care, but initial access, and especially urgent care, should not depend on having everything ready.';

  @override
  String get documentationAnswerForeignLicenseQuestion =>
      'Can I drive at first with my foreign license?';

  @override
  String get documentationAnswerForeignLicenseAnswer =>
      'In general, yes, for a limited period, with a valid document and subject to the applicable agreement. After that, it is better to confirm with the state Detran.';

  @override
  String get documentationAnswerBrazilianLicenseQuestion =>
      'Can I later get a Brazilian license?';

  @override
  String get documentationAnswerBrazilianLicenseAnswer =>
      'Yes, if you are regular in the country and meet Detran requirements. The process and fees vary by state.';

  @override
  String get documentationAnswerWorkCardQuestion =>
      'Does formal employment still exist, and how does it work?';

  @override
  String get documentationAnswerWorkCardAnswer =>
      'Yes. In formal CLT employment, the relationship is registered and the Carteira de Trabalho Digital holds the work record.';

  @override
  String get documentationAnswerPjQuestion =>
      'Is PJ work the same as monotributo?';

  @override
  String get documentationAnswerPjAnswer =>
      'It may feel similar as a self-employed or company-based model, but it is not the same legal structure. Tax, retirement, and contract rules vary by arrangement in Brazil.';

  @override
  String get documentationAnswerMarketQuestion =>
      'Is Brazil a good place to build income from work?';

  @override
  String get documentationAnswerMarketAnswer =>
      'Yes, but the practical expectation is steady income and gradual growth, not exceptionally high pay right away. Brazil has a large and diversified labor market, but earnings vary a lot by city, sector, language, and your legal work status.';

  @override
  String get documentationAnswerSafetyQuestion =>
      'Is safety in Brazil the same everywhere?';

  @override
  String get documentationAnswerSafetyAnswer =>
      'No. Safety varies a lot by state, city, neighborhood, and daily routine. The safest way to plan is to compare the specific area where you want to live and move around, not to treat the whole country as one block.';

  @override
  String get documentationAnswerInssQuestion =>
      'Is public retirement in Brazil handled through INSS?';

  @override
  String get documentationAnswerInssAnswer =>
      'Yes. INSS is the main public retirement gateway for benefits such as retirement, as long as contributions and eligibility rules are met.';

  @override
  String get documentationAnswerRetirementQuestion =>
      'Does retirement depend only on age?';

  @override
  String get documentationAnswerRetirementAnswer =>
      'No. Minimum age matters, but contribution time and transition rules matter too.';

  @override
  String get documentationHealthSectionTitle =>
      'Public health vs. private health';

  @override
  String get documentationHealthSectionBody =>
      'The key is understanding the role of each path. Public health is not a cheap insurance plan, and private health does not replace careful coverage comparison.';

  @override
  String get documentationWorkSectionTitle => 'How work and retirement connect';

  @override
  String get documentationWorkSectionBody =>
      'It helps to separate your work model from the way you contribute. Formal employment, CNPJ-based work, and INSS contributions are related, but not the same thing.';

  @override
  String get documentationDrivingSectionTitle =>
      'How to think about driving without overcomplicating it';

  @override
  String get documentationDrivingSectionBody =>
      'The safest approach is to split this into three questions: Can I drive now? What must I validate in the state? When is it worth starting the Brazilian license process?';

  @override
  String get documentationDeepDiveTitle =>
      'If you need one more level of detail';

  @override
  String get documentationDeepDiveBody =>
      'This is where the full cards with official sources stay. They are still short, but they help when the quick answer is not enough.';

  @override
  String get documentationCostsTitle => 'A starting-cost overview';

  @override
  String get documentationCostsBody =>
      'See what typically belongs in the Argentina → Brazil route budget. Federal amounts are shown per person; housing, supporting documents, and private health depend on your situation.';

  @override
  String documentationCostsUpdatedAt(String value) {
    return 'Approximate exchange rate updated at $value';
  }

  @override
  String get documentationCostsUnavailable =>
      'The exchange rate could not be updated right now. Converted values are temporarily unavailable.';

  @override
  String get documentationCostsDisclaimer =>
      'Official references checked in July 2026. Confirm amounts before paying: exemptions, residence category, city, required documents, and personal choices can change the total.';

  @override
  String get documentationCostFreeValue => 'Free';

  @override
  String get documentationCostVariableValue => 'Variable';

  @override
  String get documentationCostMigrationTitle => 'Residence + CRNM issuance';

  @override
  String get documentationCostMigrationValue => 'R\$ 372.90 per person';

  @override
  String get documentationCostMigrationSupporting =>
      'Combined federal fees for residence authorization (R\$ 168.13) and CRNM issuance (R\$ 204.77), when both apply.';

  @override
  String get documentationCostCpfTitle => 'CPF registration';

  @override
  String get documentationCostCpfValue => 'Free or R\$ 7';

  @override
  String get documentationCostCpfSupporting =>
      'The official request is free. The Revenue Service lists a R\$ 7 fee only at partner offices; no intermediary is required.';

  @override
  String get documentationCostSusCardTitle =>
      'SUS access and National Health Card';

  @override
  String get documentationCostSusCardSupporting =>
      'SUS access is free for anyone in Brazil, regardless of migration status. The card helps with registration but must not prevent care.';

  @override
  String get documentationCostHousingTitle => 'Rental guarantee';

  @override
  String get documentationCostHousingValue => 'Up to 3 months\' rent';

  @override
  String get documentationCostHousingSupporting =>
      'When a lease uses a cash deposit, tenancy law limits it to three months\' rent. Other guarantee types have their own costs.';

  @override
  String get documentationCostHousingSource => 'Tenancy Law';

  @override
  String get documentationCostDocumentsTitle =>
      'Certificates, legalization, and translation';

  @override
  String get documentationCostDocumentsSupporting =>
      'Birth or marriage certificates and criminal records may be required. The Argentina → Brazil route has specific exemptions, but extra documents can create variable costs.';

  @override
  String get documentationCostPrivateHealthTitle => 'Private health plan';

  @override
  String get documentationCostPrivateHealthSupporting =>
      'It is optional and does not replace SUS. Age, coverage, network, geographic scope, and copay determine the final price.';

  @override
  String get documentationCpfTitle => 'CPF';

  @override
  String get documentationCpfSummary =>
      'An important registration for banking, contracts, work, and services, but it does not replace migration regularization.';

  @override
  String get documentationCpfBulletOne =>
      'Resident and nonresident foreign nationals can request a CPF. The official service is free; partner offices charge R\$ 7.';

  @override
  String get documentationCpfBulletTwo =>
      'Bring an official photo ID and, if it omits birthplace, parentage, or date of birth, an equivalent civil certificate.';

  @override
  String get documentationCpfBulletThree =>
      'CPF does not replace your migration document, but it usually unlocks a large part of daily life.';

  @override
  String get documentationTravelDocsTitle =>
      'Travel document from Argentina to Brazil';

  @override
  String get documentationTravelDocsSummary =>
      'For tourism and initial entry, a passport is not the only option. The key is traveling with a recognized physical identity document that is valid for Mercosur travel.';

  @override
  String get documentationTravelDocsBulletOne =>
      'Argentine citizens may travel to Brazil with a national identity document (DNI) or a passport.';

  @override
  String get documentationTravelDocsBulletTwo =>
      'The document must be in good condition and allow the holder to be clearly identified through the photo.';

  @override
  String get documentationTravelDocsBulletThree =>
      'A document-in-process receipt, damaged documents, or older documents not accepted under migration rules may block departure or boarding.';

  @override
  String get documentationRegistrationTitle =>
      'Migration registration and CRNM';

  @override
  String get documentationRegistrationSummary =>
      'After entering regularly, registration with the Federal Police is usually the key next step.';

  @override
  String get documentationRegistrationBulletOne =>
      'Anyone who enters with a temporary visa must register within 90 days after entering Brazil.';

  @override
  String get documentationRegistrationBulletTwo =>
      'If residence authorization was granted inside Brazil, registration must happen within 30 days.';

  @override
  String get documentationRegistrationBulletThree =>
      'The CRNM may take around 30 business days to be issued; the official service allows a longer total window, and the protocol preserves rights.';

  @override
  String get documentationStayTitle => 'How long can I stay?';

  @override
  String get documentationStaySummary =>
      'For an Argentinian user, the practical path is usually regular residence instead of relying on visitor status.';

  @override
  String get documentationStayBulletOne =>
      'A visitor visa is not designed for living in Brazil or for paid work.';

  @override
  String get documentationStayBulletTwo =>
      'Residence under the Mercosur Agreement can be granted for 2 years.';

  @override
  String get documentationStayBulletThree =>
      'Before that period ends, you may request conversion to indefinite residence if you meet the requirements.';

  @override
  String get documentationWorkBankTitle => 'Work and bank account';

  @override
  String get documentationWorkBankSummary =>
      'Working and opening an account depend more on regular status than on a single magic document.';

  @override
  String get documentationWorkBankBulletOne =>
      'A visitor visa does not authorize paid work in Brazil.';

  @override
  String get documentationWorkBankBulletTwo =>
      'To work formally, you need a compatible migration status and regular registration.';

  @override
  String get documentationWorkBankBulletThree =>
      'A bank may request additional documents; CPF helps, but a regular migration document usually matters during onboarding.';

  @override
  String get documentationCitizenshipTitle => 'Naturalization';

  @override
  String get documentationCitizenshipSummary =>
      'Brazilian nationality does not come from CPF time alone; it depends on regular residence and its own legal rules.';

  @override
  String get documentationCitizenshipBulletOne =>
      'Ordinary naturalization generally requires indefinite residence in Brazil.';

  @override
  String get documentationCitizenshipBulletTwo =>
      'The general rule requires 4 years of residence before applying, along with other legal requirements.';

  @override
  String get documentationCitizenshipBulletThree =>
      'There are official cases that reduce that period, so it is worth checking the exact rule before planning your path.';

  @override
  String get documentationResidenceChecklistTitle =>
      'Argentina → Brazil residence checklist';

  @override
  String get documentationResidenceChecklistSummary =>
      'Prepare documents before traveling so a missing certificate or proof does not interrupt your Federal Police application.';

  @override
  String get documentationResidenceChecklistBulletOne =>
      'Have a valid DNI or passport and proof of regular entry into Brazil.';

  @override
  String get documentationResidenceChecklistBulletTwo =>
      'Prepare a birth or marriage certificate when your ID omits parentage, plus criminal records from countries where you lived during the previous five years.';

  @override
  String get documentationResidenceChecklistBulletThree =>
      'Confirm legalization and translation for your migration basis: the Brazil–Argentina agreement provides specific exemptions, but the Federal Police may request additional documents.';

  @override
  String get documentationHealthPublicTitle =>
      'SUS, local health posts, and public access';

  @override
  String get documentationHealthPublicSummary =>
      'Public health in Brazil is not a prepaid access plan. The logic is universal access, with different entry points depending on what you need.';

  @override
  String get documentationHealthPublicBulletOne =>
      'SUS provides universal access, including for foreign nationals in Brazil.';

  @override
  String get documentationHealthPublicBulletTwo =>
      'A UBS or local health post is usually the first point of access for routine care, follow-up, vaccines, and basic care.';

  @override
  String get documentationHealthPublicBulletThree =>
      'Urgent and emergency care follow a different access path; do not wait until every registration step is finished before seeking help.';

  @override
  String get documentationHealthFlowTitle =>
      'How to find the right kind of care';

  @override
  String get documentationHealthFlowSummary =>
      'Not every health question starts at a hospital. It helps to know when to look for a UBS, UPA, hospital, or official app.';

  @override
  String get documentationHealthFlowBulletOne =>
      'Use a UBS or health post for routine care, referrals, prescriptions, and follow-up.';

  @override
  String get documentationHealthFlowBulletTwo =>
      'Use a UPA or hospital when the case is urgent, acute, or cannot wait for a basic appointment.';

  @override
  String get documentationHealthFlowBulletThree =>
      'Meu SUS Digital and the local health department help locate units, exams, and follow-up information.';

  @override
  String get documentationHealthPrivateTitle => 'Private health';

  @override
  String get documentationHealthPrivateSummary =>
      'A private plan may improve convenience and network speed, but it becomes a recurring cost and needs careful coverage comparison.';

  @override
  String get documentationHealthPrivateBulletOne =>
      'Private health plans are paid products regulated by ANS.';

  @override
  String get documentationHealthPrivateBulletTwo =>
      'Price, network, coverage, and waiting periods vary by contract, age, and operator.';

  @override
  String get documentationHealthPrivateBulletThree =>
      'Before signing, compare network, coverage, and rules in official ANS material, not only the price.';

  @override
  String get documentationWorkCltTitle => 'Formal employment';

  @override
  String get documentationWorkCltSummary =>
      'In formal work, the employment relationship follows CLT and the record appears in the Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletOne =>
      'Formal employment is the clearest and most recognizable model of formal work in Brazil.';

  @override
  String get documentationWorkCltBulletTwo =>
      'Your work history can be followed through the Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletThree =>
      'In this model, the link with retirement contributions is usually more integrated into payroll.';

  @override
  String get documentationWorkPjTitle => 'PJ, CNPJ, and independent work';

  @override
  String get documentationWorkPjSummary =>
      'Working as a PJ or through a CNPJ changes the logic of the relationship. It may resemble monotributo culturally, but it is not the same legal structure.';

  @override
  String get documentationWorkPjBulletOne =>
      'PJ is not formal employment; the relationship is business-based or self-employed, not employment-based.';

  @override
  String get documentationWorkPjBulletTwo =>
      'Opening a CNPJ and contributing to retirement are connected topics, but not automatic in every case.';

  @override
  String get documentationWorkPjBulletThree =>
      'Before accepting this model, understand taxes, contract terms, and how retirement contributions will work.';

  @override
  String get documentationWorkMarketTitle =>
      'Labor market and income expectations';

  @override
  String get documentationWorkMarketSummary =>
      'Brazil offers scale and many work formats, but migration planning should assume moderate income and gradual progression rather than unusually high salaries in the first stage.';

  @override
  String get documentationWorkMarketBulletOne =>
      'In the rolling quarter ending in October 2025, IBGE recorded unemployment at 5.4%, habitual average earnings at R\$ 3,528, and a record 39.2 million formally registered private-sector workers.';

  @override
  String get documentationWorkMarketBulletTwo =>
      'That combination shows a large and active market, with room in services, commerce, logistics, health, education, technology, and local business networks.';

  @override
  String get documentationWorkMarketBulletThree =>
      'For someone arriving from abroad, the safest reading is to plan around realistic income, reserve capital, and city-by-city differences in wages and formalization.';

  @override
  String get documentationRetirementTitle =>
      'Public retirement and pension system';

  @override
  String get documentationRetirementSummary =>
      'In Brazil, public retirement revolves around INSS, with minimum age, contribution time, and transition rules shaping each case differently.';

  @override
  String get documentationRetirementBulletOne =>
      'The current general age-based rule uses a minimum age of 62 for women and 65 for men.';

  @override
  String get documentationRetirementBulletTwo =>
      'Contribution time still matters, especially under transition rules and eligibility analysis.';

  @override
  String get documentationRetirementBulletThree =>
      'For someone arriving from abroad, it is safest to understand early how contributions will happen in Brazil.';

  @override
  String get documentationSafetyTitle =>
      'Safety: read it by city and neighborhood';

  @override
  String get documentationSafetySummary =>
      'Safety in Brazil is not uniform. The useful decision is not whether the country is \'safe\' in the abstract, but how the exact city, neighborhood, commute, and schedule fit your routine.';

  @override
  String get documentationSafetyBulletOne =>
      'The 2025 Brazilian Public Security Yearbook is based on official public security data from states and police forces and is the broadest snapshot of the sector in the country.';

  @override
  String get documentationSafetyBulletTwo =>
      'Its data shows strong variation across states and crime categories, which is why national averages alone are not enough to choose where to live.';

  @override
  String get documentationSafetyBulletThree =>
      'Before renting or accepting a job, compare neighborhood context, nighttime mobility, route patterns, and the practical routine you will actually have.';

  @override
  String get documentationDrivingTitle => 'First driving license in Brazil';

  @override
  String get documentationDrivingSummary =>
      'If you are going to live in Brazil, a Brazilian license depends on the state Detran and a local process with mandatory steps.';

  @override
  String get documentationDrivingBulletOne =>
      'The process usually includes medical and psychological exams, classes, a theory test, and a practical test.';

  @override
  String get documentationDrivingBulletTwo =>
      'A regularized foreign national can enter the process if the state identification and residence requirements are met.';

  @override
  String get documentationDrivingBulletThree =>
      'Fees and final costs vary by Detran and driving school, so treat the displayed value only as guidance.';

  @override
  String get documentationForeignLicenseTitle =>
      'Foreign license and initial driving';

  @override
  String get documentationForeignLicenseSummary =>
      'Having a valid foreign license may help at the beginning, but it does not permanently replace the need to confirm the Brazilian rule.';

  @override
  String get documentationForeignLicenseBulletOne =>
      'The ability to drive with a foreign license depends on validity, identification, and the rule that applies to your case.';

  @override
  String get documentationForeignLicenseBulletTwo =>
      'An initial period of use does not mean automatic equivalence for your entire stay in Brazil.';

  @override
  String get documentationForeignLicenseBulletThree =>
      'If you plan to settle in Brazil, confirm early with the state Detran whether there will be registration, exchange, or a full new process.';

  @override
  String get citiesPageTitle => 'Cities';

  @override
  String get countriesPageTitle => 'Countries';

  @override
  String get publicAccessLabel => 'Public access';

  @override
  String get loginPageTitle => 'Sign in';

  @override
  String get loginHeadline => 'Sign in only when it makes sense for you';

  @override
  String get loginDescription =>
      'Movaro keeps exploration open. Sign-in appears only when you want to save something personal.';

  @override
  String get loginGoogleAction => 'Continue with Google';

  @override
  String get loginAppleAction => 'Continue with Apple';

  @override
  String get loginDevOnlyHint =>
      'These buttons use FakeAuthDataSource only in development.';

  @override
  String get loginLaterAction => 'Not now';

  @override
  String loginActionRequired(String action) {
    return 'To $action, we need to link this action to you.';
  }

  @override
  String get pendingActionSavePlan => 'save your plan';

  @override
  String get pendingActionPostCommunity => 'post in the community';

  @override
  String get pendingActionSaveCity => 'save this city';

  @override
  String get onboardingPageTitle => 'Your route';

  @override
  String get onboardingHeadline =>
      'Start with the route that makes sense for you';

  @override
  String get onboardingDescription =>
      'Choose your origin and destination to personalize cities, costs, documents, and next steps.';

  @override
  String get onboardingOriginLabel => 'Where are you coming from?';

  @override
  String get onboardingDestinationLabel => 'Where do you want to go?';

  @override
  String get onboardingContinueAction => 'Continue';

  @override
  String get authenticatedHomeTitle => 'Your space';

  @override
  String authenticatedWelcome(String name) {
    return 'Hi, $name';
  }

  @override
  String get authenticatedHomeDescription =>
      'This is where you pick up what you were doing and find your main shortcuts.';

  @override
  String get authenticatedPlanSectionTitle => 'Your plan';

  @override
  String get authenticatedShortcutsTitle => 'Helpful shortcuts';

  @override
  String get authenticatedCitiesShortcut => 'See cities';

  @override
  String get authenticatedSearchShortcut => 'Search for a city';

  @override
  String get signOutAction => 'Sign out';

  @override
  String onboardingSummary(String origin, String destination) {
    return 'Origin: $origin  Destination: $destination';
  }

  @override
  String savedPlansCount(int count) {
    return 'Saved plans: $count';
  }

  @override
  String get startNewPlanAction => 'Start a new plan';

  @override
  String get questionnairePageTitle => 'Answer a few quick questions';

  @override
  String get questionnaireLoadingLabel => 'Preparing your quick questions';

  @override
  String get questionnaireSupportText =>
      'It takes less than a minute. One question at a time.';

  @override
  String get questionnaireSectionOrigin => 'Origin';

  @override
  String get questionnaireSectionBasicProfile => 'Basic profile';

  @override
  String get questionnaireSectionPreferences => 'Preferences';

  @override
  String get questionnaireSectionFinancial => 'Financial situation';

  @override
  String get questionnaireSectionGoal => 'Migration goal';

  @override
  String questionnaireNextSection(Object section) {
    return 'Next: $section';
  }

  @override
  String get questionnaireReadyForPlan =>
      'Next, we will turn these answers into your first plan.';

  @override
  String get questionnaireProcessingTitle => 'Building your first plan';

  @override
  String get questionnaireProcessingBody =>
      'We are connecting your journey, profile, and priorities into a clear starting point.';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get backAction => 'Back';

  @override
  String get nextAction => 'Continue';

  @override
  String get generatePlanAction => 'See my plan';

  @override
  String get migrationPlanPageTitle => 'Your first plan';

  @override
  String get migrationPlanSummaryTitle => 'What you told us';

  @override
  String get planRecommendedCityTitle => 'City to review first';

  @override
  String planRecommendedCityDescription(String city, String stateCode) {
    return 'Based on your choices, $city, $stateCode appears as a useful place to review first.';
  }

  @override
  String get planRecommendedCityAction => 'Review this city';

  @override
  String planSummaryOrigin(String value) {
    return 'Origin: $value';
  }

  @override
  String planSummaryDestination(String value) {
    return 'Destination: $value';
  }

  @override
  String planSummaryGoal(String value) {
    return 'Goal: $value';
  }

  @override
  String planSummaryTimeline(String value) {
    return 'Move timing: $value';
  }

  @override
  String get migrationPlanStepsTitle => 'Suggested first steps';

  @override
  String get planNextActionsTitle => 'What usually comes right after this';

  @override
  String get planNextActionsBody =>
      'If this result helped, the next move is usually to confirm documents, compare the suggested city with alternatives, or rebuild the plan around a different priority.';

  @override
  String get planNextActionDocumentsTitle => 'Confirm documents before acting';

  @override
  String get planNextActionDocumentsBody =>
      'Use the practical guide to review CPF, registration, stay, work, and banking without falling into scattered research.';

  @override
  String get planNextActionCitiesTitle =>
      'Compare other cities before deciding';

  @override
  String get planNextActionCitiesBody =>
      'Check whether the suggested city still makes sense when compared through cost, language, safety, and work.';

  @override
  String get planNextActionRetakeTitle =>
      'Rebuild the plan with a different priority';

  @override
  String get planNextActionRetakeBody =>
      'If your priority changed, it is worth answering again and seeing whether the order of steps changes too.';

  @override
  String get readinessSectionTitle =>
      'A practical checklist for the next phase';

  @override
  String get readinessStageNow => 'Start now';

  @override
  String get readinessStageSoon => 'Prepare next';

  @override
  String get readinessStageLanding => 'Before landing';

  @override
  String get readinessSummaryResearching =>
      'You are still exploring, so the best move is to reduce uncertainty before opening too many fronts.';

  @override
  String get readinessSummaryTwelveMonths =>
      'You still have room to prepare well, so use this checklist to remove friction before the move gets close.';

  @override
  String get readinessSummarySixMonths =>
      'Six months is enough time to stop improvising and start structuring documents, money, and city choice.';

  @override
  String get readinessSummaryAsap =>
      'Since your plan is close, the priority now is sequencing the essentials and avoiding avoidable mistakes.';

  @override
  String get readinessItemMigrationPathTitle =>
      'Confirm the migration path first';

  @override
  String get readinessItemMigrationPathBody =>
      'Before banking, housing, or work, validate the residency route that best matches your move to Brazil.';

  @override
  String get readinessItemDocumentsTitle => 'Prepare the core document pack';

  @override
  String get readinessItemDocumentsBody =>
      'Separate your passport, criminal records, apostille needs, and any documents that may still require translation.';

  @override
  String get readinessItemBudgetTitle => 'Stress-test your landing budget';

  @override
  String get readinessItemBudgetBody =>
      'Estimate what the first 30 to 90 days will demand, not just the monthly living cost after you are settled.';

  @override
  String get readinessItemCityTitle => 'Turn city choice into a real filter';

  @override
  String get readinessItemCityBody =>
      'Use your current city shortlist to reduce housing, transport, and daily-life uncertainty before comparing neighborhoods.';

  @override
  String readinessItemCityBodyWithCity(String city) {
    return 'Use $city as your first filter and compare it with alternatives before moving into neighborhood-level decisions.';
  }

  @override
  String get readinessItemLanguageTitle => 'Prepare your first language layer';

  @override
  String get readinessItemLanguageBody =>
      'Focus on the Portuguese needed for everyday friction points like housing, transport, banking, and services.';

  @override
  String get readinessItemLanguageWorkBody =>
      'Focus on the Portuguese that will affect interviews, work routines, negotiations, and basic service requests.';

  @override
  String get readinessItemLanguageStudyBody =>
      'Focus on the Portuguese needed for classes, enrollment, daily errands, and institutional communication.';

  @override
  String get readinessGoalWorkTitle => 'Map employability before arriving';

  @override
  String get readinessGoalWorkBody =>
      'Review what kind of work you can pursue early, what documents may block you, and how the city affects your chances.';

  @override
  String get readinessGoalRemoteTitle => 'Stabilize remote work conditions';

  @override
  String get readinessGoalRemoteBody =>
      'Check internet quality, banking flow, daily costs, and the minimum local setup you need before relying on remote income.';

  @override
  String get readinessGoalStudyTitle => 'Validate the study route';

  @override
  String get readinessGoalStudyBody =>
      'Review admissions, routine costs, student timing, and what needs to be regularized before relying on study as your base.';

  @override
  String get readinessGoalEntrepreneurTitle => 'Plan the business entry path';

  @override
  String get readinessGoalEntrepreneurBody =>
      'Map the practical first layer: local documents, banking, city fit, and the minimum structure to start operating safely.';

  @override
  String get readinessGoalRetireTitle => 'Protect routine and predictability';

  @override
  String get readinessGoalRetireBody =>
      'Prioritize health access, neighborhood routine, recurring costs, and the paperwork that supports a calm arrival.';

  @override
  String get readinessGoalQualityTitle => 'Turn quality of life into criteria';

  @override
  String get readinessGoalQualityBody =>
      'Convert lifestyle into real filters: safety, daily routine, language adaptation, and the cost of staying longer term.';

  @override
  String get readinessItemCpfBankTitle => 'Prepare CPF and first banking steps';

  @override
  String get readinessItemCpfBankBody =>
      'CPF and regular status affect banking, contracts, and day-to-day setup. Treat them as part of the same arrival layer.';

  @override
  String get readinessItemHousingTitle =>
      'Reduce housing friction before searching';

  @override
  String get readinessItemHousingBody =>
      'Review rent guarantees, cash reserve, neighborhood priorities, and what proof you may need before contacting landlords.';

  @override
  String get readinessItemArrivalTitle => 'Build a 30-day arrival plan';

  @override
  String get readinessItemArrivalBody =>
      'List what must work in the first month: connectivity, health access, transport, routine payments, and document follow-up.';

  @override
  String readinessProgressLabel(int done, int total) {
    return '$done of $total items completed';
  }

  @override
  String planStepMeta(String category, int days) {
    return 'Category: $category  Estimated days: $days';
  }

  @override
  String get planStepOpenDetailsAction => 'Open details';

  @override
  String get planStepOpenVisaEyebrow => 'Residence and visa';

  @override
  String get planStepOpenVisaSummary =>
      'Before deciding on banking, work, or housing, it helps to confirm the right migration path for entering and staying regularly.';

  @override
  String get planStepOpenVisaPointOne =>
      'For an Argentinian user, residence under the Mercosur Agreement is often one of the most direct paths.';

  @override
  String get planStepOpenVisaPointTwo =>
      'A visitor visa is not meant for living in Brazil or for paid work.';

  @override
  String get planStepOpenVisaPointThree =>
      'If your goal is already to live in Brazil, it is better to solve this before taking on rent or work.';

  @override
  String get planStepOpenCpfEyebrow => 'Tax document';

  @override
  String get planStepOpenCpfSummary =>
      'CPF helps unlock banking, contracts, registrations, and much of daily life early on.';

  @override
  String get planStepOpenCpfPointOne =>
      'The process can start online, according to the official guidance.';

  @override
  String get planStepOpenCpfPointTwo =>
      'The officially stated time can reach up to 30 calendar days.';

  @override
  String get planStepOpenCpfPointThree =>
      'CPF helps a lot, but it does not replace a regular migration document.';

  @override
  String get planStepOpenBankEyebrow => 'First account';

  @override
  String get planStepOpenBankSummary =>
      'Opening an account depends more on your regular status and documents than on one specific bank.';

  @override
  String get planStepOpenBankPointOne =>
      'There are traditional and digital banks, but document requirements may vary.';

  @override
  String get planStepOpenBankPointTwo =>
      'CPF helps, but CRNM, a protocol receipt, or another regular document can influence approval.';

  @override
  String get planStepOpenBankPointThree =>
      'Start by comparing a digital account for simple day-to-day use and a traditional bank if you need in-person support.';

  @override
  String get planStepOpenHousingEyebrow => 'Housing and neighborhoods';

  @override
  String get planStepOpenHousingSummary =>
      'Before closing a housing deal, compare neighborhoods with better daily routine, access, and cost.';

  @override
  String planStepOpenHousingSummaryCity(String city) {
    return 'For $city, compare neighborhoods with better daily routine, access, and cost before closing a housing deal.';
  }

  @override
  String get planStepOpenHousingPointOne =>
      'Prioritize neighborhoods that connect well to what you need: work, transport, and services.';

  @override
  String get planStepOpenHousingPointTwo =>
      'Use the city cost reading as a starting point, but confirm rent and contract details before deciding.';

  @override
  String get planStepOpenHousingPointThree =>
      'Neighborhood-level analysis still needs a dedicated data layer; for now, use the current city match as an initial filter.';

  @override
  String get planStepOpenGeneralEyebrow => 'Guided checklist';

  @override
  String get planStepOpenGeneralSummary =>
      'This step works best as a practical validation within your move preparation.';

  @override
  String get planStepOpenGeneralPointOne =>
      'Solve the essentials first so you do not open too many fronts at the same time.';

  @override
  String get planStepOpenGeneralPointTwo =>
      'When a step depends on an official document, confirm the latest requirement before submitting anything.';

  @override
  String get planStepOpenGeneralPointThree =>
      'Use the plan as a suggested order, not as a rigid rule for every case.';

  @override
  String get planStepOpenTagMercosur => 'Mercosur';

  @override
  String get planStepOpenTagVisitor => 'Visitor stay is not work authorization';

  @override
  String get planStepOpenTagOnline => 'Online request';

  @override
  String get planStepOpenTagReceitaFederal => 'Receita Federal';

  @override
  String get planStepOpenTagTraditionalBanks => 'Traditional banks';

  @override
  String get planStepOpenTagDigitalBanks => 'Digital banks';

  @override
  String get planStepOpenTagNeighborhoods => 'Neighborhoods';

  @override
  String get planStepOpenTagRent => 'Rent';

  @override
  String get planStepOpenTagChecklist => 'Step by step';

  @override
  String get savePlanAction => 'Save plan';

  @override
  String get savePlanPageTitle => 'Save plan';

  @override
  String get savePlanSuccessTitle => 'Plan saved for now';

  @override
  String savePlanSuccessBody(int count) {
    return 'Temporarily saved plans in this session: $count';
  }

  @override
  String get goToProfileAction => 'Go to my space';

  @override
  String get citiesExploreTitle => 'Cities';

  @override
  String get citiesExploreHeadline => 'Discover cities with more context';

  @override
  String get citiesExploreDescription =>
      'See suggestions by intention and understand why each city appears here.';

  @override
  String get citiesExploreSearchFirstDescription =>
      'Search for a city or use the chips to filter the catalog when it makes sense. The list does not open preloaded: results appear only after you search or pick a slice.';

  @override
  String get citiesGuideEyebrow => 'Quick guide';

  @override
  String get citiesGuideTitle => 'How to use city discovery';

  @override
  String get citiesGuideBody =>
      'Here you can search by name, filter the catalog with quick slices, or open the map to choose by location.';

  @override
  String get citiesGuideStepOneTitle => 'Search a city';

  @override
  String get citiesGuideStepOneBody =>
      'Type the name and tap the closest result to open the detail.';

  @override
  String get citiesGuideStepTwoTitle => 'Use a quick slice';

  @override
  String get citiesGuideStepTwoBody =>
      'The chips narrow the list by popularity, cost, work, language, and other signals.';

  @override
  String get citiesGuideStepThreeTitle => 'Choose on the map';

  @override
  String get citiesGuideStepThreeBody =>
      'Open the map, tap a city, and continue to the detail when you want to decide by location.';

  @override
  String get citiesGuideHideNextTime => 'Do not show again';

  @override
  String get citiesGuideStepsLabel => '3 steps';

  @override
  String get citiesGuideDismissAction => 'Not now';

  @override
  String get citiesGuidePrimaryAction => 'Got it';

  @override
  String get citiesExploreSearchIdleTitle =>
      'Search for a city or choose a filter';

  @override
  String get citiesExploreSearchIdleDescription =>
      'Type a city name for immediate autocomplete or swipe the chips to explore by popularity, beach, work, language, and arrival profile.';

  @override
  String get citiesLoadingLabel => 'Loading cities';

  @override
  String get citiesMethodologyNote =>
      'Comparison based on public data when available. Internal scores are non-official estimates.';

  @override
  String get citiesExplorePopularTitle => 'Most chosen by Argentinians';

  @override
  String get citiesExploreLanguageTitle =>
      'Easier for people who still rely on Spanish';

  @override
  String get citiesExploreEconomicalTitle =>
      'Good options if cost matters more';

  @override
  String get citiesExploreWorkTitle =>
      'Good options if you are looking for work';

  @override
  String get citiesExploreHousingEasyTitle => 'Good for a lighter landing';

  @override
  String get citiesExploreHousingPressureTitle => 'Need more cash upfront';

  @override
  String get citiesExploreSoftLandingTitle =>
      'Good for a lower-friction landing';

  @override
  String get citiesExploreFamilyStabilityTitle =>
      'Good for a more predictable arrival';

  @override
  String get citiesExploreIncomeStartTitle =>
      'Good if you may need income early';

  @override
  String get citiesExploreCoastalTitle =>
      'Good if you want to live near the beach';

  @override
  String get citiesExploreCoastalSoftLandingTitle =>
      'Beach cities with a lighter landing';

  @override
  String get citiesExploreCoastalBalancedTitle =>
      'Beach cities with a better routine balance';

  @override
  String get citiesHighlightPopularLabel =>
      'Among cities in the current catalog';

  @override
  String get citiesHighlightLanguageLabel =>
      'A good option if language adaptation matters to you';

  @override
  String get citiesHighlightEconomicalLabel =>
      'A good option if you prioritize cost';

  @override
  String get citiesHighlightWorkLabel =>
      'A good option if you want more work opportunities';

  @override
  String get citiesHighlightHousingEasyLabel => 'Good for soft landing';

  @override
  String get citiesHighlightHousingPressureLabel => 'High housing pressure';

  @override
  String get citiesHighlightSoftLandingLabel =>
      'Good for a softer start with less friction';

  @override
  String get citiesHighlightFamilyStabilityLabel =>
      'Good for balancing safety, housing, and routine';

  @override
  String get citiesHighlightIncomeStartLabel =>
      'Good if you need to activate income sooner';

  @override
  String get citiesHighlightCoastalLabel => 'Good for a coastal routine';

  @override
  String get citiesHighlightMetropolisLabel =>
      'Good if you want a more urban pace';

  @override
  String get citiesHighlightInlandLabel => 'Good if you want a calmer routine';

  @override
  String get citiesHighlightBorderLabel =>
      'Good if you want a border-city lens';

  @override
  String get citiesHighlightCoastalSoftLandingLabel =>
      'Beach with a softer landing';

  @override
  String get citiesHighlightCoastalBalancedLabel =>
      'Beach with a better balance between routine and cost';

  @override
  String get citiesExploreEmptyTitle => 'We are still expanding this catalog';

  @override
  String get citiesExploreEmptyDescription =>
      'City suggestions will appear here as the Movaro catalog grows.';

  @override
  String get citiesSearchTitle => 'Search cities';

  @override
  String get citiesSearchHeadline =>
      'Validate a city before committing to a plan';

  @override
  String get citiesSearchDescription =>
      'Search by name, compare alternatives, and open the details to understand cost, fit, and next steps.';

  @override
  String get citiesSearchHint => 'Search city';

  @override
  String get citiesSearchFieldLabel => 'Which city do you want to validate?';

  @override
  String get citiesSearchHelper =>
      'Type to search cities by name and tap autocomplete.';

  @override
  String get citiesQuickChoicesTitle => 'Quick choices';

  @override
  String get citiesQuickChoicesBody =>
      'Use a slice to narrow the list faster or go by map if location is your starting point.';

  @override
  String citiesSearchResultsCount(int count) {
    return '$count cities found';
  }

  @override
  String get citiesSearchResultsHint =>
      'Tap a city to open the detail directly.';

  @override
  String get citiesMapOpenAction => 'Choose on map';

  @override
  String get citiesMapCalloutBody =>
      'Prefer to decide by location? Open the map and compare cities by the place where you want to start.';

  @override
  String get citiesMapCalloutStepOne => 'Open map';

  @override
  String get citiesMapCalloutStepTwo => 'Tap city';

  @override
  String get citiesMapCalloutStepThree => 'Open detail';

  @override
  String get citiesMapSheetTitle => 'Choose a city on the map';

  @override
  String get citiesMapSheetBody =>
      'Open the Brazil map, tap a point, and select the city by its position.';

  @override
  String get citiesMapOpenCityAction => 'Open city';

  @override
  String get citiesQuickFilterAll => 'Overview';

  @override
  String get citiesQuickFilterPopular => 'Most popular';

  @override
  String get citiesQuickFilterLowCost => 'Better cost';

  @override
  String get citiesQuickFilterWork => 'More jobs';

  @override
  String get citiesQuickFilterLanguage => 'Easier language';

  @override
  String get citiesQuickFilterHousingEasy => 'Lighter landing';

  @override
  String get citiesQuickFilterHousingPressure => 'More cash';

  @override
  String get citiesQuickFilterSoftLanding => 'Less friction';

  @override
  String get citiesQuickFilterFamilyStability => 'More predictable';

  @override
  String get citiesQuickFilterIncomeStart => 'Early income';

  @override
  String get citiesQuickFilterCoastal => 'Beach';

  @override
  String get citiesSearchingLabel => 'Searching cities';

  @override
  String get citiesCatalogLoadingLabel => 'Loading catalog';

  @override
  String get citiesFilterClear => 'Clear';

  @override
  String get citiesResultsTitle => 'Results';

  @override
  String citiesResultsBody(int count) {
    return '$count cities match this search or filter.';
  }

  @override
  String get citiesResultsMoreHint => 'Scroll to load more cities';

  @override
  String get citiesSearchEmptyTitle => 'No city found';

  @override
  String get citiesSearchEmptyDescription =>
      'Try another name or explore the initial Movaro catalog.';

  @override
  String get citiesSearchFirstEmptyDescription =>
      'Try another name or change the filter to widen results.';

  @override
  String get citiesCatalogEmptyTitle => 'Catalog still empty';

  @override
  String get citiesCatalogEmptyDescription =>
      'Cities from the Movaro catalog will appear here.';

  @override
  String get cityDetailTitleFallback => 'City';

  @override
  String get cityDetailLoadingLabel => 'Loading city details';

  @override
  String get cityDetailEmptyTitle => 'City unavailable';

  @override
  String get cityDetailEmptyDescription =>
      'We could not find details for this city right now.';

  @override
  String get cityDetailContextNote =>
      'Use these indicators as a starting point, not as absolute truth.';

  @override
  String get cityDetailDecisionSnapshotTitle => 'Quick city read';

  @override
  String cityDetailDecisionSnapshotSubtitle(Object bestFor) {
    return 'This city may be more relevant if you are prioritizing $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotPlanSubtitle(Object bestFor) {
    return 'For your plan, this city may stand out if you are prioritizing $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotRecommendedSubtitle(Object bestFor) {
    return 'This city is currently one of the stronger matches in your plan if your focus is $bestFor.';
  }

  @override
  String get cityDetailWatchoutTitle => 'Main point to validate';

  @override
  String get cityDetailPlanLeadingChip => 'Leading in your plan';

  @override
  String get cityDetailPlanMatchChip => 'Fits your plan';

  @override
  String cityDetailUpdatedLabel(Object date) {
    return 'Updated on $date';
  }

  @override
  String get cityDetailAffordabilityTitle => 'Cost and housing';

  @override
  String get cityDetailSummaryTitle => 'Quick summary';

  @override
  String get cityDetailSummaryBody =>
      'Use this top read to understand whether the city looks easier, more balanced, or more demanding before opening the deeper analysis.';

  @override
  String get cityDetailAddToPlanAction => 'Add to my plan';

  @override
  String get cityDetailCompareSavedAction => 'Saved to compare';

  @override
  String get cityDetailQualityLabel => 'Quality of life';

  @override
  String get cityDetailQualitySupporting =>
      'A quick read based on HDI, safety, and language adaptation for arrival.';

  @override
  String get cityDetailQualityHigh => 'Stronger';

  @override
  String get cityDetailQualityBalanced => 'Balanced';

  @override
  String get cityDetailQualityDeveloping => 'Growing';

  @override
  String get cityDetailDifficultyLabel => 'Difficulty';

  @override
  String get cityDetailDifficultyEasy => 'Easy';

  @override
  String get cityDetailDifficultyBalanced => 'Moderate';

  @override
  String get cityDetailDifficultyChallenging => 'Demanding';

  @override
  String get cityDetailSettleInTitle => 'Adaptation and community';

  @override
  String get cityDetailCommunityTitle => 'Support network';

  @override
  String get cityDetailContextTitle => 'City context';

  @override
  String get cityLifestyleCoastalLabel => 'Coastal lifestyle';

  @override
  String get cityLifestyleMetropolisLabel => 'Metropolitan pace';

  @override
  String get cityLifestyleBorderLabel => 'Border city';

  @override
  String get cityLifestyleInlandLabel => 'Inland routine';

  @override
  String get cityDetailMapTitle => 'Where the city is';

  @override
  String get cityDetailMapDescription =>
      'See the city on the map before comparing context, distance, and region.';

  @override
  String get cityDetailMapRegionLabel => 'Region';

  @override
  String cityDetailMapDistanceLabel(Object origin, Object distanceKm) {
    return 'Distance from $origin: ~$distanceKm km';
  }

  @override
  String get cityDetailSnapshotTitle => 'Quick view';

  @override
  String get cityDetailSnapshotPositiveTag => 'Strong point';

  @override
  String get cityDetailSnapshotWatchoutTag => 'Watch out';

  @override
  String get cityDetailSnapshotContextTag => 'Context';

  @override
  String get cityDetailMetricsSummary =>
      'Open only if you want to review every indicator and the full data slice.';

  @override
  String get cityDetailPopulationLabel => 'Population';

  @override
  String get cityDetailCostLabel => 'Cost';

  @override
  String get cityDetailRentLabel => 'Rent';

  @override
  String get cityDetailSafetyLabel => 'Safety';

  @override
  String get cityDetailPopularityLabel => 'Popularity among Argentinians';

  @override
  String get cityDetailLanguageLabel => 'Ease with Portuguese';

  @override
  String get cityCardPortugueseLabel => 'Portuguese';

  @override
  String get cityCardCostLow => 'Low';

  @override
  String get cityCardCostMedium => 'Mid-range';

  @override
  String get cityCardCostHigh => 'High';

  @override
  String get cityCardSafetyHigh => 'High';

  @override
  String get cityCardSafetyMedium => 'Medium';

  @override
  String get cityCardSafetyLow => 'Low';

  @override
  String get cityCardLanguageEasy => 'Easy';

  @override
  String get cityCardLanguageModerate => 'Moderate';

  @override
  String get cityCardLanguageChallenging => 'Challenging';

  @override
  String get cityCardDataUnavailable => 'Data unavailable';

  @override
  String get cityCardComparativeEstimate => 'Comparative estimate';

  @override
  String cityCardMonthlyEstimate(Object value) {
    return '$value/mo';
  }

  @override
  String get cityCardDataCoverageBroad => 'Broad data coverage';

  @override
  String get cityCardDataCoverageGood => 'Good data coverage';

  @override
  String get cityCardDataCoveragePartial => 'Partial data';

  @override
  String cityCardDataCoverageTooltip(int count) {
    return '$count traceable sources support this summary.';
  }

  @override
  String get cityDetailWorkLabel => 'Job market';

  @override
  String get cityDetailIdhmLabel => 'HDI';

  @override
  String get cityDetailIdhmOfficialNote =>
      'official Atlas of Human Development data';

  @override
  String get cityDetailUnemploymentLabel => 'Unemployment rate';

  @override
  String get cityDetailIndustriesTitle => 'Strong industries';

  @override
  String get cityDetailReasonsTitle => 'Why it may fit your priorities';

  @override
  String get cityDetailSourcesTitle => 'Data sources';

  @override
  String cityDetailSourcesSummary(int count) {
    return '$count sources available. Expand only if you want to validate the origin of the data.';
  }

  @override
  String get cityDetailSourceOfficialBadge => 'Official source';

  @override
  String get cityDetailSourceCuratedBadge => 'Curated source';

  @override
  String get cityDetailSourceProviderLabel => 'Provider';

  @override
  String get cityDetailSourceUrlLabel => 'Reference';

  @override
  String get cityDetailPublicOpinionTitle => 'What visitors tend to mention';

  @override
  String cityDetailPublicOpinionSubtitle(Object provider) {
    return 'A reading of recurring themes in public $provider reviews. It does not represent the opinion of the whole city.';
  }

  @override
  String cityDetailPublicOpinionRating(Object rating) {
    return 'Rating $rating';
  }

  @override
  String cityDetailPublicOpinionSample(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get cityDetailPublicOpinionFallbackSummary =>
      'These topics reflect themes that show up often in the public reviews found for this locality.';

  @override
  String get cityDetailPublicOpinionPositiveTitle => 'What people praise most';

  @override
  String get cityDetailPublicOpinionCriticalTitle =>
      'What people criticize most';

  @override
  String cityDetailPublicOpinionNote(Object date) {
    return 'Automatic summary checked on $date. Use it as a signal of recurring public perception, not as absolute consensus.';
  }

  @override
  String get citySourceTerritorialTitle => 'Territorial identity';

  @override
  String get citySourceTerritorialDescription =>
      'Official name, state, IBGE code, and municipal region.';

  @override
  String get citySourcePopulationTitle => 'Population';

  @override
  String get citySourcePopulationDescription =>
      'Official reference for city population.';

  @override
  String get citySourceHumanDevelopmentTitle => 'Human development';

  @override
  String get citySourceHumanDevelopmentDescription =>
      'Official municipal HDI with a 2010 Census reference.';

  @override
  String get citySourceCuratedMetricsTitle => 'Curated product metrics';

  @override
  String get citySourceCuratedMetricsDescription =>
      'Internal comparative estimate with no official status. Where no external source exists for a metric, use it only as exploration support.';

  @override
  String get citySourceRankingTitle => 'Scoring methodology';

  @override
  String get citySourceRankingDescription =>
      'Internal comparative calculation over available public data and estimated signals. It is not an official ranking.';

  @override
  String get citySourcePublicReviewsTitle =>
      'Public perception of the locality';

  @override
  String get citySourcePublicReviewsDescription =>
      'Recurring themes extracted from public Google reviews about the locality. It does not represent the opinion of the whole city.';

  @override
  String get cityDetailSaveAction => 'Save city';

  @override
  String get cityDetailSavedAction => 'City saved';

  @override
  String get cityDetailSavedFeedback =>
      'City saved temporarily on this device.';

  @override
  String get cityDetailFavoriteAction => 'Add to favorites';

  @override
  String get cityDetailFavoriteRemoveAction => 'Remove from favorites';

  @override
  String get cityDetailFavoriteNote =>
      'You can keep up to 3 favorite cities to return to them quickly from home.';

  @override
  String cityDetailFavoriteAddedFeedback(Object city) {
    return '$city was added to favorites.';
  }

  @override
  String cityDetailFavoriteRemovedFeedback(Object city) {
    return '$city was removed from favorites.';
  }

  @override
  String cityDetailFavoriteLimitFeedback(Object count) {
    return 'You can choose up to $count favorite cities.';
  }

  @override
  String get cityDetailDiscoverTitle => 'Get to know the city better';

  @override
  String cityDetailDiscoverBody(Object city, Object state) {
    return 'If you want photos, search results, and broader context for $city ($state), open the Google view without leaving the app.';
  }

  @override
  String get cityDetailDiscoverAction => 'Explore the city';

  @override
  String get cityDetailDeepDiveTitle => 'Detailed analysis';

  @override
  String get cityDetailDeepDiveSummary =>
      'Open this area if you want the full set of indicators, context, and a deeper reading of the city.';

  @override
  String get cityDetailCompareAction => 'Compare other cities';

  @override
  String cityDetailCompareSelectedBody(Object city) {
    return '$city pre-selected';
  }

  @override
  String get cityDetailPlanAction => 'Build my plan';

  @override
  String get cityDetailFooterNote =>
      'These indicators help with initial exploration and do not replace individual analysis.';

  @override
  String get publicHomeFavoritesTitle => 'Your favorite cities';

  @override
  String get publicHomeFavoritesBody =>
      'Keep up to 3 cities here so you can jump back into their details whenever you want.';

  @override
  String get publicHomeFavoritesJumpAction => 'See favorite cities';

  @override
  String get publicHomeFavoriteCardHint =>
      'Open the city details to compare costs, work, and arrival fit again.';

  @override
  String get mainNavHome => 'Home';

  @override
  String get mainNavFavorites => 'Favorites';

  @override
  String get mainNavCopilot => 'Move guide';

  @override
  String get mainNavDecision => 'Explore';

  @override
  String get mainNavExecution => 'Execution';

  @override
  String get mainNavExplore => 'Explore';

  @override
  String get mainNavPlan => 'Plan';

  @override
  String get mainNavProfile => 'Profile';

  @override
  String get mainNavPlanNeedsJourney =>
      'Choose your destination first so Movaro can open the right plan step.';

  @override
  String get mainNavFavoritesDisabled =>
      'Add at least 1 city to favorites to unlock this tab.';

  @override
  String get mainNavCopilotDisabled =>
      'Confirm a city in your plan to unlock the move guide.';

  @override
  String get favoritesEmptyTitle => 'No favorite cities yet';

  @override
  String get favoritesEmptyBody =>
      'When you favorite cities, they stay here together so you can track details, weather, and comparison faster.';

  @override
  String get favoritesEmptyHint =>
      'Explore cities, save the strongest ones, and come back here whenever you want to resume.';

  @override
  String get favoritesPageTitle => 'Favorites';

  @override
  String get stageClarityTitle => 'Clarity';

  @override
  String get stageClarityBody =>
      'Understand your starting point and review useful ways to begin.';

  @override
  String get stageClarityAction => 'Choose one path below';

  @override
  String get stageDecisionTitle => 'Explore options';

  @override
  String get stageDecisionBody =>
      'Get an initial shortlist and review the cities that seem most relevant now.';

  @override
  String get stageDecisionAction =>
      'Compare or confirm before starting preparation';

  @override
  String get stageExecutionTitle => 'Execution';

  @override
  String get stageExecutionBody =>
      'Turn the reviewed city into concrete next steps.';

  @override
  String get stageExecutionAction => 'Start with a suggested action';

  @override
  String favoritesPageCount(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get favoritesCompareTitle => 'Compare cities';

  @override
  String favoritesCompareSubtitle(Object left, Object right) {
    return '$left vs $right';
  }

  @override
  String get favoritesCompareAction => 'Compare';

  @override
  String get favoritesPageEmptyTitle => 'No saved cities';

  @override
  String get favoritesPageEmptyBody =>
      'Explore cities and save the ones that interest you most so you can compare them later.';

  @override
  String get favoritesAddCityTitle => 'Add city';

  @override
  String favoritesAddCitySubtitle(Object count) {
    return '$count slot(s) available';
  }

  @override
  String get favoritesActivePlanBadge => 'Active plan';

  @override
  String get favoritesContinuePlanAction => 'Continue plan';

  @override
  String get favoritesOpenDetailsAction => 'View details';

  @override
  String get favoritesRemoveAction => 'Remove';

  @override
  String get favoritesClimateLabel => 'Climate now';

  @override
  String get favoritesClimatePending => 'Loading';

  @override
  String get favoritesQualityLabel => 'Quality';

  @override
  String get cityComparisonTitle => 'Compare';

  @override
  String get cityComparisonCompareAction => 'Compare';

  @override
  String get cityComparisonEditAction => 'Edit';

  @override
  String get cityComparisonModeTwo => '2 cities';

  @override
  String get cityComparisonModeThree => '3 cities';

  @override
  String get cityComparisonAddAction => 'Add';

  @override
  String get cityComparisonSearchPlaceholder => 'Search city to compare...';

  @override
  String get cityComparisonHeaderLabel => 'Metric';

  @override
  String get cityComparisonBestFitBadge => 'STRONG MATCH';

  @override
  String get cityComparisonTopBadge => 'TOP';

  @override
  String get cityComparisonGroupCost => 'Cost of living';

  @override
  String get cityComparisonGroupQuality => 'Quality of life';

  @override
  String get cityComparisonGroupWork => 'Work and arrival';

  @override
  String get cityComparisonRentLabel => 'Estimated rent';

  @override
  String get cityComparisonFoodLabel => 'Monthly food cost';

  @override
  String get cityComparisonTransportLabel => 'Monthly transport cost';

  @override
  String get cityComparisonHdiLabel => 'HDI';

  @override
  String get cityComparisonClimateLabel => 'Current climate';

  @override
  String get cityComparisonSafetyLabel => 'Safety index';

  @override
  String get cityComparisonJobLabel => 'Job market';

  @override
  String get cityComparisonCommunityLabel => 'Immigrant community';

  @override
  String get cityComparisonCommunityLarge => 'Large';

  @override
  String get cityComparisonCommunityMedium => 'Medium';

  @override
  String get cityComparisonCommunitySmall => 'Small';

  @override
  String get cityComparisonWinnerLabel => 'CURRENT COMPARISON EDGE';

  @override
  String get cityComparisonUnavailable => '—';

  @override
  String cityComparisonStartPlanAction(Object city) {
    return 'Start plan in $city →';
  }

  @override
  String cityComparisonOtherDetailsAction(Object city) {
    return 'View details of $city';
  }

  @override
  String get favoritesExploreAction => 'Explore cities';

  @override
  String get favoritesGuideEyebrow => 'Quick guide';

  @override
  String get favoritesGuideTitle => 'How to use Favorites';

  @override
  String get favoritesGuideBody =>
      'Here you can keep up to 3 cities to revisit later without repeating your search. Use this area to compare better, reopen details, and decide with more clarity.';

  @override
  String get favoritesGuideStepOneTitle => 'Save the most promising cities';

  @override
  String get favoritesGuideStepOneBody =>
      'Use the heart on cards or in the detail page to keep the cities that make sense for you.';

  @override
  String get favoritesGuideStepTwoTitle => 'Come back for quick comparison';

  @override
  String get favoritesGuideStepTwoBody =>
      'Favorites keeps your picks in one place so you do not get lost between searches and filters.';

  @override
  String get favoritesGuideStepThreeTitle =>
      'Open the detail when you want to decide';

  @override
  String get favoritesGuideStepThreeBody =>
      'Tap a city to review context, weather, cost, and the main signals before moving forward.';

  @override
  String get favoritesGuideHideNextTime => 'Do not show again';

  @override
  String get favoritesGuideStepsLabel => '3 steps';

  @override
  String get favoritesGuideDismissAction => 'Not now';

  @override
  String get favoritesGuidePrimaryAction => 'Got it';

  @override
  String get profileJourneyTitle => 'Journey';

  @override
  String get profileJourneyBody =>
      'Movaro uses this route to keep home, exploration, and content connected to the same move context.';

  @override
  String profileJourneyValue(Object origin, Object destination) {
    return '$origin -> $destination';
  }

  @override
  String profileJourneyPendingValue(Object destination) {
    return 'Destination saved: $destination';
  }

  @override
  String get profileJourneyEmptyValue => 'No journey selected yet';

  @override
  String get profilePlanTitle => 'Plan status';

  @override
  String get profilePlanBody =>
      'Your saved plan stays connected to the journey so you can continue without starting from zero.';

  @override
  String get profilePlanEmptyValue => 'No plan generated yet';

  @override
  String profilePlanReadyValue(Object city) {
    return 'Ready to continue in $city';
  }

  @override
  String get profilePlanDraftValue => 'Draft result waiting for confirmation';

  @override
  String get profileSavedCitiesTitle => 'Saved cities';

  @override
  String get profileSavedCitiesBody =>
      'Keep up to 3 cities here so you can compare them again without losing your route or plan context.';

  @override
  String get publicHomeJourneyResetAction => 'Choose another route';

  @override
  String get publicHomeJourneyResetTitle => 'Choose another route?';

  @override
  String get publicHomeJourneyResetBody =>
      'Your current route is already saved on this device. If you restart it now, Movaro will open the route selection again so you can choose a different origin or destination.';

  @override
  String get publicHomeJourneyResetConfirm => 'Redo route';

  @override
  String get publicHomePlanResetTitle => 'Start another plan?';

  @override
  String get publicHomePlanResetBody =>
      'Your current plan will be removed from this device so you can answer the quick questions again from the beginning.';

  @override
  String cityWeatherSummary(Object temperature) {
    return '$temperature°C now';
  }

  @override
  String get introPageTitle => 'How Movaro works';

  @override
  String get introHeroTitle => 'Understand the app in under a minute';

  @override
  String get introHeroDescription =>
      'Movaro helps you compare cities, understand practical bureaucracy, and build an initial direction for your move without starting from information overload.';

  @override
  String get introExploreTitle => 'Explore cities with context';

  @override
  String get introExploreDescription =>
      'Use cost, safety, language adaptation, and local signals to understand why a city appears as a strong option.';

  @override
  String get introPlanTitle => 'Build a first plan';

  @override
  String get introPlanDescription =>
      'Answer a few questions and get a practical first direction for your next step.';

  @override
  String get introDocumentationTitle => 'Consult documentation when needed';

  @override
  String get introDocumentationDescription =>
      'Use the guide to understand CPF, registration, health, work, and approximate day-one costs.';

  @override
  String get introBetaTitle => 'What is available in this beta';

  @override
  String get introBetaDescription =>
      'This version focuses on clarity. You can explore cities, compare signals, and generate an initial plan before deeper account features arrive.';

  @override
  String get introBottomSupportLabel => 'Next step';

  @override
  String get introPrimaryAction => 'Start exploring';

  @override
  String get introSkipAction => 'Not now';

  @override
  String get cityPracticalAnswersTitle => 'Quick answers for common questions';

  @override
  String get cityPracticalLanguageQuestion =>
      'Would daily life feel easier if I still depend on Spanish?';

  @override
  String get cityPracticalCostQuestion =>
      'Does this city look manageable in day-to-day costs?';

  @override
  String get cityPracticalWorkQuestion =>
      'Does it look like a strong place to start working?';

  @override
  String get cityPracticalSafetyQuestion =>
      'Does it look easier to adapt with more routine stability?';

  @override
  String get cityPracticalLanguageEasy =>
      'It looks easier than average for a Spanish-speaking newcomer because the city combines stronger language adaptation and existing Argentine familiarity.';

  @override
  String get cityPracticalLanguageMedium =>
      'It looks manageable, but you would still benefit from basic Portuguese for daily routines.';

  @override
  String get cityPracticalLanguageHard =>
      'It may require faster Portuguese adaptation because Spanish support appears weaker in daily life.';

  @override
  String get cityPracticalCostEasy =>
      'Its cost signal looks friendlier for an initial move compared with the rest of the catalog.';

  @override
  String get cityPracticalCostMedium =>
      'It looks balanced, but you should still validate rent and neighborhood choices carefully.';

  @override
  String get cityPracticalCostHard =>
      'It may feel heavier at the start, so budget and housing research matter more here.';

  @override
  String get cityPracticalWorkStrong =>
      'It shows stronger signals for work opportunities and early economic structure.';

  @override
  String get cityPracticalWorkMedium =>
      'It can work depending on your profile, but your city choice should be more deliberate.';

  @override
  String get cityPracticalWorkLow =>
      'It looks less attractive if your main concern is finding work quickly.';

  @override
  String get cityPracticalSafetyGood =>
      'It looks better suited to a more stable daily routine within this initial catalog.';

  @override
  String get cityPracticalSafetyMedium =>
      'It looks reasonable, but local context and neighborhood choice still matter a lot.';

  @override
  String get cityPracticalSafetyLow =>
      'It deserves extra caution and more local validation before treating it as an easy move.';

  @override
  String get cityMetricBadgePositive => 'Favorable read';

  @override
  String get cityMetricBadgeNeutral => 'Needs balance';

  @override
  String get cityMetricBadgeAttention => 'Needs extra attention';

  @override
  String get cityMetricCostLowHeadline => 'Low';

  @override
  String get cityMetricCostLowSupporting =>
      'Lighter on your day-to-day budget.';

  @override
  String get cityMetricCostMediumHeadline => 'Balanced';

  @override
  String get cityMetricCostMediumSupporting =>
      'A reasonable balance between routine costs and infrastructure.';

  @override
  String get cityMetricCostHighHeadline => 'High';

  @override
  String get cityMetricCostHighSupporting =>
      'It will require more care with rent and monthly expenses.';

  @override
  String get cityMetricSafetyHighHeadline => 'High';

  @override
  String get cityMetricSafetyHighSupporting =>
      'A more comfortable read for daily life at the start.';

  @override
  String get cityMetricSafetyMediumHeadline => 'Medium';

  @override
  String get cityMetricSafetyMediumSupporting =>
      'It depends more on neighborhood and local context.';

  @override
  String get cityMetricSafetyLowHeadline => 'Low';

  @override
  String get cityMetricSafetyLowSupporting =>
      'It deserves more validation before treating it as an easy move.';

  @override
  String get cityMetricLanguageEasyHeadline => 'Easy';

  @override
  String get cityMetricLanguageEasySupporting =>
      'Usually friendlier if you arrive speaking Spanish.';

  @override
  String get cityMetricLanguageMediumHeadline => 'Moderate';

  @override
  String get cityMetricLanguageMediumSupporting =>
      'Basic Portuguese still helps a lot in daily life.';

  @override
  String get cityMetricLanguageHardHeadline => 'Hard';

  @override
  String get cityMetricLanguageHardSupporting =>
      'Language tends to matter more in day-to-day integration.';

  @override
  String get cityMetricWorkStrongHeadline => 'Strong';

  @override
  String get cityMetricWorkStrongSupporting =>
      'A more favorable city if you are looking for opportunities.';

  @override
  String get cityMetricWorkMediumHeadline => 'Balanced';

  @override
  String get cityMetricWorkMediumSupporting =>
      'It can work well, but it depends more on your profile.';

  @override
  String get cityMetricWorkLowHeadline => 'Limited';

  @override
  String get cityMetricWorkPreliminaryHeadline => 'Preliminary';

  @override
  String get cityMetricWorkPreliminarySupporting =>
      'Municipal formal-employment data is not integrated yet.';

  @override
  String get cityMetricWorkLowSupporting =>
      'It requires more strategy if quick work is your priority.';

  @override
  String get cityIdhmVeryHigh => 'Very high development';

  @override
  String get cityIdhmVeryHighSupporting =>
      'Among the strongest municipal levels in the official indicator.';

  @override
  String get cityIdhmHigh => 'High development';

  @override
  String get cityIdhmHighSupporting =>
      'A solid human development reading in the official reference.';

  @override
  String get cityIdhmMedium => 'Medium development';

  @override
  String get cityIdhmMediumSupporting =>
      'It should be read together with cost and opportunity context.';

  @override
  String get cityIdhmLow => 'Low development';

  @override
  String get cityIdhmLowSupporting =>
      'It needs more caution before assuming a strong overall structure.';

  @override
  String get cityIdhmVeryLow => 'Very low development';

  @override
  String get cityIdhmVeryLowSupporting =>
      'It signals a weaker base in the official indicator.';

  @override
  String get citySnapshotRentLower => 'Lighter rent';

  @override
  String get citySnapshotRentLowerSupporting =>
      'It tends to weigh less at the start of the move.';

  @override
  String get citySnapshotRentModerate => 'Moderate rent';

  @override
  String get citySnapshotRentModerateSupporting =>
      'It calls for balance between neighborhood, contract, and routine.';

  @override
  String get citySnapshotRentHigher => 'Higher rent';

  @override
  String get citySnapshotRentHigherSupporting =>
      'It will require more care before closing housing.';

  @override
  String get cityHousingViabilityTileLabel => 'Housing entry';

  @override
  String get cityHousingViabilityEasyHeadline => 'Lighter entry';

  @override
  String get cityHousingViabilityEasySupporting =>
      'It tends to allow a softer landing, with less rent pressure and more room to adjust neighborhood and routine.';

  @override
  String get cityHousingViabilityEasyBadge => 'Good for soft landing';

  @override
  String get cityHousingViabilityBalancedHeadline => 'Balanced entry';

  @override
  String get cityHousingViabilityBalancedSupporting =>
      'It can work well if you arrive with savings and validate the neighborhood, guarantee, and total setup cost before signing.';

  @override
  String get cityHousingViabilityBalancedBadge => 'Needs validation';

  @override
  String get cityHousingViabilityHardHeadline => 'Needs more cash';

  @override
  String get cityHousingViabilityHardSupporting =>
      'Here, rent and entry costs tend to weigh more. Treat housing as a serious filter before choosing the city.';

  @override
  String get cityHousingViabilityHardBadge => 'High housing pressure';

  @override
  String get cityMetricInsightTapHint =>
      'Tap to understand the data behind this read.';

  @override
  String get cityMetricInsightQuickReadTitle => 'A few-second read';

  @override
  String get cityMetricInsightMeaningTitle => 'What this means';

  @override
  String get cityMetricInsightMethodTitle => 'How we reached this read';

  @override
  String get cityMetricInsightFactsTitle => 'What supports this read';

  @override
  String get cityMetricInsightValidateTitle =>
      'What to validate before deciding';

  @override
  String get cityMetricInsightSourcesTitle => 'Sources and limits';

  @override
  String get cityMetricInsightDisclaimer =>
      'This is comparative guidance, not an official assessment or individual recommendation. Confirm prices, neighborhood, and current conditions before deciding.';

  @override
  String get cityMetricInsightCurrentBaseBadge => 'Current base';

  @override
  String get cityMetricInsightDerivedOfficialBadge =>
      'Derived from official data';

  @override
  String get cityMetricInsightExternalEstimateBadge => 'External estimate';

  @override
  String get cityMetricInsightInternalMethodBadge => 'Internal method';

  @override
  String get cityMetricInsightOfficialConsultationBadge => 'Official check';

  @override
  String get cityMetricInsightOpenSourceAction => 'Open source';

  @override
  String get cityMetricInsightRangeLabel => 'This card range';

  @override
  String get cityMetricInsightSpanishSupportLabel => 'Spanish support';

  @override
  String get cityMetricInsightLanguageCurrentBaseTitle =>
      'Practical adaptation read';

  @override
  String get cityMetricInsightHousingMeaning =>
      'Use this read to understand whether rent and monthly routine may require a larger arrival reserve. It is not a guaranteed price.';

  @override
  String get cityMetricInsightHousingMethod =>
      'When a monthly city estimate exists, we use the routine and rent range reported by the external source. Without that coverage, we show only an internal comparison with the rest of the catalog.';

  @override
  String get cityMetricInsightHousingValidate =>
      'Compare real rent, deposit, guarantees, furniture, and neighborhood cost before signing. Housing mistakes usually cost more here.';

  @override
  String get cityMetricInsightSafetyMeaning =>
      'This alert does not mean the city is unworkable. It means neighborhood choice, routine, and local validation matter more before treating the move as simple.';

  @override
  String get cityMetricInsightSafetyMethod =>
      'The signal combines the latest three-year municipal average of registered homicides with a smaller share of the previous comparative context. The rate comes from the Atlas of Violence/Ipea using SIM/MS data; the final score is derived and is not an official ranking.';

  @override
  String get cityMetricInsightSafetyValidate =>
      'Check neighborhood by neighborhood, nighttime travel, the real routine of residents, and the difference between tourist and residential areas.';

  @override
  String get cityMetricInsightSafetyOfficialRateLabel =>
      'Observed official average';

  @override
  String cityMetricInsightSafetyRateValue(Object value) {
    return '$value per 100k/year';
  }

  @override
  String get cityMetricInsightReferencePeriodLabel => 'Reference period';

  @override
  String get cityMetricInsightWorkMeaning =>
      'Moderate market is not a blocker. It means the city can work, but the result depends more on your field, seniority, and entry path.';

  @override
  String get cityMetricInsightWorkMethod =>
      'The current read is preliminary while the catalog has no integrated municipal formal-employment data. Sectors and economic context are only clues; real openings and official data should confirm the decision.';

  @override
  String get cityMetricInsightWorkValidate =>
      'Look for real openings in your field, see which sectors pull the city, and estimate how much runway you have until your first income.';

  @override
  String get cityMetricInsightLanguageMeaning =>
      'Harder adaptation means Portuguese is likely to weigh more in day-to-day integration and that informal Spanish support appears weaker.';

  @override
  String get cityMetricInsightLanguageMethod =>
      'This is a non-official heuristic based on Argentine presence and perceived Spanish support. It helps compare early adaptation, but does not measure individual proficiency or every neighborhood experience.';

  @override
  String get cityMetricInsightLanguageValidate =>
      'Test the routine without relying on Spanish: housing, groceries, healthcare, services, and work. If that becomes a blocker, real adaptation in the city is tougher for your profile.';

  @override
  String get citySnapshotPopularityHigh => 'Highly sought after';

  @override
  String get citySnapshotPopularityHighSupporting =>
      'It already shows strong affinity among Argentinians.';

  @override
  String get citySnapshotPopularityMedium => 'Moderate popularity';

  @override
  String get citySnapshotPopularityMediumSupporting =>
      'It has a reasonable level of familiarity within the current catalog.';

  @override
  String get citySnapshotPopularityLow => 'Less frequent';

  @override
  String get citySnapshotPopularityLowSupporting =>
      'It still appears less in the initial Argentinian interest slice.';

  @override
  String get citySnapshotUnemploymentLower => 'Lower unemployment';

  @override
  String get citySnapshotUnemploymentModerate => 'Moderate unemployment';

  @override
  String get citySnapshotUnemploymentHigher => 'Higher unemployment';

  @override
  String get languageSelectorTooltip => 'Choose language';

  @override
  String get languageOptionSpanishArgentina => 'Español (Argentina)';

  @override
  String get languageOptionEnglish => 'English';

  @override
  String get languageOptionPortuguese => 'Português';

  @override
  String get commonRetryAction => 'Try again';

  @override
  String get commonBackAction => 'Back';

  @override
  String get commonGotItAction => 'Got it';

  @override
  String get protectedCommunityCreateTitle => 'Create post';

  @override
  String get protectedCommunityCreateDescription =>
      'This area will allow community posting once that flow is enabled.';

  @override
  String get questionOriginCountryTitle => 'Where are you coming from?';

  @override
  String get journeyEntryTitle => 'Choose your destination and start faster';

  @override
  String get journeyEntryBody =>
      'Pick where you want to move first. Movaro will save that choice now and ask for your origin in the first step of the questionnaire.';

  @override
  String get journeyEntryDestinationLabel => 'Where do you want to go?';

  @override
  String get journeyEntryStartAction => 'Start my plan';

  @override
  String get journeyEntryDynamicTitle =>
      'Start with a route that matches where you are and where you want to go';

  @override
  String get journeyEntryDynamicBody =>
      'You can use your current location as a quick hint or choose everything manually. Movaro never locks your origin from device location, and you can always override it.';

  @override
  String get journeyEntryUseLocationTitle => 'Use my location';

  @override
  String get journeyEntryUseLocationBody =>
      'Ask only now, detect your current country if possible, and let you confirm whether it should be used as origin.';

  @override
  String get journeyEntryUseLocationAction => 'Use my location';

  @override
  String get journeyEntryManualTitle => 'Choose manually';

  @override
  String get journeyEntryManualBody =>
      'Skip location, set origin and destination yourself, and keep full control over the route.';

  @override
  String get journeyEntryManualAction => 'Choose manually';

  @override
  String get journeyEntryContinueAction => 'Continue with quick questions';

  @override
  String journeyEntrySelectedDestination(Object destination) {
    return 'Destination selected: $destination';
  }

  @override
  String get journeyEntryOriginPending =>
      'We\'ll collect your origin in the first question before plan generation.';

  @override
  String get journeySetupFlowHint =>
      'If there is only one route available right now, Movaro fills it in for you. If there is more than one option, you choose it manually.';

  @override
  String get journeySetupManualChangeHint =>
      'You can change origin and destination later without restarting the app.';

  @override
  String journeySetupDetectedOriginHint(Object country) {
    return 'We detected $country as an origin suggestion. You can confirm it or change it manually.';
  }

  @override
  String get journeySetupOriginAssistHint =>
      'Use your location only if you want an origin suggestion. Manual selection stays available.';

  @override
  String get journeyLocationPanelTitle =>
      'Location can save one step, but it never decides for you';

  @override
  String get journeyLocationPanelBody =>
      'If you allow location, Movaro tries to detect your current country and suggests it as origin. You can reject the suggestion and choose manually instead.';

  @override
  String get journeyLocationFallbackTitle =>
      'Location did not resolve a usable country';

  @override
  String get journeyLocationDeniedBody =>
      'Location permission was denied. You can keep going by choosing origin and destination manually.';

  @override
  String get journeyLocationDeniedForeverBody =>
      'Location permission is blocked for this app right now. You can still continue with manual selection.';

  @override
  String get journeyLocationUnavailableBody =>
      'Location services are off on this device. Turn them on if you want a location hint, or continue manually.';

  @override
  String get journeyLocationFailedBody =>
      'Movaro could not detect your location this time. You can retry or choose manually.';

  @override
  String get journeyLocationRetryAction => 'Try again';

  @override
  String journeyDetectedLocationLabel(Object value) {
    return 'Detected location: $value';
  }

  @override
  String journeyDetectedConfirmBody(Object country) {
    return 'Use $country as your origin? This only sets a suggestion you can edit at any time.';
  }

  @override
  String journeyDetectedUnknownBody(Object country) {
    return 'Movaro detected $country, but it could not match that country to the current route catalog. Choose your origin manually to continue.';
  }

  @override
  String journeyDetectedConfirmAction(Object country) {
    return 'Use $country as origin';
  }

  @override
  String get questionnaireOriginAutoDetectTitle => 'We found your location';

  @override
  String get questionnaireOriginUnsupportedTitle =>
      'This country is not supported yet';

  @override
  String get questionnaireOriginLocationFailedTitle =>
      'We could not detect your location';

  @override
  String questionnaireOriginUnsupportedBody(Object country) {
    return 'Movaro detected $country, but the guided plan is only available for people coming from Argentina right now. You can choose Argentina manually or use it to continue.';
  }

  @override
  String get questionnaireOriginUseArgentinaAction => 'Use Argentina';

  @override
  String get journeyDetectedManualAction => 'Choose origin manually';

  @override
  String get journeyOriginSectionTitle => 'Origin';

  @override
  String get journeyOriginSectionBody =>
      'Optional for now. Confirm it here if you already know it, or skip and answer it in the first questionnaire step.';

  @override
  String get journeyOriginSkipAction => 'Skip for now';

  @override
  String get journeyDestinationSectionTitle => 'Destination';

  @override
  String get journeyDestinationSectionBody =>
      'Choose where you want the migration plan to point. Destination is still required before the questionnaire starts.';

  @override
  String get journeyPickerChooseDestinationTitle => 'Choose destination';

  @override
  String get journeyPickerChooseOriginTitle => 'Choose origin';

  @override
  String get journeyPickerSearchHint => 'Search country';

  @override
  String get journeyPickerNoResults => 'No countries found';

  @override
  String get journeyCoverageFull => 'Full coverage';

  @override
  String get journeyCoveragePartial => 'Partial coverage';

  @override
  String get journeyCoverageUnsupported => 'Unsupported';

  @override
  String get journeyCoverageReadyTitle => 'This route is ready for planning';

  @override
  String journeyCoverageReadyBody(Object origin, Object destination) {
    return '$origin -> $destination is supported in the current migration flow.';
  }

  @override
  String get journeyCoverageDestinationLimitedTitle =>
      'Destination coverage is still limited';

  @override
  String journeyCoverageDestinationLimitedBody(Object destination) {
    return '$destination does not yet have full destination coverage for the guided migration flow. You can still explore content while the route expands.';
  }

  @override
  String get journeyCoverageOriginLimitedTitle =>
      'Origin coverage is still limited';

  @override
  String journeyCoverageOriginLimitedBody(Object origin) {
    return '$origin can be saved as your origin, but the current guided plan does not fully support that starting country yet.';
  }

  @override
  String get journeyCoverageDetectedUnknownTitle =>
      'Detected country is outside the current catalog';

  @override
  String journeyCoverageDetectedUnknownBody(Object country) {
    return '$country is not mapped in the current supported-country catalog yet. Choose another origin manually or keep browsing public content.';
  }

  @override
  String get journeyCoverageUnsupportedTitle =>
      'Choose a supported route to generate a plan';

  @override
  String get journeyCoverageUnsupportedBody =>
      'Movaro can still show cities and practical content, but the guided migration flow is only available on routes with full coverage.';

  @override
  String get journeyCoverageChooseRouteAction => 'Choose another route';

  @override
  String get journeyCoverageBrowseAction => 'Browse explore';

  @override
  String get journeyCoverageContentAction => 'Open content';

  @override
  String get journeyCoverageWaitlistAction => 'Join waitlist';

  @override
  String get journeyCoverageWaitlistStub =>
      'Waitlist registration is not live yet, but this route can be tracked safely for future coverage.';

  @override
  String get questionDestinationCountryTitle => 'Where do you want to go?';

  @override
  String get questionGoalTitle => 'What do you want to do in the new country?';

  @override
  String get questionPortugueseFamiliarityTitle =>
      'How comfortable are you with Portuguese today?';

  @override
  String get questionTimelineTitle => 'When are you planning to move?';

  @override
  String get questionOptionArgentina => 'Argentina';

  @override
  String get questionOptionBrazil => 'Brazil';

  @override
  String get questionOptionChile => 'Chile';

  @override
  String get questionOptionUruguay => 'Uruguay';

  @override
  String get questionOptionParaguay => 'Paraguay';

  @override
  String get questionOptionUnknown => 'I still do not know';

  @override
  String get questionOptionWork => 'Work';

  @override
  String get questionOptionRemoteWork => 'Work remotely';

  @override
  String get questionOptionStudy => 'Study';

  @override
  String get questionOptionEntrepreneur => 'Start a business';

  @override
  String get questionOptionRetire => 'Retire';

  @override
  String get questionOptionQualityOfLife => 'Quality of life';

  @override
  String get questionOptionBeachLife => 'Beach and coast';

  @override
  String get questionOptionNoPortuguese => 'I still depend mostly on Spanish';

  @override
  String get questionOptionBasicPortuguese => 'I can handle basic Portuguese';

  @override
  String get questionOptionComfortablePortuguese =>
      'I can already live in Portuguese';

  @override
  String get questionOptionResearching => 'I am just researching';

  @override
  String get questionOption12Months => 'Within the next 12 months';

  @override
  String get questionOption6Months => 'Within the next 6 months';

  @override
  String get questionOptionAsap => 'As soon as possible';

  @override
  String get recommendationReasonEconomical =>
      'A good option if cost matters to you';

  @override
  String get recommendationReasonPopularArgentina =>
      'Popular among Argentinians';

  @override
  String get recommendationReasonLanguageSupport =>
      'Easier adaptation if you still depend on Spanish';

  @override
  String get recommendationReasonWorkMarket => 'Stronger job market';

  @override
  String get recommendationReasonInfrastructure =>
      'Higher cost, but stronger infrastructure';

  @override
  String get recommendationReasonBalanced =>
      'A balanced option within the initial Movaro catalog';

  @override
  String get planReasonGoalWork =>
      'It stands out if you are looking for more work opportunities.';

  @override
  String get planReasonGoalRemoteWork =>
      'It fits better if you want remote work and a better balance between cost and quality of life.';

  @override
  String get planReasonGoalStudy =>
      'It has a good mix of urban structure and early adaptation for studying.';

  @override
  String get planReasonGoalEntrepreneur =>
      'It shows stronger economic activity for someone who wants to start a business.';

  @override
  String get planReasonGoalRetire =>
      'It makes more sense if you are looking for more safety and a more controlled cost of living.';

  @override
  String get planReasonGoalQualityOfLife =>
      'It fits better if you are prioritizing quality of life and gradual adaptation.';

  @override
  String get planReasonGoalBeachLife =>
      'It makes more sense if you want to prioritize the coast, the beach, and a routine more connected to the sea.';

  @override
  String get planReasonLanguageNeedsSupport =>
      'You said you still depend on Spanish, so we gave more weight to places with stronger language adaptation.';

  @override
  String get planReasonLanguageBasic =>
      'You said you only handle basic Portuguese, so language adaptation still influenced the recommendation.';

  @override
  String get planReasonTimelineAsap =>
      'It may help with a faster move by combining easier early adaptation and more practical daily life.';

  @override
  String get planReasonTimeline6Months =>
      'It works well for a shorter moving timeline.';

  @override
  String get planReasonTimeline12Months =>
      'It offers a balanced base for someone still structuring the move.';

  @override
  String get planStepTitleVisaResidence => 'Review residency or visa type';

  @override
  String get planStepDescriptionVisaResidence =>
      'Map the right migration path for your main reason to move.';

  @override
  String get planStepTitleCpf => 'Get a CPF';

  @override
  String get planStepDescriptionCpf =>
      'Organize the tax registration needed for services and transactions in Brazil.';

  @override
  String get planStepTitleBankAccount => 'Open a bank account';

  @override
  String get planStepDescriptionBankAccount =>
      'Set up a local account for your first financial steps.';

  @override
  String get planStepTitleHousing => 'Look for housing';

  @override
  String get planStepDescriptionHousing =>
      'Research neighborhoods, contracts, and costs for a safer move.';

  @override
  String get planStepTitleSettleDocuments => 'Regularize local documents';

  @override
  String get planStepDescriptionSettleDocuments =>
      'Review additional registrations, proof documents, and local administrative steps.';

  @override
  String get planStepTitleMapDestinations => 'Map possible destinations';

  @override
  String get planStepDescriptionMapDestinations =>
      'Compare destination options based on your goal and moving window.';

  @override
  String get planStepTitleDecisionCriteria => 'Define decision criteria';

  @override
  String get planStepDescriptionDecisionCriteria =>
      'Organize priorities such as cost, paperwork, and quality of life.';

  @override
  String get planBeachDecisionTitle => 'Coastline in the decision';

  @override
  String get planBeachDecisionIntro =>
      'If beach and coast are part of your criteria, do not look only at beauty or tourism. The real filter is housing entry, city pace, and soft landing.';

  @override
  String get planBeachDecisionCoastalHeadline =>
      'Your current city match already points to the coast';

  @override
  String planBeachDecisionCoastalBody(Object cityName) {
    return '$cityName already fits the coastal-city filter. A useful next check is whether housing entry and local routine match your current situation.';
  }

  @override
  String get planBeachDecisionNotCoastalHeadline =>
      'Your beach criterion needs an extra comparison';

  @override
  String get planBeachDecisionNotCoastalBody =>
      'Even with this goal, it is worth comparing beach cities before making a decision. Not every city that looks strong in the plan delivers the coastal routine you may be looking for.';

  @override
  String get planBeachDecisionPriorityNote =>
      'If beach is a priority, treat housing and local routine as your main filter.';

  @override
  String get planBeachDecisionHousingHeadline => 'Housing entry on the coast';

  @override
  String get stepCategoryDocumentation => 'Documentation';

  @override
  String get stepCategoryFinancial => 'Finance';

  @override
  String get stepCategoryHousing => 'Housing';

  @override
  String get stepCategorySettlement => 'Settlement';

  @override
  String get stepCategoryResearch => 'Research';

  @override
  String get stepCategoryPlanning => 'Planning';

  @override
  String get industryAgribusiness => 'Agribusiness';

  @override
  String get industryCommerce => 'Commerce';

  @override
  String get industryConstruction => 'Construction';

  @override
  String get industryEnergy => 'Energy';

  @override
  String get industryFinance => 'Finance';

  @override
  String get industryIndustry => 'Industry';

  @override
  String get industryLogistics => 'Logistics';

  @override
  String get industryPort => 'Port';

  @override
  String get industryHealth => 'Health';

  @override
  String get industryServices => 'Services';

  @override
  String get industryTechnology => 'Technology';

  @override
  String get industryTourism => 'Tourism';

  @override
  String get errorNetworkTitle => 'It looks like you are offline.';

  @override
  String get errorNetworkDescription =>
      'Check your connection and try again in a moment.';

  @override
  String get errorServerTitle => 'Something went wrong. Try again.';

  @override
  String get errorServerDescription =>
      'We could not complete this action right now. Try again in a moment.';

  @override
  String get errorNotFoundTitle => 'We could not find this information.';

  @override
  String get errorNotFoundDescription =>
      'This content is not available right now or is not part of this catalog yet.';

  @override
  String get errorUnauthorizedTitle => 'You need to sign in to continue.';

  @override
  String get errorUnauthorizedDescription =>
      'Some actions need to be linked to you before they can be saved.';

  @override
  String get errorUnknownTitle => 'Something unexpected happened.';

  @override
  String get errorUnknownDescription => 'Try again in a moment.';

  @override
  String get errorValidationTitle => 'We could not complete this request.';

  @override
  String get errorNetworkMovaroDescription =>
      'We could not reach Movaro right now. Try again in a moment.';

  @override
  String get errorApiGenericDescription =>
      'We could not complete this action right now.';

  @override
  String get apiUnavailableTitle => 'Movaro could not reach the API right now.';

  @override
  String get apiUnavailableDescription =>
      'The app opened, but the main service is unavailable at the moment. Without this connection, it cannot load your journey with real data.';

  @override
  String get apiUnavailableSupportingText =>
      'Try again in a moment. If this keeps happening, check whether the API is online and whether this environment is pointing to the correct URL.';

  @override
  String get apiUnavailableRetryAction => 'Try again';

  @override
  String get sourceProviderIbgeLocalities => 'IBGE Localities';

  @override
  String get sourceProviderIbgeCities => 'IBGE Cities and States';

  @override
  String get sourceProviderAtlasHumanDevelopment =>
      'Human Development Atlas in Brazil (UNDP, Ipea, and FJP)';

  @override
  String get sourceProviderMovaroDataset =>
      'Internal comparative dataset (not official)';

  @override
  String get sourceProviderMovaroRanking =>
      'Internal comparative methodology (not official)';

  @override
  String get sourceProviderGoogleMaps => 'Google Maps';

  @override
  String get sourceProviderReceitaFederalGovBr => 'Federal Revenue / Gov.br';

  @override
  String get sourceProviderArgentinaMigraciones =>
      'Argentina.gob.ar / Migration Office';

  @override
  String get sourceProviderPoliciaFederal => 'Federal Police';

  @override
  String get sourceProviderPoliciaFederalGovBr => 'Federal Police / Gov.br';

  @override
  String get sourceProviderMrePoliciaFederal =>
      'Foreign Ministry / Federal Police';

  @override
  String get sourceProviderMreBancoCentral => 'Foreign Ministry / Central Bank';

  @override
  String get sourceProviderMinisterioJustica => 'Ministry of Justice';

  @override
  String get sourceProviderMinisterioSaude => 'Gov.br / Ministry of Health';

  @override
  String get sourceProviderMeuSusDigital => 'Meu SUS Digital / Gov.br';

  @override
  String get sourceProviderAns => 'ANS';

  @override
  String get sourceProviderDetranEsMgGov => 'Detran-ES / MG.gov.br';

  @override
  String get sourceProviderSenatranMgGov => 'SENATRAN / MG.gov.br';

  @override
  String get sourceProviderMteCtps => 'Labor Ministry / Digital Work Card';

  @override
  String get sourceProviderPortalEmpreendedorInss =>
      'Entrepreneur Portal / INSS';

  @override
  String get sourceProviderMinisterioPrevidenciaInss =>
      'Ministry of Social Security / INSS';

  @override
  String get sourceProviderIbgePnadContinua => 'IBGE / Continuous PNAD';

  @override
  String get sourceProviderForumBrasileiroSegurancaPublica =>
      'Brazilian Forum of Public Security';

  @override
  String get sourceProviderBancoCentralBrasil => 'Central Bank of Brazil';

  @override
  String get sourceProviderMovaro =>
      'Checklist based on your answers (not official)';

  @override
  String get documentReadinessSectionTitle =>
      'Document readiness before the move';

  @override
  String get documentReadinessPriorityCritical => 'Critical now';

  @override
  String get documentReadinessPriorityPrepare => 'Prepare with lead time';

  @override
  String get documentReadinessPriorityArrival => 'Keep ready on arrival';

  @override
  String get documentReadinessSummaryResearching =>
      'Before comparing too many paths, make sure your move depends on a document pack that can actually be assembled without surprises.';

  @override
  String get documentReadinessSummaryTwelveMonths =>
      'With more time, the goal is to remove preventable document risk early instead of discovering missing items close to the move.';

  @override
  String get documentReadinessSummarySixMonths =>
      'Six months is enough to organize the hard documents now and make the arrival layer lighter.';

  @override
  String get documentReadinessSummaryAsap =>
      'Since the move is close, focus first on the documents that can block residency, banking, and housing.';

  @override
  String get documentReadinessRouteTitle => 'Validate the legal entry route';

  @override
  String get documentReadinessRouteBodyBrazil =>
      'Confirm whether your move will rely on the Mercosur residence path and what that route demands before you plan around assumptions.';

  @override
  String get documentReadinessRouteBodyGeneric =>
      'Confirm the legal route for the destination first so the rest of the checklist is built on the correct migration path.';

  @override
  String get documentReadinessIdentityPackTitle =>
      'Separate the core identity pack';

  @override
  String get documentReadinessIdentityPackBody =>
      'Keep your passport, birth records, criminal records, and personal identifiers in one reviewed bundle before opening other fronts.';

  @override
  String get documentReadinessApostilleTitle =>
      'Review apostille and validity windows';

  @override
  String get documentReadinessApostilleBodyBrazil =>
      'For Brazil, check which Argentine documents need an apostille, how recent they must be, and what may expire before arrival.';

  @override
  String get documentReadinessRuleCheckTitle =>
      'Check official document rules early';

  @override
  String get documentReadinessRuleCheckBody =>
      'Map which documents must be original, apostilled, translated, or reissued so the move does not depend on assumptions.';

  @override
  String get documentReadinessTranslationTitle =>
      'Map translation needs before paying twice';

  @override
  String get documentReadinessTranslationBodyBrazil =>
      'Separate what can stay in Spanish from what may require sworn translation in Brazil, especially for residency and civil proof.';

  @override
  String get documentReadinessTranslationBodyGeneric =>
      'Separate what can remain in the source language from what may require certified translation in the destination country.';

  @override
  String get documentReadinessHousingProofTitle =>
      'Prepare proof for housing and routine setup';

  @override
  String get documentReadinessHousingProofBodyBrazil =>
      'Group proof of income, savings, identification, and any supporting papers that landlords, banks, or guarantee products may ask for in Brazil.';

  @override
  String get documentReadinessProofPackTitle =>
      'Build your practical proof pack';

  @override
  String get documentReadinessProofPackBody =>
      'Group identity, proof of funds, income evidence, and the documents that usually unlock banking, housing, and essential services.';

  @override
  String get documentReadinessCpfTitle =>
      'Treat CPF and regular status as one layer';

  @override
  String get documentReadinessCpfBodyBrazil =>
      'CPF, residency follow-up, and your first local proof often unlock the practical side of arrival. Keep that bundle ready to execute quickly.';

  @override
  String get documentReadinessCopiesTitle =>
      'Keep physical and digital backups aligned';

  @override
  String get documentReadinessCopiesBody =>
      'Save scans, originals, and emergency copies in a structure that can be accessed from your phone and used in person if needed.';

  @override
  String get documentReadinessArrivalFolderTitle =>
      'Prepare an arrival folder, not scattered files';

  @override
  String get documentReadinessArrivalFolderBodyBrazil =>
      'Create one arrival folder with residency follow-up, CPF references, address notes, and the proof most likely to be requested in the first month.';

  @override
  String get documentReadinessArrivalFolderBodyGeneric =>
      'Create one arrival folder with the first documents, local proof notes, and the evidence you are most likely to need in the first weeks.';

  @override
  String get documentReadinessGoalWorkTitle =>
      'Protect your employability documents';

  @override
  String get documentReadinessGoalWorkBodyBrazil =>
      'Review what can block early work in Brazil: identity consistency, residence follow-up, and any profession-specific proof you may need to show quickly.';

  @override
  String get documentReadinessGoalWorkBodyGeneric =>
      'Review what can block early work in the destination: identity consistency, immigration status, and profession-specific proof.';

  @override
  String get documentReadinessGoalRemoteTitle =>
      'Stabilize the document base for remote income';

  @override
  String get documentReadinessGoalRemoteBodyBrazil =>
      'Keep tax identity, banking references, and proof that supports contracts, transfers, and a stable routine in Brazil.';

  @override
  String get documentReadinessGoalRemoteBodyGeneric =>
      'Keep tax identity, banking references, and the proof that supports contracts and international income flow in the new country.';

  @override
  String get documentReadinessGoalStudyTitle =>
      'Protect the study path with the right records';

  @override
  String get documentReadinessGoalStudyBodyBrazil =>
      'Keep admissions, school records, identity documents, and time-sensitive paperwork aligned before relying on study as the entry path.';

  @override
  String get documentReadinessGoalStudyBodyGeneric =>
      'Keep admissions, school records, identity documents, and time-sensitive paperwork aligned before relying on study as the base.';

  @override
  String get documentReadinessGoalEntrepreneurTitle =>
      'Prepare the operating document layer';

  @override
  String get documentReadinessGoalEntrepreneurBodyBrazil =>
      'Separate the identity, banking, and residency proof that will affect how safely you can start operating once in Brazil.';

  @override
  String get documentReadinessGoalEntrepreneurBodyGeneric =>
      'Separate the identity, banking, and immigration proof that will affect how safely you can start operating in the destination country.';

  @override
  String get documentReadinessGoalRetireTitle =>
      'Protect a calm arrival with reviewed paperwork';

  @override
  String get documentReadinessGoalRetireBodyBrazil =>
      'Favor the document set that reduces surprises in health access, banking, and recurring routine once you land in Brazil.';

  @override
  String get documentReadinessGoalRetireBodyGeneric =>
      'Favor the document set that reduces surprises in health access, banking, and recurring routine once you arrive.';

  @override
  String get documentReadinessGoalQualityTitle =>
      'Use documents to reduce friction, not just to comply';

  @override
  String get documentReadinessGoalQualityBodyBrazil =>
      'Even when quality of life is the goal, the smoother move is the one with identity, proof, and arrival paperwork already structured for Brazil.';

  @override
  String get documentReadinessGoalQualityBodyGeneric =>
      'Even when quality of life is the goal, the smoother move is the one with identity, proof, and arrival paperwork already structured.';

  @override
  String get documentReadinessRiskBlocking => 'Can block the move';

  @override
  String get documentReadinessRiskCaution => 'Avoids delay and rework';

  @override
  String get documentReadinessRiskReview => 'Review at the right stage';

  @override
  String get documentReadinessReviewBeforeBooking =>
      'Review before booking travel';

  @override
  String get documentReadinessReviewCloseToMove =>
      'Reconfirm close to the move';

  @override
  String get documentReadinessReviewOnArrival => 'Keep ready for arrival';

  @override
  String documentReadinessSourceLabel(Object source) {
    return 'Base: $source';
  }

  @override
  String get housingDecisionSectionTitle =>
      'Housing is a critical decision before the city';

  @override
  String housingDecisionSectionTitleWithCity(Object city) {
    return 'Housing may decide whether $city works for you';
  }

  @override
  String get housingDecisionSectionBody =>
      'Before choosing the city, understand how rent and guarantees work in Brazil. The biggest risk is not only the monthly price: it is landing without a viable path for the contract, neighborhood, and initial setup.';

  @override
  String housingDecisionSectionBodyWithCity(Object city) {
    return 'Before treating $city as a strong option, validate whether rent, guarantees, and initial setup look viable for your current situation. The risk is not only the price, but the real path to secure housing.';
  }

  @override
  String get housingDecisionGuaranteesTitle => 'Guarantees can block the lease';

  @override
  String get housingDecisionGuaranteesBody =>
      'A local guarantor still matters in many contracts. If that is not realistic for you, compare deposit, guarantee insurance, capitalization products, and income-proof requirements before counting on a neighborhood.';

  @override
  String get housingDecisionSoftLandingTitle =>
      'A softer landing avoids expensive mistakes';

  @override
  String get housingDecisionSoftLandingBody =>
      'Temporary, furnished, coliving, or short contracts for 30 to 90 days are usually safer than taking a long lease before you understand the local routine.';

  @override
  String get housingDecisionProofPackTitle =>
      'Carry the folder that unlocks the conversation';

  @override
  String get housingDecisionProofPackBody =>
      'Keep identity, income, cash reserve, references, and digital proof in one folder. It does not guarantee approval, but it reduces friction from the first contact.';

  @override
  String get housingDecisionCityReadTitle =>
      'Read the city through housing pressure';

  @override
  String housingDecisionCityReadTitleWithCity(Object city) {
    return 'Read $city through housing pressure';
  }

  @override
  String get housingDecisionCityReadBody =>
      'Do not compare only average rent. Look at neighborhoods, transport, nearby services, furniture needs, commute distance, and cash margin for deposit and surprises.';

  @override
  String housingDecisionCityReadBodyWithCity(Object city) {
    return 'In $city, compare neighborhoods, transport, nearby services, furniture needs, and cash margin for deposit and surprises before treating housing as solved.';
  }

  @override
  String get housingDecisionSectionNote =>
      'Movaro currently organizes the context to help you decide better. Contract terms, accepted guarantees, and each landlord’s or platform’s policy still need to be validated at the source before signing for housing.';

  @override
  String get housingEntrySectionTitle => 'Estimated housing entry cost';

  @override
  String housingEntrySectionTitleWithCity(Object city) {
    return 'What housing may require upfront in $city';
  }

  @override
  String get housingEntrySectionBody =>
      'Rent that looks affordable in the listing can demand much more upfront. Use this view to simulate a deposit, guarantee insurance, or a temporary landing before deciding on the city.';

  @override
  String housingEntrySectionBodyWithCity(Object city) {
    return 'In $city, do not look only at monthly rent. Use this view to estimate what upfront entry may require with a deposit, guarantee insurance, or a temporary landing.';
  }

  @override
  String housingEntryRentLabel(Object amount) {
    return 'Reference monthly rent: $amount';
  }

  @override
  String get housingEntryModeDeposit => 'Deposit';

  @override
  String get housingEntryModeInsurance => 'Guarantee insurance';

  @override
  String get housingEntryModeTemporary => 'Temporary';

  @override
  String get housingEntryModeDepositBody =>
      'Typical scenario when the lease requires roughly 3 months of deposit plus the first month.';

  @override
  String get housingEntryModeInsuranceBody =>
      'Typical scenario when a guarantor is replaced by an annual insurance or digital guarantee fee.';

  @override
  String get housingEntryModeTemporaryBody =>
      'A lighter scenario for the first 30 to 90 days, prioritizing flexibility before taking a long lease.';

  @override
  String get housingEntryTotalTitle => 'What upfront entry may cost';

  @override
  String get housingEntryFirstMonthLabel => 'First month';

  @override
  String get housingEntryGuaranteeLabel => 'Guarantee / deposit';

  @override
  String get housingEntrySetupLabel => 'Fees and setup';

  @override
  String get housingEntryPlatformsTitle => 'Platforms and useful paths';

  @override
  String get housingEntryPlatformsHeadline =>
      'Use the right channel for your current risk level';

  @override
  String get housingEntryPlatformsBody =>
      'The best platform depends less on the pretty listing and more on the bureaucracy you can actually support right now.';

  @override
  String get housingEntryPlatformsQuintoAndar =>
      'Digital and without a guarantor, but it still expects consistent income and documentation.';

  @override
  String get housingEntryPlatformsZap =>
      'Use filters like rent without guarantor to cut wasted search time.';

  @override
  String get housingEntryPlatformsCredPago =>
      'A digital guarantee accepted by many agencies as a guarantor substitute.';

  @override
  String get housingEntryPlatformsAirbnb =>
      'Useful for the first 15 to 30 days while you visit neighborhoods before taking a longer lease.';

  @override
  String get housingEntryDisclaimer =>
      'This simulation is directional. Real numbers vary by city, neighborhood, platform, income proof, and landlord policy. The goal is to avoid underestimating the upfront cost.';

  @override
  String get housingSoftLandingTitle =>
      'How Argentinians usually land before a fixed lease';

  @override
  String get housingSoftLandingBody =>
      'In the first days, the common path is not going straight into a traditional lease. The sequence is usually landing, temporary housing, and only then the search for a more stable base with less risk.';

  @override
  String get housingSoftLandingTemporaryTitle =>
      'Land through short stay or a serviced flat';

  @override
  String get housingSoftLandingTemporaryBody =>
      'Monthly Airbnb deals, serviced apartments, and flats help you land without a guarantor or local income proof. That buys time to visit neighborhoods and understand the city in practice.';

  @override
  String get housingSoftLandingDirectTitle =>
      'Search directly with owners or local groups';

  @override
  String get housingSoftLandingDirectBody =>
      'Facebook Marketplace, OLX, and direct contacts are often more flexible than a traditional agency. In exchange, scam risk rises and property validation needs to be stricter.';

  @override
  String get housingSoftLandingGuaranteeTitle =>
      'The exchange currency is the guarantee';

  @override
  String get housingSoftLandingGuaranteeBody =>
      'Without a guarantor, the strongest argument is usually a deposit, guarantee insurance, a capitalization title, or a few months paid upfront. The point is not to overpromise, but to arrive with a credible structure.';

  @override
  String get housingSoftLandingSurvivalTitle => 'Arrival survival checklist';

  @override
  String get housingSoftLandingSurvivalChip =>
      'Buy a Brazilian SIM early. Without a local number, agencies and landlords tend to reply less.';

  @override
  String get housingSoftLandingSurvivalCpf =>
      'If CPF is not solved yet, treat it as a priority. It matters for platforms, banking, and rental conversations.';

  @override
  String get housingSoftLandingSurvivalLocation =>
      'In the first days, prioritize staying near groceries, pharmacies, transport, and a health post to reduce cost and friction.';

  @override
  String get housingSoftLandingSurvivalScam =>
      'Do not send a reservation deposit without visiting the property or having someone you trust verify it locally.';

  @override
  String get landingBudgetSectionTitle => 'Suggested landing budget';

  @override
  String landingBudgetSectionTitleWithCity(String city) {
    return 'Suggested landing budget for $city';
  }

  @override
  String get landingBudgetSummaryResearching =>
      'Use this as a directional reserve reference so your move is not designed only around monthly cost after everything is already stable.';

  @override
  String get landingBudgetSummaryTwelveMonths =>
      'With more time, the goal is to build a realistic reserve and reduce the shock of setup costs before the move gets close.';

  @override
  String get landingBudgetSummarySixMonths =>
      'Six months is enough to turn the move into a budgeted plan instead of a sequence of reactive expenses.';

  @override
  String get landingBudgetSummaryAsap =>
      'Since the move is close, your reserve matters as much as the city choice. Use this estimate to avoid arriving with too little runway.';

  @override
  String get landingBudgetLeanTitle => 'Lean';

  @override
  String get landingBudgetLeanBody =>
      'Useful if you plan to arrive with stricter spending, simpler housing expectations, and tighter early decisions.';

  @override
  String get landingBudgetBalancedTitle => 'Balanced';

  @override
  String get landingBudgetBalancedBody =>
      'A middle-ground view for someone trying to reduce stress without assuming a premium setup from day one.';

  @override
  String get landingBudgetComfortableTitle => 'Comfortable';

  @override
  String get landingBudgetComfortableBody =>
      'A safer cushion if you want more margin for housing friction, slower adaptation, or unexpected setup costs.';

  @override
  String get landingBudget30DaysLabel => 'Reference for the first 30 days';

  @override
  String get landingBudgetMonthlyBaseLabel => 'Monthly base';

  @override
  String get landingBudgetSetupLabel => 'Setup and installation';

  @override
  String get landingBudgetBufferLabel => 'Safety buffer';

  @override
  String landingBudget90DaysLabel(String amount) {
    return 'If you want a 90-day runway, use around $amount';
  }

  @override
  String get landingBudgetDisclaimer =>
      'These estimates are directional, not official prices. They combine city signals, setup pressure, and timeline risk to help you plan your reserve before the move.';

  @override
  String landingBudgetExchangeUpdatedAt(Object value) {
    return 'Official exchange rate updated at $value';
  }

  @override
  String get landingBudgetExchangeUnavailable =>
      'The official exchange rate could not be updated right now. Converted values are temporarily unavailable.';

  @override
  String get arrivalExecutionSectionTitle => 'First 7 / 30 / 90 days';

  @override
  String get arrivalExecutionStageWeek => 'First 7 days';

  @override
  String get arrivalExecutionStageMonth => 'First 30 days';

  @override
  String get arrivalExecutionStageQuarter => 'First 90 days';

  @override
  String get arrivalExecutionSummaryResearching =>
      'This is the execution layer after arrival. Use it now to understand what the first weeks will require beyond paperwork.';

  @override
  String get arrivalExecutionSummaryTwelveMonths =>
      'With more time, this layer helps you picture what settling in will demand so the move is not planned only around paperwork and budget.';

  @override
  String get arrivalExecutionSummarySixMonths =>
      'Six months is enough to plan arrival as an operational sequence, not just as a destination decision.';

  @override
  String get arrivalExecutionSummaryAsap =>
      'If arrival is close, this 7 / 30 / 90-day layer matters now. It is where daily friction usually appears first.';

  @override
  String get arrivalExecutionConnectivityTitle =>
      'Resolve connectivity on day one';

  @override
  String get arrivalExecutionConnectivityBody =>
      'Start with a local SIM, mobile data, and the minimum digital setup needed for maps, banking, and document follow-up.';

  @override
  String get arrivalExecutionTransportTitle =>
      'Learn your first transport routine';

  @override
  String get arrivalExecutionTransportBody =>
      'Map how you will move in the first week so housing, services, and bureaucracy do not depend on improvisation.';

  @override
  String arrivalExecutionTransportBodyWithCity(String city) {
    return 'Map how you will move through $city in the first week so housing, services, and bureaucracy do not depend on improvisation.';
  }

  @override
  String get arrivalExecutionHealthTitle => 'Set your first health fallback';

  @override
  String get arrivalExecutionHealthBody =>
      'Know where your first public or private health access point is so a routine issue does not become chaos on arrival.';

  @override
  String get arrivalExecutionBankTitle => 'Stabilize payments and banking flow';

  @override
  String get arrivalExecutionBankBody =>
      'Make sure your first local payment flow works: account, Pix, card use, and how you will move money in the first month.';

  @override
  String get arrivalExecutionHousingTitle =>
      'Turn housing into routine, not just entry';

  @override
  String get arrivalExecutionHousingBody =>
      'After arriving, confirm whether the chosen area really supports work, transport, safety, and the pace of daily life you need.';

  @override
  String get arrivalExecutionGoalWorkTitle => 'Turn arrival into employability';

  @override
  String get arrivalExecutionGoalWorkBody =>
      'Use the first month to test how documents, language, and city actually affect your chances of getting work.';

  @override
  String get arrivalExecutionGoalRemoteTitle =>
      'Turn arrival into a stable remote base';

  @override
  String get arrivalExecutionGoalRemoteBody =>
      'Validate internet reliability, a quiet routine, banking flow, and the real cost of maintaining remote work from the new city.';

  @override
  String get arrivalExecutionGoalStudyTitle =>
      'Turn arrival into a study routine';

  @override
  String get arrivalExecutionGoalStudyBody =>
      'Use the first month to confirm whether enrollment, commute, classes, and daily costs still support study as the base plan.';

  @override
  String get arrivalExecutionGoalEntrepreneurTitle =>
      'Turn arrival into operating capacity';

  @override
  String get arrivalExecutionGoalEntrepreneurBody =>
      'Use the first month to validate whether banking, documents, local routine, and city context actually support operating safely.';

  @override
  String get arrivalExecutionGoalRetireTitle =>
      'Turn arrival into a predictable routine';

  @override
  String get arrivalExecutionGoalRetireBody =>
      'Use the first month to test whether health access, neighborhood routine, and recurring costs feel sustainable in practice.';

  @override
  String get arrivalExecutionGoalQualityTitle =>
      'Turn arrival into real quality of life';

  @override
  String get arrivalExecutionGoalQualityBody =>
      'Use the first month to verify whether the city feels right in daily life, not only on paper or in rankings.';

  @override
  String get arrivalExecutionRealityCheckTitle =>
      'Do a reality check at 90 days';

  @override
  String get arrivalExecutionRealityCheckBody =>
      'Compare your real costs, routine friction, and city fit against what the plan suggested. This is where the move stops being hypothetical.';

  @override
  String get arrivalExecutionDocumentsTitle => 'Close the document loose ends';

  @override
  String get arrivalExecutionDocumentsBody =>
      'By the first 90 days, reduce pending follow-up on residency, proof, banking, and any local records still blocking stability.';

  @override
  String get arrivalExecutionReplanTitle => 'Replan before inertia takes over';

  @override
  String get arrivalExecutionReplanBody =>
      'If the city, cost, or pace is not matching the original plan, adjust direction before temporary friction becomes your default.';

  @override
  String arrivalExecutionReplanBodyWithCity(String city) {
    return 'If $city is not matching the original plan in practice, adjust direction before temporary friction becomes your default.';
  }

  @override
  String get publicHomeResumePlanAction => 'Continue my plan';

  @override
  String get publicHomeResumePlanTitle => 'Pick up where you left off';

  @override
  String get publicHomeResumePlanBody =>
      'Your last migration plan is still here. Reopen it to continue the checklist, document readiness, and landing budget.';

  @override
  String publicHomeResumePlanBodyWithCity(String city, String state) {
    return 'Your last plan is still here, with $city ($state) as the current lead city. Reopen it to continue the checklist, document readiness, and landing budget.';
  }

  @override
  String get publicHomeRetakePlanAction => 'Rebuild plan';

  @override
  String get migrationPlanCopilotTitle => 'Move guide';

  @override
  String get migrationPlanCopilotAction => 'Open guide';

  @override
  String get migrationPlanCopilotGuideEyebrow => 'Quick guide';

  @override
  String get migrationPlanCopilotGuideTitle => 'How to use the move guide';

  @override
  String get migrationPlanCopilotGuideBody =>
      'This area turns your chosen city into practical preparation. Open the right stage, resolve the current priority, and return to the overview without losing the order of the plan.';

  @override
  String get migrationPlanCopilotGuideStepOneTitle => 'Start from the overview';

  @override
  String get migrationPlanCopilotGuideStepOneBody =>
      'The overview shows the most important stage right now and helps you avoid spreading your energy.';

  @override
  String get migrationPlanCopilotGuideStepTwoTitle =>
      'Enter the priority stage';

  @override
  String get migrationPlanCopilotGuideStepTwoBody =>
      'Documents, housing, work, and arrival are split so you can solve one block at a time.';

  @override
  String get migrationPlanCopilotGuideStepThreeTitle =>
      'Use the practical shortcuts';

  @override
  String get migrationPlanCopilotGuideStepThreeBody =>
      'Open links, sources, and guided blocks inside the app to move from planning into execution.';

  @override
  String get migrationPlanCopilotGuideHideNextTime => 'Do not show again';

  @override
  String get migrationPlanCopilotGuideStepsLabel => '3 steps';

  @override
  String get migrationPlanCopilotGuideDismissAction => 'Not now';

  @override
  String get migrationPlanCopilotGuidePrimaryAction => 'Got it';

  @override
  String get migrationPlanCopilotIntroTitle =>
      'When you want to move from decision to execution';

  @override
  String get migrationPlanCopilotIntroBody =>
      'This stage organizes your checklist, documents, housing, and landing reserve. Use it when you are ready to start preparing the move.';

  @override
  String migrationPlanCopilotIntroBodyWithCity(String city, String state) {
    return 'This stage organizes your checklist, documents, housing, and landing reserve with $city ($state) as the main reference in your plan.';
  }

  @override
  String get migrationPlanCopilotResultBody =>
      'First, check whether the current city match still fits your context. When you want to turn that exploration into concrete preparation, open the guided layer with a checklist, documents, and an arrival reserve.';

  @override
  String migrationPlanCopilotStepCounter(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get migrationPlanCopilotStepStartTitle =>
      'Start with what unlocks the move';

  @override
  String get migrationPlanCopilotStepStartBody =>
      'Focus first on the checks that reduce risk before you spend more energy on details.';

  @override
  String get migrationPlanCopilotStepDocumentsTitle =>
      'Get the key documents in order';

  @override
  String get migrationPlanCopilotStepDocumentsBody =>
      'Use this step to organize the document layer that usually blocks progress later.';

  @override
  String get migrationPlanCopilotStepBudgetTitle =>
      'Plan reserve and housing entry';

  @override
  String get migrationPlanCopilotStepBudgetBody =>
      'Estimate your first reserve and review the housing friction before arrival turns urgent.';

  @override
  String get migrationPlanCopilotStepArrivalTitle =>
      'Prepare the first 7 / 30 / 90 days';

  @override
  String get migrationPlanCopilotStepArrivalBody =>
      'Turn the plan into execution so arrival does not depend on improvisation.';

  @override
  String get migrationPlanCopilotHomeTitle => 'What to do now';

  @override
  String get migrationPlanCopilotHomeBody =>
      'Use this home to see the next actions, the main risk, and the stage that deserves attention first.';

  @override
  String migrationPlanCopilotStageCountLabel(Object count) {
    return '$count guided stages';
  }

  @override
  String get migrationPlanCopilotNextActionsTitle => 'Your next 3 actions';

  @override
  String get migrationPlanCopilotNextActionsBody =>
      'Start with the tasks that unlock the move before you go deeper.';

  @override
  String get migrationPlanCopilotNextActionStart => 'Reduce the first blockers';

  @override
  String get migrationPlanCopilotNextActionDocuments =>
      'Put documents in motion';

  @override
  String get migrationPlanCopilotNextActionBudget =>
      'Review reserve and housing entry';

  @override
  String get migrationPlanCopilotNextActionBudgetBody =>
      'Estimate your first reserve and understand how housing entry may weigh on arrival.';

  @override
  String get migrationPlanCopilotFallbackActionBody =>
      'Open this stage to see a useful first action.';

  @override
  String get migrationPlanCopilotRiskTitle => 'Main risk now';

  @override
  String get migrationPlanCopilotRiskDocuments =>
      'The document layer is still the biggest risk. If it stays loose, later steps may feel blocked even with city and budget already decided.';

  @override
  String get migrationPlanCopilotRiskReadiness =>
      'The move still needs a stronger starting base. Resolve the first practical blockers before investing more energy in details.';

  @override
  String get migrationPlanCopilotRiskHousing =>
      'Housing entry can still create friction on arrival. Review reserve, guarantees, and fallback strategy before treating the move as operational.';

  @override
  String get migrationPlanCopilotStagesTitle => 'Open a guided stage';

  @override
  String get migrationPlanCopilotStagesBody =>
      'You can jump directly to the stage you need, but Movaro keeps the order clear so the move does not lose priority.';

  @override
  String get migrationPlanCopilotRecommendedTitle =>
      'Suggested area to review next';

  @override
  String get migrationPlanCopilotRecommendedReadinessBody =>
      'This stage may help reduce the first blockers and give the rest of the plan a stronger base.';

  @override
  String get migrationPlanCopilotRecommendedDocumentsBody =>
      'The document layer may deserve attention first. Reviewing it now can reduce more expensive blockers later.';

  @override
  String get migrationPlanCopilotRecommendedBudgetBody =>
      'This may be a good moment to turn the plan into real numbers and review housing entry before arrival gets tight.';

  @override
  String get migrationPlanCopilotRecommendedArrivalBody =>
      'You may already have enough base to organize the arrival. This stage can help you move from planning into execution.';

  @override
  String get migrationPlanCopilotRecommendedOpen => 'Open suggested stage';

  @override
  String get migrationPlanCopilotQuickQuestionsTitle => 'Quick questions';

  @override
  String get migrationPlanCopilotQuickQuestionsBody =>
      'Use these short answers when a practical doubt shows up before you move forward.';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsTitle =>
      'Which documents should I move first?';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsAnswer =>
      'Start with the documents that take longer to obtain or expire sooner. The document stage helps you separate what unlocks residence, CPF, and practical arrival without pushing you into a full bureaucratic flow all at once.';

  @override
  String get migrationPlanCopilotQuickQuestionHousingTitle =>
      'Do I need to solve permanent housing now?';

  @override
  String get migrationPlanCopilotQuickQuestionHousingAnswer =>
      'Not always. In many cases, it is better to start with a temporary housing plan, understand guarantees, and only then commit to a larger rental. What matters now is estimating your reserve, entry costs, and fallback plan.';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalTitle =>
      'What should I solve right after arrival?';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalAnswer =>
      'Think first about what reduces friction in the first days: where to stay, how to move around, what must be solved in the first 7 days, and which tasks cannot slip past the first month. The arrival stage already organizes this by priority.';

  @override
  String get migrationPlanCopilotQuickQuestionOpenStage => 'Go to this stage';

  @override
  String get migrationPlanCopilotActionOpen => 'Resolve now';

  @override
  String get migrationPlanCopilotOverviewAction => 'Start guided preparation';

  @override
  String get migrationPlanCopilotOverviewBackAction => 'Back to overview';

  @override
  String get migrationPlanCopilotFinishAction => 'Finish for now';

  @override
  String get migrationPlanDecisionLabel => 'City comparison';

  @override
  String migrationPlanDecisionTitle(Object goal) {
    return 'Now compare the cities that may match $goal more closely';
  }

  @override
  String migrationPlanDecisionBody(Object timeline) {
    return 'Based on your $timeline horizon, these options appear first because they are closer to the profile you selected.';
  }

  @override
  String get migrationPlanDecisionSummaryTitle => 'How to use this step';

  @override
  String get migrationPlanDecisionSummaryBody =>
      'Review the city options first. The detailed checklist becomes more useful after you decide which route to keep exploring.';

  @override
  String migrationPlanHeroTitle(Object city) {
    return '$city is your strongest starting city for now';
  }

  @override
  String migrationPlanHeroBody(Object timeline) {
    return 'Based on your $timeline horizon, start by reviewing the 3 cities below and open the one that feels strongest for your move.';
  }

  @override
  String get migrationPlanConfidenceLow => 'Initial recommendation';

  @override
  String get migrationPlanConfidenceHigh => 'Strong recommendation';

  @override
  String migrationPlanSummaryArchetype(Object value) {
    return 'Detected profile: $value';
  }

  @override
  String migrationPlanSummaryVariant(Object value) {
    return 'Mode used: $value';
  }

  @override
  String migrationPlanSummaryFunding(Object value) {
    return 'Initial support: $value';
  }

  @override
  String get migrationPlanCandidateCitiesTitle =>
      'Cities more aligned with your profile';

  @override
  String get migrationPlanCandidateCitiesBody =>
      'The list is already ordered to keep first what tends to make more sense for Argentinians with this goal.';

  @override
  String get migrationPlanShortlistTitle => '3 cities to review now';

  @override
  String get migrationPlanShortlistBody =>
      'These are the 3 strongest starting options right now. Open one city to compare it with your move context.';

  @override
  String get migrationPlanCandidateCitiesSheetBody =>
      'Open the details to understand each city better. City confirmation happens inside the detail screen, after you see more context.';

  @override
  String get migrationPlanSelectedCityBadge => 'Selected';

  @override
  String get migrationPlanSuggestedCityBadge => 'Leading now';

  @override
  String get migrationPlanChooseCityAction => 'Choose this city';

  @override
  String get migrationPlanSelectedCityAction => 'City selected';

  @override
  String get migrationPlanInspectCityAction => 'Open details';

  @override
  String get migrationPlanOpenCitiesAction => 'See suggested cities';

  @override
  String get migrationPlanCompareOtherCitiesAction => 'Compare other cities';

  @override
  String migrationPlanSuggestedCityTitle(Object city) {
    return '$city is leading for now';
  }

  @override
  String migrationPlanSuggestedCityBody(Object city, Object housing) {
    return '$city is currently leading for the profile you chose, with a housing-entry read of $housing. Before deciding, open the details and compare it with the other options.';
  }

  @override
  String migrationPlanConfirmedCityTitle(Object city) {
    return '$city is the city you selected';
  }

  @override
  String migrationPlanSelectedCityTitle(Object city) {
    return '$city is leading for now';
  }

  @override
  String migrationPlanSelectedCityBody(Object city, Object housing) {
    return '$city stands out for your current context, with a housing-entry read of $housing. If this city feels right, then it makes sense to open the guided preparation.';
  }

  @override
  String get migrationPlanPreparationTitle => 'When to move into preparation';

  @override
  String migrationPlanPreparationBody(Object city) {
    return 'If you decide to move forward with $city, guided preparation opens a checklist, documents, housing, and an arrival reserve focused on that city.';
  }

  @override
  String get migrationPlanResultPrimaryCtaEyebrow => 'Possible next move';

  @override
  String get migrationPlanResultStartPlanTitle => 'Open this route';

  @override
  String migrationPlanResultStartPlanBody(Object city) {
    return 'Review $city with a little more context and keep exploring it if it still feels relevant for your route.';
  }

  @override
  String get migrationPlanResultStartPlanAction => 'Open this route';

  @override
  String get migrationPlanResultOpenPlanTitle => 'View full plan';

  @override
  String get migrationPlanResultOpenPlanAction => 'View full plan';

  @override
  String get migrationPlanResultCompatibilityHigh =>
      'Stronger fit for your profile';

  @override
  String get migrationPlanResultCompatibilityMedium =>
      'Good fit for your profile';

  @override
  String get migrationPlanResultCompatibilityInitial => 'Suggestion to explore';

  @override
  String get migrationPlanResultCompatibilityHelpTitle =>
      'How this suggestion was ordered';

  @override
  String get migrationPlanResultCompatibilityHelpBody =>
      'The order compares your goal and priorities with the signals available for cities in the catalog. It is directional guidance for exploring options, not a guarantee that this is the best city in Brazil for you.';

  @override
  String get migrationPlanResultUnavailableTitle =>
      'We could not load your city result.';

  @override
  String get migrationPlanResultUnavailableBody =>
      'Try again to reopen your city matches and continue from the quick questions.';

  @override
  String get migrationPlanResultBasedOnAnswersTitle => 'Based on your answers';

  @override
  String get migrationPlanResultCityDataTitle => 'City data';

  @override
  String get migrationPlanResultOtherCitiesTitle => 'Other suggested cities';

  @override
  String get migrationPlanResultReviewsMetricTitle => 'Public reviews';

  @override
  String get migrationPlanResultSafetyMetricTitle => 'Safety';

  @override
  String migrationPlanResultPrimaryAction(Object city) {
    return 'Start my plan in $city ->';
  }

  @override
  String get migrationPlanResultExploreDetailsAction =>
      'Explore the city in detail';

  @override
  String migrationPlanResultReasonFromPriority(Object label) {
    return 'You chose: $label';
  }

  @override
  String migrationPlanResultReasonBudget(Object city) {
    return '$city keeps the entry cost more manageable, which helps you arrive with less pressure.';
  }

  @override
  String migrationPlanResultReasonWork(Object city, Object signal) {
    return '$city shows a $signal work signal, which gives you more room to move after arrival.';
  }

  @override
  String migrationPlanResultReasonQuality(Object city, Object signal) {
    return '$city stands out with a $signal quality-of-life signal, which supports a steadier day-to-day routine.';
  }

  @override
  String migrationPlanResultReasonClimate(Object city, Object signal) {
    return '$city aligns well with the lifestyle you signaled, with $signal.';
  }

  @override
  String migrationPlanResultReasonTransit(Object city) {
    return '$city gives you a more practical base if you need to move around the city often.';
  }

  @override
  String migrationPlanResultReasonUniversity(Object city) {
    return '$city keeps study and qualification paths closer if education is part of your plan.';
  }

  @override
  String migrationPlanResultReasonCommunity(Object city) {
    return '$city has stronger adaptation signals for building routine and support once you arrive.';
  }

  @override
  String migrationPlanResultReasonProximity(Object city) {
    return '$city keeps you on a route that feels easier to coordinate from Argentina.';
  }

  @override
  String migrationPlanResultReasonBalanced(Object city) {
    return '$city is the most balanced recommendation for your current profile across the available city signals.';
  }

  @override
  String get migrationPlanResultWeatherPending => 'Weather is updating';

  @override
  String get migrationPlanResultWeatherDay => 'Day';

  @override
  String get migrationPlanResultWeatherNight => 'Night';

  @override
  String get migrationPlanResultWeatherSunny => 'sunny right now';

  @override
  String get migrationPlanResultWeatherCloudy => 'more cloudy conditions';

  @override
  String get migrationPlanResultWeatherRain => 'rain in the area';

  @override
  String get migrationPlanResultWeatherCold => 'cooler conditions';

  @override
  String get migrationPlanResultWeatherStorm => 'more unstable weather';

  @override
  String get migrationPlanResultWeatherMild => 'mild weather';

  @override
  String get migrationPlanResultWeatherClearNight => 'clear night';

  @override
  String get migrationPlanResultCostLabel => 'Estimated cost';

  @override
  String get migrationPlanResultWeatherLabel => 'Weather now';

  @override
  String get migrationPlanResultWhyLabel => 'Why this city';

  @override
  String migrationPlanResultReviewsLabel(Object count) {
    return '$count reviews';
  }

  @override
  String get migrationPlanResultCostSupporting =>
      'A directional read based on city cost and rent signals.';

  @override
  String get migrationPlanResultCostLower => 'Lower';

  @override
  String get migrationPlanResultCostMedium => 'Moderate';

  @override
  String get migrationPlanResultCostHigher => 'Higher';

  @override
  String get migrationPlanResultDifficultyLabel => 'Difficulty level';

  @override
  String get migrationPlanResultDifficultySupporting =>
      'How much coordination this plan may need before arrival.';

  @override
  String get migrationPlanResultDifficultyFocused => 'Focused';

  @override
  String get migrationPlanResultDifficultyModerate => 'Moderate';

  @override
  String get migrationPlanResultDifficultyStructured => 'Structured';

  @override
  String get migrationPlanResultTimelineLabel => 'Estimated timeline';

  @override
  String migrationPlanResultTimelineValue(Object days) {
    return '~$days days';
  }

  @override
  String get migrationPlanResultCitySectionTitle => 'Why this city is leading';

  @override
  String get migrationPlanResultCitySectionBody =>
      'Open the city context when you want more detail, not before the main decision is clear.';

  @override
  String get migrationPlanResultPlanSectionTitle =>
      'What happens after this result';

  @override
  String get migrationPlanResultPlanSectionBody =>
      'Preparation becomes useful only after the city choice feels strong enough to move forward.';

  @override
  String get migrationPlanCompareThreeCitiesAction => 'Compare the 3 cities';

  @override
  String get migrationPlanResultProgressSupporting =>
      'Completed checklist items across the guided plan.';

  @override
  String migrationPlanCopilotProgressValue(Object done, Object total) {
    return '$done of $total checklist items completed';
  }

  @override
  String migrationPlanCopilotProgressHeader(
    Object current,
    Object total,
    Object percent,
  ) {
    return 'Stage $current of $total · $percent% complete';
  }

  @override
  String get migrationPlanCopilotStatusNotStarted => 'Not started';

  @override
  String get migrationPlanCopilotStatusInProgress => 'In progress';

  @override
  String get migrationPlanCopilotStatusDone => 'Completed';

  @override
  String get migrationPlanCopilotToolsButton => 'Tools';

  @override
  String get migrationPlanCopilotCityRequiredHint =>
      'Available after confirming your city.';

  @override
  String get migrationPlanCopilotGoalRequiredHint =>
      'Available after defining your migration goal.';

  @override
  String get migrationPlanCopilotToolsFlightsHint =>
      'Flight planner available in Tools.';

  @override
  String get migrationPlanHousingCompareTitle =>
      'Thinking about changing cities?';

  @override
  String migrationPlanHousingCompareBody(Object cityName) {
    return 'Compare $cityName with other options before you decide.';
  }

  @override
  String get migrationPlanHousingCompareAction => 'Compare cities';

  @override
  String get migrationPlanScrollHint => 'See more';

  @override
  String get languageSelectorSystem => 'System';

  @override
  String get bmpDisclaimer =>
      'This builds a starting point. It does not replace professional legal guidance.';

  @override
  String bmpProgressStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get bmpCtaBack => 'Back';

  @override
  String get bmpCtaContinue => 'Continue';

  @override
  String get bmpCtaSkip => 'Skip';

  @override
  String get bmpCtaGenerate => 'Generate my plan';

  @override
  String get bmpExitDialogTitle => 'Do you want to leave this plan?';

  @override
  String get bmpExitDialogBody =>
      'If you go back home, you will lose this flow and your current answers.';

  @override
  String get bmpExitDialogStay => 'Stay here';

  @override
  String get bmpExitDialogLeave => 'Back to home';

  @override
  String get bmpCtaRefineYes => 'Yes, refine';

  @override
  String get bmpCtaRefineNo => 'No, generate my plan';

  @override
  String get bmpVariantTitle => 'How do you want to build your plan?';

  @override
  String get bmpVariantSubtitle =>
      'You can go faster or answer one extra question for a more precise recommendation.';

  @override
  String get bmpVariantLeanTitle => 'Quick plan';

  @override
  String get bmpVariantLeanBody =>
      '4 focused questions to get an initial direction with low friction.';

  @override
  String get bmpVariantLeanTag => 'Faster';

  @override
  String get bmpVariantStrategicTitle => 'Strategic plan';

  @override
  String get bmpVariantStrategicBody =>
      'Adds one extra preference step for a sharper starting recommendation.';

  @override
  String get bmpVariantStrategicTag => 'More precise';

  @override
  String get bmpGuideEyebrow => 'Build my plan';

  @override
  String get bmpGuideTitle => 'How this plan builder works';

  @override
  String get bmpGuideBody =>
      'Start with the mode that matches how much detail you want right now. Both options lead to a suggested city and a first sequence of actions, but they differ in depth.';

  @override
  String get bmpGuideStepsLabel => 'What changes between the two modes';

  @override
  String get bmpGuideStepQuickTitle => 'Quick plan';

  @override
  String get bmpGuideStepQuickBody =>
      'This is the fastest path. You answer the core questions, get an initial direction, and can refine later if the first result is still too broad.';

  @override
  String get bmpGuideStepStrategicTitle => 'Strategic plan';

  @override
  String get bmpGuideStepStrategicBody =>
      'This adds one extra layer about how you intend to support yourself after the move, so the recommendation becomes more precise and more practical.';

  @override
  String get bmpGuideStepUseTitle => 'How to use the result';

  @override
  String get bmpGuideStepUseBody =>
      'Use the plan as a starting point, not a final verdict. The best next move is usually to compare the suggested city, confirm documents, and adjust the plan if your priority changes.';

  @override
  String get bmpGuideHideNextTime =>
      'Do not open this explanation automatically again';

  @override
  String get bmpGuideDismissAction => 'Close';

  @override
  String get bmpGuidePrimaryAction => 'Start planning';

  @override
  String get bmpRefineTitle =>
      'Consider family, pets, a vehicle, health, and income before the recommendation?';

  @override
  String get bmpRefineSubtitle =>
      'Optional · adds about 1 minute and makes the city and plan more coherent';

  @override
  String get qIntentPrompt => 'What are you looking for in Brazil right now?';

  @override
  String get qFundingPrompt =>
      'How do you plan to support yourself during the first 3 months?';

  @override
  String get qFundingSubtitle =>
      'This helps us adjust your starting point without asking for personal data.';

  @override
  String get qTimelinePrompt =>
      'When would you like to be in Brazil? (roughly)';

  @override
  String get qPrioritiesPrompt => 'What matters most when choosing a city?';

  @override
  String get qPrioritiesHelper => 'Select up to 3';

  @override
  String qPrioritiesSelectedCount(Object selected, Object total) {
    return '$selected/$total';
  }

  @override
  String get qPrioritiesValidation => 'Pick 2 options to continue';

  @override
  String get qConstraintsPrompt =>
      'Is there anything you do NOT want to compromise on?';

  @override
  String get qConstraintsSubtitle => '(Optional) Pick up to 2';

  @override
  String get bmpScrollHint => 'See more options';

  @override
  String get qConstraintsValidation => 'You can pick up to 2 options';

  @override
  String get qConstraintsNone => 'I do not have fixed constraints';

  @override
  String get questionOptionFindJobBr => 'Find a job in Brazil';

  @override
  String get questionOptionRemoteIncome =>
      'Work remotely (I already have income)';

  @override
  String get questionOptionFundingSavings => 'I have savings to get started';

  @override
  String get questionOptionFundingJobSearch =>
      'I will look for a job in Brazil';

  @override
  String get questionOptionFundingJobOffer =>
      'I already have an offer or contract';

  @override
  String get questionOptionFundingFamilySupport =>
      'Support from family or partner';

  @override
  String get questionOptionFundingDontKnow => 'I still do not know';

  @override
  String get questionOptionFamilyPartner => 'Move because of partner or family';

  @override
  String get questionOptionFreshStart => 'Better quality of life / start over';

  @override
  String get questionOptionExploreUnsure =>
      'I just want to understand my options';

  @override
  String get questionOptionJustExploring => 'Just exploring';

  @override
  String get questionOptionIn03Months => 'In 0-3 months';

  @override
  String get questionOptionIn36Months => 'In 3-6 months';

  @override
  String get questionOptionIn612Months => 'In 6-12 months';

  @override
  String get questionOptionIn12PlusMonths => 'In more than 12 months';

  @override
  String get questionOptionDepends => 'It depends / I am still figuring it out';

  @override
  String get questionOptionLowCost => 'Lower cost of living';

  @override
  String get questionOptionJobOpportunities => 'More job opportunities';

  @override
  String get questionOptionSafetyPriority => 'Safety / peace of mind';

  @override
  String get questionOptionWarmClimateBeach => 'Warmer climate / beach';

  @override
  String get questionOptionTransitInfra => 'Good infrastructure and transit';

  @override
  String get questionOptionNature => 'Nature';

  @override
  String get questionOptionUniversity => 'University environment';

  @override
  String get questionOptionCommunity => 'Community / making friends';

  @override
  String get questionOptionCloseToArgentina => 'Closer to Argentina';

  @override
  String get questionOptionBalancedUnsure => 'I want balance / I am not sure';

  @override
  String get questionOptionPreferSouth => 'I prefer the South';

  @override
  String get questionOptionNeedBigCity => 'I need a big city';

  @override
  String get questionOptionPreferMidCity =>
      'I prefer a mid-size or calmer city';

  @override
  String get questionOptionWantCoast => 'I want coast or beach';

  @override
  String get questionOptionPreferCooler => 'I prefer cooler weather';

  @override
  String get questionOptionNeedTransit => 'I need strong public transit';

  @override
  String get questionOptionAvoidExpensive => 'I want to avoid expensive cities';

  @override
  String get planReasonBudgetFit =>
      'A better match if you want to protect your budget.';

  @override
  String get planReasonJobMobility =>
      'More room to search for work and move around.';

  @override
  String get planReasonSafety => 'It matches your priority for peace of mind.';

  @override
  String get planReasonClimateNature =>
      'A good starting point if you want climate and outdoor life.';

  @override
  String get planReasonTransit =>
      'More practical if you want to get around without a car.';

  @override
  String get planReasonProximityArgentina =>
      'Closer if you want to return to Argentina when needed.';

  @override
  String get planReasonUniversity => 'More aligned if your plan is to study.';

  @override
  String get planReasonCommunity =>
      'Better chances to build network and community.';

  @override
  String get planReasonBalancedProfile =>
      'It appears as a balanced place to start.';

  @override
  String get archetypeJobHunter => 'Job search';

  @override
  String get archetypeJobHunterWithOffer => 'Job with offer';

  @override
  String get archetypeJobHunterSearching => 'Active job search';

  @override
  String get archetypeRemoteWorker => 'Remote work';

  @override
  String get archetypeRemoteStable => 'Stable remote work';

  @override
  String get archetypeStudent => 'Study';

  @override
  String get archetypeFamilyMove => 'Family move';

  @override
  String get archetypeFreshStart => 'Fresh start';

  @override
  String get archetypeExplorer => 'Exploration';

  @override
  String get planStepTitleChooseBaseCity => 'Choose your base city';

  @override
  String get planStepTitleResidencePath => 'Understand the residence path';

  @override
  String get planStepTitleCpfStart => 'Start your CPF';

  @override
  String get planStepDescriptionChooseBaseCityExplore =>
      'Choose 1 city to start with and review neighborhoods, living costs, and basic mobility. It is not final: it is just to begin with clarity.';

  @override
  String get planStepDescriptionChooseBaseCityBalanced =>
      'Define a base city and compare 2 neighborhoods, rent, and mobility to turn the idea into a practical plan.';

  @override
  String get planStepDescriptionChooseBaseCityUrgent =>
      'Define a base city and a tentative date this week to organize the most urgent decisions.';

  @override
  String get planStepDescriptionChooseBaseCityOffer =>
      'Since you already have an offer or contract, choose the base city and validate neighborhood, commute, and starting costs.';

  @override
  String get planStepDescriptionResidencePathExplore =>
      'Review the most common residence path for Argentina to Brazil and which base documents you will need later.';

  @override
  String get planStepDescriptionResidencePathBalanced =>
      'Understand the residence path and start gathering the base documents before getting into detailed bureaucracy.';

  @override
  String get planStepDescriptionResidencePathUrgent =>
      'Review the residence path and separate the base documents now so execution does not get blocked.';

  @override
  String get planStepDescriptionResidencePathFundingUnknown =>
      'Before moving ahead, understand the residence path and clarify how you will support yourself during the first months to avoid blockers.';

  @override
  String get planStepDescriptionCpfStart =>
      'CPF unlocks many practical steps in Brazil. Start with the official guidance and continue later in Movaro step by step.';

  @override
  String get migrationPlanPrepHeroTitle =>
      'Prepare the move without getting lost in the process';

  @override
  String get migrationPlanPrepHeroBody =>
      'The goal here is not to tick checkboxes. First understand what to issue, where to open each topic, and which guide solves your next step.';

  @override
  String get migrationPlanPrepHeroBodyCompact =>
      'Open the right stage and prepare the move without losing the order of the plan.';

  @override
  String get migrationPlanPrepTabOverview => 'Overview';

  @override
  String get migrationPlanPrepTabDocuments => 'Documents';

  @override
  String get migrationPlanPrepTabHousing => 'Housing and costs';

  @override
  String get migrationPlanPrepTabWork => 'Work and daily life';

  @override
  String get migrationPlanPrepTabArrival => 'Arrival';

  @override
  String get migrationPlanPrepOverviewTitle =>
      'Start with what really unlocks the move';

  @override
  String get migrationPlanPrepOverviewBody =>
      'Instead of a long checklist, this area now works as a practical guide. Documents come first, then housing, costs, work, and arrival.';

  @override
  String get migrationPlanPrepChooseCityTitle =>
      'Choose a city to unlock preparation';

  @override
  String get migrationPlanPrepChooseCityBody =>
      'Preparation only makes sense with a confirmed base city. First choose the city that will guide housing, costs, work, and arrival.';

  @override
  String get migrationPlanPrepChooseCityAction => 'Choose plan city';

  @override
  String get migrationPlanPrepQuestionDocsTitle =>
      'How do I regularize my documents?';

  @override
  String get migrationPlanPrepQuestionDocsBody =>
      'Open CPF, registration, banking, and contracts in a more guided way without falling into a loose bureaucratic flow.';

  @override
  String get migrationPlanPrepQuestionRentTitle =>
      'What do I need to rent a place?';

  @override
  String get migrationPlanPrepQuestionRentBody =>
      'See guarantees, deposit, temporary rent, and what is usually requested to enter housing at the beginning.';

  @override
  String get migrationPlanPrepQuestionMoneyTitle =>
      'How much money should I bring?';

  @override
  String get migrationPlanPrepQuestionMoneyBody =>
      'Use a more conservative arrival view with a safety margin instead of unrealistic numbers.';

  @override
  String get migrationPlanPrepQuestionHealthTitle =>
      'Is healthcare public or private?';

  @override
  String get migrationPlanPrepQuestionHealthBody =>
      'Understand when SUS, a local clinic, a hospital, or a private plan makes sense without mixing everything together.';

  @override
  String get migrationPlanPrepQuestionWorkTitle =>
      'Can I work and open a bank account?';

  @override
  String get migrationPlanPrepQuestionWorkBody =>
      'Open formal work, income, banking, and contracts in a practical way, focused on what unlocks real life.';

  @override
  String get migrationPlanPrepQuestionArrivalTitle =>
      'What should I solve right after arrival?';

  @override
  String get migrationPlanPrepQuestionArrivalBody =>
      'Organize the first days, the first housing base, and the initial routine so everything is not improvised.';

  @override
  String get migrationPlanPrepQuestionFlightsTitle =>
      'How can I check flights to this city?';

  @override
  String get migrationPlanPrepQuestionFlightsBody =>
      'Open an external flight search to compare routes to the chosen city in Brazil.';

  @override
  String get migrationPlanPrepPrimaryEyebrow => 'First step';

  @override
  String get migrationPlanPrepCardToneGuide => 'Quick guide';

  @override
  String get migrationPlanPrepCardTonePractical => 'Solve now';

  @override
  String get migrationPlanPrepCardTonePriority => 'High priority';

  @override
  String get migrationPlanPrepCardToneArrival => 'First steps';

  @override
  String get migrationPlanPrepOpenSection => 'Open this area';

  @override
  String get migrationPlanPrepOpenOfficialSource => 'Open official source';

  @override
  String get migrationPlanPrepExternalToolHint =>
      'Use this shortcut as quick orientation. The next step opens the official source inside the app so you can continue without losing context.';

  @override
  String get migrationPlanPrepOpenGuide => 'Open full guide';

  @override
  String get migrationPlanPrepBackToOverview => 'Back to overview';

  @override
  String get migrationPlanPrepDocumentsTitle => 'Documents and residence';

  @override
  String get migrationPlanPrepDocumentsBody =>
      'See what to issue first, how CPF and registration work in practice, and where to open the right guidance without getting lost in scattered research.';

  @override
  String get migrationPlanPrepHousingTitle => 'Housing and costs';

  @override
  String get migrationPlanPrepHousingBody =>
      'Understand reserve, rental entry, guarantees, and a temporary housing plan before arrival gets tight.';

  @override
  String get migrationPlanPrepWorkTitle => 'Work and daily life';

  @override
  String get migrationPlanPrepWorkBody =>
      'Open work, health, and mobility in more direct blocks to solve daily life without excessive reading.';

  @override
  String get migrationPlanPrepArrivalTitle => 'First days in Brazil';

  @override
  String get migrationPlanPrepArrivalBody =>
      'Organize arrival by short horizon: first week, first month, and the 90 days that stabilize the move.';

  @override
  String get migrationPlanPrepDocumentsGuideTitle =>
      'Start with documents, not with a checklist';

  @override
  String get migrationPlanPrepDocumentsGuideBody =>
      'If the document layer is confusing, the rest gets blocked. That is why this area sends you straight to what to issue, how it works, and where to continue.';

  @override
  String get migrationPlanPrepOpenDocumentsTopic => 'Open documents topic';

  @override
  String get migrationPlanPrepDocumentsCpfTitle =>
      'CPF and what it really unlocks';

  @override
  String get migrationPlanPrepDocumentsCpfBody =>
      'Open this part to understand when CPF helps, what it cannot solve alone, and how it connects to banking, contracts, and daily life.';

  @override
  String get migrationPlanPrepDocumentsResidenceTitle =>
      'Registration and residence without bureaucratic language';

  @override
  String get migrationPlanPrepDocumentsResidenceBody =>
      'Understand the most common residence path, the role of the protocol, and how that connects with arrival.';

  @override
  String get migrationPlanPrepDocumentsBankTitle =>
      'Banking, records, and contracts';

  @override
  String get migrationPlanPrepDocumentsBankBody =>
      'See what is usually required to open an account, sign a rental agreement, and avoid blocking daily life right at the start.';

  @override
  String get migrationPlanPrepTaxesTitle => 'How taxes and tax residence work';

  @override
  String get migrationPlanPrepTaxesBody =>
      'Open the official Receita guidance to understand entry into Brazil, tax residence, and when this starts to matter.';

  @override
  String get migrationPlanPrepDeadlinesTitle =>
      'Which deadlines you cannot miss';

  @override
  String get migrationPlanPrepDeadlinesBody =>
      'Open the official residence route so you do not discover registration, issuance, and critical deadlines too late.';

  @override
  String get migrationPlanPrepHousingGuideTitle =>
      'Turn the move into real numbers';

  @override
  String get migrationPlanPrepHousingGuideBody =>
      'Here you review reserve, entry costs, guarantees, and soft landing with a much more practical structure than a checklist block.';

  @override
  String get migrationPlanPrepWorkGuideTitle =>
      'Daily life after the city is chosen';

  @override
  String get migrationPlanPrepWorkGuideBody =>
      'Use these blocks to open work, health, and mobility quickly. These are the topics that most often become doubts after the city decision.';

  @override
  String get migrationPlanPrepWorkSignalsTitle => 'Work signals for this city';

  @override
  String get migrationPlanPrepWorkSignalsBody =>
      'Movaro currently shows labor-market, economic-activity, and unemployment signals. Average income is not integrated into the catalog yet.';

  @override
  String get migrationPlanPrepMoneyPracticeTitle =>
      'Banking and money in practice';

  @override
  String get migrationPlanPrepMoneyPracticeBody =>
      'Open the public Central Bank guidance to understand accounts, Pix, payments, and financial organization for migrants.';

  @override
  String get migrationPlanPrepDiplomaTitle =>
      'Recognize diploma and profession';

  @override
  String get migrationPlanPrepDiplomaBody =>
      'Open the official route to revalidate a foreign diploma and understand when the profession may require an extra step in Brazil.';

  @override
  String get migrationPlanPrepWorkSignalJobs => 'Job market';

  @override
  String get migrationPlanPrepWorkSignalEconomic => 'Economic activity';

  @override
  String get migrationPlanPrepWorkSignalUnemployment => 'Unemployment';

  @override
  String get migrationPlanPrepArrivalGuideTitle =>
      'What to solve first when you arrive';

  @override
  String get migrationPlanPrepArrivalGuideBody =>
      'Instead of marking loose tasks, look at arrival as a short sequence: land, stabilize, and consolidate the new routine.';

  @override
  String get migrationPlanPrepArrivalWeekTitle => 'First week';

  @override
  String get migrationPlanPrepArrivalWeekBody =>
      'Focus on where to stay, how to move around, what to buy first, and how to avoid the first housing mistakes.';

  @override
  String get migrationPlanPrepArrivalMonthTitle => 'First month';

  @override
  String get migrationPlanPrepArrivalMonthBody =>
      'Adjust documents, neighborhood routine, bank account, rent, and the points that turn arrival into something less improvised.';

  @override
  String get migrationPlanPrepArrivalQuarterTitle => 'First 90 days';

  @override
  String get migrationPlanPrepArrivalQuarterBody =>
      'Consolidate work, financial organization, health routine, and the next steps that make the move sustainable.';

  @override
  String get migrationPlanPrepSupportNetworkTitle =>
      'Where to find support networks';

  @override
  String get migrationPlanPrepSupportNetworkBody =>
      'Open public support networks for migrants and refugees to understand where to look for assistance, orientation, and reception.';

  @override
  String get migrationPlanPrepArgentineNetworkTitle =>
      'Argentine embassy and consulates';

  @override
  String get migrationPlanPrepArgentineNetworkBody =>
      'Open the official list of the Argentine embassy and consulates in Brazil to check procedures, contact details, and official consular guidance.';

  @override
  String get migrationPlanPrepFamilyTitle => 'What about family and children';

  @override
  String get migrationPlanPrepFamilyBody =>
      'Open the public guidance on school enrollment and rights for migrant children and teenagers in Brazil.';

  @override
  String get migrationPlanPrepRiskAlertsTitle => 'Scams and risks to avoid';

  @override
  String get migrationPlanPrepRiskAlertsBody =>
      'Open public alerts about misleading offers, false promises, and risks that often affect people moving to another country.';

  @override
  String get migrationPlanPrepFlightsPlannerTitle => 'Plan the flight search';

  @override
  String migrationPlanPrepFlightsPlannerBody(Object city) {
    return 'Choose the departure city in Argentina and the date you expect to move to open the search already prepared for $city.';
  }

  @override
  String get migrationPlanPrepFlightsOriginLabel => 'Departure city';

  @override
  String get migrationPlanPrepFlightsDateLabel => 'Estimated move date';

  @override
  String get migrationPlanPrepFlightsDatePlaceholder => 'Select a date';

  @override
  String get migrationPlanPrepFlightsDisclaimer =>
      'Final prices vary by date, how early you book, and availability. Use this search as a starting point and compare before buying.';

  @override
  String get migrationPlanPrepFlightsOpenGoogle => 'Check on Google Flights';

  @override
  String get migrationPlanPrepOfficialIncomeTitle =>
      'View official income and city indicators';

  @override
  String get migrationPlanPrepOfficialIncomeBody =>
      'Open the official IBGE page for this city to consult municipal indicators, including the panorama used as a reliable source.';

  @override
  String get migrationPlanPrepOfficialJobsTitle =>
      'Search jobs on Emprega Brasil';

  @override
  String get migrationPlanPrepOfficialJobsBodyNoCity =>
      'Open the official government employment portal to look for formal jobs and use your region as the basis of the search.';

  @override
  String migrationPlanPrepOfficialJobsBodyWithCity(Object city, Object state) {
    return 'Open the official government employment portal to look for formal jobs and use $city ($state) as the basis of the search.';
  }

  @override
  String get migrationPlanPrepOfficialStudyCatalogTitle =>
      'View official public universities';

  @override
  String get migrationPlanPrepOfficialStudyCatalogBodyNoCity =>
      'Open the official MEC catalog to search public higher education institutions and filter by state or city.';

  @override
  String migrationPlanPrepOfficialStudyCatalogBodyWithCity(
    Object city,
    Object state,
  ) {
    return 'Open the official MEC catalog to search public higher education institutions and filter by $city ($state) or the nearest region.';
  }

  @override
  String get migrationPlanPrepOfficialStudyForeignersTitle =>
      'Understand foreign student admission';

  @override
  String get migrationPlanPrepOfficialStudyForeignersBody =>
      'Open the official PEC-G route to understand how foreign student admission works and which participating universities already receive this process.';

  @override
  String get migrationPlanPrepRentalSearchTitle =>
      'Search rentals in this city';

  @override
  String migrationPlanPrepRentalSearchBody(Object city, Object state) {
    return 'Open a rental search already filtered for $city ($state) inside the app and compare options by area.';
  }

  @override
  String get migrationPlanPrepRentalProviderLabel => 'Rental portal';

  @override
  String get migrationPlanPrepRentalProviderZap => 'ZAP Imóveis';

  @override
  String get migrationPlanPrepRentalProviderVivaReal => 'Viva Real';

  @override
  String get migrationPlanPrepRentalProviderChaves => 'Chaves na Mão';

  @override
  String get migrationPlanPrepRentalSearchDisclaimer =>
      'Coverage and listings may vary by city and current availability. Check more than one source before deciding.';

  @override
  String get migrationPlanPrepRentalSearchOpen => 'Open rental search';

  @override
  String get migrationPlanPrepScamsTitle => 'How to avoid rental scams';

  @override
  String get migrationPlanPrepScamsBody =>
      'Open a public alert about common fraud in listings and rentals so you do not decide only on price or urgency.';

  @override
  String get phase_before_travel => 'Before travel';

  @override
  String get phase_first_days => 'First days';

  @override
  String get phase_documentation => 'Documentation';

  @override
  String get phase_life_working => 'Life working';

  @override
  String get phase_integration => 'Integration';

  @override
  String get phase_desc_before_travel =>
      'What to prepare in Argentina so you arrive without surprises';

  @override
  String get phase_desc_first_days =>
      'You arrived in Brazil. Focus on getting established and being able to communicate.';

  @override
  String get phase_desc_documentation =>
      'The documents that unlock everything. Do them in this exact order.';

  @override
  String get phase_desc_life_working =>
      'With CPF and residence in progress, now you build the structure of daily life.';

  @override
  String get phase_desc_integration =>
      'Adapt your full life to Brazil and secure long-term stay.';

  @override
  String get item_next_action_tag => 'NEXT ACTION';

  @override
  String get item_external_tag => 'EXTERNAL ACTION';

  @override
  String get item_tool_tag => 'USE A TOOL';

  @override
  String get item_checklist_tag => 'TO COMPLETE';

  @override
  String deadline_badge(Object date) {
    return 'Apply by $date';
  }

  @override
  String get deadline_alert_title => 'Deadline is getting close';

  @override
  String deadline_alert_body(Object days) {
    return 'Your temporary residence expires in $days days. Apply for permanent residence before that.';
  }

  @override
  String get guide_completed_title => 'Plan completed!';

  @override
  String guide_completed_subtitle(Object city) {
    return 'You completed every step in your guide for $city.';
  }

  @override
  String get guide_no_plan_title => 'Choose your city first';

  @override
  String get guide_no_plan_subtitle =>
      'Confirm your plan city to start the guide';

  @override
  String get infoGuideEyebrow => 'Quick guide';

  @override
  String get infoGuideTitle => 'Your migration info hub';

  @override
  String get infoGuideBody =>
      'Find answers about documents, housing, health, work, and costs for your destination country — all in one place.';

  @override
  String get infoGuideStepOneTitle => 'Browse by category';

  @override
  String get infoGuideStepOneBody =>
      'Tap a section card to see detailed guides with official sources for each topic.';

  @override
  String get infoGuideStepTwoTitle => 'Search any topic';

  @override
  String get infoGuideStepTwoBody =>
      'Use the search bar to find specific answers about CPF, visa, SUS, or any other subject.';

  @override
  String get infoGuideStepThreeTitle => 'Ask the Movaro assistant';

  @override
  String get infoGuideStepThreeBody =>
      'Tap the blue button at the bottom right to chat with our assistant and get personalized answers.';

  @override
  String get aiChatTitle => 'Assistant';

  @override
  String get aiChatSubtitle => 'Get answers about migration';

  @override
  String get aiChatClearTooltip => 'Clear chat';

  @override
  String get aiChatInputHint => 'Ask about migration...';

  @override
  String get aiChatWelcomeTitle => 'How can I help?';

  @override
  String get aiChatWelcomeBody =>
      'Ask about documents, housing, health, work and more';

  @override
  String get aiChatErrorRateLimit =>
      'Request limit reached. Please wait a moment.';

  @override
  String get aiChatErrorApiLimit =>
      'API limit reached. Please try again in a few minutes.';

  @override
  String get aiChatErrorGeneric =>
      'Error processing your question. Please try again.';

  @override
  String get aiChatNotInitialized =>
      'Service not initialized. Please try again.';

  @override
  String get aiChatSuggestPassport =>
      'Do I need a passport to travel to Brazil?';

  @override
  String get aiChatSuggestCpf => 'How to get a CPF?';

  @override
  String get aiChatSuggestSus => 'How does SUS (public health) work?';

  @override
  String get aiChatSuggestWork => 'Can I work with a tourist visa?';

  @override
  String get aiChatSuggestCosts => 'How much does it cost to move?';

  @override
  String get aiChatSuggestLicense => 'How to validate my driver\'s license?';

  @override
  String get homeAssistantTitle => 'Movaro Assistant';

  @override
  String get homeAssistantSubtitle => 'Ask anything about your trip';

  @override
  String get homeAssistantSwipeHint => 'Swipe to expand ↑';

  @override
  String get homeAssistantInputPlaceholder => 'Ask something...';

  @override
  String get homeAssistantInputPlaceholderExpanded =>
      'Or type your question...';

  @override
  String homeAssistantWelcome(String destination) {
    return 'Hi! I see you\'re planning $destination. How can I help with your trip?';
  }

  @override
  String get homeAssistantSectionQuickQuestions => 'Quick questions';

  @override
  String get homeAssistantSectionExploreTopics => 'Explore by topic';

  @override
  String get homeAssistantChipVisa => 'Do I need a visa?';

  @override
  String get homeAssistantChipBestTime => 'Best time to go?';

  @override
  String get homeAssistantChipPacking => 'What to pack?';

  @override
  String get homeAssistantChipSafety => 'Is it safe?';

  @override
  String get homeAssistantChipHowToGet => 'How to get there?';

  @override
  String get homeAssistantCategoryDocuments => 'Visa & documents';

  @override
  String get homeAssistantCategoryCosts => 'Costs & budget';

  @override
  String get homeAssistantCategoryActivities => 'Things to do';

  @override
  String get homeAssistantCategoryStay => 'Where to stay';

  @override
  String homeAssistantMessageDocuments(String destination) {
    return 'What documents do I need to travel to $destination?';
  }

  @override
  String homeAssistantMessageCosts(String destination) {
    return 'How much does a trip to $destination cost on average?';
  }

  @override
  String homeAssistantMessageActivities(String destination) {
    return 'What to do in $destination? What are the best activities?';
  }

  @override
  String homeAssistantMessageStay(String destination) {
    return 'What are the best areas to stay in $destination?';
  }

  @override
  String get aiChatLoading => 'Loading assistant...';

  @override
  String get aiChatUnavailable => 'Assistant unavailable';

  @override
  String get aiChatRetry =>
      'The assistant is still loading. Please try again in a moment.';

  @override
  String get aiChatNetworkError =>
      'Connection error. Check your internet and try again.';

  @override
  String get migrationResultRevealEyebrow => 'Current comparison';

  @override
  String get migrationResultRevealHeaderTitle => 'Suggested cities';

  @override
  String get migrationResultRevealRedoAction => 'Answer quick questions again';

  @override
  String migrationResultRevealWhyTitle(String city) {
    return 'Why $city?';
  }

  @override
  String get migrationResultRevealOtherOptionsTitle => 'Other options';

  @override
  String migrationResultRevealStartCta(String city) {
    return 'Start plan in $city';
  }

  @override
  String get migrationResultRevealExploreCity => 'View city details';

  @override
  String get migrationResultRevealCompareCta => 'Compare with alternatives';

  @override
  String migrationResultRevealStartPreparationCta(String city) {
    return 'Start preparation with $city';
  }

  @override
  String get migrationResultRevealRefineAction =>
      'Make this recommendation more precise';

  @override
  String get homeVisualTitlePrefix => 'Thinking about living in ';

  @override
  String get homeVisualTitleHighlight => 'another country?';

  @override
  String get homeVisualSubtitle =>
      'We help you understand what to do, what it may cost, and where to start.';

  @override
  String get homeVisualSupportLine =>
      'You can start even if you have not decided everything yet.';

  @override
  String get homeEntryTitle => 'Find cities that fit your plan';

  @override
  String get homeEntrySubtitle =>
      'Compare cost of living, opportunities, and quality of life to decide where to start.';

  @override
  String get homeEntrySupportLine => 'Takes less than 1 minute';

  @override
  String get homeEntryDiscoverAction => 'Discover cities for me';

  @override
  String get homeEntryKnownCityAction => 'I already have a city to evaluate';

  @override
  String get homeEntryShortcutsTitle => 'Get an answer now';

  @override
  String get homeVisualCostsAction => 'Initial costs';

  @override
  String get homeVisualDocumentsAction => 'Documents';

  @override
  String get homeVisualHousingAction => 'Housing';

  @override
  String get homeVisualStartAction => 'Find where to start';

  @override
  String get homeVisualPrimaryAction => 'Build my plan';

  @override
  String get homeVisualOriginLabel => 'ORIGIN';

  @override
  String get homeVisualDestinationLabel => 'DESTINATION';

  @override
  String get homeVisualWaypointDocuments => 'docs';

  @override
  String get homeVisualWaypointCosts => 'costs';

  @override
  String get homeVisualWaypointRoute => 'route';

  @override
  String get assistantEntryTitle => 'Movaro Assistant';

  @override
  String get assistantEntrySubtitle => 'Get answers about your move';

  @override
  String get assistantEntryOpenAction => 'Open ↑';

  @override
  String get assistantEntryInputHint => 'Or type your question...';

  @override
  String get assistantEntryQuickVisa => 'Do I need a visa?';

  @override
  String get assistantEntryQuickBestTime => 'Best time to go?';

  @override
  String get assistantEntryQuickCpf => 'How to get CPF?';

  @override
  String get assistantModeConversation => '💬 Chat';

  @override
  String get assistantModeGuides => '📋 Guides';

  @override
  String get assistantQuickTopicsTitle => 'Quick topics';

  @override
  String get assistantQuickQuestionsTitle => 'Quick questions';

  @override
  String get assistantOpenGuidesAction => 'Open guide';

  @override
  String get assistantContextChatTitle => 'Chat with context';

  @override
  String assistantContextChatBody(Object origin, Object destination) {
    return 'Ask short questions about the $origin → $destination route. The assistant is best at documents, costs, housing, and next steps.';
  }

  @override
  String get assistantContextGuideTitle => 'Guides by country';

  @override
  String assistantContextGuideBody(Object destination) {
    return 'Choose the country you want to review and open the right topic-based content to unblock your next step in $destination.';
  }

  @override
  String get assistantStartCardTitle => 'Start with the real question';

  @override
  String assistantStartCardBody(Object origin, Object destination) {
    return 'You can ask directly about the $origin → $destination route or open the guide to browse documents, housing, work, and costs.';
  }

  @override
  String get planResetManageAction => 'Start a new plan';

  @override
  String get planResetManageBody =>
      'If you want to restart, you can clear your current progress and build a new plan from the beginning.';

  @override
  String get planMenuTitle => 'Your plan options';

  @override
  String get planMenuSubtitle =>
      'Manage your journey without losing sight of your current progress.';

  @override
  String get planMenuNewPlanBody =>
      'Choose another city, goal, or moving timeline.';

  @override
  String get planMenuSafetyNote =>
      'Your current plan is only erased after you confirm.';

  @override
  String get planResetImpactTitle => 'If you continue, we will reset';

  @override
  String get planResetDialogBody =>
      'The new plan starts with every step at zero, even when its city, goal, or timeline resembles the previous plan.';

  @override
  String get planResetPreservedNote =>
      'Your origin, language, currency, favorites, and settings are kept. Permanent documents can be marked as “already done” in the new plan.';

  @override
  String get planResetRebuildLabel => 'Yes, start from scratch';

  @override
  String get planResetCancelLabel => 'Cancel';

  @override
  String get planResetCurrentPlanFallbackLabel => 'current plan';

  @override
  String planResetCityWarning(String cityName) {
    return 'Your progress in $cityName and all checked items will be erased.';
  }

  @override
  String planResetCancelWithCity(String cityName) {
    return 'Cancel — keep $cityName';
  }

  @override
  String get homeActivePlanBadge => 'ACTIVE PLAN';

  @override
  String get homeJourneyTitle => 'YOUR JOURNEY';

  @override
  String get homeJourneyComplete => 'Journey complete! 🎉';

  @override
  String get homeJourneySeeSummary => 'See summary →';

  @override
  String get homeJourneyContinueGuide => 'Continue guide →';

  @override
  String get homeJourneyViewAction => 'View';

  @override
  String get homeJourneyActiveDaySingle => 'active day';

  @override
  String get homeJourneyActiveDayPlural => 'active days';

  @override
  String get homeJourneyCurrentPhaseMarker => '→ now';

  @override
  String get homeJourneyLockedPhaseMarker => 'lock.';

  @override
  String get homeJourneyPhasePreparation => 'Preparation';

  @override
  String get homeJourneyPhaseDocuments => 'Documentation';

  @override
  String get homeJourneyPhaseHousing => 'Housing';

  @override
  String get homeJourneyPhaseWork => 'Work';

  @override
  String get homeJourneyPhaseArrival => 'Arrival';

  @override
  String get homeJourneyDoneLabel => 'done';

  @override
  String get homeJourneyItemsLabel => 'items';

  @override
  String homeStepperProgress(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get homeStepperUrgent => 'URGENT';

  @override
  String get homeStepperDoNow => 'Do now';

  @override
  String homeStepperSeeMore(String count) {
    return '+ $count more';
  }

  @override
  String get homeActionCompare => 'Compare';

  @override
  String get homeActionViewCity => 'View city';

  @override
  String get homeActionNewPlan => 'New plan';

  @override
  String get homeJourneyPhaseBeforeTravel => 'Before travel';

  @override
  String get homeJourneyPhaseFirstDays => 'First days';

  @override
  String get homeJourneyPhaseDocumentation => 'Documentation';

  @override
  String get homeJourneyPhaseLifeWorking => 'Life working';

  @override
  String get homeJourneyPhaseIntegration => 'Integration';

  @override
  String get questionRemainingTimeUnderOneMinute => 'under 1 min left';

  @override
  String questionRemainingTimeMinutes(int minutes) {
    return '~$minutes min left';
  }

  @override
  String get questionSelectionCounterSelected => 'selected';

  @override
  String get questionArgentinaOriginLitoral =>
      'Litoral (Entre Ríos, Corrientes…)';

  @override
  String get questionArgentinaOriginOther => 'Other';

  @override
  String get questionLocationDetectedTitle => 'Location detected';

  @override
  String questionLocationDetectedBody(String city, String country) {
    return 'We found you in $city, $country. We\'ll use this to personalise your journey.';
  }

  @override
  String get questionLocationContinueAction => 'Continue';

  @override
  String get questionLocationRequestTitle => 'Where are you in Argentina?';

  @override
  String get questionLocationRequestBody =>
      'Your location helps us estimate distances and personalise recommendations.';

  @override
  String get questionLocationUseAction => 'Use my location';

  @override
  String get questionLocationChooseManualAction => 'Choose manually';

  @override
  String get questionLocationManualTitle => 'Where in Argentina are you from?';

  @override
  String get commonDoneCheck => 'Done ✓';

  @override
  String get commonOpenOfficialSiteAction => 'Open official site ->';

  @override
  String get readinessStageOnArrival => 'On arrival';

  @override
  String get arrivalExecutionStageFirstWeek => 'FIRST WEEK — top priority';

  @override
  String get arrivalExecutionStageFirstMonth => 'FIRST MONTH — build your base';

  @override
  String get arrivalExecutionStageFirstQuarter =>
      'FIRST 3 MONTHS — stabilize life';

  @override
  String get cityDetailMediaTitle => 'See videos and photos';

  @override
  String get cityDetailMediaBody => 'Open the city visual content';

  @override
  String get migrationPlanResultCelebrationTitle => 'Plan started!';

  @override
  String migrationPlanResultCelebrationBody(String cityName) {
    return 'You chose $cityName.\nLet’s turn that into reality.';
  }

  @override
  String get chatServiceErrorProcessingQuestion =>
      'I couldn\'t process your question. Please try again.';

  @override
  String get chatFallbackDestination => 'your destination';

  @override
  String chatFallbackMessageDocuments(
    String destination,
    String localDocument,
  ) {
    return 'What documents do I need to move to $destination? Explain visas and $localDocument.';
  }

  @override
  String get chatFallbackMessageCosts =>
      'How much does it cost to move? Give me a cost overview.';

  @override
  String get chatFallbackMessageActivities =>
      'What should I know about life in the destination city?';

  @override
  String chatFallbackMessageStay(String destination) {
    return 'How do I find housing in $destination? Renting tips.';
  }

  @override
  String get chatFallbackFirstLocalDocumentBrazil => 'How do I get my CPF?';

  @override
  String get chatFallbackFirstLocalDocumentDefault =>
      'What is my first local document?';

  @override
  String get commonMonthAbbrevJan => 'Jan';

  @override
  String get commonMonthAbbrevFeb => 'Feb';

  @override
  String get commonMonthAbbrevMar => 'Mar';

  @override
  String get commonMonthAbbrevApr => 'Apr';

  @override
  String get commonMonthAbbrevMay => 'May';

  @override
  String get commonMonthAbbrevJun => 'Jun';

  @override
  String get commonMonthAbbrevJul => 'Jul';

  @override
  String get commonMonthAbbrevAug => 'Aug';

  @override
  String get commonMonthAbbrevSep => 'Sep';

  @override
  String get commonMonthAbbrevOct => 'Oct';

  @override
  String get commonMonthAbbrevNov => 'Nov';

  @override
  String get commonMonthAbbrevDec => 'Dec';

  @override
  String get commonMonthInitialJan => 'J';

  @override
  String get commonMonthInitialFeb => 'F';

  @override
  String get commonMonthInitialMar => 'M';

  @override
  String get commonMonthInitialApr => 'A';

  @override
  String get commonMonthInitialMay => 'M';

  @override
  String get commonMonthInitialJun => 'J';

  @override
  String get commonMonthInitialJul => 'J';

  @override
  String get commonMonthInitialAug => 'A';

  @override
  String get commonMonthInitialSep => 'S';

  @override
  String get commonMonthInitialOct => 'O';

  @override
  String get commonMonthInitialNov => 'N';

  @override
  String get commonMonthInitialDec => 'D';

  @override
  String get flightSeasonalityTitle => 'Best time to fly';

  @override
  String flightSeasonalitySubtitle(String origin, String destination) {
    return '$origin -> $destination · Historical ranges (USD)';
  }

  @override
  String flightSeasonalitySavingsMonths(String months) {
    return 'Cheapest: $months · Up to 40% savings';
  }

  @override
  String get flightSeasonalityFallback =>
      'We do not have enough history for this exact route yet. Use the live search below to see the real origin and destination combination.';

  @override
  String flightSeasonalityLiveButton(String origin, String destination) {
    return 'See live prices  $origin -> $destination';
  }

  @override
  String get flightSeasonalityFooter =>
      'Historical ranges · Real prices vary by date';

  @override
  String flightSeasonalityWebviewTitle(String origin, String destination) {
    return 'Flights $origin -> $destination';
  }

  @override
  String flightSeasonalityLegendLow(int min, int max) {
    return 'Cheap (USD $min-$max)';
  }

  @override
  String get flightSeasonalityLegendMid => 'Average';

  @override
  String get flightSeasonalityLegendHigh => 'Expensive';

  @override
  String get flightSeasonalityBadgePrefix => 'Flight: ';

  @override
  String flightSeasonalityBadgeFrom(int value) {
    return 'from $value USD';
  }

  @override
  String get flightSeasonalityBadgeCheapestPrefix => '  ·  Cheapest: ';

  @override
  String get flightSeasonalityWarningFln =>
      'Florianópolis usually has fewer direct flights outside Mar-Apr. In other months, connections via São Paulo or Porto Alegre are common.';

  @override
  String get flightSeasonalityWarningNvt =>
      'Navegantes serves Balneário, Itajaí, and Blumenau. In part of the year, the best fare appears with a short connection in São Paulo.';

  @override
  String get flightSeasonalityWarningGig =>
      'February usually concentrates the strongest high season in Rio because of Carnival. If that window fits your plan, monitor early.';

  @override
  String get flightSeasonalityWarningMao =>
      'Manaus tends to vary more because of connections and supply. Comparing a few days around your date helps a lot.';

  @override
  String get flightSeasonalityWarningBel =>
      'Belém tends to swing a lot between connections and schedules. It is worth opening the live search with some flexibility.';

  @override
  String get housingSelectionTitle => 'Housing';

  @override
  String get housingTemporaryTitle => 'Temporary';

  @override
  String get housingLongTermTitle => 'Long-term rent';

  @override
  String get housingTemporaryPortalHostelworld => 'Budget hostels and dorms';

  @override
  String get housingTemporaryPortalAirbnb => 'Furnished apartments';

  @override
  String get housingTemporaryPortalBooking => 'Hotels and aparthotels';

  @override
  String get housingTemporaryPortalVivaReal => 'Temporary rental';

  @override
  String get housingTemporaryPortalZap => 'Monthly and seasonal';

  @override
  String housingStayInCityTitle(String city) {
    return 'Stay in $city';
  }

  @override
  String housingTemporarySearchAction(String city, String duration) {
    return 'Search in $city - $duration';
  }

  @override
  String get housingOpenSelectedSourceHint =>
      'Opens in the selected app or site';

  @override
  String get housingLongTermPortalQuintoAndar =>
      'No guarantor · Accepts passport · Digital';

  @override
  String get housingLongTermPortalFlatio =>
      'Medium-term · No deposit · For expats';

  @override
  String get housingLongTermPortalZap => 'Large listing base in Brazil';

  @override
  String get housingLongTermPortalVivaReal =>
      'More detailed photos and floor plans';

  @override
  String get housingLongTermPortalChaves =>
      'Useful coverage across southern cities';

  @override
  String housingPlanCityBanner(String city, String state) {
    return '$city ($state) - your plan city';
  }

  @override
  String get housingPlanCityBannerBody =>
      'Most Argentine movers start with temporary housing and only sign a long contract after learning the neighborhoods. That is usually the safest path.';

  @override
  String get housingTemporaryBadge => 'Often useful on arrival';

  @override
  String get housingTemporaryCardTitle => 'Temporary housing';

  @override
  String get housingTemporaryCardBody =>
      'For the first 30 to 90 days. No long contract, no guarantor, and time to understand the city before deciding.';

  @override
  String get housingTemporaryStatDurationValue => '1-3 months';

  @override
  String get housingTemporaryStatDurationLabel => 'length';

  @override
  String get housingTemporaryStatNoGuarantor => 'No guarantor';

  @override
  String get housingTemporaryStatFurnished => 'Furnished';

  @override
  String get housingTemporaryCardAction => 'Search temporary housing';

  @override
  String get housingLongTermBadge => 'When you already know the city';

  @override
  String get housingLongTermCardTitle => 'Long-term rental';

  @override
  String get housingLongTermCardBody =>
      'A 12 to 30 month contract. Usually cheaper per month, but it often requires guarantees, documents, and more care before signing.';

  @override
  String get housingLongTermCardAction => 'See long-term rental options';

  @override
  String housingTemporaryHeaderTitle(String city) {
    return 'Your base in $city';
  }

  @override
  String get housingTemporaryHeaderBody =>
      'No fixed contract. Furnished. Easy to adjust as you settle in.';

  @override
  String get housingTemporaryAirbnbTip =>
      'Airbnb often gives discounts on 28+ day stays. It is a common soft-landing option after arrival.';

  @override
  String housingLongTermHeaderTitle(String city) {
    return 'Rent in $city';
  }

  @override
  String get housingLongTermHeaderBody =>
      'A 12 to 30 month contract. Usually cheaper long term.';

  @override
  String get housingLongTermStatBedroom => '1 bedroom';

  @override
  String get housingLongTermStatEntryValue => '3x deposit';

  @override
  String get housingLongTermStatEntry => 'entry';

  @override
  String get housingLongTermStatRequired => 'required';

  @override
  String get housingLongTermAlertTitle => 'Before signing any contract';

  @override
  String get housingLongTermAlertBody =>
      'As a foreigner, you will usually need CPF and a guarantee, such as a Brazilian guarantor or rental insurance. Do not sign without reading the clauses carefully.';

  @override
  String get housingLongTermForeignersBadge => 'For foreigners';

  @override
  String get housingForeignTipsTitle => 'Tips for foreigners';

  @override
  String get housingForeignTipOne =>
      'No guarantor? Check rental insurance or deposit paths first.';

  @override
  String get housingForeignTipTwo =>
      'You do not need to wait for full residence approval to start learning the market.';

  @override
  String get housingForeignTipThree =>
      'Always ask for receipts and a signed contract. Never pay without records.';

  @override
  String get housingForeignTipFour =>
      'Be careful with prices that are too low and pressure to close without a visit.';

  @override
  String get housingDurationOneWeek => '7-14 days';

  @override
  String get housingDurationOneMonth => '1 month';

  @override
  String get housingDurationTwoThreeMonths => '2-3 months';

  @override
  String get copilotProgressCompletedLabel => 'completed';

  @override
  String get copilotProgressRemainingLabel => 'remaining';

  @override
  String get copilotPlanCompletedTitle => 'Plan completed!';

  @override
  String get copilotPlanCompletedBody =>
      'You completed every step in your guide.';

  @override
  String get copilotNextActionUnlocked => 'Great. The next action is unlocked.';

  @override
  String get copilotTagNextAction => 'NEXT ACTION';

  @override
  String get copilotTagExternalAction => 'EXTERNAL ACTION';

  @override
  String get copilotTagUseTool => 'USE A TOOL';

  @override
  String get copilotTagToComplete => 'TO COMPLETE';

  @override
  String get copilotCompletionMessageFirst => 'First step done. Keep going.';

  @override
  String copilotCompletionMessageFew(int count) {
    return 'Great pace. $count steps done.';
  }

  @override
  String copilotCompletionMessageMid(int count) {
    return '$count steps completed. You are moving forward.';
  }

  @override
  String copilotCompletionMessageHigh(int count) {
    return 'Amazing — $count steps ready.';
  }

  @override
  String get copilotPrepOverview => 'Plan overview';

  @override
  String get copilotPrepDocuments => 'View my documents';

  @override
  String get copilotPrepHousing => 'View housing';

  @override
  String get copilotPrepWork => 'View work and prep';

  @override
  String get copilotPrepArrival => 'View arrival';

  @override
  String get copilotGoalFindJob => 'looking for work in Brazil';

  @override
  String get copilotGoalRemoteIncome => 'working remotely';

  @override
  String get copilotGoalStudy => 'moving to study';

  @override
  String get copilotGoalFamily => 'bringing family together';

  @override
  String get copilotGoalFreshStart => 'starting over';

  @override
  String get copilotGoalDefault => 'planning the move';

  @override
  String copilotOpenSection(String section) {
    return 'Open: $section';
  }

  @override
  String get copilotJobMarketHigh => 'active — good demand for professionals';

  @override
  String get copilotJobMarketMid =>
      'moderate — opportunities in specific areas';

  @override
  String get copilotJobMarketLow => 'developing — research before you arrive';

  @override
  String get copilotPhaseShortPreparation => 'Prep';

  @override
  String get copilotPhaseShortHousing => '1st days';

  @override
  String get copilotPhaseShortDocuments => 'Docs';

  @override
  String get copilotPhaseShortWork => 'Life';

  @override
  String get copilotPhaseShortArrival => 'Settle';

  @override
  String get copilotButtonNextStep => 'Got it, next step';

  @override
  String get copilotButtonViewDetails => 'View details';

  @override
  String get copilotButtonChecked => 'I\'ve checked this';

  @override
  String copilotButtonOpen(String label) {
    return 'Open $label';
  }

  @override
  String get copilotButtonCompleteStep => 'Complete this step';

  @override
  String get copilotButtonOpenTool => 'Open tool';

  @override
  String get copilotButtonComplete => 'Complete';

  @override
  String get citySeasonalityTitle => 'Seasonality';

  @override
  String get citySeasonalityHighSeverityLabel =>
      'Intense peak season — plan carefully';

  @override
  String get citySeasonalityMediumSeverityLabel =>
      'Moderate seasonality — plan ahead';

  @override
  String get citySeasonalityShowDetails => 'See housing & work impacts';

  @override
  String get citySeasonalityHideDetails => 'Hide details';

  @override
  String get citySeasonalityHousingTitle => 'Housing during peak season';

  @override
  String get citySeasonalityJobsTitle => 'Job market';

  @override
  String get citySeasonalityPopulationPrefix => 'population';

  @override
  String get citySeasonalityHighAdvice =>
      'Tip: arriving outside peak season (May–Oct) may open more long-term rental options at reasonable prices. If peak season is your only window, booking accommodation at least 3 months in advance may help.';

  @override
  String get citySeasonalityMediumAdvice =>
      'Tip: sign a long-term lease before the peak season starts. This locks in a stable price even when tourist demand rises.';

  @override
  String get citySeasonalityCardBadgeHigh => 'Peak season';

  @override
  String get citySeasonalityCardBadgeMedium => 'Seasonal';
}

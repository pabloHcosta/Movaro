import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Movaro'**
  String get homeTitle;

  /// No description provided for @homeEnvironmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current environment'**
  String get homeEnvironmentLabel;

  /// No description provided for @environmentValue.
  ///
  /// In en, this message translates to:
  /// **'{environment}'**
  String environmentValue(String environment);

  /// No description provided for @splashLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Getting your experience ready'**
  String get splashLoadingLabel;

  /// No description provided for @splashHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration planning with more clarity.'**
  String get splashHeroTitle;

  /// No description provided for @splashHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Loading cities, costs, and practical context to shape your first route.'**
  String get splashHeroBody;

  /// No description provided for @splashInitializingLabel.
  ///
  /// In en, this message translates to:
  /// **'Initializing your experience'**
  String get splashInitializingLabel;

  /// No description provided for @loadingCountriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading countries'**
  String get loadingCountriesLabel;

  /// No description provided for @loadingCitiesCatalogLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading city catalog'**
  String get loadingCitiesCatalogLabel;

  /// No description provided for @journeySetupPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your route'**
  String get journeySetupPageTitle;

  /// No description provided for @journeySetupHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Start by defining where you are coming from and where you want to go'**
  String get journeySetupHeroTitle;

  /// No description provided for @journeySetupHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro uses this choice to shape the right experience for you. Today, the beta is open for Argentina -> Brazil, but the structure is already built to grow globally.'**
  String get journeySetupHeroBody;

  /// No description provided for @journeyOriginTitle.
  ///
  /// In en, this message translates to:
  /// **'Origin country'**
  String get journeyOriginTitle;

  /// No description provided for @journeyOriginBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the country you are leaving from. This helps contextualize language, paperwork, and adaptation.'**
  String get journeyOriginBody;

  /// No description provided for @journeyDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination country'**
  String get journeyDestinationTitle;

  /// No description provided for @journeyDestinationBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the country you want to evaluate. The home screen and your plan will reflect that destination.'**
  String get journeyDestinationBody;

  /// No description provided for @journeySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your current route'**
  String get journeySummaryTitle;

  /// No description provided for @journeySummaryValue.
  ///
  /// In en, this message translates to:
  /// **'{origin} -> {destination}'**
  String journeySummaryValue(String origin, String destination);

  /// No description provided for @journeySummaryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your origin and destination to continue.'**
  String get journeySummaryPlaceholder;

  /// No description provided for @journeyAvailabilityNote.
  ///
  /// In en, this message translates to:
  /// **'Right now, only the Argentina -> Brazil route is fully available. Other countries are already visible to signal the product’s global direction.'**
  String get journeyAvailabilityNote;

  /// No description provided for @journeyContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue with this route'**
  String get journeyContinueAction;

  /// No description provided for @journeyAvailableNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get journeyAvailableNowLabel;

  /// No description provided for @journeyComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get journeyComingSoonLabel;

  /// No description provided for @journeyChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change route'**
  String get journeyChangeAction;

  /// No description provided for @publicHomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Plan your move with more clarity'**
  String get publicHomeHeadline;

  /// No description provided for @publicHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Understand your options in a few steps before deciding what to save.'**
  String get publicHomeDescription;

  /// No description provided for @publicHomeScopeBadge.
  ///
  /// In en, this message translates to:
  /// **'Today: Argentina -> Brazil'**
  String get publicHomeScopeBadge;

  /// No description provided for @publicHomeFocusedDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro is currently designed for people evaluating a move from Argentina to Brazil. Instead of showing everything at once, it helps you choose the best first step.'**
  String get publicHomeFocusedDescription;

  /// No description provided for @publicHomeSelectedJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro will organize your experience for the {origin} -> {destination} journey. You start with what matters now and go deeper only when it helps.'**
  String publicHomeSelectedJourneyDescription(
    String origin,
    String destination,
  );

  /// No description provided for @publicHomePrimaryQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the main decision'**
  String get publicHomePrimaryQuestionTitle;

  /// No description provided for @publicHomePrimaryQuestionBody.
  ///
  /// In en, this message translates to:
  /// **'First, decide whether you need a guided plan, a city comparison, or just a quick overview of what the product does.'**
  String get publicHomePrimaryQuestionBody;

  /// No description provided for @publicHomeTrustFastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast start'**
  String get publicHomeTrustFastTitle;

  /// No description provided for @publicHomeTrustFastBody.
  ///
  /// In en, this message translates to:
  /// **'You can get started without a long form or an initial barrier.'**
  String get publicHomeTrustFastBody;

  /// No description provided for @publicHomeTrustGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'No login for now'**
  String get publicHomeTrustGuestTitle;

  /// No description provided for @publicHomeTrustGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Explore as a guest and sign in only when saving becomes useful.'**
  String get publicHomeTrustGuestBody;

  /// No description provided for @publicHomeTrustFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear scope'**
  String get publicHomeTrustFocusTitle;

  /// No description provided for @publicHomeTrustFocusBody.
  ///
  /// In en, this message translates to:
  /// **'This beta is focused on the Argentina -> Brazil corridor.'**
  String get publicHomeTrustFocusBody;

  /// No description provided for @publicHomeTrustSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your navigation is now contextualized for {origin} -> {destination}, without surfacing irrelevant content before you choose.'**
  String publicHomeTrustSelectedBody(String origin, String destination);

  /// No description provided for @publicHomeFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your first step'**
  String get publicHomeFirstStepTitle;

  /// No description provided for @publicHomeFirstStepBody.
  ///
  /// In en, this message translates to:
  /// **'The home screen is here to guide your entry point. Deeper content comes later, inside the path you choose.'**
  String get publicHomeFirstStepBody;

  /// No description provided for @publicHomeSecondaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Documentation comes later'**
  String get publicHomeSecondaryTitle;

  /// No description provided for @publicHomeSecondaryBody.
  ///
  /// In en, this message translates to:
  /// **'The Brazil practical guide is still available, but as support. It makes more sense after you understand whether you want a guided plan or a city comparison.'**
  String get publicHomeSecondaryBody;

  /// No description provided for @publicHomeSecondaryGenericBody.
  ///
  /// In en, this message translates to:
  /// **'When a new destination becomes available, documentation and local details should appear as contextual support, not as noise on the first screen.'**
  String get publicHomeSecondaryGenericBody;

  /// No description provided for @publicHomeExploreAction.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get publicHomeExploreAction;

  /// No description provided for @publicHomeQuestionnaireAction.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get publicHomeQuestionnaireAction;

  /// No description provided for @publicHomeLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in when I need to save'**
  String get publicHomeLoginAction;

  /// No description provided for @publicHomeGuestSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'You can start in guest mode'**
  String get publicHomeGuestSectionTitle;

  /// No description provided for @publicHomeGuestSectionBody.
  ///
  /// In en, this message translates to:
  /// **'You can explore all of this without signing in. Sign-in only appears when it makes sense to save something personal.'**
  String get publicHomeGuestSectionBody;

  /// No description provided for @publicHomeBetaSectionBody.
  ///
  /// In en, this message translates to:
  /// **'This beta already opens what is ready: exploration, practical documentation, and your first plan.'**
  String get publicHomeBetaSectionBody;

  /// No description provided for @publicHomeHowItWorksAction.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get publicHomeHowItWorksAction;

  /// No description provided for @publicHomeCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover cities'**
  String get publicHomeCitiesTitle;

  /// No description provided for @publicHomeCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'See suggestions based on cost, work, and popularity among Argentinians.'**
  String get publicHomeCitiesBody;

  /// No description provided for @publicHomeCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'See cities'**
  String get publicHomeCitiesAction;

  /// No description provided for @publicHomeQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practical guide'**
  String get publicHomeQuestionsTitle;

  /// No description provided for @publicHomeQuestionsBody.
  ///
  /// In en, this message translates to:
  /// **'Open the guide to understand documents, healthcare, housing, and first costs without scattered research.'**
  String get publicHomeQuestionsBody;

  /// No description provided for @publicHomeQuestionsAction.
  ///
  /// In en, this message translates to:
  /// **'Clear my doubts'**
  String get publicHomeQuestionsAction;

  /// No description provided for @homeHeroWelcomeDefault.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Movaro'**
  String get homeHeroWelcomeDefault;

  /// No description provided for @homeHeroWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get homeHeroWelcomeBack;

  /// No description provided for @homeHeroGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String homeHeroGreetingMorning(Object name);

  /// No description provided for @homeHeroGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String homeHeroGreetingAfternoon(Object name);

  /// No description provided for @homeHeroGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String homeHeroGreetingEvening(Object name);

  /// No description provided for @homeHeroSubtitleNoPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan your move'**
  String get homeHeroSubtitleNoPlan;

  /// No description provided for @homeHeroSubtitleWithPlan.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get homeHeroSubtitleWithPlan;

  /// No description provided for @homeHeroOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get homeHeroOriginLabel;

  /// No description provided for @homeHeroDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get homeHeroDestinationLabel;

  /// No description provided for @homeHeroNoPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your migration plan in 3 steps'**
  String get homeHeroNoPlanTitle;

  /// No description provided for @homeHeroNoPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions and get a recommended city that fits your profile.'**
  String get homeHeroNoPlanBody;

  /// No description provided for @homeHeroStepQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Answer quick questions'**
  String get homeHeroStepQuestionnaire;

  /// No description provided for @homeHeroStepCity.
  ///
  /// In en, this message translates to:
  /// **'Get ideal city'**
  String get homeHeroStepCity;

  /// No description provided for @homeHeroStepGuide.
  ///
  /// In en, this message translates to:
  /// **'Execute with guide'**
  String get homeHeroStepGuide;

  /// No description provided for @homeHeroStartAction.
  ///
  /// In en, this message translates to:
  /// **'Build my plan -> takes ~5 min'**
  String get homeHeroStartAction;

  /// No description provided for @homeHeroPlanActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Active plan'**
  String get homeHeroPlanActiveBadge;

  /// No description provided for @homeHeroSelectedCityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your chosen city'**
  String get homeHeroSelectedCityEyebrow;

  /// No description provided for @homeHeroProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall plan progress'**
  String get homeHeroProgressLabel;

  /// No description provided for @homeHeroStageMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get homeHeroStageMetricLabel;

  /// No description provided for @homeHeroStageTotalValue.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get homeHeroStageTotalValue;

  /// No description provided for @homeHeroCostMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'COST'**
  String get homeHeroCostMetricLabel;

  /// No description provided for @homeHeroClimateMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'CLIMATE'**
  String get homeHeroClimateMetricLabel;

  /// No description provided for @homeHeroNextStepLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT STEP'**
  String get homeHeroNextStepLabel;

  /// No description provided for @homeHeroContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue plan ->'**
  String get homeHeroContinueAction;

  /// No description provided for @homeHeroDiscoverCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Cost, jobs, and quality of life'**
  String get homeHeroDiscoverCitiesBody;

  /// No description provided for @homeHeroDiscoverCitiesBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'See alternatives to {city}'**
  String homeHeroDiscoverCitiesBodyWithCity(Object city);

  /// No description provided for @homeHeroExploreAction.
  ///
  /// In en, this message translates to:
  /// **'Explore ->'**
  String get homeHeroExploreAction;

  /// No description provided for @homeHeroGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Documents and arrival in Brazil'**
  String get homeHeroGuideBody;

  /// No description provided for @homeHeroOpenGuideAction.
  ///
  /// In en, this message translates to:
  /// **'Open guide ->'**
  String get homeHeroOpenGuideAction;

  /// No description provided for @homeHeroOpenShortAction.
  ///
  /// In en, this message translates to:
  /// **'Open ->'**
  String get homeHeroOpenShortAction;

  /// No description provided for @homeHeroExploreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeHeroExploreSectionTitle;

  /// No description provided for @homeHeroPlanCompleteTask.
  ///
  /// In en, this message translates to:
  /// **'Review completed plan'**
  String get homeHeroPlanCompleteTask;

  /// No description provided for @publicHomePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get publicHomePlanTitle;

  /// No description provided for @publicHomePlanBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and get a clear starter plan with better suggestions.'**
  String get publicHomePlanBody;

  /// No description provided for @publicHomeJourneyDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your plan with your destination already set'**
  String get publicHomeJourneyDraftTitle;

  /// No description provided for @publicHomeJourneyDraftBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re heading toward {destination}. Next, answer a few short questions and tell us where you\'re coming from so Movaro can generate the right plan.'**
  String publicHomeJourneyDraftBody(Object destination);

  /// No description provided for @publicHomeStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Read real experiences'**
  String get publicHomeStoriesTitle;

  /// No description provided for @publicHomeStoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Understand what other people are looking for before deciding your next step.'**
  String get publicHomeStoriesBody;

  /// No description provided for @publicHomeStoriesAction.
  ///
  /// In en, this message translates to:
  /// **'Explore stories'**
  String get publicHomeStoriesAction;

  /// No description provided for @decisionSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the question that matters most'**
  String get decisionSupportTitle;

  /// No description provided for @decisionSupportBody.
  ///
  /// In en, this message translates to:
  /// **'People moving abroad usually want quick first answers about language, cost, paperwork, and work. Movaro should make that obvious.'**
  String get decisionSupportBody;

  /// No description provided for @decisionSupportLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Can I manage daily life there without Portuguese?'**
  String get decisionSupportLanguageTitle;

  /// No description provided for @decisionSupportLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Use the language adaptation signal to find places that feel easier for a Spanish speaker at the beginning.'**
  String get decisionSupportLanguageBody;

  /// No description provided for @decisionSupportCostTitle.
  ///
  /// In en, this message translates to:
  /// **'Will daily life feel too expensive?'**
  String get decisionSupportCostTitle;

  /// No description provided for @decisionSupportCostBody.
  ///
  /// In en, this message translates to:
  /// **'Compare cities through cost and rent before going deep into a destination.'**
  String get decisionSupportCostBody;

  /// No description provided for @decisionSupportPaperworkTitle.
  ///
  /// In en, this message translates to:
  /// **'What are the first paperwork steps?'**
  String get decisionSupportPaperworkTitle;

  /// No description provided for @decisionSupportPaperworkBody.
  ///
  /// In en, this message translates to:
  /// **'The guided plan turns uncertainty into a short first checklist instead of a long research spiral.'**
  String get decisionSupportPaperworkBody;

  /// No description provided for @decisionSupportWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should I start if I need work or structure?'**
  String get decisionSupportWorkTitle;

  /// No description provided for @decisionSupportWorkBody.
  ///
  /// In en, this message translates to:
  /// **'The questionnaire and city ranking help narrow the search to places with a better early fit.'**
  String get decisionSupportWorkBody;

  /// No description provided for @commonNeedsTitle.
  ///
  /// In en, this message translates to:
  /// **'If you still do not know where to start'**
  String get commonNeedsTitle;

  /// No description provided for @commonNeedsBody.
  ///
  /// In en, this message translates to:
  /// **'These are the most useful shortcuts for someone arriving with mixed doubts and wanting clarity before deciding.'**
  String get commonNeedsBody;

  /// No description provided for @commonNeedCompareCostTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to compare cost and rent first'**
  String get commonNeedCompareCostTitle;

  /// No description provided for @commonNeedCompareCostBody.
  ///
  /// In en, this message translates to:
  /// **'Go straight to cities and use cost, rent, language, and work signals as your first read.'**
  String get commonNeedCompareCostBody;

  /// No description provided for @commonNeedDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'I need to understand documents before anything else'**
  String get commonNeedDocumentsTitle;

  /// No description provided for @commonNeedDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'The documentation guide summarizes CPF, registration, stay, work, and banking with official sources and simpler language.'**
  String get commonNeedDocumentsBody;

  /// No description provided for @commonNeedDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'I still do not know which path fits me'**
  String get commonNeedDirectionTitle;

  /// No description provided for @commonNeedDirectionBody.
  ///
  /// In en, this message translates to:
  /// **'The guided plan reduces uncertainty to one first city and a short order of first steps.'**
  String get commonNeedDirectionBody;

  /// No description provided for @commonNeedExploreAllTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to see everything without getting stuck'**
  String get commonNeedExploreAllTitle;

  /// No description provided for @commonNeedExploreAllBody.
  ///
  /// In en, this message translates to:
  /// **'Explore brings cities, documentation, and other paths together in one place.'**
  String get commonNeedExploreAllBody;

  /// No description provided for @explorePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explorePageTitle;

  /// No description provided for @explorePublicFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Public exploration'**
  String get explorePublicFeaturesTitle;

  /// No description provided for @explorePublicFeaturesDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover cities and countries that are visible to every guest user.'**
  String get explorePublicFeaturesDescription;

  /// No description provided for @exploreDocumentationTitle.
  ///
  /// In en, this message translates to:
  /// **'Practical life in Brazil'**
  String get exploreDocumentationTitle;

  /// No description provided for @exploreDocumentationDescription.
  ///
  /// In en, this message translates to:
  /// **'Understand documents, health, driving, work, and banking in simpler language.'**
  String get exploreDocumentationDescription;

  /// No description provided for @exploreDocumentationAction.
  ///
  /// In en, this message translates to:
  /// **'See documentation'**
  String get exploreDocumentationAction;

  /// No description provided for @exploreCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'View cities'**
  String get exploreCitiesAction;

  /// No description provided for @exploreCountriesAction.
  ///
  /// In en, this message translates to:
  /// **'View countries'**
  String get exploreCountriesAction;

  /// No description provided for @exploreCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community content'**
  String get exploreCommunityTitle;

  /// No description provided for @exploreCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Community content remains public, but posting requires authentication.'**
  String get exploreCommunityDescription;

  /// No description provided for @exploreCreatePostAction.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get exploreCreatePostAction;

  /// No description provided for @exploreIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use Movaro'**
  String get exploreIntroTitle;

  /// No description provided for @exploreIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Before diving into the app, see in under a minute what Movaro helps with and what is already available in this beta.'**
  String get exploreIntroDescription;

  /// No description provided for @exploreIntroAction.
  ///
  /// In en, this message translates to:
  /// **'Open introduction'**
  String get exploreIntroAction;

  /// No description provided for @exploreChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Your initial plan'**
  String get exploreChecklistTitle;

  /// No description provided for @exploreChecklistDescription.
  ///
  /// In en, this message translates to:
  /// **'Guests can answer a short flow and generate an initial migration plan before signing in.'**
  String get exploreChecklistDescription;

  /// No description provided for @exploreQuestionnaireAction.
  ///
  /// In en, this message translates to:
  /// **'Answer quick questions'**
  String get exploreQuestionnaireAction;

  /// No description provided for @exploreTrailsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Three clear paths'**
  String get exploreTrailsEyebrow;

  /// No description provided for @exploreTrailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the kind of help you need right now'**
  String get exploreTrailsTitle;

  /// No description provided for @exploreTrailsBody.
  ///
  /// In en, this message translates to:
  /// **'Instead of showing everything at once, the app now splits the experience into three tracks: decide the city, understand practical bureaucracy, and prepare the move.'**
  String get exploreTrailsBody;

  /// No description provided for @exploreTrailCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Decide the city'**
  String get exploreTrailCitiesTitle;

  /// No description provided for @exploreTrailCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Compare cities and use coast, cost, work, language, and housing signals to see which context fits you better.'**
  String get exploreTrailCitiesBody;

  /// No description provided for @exploreTrailDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand practical bureaucracy'**
  String get exploreTrailDocsTitle;

  /// No description provided for @exploreTrailDocsBody.
  ///
  /// In en, this message translates to:
  /// **'See rent, SUS, CPF, work, driving, and initial costs in clearer sections with less noise.'**
  String get exploreTrailDocsBody;

  /// No description provided for @exploreTrailPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the move'**
  String get exploreTrailPrepTitle;

  /// No description provided for @exploreTrailPrepBodyStart.
  ///
  /// In en, this message translates to:
  /// **'If you have not confirmed a city yet, start with the initial plan to organize the decision.'**
  String get exploreTrailPrepBodyStart;

  /// No description provided for @exploreTrailPrepBodyReady.
  ///
  /// In en, this message translates to:
  /// **'Since you have already confirmed a city, this track focuses on checklist, documents, housing, and arrival.'**
  String get exploreTrailPrepBodyReady;

  /// No description provided for @exploreSavePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get exploreSavePlanAction;

  /// No description provided for @exploreUnifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore cities, content, and your next move in one place'**
  String get exploreUnifiedTitle;

  /// No description provided for @exploreUnifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Use this area to reinforce your decision, review the city options that still matter, and open the practical content that matches your route.'**
  String get exploreUnifiedBody;

  /// No description provided for @explorePlanSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your plan'**
  String get explorePlanSectionTitle;

  /// No description provided for @explorePlanSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Resume the current plan, reopen the leading city, or jump straight into the most useful guide for your next step.'**
  String get explorePlanSectionBody;

  /// No description provided for @exploreCitiesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover other cities'**
  String get exploreCitiesSectionTitle;

  /// No description provided for @exploreCitiesSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Keep comparing before locking the decision. These cities are strong alternatives for your current route and profile.'**
  String get exploreCitiesSectionBody;

  /// No description provided for @exploreContentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Useful content'**
  String get exploreContentSectionTitle;

  /// No description provided for @exploreContentSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Open the practical guidance that usually matters next: documents, housing, and work.'**
  String get exploreContentSectionBody;

  /// No description provided for @exploreRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Journey: {origin} -> {destination}'**
  String exploreRouteLabel(Object origin, Object destination);

  /// No description provided for @exploreDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination selected: {destination}'**
  String exploreDestinationLabel(Object destination);

  /// No description provided for @exploreNoJourneyLabel.
  ///
  /// In en, this message translates to:
  /// **'Set a destination to make exploration more relevant.'**
  String get exploreNoJourneyLabel;

  /// No description provided for @explorePlanEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a plan before you go deeper'**
  String get explorePlanEmptyTitle;

  /// No description provided for @explorePlanEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your destination, answer a few questions, and let Movaro turn exploration into a practical direction.'**
  String get explorePlanEmptyBody;

  /// No description provided for @explorePlanReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready to continue'**
  String get explorePlanReadyTitle;

  /// No description provided for @explorePlanReadyBody.
  ///
  /// In en, this message translates to:
  /// **'{city} is already confirmed. Open your checklist and keep moving through the next actions.'**
  String explorePlanReadyBody(Object city);

  /// No description provided for @explorePlanDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan still needs a decision'**
  String get explorePlanDraftTitle;

  /// No description provided for @explorePlanDraftBody.
  ///
  /// In en, this message translates to:
  /// **'You already have a draft. Reopen the result and confirm the city before moving into checklist mode.'**
  String get explorePlanDraftBody;

  /// No description provided for @explorePlanDraftBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'{city} is currently leading. Reopen the result, compare it, and confirm it when ready.'**
  String explorePlanDraftBodyWithCity(Object city);

  /// No description provided for @exploreRecommendedCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Leading city right now'**
  String get exploreRecommendedCityTitle;

  /// No description provided for @exploreRecommendedCityBody.
  ///
  /// In en, this message translates to:
  /// **'Open the city details to validate cost, quality of life, and fit with your plan.'**
  String get exploreRecommendedCityBody;

  /// No description provided for @exploreOpenCityAction.
  ///
  /// In en, this message translates to:
  /// **'Open city'**
  String get exploreOpenCityAction;

  /// No description provided for @exploreOpenContentAction.
  ///
  /// In en, this message translates to:
  /// **'Open guide'**
  String get exploreOpenContentAction;

  /// No description provided for @explorePlanDocsBody.
  ///
  /// In en, this message translates to:
  /// **'Documents usually unlock the next part of the move faster than more comparison.'**
  String get explorePlanDocsBody;

  /// No description provided for @exploreContentDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'See CPF, registration, banking, and legal stay with less noise and clearer routing.'**
  String get exploreContentDocumentsBody;

  /// No description provided for @exploreContentHousingBody.
  ///
  /// In en, this message translates to:
  /// **'Review rent pressure, guarantees, deposits, and first-landing decisions before choosing a neighborhood.'**
  String get exploreContentHousingBody;

  /// No description provided for @exploreContentWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Check work setup, contribution paths, and what to validate before treating income as solved.'**
  String get exploreContentWorkBody;

  /// No description provided for @documentationPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Documentation and practical life'**
  String get documentationPageTitle;

  /// No description provided for @documentationHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Practical guide'**
  String get documentationHeroEyebrow;

  /// No description provided for @documentationHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand practical life in Brazil with more clarity'**
  String get documentationHeroTitle;

  /// No description provided for @documentationHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Type a question or choose a topic. Movaro helps you find the right guidance and guide across documents, health, work, housing, mobility, and early costs.'**
  String get documentationHeroDescription;

  /// No description provided for @documentationFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Useful for your current journey'**
  String get documentationFocusTitle;

  /// No description provided for @documentationFocusBody.
  ///
  /// In en, this message translates to:
  /// **'These categories are the strongest starting point for moving from {origin} to {destination}.'**
  String documentationFocusBody(Object origin, Object destination);

  /// No description provided for @documentationFocusBodyDestination.
  ///
  /// In en, this message translates to:
  /// **'These categories are a strong starting point for your route into {destination}.'**
  String documentationFocusBodyDestination(Object destination);

  /// No description provided for @documentationFocusBodyDefault.
  ///
  /// In en, this message translates to:
  /// **'Open the category that removes the biggest blocker first: documents, housing, or work.'**
  String get documentationFocusBodyDefault;

  /// No description provided for @documentationHeroStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Type a question'**
  String get documentationHeroStepOneTitle;

  /// No description provided for @documentationHeroStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'You can search in English, Portuguese, or Spanish.'**
  String get documentationHeroStepOneBody;

  /// No description provided for @documentationHeroStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic'**
  String get documentationHeroStepTwoTitle;

  /// No description provided for @documentationHeroStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Filter by documents, health, work, housing, mobility, and costs.'**
  String get documentationHeroStepTwoBody;

  /// No description provided for @documentationHeroStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the right guide'**
  String get documentationHeroStepThreeTitle;

  /// No description provided for @documentationHeroStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Jump into a quick answer or the full block when you need more context.'**
  String get documentationHeroStepThreeBody;

  /// No description provided for @documentationSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you need to understand?'**
  String get documentationSearchLabel;

  /// No description provided for @documentationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Ex.: can I work with visitor status? / CPF / banco / salud / costs'**
  String get documentationSearchHint;

  /// No description provided for @documentationSearchSupport.
  ///
  /// In en, this message translates to:
  /// **'You can search in English, Portuguese, or Spanish.'**
  String get documentationSearchSupport;

  /// No description provided for @documentationSearchPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with search or a topic'**
  String get documentationSearchPanelTitle;

  /// No description provided for @documentationSearchPanelBody.
  ///
  /// In en, this message translates to:
  /// **'Type your question or tap a topic to reach the right block faster.'**
  String get documentationSearchPanelBody;

  /// No description provided for @documentationGuideHideNextTime.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get documentationGuideHideNextTime;

  /// No description provided for @documentationGuideStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 steps'**
  String get documentationGuideStepsLabel;

  /// No description provided for @documentationGuideDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get documentationGuideDismissAction;

  /// No description provided for @documentationGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get documentationGuidePrimaryAction;

  /// No description provided for @documentationGuideModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the practical guide faster'**
  String get documentationGuideModalTitle;

  /// No description provided for @documentationGuideModalBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the country you want to review, search a topic or question, and open the section that removes the next blocker.'**
  String get documentationGuideModalBody;

  /// No description provided for @documentationGuideModalStepCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the country'**
  String get documentationGuideModalStepCountryTitle;

  /// No description provided for @documentationGuideModalStepCountryBody.
  ///
  /// In en, this message translates to:
  /// **'The guide opens with your destination country when available, but you can switch countries at any time.'**
  String get documentationGuideModalStepCountryBody;

  /// No description provided for @documentationGuideModalStepSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by need'**
  String get documentationGuideModalStepSearchTitle;

  /// No description provided for @documentationGuideModalStepSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Type a topic, document, or everyday question to jump to the most relevant section.'**
  String get documentationGuideModalStepSearchBody;

  /// No description provided for @documentationGuideModalStepOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the section'**
  String get documentationGuideModalStepOpenTitle;

  /// No description provided for @documentationGuideModalStepOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Use filters or results to go straight into documents, housing, health, work, driving, or costs.'**
  String get documentationGuideModalStepOpenBody;

  /// No description provided for @documentationGuideNoPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'No plan selected yet'**
  String get documentationGuideNoPlanTitle;

  /// No description provided for @documentationGuideNoPlanBody.
  ///
  /// In en, this message translates to:
  /// **'You can still use the practical guide. We loaded {country} for now, and you can switch countries whenever you need.'**
  String documentationGuideNoPlanBody(Object country);

  /// No description provided for @documentationGuideCountryPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'{country} guide is not available yet'**
  String documentationGuideCountryPendingTitle(Object country);

  /// No description provided for @documentationGuideCountryPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro currently has practical guide coverage for Brazil. Choose Brazil to continue browsing the available guidance.'**
  String get documentationGuideCountryPendingBody;

  /// No description provided for @documentationGuideUsingPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'From your plan'**
  String get documentationGuideUsingPlanLabel;

  /// No description provided for @documentationGuideManualCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Manual country'**
  String get documentationGuideManualCountryLabel;

  /// No description provided for @documentationSearchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items found'**
  String documentationSearchResultsCount(int count);

  /// No description provided for @documentationSearchResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an item to open the topic or jump straight to filtered results.'**
  String get documentationSearchResultsHint;

  /// No description provided for @documentationFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get documentationFilterAll;

  /// No description provided for @documentationQuickRoutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic shortcuts'**
  String get documentationQuickRoutesTitle;

  /// No description provided for @documentationQuickRoutesBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe and jump straight into the right block if you already know which topic you want to solve.'**
  String get documentationQuickRoutesBody;

  /// No description provided for @documentationQuickChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick choices'**
  String get documentationQuickChoicesTitle;

  /// No description provided for @documentationQuickChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Filter by topic or use ready-made questions to reach the right block faster.'**
  String get documentationQuickChoicesBody;

  /// No description provided for @documentationResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide results'**
  String get documentationResultsTitle;

  /// No description provided for @documentationResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a quick answer or open the full topic when you need more depth.'**
  String get documentationResultsBody;

  /// No description provided for @documentationResultsFilteredBody.
  ///
  /// In en, this message translates to:
  /// **'Search mixes quick answers and full topic blocks to shorten the path to the right information.'**
  String get documentationResultsFilteredBody;

  /// No description provided for @documentationViewMatchesAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get documentationViewMatchesAction;

  /// No description provided for @documentationNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that term'**
  String get documentationNoResultsTitle;

  /// No description provided for @documentationNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try CPF, registration, work, visa, health, rent, or costs.'**
  String get documentationNoResultsBody;

  /// No description provided for @documentationQuickStepCpf.
  ///
  /// In en, this message translates to:
  /// **'CPF'**
  String get documentationQuickStepCpf;

  /// No description provided for @documentationQuickStepRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get documentationQuickStepRegistration;

  /// No description provided for @documentationQuickStepStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get documentationQuickStepStay;

  /// No description provided for @documentationQuickStepWorkBank.
  ///
  /// In en, this message translates to:
  /// **'Work and banking'**
  String get documentationQuickStepWorkBank;

  /// No description provided for @documentationQuickStepCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Naturalization'**
  String get documentationQuickStepCitizenship;

  /// No description provided for @documentationQuickStepHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get documentationQuickStepHealth;

  /// No description provided for @documentationQuickStepDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get documentationQuickStepDriving;

  /// No description provided for @documentationQuickStepWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get documentationQuickStepWork;

  /// No description provided for @documentationQuickStepRetirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get documentationQuickStepRetirement;

  /// No description provided for @documentationOfficialSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get documentationOfficialSourceLabel;

  /// No description provided for @documentationPathsTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the question that matters most'**
  String get documentationPathsTitle;

  /// No description provided for @documentationPathsBody.
  ///
  /// In en, this message translates to:
  /// **'Instead of reading everything, pick the area that matters most right now. The rest stays available when you need more depth.'**
  String get documentationPathsBody;

  /// No description provided for @documentationHousingArrivalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Housing and arrival'**
  String get documentationHousingArrivalSectionTitle;

  /// No description provided for @documentationHousingArrivalSectionBody.
  ///
  /// In en, this message translates to:
  /// **'See rent, upfront entry cost, guarantees, soft landing, and how to avoid the first mistakes.'**
  String get documentationHousingArrivalSectionBody;

  /// No description provided for @documentationNavigatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to find each topic'**
  String get documentationNavigatorTitle;

  /// No description provided for @documentationNavigatorBody.
  ///
  /// In en, this message translates to:
  /// **'Use these blocks to find rent, SUS, work, driving, and costs faster without reading the full page at once.'**
  String get documentationNavigatorBody;

  /// No description provided for @documentationNavigatorHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing and rent'**
  String get documentationNavigatorHousing;

  /// No description provided for @documentationNavigatorHealth.
  ///
  /// In en, this message translates to:
  /// **'SUS and health'**
  String get documentationNavigatorHealth;

  /// No description provided for @documentationNavigatorWork.
  ///
  /// In en, this message translates to:
  /// **'Work and income'**
  String get documentationNavigatorWork;

  /// No description provided for @documentationNavigatorDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving in Brazil'**
  String get documentationNavigatorDriving;

  /// No description provided for @documentationNavigatorCosts.
  ///
  /// In en, this message translates to:
  /// **'Initial costs'**
  String get documentationNavigatorCosts;

  /// No description provided for @documentationNavigatorDocuments.
  ///
  /// In en, this message translates to:
  /// **'Core documents'**
  String get documentationNavigatorDocuments;

  /// No description provided for @documentationPathDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents and legal stay'**
  String get documentationPathDocumentsTitle;

  /// No description provided for @documentationPathDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'CPF, registration, stay timing, and what usually unlocks practical life first.'**
  String get documentationPathDocumentsBody;

  /// No description provided for @documentationPathHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health in daily life'**
  String get documentationPathHealthTitle;

  /// No description provided for @documentationPathHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Understand when it makes sense to use SUS, a local health post, a hospital, or a private plan.'**
  String get documentationPathHealthBody;

  /// No description provided for @documentationPathDrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'Driving and mobility'**
  String get documentationPathDrivingTitle;

  /// No description provided for @documentationPathDrivingBody.
  ///
  /// In en, this message translates to:
  /// **'See whether your foreign license helps at the beginning and when you should check with Detran.'**
  String get documentationPathDrivingBody;

  /// No description provided for @documentationPathWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Work and contributions'**
  String get documentationPathWorkTitle;

  /// No description provided for @documentationPathWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Understand formal employment, PJ work, and how each one connects to public retirement contributions.'**
  String get documentationPathWorkBody;

  /// No description provided for @documentationPathCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Early costs'**
  String get documentationPathCostsTitle;

  /// No description provided for @documentationPathCostsBody.
  ///
  /// In en, this message translates to:
  /// **'Read approximate costs in reais, pesos, and dollars without confusing a reference value with a final price.'**
  String get documentationPathCostsBody;

  /// No description provided for @documentationOpenTopicAction.
  ///
  /// In en, this message translates to:
  /// **'Open topic'**
  String get documentationOpenTopicAction;

  /// No description provided for @documentationQuickAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick answers for the most common questions'**
  String get documentationQuickAnswersTitle;

  /// No description provided for @documentationQuickAnswersBody.
  ///
  /// In en, this message translates to:
  /// **'Before opening every card, start with these short answers. If one already answers your question, you save time.'**
  String get documentationQuickAnswersBody;

  /// No description provided for @documentationAnswerWorkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I work with visitor status alone?'**
  String get documentationAnswerWorkQuestion;

  /// No description provided for @documentationAnswerWorkAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. Formal work requires a compatible migration status and regular registration.'**
  String get documentationAnswerWorkAnswer;

  /// No description provided for @documentationAnswerTravelDocQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do I need a passport to travel from Argentina to Brazil?'**
  String get documentationAnswerTravelDocQuestion;

  /// No description provided for @documentationAnswerTravelDocAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not necessarily. Argentine citizens can travel to Brazil with a valid physical DNI in good condition and with a photo that clearly identifies the holder. A proof of document renewal or issuance is not enough.'**
  String get documentationAnswerTravelDocAnswer;

  /// No description provided for @documentationAnswerCpfQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does CPF alone solve banking and contracts?'**
  String get documentationAnswerCpfQuestion;

  /// No description provided for @documentationAnswerCpfAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. CPF helps a lot, but it usually does not replace a regular migration document.'**
  String get documentationAnswerCpfAnswer;

  /// No description provided for @documentationAnswerRegistrationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is migration registration completed immediately?'**
  String get documentationAnswerRegistrationQuestion;

  /// No description provided for @documentationAnswerRegistrationAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. The protocol already matters while the CRNM is being issued, so the process does not depend on an instant card.'**
  String get documentationAnswerRegistrationAnswer;

  /// No description provided for @documentationAnswerStayQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is staying longer as a visitor the same as living regularly?'**
  String get documentationAnswerStayQuestion;

  /// No description provided for @documentationAnswerStayAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. For someone who plans to live in Brazil, regular residence is usually the right path.'**
  String get documentationAnswerStayAnswer;

  /// No description provided for @documentationAnswerSusQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can a foreign national use SUS?'**
  String get documentationAnswerSusQuestion;

  /// No description provided for @documentationAnswerSusAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. SUS is universal in Brazil, and the Ministry of Health explicitly reaffirms access for foreign nationals.'**
  String get documentationAnswerSusAnswer;

  /// No description provided for @documentationAnswerSusCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do I need a SUS card or CPF before getting care?'**
  String get documentationAnswerSusCardQuestion;

  /// No description provided for @documentationAnswerSusCardAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not necessarily. Registration helps with follow-up care, but initial access, and especially urgent care, should not depend on having everything ready.'**
  String get documentationAnswerSusCardAnswer;

  /// No description provided for @documentationAnswerForeignLicenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I drive at first with my foreign license?'**
  String get documentationAnswerForeignLicenseQuestion;

  /// No description provided for @documentationAnswerForeignLicenseAnswer.
  ///
  /// In en, this message translates to:
  /// **'In general, yes, for a limited period, with a valid document and subject to the applicable agreement. After that, it is better to confirm with the state Detran.'**
  String get documentationAnswerForeignLicenseAnswer;

  /// No description provided for @documentationAnswerBrazilianLicenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I later get a Brazilian license?'**
  String get documentationAnswerBrazilianLicenseQuestion;

  /// No description provided for @documentationAnswerBrazilianLicenseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, if you are regular in the country and meet Detran requirements. The process and fees vary by state.'**
  String get documentationAnswerBrazilianLicenseAnswer;

  /// No description provided for @documentationAnswerWorkCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does formal employment still exist, and how does it work?'**
  String get documentationAnswerWorkCardQuestion;

  /// No description provided for @documentationAnswerWorkCardAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. In formal CLT employment, the relationship is registered and the Carteira de Trabalho Digital holds the work record.'**
  String get documentationAnswerWorkCardAnswer;

  /// No description provided for @documentationAnswerPjQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is PJ work the same as monotributo?'**
  String get documentationAnswerPjQuestion;

  /// No description provided for @documentationAnswerPjAnswer.
  ///
  /// In en, this message translates to:
  /// **'It may feel similar as a self-employed or company-based model, but it is not the same legal structure. Tax, retirement, and contract rules vary by arrangement in Brazil.'**
  String get documentationAnswerPjAnswer;

  /// No description provided for @documentationAnswerMarketQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is Brazil a good place to build income from work?'**
  String get documentationAnswerMarketQuestion;

  /// No description provided for @documentationAnswerMarketAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, but the practical expectation is steady income and gradual growth, not exceptionally high pay right away. Brazil has a large and diversified labor market, but earnings vary a lot by city, sector, language, and your legal work status.'**
  String get documentationAnswerMarketAnswer;

  /// No description provided for @documentationAnswerSafetyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is safety in Brazil the same everywhere?'**
  String get documentationAnswerSafetyQuestion;

  /// No description provided for @documentationAnswerSafetyAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. Safety varies a lot by state, city, neighborhood, and daily routine. The safest way to plan is to compare the specific area where you want to live and move around, not to treat the whole country as one block.'**
  String get documentationAnswerSafetyAnswer;

  /// No description provided for @documentationAnswerInssQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is public retirement in Brazil handled through INSS?'**
  String get documentationAnswerInssQuestion;

  /// No description provided for @documentationAnswerInssAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. INSS is the main public retirement gateway for benefits such as retirement, as long as contributions and eligibility rules are met.'**
  String get documentationAnswerInssAnswer;

  /// No description provided for @documentationAnswerRetirementQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does retirement depend only on age?'**
  String get documentationAnswerRetirementQuestion;

  /// No description provided for @documentationAnswerRetirementAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. Minimum age matters, but contribution time and transition rules matter too.'**
  String get documentationAnswerRetirementAnswer;

  /// No description provided for @documentationHealthSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Public health vs. private health'**
  String get documentationHealthSectionTitle;

  /// No description provided for @documentationHealthSectionBody.
  ///
  /// In en, this message translates to:
  /// **'The key is understanding the role of each path. Public health is not a cheap insurance plan, and private health does not replace careful coverage comparison.'**
  String get documentationHealthSectionBody;

  /// No description provided for @documentationWorkSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How work and retirement connect'**
  String get documentationWorkSectionTitle;

  /// No description provided for @documentationWorkSectionBody.
  ///
  /// In en, this message translates to:
  /// **'It helps to separate your work model from the way you contribute. Formal employment, CNPJ-based work, and INSS contributions are related, but not the same thing.'**
  String get documentationWorkSectionBody;

  /// No description provided for @documentationDrivingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How to think about driving without overcomplicating it'**
  String get documentationDrivingSectionTitle;

  /// No description provided for @documentationDrivingSectionBody.
  ///
  /// In en, this message translates to:
  /// **'The safest approach is to split this into three questions: Can I drive now? What must I validate in the state? When is it worth starting the Brazilian license process?'**
  String get documentationDrivingSectionBody;

  /// No description provided for @documentationDeepDiveTitle.
  ///
  /// In en, this message translates to:
  /// **'If you need one more level of detail'**
  String get documentationDeepDiveTitle;

  /// No description provided for @documentationDeepDiveBody.
  ///
  /// In en, this message translates to:
  /// **'This is where the full cards with official sources stay. They are still short, but they help when the quick answer is not enough.'**
  String get documentationDeepDiveBody;

  /// No description provided for @documentationCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Approximate costs that help with first decisions'**
  String get documentationCostsTitle;

  /// No description provided for @documentationCostsBody.
  ///
  /// In en, this message translates to:
  /// **'When a national value or a useful official reference exists, the app shows an approximate conversion to support your first reading.'**
  String get documentationCostsBody;

  /// No description provided for @documentationCostsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Approximate exchange rate updated at {value}'**
  String documentationCostsUpdatedAt(String value);

  /// No description provided for @documentationCostsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The exchange rate could not be updated right now. Values in BRL remain as the reference.'**
  String get documentationCostsUnavailable;

  /// No description provided for @documentationCostsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Use this as early guidance only. Costs vary by state, provider, age, coverage, and local rules.'**
  String get documentationCostsDisclaimer;

  /// No description provided for @documentationCostFreeValue.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get documentationCostFreeValue;

  /// No description provided for @documentationCostVariableValue.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get documentationCostVariableValue;

  /// No description provided for @documentationCostCpfTitle.
  ///
  /// In en, this message translates to:
  /// **'Official CPF request'**
  String get documentationCostCpfTitle;

  /// No description provided for @documentationCostCpfSupporting.
  ///
  /// In en, this message translates to:
  /// **'The official request is free; the app treats it as zero cost.'**
  String get documentationCostCpfSupporting;

  /// No description provided for @documentationCostSusCardTitle.
  ///
  /// In en, this message translates to:
  /// **'SUS card and first registration'**
  String get documentationCostSusCardTitle;

  /// No description provided for @documentationCostSusCardSupporting.
  ///
  /// In en, this message translates to:
  /// **'Public registration and issuance do not usually require direct payment.'**
  String get documentationCostSusCardSupporting;

  /// No description provided for @documentationCostPublicCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial SUS care'**
  String get documentationCostPublicCareTitle;

  /// No description provided for @documentationCostPublicCareSupporting.
  ///
  /// In en, this message translates to:
  /// **'A UBS, health post, or public entry point does not work like a paid private consultation.'**
  String get documentationCostPublicCareSupporting;

  /// No description provided for @documentationCostDrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'First driving license'**
  String get documentationCostDrivingTitle;

  /// No description provided for @documentationCostDrivingValue.
  ///
  /// In en, this message translates to:
  /// **'Official example'**
  String get documentationCostDrivingValue;

  /// No description provided for @documentationCostDrivingSupporting.
  ///
  /// In en, this message translates to:
  /// **'Recent Detran-ES reference: R\$ 533.34. Your state and driving school may charge differently.'**
  String get documentationCostDrivingSupporting;

  /// No description provided for @documentationCostPrivateHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Private health plan'**
  String get documentationCostPrivateHealthTitle;

  /// No description provided for @documentationCostPrivateHealthSupporting.
  ///
  /// In en, this message translates to:
  /// **'There is no single national price. Age, coverage, network, and waiting periods can significantly change the final cost.'**
  String get documentationCostPrivateHealthSupporting;

  /// No description provided for @documentationCpfTitle.
  ///
  /// In en, this message translates to:
  /// **'CPF'**
  String get documentationCpfTitle;

  /// No description provided for @documentationCpfSummary.
  ///
  /// In en, this message translates to:
  /// **'The first practical document that helps with banking, contracts, and registrations.'**
  String get documentationCpfSummary;

  /// No description provided for @documentationCpfBulletOne.
  ///
  /// In en, this message translates to:
  /// **'A foreign national can request a CPF; in Brazil, the process can be started online or through a partnered entity.'**
  String get documentationCpfBulletOne;

  /// No description provided for @documentationCpfBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'The official service lists an estimated time of up to 30 calendar days.'**
  String get documentationCpfBulletTwo;

  /// No description provided for @documentationCpfBulletThree.
  ///
  /// In en, this message translates to:
  /// **'CPF does not replace your migration document, but it usually unlocks a large part of daily life.'**
  String get documentationCpfBulletThree;

  /// No description provided for @documentationTravelDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel document from Argentina to Brazil'**
  String get documentationTravelDocsTitle;

  /// No description provided for @documentationTravelDocsSummary.
  ///
  /// In en, this message translates to:
  /// **'For tourism and initial entry, a passport is not the only option. The key is traveling with a recognized physical identity document that is valid for Mercosur travel.'**
  String get documentationTravelDocsSummary;

  /// No description provided for @documentationTravelDocsBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Argentine citizens may travel to Brazil with a national identity document (DNI) or a passport.'**
  String get documentationTravelDocsBulletOne;

  /// No description provided for @documentationTravelDocsBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'The document must be in good condition and allow the holder to be clearly identified through the photo.'**
  String get documentationTravelDocsBulletTwo;

  /// No description provided for @documentationTravelDocsBulletThree.
  ///
  /// In en, this message translates to:
  /// **'A document-in-process receipt, damaged documents, or older documents not accepted under migration rules may block departure or boarding.'**
  String get documentationTravelDocsBulletThree;

  /// No description provided for @documentationRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration registration and CRNM'**
  String get documentationRegistrationTitle;

  /// No description provided for @documentationRegistrationSummary.
  ///
  /// In en, this message translates to:
  /// **'After entering regularly, registration with the Federal Police is usually the key next step.'**
  String get documentationRegistrationSummary;

  /// No description provided for @documentationRegistrationBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Anyone who enters with a temporary visa must register within 90 days after entering Brazil.'**
  String get documentationRegistrationBulletOne;

  /// No description provided for @documentationRegistrationBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'If residence authorization was granted inside Brazil, registration must happen within 30 days.'**
  String get documentationRegistrationBulletTwo;

  /// No description provided for @documentationRegistrationBulletThree.
  ///
  /// In en, this message translates to:
  /// **'The CRNM may take around 30 business days to be issued; the official service allows a longer total window, and the protocol preserves rights.'**
  String get documentationRegistrationBulletThree;

  /// No description provided for @documentationStayTitle.
  ///
  /// In en, this message translates to:
  /// **'How long can I stay?'**
  String get documentationStayTitle;

  /// No description provided for @documentationStaySummary.
  ///
  /// In en, this message translates to:
  /// **'For an Argentinian user, the practical path is usually regular residence instead of relying on visitor status.'**
  String get documentationStaySummary;

  /// No description provided for @documentationStayBulletOne.
  ///
  /// In en, this message translates to:
  /// **'A visitor visa is not designed for living in Brazil or for paid work.'**
  String get documentationStayBulletOne;

  /// No description provided for @documentationStayBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Residence under the Mercosur Agreement can be granted for 2 years.'**
  String get documentationStayBulletTwo;

  /// No description provided for @documentationStayBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Before that period ends, you may request conversion to indefinite residence if you meet the requirements.'**
  String get documentationStayBulletThree;

  /// No description provided for @documentationWorkBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Work and bank account'**
  String get documentationWorkBankTitle;

  /// No description provided for @documentationWorkBankSummary.
  ///
  /// In en, this message translates to:
  /// **'Working and opening an account depend more on regular status than on a single magic document.'**
  String get documentationWorkBankSummary;

  /// No description provided for @documentationWorkBankBulletOne.
  ///
  /// In en, this message translates to:
  /// **'A visitor visa does not authorize paid work in Brazil.'**
  String get documentationWorkBankBulletOne;

  /// No description provided for @documentationWorkBankBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'To work formally, you need a compatible migration status and regular registration.'**
  String get documentationWorkBankBulletTwo;

  /// No description provided for @documentationWorkBankBulletThree.
  ///
  /// In en, this message translates to:
  /// **'A bank may request additional documents; CPF helps, but a regular migration document usually matters during onboarding.'**
  String get documentationWorkBankBulletThree;

  /// No description provided for @documentationCitizenshipTitle.
  ///
  /// In en, this message translates to:
  /// **'Naturalization'**
  String get documentationCitizenshipTitle;

  /// No description provided for @documentationCitizenshipSummary.
  ///
  /// In en, this message translates to:
  /// **'Brazilian nationality does not come from CPF time alone; it depends on regular residence and its own legal rules.'**
  String get documentationCitizenshipSummary;

  /// No description provided for @documentationCitizenshipBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Ordinary naturalization generally requires indefinite residence in Brazil.'**
  String get documentationCitizenshipBulletOne;

  /// No description provided for @documentationCitizenshipBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'The general rule requires 4 years of residence before applying, along with other legal requirements.'**
  String get documentationCitizenshipBulletTwo;

  /// No description provided for @documentationCitizenshipBulletThree.
  ///
  /// In en, this message translates to:
  /// **'There are official cases that reduce that period, so it is worth checking the exact rule before planning your path.'**
  String get documentationCitizenshipBulletThree;

  /// No description provided for @documentationHealthPublicTitle.
  ///
  /// In en, this message translates to:
  /// **'SUS, local health posts, and public access'**
  String get documentationHealthPublicTitle;

  /// No description provided for @documentationHealthPublicSummary.
  ///
  /// In en, this message translates to:
  /// **'Public health in Brazil is not a prepaid access plan. The logic is universal access, with different entry points depending on what you need.'**
  String get documentationHealthPublicSummary;

  /// No description provided for @documentationHealthPublicBulletOne.
  ///
  /// In en, this message translates to:
  /// **'SUS provides universal access, including for foreign nationals in Brazil.'**
  String get documentationHealthPublicBulletOne;

  /// No description provided for @documentationHealthPublicBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'A UBS or local health post is usually the first point of access for routine care, follow-up, vaccines, and basic care.'**
  String get documentationHealthPublicBulletTwo;

  /// No description provided for @documentationHealthPublicBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Urgent and emergency care follow a different access path; do not wait until every registration step is finished before seeking help.'**
  String get documentationHealthPublicBulletThree;

  /// No description provided for @documentationHealthFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to find the right kind of care'**
  String get documentationHealthFlowTitle;

  /// No description provided for @documentationHealthFlowSummary.
  ///
  /// In en, this message translates to:
  /// **'Not every health question starts at a hospital. It helps to know when to look for a UBS, UPA, hospital, or official app.'**
  String get documentationHealthFlowSummary;

  /// No description provided for @documentationHealthFlowBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Use a UBS or health post for routine care, referrals, prescriptions, and follow-up.'**
  String get documentationHealthFlowBulletOne;

  /// No description provided for @documentationHealthFlowBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Use a UPA or hospital when the case is urgent, acute, or cannot wait for a basic appointment.'**
  String get documentationHealthFlowBulletTwo;

  /// No description provided for @documentationHealthFlowBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Meu SUS Digital and the local health department help locate units, exams, and follow-up information.'**
  String get documentationHealthFlowBulletThree;

  /// No description provided for @documentationHealthPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private health'**
  String get documentationHealthPrivateTitle;

  /// No description provided for @documentationHealthPrivateSummary.
  ///
  /// In en, this message translates to:
  /// **'A private plan may improve convenience and network speed, but it becomes a recurring cost and needs careful coverage comparison.'**
  String get documentationHealthPrivateSummary;

  /// No description provided for @documentationHealthPrivateBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Private health plans are paid products regulated by ANS.'**
  String get documentationHealthPrivateBulletOne;

  /// No description provided for @documentationHealthPrivateBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Price, network, coverage, and waiting periods vary by contract, age, and operator.'**
  String get documentationHealthPrivateBulletTwo;

  /// No description provided for @documentationHealthPrivateBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Before signing, compare network, coverage, and rules in official ANS material, not only the price.'**
  String get documentationHealthPrivateBulletThree;

  /// No description provided for @documentationWorkCltTitle.
  ///
  /// In en, this message translates to:
  /// **'Formal employment'**
  String get documentationWorkCltTitle;

  /// No description provided for @documentationWorkCltSummary.
  ///
  /// In en, this message translates to:
  /// **'In formal work, the employment relationship follows CLT and the record appears in the Carteira de Trabalho Digital.'**
  String get documentationWorkCltSummary;

  /// No description provided for @documentationWorkCltBulletOne.
  ///
  /// In en, this message translates to:
  /// **'Formal employment is the clearest and most recognizable model of formal work in Brazil.'**
  String get documentationWorkCltBulletOne;

  /// No description provided for @documentationWorkCltBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Your work history can be followed through the Carteira de Trabalho Digital.'**
  String get documentationWorkCltBulletTwo;

  /// No description provided for @documentationWorkCltBulletThree.
  ///
  /// In en, this message translates to:
  /// **'In this model, the link with retirement contributions is usually more integrated into payroll.'**
  String get documentationWorkCltBulletThree;

  /// No description provided for @documentationWorkPjTitle.
  ///
  /// In en, this message translates to:
  /// **'PJ, CNPJ, and independent work'**
  String get documentationWorkPjTitle;

  /// No description provided for @documentationWorkPjSummary.
  ///
  /// In en, this message translates to:
  /// **'Working as a PJ or through a CNPJ changes the logic of the relationship. It may resemble monotributo culturally, but it is not the same legal structure.'**
  String get documentationWorkPjSummary;

  /// No description provided for @documentationWorkPjBulletOne.
  ///
  /// In en, this message translates to:
  /// **'PJ is not formal employment; the relationship is business-based or self-employed, not employment-based.'**
  String get documentationWorkPjBulletOne;

  /// No description provided for @documentationWorkPjBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Opening a CNPJ and contributing to retirement are connected topics, but not automatic in every case.'**
  String get documentationWorkPjBulletTwo;

  /// No description provided for @documentationWorkPjBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Before accepting this model, understand taxes, contract terms, and how retirement contributions will work.'**
  String get documentationWorkPjBulletThree;

  /// No description provided for @documentationWorkMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Labor market and income expectations'**
  String get documentationWorkMarketTitle;

  /// No description provided for @documentationWorkMarketSummary.
  ///
  /// In en, this message translates to:
  /// **'Brazil offers scale and many work formats, but migration planning should assume moderate income and gradual progression rather than unusually high salaries in the first stage.'**
  String get documentationWorkMarketSummary;

  /// No description provided for @documentationWorkMarketBulletOne.
  ///
  /// In en, this message translates to:
  /// **'In the rolling quarter ending in October 2025, IBGE recorded unemployment at 5.4%, habitual average earnings at R\$ 3,528, and a record 39.2 million formally registered private-sector workers.'**
  String get documentationWorkMarketBulletOne;

  /// No description provided for @documentationWorkMarketBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'That combination shows a large and active market, with room in services, commerce, logistics, health, education, technology, and local business networks.'**
  String get documentationWorkMarketBulletTwo;

  /// No description provided for @documentationWorkMarketBulletThree.
  ///
  /// In en, this message translates to:
  /// **'For someone arriving from abroad, the safest reading is to plan around realistic income, reserve capital, and city-by-city differences in wages and formalization.'**
  String get documentationWorkMarketBulletThree;

  /// No description provided for @documentationRetirementTitle.
  ///
  /// In en, this message translates to:
  /// **'Public retirement and pension system'**
  String get documentationRetirementTitle;

  /// No description provided for @documentationRetirementSummary.
  ///
  /// In en, this message translates to:
  /// **'In Brazil, public retirement revolves around INSS, with minimum age, contribution time, and transition rules shaping each case differently.'**
  String get documentationRetirementSummary;

  /// No description provided for @documentationRetirementBulletOne.
  ///
  /// In en, this message translates to:
  /// **'The current general age-based rule uses a minimum age of 62 for women and 65 for men.'**
  String get documentationRetirementBulletOne;

  /// No description provided for @documentationRetirementBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Contribution time still matters, especially under transition rules and eligibility analysis.'**
  String get documentationRetirementBulletTwo;

  /// No description provided for @documentationRetirementBulletThree.
  ///
  /// In en, this message translates to:
  /// **'For someone arriving from abroad, it is safest to understand early how contributions will happen in Brazil.'**
  String get documentationRetirementBulletThree;

  /// No description provided for @documentationSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety: read it by city and neighborhood'**
  String get documentationSafetyTitle;

  /// No description provided for @documentationSafetySummary.
  ///
  /// In en, this message translates to:
  /// **'Safety in Brazil is not uniform. The useful decision is not whether the country is \'safe\' in the abstract, but how the exact city, neighborhood, commute, and schedule fit your routine.'**
  String get documentationSafetySummary;

  /// No description provided for @documentationSafetyBulletOne.
  ///
  /// In en, this message translates to:
  /// **'The 2025 Brazilian Public Security Yearbook is based on official public security data from states and police forces and is the broadest snapshot of the sector in the country.'**
  String get documentationSafetyBulletOne;

  /// No description provided for @documentationSafetyBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'Its data shows strong variation across states and crime categories, which is why national averages alone are not enough to choose where to live.'**
  String get documentationSafetyBulletTwo;

  /// No description provided for @documentationSafetyBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Before renting or accepting a job, compare neighborhood context, nighttime mobility, route patterns, and the practical routine you will actually have.'**
  String get documentationSafetyBulletThree;

  /// No description provided for @documentationDrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'First driving license in Brazil'**
  String get documentationDrivingTitle;

  /// No description provided for @documentationDrivingSummary.
  ///
  /// In en, this message translates to:
  /// **'If you are going to live in Brazil, a Brazilian license depends on the state Detran and a local process with mandatory steps.'**
  String get documentationDrivingSummary;

  /// No description provided for @documentationDrivingBulletOne.
  ///
  /// In en, this message translates to:
  /// **'The process usually includes medical and psychological exams, classes, a theory test, and a practical test.'**
  String get documentationDrivingBulletOne;

  /// No description provided for @documentationDrivingBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'A regularized foreign national can enter the process if the state identification and residence requirements are met.'**
  String get documentationDrivingBulletTwo;

  /// No description provided for @documentationDrivingBulletThree.
  ///
  /// In en, this message translates to:
  /// **'Fees and final costs vary by Detran and driving school, so treat the displayed value only as guidance.'**
  String get documentationDrivingBulletThree;

  /// No description provided for @documentationForeignLicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Foreign license and initial driving'**
  String get documentationForeignLicenseTitle;

  /// No description provided for @documentationForeignLicenseSummary.
  ///
  /// In en, this message translates to:
  /// **'Having a valid foreign license may help at the beginning, but it does not permanently replace the need to confirm the Brazilian rule.'**
  String get documentationForeignLicenseSummary;

  /// No description provided for @documentationForeignLicenseBulletOne.
  ///
  /// In en, this message translates to:
  /// **'The ability to drive with a foreign license depends on validity, identification, and the rule that applies to your case.'**
  String get documentationForeignLicenseBulletOne;

  /// No description provided for @documentationForeignLicenseBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'An initial period of use does not mean automatic equivalence for your entire stay in Brazil.'**
  String get documentationForeignLicenseBulletTwo;

  /// No description provided for @documentationForeignLicenseBulletThree.
  ///
  /// In en, this message translates to:
  /// **'If you plan to settle in Brazil, confirm early with the state Detran whether there will be registration, exchange, or a full new process.'**
  String get documentationForeignLicenseBulletThree;

  /// No description provided for @citiesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get citiesPageTitle;

  /// No description provided for @countriesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countriesPageTitle;

  /// No description provided for @publicAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Public access'**
  String get publicAccessLabel;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginPageTitle;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Sign in only when it makes sense for you'**
  String get loginHeadline;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro keeps exploration open. Sign-in appears only when you want to save something personal.'**
  String get loginDescription;

  /// No description provided for @loginGoogleAction.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogleAction;

  /// No description provided for @loginAppleAction.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginAppleAction;

  /// No description provided for @loginDevOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'These buttons use FakeAuthDataSource only in development.'**
  String get loginDevOnlyHint;

  /// No description provided for @loginLaterAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get loginLaterAction;

  /// No description provided for @loginActionRequired.
  ///
  /// In en, this message translates to:
  /// **'To {action}, we need to link this action to you.'**
  String loginActionRequired(String action);

  /// No description provided for @pendingActionSavePlan.
  ///
  /// In en, this message translates to:
  /// **'save your plan'**
  String get pendingActionSavePlan;

  /// No description provided for @pendingActionPostCommunity.
  ///
  /// In en, this message translates to:
  /// **'post in the community'**
  String get pendingActionPostCommunity;

  /// No description provided for @pendingActionSaveCity.
  ///
  /// In en, this message translates to:
  /// **'save this city'**
  String get pendingActionSaveCity;

  /// No description provided for @onboardingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your route'**
  String get onboardingPageTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'To start, choose your origin and destination'**
  String get onboardingHeadline;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'That helps us organize the next steps in the right way for you.'**
  String get onboardingDescription;

  /// No description provided for @onboardingOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'Where are you coming from?'**
  String get onboardingOriginLabel;

  /// No description provided for @onboardingDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get onboardingDestinationLabel;

  /// No description provided for @onboardingContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinueAction;

  /// No description provided for @authenticatedHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your space'**
  String get authenticatedHomeTitle;

  /// No description provided for @authenticatedWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String authenticatedWelcome(String name);

  /// No description provided for @authenticatedHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'This is where you pick up what you were doing and find your main shortcuts.'**
  String get authenticatedHomeDescription;

  /// No description provided for @authenticatedPlanSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get authenticatedPlanSectionTitle;

  /// No description provided for @authenticatedShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Helpful shortcuts'**
  String get authenticatedShortcutsTitle;

  /// No description provided for @authenticatedCitiesShortcut.
  ///
  /// In en, this message translates to:
  /// **'See cities'**
  String get authenticatedCitiesShortcut;

  /// No description provided for @authenticatedSearchShortcut.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get authenticatedSearchShortcut;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @onboardingSummary.
  ///
  /// In en, this message translates to:
  /// **'Origin: {origin}  Destination: {destination}'**
  String onboardingSummary(String origin, String destination);

  /// No description provided for @savedPlansCount.
  ///
  /// In en, this message translates to:
  /// **'Saved plans: {count}'**
  String savedPlansCount(int count);

  /// No description provided for @startNewPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Start a new plan'**
  String get startNewPlanAction;

  /// No description provided for @questionnairePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions'**
  String get questionnairePageTitle;

  /// No description provided for @questionnaireLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparing your quick questions'**
  String get questionnaireLoadingLabel;

  /// No description provided for @questionnaireSupportText.
  ///
  /// In en, this message translates to:
  /// **'It takes less than a minute. One question at a time.'**
  String get questionnaireSupportText;

  /// No description provided for @questionnaireSectionOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get questionnaireSectionOrigin;

  /// No description provided for @questionnaireSectionBasicProfile.
  ///
  /// In en, this message translates to:
  /// **'Basic profile'**
  String get questionnaireSectionBasicProfile;

  /// No description provided for @questionnaireSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get questionnaireSectionPreferences;

  /// No description provided for @questionnaireSectionFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial situation'**
  String get questionnaireSectionFinancial;

  /// No description provided for @questionnaireSectionGoal.
  ///
  /// In en, this message translates to:
  /// **'Migration goal'**
  String get questionnaireSectionGoal;

  /// No description provided for @questionnaireNextSection.
  ///
  /// In en, this message translates to:
  /// **'Next: {section}'**
  String questionnaireNextSection(Object section);

  /// No description provided for @questionnaireReadyForPlan.
  ///
  /// In en, this message translates to:
  /// **'Next, we will turn these answers into your first plan.'**
  String get questionnaireReadyForPlan;

  /// No description provided for @questionnaireProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building your first plan'**
  String get questionnaireProcessingTitle;

  /// No description provided for @questionnaireProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'We are connecting your journey, profile, and priorities into a clear starting point.'**
  String get questionnaireProcessingBody;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @nextAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get nextAction;

  /// No description provided for @generatePlanAction.
  ///
  /// In en, this message translates to:
  /// **'See my plan'**
  String get generatePlanAction;

  /// No description provided for @migrationPlanPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first plan'**
  String get migrationPlanPageTitle;

  /// No description provided for @migrationPlanSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'What you told us'**
  String get migrationPlanSummaryTitle;

  /// No description provided for @planRecommendedCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested city to start with'**
  String get planRecommendedCityTitle;

  /// No description provided for @planRecommendedCityDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your choices, Movaro suggests looking at {city}, {stateCode} first.'**
  String planRecommendedCityDescription(String city, String stateCode);

  /// No description provided for @planRecommendedCityAction.
  ///
  /// In en, this message translates to:
  /// **'View this city'**
  String get planRecommendedCityAction;

  /// No description provided for @planSummaryOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin: {value}'**
  String planSummaryOrigin(String value);

  /// No description provided for @planSummaryDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination: {value}'**
  String planSummaryDestination(String value);

  /// No description provided for @planSummaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {value}'**
  String planSummaryGoal(String value);

  /// No description provided for @planSummaryTimeline.
  ///
  /// In en, this message translates to:
  /// **'Move timing: {value}'**
  String planSummaryTimeline(String value);

  /// No description provided for @migrationPlanStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested first steps'**
  String get migrationPlanStepsTitle;

  /// No description provided for @planNextActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What usually comes right after this'**
  String get planNextActionsTitle;

  /// No description provided for @planNextActionsBody.
  ///
  /// In en, this message translates to:
  /// **'If this result helped, the next move is usually to confirm documents, compare the suggested city with alternatives, or rebuild the plan around a different priority.'**
  String get planNextActionsBody;

  /// No description provided for @planNextActionDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm documents before acting'**
  String get planNextActionDocumentsTitle;

  /// No description provided for @planNextActionDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'Use the practical guide to review CPF, registration, stay, work, and banking without falling into scattered research.'**
  String get planNextActionDocumentsBody;

  /// No description provided for @planNextActionCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare other cities before deciding'**
  String get planNextActionCitiesTitle;

  /// No description provided for @planNextActionCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Check whether the suggested city still makes sense when compared through cost, language, safety, and work.'**
  String get planNextActionCitiesBody;

  /// No description provided for @planNextActionRetakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rebuild the plan with a different priority'**
  String get planNextActionRetakeTitle;

  /// No description provided for @planNextActionRetakeBody.
  ///
  /// In en, this message translates to:
  /// **'If your priority changed, it is worth answering again and seeing whether the order of steps changes too.'**
  String get planNextActionRetakeBody;

  /// No description provided for @readinessSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'A practical checklist for the next phase'**
  String get readinessSectionTitle;

  /// No description provided for @readinessStageNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get readinessStageNow;

  /// No description provided for @readinessStageSoon.
  ///
  /// In en, this message translates to:
  /// **'Prepare next'**
  String get readinessStageSoon;

  /// No description provided for @readinessStageLanding.
  ///
  /// In en, this message translates to:
  /// **'Before landing'**
  String get readinessStageLanding;

  /// No description provided for @readinessSummaryResearching.
  ///
  /// In en, this message translates to:
  /// **'You are still exploring, so the best move is to reduce uncertainty before opening too many fronts.'**
  String get readinessSummaryResearching;

  /// No description provided for @readinessSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'You still have room to prepare well, so use this checklist to remove friction before the move gets close.'**
  String get readinessSummaryTwelveMonths;

  /// No description provided for @readinessSummarySixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six months is enough time to stop improvising and start structuring documents, money, and city choice.'**
  String get readinessSummarySixMonths;

  /// No description provided for @readinessSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'Since your plan is close, the priority now is sequencing the essentials and avoiding avoidable mistakes.'**
  String get readinessSummaryAsap;

  /// No description provided for @readinessItemMigrationPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the migration path first'**
  String get readinessItemMigrationPathTitle;

  /// No description provided for @readinessItemMigrationPathBody.
  ///
  /// In en, this message translates to:
  /// **'Before banking, housing, or work, validate the residency route that best matches your move to Brazil.'**
  String get readinessItemMigrationPathBody;

  /// No description provided for @readinessItemDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the core document pack'**
  String get readinessItemDocumentsTitle;

  /// No description provided for @readinessItemDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'Separate your passport, criminal records, apostille needs, and any documents that may still require translation.'**
  String get readinessItemDocumentsBody;

  /// No description provided for @readinessItemBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress-test your landing budget'**
  String get readinessItemBudgetTitle;

  /// No description provided for @readinessItemBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Estimate what the first 30 to 90 days will demand, not just the monthly living cost after you are settled.'**
  String get readinessItemBudgetBody;

  /// No description provided for @readinessItemCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn city choice into a real filter'**
  String get readinessItemCityTitle;

  /// No description provided for @readinessItemCityBody.
  ///
  /// In en, this message translates to:
  /// **'Use your current city shortlist to reduce housing, transport, and daily-life uncertainty before comparing neighborhoods.'**
  String get readinessItemCityBody;

  /// No description provided for @readinessItemCityBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Use {city} as your first filter and compare it with alternatives before moving into neighborhood-level decisions.'**
  String readinessItemCityBodyWithCity(String city);

  /// No description provided for @readinessItemLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare your first language layer'**
  String get readinessItemLanguageTitle;

  /// No description provided for @readinessItemLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Focus on the Portuguese needed for everyday friction points like housing, transport, banking, and services.'**
  String get readinessItemLanguageBody;

  /// No description provided for @readinessItemLanguageWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Focus on the Portuguese that will affect interviews, work routines, negotiations, and basic service requests.'**
  String get readinessItemLanguageWorkBody;

  /// No description provided for @readinessItemLanguageStudyBody.
  ///
  /// In en, this message translates to:
  /// **'Focus on the Portuguese needed for classes, enrollment, daily errands, and institutional communication.'**
  String get readinessItemLanguageStudyBody;

  /// No description provided for @readinessGoalWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Map employability before arriving'**
  String get readinessGoalWorkTitle;

  /// No description provided for @readinessGoalWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Review what kind of work you can pursue early, what documents may block you, and how the city affects your chances.'**
  String get readinessGoalWorkBody;

  /// No description provided for @readinessGoalRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Stabilize remote work conditions'**
  String get readinessGoalRemoteTitle;

  /// No description provided for @readinessGoalRemoteBody.
  ///
  /// In en, this message translates to:
  /// **'Check internet quality, banking flow, daily costs, and the minimum local setup you need before relying on remote income.'**
  String get readinessGoalRemoteBody;

  /// No description provided for @readinessGoalStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate the study route'**
  String get readinessGoalStudyTitle;

  /// No description provided for @readinessGoalStudyBody.
  ///
  /// In en, this message translates to:
  /// **'Review admissions, routine costs, student timing, and what needs to be regularized before relying on study as your base.'**
  String get readinessGoalStudyBody;

  /// No description provided for @readinessGoalEntrepreneurTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the business entry path'**
  String get readinessGoalEntrepreneurTitle;

  /// No description provided for @readinessGoalEntrepreneurBody.
  ///
  /// In en, this message translates to:
  /// **'Map the practical first layer: local documents, banking, city fit, and the minimum structure to start operating safely.'**
  String get readinessGoalEntrepreneurBody;

  /// No description provided for @readinessGoalRetireTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect routine and predictability'**
  String get readinessGoalRetireTitle;

  /// No description provided for @readinessGoalRetireBody.
  ///
  /// In en, this message translates to:
  /// **'Prioritize health access, neighborhood routine, recurring costs, and the paperwork that supports a calm arrival.'**
  String get readinessGoalRetireBody;

  /// No description provided for @readinessGoalQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn quality of life into criteria'**
  String get readinessGoalQualityTitle;

  /// No description provided for @readinessGoalQualityBody.
  ///
  /// In en, this message translates to:
  /// **'Convert lifestyle into real filters: safety, daily routine, language adaptation, and the cost of staying longer term.'**
  String get readinessGoalQualityBody;

  /// No description provided for @readinessItemCpfBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare CPF and first banking steps'**
  String get readinessItemCpfBankTitle;

  /// No description provided for @readinessItemCpfBankBody.
  ///
  /// In en, this message translates to:
  /// **'CPF and regular status affect banking, contracts, and day-to-day setup. Treat them as part of the same arrival layer.'**
  String get readinessItemCpfBankBody;

  /// No description provided for @readinessItemHousingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce housing friction before searching'**
  String get readinessItemHousingTitle;

  /// No description provided for @readinessItemHousingBody.
  ///
  /// In en, this message translates to:
  /// **'Review rent guarantees, cash reserve, neighborhood priorities, and what proof you may need before contacting landlords.'**
  String get readinessItemHousingBody;

  /// No description provided for @readinessItemArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a 30-day arrival plan'**
  String get readinessItemArrivalTitle;

  /// No description provided for @readinessItemArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'List what must work in the first month: connectivity, health access, transport, routine payments, and document follow-up.'**
  String get readinessItemArrivalBody;

  /// No description provided for @readinessProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} items completed'**
  String readinessProgressLabel(int done, int total);

  /// No description provided for @planStepMeta.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}  Estimated days: {days}'**
  String planStepMeta(String category, int days);

  /// No description provided for @planStepOpenDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get planStepOpenDetailsAction;

  /// No description provided for @planStepOpenVisaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Residence and visa'**
  String get planStepOpenVisaEyebrow;

  /// No description provided for @planStepOpenVisaSummary.
  ///
  /// In en, this message translates to:
  /// **'Before deciding on banking, work, or housing, it helps to confirm the right migration path for entering and staying regularly.'**
  String get planStepOpenVisaSummary;

  /// No description provided for @planStepOpenVisaPointOne.
  ///
  /// In en, this message translates to:
  /// **'For an Argentinian user, residence under the Mercosur Agreement is often one of the most direct paths.'**
  String get planStepOpenVisaPointOne;

  /// No description provided for @planStepOpenVisaPointTwo.
  ///
  /// In en, this message translates to:
  /// **'A visitor visa is not meant for living in Brazil or for paid work.'**
  String get planStepOpenVisaPointTwo;

  /// No description provided for @planStepOpenVisaPointThree.
  ///
  /// In en, this message translates to:
  /// **'If your goal is already to live in Brazil, it is better to solve this before taking on rent or work.'**
  String get planStepOpenVisaPointThree;

  /// No description provided for @planStepOpenCpfEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Tax document'**
  String get planStepOpenCpfEyebrow;

  /// No description provided for @planStepOpenCpfSummary.
  ///
  /// In en, this message translates to:
  /// **'CPF helps unlock banking, contracts, registrations, and much of daily life early on.'**
  String get planStepOpenCpfSummary;

  /// No description provided for @planStepOpenCpfPointOne.
  ///
  /// In en, this message translates to:
  /// **'The process can start online, according to the official guidance.'**
  String get planStepOpenCpfPointOne;

  /// No description provided for @planStepOpenCpfPointTwo.
  ///
  /// In en, this message translates to:
  /// **'The officially stated time can reach up to 30 calendar days.'**
  String get planStepOpenCpfPointTwo;

  /// No description provided for @planStepOpenCpfPointThree.
  ///
  /// In en, this message translates to:
  /// **'CPF helps a lot, but it does not replace a regular migration document.'**
  String get planStepOpenCpfPointThree;

  /// No description provided for @planStepOpenBankEyebrow.
  ///
  /// In en, this message translates to:
  /// **'First account'**
  String get planStepOpenBankEyebrow;

  /// No description provided for @planStepOpenBankSummary.
  ///
  /// In en, this message translates to:
  /// **'Opening an account depends more on your regular status and documents than on one specific bank.'**
  String get planStepOpenBankSummary;

  /// No description provided for @planStepOpenBankPointOne.
  ///
  /// In en, this message translates to:
  /// **'There are traditional and digital banks, but document requirements may vary.'**
  String get planStepOpenBankPointOne;

  /// No description provided for @planStepOpenBankPointTwo.
  ///
  /// In en, this message translates to:
  /// **'CPF helps, but CRNM, a protocol receipt, or another regular document can influence approval.'**
  String get planStepOpenBankPointTwo;

  /// No description provided for @planStepOpenBankPointThree.
  ///
  /// In en, this message translates to:
  /// **'Start by comparing a digital account for simple day-to-day use and a traditional bank if you need in-person support.'**
  String get planStepOpenBankPointThree;

  /// No description provided for @planStepOpenHousingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Housing and neighborhoods'**
  String get planStepOpenHousingEyebrow;

  /// No description provided for @planStepOpenHousingSummary.
  ///
  /// In en, this message translates to:
  /// **'Before closing a housing deal, compare neighborhoods with better daily routine, access, and cost.'**
  String get planStepOpenHousingSummary;

  /// No description provided for @planStepOpenHousingSummaryCity.
  ///
  /// In en, this message translates to:
  /// **'For {city}, compare neighborhoods with better daily routine, access, and cost before closing a housing deal.'**
  String planStepOpenHousingSummaryCity(String city);

  /// No description provided for @planStepOpenHousingPointOne.
  ///
  /// In en, this message translates to:
  /// **'Prioritize neighborhoods that connect well to what you need: work, transport, and services.'**
  String get planStepOpenHousingPointOne;

  /// No description provided for @planStepOpenHousingPointTwo.
  ///
  /// In en, this message translates to:
  /// **'Use the city cost reading as a starting point, but confirm rent and contract details before deciding.'**
  String get planStepOpenHousingPointTwo;

  /// No description provided for @planStepOpenHousingPointThree.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood-level analysis still needs a dedicated data layer; for now, use the recommended city as your first filter.'**
  String get planStepOpenHousingPointThree;

  /// No description provided for @planStepOpenGeneralEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Guided checklist'**
  String get planStepOpenGeneralEyebrow;

  /// No description provided for @planStepOpenGeneralSummary.
  ///
  /// In en, this message translates to:
  /// **'This step works best as a practical validation within your move preparation.'**
  String get planStepOpenGeneralSummary;

  /// No description provided for @planStepOpenGeneralPointOne.
  ///
  /// In en, this message translates to:
  /// **'Solve the essentials first so you do not open too many fronts at the same time.'**
  String get planStepOpenGeneralPointOne;

  /// No description provided for @planStepOpenGeneralPointTwo.
  ///
  /// In en, this message translates to:
  /// **'When a step depends on an official document, confirm the latest requirement before submitting anything.'**
  String get planStepOpenGeneralPointTwo;

  /// No description provided for @planStepOpenGeneralPointThree.
  ///
  /// In en, this message translates to:
  /// **'Use the plan as a suggested order, not as a rigid rule for every case.'**
  String get planStepOpenGeneralPointThree;

  /// No description provided for @planStepOpenTagMercosur.
  ///
  /// In en, this message translates to:
  /// **'Mercosur'**
  String get planStepOpenTagMercosur;

  /// No description provided for @planStepOpenTagVisitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor stay is not work authorization'**
  String get planStepOpenTagVisitor;

  /// No description provided for @planStepOpenTagOnline.
  ///
  /// In en, this message translates to:
  /// **'Online request'**
  String get planStepOpenTagOnline;

  /// No description provided for @planStepOpenTagReceitaFederal.
  ///
  /// In en, this message translates to:
  /// **'Receita Federal'**
  String get planStepOpenTagReceitaFederal;

  /// No description provided for @planStepOpenTagTraditionalBanks.
  ///
  /// In en, this message translates to:
  /// **'Traditional banks'**
  String get planStepOpenTagTraditionalBanks;

  /// No description provided for @planStepOpenTagDigitalBanks.
  ///
  /// In en, this message translates to:
  /// **'Digital banks'**
  String get planStepOpenTagDigitalBanks;

  /// No description provided for @planStepOpenTagNeighborhoods.
  ///
  /// In en, this message translates to:
  /// **'Neighborhoods'**
  String get planStepOpenTagNeighborhoods;

  /// No description provided for @planStepOpenTagRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get planStepOpenTagRent;

  /// No description provided for @planStepOpenTagChecklist.
  ///
  /// In en, this message translates to:
  /// **'Step by step'**
  String get planStepOpenTagChecklist;

  /// No description provided for @savePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get savePlanAction;

  /// No description provided for @savePlanPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get savePlanPageTitle;

  /// No description provided for @savePlanSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan saved for now'**
  String get savePlanSuccessTitle;

  /// No description provided for @savePlanSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Temporarily saved plans in this session: {count}'**
  String savePlanSuccessBody(int count);

  /// No description provided for @goToProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Go to my space'**
  String get goToProfileAction;

  /// No description provided for @citiesExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get citiesExploreTitle;

  /// No description provided for @citiesExploreHeadline.
  ///
  /// In en, this message translates to:
  /// **'Discover cities with more context'**
  String get citiesExploreHeadline;

  /// No description provided for @citiesExploreDescription.
  ///
  /// In en, this message translates to:
  /// **'See suggestions by intention and understand why each city appears here.'**
  String get citiesExploreDescription;

  /// No description provided for @citiesExploreSearchFirstDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or use the chips to filter the catalog when it makes sense. The list does not open preloaded: results appear only after you search or pick a slice.'**
  String get citiesExploreSearchFirstDescription;

  /// No description provided for @citiesGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get citiesGuideEyebrow;

  /// No description provided for @citiesGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use city discovery'**
  String get citiesGuideTitle;

  /// No description provided for @citiesGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Here you can search by name, filter the catalog with quick slices, or open the map to choose by location.'**
  String get citiesGuideBody;

  /// No description provided for @citiesGuideStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Search a city'**
  String get citiesGuideStepOneTitle;

  /// No description provided for @citiesGuideStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'Type the name and tap the closest result to open the detail.'**
  String get citiesGuideStepOneBody;

  /// No description provided for @citiesGuideStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Use a quick slice'**
  String get citiesGuideStepTwoTitle;

  /// No description provided for @citiesGuideStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'The chips narrow the list by popularity, cost, work, language, and other signals.'**
  String get citiesGuideStepTwoBody;

  /// No description provided for @citiesGuideStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose on the map'**
  String get citiesGuideStepThreeTitle;

  /// No description provided for @citiesGuideStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Open the map, tap a city, and continue to the detail when you want to decide by location.'**
  String get citiesGuideStepThreeBody;

  /// No description provided for @citiesGuideHideNextTime.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get citiesGuideHideNextTime;

  /// No description provided for @citiesGuideStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 steps'**
  String get citiesGuideStepsLabel;

  /// No description provided for @citiesGuideDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get citiesGuideDismissAction;

  /// No description provided for @citiesGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get citiesGuidePrimaryAction;

  /// No description provided for @citiesExploreSearchIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or choose a filter'**
  String get citiesExploreSearchIdleTitle;

  /// No description provided for @citiesExploreSearchIdleDescription.
  ///
  /// In en, this message translates to:
  /// **'Type a city name for immediate autocomplete or swipe the chips to explore by popularity, beach, work, language, and arrival profile.'**
  String get citiesExploreSearchIdleDescription;

  /// No description provided for @citiesLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading cities'**
  String get citiesLoadingLabel;

  /// No description provided for @citiesMethodologyNote.
  ///
  /// In en, this message translates to:
  /// **'Rankings based on public data and the Movaro methodology.'**
  String get citiesMethodologyNote;

  /// No description provided for @citiesExplorePopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Most chosen by Argentinians'**
  String get citiesExplorePopularTitle;

  /// No description provided for @citiesExploreLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Easier for people who still rely on Spanish'**
  String get citiesExploreLanguageTitle;

  /// No description provided for @citiesExploreEconomicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Good options if cost matters more'**
  String get citiesExploreEconomicalTitle;

  /// No description provided for @citiesExploreWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Good options if you are looking for work'**
  String get citiesExploreWorkTitle;

  /// No description provided for @citiesExploreHousingEasyTitle.
  ///
  /// In en, this message translates to:
  /// **'Best for a lighter landing'**
  String get citiesExploreHousingEasyTitle;

  /// No description provided for @citiesExploreHousingPressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Need more cash upfront'**
  String get citiesExploreHousingPressureTitle;

  /// No description provided for @citiesExploreSoftLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Best for a lower-friction landing'**
  String get citiesExploreSoftLandingTitle;

  /// No description provided for @citiesExploreFamilyStabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Best for a more predictable arrival'**
  String get citiesExploreFamilyStabilityTitle;

  /// No description provided for @citiesExploreIncomeStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Best if you need income early'**
  String get citiesExploreIncomeStartTitle;

  /// No description provided for @citiesExploreCoastalTitle.
  ///
  /// In en, this message translates to:
  /// **'Best if you want to live near the beach'**
  String get citiesExploreCoastalTitle;

  /// No description provided for @citiesExploreCoastalSoftLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Beach cities with a lighter landing'**
  String get citiesExploreCoastalSoftLandingTitle;

  /// No description provided for @citiesExploreCoastalBalancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Beach cities with a better routine balance'**
  String get citiesExploreCoastalBalancedTitle;

  /// No description provided for @citiesHighlightPopularLabel.
  ///
  /// In en, this message translates to:
  /// **'Among the cities analyzed by Movaro'**
  String get citiesHighlightPopularLabel;

  /// No description provided for @citiesHighlightLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'A good option if language adaptation matters to you'**
  String get citiesHighlightLanguageLabel;

  /// No description provided for @citiesHighlightEconomicalLabel.
  ///
  /// In en, this message translates to:
  /// **'A good option if you prioritize cost'**
  String get citiesHighlightEconomicalLabel;

  /// No description provided for @citiesHighlightWorkLabel.
  ///
  /// In en, this message translates to:
  /// **'A good option if you want more work opportunities'**
  String get citiesHighlightWorkLabel;

  /// No description provided for @citiesHighlightHousingEasyLabel.
  ///
  /// In en, this message translates to:
  /// **'Good for soft landing'**
  String get citiesHighlightHousingEasyLabel;

  /// No description provided for @citiesHighlightHousingPressureLabel.
  ///
  /// In en, this message translates to:
  /// **'High housing pressure'**
  String get citiesHighlightHousingPressureLabel;

  /// No description provided for @citiesHighlightSoftLandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Good for a softer start with less friction'**
  String get citiesHighlightSoftLandingLabel;

  /// No description provided for @citiesHighlightFamilyStabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Good for balancing safety, housing, and routine'**
  String get citiesHighlightFamilyStabilityLabel;

  /// No description provided for @citiesHighlightIncomeStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you need to activate income sooner'**
  String get citiesHighlightIncomeStartLabel;

  /// No description provided for @citiesHighlightCoastalLabel.
  ///
  /// In en, this message translates to:
  /// **'Good for a coastal routine'**
  String get citiesHighlightCoastalLabel;

  /// No description provided for @citiesHighlightMetropolisLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you want a more urban pace'**
  String get citiesHighlightMetropolisLabel;

  /// No description provided for @citiesHighlightInlandLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you want a calmer routine'**
  String get citiesHighlightInlandLabel;

  /// No description provided for @citiesHighlightBorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you want a border-city lens'**
  String get citiesHighlightBorderLabel;

  /// No description provided for @citiesHighlightCoastalSoftLandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Beach with a softer landing'**
  String get citiesHighlightCoastalSoftLandingLabel;

  /// No description provided for @citiesHighlightCoastalBalancedLabel.
  ///
  /// In en, this message translates to:
  /// **'Beach with a better balance between routine and cost'**
  String get citiesHighlightCoastalBalancedLabel;

  /// No description provided for @citiesExploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'We are still expanding this catalog'**
  String get citiesExploreEmptyTitle;

  /// No description provided for @citiesExploreEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'City suggestions will appear here as the Movaro catalog grows.'**
  String get citiesExploreEmptyDescription;

  /// No description provided for @citiesSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search cities'**
  String get citiesSearchTitle;

  /// No description provided for @citiesSearchHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find a city in the initial catalog'**
  String get citiesSearchHeadline;

  /// No description provided for @citiesSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by name or browse the current Movaro list.'**
  String get citiesSearchDescription;

  /// No description provided for @citiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get citiesSearchHint;

  /// No description provided for @citiesSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get citiesSearchFieldLabel;

  /// No description provided for @citiesSearchHelper.
  ///
  /// In en, this message translates to:
  /// **'Type to search cities by name and tap autocomplete.'**
  String get citiesSearchHelper;

  /// No description provided for @citiesQuickChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick choices'**
  String get citiesQuickChoicesTitle;

  /// No description provided for @citiesQuickChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Use a slice to narrow the list faster or go by map if location is your starting point.'**
  String get citiesQuickChoicesBody;

  /// No description provided for @citiesSearchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cities found'**
  String citiesSearchResultsCount(int count);

  /// No description provided for @citiesSearchResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a city to open the detail directly.'**
  String get citiesSearchResultsHint;

  /// No description provided for @citiesMapOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get citiesMapOpenAction;

  /// No description provided for @citiesMapCalloutBody.
  ///
  /// In en, this message translates to:
  /// **'Prefer to decide by location? Open the map and compare cities by the place where you want to start.'**
  String get citiesMapCalloutBody;

  /// No description provided for @citiesMapCalloutStepOne.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get citiesMapCalloutStepOne;

  /// No description provided for @citiesMapCalloutStepTwo.
  ///
  /// In en, this message translates to:
  /// **'Tap city'**
  String get citiesMapCalloutStepTwo;

  /// No description provided for @citiesMapCalloutStepThree.
  ///
  /// In en, this message translates to:
  /// **'Open detail'**
  String get citiesMapCalloutStepThree;

  /// No description provided for @citiesMapSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city on the map'**
  String get citiesMapSheetTitle;

  /// No description provided for @citiesMapSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Open the Brazil map, tap a point, and select the city by its position.'**
  String get citiesMapSheetBody;

  /// No description provided for @citiesMapOpenCityAction.
  ///
  /// In en, this message translates to:
  /// **'Open city'**
  String get citiesMapOpenCityAction;

  /// No description provided for @citiesQuickFilterAll.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get citiesQuickFilterAll;

  /// No description provided for @citiesQuickFilterPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get citiesQuickFilterPopular;

  /// No description provided for @citiesQuickFilterLowCost.
  ///
  /// In en, this message translates to:
  /// **'Better cost'**
  String get citiesQuickFilterLowCost;

  /// No description provided for @citiesQuickFilterWork.
  ///
  /// In en, this message translates to:
  /// **'More jobs'**
  String get citiesQuickFilterWork;

  /// No description provided for @citiesQuickFilterLanguage.
  ///
  /// In en, this message translates to:
  /// **'Easier language'**
  String get citiesQuickFilterLanguage;

  /// No description provided for @citiesQuickFilterHousingEasy.
  ///
  /// In en, this message translates to:
  /// **'Lighter landing'**
  String get citiesQuickFilterHousingEasy;

  /// No description provided for @citiesQuickFilterHousingPressure.
  ///
  /// In en, this message translates to:
  /// **'More cash'**
  String get citiesQuickFilterHousingPressure;

  /// No description provided for @citiesQuickFilterSoftLanding.
  ///
  /// In en, this message translates to:
  /// **'Less friction'**
  String get citiesQuickFilterSoftLanding;

  /// No description provided for @citiesQuickFilterFamilyStability.
  ///
  /// In en, this message translates to:
  /// **'More predictable'**
  String get citiesQuickFilterFamilyStability;

  /// No description provided for @citiesQuickFilterIncomeStart.
  ///
  /// In en, this message translates to:
  /// **'Early income'**
  String get citiesQuickFilterIncomeStart;

  /// No description provided for @citiesQuickFilterCoastal.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get citiesQuickFilterCoastal;

  /// No description provided for @citiesSearchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Searching cities'**
  String get citiesSearchingLabel;

  /// No description provided for @citiesCatalogLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading catalog'**
  String get citiesCatalogLoadingLabel;

  /// No description provided for @citiesFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get citiesFilterClear;

  /// No description provided for @citiesResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get citiesResultsTitle;

  /// No description provided for @citiesResultsBody.
  ///
  /// In en, this message translates to:
  /// **'{count} cities match this search or filter.'**
  String citiesResultsBody(int count);

  /// No description provided for @citiesResultsMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more cities'**
  String get citiesResultsMoreHint;

  /// No description provided for @citiesSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No city found'**
  String get citiesSearchEmptyTitle;

  /// No description provided for @citiesSearchEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try another name or explore the initial Movaro catalog.'**
  String get citiesSearchEmptyDescription;

  /// No description provided for @citiesSearchFirstEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try another name or change the filter to widen results.'**
  String get citiesSearchFirstEmptyDescription;

  /// No description provided for @citiesCatalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog still empty'**
  String get citiesCatalogEmptyTitle;

  /// No description provided for @citiesCatalogEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Cities from the Movaro catalog will appear here.'**
  String get citiesCatalogEmptyDescription;

  /// No description provided for @cityDetailTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityDetailTitleFallback;

  /// No description provided for @cityDetailLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading city details'**
  String get cityDetailLoadingLabel;

  /// No description provided for @cityDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'City unavailable'**
  String get cityDetailEmptyTitle;

  /// No description provided for @cityDetailEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'We could not find details for this city right now.'**
  String get cityDetailEmptyDescription;

  /// No description provided for @cityDetailContextNote.
  ///
  /// In en, this message translates to:
  /// **'Use these indicators as a starting point, not as absolute truth.'**
  String get cityDetailContextNote;

  /// No description provided for @cityDetailDecisionSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision snapshot'**
  String get cityDetailDecisionSnapshotTitle;

  /// No description provided for @cityDetailDecisionSnapshotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Movaro sees this city as a strong option if you are prioritizing {bestFor}.'**
  String cityDetailDecisionSnapshotSubtitle(Object bestFor);

  /// No description provided for @cityDetailDecisionSnapshotPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your plan, this city stands out if you are prioritizing {bestFor}.'**
  String cityDetailDecisionSnapshotPlanSubtitle(Object bestFor);

  /// No description provided for @cityDetailDecisionSnapshotRecommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This city is currently leading in your plan if your focus is {bestFor}.'**
  String cityDetailDecisionSnapshotRecommendedSubtitle(Object bestFor);

  /// No description provided for @cityDetailWatchoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Main point to validate'**
  String get cityDetailWatchoutTitle;

  /// No description provided for @cityDetailPlanLeadingChip.
  ///
  /// In en, this message translates to:
  /// **'Leading in your plan'**
  String get cityDetailPlanLeadingChip;

  /// No description provided for @cityDetailPlanMatchChip.
  ///
  /// In en, this message translates to:
  /// **'Fits your plan'**
  String get cityDetailPlanMatchChip;

  /// No description provided for @cityDetailUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated on {date}'**
  String cityDetailUpdatedLabel(Object date);

  /// No description provided for @cityDetailAffordabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Cost and housing'**
  String get cityDetailAffordabilityTitle;

  /// No description provided for @cityDetailSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick summary'**
  String get cityDetailSummaryTitle;

  /// No description provided for @cityDetailSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Use this top read to understand whether the city looks easier, more balanced, or more demanding before opening the deeper analysis.'**
  String get cityDetailSummaryBody;

  /// No description provided for @cityDetailAddToPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Add to my plan'**
  String get cityDetailAddToPlanAction;

  /// No description provided for @cityDetailCompareSavedAction.
  ///
  /// In en, this message translates to:
  /// **'Saved to compare'**
  String get cityDetailCompareSavedAction;

  /// No description provided for @cityDetailQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality of life'**
  String get cityDetailQualityLabel;

  /// No description provided for @cityDetailQualitySupporting.
  ///
  /// In en, this message translates to:
  /// **'A quick read based on HDI, safety, and language adaptation for arrival.'**
  String get cityDetailQualitySupporting;

  /// No description provided for @cityDetailQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'Stronger'**
  String get cityDetailQualityHigh;

  /// No description provided for @cityDetailQualityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get cityDetailQualityBalanced;

  /// No description provided for @cityDetailQualityDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Needs validation'**
  String get cityDetailQualityDeveloping;

  /// No description provided for @cityDetailDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get cityDetailDifficultyLabel;

  /// No description provided for @cityDetailDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Lighter move'**
  String get cityDetailDifficultyEasy;

  /// No description provided for @cityDetailDifficultyBalanced.
  ///
  /// In en, this message translates to:
  /// **'Moderate move'**
  String get cityDetailDifficultyBalanced;

  /// No description provided for @cityDetailDifficultyChallenging.
  ///
  /// In en, this message translates to:
  /// **'More demanding move'**
  String get cityDetailDifficultyChallenging;

  /// No description provided for @cityDetailSettleInTitle.
  ///
  /// In en, this message translates to:
  /// **'Adaptation and community'**
  String get cityDetailSettleInTitle;

  /// No description provided for @cityDetailCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Support network'**
  String get cityDetailCommunityTitle;

  /// No description provided for @cityDetailContextTitle.
  ///
  /// In en, this message translates to:
  /// **'City context'**
  String get cityDetailContextTitle;

  /// No description provided for @cityLifestyleCoastalLabel.
  ///
  /// In en, this message translates to:
  /// **'Coastal lifestyle'**
  String get cityLifestyleCoastalLabel;

  /// No description provided for @cityLifestyleMetropolisLabel.
  ///
  /// In en, this message translates to:
  /// **'Metropolitan pace'**
  String get cityLifestyleMetropolisLabel;

  /// No description provided for @cityLifestyleBorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Border city'**
  String get cityLifestyleBorderLabel;

  /// No description provided for @cityLifestyleInlandLabel.
  ///
  /// In en, this message translates to:
  /// **'Inland routine'**
  String get cityLifestyleInlandLabel;

  /// No description provided for @cityDetailMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Where the city is'**
  String get cityDetailMapTitle;

  /// No description provided for @cityDetailMapDescription.
  ///
  /// In en, this message translates to:
  /// **'See the city on the map before comparing context, distance, and region.'**
  String get cityDetailMapDescription;

  /// No description provided for @cityDetailMapRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get cityDetailMapRegionLabel;

  /// No description provided for @cityDetailMapDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance from {origin}: ~{distanceKm} km'**
  String cityDetailMapDistanceLabel(Object origin, Object distanceKm);

  /// No description provided for @cityDetailSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick view'**
  String get cityDetailSnapshotTitle;

  /// No description provided for @cityDetailSnapshotPositiveTag.
  ///
  /// In en, this message translates to:
  /// **'Strong point'**
  String get cityDetailSnapshotPositiveTag;

  /// No description provided for @cityDetailSnapshotWatchoutTag.
  ///
  /// In en, this message translates to:
  /// **'Watch out'**
  String get cityDetailSnapshotWatchoutTag;

  /// No description provided for @cityDetailSnapshotContextTag.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get cityDetailSnapshotContextTag;

  /// No description provided for @cityDetailMetricsSummary.
  ///
  /// In en, this message translates to:
  /// **'Open only if you want to review every indicator and the full data slice.'**
  String get cityDetailMetricsSummary;

  /// No description provided for @cityDetailPopulationLabel.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get cityDetailPopulationLabel;

  /// No description provided for @cityDetailCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cityDetailCostLabel;

  /// No description provided for @cityDetailRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get cityDetailRentLabel;

  /// No description provided for @cityDetailSafetyLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get cityDetailSafetyLabel;

  /// No description provided for @cityDetailPopularityLabel.
  ///
  /// In en, this message translates to:
  /// **'Popularity among Argentinians'**
  String get cityDetailPopularityLabel;

  /// No description provided for @cityDetailLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language adaptation'**
  String get cityDetailLanguageLabel;

  /// No description provided for @cityDetailWorkLabel.
  ///
  /// In en, this message translates to:
  /// **'Job market'**
  String get cityDetailWorkLabel;

  /// No description provided for @cityDetailIdhmLabel.
  ///
  /// In en, this message translates to:
  /// **'HDI'**
  String get cityDetailIdhmLabel;

  /// No description provided for @cityDetailIdhmOfficialNote.
  ///
  /// In en, this message translates to:
  /// **'official Atlas of Human Development data'**
  String get cityDetailIdhmOfficialNote;

  /// No description provided for @cityDetailUnemploymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Unemployment rate'**
  String get cityDetailUnemploymentLabel;

  /// No description provided for @cityDetailIndustriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Strong industries'**
  String get cityDetailIndustriesTitle;

  /// No description provided for @cityDetailReasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Movaro recommends it'**
  String get cityDetailReasonsTitle;

  /// No description provided for @cityDetailSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get cityDetailSourcesTitle;

  /// No description provided for @cityDetailSourcesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} sources available. Expand only if you want to validate the origin of the data.'**
  String cityDetailSourcesSummary(int count);

  /// No description provided for @cityDetailSourceOfficialBadge.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get cityDetailSourceOfficialBadge;

  /// No description provided for @cityDetailSourceCuratedBadge.
  ///
  /// In en, this message translates to:
  /// **'Curated source'**
  String get cityDetailSourceCuratedBadge;

  /// No description provided for @cityDetailSourceProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get cityDetailSourceProviderLabel;

  /// No description provided for @cityDetailSourceUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get cityDetailSourceUrlLabel;

  /// No description provided for @cityDetailPublicOpinionTitle.
  ///
  /// In en, this message translates to:
  /// **'What visitors tend to mention'**
  String get cityDetailPublicOpinionTitle;

  /// No description provided for @cityDetailPublicOpinionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A reading of recurring themes in public {provider} reviews. It does not represent the opinion of the whole city.'**
  String cityDetailPublicOpinionSubtitle(Object provider);

  /// No description provided for @cityDetailPublicOpinionRating.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating}'**
  String cityDetailPublicOpinionRating(Object rating);

  /// No description provided for @cityDetailPublicOpinionSample.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No reviews} =1 {1 review} other {{count} reviews}}'**
  String cityDetailPublicOpinionSample(int count);

  /// No description provided for @cityDetailPublicOpinionFallbackSummary.
  ///
  /// In en, this message translates to:
  /// **'These topics reflect themes that show up often in the public reviews found for this locality.'**
  String get cityDetailPublicOpinionFallbackSummary;

  /// No description provided for @cityDetailPublicOpinionPositiveTitle.
  ///
  /// In en, this message translates to:
  /// **'What people praise most'**
  String get cityDetailPublicOpinionPositiveTitle;

  /// No description provided for @cityDetailPublicOpinionCriticalTitle.
  ///
  /// In en, this message translates to:
  /// **'What people criticize most'**
  String get cityDetailPublicOpinionCriticalTitle;

  /// No description provided for @cityDetailPublicOpinionNote.
  ///
  /// In en, this message translates to:
  /// **'Automatic summary checked on {date}. Use it as a signal of recurring public perception, not as absolute consensus.'**
  String cityDetailPublicOpinionNote(Object date);

  /// No description provided for @citySourceTerritorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Territorial identity'**
  String get citySourceTerritorialTitle;

  /// No description provided for @citySourceTerritorialDescription.
  ///
  /// In en, this message translates to:
  /// **'Official name, state, IBGE code, and municipal region.'**
  String get citySourceTerritorialDescription;

  /// No description provided for @citySourcePopulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get citySourcePopulationTitle;

  /// No description provided for @citySourcePopulationDescription.
  ///
  /// In en, this message translates to:
  /// **'Official reference for city population.'**
  String get citySourcePopulationDescription;

  /// No description provided for @citySourceHumanDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Human development'**
  String get citySourceHumanDevelopmentTitle;

  /// No description provided for @citySourceHumanDevelopmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Official municipal HDI with a 2010 Census reference.'**
  String get citySourceHumanDevelopmentDescription;

  /// No description provided for @citySourceCuratedMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Curated product metrics'**
  String get citySourceCuratedMetricsTitle;

  /// No description provided for @citySourceCuratedMetricsDescription.
  ///
  /// In en, this message translates to:
  /// **'It currently comes from Movaro\'s curated dataset. The priority official replacements are Atlas da Violência (safety), Novo Caged (jobs), FipeZAP (rent), and IBGE PIB dos Municípios (economic activity).'**
  String get citySourceCuratedMetricsDescription;

  /// No description provided for @citySourceRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring methodology'**
  String get citySourceRankingTitle;

  /// No description provided for @citySourceRankingDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro scores calculated from public data and a curated dataset.'**
  String get citySourceRankingDescription;

  /// No description provided for @citySourcePublicReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Public perception of the locality'**
  String get citySourcePublicReviewsTitle;

  /// No description provided for @citySourcePublicReviewsDescription.
  ///
  /// In en, this message translates to:
  /// **'Recurring themes extracted from public Google reviews about the locality. It does not represent the opinion of the whole city.'**
  String get citySourcePublicReviewsDescription;

  /// No description provided for @cityDetailSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save city'**
  String get cityDetailSaveAction;

  /// No description provided for @cityDetailSavedAction.
  ///
  /// In en, this message translates to:
  /// **'City saved'**
  String get cityDetailSavedAction;

  /// No description provided for @cityDetailSavedFeedback.
  ///
  /// In en, this message translates to:
  /// **'City saved temporarily on this device.'**
  String get cityDetailSavedFeedback;

  /// No description provided for @cityDetailFavoriteAction.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get cityDetailFavoriteAction;

  /// No description provided for @cityDetailFavoriteRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get cityDetailFavoriteRemoveAction;

  /// No description provided for @cityDetailFavoriteNote.
  ///
  /// In en, this message translates to:
  /// **'You can keep up to 3 favorite cities to return to them quickly from home.'**
  String get cityDetailFavoriteNote;

  /// No description provided for @cityDetailFavoriteAddedFeedback.
  ///
  /// In en, this message translates to:
  /// **'{city} was added to favorites.'**
  String cityDetailFavoriteAddedFeedback(Object city);

  /// No description provided for @cityDetailFavoriteRemovedFeedback.
  ///
  /// In en, this message translates to:
  /// **'{city} was removed from favorites.'**
  String cityDetailFavoriteRemovedFeedback(Object city);

  /// No description provided for @cityDetailFavoriteLimitFeedback.
  ///
  /// In en, this message translates to:
  /// **'You can choose up to {count} favorite cities.'**
  String cityDetailFavoriteLimitFeedback(Object count);

  /// No description provided for @cityDetailDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Get to know the city better'**
  String get cityDetailDiscoverTitle;

  /// No description provided for @cityDetailDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'If you want photos, search results, and broader context for {city} ({state}), open the Google view without leaving the app.'**
  String cityDetailDiscoverBody(Object city, Object state);

  /// No description provided for @cityDetailDiscoverAction.
  ///
  /// In en, this message translates to:
  /// **'Explore the city'**
  String get cityDetailDiscoverAction;

  /// No description provided for @cityDetailDeepDiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis'**
  String get cityDetailDeepDiveTitle;

  /// No description provided for @cityDetailDeepDiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Open this area if you want the full set of indicators, context, and a deeper reading of the city.'**
  String get cityDetailDeepDiveSummary;

  /// No description provided for @cityDetailCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare other cities'**
  String get cityDetailCompareAction;

  /// No description provided for @cityDetailCompareSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'{city} pre-selected'**
  String cityDetailCompareSelectedBody(Object city);

  /// No description provided for @cityDetailPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get cityDetailPlanAction;

  /// No description provided for @cityDetailFooterNote.
  ///
  /// In en, this message translates to:
  /// **'These indicators help with initial exploration and do not replace individual analysis.'**
  String get cityDetailFooterNote;

  /// No description provided for @publicHomeFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorite cities'**
  String get publicHomeFavoritesTitle;

  /// No description provided for @publicHomeFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Keep up to 3 cities here so you can jump back into their details whenever you want.'**
  String get publicHomeFavoritesBody;

  /// No description provided for @publicHomeFavoritesJumpAction.
  ///
  /// In en, this message translates to:
  /// **'See favorite cities'**
  String get publicHomeFavoritesJumpAction;

  /// No description provided for @publicHomeFavoriteCardHint.
  ///
  /// In en, this message translates to:
  /// **'Open the city details to compare costs, work, and arrival fit again.'**
  String get publicHomeFavoriteCardHint;

  /// No description provided for @mainNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainNavHome;

  /// No description provided for @mainNavFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get mainNavFavorites;

  /// No description provided for @mainNavCopilot.
  ///
  /// In en, this message translates to:
  /// **'Move guide'**
  String get mainNavCopilot;

  /// No description provided for @mainNavExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get mainNavExplore;

  /// No description provided for @mainNavPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get mainNavPlan;

  /// No description provided for @mainNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get mainNavProfile;

  /// No description provided for @mainNavPlanNeedsJourney.
  ///
  /// In en, this message translates to:
  /// **'Choose your destination first so Movaro can open the right plan step.'**
  String get mainNavPlanNeedsJourney;

  /// No description provided for @mainNavFavoritesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 city to favorites to unlock this tab.'**
  String get mainNavFavoritesDisabled;

  /// No description provided for @mainNavCopilotDisabled.
  ///
  /// In en, this message translates to:
  /// **'Confirm a city in your plan to unlock the move guide.'**
  String get mainNavCopilotDisabled;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite cities yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you favorite cities, they stay here together so you can track details, weather, and comparison faster.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Explore cities, save the strongest ones, and come back here whenever you want to resume.'**
  String get favoritesEmptyHint;

  /// No description provided for @favoritesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved cities'**
  String get favoritesPageTitle;

  /// No description provided for @favoritesPageCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String favoritesPageCount(Object current, Object total);

  /// No description provided for @favoritesCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare cities'**
  String get favoritesCompareTitle;

  /// No description provided for @favoritesCompareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{left} vs {right}'**
  String favoritesCompareSubtitle(Object left, Object right);

  /// No description provided for @favoritesCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get favoritesCompareAction;

  /// No description provided for @favoritesPageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved cities'**
  String get favoritesPageEmptyTitle;

  /// No description provided for @favoritesPageEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Explore cities and save the ones that interest you most so you can compare them later.'**
  String get favoritesPageEmptyBody;

  /// No description provided for @favoritesAddCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Add city'**
  String get favoritesAddCityTitle;

  /// No description provided for @favoritesAddCitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} slot(s) available'**
  String favoritesAddCitySubtitle(Object count);

  /// No description provided for @favoritesActivePlanBadge.
  ///
  /// In en, this message translates to:
  /// **'Active plan'**
  String get favoritesActivePlanBadge;

  /// No description provided for @favoritesContinuePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Continue plan'**
  String get favoritesContinuePlanAction;

  /// No description provided for @favoritesOpenDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get favoritesOpenDetailsAction;

  /// No description provided for @favoritesRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get favoritesRemoveAction;

  /// No description provided for @favoritesClimateLabel.
  ///
  /// In en, this message translates to:
  /// **'Climate now'**
  String get favoritesClimateLabel;

  /// No description provided for @favoritesClimatePending.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get favoritesClimatePending;

  /// No description provided for @favoritesQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get favoritesQualityLabel;

  /// No description provided for @cityComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare cities'**
  String get cityComparisonTitle;

  /// No description provided for @cityComparisonCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get cityComparisonCompareAction;

  /// No description provided for @cityComparisonEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get cityComparisonEditAction;

  /// No description provided for @cityComparisonModeTwo.
  ///
  /// In en, this message translates to:
  /// **'2 cities'**
  String get cityComparisonModeTwo;

  /// No description provided for @cityComparisonModeThree.
  ///
  /// In en, this message translates to:
  /// **'3 cities'**
  String get cityComparisonModeThree;

  /// No description provided for @cityComparisonAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cityComparisonAddAction;

  /// No description provided for @cityComparisonSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search city to compare...'**
  String get cityComparisonSearchPlaceholder;

  /// No description provided for @cityComparisonHeaderLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get cityComparisonHeaderLabel;

  /// No description provided for @cityComparisonBestFitBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST FIT'**
  String get cityComparisonBestFitBadge;

  /// No description provided for @cityComparisonTopBadge.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get cityComparisonTopBadge;

  /// No description provided for @cityComparisonGroupCost.
  ///
  /// In en, this message translates to:
  /// **'Cost of living'**
  String get cityComparisonGroupCost;

  /// No description provided for @cityComparisonGroupQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality of life'**
  String get cityComparisonGroupQuality;

  /// No description provided for @cityComparisonGroupWork.
  ///
  /// In en, this message translates to:
  /// **'Work and arrival'**
  String get cityComparisonGroupWork;

  /// No description provided for @cityComparisonRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated rent'**
  String get cityComparisonRentLabel;

  /// No description provided for @cityComparisonFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly food cost'**
  String get cityComparisonFoodLabel;

  /// No description provided for @cityComparisonTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly transport cost'**
  String get cityComparisonTransportLabel;

  /// No description provided for @cityComparisonHdiLabel.
  ///
  /// In en, this message translates to:
  /// **'HDI'**
  String get cityComparisonHdiLabel;

  /// No description provided for @cityComparisonClimateLabel.
  ///
  /// In en, this message translates to:
  /// **'Current climate'**
  String get cityComparisonClimateLabel;

  /// No description provided for @cityComparisonSafetyLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety index'**
  String get cityComparisonSafetyLabel;

  /// No description provided for @cityComparisonJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Job market'**
  String get cityComparisonJobLabel;

  /// No description provided for @cityComparisonCommunityLabel.
  ///
  /// In en, this message translates to:
  /// **'Immigrant community'**
  String get cityComparisonCommunityLabel;

  /// No description provided for @cityComparisonCommunityLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get cityComparisonCommunityLarge;

  /// No description provided for @cityComparisonCommunityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cityComparisonCommunityMedium;

  /// No description provided for @cityComparisonCommunitySmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get cityComparisonCommunitySmall;

  /// No description provided for @cityComparisonWinnerLabel.
  ///
  /// In en, this message translates to:
  /// **'BEST CHOICE FOR YOU'**
  String get cityComparisonWinnerLabel;

  /// No description provided for @cityComparisonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get cityComparisonUnavailable;

  /// No description provided for @cityComparisonStartPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Start plan in {city} →'**
  String cityComparisonStartPlanAction(Object city);

  /// No description provided for @cityComparisonOtherDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'View details of {city}'**
  String cityComparisonOtherDetailsAction(Object city);

  /// No description provided for @favoritesExploreAction.
  ///
  /// In en, this message translates to:
  /// **'Explore cities'**
  String get favoritesExploreAction;

  /// No description provided for @favoritesGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get favoritesGuideEyebrow;

  /// No description provided for @favoritesGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use Favorites'**
  String get favoritesGuideTitle;

  /// No description provided for @favoritesGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Here you can keep up to 3 cities to revisit later without repeating your search. Use this area to compare better, reopen details, and decide with more clarity.'**
  String get favoritesGuideBody;

  /// No description provided for @favoritesGuideStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Save the most promising cities'**
  String get favoritesGuideStepOneTitle;

  /// No description provided for @favoritesGuideStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'Use the heart on cards or in the detail page to keep the cities that make sense for you.'**
  String get favoritesGuideStepOneBody;

  /// No description provided for @favoritesGuideStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Come back for quick comparison'**
  String get favoritesGuideStepTwoTitle;

  /// No description provided for @favoritesGuideStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Favorites keeps your picks in one place so you do not get lost between searches and filters.'**
  String get favoritesGuideStepTwoBody;

  /// No description provided for @favoritesGuideStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the detail when you want to decide'**
  String get favoritesGuideStepThreeTitle;

  /// No description provided for @favoritesGuideStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a city to review context, weather, cost, and the main signals before moving forward.'**
  String get favoritesGuideStepThreeBody;

  /// No description provided for @favoritesGuideHideNextTime.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get favoritesGuideHideNextTime;

  /// No description provided for @favoritesGuideStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 steps'**
  String get favoritesGuideStepsLabel;

  /// No description provided for @favoritesGuideDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get favoritesGuideDismissAction;

  /// No description provided for @favoritesGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get favoritesGuidePrimaryAction;

  /// No description provided for @profileJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get profileJourneyTitle;

  /// No description provided for @profileJourneyBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro uses this route to keep home, exploration, and content connected to the same move context.'**
  String get profileJourneyBody;

  /// No description provided for @profileJourneyValue.
  ///
  /// In en, this message translates to:
  /// **'{origin} -> {destination}'**
  String profileJourneyValue(Object origin, Object destination);

  /// No description provided for @profileJourneyPendingValue.
  ///
  /// In en, this message translates to:
  /// **'Destination saved: {destination}'**
  String profileJourneyPendingValue(Object destination);

  /// No description provided for @profileJourneyEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'No journey selected yet'**
  String get profileJourneyEmptyValue;

  /// No description provided for @profilePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan status'**
  String get profilePlanTitle;

  /// No description provided for @profilePlanBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved plan stays connected to the journey so you can continue without starting from zero.'**
  String get profilePlanBody;

  /// No description provided for @profilePlanEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'No plan generated yet'**
  String get profilePlanEmptyValue;

  /// No description provided for @profilePlanReadyValue.
  ///
  /// In en, this message translates to:
  /// **'Ready to continue in {city}'**
  String profilePlanReadyValue(Object city);

  /// No description provided for @profilePlanDraftValue.
  ///
  /// In en, this message translates to:
  /// **'Draft result waiting for confirmation'**
  String get profilePlanDraftValue;

  /// No description provided for @profileSavedCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved cities'**
  String get profileSavedCitiesTitle;

  /// No description provided for @profileSavedCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Keep up to 3 cities here so you can compare them again without losing your route or plan context.'**
  String get profileSavedCitiesBody;

  /// No description provided for @publicHomeJourneyResetAction.
  ///
  /// In en, this message translates to:
  /// **'Choose another route'**
  String get publicHomeJourneyResetAction;

  /// No description provided for @publicHomeJourneyResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose another route?'**
  String get publicHomeJourneyResetTitle;

  /// No description provided for @publicHomeJourneyResetBody.
  ///
  /// In en, this message translates to:
  /// **'Your current route is already saved on this device. If you restart it now, Movaro will open the route selection again so you can choose a different origin or destination.'**
  String get publicHomeJourneyResetBody;

  /// No description provided for @publicHomeJourneyResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Redo route'**
  String get publicHomeJourneyResetConfirm;

  /// No description provided for @publicHomePlanResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Start another plan?'**
  String get publicHomePlanResetTitle;

  /// No description provided for @publicHomePlanResetBody.
  ///
  /// In en, this message translates to:
  /// **'Your current plan will be removed from this device so you can answer the quick questions again from the beginning.'**
  String get publicHomePlanResetBody;

  /// No description provided for @cityWeatherSummary.
  ///
  /// In en, this message translates to:
  /// **'{temperature}°C now'**
  String cityWeatherSummary(Object temperature);

  /// No description provided for @introPageTitle.
  ///
  /// In en, this message translates to:
  /// **'How Movaro works'**
  String get introPageTitle;

  /// No description provided for @introHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand the app in under a minute'**
  String get introHeroTitle;

  /// No description provided for @introHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro helps you compare cities, understand practical bureaucracy, and build an initial direction for your move without starting from information overload.'**
  String get introHeroDescription;

  /// No description provided for @introExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore cities with context'**
  String get introExploreTitle;

  /// No description provided for @introExploreDescription.
  ///
  /// In en, this message translates to:
  /// **'Use cost, safety, language adaptation, and local signals to understand why a city appears as a strong option.'**
  String get introExploreDescription;

  /// No description provided for @introPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a first plan'**
  String get introPlanTitle;

  /// No description provided for @introPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and get a practical first direction for your next step.'**
  String get introPlanDescription;

  /// No description provided for @introDocumentationTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult documentation when needed'**
  String get introDocumentationTitle;

  /// No description provided for @introDocumentationDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the guide to understand CPF, registration, health, work, and approximate day-one costs.'**
  String get introDocumentationDescription;

  /// No description provided for @introBetaTitle.
  ///
  /// In en, this message translates to:
  /// **'What is available in this beta'**
  String get introBetaTitle;

  /// No description provided for @introBetaDescription.
  ///
  /// In en, this message translates to:
  /// **'This version focuses on clarity. You can explore cities, compare signals, and generate an initial plan before deeper account features arrive.'**
  String get introBetaDescription;

  /// No description provided for @introBottomSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get introBottomSupportLabel;

  /// No description provided for @introPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get introPrimaryAction;

  /// No description provided for @introSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get introSkipAction;

  /// No description provided for @cityPracticalAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick answers for common questions'**
  String get cityPracticalAnswersTitle;

  /// No description provided for @cityPracticalLanguageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would daily life feel easier if I still depend on Spanish?'**
  String get cityPracticalLanguageQuestion;

  /// No description provided for @cityPracticalCostQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does this city look manageable in day-to-day costs?'**
  String get cityPracticalCostQuestion;

  /// No description provided for @cityPracticalWorkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does it look like a strong place to start working?'**
  String get cityPracticalWorkQuestion;

  /// No description provided for @cityPracticalSafetyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does it look easier to adapt with more routine stability?'**
  String get cityPracticalSafetyQuestion;

  /// No description provided for @cityPracticalLanguageEasy.
  ///
  /// In en, this message translates to:
  /// **'It looks easier than average for a Spanish-speaking newcomer because the city combines stronger language adaptation and existing Argentine familiarity.'**
  String get cityPracticalLanguageEasy;

  /// No description provided for @cityPracticalLanguageMedium.
  ///
  /// In en, this message translates to:
  /// **'It looks manageable, but you would still benefit from basic Portuguese for daily routines.'**
  String get cityPracticalLanguageMedium;

  /// No description provided for @cityPracticalLanguageHard.
  ///
  /// In en, this message translates to:
  /// **'It may require faster Portuguese adaptation because Spanish support appears weaker in daily life.'**
  String get cityPracticalLanguageHard;

  /// No description provided for @cityPracticalCostEasy.
  ///
  /// In en, this message translates to:
  /// **'Its cost signal looks friendlier for an initial move compared with the rest of the catalog.'**
  String get cityPracticalCostEasy;

  /// No description provided for @cityPracticalCostMedium.
  ///
  /// In en, this message translates to:
  /// **'It looks balanced, but you should still validate rent and neighborhood choices carefully.'**
  String get cityPracticalCostMedium;

  /// No description provided for @cityPracticalCostHard.
  ///
  /// In en, this message translates to:
  /// **'It may feel heavier at the start, so budget and housing research matter more here.'**
  String get cityPracticalCostHard;

  /// No description provided for @cityPracticalWorkStrong.
  ///
  /// In en, this message translates to:
  /// **'It shows stronger signals for work opportunities and early economic structure.'**
  String get cityPracticalWorkStrong;

  /// No description provided for @cityPracticalWorkMedium.
  ///
  /// In en, this message translates to:
  /// **'It can work depending on your profile, but your city choice should be more deliberate.'**
  String get cityPracticalWorkMedium;

  /// No description provided for @cityPracticalWorkLow.
  ///
  /// In en, this message translates to:
  /// **'It looks less attractive if your main concern is finding work quickly.'**
  String get cityPracticalWorkLow;

  /// No description provided for @cityPracticalSafetyGood.
  ///
  /// In en, this message translates to:
  /// **'It looks better suited to a more stable daily routine within this initial catalog.'**
  String get cityPracticalSafetyGood;

  /// No description provided for @cityPracticalSafetyMedium.
  ///
  /// In en, this message translates to:
  /// **'It looks reasonable, but local context and neighborhood choice still matter a lot.'**
  String get cityPracticalSafetyMedium;

  /// No description provided for @cityPracticalSafetyLow.
  ///
  /// In en, this message translates to:
  /// **'It deserves extra caution and more local validation before treating it as an easy move.'**
  String get cityPracticalSafetyLow;

  /// No description provided for @cityMetricBadgePositive.
  ///
  /// In en, this message translates to:
  /// **'Favorable read'**
  String get cityMetricBadgePositive;

  /// No description provided for @cityMetricBadgeNeutral.
  ///
  /// In en, this message translates to:
  /// **'Needs balance'**
  String get cityMetricBadgeNeutral;

  /// No description provided for @cityMetricBadgeAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs extra attention'**
  String get cityMetricBadgeAttention;

  /// No description provided for @cityMetricCostLowHeadline.
  ///
  /// In en, this message translates to:
  /// **'Lower cost'**
  String get cityMetricCostLowHeadline;

  /// No description provided for @cityMetricCostLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'Lighter on your day-to-day budget.'**
  String get cityMetricCostLowSupporting;

  /// No description provided for @cityMetricCostMediumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Moderate cost'**
  String get cityMetricCostMediumHeadline;

  /// No description provided for @cityMetricCostMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'A reasonable balance between routine costs and infrastructure.'**
  String get cityMetricCostMediumSupporting;

  /// No description provided for @cityMetricCostHighHeadline.
  ///
  /// In en, this message translates to:
  /// **'Higher cost'**
  String get cityMetricCostHighHeadline;

  /// No description provided for @cityMetricCostHighSupporting.
  ///
  /// In en, this message translates to:
  /// **'It will require more care with rent and monthly expenses.'**
  String get cityMetricCostHighSupporting;

  /// No description provided for @cityMetricSafetyHighHeadline.
  ///
  /// In en, this message translates to:
  /// **'Higher safety'**
  String get cityMetricSafetyHighHeadline;

  /// No description provided for @cityMetricSafetyHighSupporting.
  ///
  /// In en, this message translates to:
  /// **'A more comfortable read for daily life at the start.'**
  String get cityMetricSafetyHighSupporting;

  /// No description provided for @cityMetricSafetyMediumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Moderate safety'**
  String get cityMetricSafetyMediumHeadline;

  /// No description provided for @cityMetricSafetyMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'It depends more on neighborhood and local context.'**
  String get cityMetricSafetyMediumSupporting;

  /// No description provided for @cityMetricSafetyLowHeadline.
  ///
  /// In en, this message translates to:
  /// **'More caution'**
  String get cityMetricSafetyLowHeadline;

  /// No description provided for @cityMetricSafetyLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'It deserves more validation before treating it as an easy move.'**
  String get cityMetricSafetyLowSupporting;

  /// No description provided for @cityMetricLanguageEasyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Easier adaptation'**
  String get cityMetricLanguageEasyHeadline;

  /// No description provided for @cityMetricLanguageEasySupporting.
  ///
  /// In en, this message translates to:
  /// **'Usually friendlier if you arrive speaking Spanish.'**
  String get cityMetricLanguageEasySupporting;

  /// No description provided for @cityMetricLanguageMediumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Moderate adaptation'**
  String get cityMetricLanguageMediumHeadline;

  /// No description provided for @cityMetricLanguageMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'Basic Portuguese still helps a lot in daily life.'**
  String get cityMetricLanguageMediumSupporting;

  /// No description provided for @cityMetricLanguageHardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Harder adaptation'**
  String get cityMetricLanguageHardHeadline;

  /// No description provided for @cityMetricLanguageHardSupporting.
  ///
  /// In en, this message translates to:
  /// **'Language tends to matter more in day-to-day integration.'**
  String get cityMetricLanguageHardSupporting;

  /// No description provided for @cityMetricWorkStrongHeadline.
  ///
  /// In en, this message translates to:
  /// **'Stronger market'**
  String get cityMetricWorkStrongHeadline;

  /// No description provided for @cityMetricWorkStrongSupporting.
  ///
  /// In en, this message translates to:
  /// **'A more favorable city if you are looking for opportunities.'**
  String get cityMetricWorkStrongSupporting;

  /// No description provided for @cityMetricWorkMediumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Moderate market'**
  String get cityMetricWorkMediumHeadline;

  /// No description provided for @cityMetricWorkMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'It can work well, but it depends more on your profile.'**
  String get cityMetricWorkMediumSupporting;

  /// No description provided for @cityMetricWorkLowHeadline.
  ///
  /// In en, this message translates to:
  /// **'More limited market'**
  String get cityMetricWorkLowHeadline;

  /// No description provided for @cityMetricWorkLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'It requires more strategy if quick work is your priority.'**
  String get cityMetricWorkLowSupporting;

  /// No description provided for @cityIdhmVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high development'**
  String get cityIdhmVeryHigh;

  /// No description provided for @cityIdhmVeryHighSupporting.
  ///
  /// In en, this message translates to:
  /// **'Among the strongest municipal levels in the official indicator.'**
  String get cityIdhmVeryHighSupporting;

  /// No description provided for @cityIdhmHigh.
  ///
  /// In en, this message translates to:
  /// **'High development'**
  String get cityIdhmHigh;

  /// No description provided for @cityIdhmHighSupporting.
  ///
  /// In en, this message translates to:
  /// **'A solid human development reading in the official reference.'**
  String get cityIdhmHighSupporting;

  /// No description provided for @cityIdhmMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium development'**
  String get cityIdhmMedium;

  /// No description provided for @cityIdhmMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'It should be read together with cost and opportunity context.'**
  String get cityIdhmMediumSupporting;

  /// No description provided for @cityIdhmLow.
  ///
  /// In en, this message translates to:
  /// **'Low development'**
  String get cityIdhmLow;

  /// No description provided for @cityIdhmLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'It needs more caution before assuming a strong overall structure.'**
  String get cityIdhmLowSupporting;

  /// No description provided for @cityIdhmVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very low development'**
  String get cityIdhmVeryLow;

  /// No description provided for @cityIdhmVeryLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'It signals a weaker base in the official indicator.'**
  String get cityIdhmVeryLowSupporting;

  /// No description provided for @citySnapshotRentLower.
  ///
  /// In en, this message translates to:
  /// **'Lighter rent'**
  String get citySnapshotRentLower;

  /// No description provided for @citySnapshotRentLowerSupporting.
  ///
  /// In en, this message translates to:
  /// **'It tends to weigh less at the start of the move.'**
  String get citySnapshotRentLowerSupporting;

  /// No description provided for @citySnapshotRentModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate rent'**
  String get citySnapshotRentModerate;

  /// No description provided for @citySnapshotRentModerateSupporting.
  ///
  /// In en, this message translates to:
  /// **'It calls for balance between neighborhood, contract, and routine.'**
  String get citySnapshotRentModerateSupporting;

  /// No description provided for @citySnapshotRentHigher.
  ///
  /// In en, this message translates to:
  /// **'Higher rent'**
  String get citySnapshotRentHigher;

  /// No description provided for @citySnapshotRentHigherSupporting.
  ///
  /// In en, this message translates to:
  /// **'It will require more care before closing housing.'**
  String get citySnapshotRentHigherSupporting;

  /// No description provided for @cityHousingViabilityTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing entry'**
  String get cityHousingViabilityTileLabel;

  /// No description provided for @cityHousingViabilityEasyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Lighter entry'**
  String get cityHousingViabilityEasyHeadline;

  /// No description provided for @cityHousingViabilityEasySupporting.
  ///
  /// In en, this message translates to:
  /// **'It tends to allow a softer landing, with less rent pressure and more room to adjust neighborhood and routine.'**
  String get cityHousingViabilityEasySupporting;

  /// No description provided for @cityHousingViabilityEasyBadge.
  ///
  /// In en, this message translates to:
  /// **'Good for soft landing'**
  String get cityHousingViabilityEasyBadge;

  /// No description provided for @cityHousingViabilityBalancedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Balanced entry'**
  String get cityHousingViabilityBalancedHeadline;

  /// No description provided for @cityHousingViabilityBalancedSupporting.
  ///
  /// In en, this message translates to:
  /// **'It can work well if you arrive with savings and validate the neighborhood, guarantee, and total setup cost before signing.'**
  String get cityHousingViabilityBalancedSupporting;

  /// No description provided for @cityHousingViabilityBalancedBadge.
  ///
  /// In en, this message translates to:
  /// **'Needs validation'**
  String get cityHousingViabilityBalancedBadge;

  /// No description provided for @cityHousingViabilityHardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Needs more cash'**
  String get cityHousingViabilityHardHeadline;

  /// No description provided for @cityHousingViabilityHardSupporting.
  ///
  /// In en, this message translates to:
  /// **'Here, rent and entry costs tend to weigh more. Treat housing as a serious filter before choosing the city.'**
  String get cityHousingViabilityHardSupporting;

  /// No description provided for @cityHousingViabilityHardBadge.
  ///
  /// In en, this message translates to:
  /// **'High housing pressure'**
  String get cityHousingViabilityHardBadge;

  /// No description provided for @cityMetricInsightTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to understand the data behind this read.'**
  String get cityMetricInsightTapHint;

  /// No description provided for @cityMetricInsightMeaningTitle.
  ///
  /// In en, this message translates to:
  /// **'What this means'**
  String get cityMetricInsightMeaningTitle;

  /// No description provided for @cityMetricInsightMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'How this read was built'**
  String get cityMetricInsightMethodTitle;

  /// No description provided for @cityMetricInsightFactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data used today'**
  String get cityMetricInsightFactsTitle;

  /// No description provided for @cityMetricInsightValidateTitle.
  ///
  /// In en, this message translates to:
  /// **'What to validate before deciding'**
  String get cityMetricInsightValidateTitle;

  /// No description provided for @cityMetricInsightSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Base and sources'**
  String get cityMetricInsightSourcesTitle;

  /// No description provided for @cityMetricInsightDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Use this card as an early triage. The final decision still depends on neighborhood, real prices, and local validation.'**
  String get cityMetricInsightDisclaimer;

  /// No description provided for @cityMetricInsightCurrentBaseBadge.
  ///
  /// In en, this message translates to:
  /// **'Current base'**
  String get cityMetricInsightCurrentBaseBadge;

  /// No description provided for @cityMetricInsightMappedBaseBadge.
  ///
  /// In en, this message translates to:
  /// **'Mapped reference'**
  String get cityMetricInsightMappedBaseBadge;

  /// No description provided for @cityMetricInsightOpenSourceAction.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get cityMetricInsightOpenSourceAction;

  /// No description provided for @cityMetricInsightRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'This card range'**
  String get cityMetricInsightRangeLabel;

  /// No description provided for @cityMetricInsightSpanishSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Spanish support'**
  String get cityMetricInsightSpanishSupportLabel;

  /// No description provided for @cityMetricInsightLanguageCurrentBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Practical adaptation read'**
  String get cityMetricInsightLanguageCurrentBaseTitle;

  /// No description provided for @cityMetricInsightHousingMeaning.
  ///
  /// In en, this message translates to:
  /// **'When this block drops into alert territory, it means rent and housing entry costs tend to weigh more in the first move to this city.'**
  String get cityMetricInsightHousingMeaning;

  /// No description provided for @cityMetricInsightHousingMethod.
  ///
  /// In en, this message translates to:
  /// **'Today the app combines the city\'s rentScore with its broader economical score. When housing stays below 55, the product treats housing entry as a critical filter.'**
  String get cityMetricInsightHousingMethod;

  /// No description provided for @cityMetricInsightHousingValidate.
  ///
  /// In en, this message translates to:
  /// **'Compare real rent, deposit, guarantees, furniture, and neighborhood cost before signing. Housing mistakes usually cost more here.'**
  String get cityMetricInsightHousingValidate;

  /// No description provided for @cityMetricInsightHousingMappedSource.
  ///
  /// In en, this message translates to:
  /// **'FipeZAP is the strongest reference already mapped in the project to recalibrate rent and housing pressure where municipal coverage exists.'**
  String get cityMetricInsightHousingMappedSource;

  /// No description provided for @cityMetricInsightSafetyMeaning.
  ///
  /// In en, this message translates to:
  /// **'This alert does not mean the city is unworkable. It means neighborhood choice, routine, and local validation matter more before treating the move as simple.'**
  String get cityMetricInsightSafetyMeaning;

  /// No description provided for @cityMetricInsightSafetyMethod.
  ///
  /// In en, this message translates to:
  /// **'Today the card uses Movaro\'s catalog safetyScore. Below 55, the read becomes caution; between 55 and 69 it stays moderate; from 70 onward it becomes more favorable.'**
  String get cityMetricInsightSafetyMethod;

  /// No description provided for @cityMetricInsightSafetyValidate.
  ///
  /// In en, this message translates to:
  /// **'Check neighborhood by neighborhood, nighttime travel, the real routine of residents, and the difference between tourist and residential areas.'**
  String get cityMetricInsightSafetyValidate;

  /// No description provided for @cityMetricInsightSafetyMappedSource.
  ///
  /// In en, this message translates to:
  /// **'Atlas da Violência is the official reference already mapped in the project to recalibrate this group with public data and open methodology.'**
  String get cityMetricInsightSafetyMappedSource;

  /// No description provided for @cityMetricInsightWorkMeaning.
  ///
  /// In en, this message translates to:
  /// **'Moderate market is not a blocker. It means the city can work, but the result depends more on your field, seniority, and entry path.'**
  String get cityMetricInsightWorkMeaning;

  /// No description provided for @cityMetricInsightWorkMethod.
  ///
  /// In en, this message translates to:
  /// **'The work score combines jobMarketScore, economicActivityScore, and inverted unemployment. Between 62 and 77, the read stays moderate; above 78, it becomes strong.'**
  String get cityMetricInsightWorkMethod;

  /// No description provided for @cityMetricInsightWorkValidate.
  ///
  /// In en, this message translates to:
  /// **'Look for real openings in your field, see which sectors pull the city, and estimate how much runway you have until your first income.'**
  String get cityMetricInsightWorkValidate;

  /// No description provided for @cityMetricInsightWorkMappedSource.
  ///
  /// In en, this message translates to:
  /// **'Novo Caged is the main official reference mapped to measure municipal formal-employment momentum.'**
  String get cityMetricInsightWorkMappedSource;

  /// No description provided for @cityMetricInsightWorkEconomicMappedSource.
  ///
  /// In en, this message translates to:
  /// **'IBGE\'s PIB dos Municipios is the mapped official reference for calibrating the city\'s economic activity weight.'**
  String get cityMetricInsightWorkEconomicMappedSource;

  /// No description provided for @cityMetricInsightLanguageMeaning.
  ///
  /// In en, this message translates to:
  /// **'Harder adaptation means Portuguese is likely to weigh more in day-to-day integration and that informal Spanish support appears weaker.'**
  String get cityMetricInsightLanguageMeaning;

  /// No description provided for @cityMetricInsightLanguageMethod.
  ///
  /// In en, this message translates to:
  /// **'This read uses the language-adaptation score, supported by Spanish support and familiarity among Argentinians. Below 65, friction tends to be higher.'**
  String get cityMetricInsightLanguageMethod;

  /// No description provided for @cityMetricInsightLanguageValidate.
  ///
  /// In en, this message translates to:
  /// **'Test the routine without relying on Spanish: housing, groceries, healthcare, services, and work. If that becomes a blocker, real adaptation in the city is tougher for your profile.'**
  String get cityMetricInsightLanguageValidate;

  /// No description provided for @cityMetricInsightLanguageMappedSource.
  ///
  /// In en, this message translates to:
  /// **'There is still no single official source for this read. Today it remains a curated product heuristic for practical adaptation.'**
  String get cityMetricInsightLanguageMappedSource;

  /// No description provided for @citySnapshotPopularityHigh.
  ///
  /// In en, this message translates to:
  /// **'Highly sought after'**
  String get citySnapshotPopularityHigh;

  /// No description provided for @citySnapshotPopularityHighSupporting.
  ///
  /// In en, this message translates to:
  /// **'It already shows strong affinity among Argentinians.'**
  String get citySnapshotPopularityHighSupporting;

  /// No description provided for @citySnapshotPopularityMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate popularity'**
  String get citySnapshotPopularityMedium;

  /// No description provided for @citySnapshotPopularityMediumSupporting.
  ///
  /// In en, this message translates to:
  /// **'It has a reasonable level of familiarity within the current catalog.'**
  String get citySnapshotPopularityMediumSupporting;

  /// No description provided for @citySnapshotPopularityLow.
  ///
  /// In en, this message translates to:
  /// **'Less frequent'**
  String get citySnapshotPopularityLow;

  /// No description provided for @citySnapshotPopularityLowSupporting.
  ///
  /// In en, this message translates to:
  /// **'It still appears less in the initial Argentinian interest slice.'**
  String get citySnapshotPopularityLowSupporting;

  /// No description provided for @citySnapshotUnemploymentLower.
  ///
  /// In en, this message translates to:
  /// **'Lower unemployment'**
  String get citySnapshotUnemploymentLower;

  /// No description provided for @citySnapshotUnemploymentModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate unemployment'**
  String get citySnapshotUnemploymentModerate;

  /// No description provided for @citySnapshotUnemploymentHigher.
  ///
  /// In en, this message translates to:
  /// **'Higher unemployment'**
  String get citySnapshotUnemploymentHigher;

  /// No description provided for @languageSelectorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageSelectorTooltip;

  /// No description provided for @languageOptionSpanishArgentina.
  ///
  /// In en, this message translates to:
  /// **'Español (Argentina)'**
  String get languageOptionSpanishArgentina;

  /// No description provided for @languageOptionEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageOptionEnglish;

  /// No description provided for @languageOptionPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languageOptionPortuguese;

  /// No description provided for @commonRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetryAction;

  /// No description provided for @commonBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBackAction;

  /// No description provided for @commonGotItAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotItAction;

  /// No description provided for @protectedCommunityCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get protectedCommunityCreateTitle;

  /// No description provided for @protectedCommunityCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'This area will allow community posting once that flow is enabled.'**
  String get protectedCommunityCreateDescription;

  /// No description provided for @questionOriginCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you coming from?'**
  String get questionOriginCountryTitle;

  /// No description provided for @journeyEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your destination and start faster'**
  String get journeyEntryTitle;

  /// No description provided for @journeyEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Pick where you want to move first. Movaro will save that choice now and ask for your origin in the first step of the questionnaire.'**
  String get journeyEntryBody;

  /// No description provided for @journeyEntryDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get journeyEntryDestinationLabel;

  /// No description provided for @journeyEntryStartAction.
  ///
  /// In en, this message translates to:
  /// **'Start my plan'**
  String get journeyEntryStartAction;

  /// No description provided for @journeyEntryDynamicTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a route that matches where you are and where you want to go'**
  String get journeyEntryDynamicTitle;

  /// No description provided for @journeyEntryDynamicBody.
  ///
  /// In en, this message translates to:
  /// **'You can use your current location as a quick hint or choose everything manually. Movaro never locks your origin from device location, and you can always override it.'**
  String get journeyEntryDynamicBody;

  /// No description provided for @journeyEntryUseLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get journeyEntryUseLocationTitle;

  /// No description provided for @journeyEntryUseLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Ask only now, detect your current country if possible, and let you confirm whether it should be used as origin.'**
  String get journeyEntryUseLocationBody;

  /// No description provided for @journeyEntryUseLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get journeyEntryUseLocationAction;

  /// No description provided for @journeyEntryManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose manually'**
  String get journeyEntryManualTitle;

  /// No description provided for @journeyEntryManualBody.
  ///
  /// In en, this message translates to:
  /// **'Skip location, set origin and destination yourself, and keep full control over the route.'**
  String get journeyEntryManualBody;

  /// No description provided for @journeyEntryManualAction.
  ///
  /// In en, this message translates to:
  /// **'Choose manually'**
  String get journeyEntryManualAction;

  /// No description provided for @journeyEntryContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue with quick questions'**
  String get journeyEntryContinueAction;

  /// No description provided for @journeyEntrySelectedDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination selected: {destination}'**
  String journeyEntrySelectedDestination(Object destination);

  /// No description provided for @journeyEntryOriginPending.
  ///
  /// In en, this message translates to:
  /// **'We\'ll collect your origin in the first question before plan generation.'**
  String get journeyEntryOriginPending;

  /// No description provided for @journeyLocationPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Location can save one step, but it never decides for you'**
  String get journeyLocationPanelTitle;

  /// No description provided for @journeyLocationPanelBody.
  ///
  /// In en, this message translates to:
  /// **'If you allow location, Movaro tries to detect your current country and suggests it as origin. You can reject the suggestion and choose manually instead.'**
  String get journeyLocationPanelBody;

  /// No description provided for @journeyLocationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Location did not resolve a usable country'**
  String get journeyLocationFallbackTitle;

  /// No description provided for @journeyLocationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can keep going by choosing origin and destination manually.'**
  String get journeyLocationDeniedBody;

  /// No description provided for @journeyLocationDeniedForeverBody.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked for this app right now. You can still continue with manual selection.'**
  String get journeyLocationDeniedForeverBody;

  /// No description provided for @journeyLocationUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Location services are off on this device. Turn them on if you want a location hint, or continue manually.'**
  String get journeyLocationUnavailableBody;

  /// No description provided for @journeyLocationFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro could not detect your location this time. You can retry or choose manually.'**
  String get journeyLocationFailedBody;

  /// No description provided for @journeyLocationRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get journeyLocationRetryAction;

  /// No description provided for @journeyDetectedLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected location: {value}'**
  String journeyDetectedLocationLabel(Object value);

  /// No description provided for @journeyDetectedConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Use {country} as your origin? This only sets a suggestion you can edit at any time.'**
  String journeyDetectedConfirmBody(Object country);

  /// No description provided for @journeyDetectedUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro detected {country}, but it could not match that country to the current route catalog. Choose your origin manually to continue.'**
  String journeyDetectedUnknownBody(Object country);

  /// No description provided for @journeyDetectedConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Use {country} as origin'**
  String journeyDetectedConfirmAction(Object country);

  /// No description provided for @questionnaireOriginAutoDetectTitle.
  ///
  /// In en, this message translates to:
  /// **'We found your location'**
  String get questionnaireOriginAutoDetectTitle;

  /// No description provided for @questionnaireOriginUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'This country is not supported yet'**
  String get questionnaireOriginUnsupportedTitle;

  /// No description provided for @questionnaireOriginLocationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not detect your location'**
  String get questionnaireOriginLocationFailedTitle;

  /// No description provided for @questionnaireOriginUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro detected {country}, but the guided plan is only available for people coming from Argentina right now. You can choose Argentina manually or use it to continue.'**
  String questionnaireOriginUnsupportedBody(Object country);

  /// No description provided for @questionnaireOriginUseArgentinaAction.
  ///
  /// In en, this message translates to:
  /// **'Use Argentina'**
  String get questionnaireOriginUseArgentinaAction;

  /// No description provided for @journeyDetectedManualAction.
  ///
  /// In en, this message translates to:
  /// **'Choose origin manually'**
  String get journeyDetectedManualAction;

  /// No description provided for @journeyOriginSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get journeyOriginSectionTitle;

  /// No description provided for @journeyOriginSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Optional for now. Confirm it here if you already know it, or skip and answer it in the first questionnaire step.'**
  String get journeyOriginSectionBody;

  /// No description provided for @journeyOriginSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get journeyOriginSkipAction;

  /// No description provided for @journeyDestinationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get journeyDestinationSectionTitle;

  /// No description provided for @journeyDestinationSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Choose where you want the migration plan to point. Destination is still required before the questionnaire starts.'**
  String get journeyDestinationSectionBody;

  /// No description provided for @journeyPickerChooseDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get journeyPickerChooseDestinationTitle;

  /// No description provided for @journeyPickerChooseOriginTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose origin'**
  String get journeyPickerChooseOriginTitle;

  /// No description provided for @journeyPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get journeyPickerSearchHint;

  /// No description provided for @journeyPickerNoResults.
  ///
  /// In en, this message translates to:
  /// **'No countries found'**
  String get journeyPickerNoResults;

  /// No description provided for @journeyCoverageFull.
  ///
  /// In en, this message translates to:
  /// **'Full coverage'**
  String get journeyCoverageFull;

  /// No description provided for @journeyCoveragePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial coverage'**
  String get journeyCoveragePartial;

  /// No description provided for @journeyCoverageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported'**
  String get journeyCoverageUnsupported;

  /// No description provided for @journeyCoverageReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'This route is ready for planning'**
  String get journeyCoverageReadyTitle;

  /// No description provided for @journeyCoverageReadyBody.
  ///
  /// In en, this message translates to:
  /// **'{origin} -> {destination} is supported in the current migration flow.'**
  String journeyCoverageReadyBody(Object origin, Object destination);

  /// No description provided for @journeyCoverageDestinationLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination coverage is still limited'**
  String get journeyCoverageDestinationLimitedTitle;

  /// No description provided for @journeyCoverageDestinationLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'{destination} does not yet have full destination coverage for the guided migration flow. You can still explore content while the route expands.'**
  String journeyCoverageDestinationLimitedBody(Object destination);

  /// No description provided for @journeyCoverageOriginLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Origin coverage is still limited'**
  String get journeyCoverageOriginLimitedTitle;

  /// No description provided for @journeyCoverageOriginLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'{origin} can be saved as your origin, but the current guided plan does not fully support that starting country yet.'**
  String journeyCoverageOriginLimitedBody(Object origin);

  /// No description provided for @journeyCoverageDetectedUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected country is outside the current catalog'**
  String get journeyCoverageDetectedUnknownTitle;

  /// No description provided for @journeyCoverageDetectedUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'{country} is not mapped in the current supported-country catalog yet. Choose another origin manually or keep browsing public content.'**
  String journeyCoverageDetectedUnknownBody(Object country);

  /// No description provided for @journeyCoverageUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a supported route to generate a plan'**
  String get journeyCoverageUnsupportedTitle;

  /// No description provided for @journeyCoverageUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro can still show cities and practical content, but the guided migration flow is only available on routes with full coverage.'**
  String get journeyCoverageUnsupportedBody;

  /// No description provided for @journeyCoverageChooseRouteAction.
  ///
  /// In en, this message translates to:
  /// **'Choose another route'**
  String get journeyCoverageChooseRouteAction;

  /// No description provided for @journeyCoverageBrowseAction.
  ///
  /// In en, this message translates to:
  /// **'Browse explore'**
  String get journeyCoverageBrowseAction;

  /// No description provided for @journeyCoverageContentAction.
  ///
  /// In en, this message translates to:
  /// **'Open content'**
  String get journeyCoverageContentAction;

  /// No description provided for @journeyCoverageWaitlistAction.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get journeyCoverageWaitlistAction;

  /// No description provided for @journeyCoverageWaitlistStub.
  ///
  /// In en, this message translates to:
  /// **'Waitlist registration is not live yet, but this route can be tracked safely for future coverage.'**
  String get journeyCoverageWaitlistStub;

  /// No description provided for @questionDestinationCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get questionDestinationCountryTitle;

  /// No description provided for @questionGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do in the new country?'**
  String get questionGoalTitle;

  /// No description provided for @questionPortugueseFamiliarityTitle.
  ///
  /// In en, this message translates to:
  /// **'How comfortable are you with Portuguese today?'**
  String get questionPortugueseFamiliarityTitle;

  /// No description provided for @questionTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'When are you planning to move?'**
  String get questionTimelineTitle;

  /// No description provided for @questionOptionArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get questionOptionArgentina;

  /// No description provided for @questionOptionBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get questionOptionBrazil;

  /// No description provided for @questionOptionChile.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get questionOptionChile;

  /// No description provided for @questionOptionUruguay.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get questionOptionUruguay;

  /// No description provided for @questionOptionParaguay.
  ///
  /// In en, this message translates to:
  /// **'Paraguay'**
  String get questionOptionParaguay;

  /// No description provided for @questionOptionUnknown.
  ///
  /// In en, this message translates to:
  /// **'I still do not know'**
  String get questionOptionUnknown;

  /// No description provided for @questionOptionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get questionOptionWork;

  /// No description provided for @questionOptionRemoteWork.
  ///
  /// In en, this message translates to:
  /// **'Work remotely'**
  String get questionOptionRemoteWork;

  /// No description provided for @questionOptionStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get questionOptionStudy;

  /// No description provided for @questionOptionEntrepreneur.
  ///
  /// In en, this message translates to:
  /// **'Start a business'**
  String get questionOptionEntrepreneur;

  /// No description provided for @questionOptionRetire.
  ///
  /// In en, this message translates to:
  /// **'Retire'**
  String get questionOptionRetire;

  /// No description provided for @questionOptionQualityOfLife.
  ///
  /// In en, this message translates to:
  /// **'Quality of life'**
  String get questionOptionQualityOfLife;

  /// No description provided for @questionOptionBeachLife.
  ///
  /// In en, this message translates to:
  /// **'Beach and coast'**
  String get questionOptionBeachLife;

  /// No description provided for @questionOptionNoPortuguese.
  ///
  /// In en, this message translates to:
  /// **'I still depend mostly on Spanish'**
  String get questionOptionNoPortuguese;

  /// No description provided for @questionOptionBasicPortuguese.
  ///
  /// In en, this message translates to:
  /// **'I can handle basic Portuguese'**
  String get questionOptionBasicPortuguese;

  /// No description provided for @questionOptionComfortablePortuguese.
  ///
  /// In en, this message translates to:
  /// **'I can already live in Portuguese'**
  String get questionOptionComfortablePortuguese;

  /// No description provided for @questionOptionResearching.
  ///
  /// In en, this message translates to:
  /// **'I am just researching'**
  String get questionOptionResearching;

  /// No description provided for @questionOption12Months.
  ///
  /// In en, this message translates to:
  /// **'Within the next 12 months'**
  String get questionOption12Months;

  /// No description provided for @questionOption6Months.
  ///
  /// In en, this message translates to:
  /// **'Within the next 6 months'**
  String get questionOption6Months;

  /// No description provided for @questionOptionAsap.
  ///
  /// In en, this message translates to:
  /// **'As soon as possible'**
  String get questionOptionAsap;

  /// No description provided for @recommendationReasonEconomical.
  ///
  /// In en, this message translates to:
  /// **'A good option if cost matters to you'**
  String get recommendationReasonEconomical;

  /// No description provided for @recommendationReasonPopularArgentina.
  ///
  /// In en, this message translates to:
  /// **'Popular among Argentinians'**
  String get recommendationReasonPopularArgentina;

  /// No description provided for @recommendationReasonLanguageSupport.
  ///
  /// In en, this message translates to:
  /// **'Easier adaptation if you still depend on Spanish'**
  String get recommendationReasonLanguageSupport;

  /// No description provided for @recommendationReasonWorkMarket.
  ///
  /// In en, this message translates to:
  /// **'Stronger job market'**
  String get recommendationReasonWorkMarket;

  /// No description provided for @recommendationReasonInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Higher cost, but stronger infrastructure'**
  String get recommendationReasonInfrastructure;

  /// No description provided for @recommendationReasonBalanced.
  ///
  /// In en, this message translates to:
  /// **'A balanced option within the initial Movaro catalog'**
  String get recommendationReasonBalanced;

  /// No description provided for @planReasonGoalWork.
  ///
  /// In en, this message translates to:
  /// **'It stands out if you are looking for more work opportunities.'**
  String get planReasonGoalWork;

  /// No description provided for @planReasonGoalRemoteWork.
  ///
  /// In en, this message translates to:
  /// **'It fits better if you want remote work and a better balance between cost and quality of life.'**
  String get planReasonGoalRemoteWork;

  /// No description provided for @planReasonGoalStudy.
  ///
  /// In en, this message translates to:
  /// **'It has a good mix of urban structure and early adaptation for studying.'**
  String get planReasonGoalStudy;

  /// No description provided for @planReasonGoalEntrepreneur.
  ///
  /// In en, this message translates to:
  /// **'It shows stronger economic activity for someone who wants to start a business.'**
  String get planReasonGoalEntrepreneur;

  /// No description provided for @planReasonGoalRetire.
  ///
  /// In en, this message translates to:
  /// **'It makes more sense if you are looking for more safety and a more controlled cost of living.'**
  String get planReasonGoalRetire;

  /// No description provided for @planReasonGoalQualityOfLife.
  ///
  /// In en, this message translates to:
  /// **'It fits better if you are prioritizing quality of life and gradual adaptation.'**
  String get planReasonGoalQualityOfLife;

  /// No description provided for @planReasonGoalBeachLife.
  ///
  /// In en, this message translates to:
  /// **'It makes more sense if you want to prioritize the coast, the beach, and a routine more connected to the sea.'**
  String get planReasonGoalBeachLife;

  /// No description provided for @planReasonLanguageNeedsSupport.
  ///
  /// In en, this message translates to:
  /// **'You said you still depend on Spanish, so we gave more weight to places with stronger language adaptation.'**
  String get planReasonLanguageNeedsSupport;

  /// No description provided for @planReasonLanguageBasic.
  ///
  /// In en, this message translates to:
  /// **'You said you only handle basic Portuguese, so language adaptation still influenced the recommendation.'**
  String get planReasonLanguageBasic;

  /// No description provided for @planReasonTimelineAsap.
  ///
  /// In en, this message translates to:
  /// **'It may help with a faster move by combining easier early adaptation and more practical daily life.'**
  String get planReasonTimelineAsap;

  /// No description provided for @planReasonTimeline6Months.
  ///
  /// In en, this message translates to:
  /// **'It works well for a shorter moving timeline.'**
  String get planReasonTimeline6Months;

  /// No description provided for @planReasonTimeline12Months.
  ///
  /// In en, this message translates to:
  /// **'It offers a balanced base for someone still structuring the move.'**
  String get planReasonTimeline12Months;

  /// No description provided for @planStepTitleVisaResidence.
  ///
  /// In en, this message translates to:
  /// **'Review residency or visa type'**
  String get planStepTitleVisaResidence;

  /// No description provided for @planStepDescriptionVisaResidence.
  ///
  /// In en, this message translates to:
  /// **'Map the right migration path for your main reason to move.'**
  String get planStepDescriptionVisaResidence;

  /// No description provided for @planStepTitleCpf.
  ///
  /// In en, this message translates to:
  /// **'Get a CPF'**
  String get planStepTitleCpf;

  /// No description provided for @planStepDescriptionCpf.
  ///
  /// In en, this message translates to:
  /// **'Organize the tax registration needed for services and transactions in Brazil.'**
  String get planStepDescriptionCpf;

  /// No description provided for @planStepTitleBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Open a bank account'**
  String get planStepTitleBankAccount;

  /// No description provided for @planStepDescriptionBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up a local account for your first financial steps.'**
  String get planStepDescriptionBankAccount;

  /// No description provided for @planStepTitleHousing.
  ///
  /// In en, this message translates to:
  /// **'Look for housing'**
  String get planStepTitleHousing;

  /// No description provided for @planStepDescriptionHousing.
  ///
  /// In en, this message translates to:
  /// **'Research neighborhoods, contracts, and costs for a safer move.'**
  String get planStepDescriptionHousing;

  /// No description provided for @planStepTitleSettleDocuments.
  ///
  /// In en, this message translates to:
  /// **'Regularize local documents'**
  String get planStepTitleSettleDocuments;

  /// No description provided for @planStepDescriptionSettleDocuments.
  ///
  /// In en, this message translates to:
  /// **'Review additional registrations, proof documents, and local administrative steps.'**
  String get planStepDescriptionSettleDocuments;

  /// No description provided for @planStepTitleMapDestinations.
  ///
  /// In en, this message translates to:
  /// **'Map possible destinations'**
  String get planStepTitleMapDestinations;

  /// No description provided for @planStepDescriptionMapDestinations.
  ///
  /// In en, this message translates to:
  /// **'Compare destination options based on your goal and moving window.'**
  String get planStepDescriptionMapDestinations;

  /// No description provided for @planStepTitleDecisionCriteria.
  ///
  /// In en, this message translates to:
  /// **'Define decision criteria'**
  String get planStepTitleDecisionCriteria;

  /// No description provided for @planStepDescriptionDecisionCriteria.
  ///
  /// In en, this message translates to:
  /// **'Organize priorities such as cost, paperwork, and quality of life.'**
  String get planStepDescriptionDecisionCriteria;

  /// No description provided for @planBeachDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coastline in the decision'**
  String get planBeachDecisionTitle;

  /// No description provided for @planBeachDecisionIntro.
  ///
  /// In en, this message translates to:
  /// **'If beach and coast are part of your criteria, do not look only at beauty or tourism. The real filter is housing entry, city pace, and soft landing.'**
  String get planBeachDecisionIntro;

  /// No description provided for @planBeachDecisionCoastalHeadline.
  ///
  /// In en, this message translates to:
  /// **'The recommendation already points to the coast'**
  String get planBeachDecisionCoastalHeadline;

  /// No description provided for @planBeachDecisionCoastalBody.
  ///
  /// In en, this message translates to:
  /// **'{cityName} already fits the coastal-city filter. The next step is understanding whether housing entry and local routine match your current situation.'**
  String planBeachDecisionCoastalBody(Object cityName);

  /// No description provided for @planBeachDecisionNotCoastalHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your beach criterion needs an extra comparison'**
  String get planBeachDecisionNotCoastalHeadline;

  /// No description provided for @planBeachDecisionNotCoastalBody.
  ///
  /// In en, this message translates to:
  /// **'Even with this goal, it is worth comparing beach cities before making a decision. Not every city that looks strong in the plan delivers the coastal routine you may be looking for.'**
  String get planBeachDecisionNotCoastalBody;

  /// No description provided for @planBeachDecisionPriorityNote.
  ///
  /// In en, this message translates to:
  /// **'If beach is a priority, treat housing and local routine as your main filter.'**
  String get planBeachDecisionPriorityNote;

  /// No description provided for @planBeachDecisionHousingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Housing entry on the coast'**
  String get planBeachDecisionHousingHeadline;

  /// No description provided for @stepCategoryDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get stepCategoryDocumentation;

  /// No description provided for @stepCategoryFinancial.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get stepCategoryFinancial;

  /// No description provided for @stepCategoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get stepCategoryHousing;

  /// No description provided for @stepCategorySettlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get stepCategorySettlement;

  /// No description provided for @stepCategoryResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get stepCategoryResearch;

  /// No description provided for @stepCategoryPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get stepCategoryPlanning;

  /// No description provided for @industryAgribusiness.
  ///
  /// In en, this message translates to:
  /// **'Agribusiness'**
  String get industryAgribusiness;

  /// No description provided for @industryCommerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get industryCommerce;

  /// No description provided for @industryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get industryConstruction;

  /// No description provided for @industryEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get industryEnergy;

  /// No description provided for @industryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get industryFinance;

  /// No description provided for @industryIndustry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industryIndustry;

  /// No description provided for @industryLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get industryLogistics;

  /// No description provided for @industryPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get industryPort;

  /// No description provided for @industryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get industryHealth;

  /// No description provided for @industryServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get industryServices;

  /// No description provided for @industryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get industryTechnology;

  /// No description provided for @industryTourism.
  ///
  /// In en, this message translates to:
  /// **'Tourism'**
  String get industryTourism;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'It looks like you are offline.'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again in a moment.'**
  String get errorNetworkDescription;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorServerTitle;

  /// No description provided for @errorServerDescription.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this action right now. Try again in a moment.'**
  String get errorServerDescription;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not find this information.'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'This content is not available right now or is not part of this catalog yet.'**
  String get errorNotFoundDescription;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'You need to sign in to continue.'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorizedDescription.
  ///
  /// In en, this message translates to:
  /// **'Some actions need to be linked to you before they can be saved.'**
  String get errorUnauthorizedDescription;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened.'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownDescription.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get errorUnknownDescription;

  /// No description provided for @errorValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this request.'**
  String get errorValidationTitle;

  /// No description provided for @errorNetworkMovaroDescription.
  ///
  /// In en, this message translates to:
  /// **'We could not reach Movaro right now. Try again in a moment.'**
  String get errorNetworkMovaroDescription;

  /// No description provided for @errorApiGenericDescription.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this action right now.'**
  String get errorApiGenericDescription;

  /// No description provided for @apiUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Movaro could not reach the API right now.'**
  String get apiUnavailableTitle;

  /// No description provided for @apiUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'The app opened, but the main service is unavailable at the moment. Without this connection, it cannot load your journey with real data.'**
  String get apiUnavailableDescription;

  /// No description provided for @apiUnavailableSupportingText.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment. If this keeps happening, check whether the API is online and whether this environment is pointing to the correct URL.'**
  String get apiUnavailableSupportingText;

  /// No description provided for @apiUnavailableRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get apiUnavailableRetryAction;

  /// No description provided for @sourceProviderIbgeLocalities.
  ///
  /// In en, this message translates to:
  /// **'IBGE Localities'**
  String get sourceProviderIbgeLocalities;

  /// No description provided for @sourceProviderIbgeCities.
  ///
  /// In en, this message translates to:
  /// **'IBGE Cities and States'**
  String get sourceProviderIbgeCities;

  /// No description provided for @sourceProviderAtlasHumanDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Human Development Atlas in Brazil (UNDP, Ipea, and FJP)'**
  String get sourceProviderAtlasHumanDevelopment;

  /// No description provided for @sourceProviderMovaroDataset.
  ///
  /// In en, this message translates to:
  /// **'Movaro Curated Dataset v1'**
  String get sourceProviderMovaroDataset;

  /// No description provided for @sourceProviderMovaroRanking.
  ///
  /// In en, this message translates to:
  /// **'Movaro Ranking Methodology v1'**
  String get sourceProviderMovaroRanking;

  /// No description provided for @sourceProviderGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get sourceProviderGoogleMaps;

  /// No description provided for @sourceProviderReceitaFederalGovBr.
  ///
  /// In en, this message translates to:
  /// **'Federal Revenue / Gov.br'**
  String get sourceProviderReceitaFederalGovBr;

  /// No description provided for @sourceProviderArgentinaMigraciones.
  ///
  /// In en, this message translates to:
  /// **'Argentina.gob.ar / Migration Office'**
  String get sourceProviderArgentinaMigraciones;

  /// No description provided for @sourceProviderPoliciaFederal.
  ///
  /// In en, this message translates to:
  /// **'Federal Police'**
  String get sourceProviderPoliciaFederal;

  /// No description provided for @sourceProviderPoliciaFederalGovBr.
  ///
  /// In en, this message translates to:
  /// **'Federal Police / Gov.br'**
  String get sourceProviderPoliciaFederalGovBr;

  /// No description provided for @sourceProviderMrePoliciaFederal.
  ///
  /// In en, this message translates to:
  /// **'Foreign Ministry / Federal Police'**
  String get sourceProviderMrePoliciaFederal;

  /// No description provided for @sourceProviderMreBancoCentral.
  ///
  /// In en, this message translates to:
  /// **'Foreign Ministry / Central Bank'**
  String get sourceProviderMreBancoCentral;

  /// No description provided for @sourceProviderMinisterioJustica.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Justice'**
  String get sourceProviderMinisterioJustica;

  /// No description provided for @sourceProviderMinisterioSaude.
  ///
  /// In en, this message translates to:
  /// **'Gov.br / Ministry of Health'**
  String get sourceProviderMinisterioSaude;

  /// No description provided for @sourceProviderMeuSusDigital.
  ///
  /// In en, this message translates to:
  /// **'Meu SUS Digital / Gov.br'**
  String get sourceProviderMeuSusDigital;

  /// No description provided for @sourceProviderAns.
  ///
  /// In en, this message translates to:
  /// **'ANS'**
  String get sourceProviderAns;

  /// No description provided for @sourceProviderDetranEsMgGov.
  ///
  /// In en, this message translates to:
  /// **'Detran-ES / MG.gov.br'**
  String get sourceProviderDetranEsMgGov;

  /// No description provided for @sourceProviderSenatranMgGov.
  ///
  /// In en, this message translates to:
  /// **'SENATRAN / MG.gov.br'**
  String get sourceProviderSenatranMgGov;

  /// No description provided for @sourceProviderMteCtps.
  ///
  /// In en, this message translates to:
  /// **'Labor Ministry / Digital Work Card'**
  String get sourceProviderMteCtps;

  /// No description provided for @sourceProviderPortalEmpreendedorInss.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneur Portal / INSS'**
  String get sourceProviderPortalEmpreendedorInss;

  /// No description provided for @sourceProviderMinisterioPrevidenciaInss.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Social Security / INSS'**
  String get sourceProviderMinisterioPrevidenciaInss;

  /// No description provided for @sourceProviderIbgePnadContinua.
  ///
  /// In en, this message translates to:
  /// **'IBGE / Continuous PNAD'**
  String get sourceProviderIbgePnadContinua;

  /// No description provided for @sourceProviderForumBrasileiroSegurancaPublica.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Forum of Public Security'**
  String get sourceProviderForumBrasileiroSegurancaPublica;

  /// No description provided for @sourceProviderBancoCentralBrasil.
  ///
  /// In en, this message translates to:
  /// **'Central Bank of Brazil'**
  String get sourceProviderBancoCentralBrasil;

  /// No description provided for @sourceProviderMovaro.
  ///
  /// In en, this message translates to:
  /// **'Movaro'**
  String get sourceProviderMovaro;

  /// No description provided for @documentReadinessSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Document readiness before the move'**
  String get documentReadinessSectionTitle;

  /// No description provided for @documentReadinessPriorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical now'**
  String get documentReadinessPriorityCritical;

  /// No description provided for @documentReadinessPriorityPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare with lead time'**
  String get documentReadinessPriorityPrepare;

  /// No description provided for @documentReadinessPriorityArrival.
  ///
  /// In en, this message translates to:
  /// **'Keep ready on arrival'**
  String get documentReadinessPriorityArrival;

  /// No description provided for @documentReadinessSummaryResearching.
  ///
  /// In en, this message translates to:
  /// **'Before comparing too many paths, make sure your move depends on a document pack that can actually be assembled without surprises.'**
  String get documentReadinessSummaryResearching;

  /// No description provided for @documentReadinessSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'With more time, the goal is to remove preventable document risk early instead of discovering missing items close to the move.'**
  String get documentReadinessSummaryTwelveMonths;

  /// No description provided for @documentReadinessSummarySixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six months is enough to organize the hard documents now and make the arrival layer lighter.'**
  String get documentReadinessSummarySixMonths;

  /// No description provided for @documentReadinessSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'Since the move is close, focus first on the documents that can block residency, banking, and housing.'**
  String get documentReadinessSummaryAsap;

  /// No description provided for @documentReadinessRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate the legal entry route'**
  String get documentReadinessRouteTitle;

  /// No description provided for @documentReadinessRouteBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Confirm whether your move will rely on the Mercosur residence path and what that route demands before you plan around assumptions.'**
  String get documentReadinessRouteBodyBrazil;

  /// No description provided for @documentReadinessRouteBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Confirm the legal route for the destination first so the rest of the checklist is built on the correct migration path.'**
  String get documentReadinessRouteBodyGeneric;

  /// No description provided for @documentReadinessIdentityPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Separate the core identity pack'**
  String get documentReadinessIdentityPackTitle;

  /// No description provided for @documentReadinessIdentityPackBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your passport, birth records, criminal records, and personal identifiers in one reviewed bundle before opening other fronts.'**
  String get documentReadinessIdentityPackBody;

  /// No description provided for @documentReadinessApostilleTitle.
  ///
  /// In en, this message translates to:
  /// **'Review apostille and validity windows'**
  String get documentReadinessApostilleTitle;

  /// No description provided for @documentReadinessApostilleBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'For Brazil, check which Argentine documents need an apostille, how recent they must be, and what may expire before arrival.'**
  String get documentReadinessApostilleBodyBrazil;

  /// No description provided for @documentReadinessRuleCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check official document rules early'**
  String get documentReadinessRuleCheckTitle;

  /// No description provided for @documentReadinessRuleCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Map which documents must be original, apostilled, translated, or reissued so the move does not depend on assumptions.'**
  String get documentReadinessRuleCheckBody;

  /// No description provided for @documentReadinessTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Map translation needs before paying twice'**
  String get documentReadinessTranslationTitle;

  /// No description provided for @documentReadinessTranslationBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Separate what can stay in Spanish from what may require sworn translation in Brazil, especially for residency and civil proof.'**
  String get documentReadinessTranslationBodyBrazil;

  /// No description provided for @documentReadinessTranslationBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Separate what can remain in the source language from what may require certified translation in the destination country.'**
  String get documentReadinessTranslationBodyGeneric;

  /// No description provided for @documentReadinessHousingProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare proof for housing and routine setup'**
  String get documentReadinessHousingProofTitle;

  /// No description provided for @documentReadinessHousingProofBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Group proof of income, savings, identification, and any supporting papers that landlords, banks, or guarantee products may ask for in Brazil.'**
  String get documentReadinessHousingProofBodyBrazil;

  /// No description provided for @documentReadinessProofPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your practical proof pack'**
  String get documentReadinessProofPackTitle;

  /// No description provided for @documentReadinessProofPackBody.
  ///
  /// In en, this message translates to:
  /// **'Group identity, proof of funds, income evidence, and the documents that usually unlock banking, housing, and essential services.'**
  String get documentReadinessProofPackBody;

  /// No description provided for @documentReadinessCpfTitle.
  ///
  /// In en, this message translates to:
  /// **'Treat CPF and regular status as one layer'**
  String get documentReadinessCpfTitle;

  /// No description provided for @documentReadinessCpfBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'CPF, residency follow-up, and your first local proof often unlock the practical side of arrival. Keep that bundle ready to execute quickly.'**
  String get documentReadinessCpfBodyBrazil;

  /// No description provided for @documentReadinessCopiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep physical and digital backups aligned'**
  String get documentReadinessCopiesTitle;

  /// No description provided for @documentReadinessCopiesBody.
  ///
  /// In en, this message translates to:
  /// **'Save scans, originals, and emergency copies in a structure that can be accessed from your phone and used in person if needed.'**
  String get documentReadinessCopiesBody;

  /// No description provided for @documentReadinessArrivalFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare an arrival folder, not scattered files'**
  String get documentReadinessArrivalFolderTitle;

  /// No description provided for @documentReadinessArrivalFolderBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Create one arrival folder with residency follow-up, CPF references, address notes, and the proof most likely to be requested in the first month.'**
  String get documentReadinessArrivalFolderBodyBrazil;

  /// No description provided for @documentReadinessArrivalFolderBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Create one arrival folder with the first documents, local proof notes, and the evidence you are most likely to need in the first weeks.'**
  String get documentReadinessArrivalFolderBodyGeneric;

  /// No description provided for @documentReadinessGoalWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your employability documents'**
  String get documentReadinessGoalWorkTitle;

  /// No description provided for @documentReadinessGoalWorkBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Review what can block early work in Brazil: identity consistency, residence follow-up, and any profession-specific proof you may need to show quickly.'**
  String get documentReadinessGoalWorkBodyBrazil;

  /// No description provided for @documentReadinessGoalWorkBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Review what can block early work in the destination: identity consistency, immigration status, and profession-specific proof.'**
  String get documentReadinessGoalWorkBodyGeneric;

  /// No description provided for @documentReadinessGoalRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Stabilize the document base for remote income'**
  String get documentReadinessGoalRemoteTitle;

  /// No description provided for @documentReadinessGoalRemoteBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Keep tax identity, banking references, and proof that supports contracts, transfers, and a stable routine in Brazil.'**
  String get documentReadinessGoalRemoteBodyBrazil;

  /// No description provided for @documentReadinessGoalRemoteBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Keep tax identity, banking references, and the proof that supports contracts and international income flow in the new country.'**
  String get documentReadinessGoalRemoteBodyGeneric;

  /// No description provided for @documentReadinessGoalStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the study path with the right records'**
  String get documentReadinessGoalStudyTitle;

  /// No description provided for @documentReadinessGoalStudyBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Keep admissions, school records, identity documents, and time-sensitive paperwork aligned before relying on study as the entry path.'**
  String get documentReadinessGoalStudyBodyBrazil;

  /// No description provided for @documentReadinessGoalStudyBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Keep admissions, school records, identity documents, and time-sensitive paperwork aligned before relying on study as the base.'**
  String get documentReadinessGoalStudyBodyGeneric;

  /// No description provided for @documentReadinessGoalEntrepreneurTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the operating document layer'**
  String get documentReadinessGoalEntrepreneurTitle;

  /// No description provided for @documentReadinessGoalEntrepreneurBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Separate the identity, banking, and residency proof that will affect how safely you can start operating once in Brazil.'**
  String get documentReadinessGoalEntrepreneurBodyBrazil;

  /// No description provided for @documentReadinessGoalEntrepreneurBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Separate the identity, banking, and immigration proof that will affect how safely you can start operating in the destination country.'**
  String get documentReadinessGoalEntrepreneurBodyGeneric;

  /// No description provided for @documentReadinessGoalRetireTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect a calm arrival with reviewed paperwork'**
  String get documentReadinessGoalRetireTitle;

  /// No description provided for @documentReadinessGoalRetireBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Favor the document set that reduces surprises in health access, banking, and recurring routine once you land in Brazil.'**
  String get documentReadinessGoalRetireBodyBrazil;

  /// No description provided for @documentReadinessGoalRetireBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Favor the document set that reduces surprises in health access, banking, and recurring routine once you arrive.'**
  String get documentReadinessGoalRetireBodyGeneric;

  /// No description provided for @documentReadinessGoalQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Use documents to reduce friction, not just to comply'**
  String get documentReadinessGoalQualityTitle;

  /// No description provided for @documentReadinessGoalQualityBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Even when quality of life is the goal, the smoother move is the one with identity, proof, and arrival paperwork already structured for Brazil.'**
  String get documentReadinessGoalQualityBodyBrazil;

  /// No description provided for @documentReadinessGoalQualityBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Even when quality of life is the goal, the smoother move is the one with identity, proof, and arrival paperwork already structured.'**
  String get documentReadinessGoalQualityBodyGeneric;

  /// No description provided for @documentReadinessRiskBlocking.
  ///
  /// In en, this message translates to:
  /// **'Can block the move'**
  String get documentReadinessRiskBlocking;

  /// No description provided for @documentReadinessRiskCaution.
  ///
  /// In en, this message translates to:
  /// **'Avoids delay and rework'**
  String get documentReadinessRiskCaution;

  /// No description provided for @documentReadinessRiskReview.
  ///
  /// In en, this message translates to:
  /// **'Review at the right stage'**
  String get documentReadinessRiskReview;

  /// No description provided for @documentReadinessReviewBeforeBooking.
  ///
  /// In en, this message translates to:
  /// **'Review before booking travel'**
  String get documentReadinessReviewBeforeBooking;

  /// No description provided for @documentReadinessReviewCloseToMove.
  ///
  /// In en, this message translates to:
  /// **'Reconfirm close to the move'**
  String get documentReadinessReviewCloseToMove;

  /// No description provided for @documentReadinessReviewOnArrival.
  ///
  /// In en, this message translates to:
  /// **'Keep ready for arrival'**
  String get documentReadinessReviewOnArrival;

  /// No description provided for @documentReadinessSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Base: {source}'**
  String documentReadinessSourceLabel(Object source);

  /// No description provided for @housingDecisionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Housing is a critical decision before the city'**
  String get housingDecisionSectionTitle;

  /// No description provided for @housingDecisionSectionTitleWithCity.
  ///
  /// In en, this message translates to:
  /// **'Housing may decide whether {city} works for you'**
  String housingDecisionSectionTitleWithCity(Object city);

  /// No description provided for @housingDecisionSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Before choosing the city, understand how rent and guarantees work in Brazil. The biggest risk is not only the monthly price: it is landing without a viable path for the contract, neighborhood, and initial setup.'**
  String get housingDecisionSectionBody;

  /// No description provided for @housingDecisionSectionBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Before assuming {city} is the best option, validate whether rent, guarantees, and initial setup look viable for your current situation. The risk is not only the price, but the real path to secure housing.'**
  String housingDecisionSectionBodyWithCity(Object city);

  /// No description provided for @housingDecisionGuaranteesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guarantees can block the lease'**
  String get housingDecisionGuaranteesTitle;

  /// No description provided for @housingDecisionGuaranteesBody.
  ///
  /// In en, this message translates to:
  /// **'A local guarantor still matters in many contracts. If that is not realistic for you, compare deposit, guarantee insurance, capitalization products, and income-proof requirements before counting on a neighborhood.'**
  String get housingDecisionGuaranteesBody;

  /// No description provided for @housingDecisionSoftLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'A softer landing avoids expensive mistakes'**
  String get housingDecisionSoftLandingTitle;

  /// No description provided for @housingDecisionSoftLandingBody.
  ///
  /// In en, this message translates to:
  /// **'Temporary, furnished, coliving, or short contracts for 30 to 90 days are usually safer than taking a long lease before you understand the local routine.'**
  String get housingDecisionSoftLandingBody;

  /// No description provided for @housingDecisionProofPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Carry the folder that unlocks the conversation'**
  String get housingDecisionProofPackTitle;

  /// No description provided for @housingDecisionProofPackBody.
  ///
  /// In en, this message translates to:
  /// **'Keep identity, income, cash reserve, references, and digital proof in one folder. It does not guarantee approval, but it reduces friction from the first contact.'**
  String get housingDecisionProofPackBody;

  /// No description provided for @housingDecisionCityReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Read the city through housing pressure'**
  String get housingDecisionCityReadTitle;

  /// No description provided for @housingDecisionCityReadTitleWithCity.
  ///
  /// In en, this message translates to:
  /// **'Read {city} through housing pressure'**
  String housingDecisionCityReadTitleWithCity(Object city);

  /// No description provided for @housingDecisionCityReadBody.
  ///
  /// In en, this message translates to:
  /// **'Do not compare only average rent. Look at neighborhoods, transport, nearby services, furniture needs, commute distance, and cash margin for deposit and surprises.'**
  String get housingDecisionCityReadBody;

  /// No description provided for @housingDecisionCityReadBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'In {city}, compare neighborhoods, transport, nearby services, furniture needs, and cash margin for deposit and surprises before treating housing as solved.'**
  String housingDecisionCityReadBodyWithCity(Object city);

  /// No description provided for @housingDecisionSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Movaro currently organizes the context to help you decide better. Contract terms, accepted guarantees, and each landlord’s or platform’s policy still need to be validated at the source before signing for housing.'**
  String get housingDecisionSectionNote;

  /// No description provided for @housingEntrySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated housing entry cost'**
  String get housingEntrySectionTitle;

  /// No description provided for @housingEntrySectionTitleWithCity.
  ///
  /// In en, this message translates to:
  /// **'What housing may require upfront in {city}'**
  String housingEntrySectionTitleWithCity(Object city);

  /// No description provided for @housingEntrySectionBody.
  ///
  /// In en, this message translates to:
  /// **'Rent that looks affordable in the listing can demand much more upfront. Use this view to simulate a deposit, guarantee insurance, or a temporary landing before deciding on the city.'**
  String get housingEntrySectionBody;

  /// No description provided for @housingEntrySectionBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'In {city}, do not look only at monthly rent. Use this view to estimate what upfront entry may require with a deposit, guarantee insurance, or a temporary landing.'**
  String housingEntrySectionBodyWithCity(Object city);

  /// No description provided for @housingEntryRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference monthly rent: {amount}'**
  String housingEntryRentLabel(Object amount);

  /// No description provided for @housingEntryModeDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get housingEntryModeDeposit;

  /// No description provided for @housingEntryModeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Guarantee insurance'**
  String get housingEntryModeInsurance;

  /// No description provided for @housingEntryModeTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get housingEntryModeTemporary;

  /// No description provided for @housingEntryModeDepositBody.
  ///
  /// In en, this message translates to:
  /// **'Typical scenario when the lease requires roughly 3 months of deposit plus the first month.'**
  String get housingEntryModeDepositBody;

  /// No description provided for @housingEntryModeInsuranceBody.
  ///
  /// In en, this message translates to:
  /// **'Typical scenario when a guarantor is replaced by an annual insurance or digital guarantee fee.'**
  String get housingEntryModeInsuranceBody;

  /// No description provided for @housingEntryModeTemporaryBody.
  ///
  /// In en, this message translates to:
  /// **'A lighter scenario for the first 30 to 90 days, prioritizing flexibility before taking a long lease.'**
  String get housingEntryModeTemporaryBody;

  /// No description provided for @housingEntryTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'What upfront entry may cost'**
  String get housingEntryTotalTitle;

  /// No description provided for @housingEntryFirstMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'First month'**
  String get housingEntryFirstMonthLabel;

  /// No description provided for @housingEntryGuaranteeLabel.
  ///
  /// In en, this message translates to:
  /// **'Guarantee / deposit'**
  String get housingEntryGuaranteeLabel;

  /// No description provided for @housingEntrySetupLabel.
  ///
  /// In en, this message translates to:
  /// **'Fees and setup'**
  String get housingEntrySetupLabel;

  /// No description provided for @housingEntryPlatformsTitle.
  ///
  /// In en, this message translates to:
  /// **'Platforms and useful paths'**
  String get housingEntryPlatformsTitle;

  /// No description provided for @housingEntryPlatformsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Use the right channel for your current risk level'**
  String get housingEntryPlatformsHeadline;

  /// No description provided for @housingEntryPlatformsBody.
  ///
  /// In en, this message translates to:
  /// **'The best platform depends less on the pretty listing and more on the bureaucracy you can actually support right now.'**
  String get housingEntryPlatformsBody;

  /// No description provided for @housingEntryPlatformsQuintoAndar.
  ///
  /// In en, this message translates to:
  /// **'Digital and without a guarantor, but it still expects consistent income and documentation.'**
  String get housingEntryPlatformsQuintoAndar;

  /// No description provided for @housingEntryPlatformsZap.
  ///
  /// In en, this message translates to:
  /// **'Use filters like rent without guarantor to cut wasted search time.'**
  String get housingEntryPlatformsZap;

  /// No description provided for @housingEntryPlatformsCredPago.
  ///
  /// In en, this message translates to:
  /// **'A digital guarantee accepted by many agencies as a guarantor substitute.'**
  String get housingEntryPlatformsCredPago;

  /// No description provided for @housingEntryPlatformsAirbnb.
  ///
  /// In en, this message translates to:
  /// **'Useful for the first 15 to 30 days while you visit neighborhoods before taking a longer lease.'**
  String get housingEntryPlatformsAirbnb;

  /// No description provided for @housingEntryDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This simulation is directional. Real numbers vary by city, neighborhood, platform, income proof, and landlord policy. The goal is to avoid underestimating the upfront cost.'**
  String get housingEntryDisclaimer;

  /// No description provided for @housingSoftLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'How Argentinians usually land before a fixed lease'**
  String get housingSoftLandingTitle;

  /// No description provided for @housingSoftLandingBody.
  ///
  /// In en, this message translates to:
  /// **'In the first days, the common path is not going straight into a traditional lease. The sequence is usually landing, temporary housing, and only then the search for a more stable base with less risk.'**
  String get housingSoftLandingBody;

  /// No description provided for @housingSoftLandingTemporaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Land through short stay or a serviced flat'**
  String get housingSoftLandingTemporaryTitle;

  /// No description provided for @housingSoftLandingTemporaryBody.
  ///
  /// In en, this message translates to:
  /// **'Monthly Airbnb deals, serviced apartments, and flats help you land without a guarantor or local income proof. That buys time to visit neighborhoods and understand the city in practice.'**
  String get housingSoftLandingTemporaryBody;

  /// No description provided for @housingSoftLandingDirectTitle.
  ///
  /// In en, this message translates to:
  /// **'Search directly with owners or local groups'**
  String get housingSoftLandingDirectTitle;

  /// No description provided for @housingSoftLandingDirectBody.
  ///
  /// In en, this message translates to:
  /// **'Facebook Marketplace, OLX, and direct contacts are often more flexible than a traditional agency. In exchange, scam risk rises and property validation needs to be stricter.'**
  String get housingSoftLandingDirectBody;

  /// No description provided for @housingSoftLandingGuaranteeTitle.
  ///
  /// In en, this message translates to:
  /// **'The exchange currency is the guarantee'**
  String get housingSoftLandingGuaranteeTitle;

  /// No description provided for @housingSoftLandingGuaranteeBody.
  ///
  /// In en, this message translates to:
  /// **'Without a guarantor, the strongest argument is usually a deposit, guarantee insurance, a capitalization title, or a few months paid upfront. The point is not to overpromise, but to arrive with a credible structure.'**
  String get housingSoftLandingGuaranteeBody;

  /// No description provided for @housingSoftLandingSurvivalTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrival survival checklist'**
  String get housingSoftLandingSurvivalTitle;

  /// No description provided for @housingSoftLandingSurvivalChip.
  ///
  /// In en, this message translates to:
  /// **'Buy a Brazilian SIM early. Without a local number, agencies and landlords tend to reply less.'**
  String get housingSoftLandingSurvivalChip;

  /// No description provided for @housingSoftLandingSurvivalCpf.
  ///
  /// In en, this message translates to:
  /// **'If CPF is not solved yet, treat it as a priority. It matters for platforms, banking, and rental conversations.'**
  String get housingSoftLandingSurvivalCpf;

  /// No description provided for @housingSoftLandingSurvivalLocation.
  ///
  /// In en, this message translates to:
  /// **'In the first days, prioritize staying near groceries, pharmacies, transport, and a health post to reduce cost and friction.'**
  String get housingSoftLandingSurvivalLocation;

  /// No description provided for @housingSoftLandingSurvivalScam.
  ///
  /// In en, this message translates to:
  /// **'Do not send a reservation deposit without visiting the property or having someone you trust verify it locally.'**
  String get housingSoftLandingSurvivalScam;

  /// No description provided for @landingBudgetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested landing budget'**
  String get landingBudgetSectionTitle;

  /// No description provided for @landingBudgetSectionTitleWithCity.
  ///
  /// In en, this message translates to:
  /// **'Suggested landing budget for {city}'**
  String landingBudgetSectionTitleWithCity(String city);

  /// No description provided for @landingBudgetSummaryResearching.
  ///
  /// In en, this message translates to:
  /// **'Use this as a directional reserve reference so your move is not designed only around monthly cost after everything is already stable.'**
  String get landingBudgetSummaryResearching;

  /// No description provided for @landingBudgetSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'With more time, the goal is to build a realistic reserve and reduce the shock of setup costs before the move gets close.'**
  String get landingBudgetSummaryTwelveMonths;

  /// No description provided for @landingBudgetSummarySixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six months is enough to turn the move into a budgeted plan instead of a sequence of reactive expenses.'**
  String get landingBudgetSummarySixMonths;

  /// No description provided for @landingBudgetSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'Since the move is close, your reserve matters as much as the city choice. Use this estimate to avoid arriving with too little runway.'**
  String get landingBudgetSummaryAsap;

  /// No description provided for @landingBudgetLeanTitle.
  ///
  /// In en, this message translates to:
  /// **'Lean'**
  String get landingBudgetLeanTitle;

  /// No description provided for @landingBudgetLeanBody.
  ///
  /// In en, this message translates to:
  /// **'Useful if you plan to arrive with stricter spending, simpler housing expectations, and tighter early decisions.'**
  String get landingBudgetLeanBody;

  /// No description provided for @landingBudgetBalancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get landingBudgetBalancedTitle;

  /// No description provided for @landingBudgetBalancedBody.
  ///
  /// In en, this message translates to:
  /// **'A middle-ground view for someone trying to reduce stress without assuming a premium setup from day one.'**
  String get landingBudgetBalancedBody;

  /// No description provided for @landingBudgetComfortableTitle.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get landingBudgetComfortableTitle;

  /// No description provided for @landingBudgetComfortableBody.
  ///
  /// In en, this message translates to:
  /// **'A safer cushion if you want more margin for housing friction, slower adaptation, or unexpected setup costs.'**
  String get landingBudgetComfortableBody;

  /// No description provided for @landingBudget30DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference for the first 30 days'**
  String get landingBudget30DaysLabel;

  /// No description provided for @landingBudgetMonthlyBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly base'**
  String get landingBudgetMonthlyBaseLabel;

  /// No description provided for @landingBudgetSetupLabel.
  ///
  /// In en, this message translates to:
  /// **'Setup and installation'**
  String get landingBudgetSetupLabel;

  /// No description provided for @landingBudgetBufferLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety buffer'**
  String get landingBudgetBufferLabel;

  /// No description provided for @landingBudget90DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'If you want a 90-day runway, use around {amount}'**
  String landingBudget90DaysLabel(String amount);

  /// No description provided for @landingBudgetDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These estimates are directional, not official prices. They combine city signals, setup pressure, and timeline risk to help you plan your reserve before the move.'**
  String get landingBudgetDisclaimer;

  /// No description provided for @landingBudgetExchangeUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Official exchange rate updated at {value}'**
  String landingBudgetExchangeUpdatedAt(Object value);

  /// No description provided for @landingBudgetExchangeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The official exchange rate could not be updated right now. BRL values remain as the reference.'**
  String get landingBudgetExchangeUnavailable;

  /// No description provided for @arrivalExecutionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'First 7 / 30 / 90 days'**
  String get arrivalExecutionSectionTitle;

  /// No description provided for @arrivalExecutionStageWeek.
  ///
  /// In en, this message translates to:
  /// **'First 7 days'**
  String get arrivalExecutionStageWeek;

  /// No description provided for @arrivalExecutionStageMonth.
  ///
  /// In en, this message translates to:
  /// **'First 30 days'**
  String get arrivalExecutionStageMonth;

  /// No description provided for @arrivalExecutionStageQuarter.
  ///
  /// In en, this message translates to:
  /// **'First 90 days'**
  String get arrivalExecutionStageQuarter;

  /// No description provided for @arrivalExecutionSummaryResearching.
  ///
  /// In en, this message translates to:
  /// **'This is the execution layer after arrival. Use it now to understand what the first weeks will require beyond paperwork.'**
  String get arrivalExecutionSummaryResearching;

  /// No description provided for @arrivalExecutionSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'With more time, this layer helps you picture what settling in will demand so the move is not planned only around paperwork and budget.'**
  String get arrivalExecutionSummaryTwelveMonths;

  /// No description provided for @arrivalExecutionSummarySixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six months is enough to plan arrival as an operational sequence, not just as a destination decision.'**
  String get arrivalExecutionSummarySixMonths;

  /// No description provided for @arrivalExecutionSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'If arrival is close, this 7 / 30 / 90-day layer matters now. It is where daily friction usually appears first.'**
  String get arrivalExecutionSummaryAsap;

  /// No description provided for @arrivalExecutionConnectivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve connectivity on day one'**
  String get arrivalExecutionConnectivityTitle;

  /// No description provided for @arrivalExecutionConnectivityBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a local SIM, mobile data, and the minimum digital setup needed for maps, banking, and document follow-up.'**
  String get arrivalExecutionConnectivityBody;

  /// No description provided for @arrivalExecutionTransportTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn your first transport routine'**
  String get arrivalExecutionTransportTitle;

  /// No description provided for @arrivalExecutionTransportBody.
  ///
  /// In en, this message translates to:
  /// **'Map how you will move in the first week so housing, services, and bureaucracy do not depend on improvisation.'**
  String get arrivalExecutionTransportBody;

  /// No description provided for @arrivalExecutionTransportBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Map how you will move through {city} in the first week so housing, services, and bureaucracy do not depend on improvisation.'**
  String arrivalExecutionTransportBodyWithCity(String city);

  /// No description provided for @arrivalExecutionHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your first health fallback'**
  String get arrivalExecutionHealthTitle;

  /// No description provided for @arrivalExecutionHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Know where your first public or private health access point is so a routine issue does not become chaos on arrival.'**
  String get arrivalExecutionHealthBody;

  /// No description provided for @arrivalExecutionBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Stabilize payments and banking flow'**
  String get arrivalExecutionBankTitle;

  /// No description provided for @arrivalExecutionBankBody.
  ///
  /// In en, this message translates to:
  /// **'Make sure your first local payment flow works: account, Pix, card use, and how you will move money in the first month.'**
  String get arrivalExecutionBankBody;

  /// No description provided for @arrivalExecutionHousingTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn housing into routine, not just entry'**
  String get arrivalExecutionHousingTitle;

  /// No description provided for @arrivalExecutionHousingBody.
  ///
  /// In en, this message translates to:
  /// **'After arriving, confirm whether the chosen area really supports work, transport, safety, and the pace of daily life you need.'**
  String get arrivalExecutionHousingBody;

  /// No description provided for @arrivalExecutionGoalWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into employability'**
  String get arrivalExecutionGoalWorkTitle;

  /// No description provided for @arrivalExecutionGoalWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to test how documents, language, and city actually affect your chances of getting work.'**
  String get arrivalExecutionGoalWorkBody;

  /// No description provided for @arrivalExecutionGoalRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into a stable remote base'**
  String get arrivalExecutionGoalRemoteTitle;

  /// No description provided for @arrivalExecutionGoalRemoteBody.
  ///
  /// In en, this message translates to:
  /// **'Validate internet reliability, a quiet routine, banking flow, and the real cost of maintaining remote work from the new city.'**
  String get arrivalExecutionGoalRemoteBody;

  /// No description provided for @arrivalExecutionGoalStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into a study routine'**
  String get arrivalExecutionGoalStudyTitle;

  /// No description provided for @arrivalExecutionGoalStudyBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to confirm whether enrollment, commute, classes, and daily costs still support study as the base plan.'**
  String get arrivalExecutionGoalStudyBody;

  /// No description provided for @arrivalExecutionGoalEntrepreneurTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into operating capacity'**
  String get arrivalExecutionGoalEntrepreneurTitle;

  /// No description provided for @arrivalExecutionGoalEntrepreneurBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to validate whether banking, documents, local routine, and city context actually support operating safely.'**
  String get arrivalExecutionGoalEntrepreneurBody;

  /// No description provided for @arrivalExecutionGoalRetireTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into a predictable routine'**
  String get arrivalExecutionGoalRetireTitle;

  /// No description provided for @arrivalExecutionGoalRetireBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to test whether health access, neighborhood routine, and recurring costs feel sustainable in practice.'**
  String get arrivalExecutionGoalRetireBody;

  /// No description provided for @arrivalExecutionGoalQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into real quality of life'**
  String get arrivalExecutionGoalQualityTitle;

  /// No description provided for @arrivalExecutionGoalQualityBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to verify whether the city feels right in daily life, not only on paper or in rankings.'**
  String get arrivalExecutionGoalQualityBody;

  /// No description provided for @arrivalExecutionRealityCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Do a reality check at 90 days'**
  String get arrivalExecutionRealityCheckTitle;

  /// No description provided for @arrivalExecutionRealityCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Compare your real costs, routine friction, and city fit against what the plan suggested. This is where the move stops being hypothetical.'**
  String get arrivalExecutionRealityCheckBody;

  /// No description provided for @arrivalExecutionDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the document loose ends'**
  String get arrivalExecutionDocumentsTitle;

  /// No description provided for @arrivalExecutionDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'By the first 90 days, reduce pending follow-up on residency, proof, banking, and any local records still blocking stability.'**
  String get arrivalExecutionDocumentsBody;

  /// No description provided for @arrivalExecutionReplanTitle.
  ///
  /// In en, this message translates to:
  /// **'Replan before inertia takes over'**
  String get arrivalExecutionReplanTitle;

  /// No description provided for @arrivalExecutionReplanBody.
  ///
  /// In en, this message translates to:
  /// **'If the city, cost, or pace is not matching the original plan, adjust direction before temporary friction becomes your default.'**
  String get arrivalExecutionReplanBody;

  /// No description provided for @arrivalExecutionReplanBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'If {city} is not matching the original plan in practice, adjust direction before temporary friction becomes your default.'**
  String arrivalExecutionReplanBodyWithCity(String city);

  /// No description provided for @publicHomeResumePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Continue my plan'**
  String get publicHomeResumePlanAction;

  /// No description provided for @publicHomeResumePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get publicHomeResumePlanTitle;

  /// No description provided for @publicHomeResumePlanBody.
  ///
  /// In en, this message translates to:
  /// **'Your last migration plan is still here. Reopen it to continue the checklist, document readiness, and landing budget.'**
  String get publicHomeResumePlanBody;

  /// No description provided for @publicHomeResumePlanBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Your last plan is still here, with {city} ({state}) as the current lead city. Reopen it to continue the checklist, document readiness, and landing budget.'**
  String publicHomeResumePlanBodyWithCity(String city, String state);

  /// No description provided for @publicHomeRetakePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Rebuild plan'**
  String get publicHomeRetakePlanAction;

  /// No description provided for @migrationPlanCopilotTitle.
  ///
  /// In en, this message translates to:
  /// **'Move guide'**
  String get migrationPlanCopilotTitle;

  /// No description provided for @migrationPlanCopilotAction.
  ///
  /// In en, this message translates to:
  /// **'Open guide'**
  String get migrationPlanCopilotAction;

  /// No description provided for @migrationPlanCopilotGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get migrationPlanCopilotGuideEyebrow;

  /// No description provided for @migrationPlanCopilotGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use the move guide'**
  String get migrationPlanCopilotGuideTitle;

  /// No description provided for @migrationPlanCopilotGuideBody.
  ///
  /// In en, this message translates to:
  /// **'This area turns your chosen city into practical preparation. Open the right stage, resolve the current priority, and return to the overview without losing the order of the plan.'**
  String get migrationPlanCopilotGuideBody;

  /// No description provided for @migrationPlanCopilotGuideStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Start from the overview'**
  String get migrationPlanCopilotGuideStepOneTitle;

  /// No description provided for @migrationPlanCopilotGuideStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'The overview shows the most important stage right now and helps you avoid spreading your energy.'**
  String get migrationPlanCopilotGuideStepOneBody;

  /// No description provided for @migrationPlanCopilotGuideStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the priority stage'**
  String get migrationPlanCopilotGuideStepTwoTitle;

  /// No description provided for @migrationPlanCopilotGuideStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Documents, housing, work, and arrival are split so you can solve one block at a time.'**
  String get migrationPlanCopilotGuideStepTwoBody;

  /// No description provided for @migrationPlanCopilotGuideStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the practical shortcuts'**
  String get migrationPlanCopilotGuideStepThreeTitle;

  /// No description provided for @migrationPlanCopilotGuideStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Open links, sources, and guided blocks inside the app to move from planning into execution.'**
  String get migrationPlanCopilotGuideStepThreeBody;

  /// No description provided for @migrationPlanCopilotGuideHideNextTime.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get migrationPlanCopilotGuideHideNextTime;

  /// No description provided for @migrationPlanCopilotGuideStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 steps'**
  String get migrationPlanCopilotGuideStepsLabel;

  /// No description provided for @migrationPlanCopilotGuideDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get migrationPlanCopilotGuideDismissAction;

  /// No description provided for @migrationPlanCopilotGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get migrationPlanCopilotGuidePrimaryAction;

  /// No description provided for @migrationPlanCopilotIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'When you want to move from decision to execution'**
  String get migrationPlanCopilotIntroTitle;

  /// No description provided for @migrationPlanCopilotIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This stage organizes your checklist, documents, housing, and landing reserve. Use it when you are ready to start preparing the move.'**
  String get migrationPlanCopilotIntroBody;

  /// No description provided for @migrationPlanCopilotIntroBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'This stage organizes your checklist, documents, housing, and landing reserve with {city} ({state}) as the main reference in your plan.'**
  String migrationPlanCopilotIntroBodyWithCity(String city, String state);

  /// No description provided for @migrationPlanCopilotResultBody.
  ///
  /// In en, this message translates to:
  /// **'First, check whether the recommended city really fits your context. When you want to turn that decision into concrete preparation, open the guided layer with a checklist, documents, and an arrival reserve.'**
  String get migrationPlanCopilotResultBody;

  /// No description provided for @migrationPlanCopilotStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String migrationPlanCopilotStepCounter(Object current, Object total);

  /// No description provided for @migrationPlanCopilotStepStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with what unlocks the move'**
  String get migrationPlanCopilotStepStartTitle;

  /// No description provided for @migrationPlanCopilotStepStartBody.
  ///
  /// In en, this message translates to:
  /// **'Focus first on the checks that reduce risk before you spend more energy on details.'**
  String get migrationPlanCopilotStepStartBody;

  /// No description provided for @migrationPlanCopilotStepDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get the key documents in order'**
  String get migrationPlanCopilotStepDocumentsTitle;

  /// No description provided for @migrationPlanCopilotStepDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'Use this step to organize the document layer that usually blocks progress later.'**
  String get migrationPlanCopilotStepDocumentsBody;

  /// No description provided for @migrationPlanCopilotStepBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan reserve and housing entry'**
  String get migrationPlanCopilotStepBudgetTitle;

  /// No description provided for @migrationPlanCopilotStepBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Estimate your first reserve and review the housing friction before arrival turns urgent.'**
  String get migrationPlanCopilotStepBudgetBody;

  /// No description provided for @migrationPlanCopilotStepArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the first 7 / 30 / 90 days'**
  String get migrationPlanCopilotStepArrivalTitle;

  /// No description provided for @migrationPlanCopilotStepArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'Turn the plan into execution so arrival does not depend on improvisation.'**
  String get migrationPlanCopilotStepArrivalBody;

  /// No description provided for @migrationPlanCopilotHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do now'**
  String get migrationPlanCopilotHomeTitle;

  /// No description provided for @migrationPlanCopilotHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Use this home to see the next actions, the main risk, and the stage that deserves attention first.'**
  String get migrationPlanCopilotHomeBody;

  /// No description provided for @migrationPlanCopilotStageCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} guided stages'**
  String migrationPlanCopilotStageCountLabel(Object count);

  /// No description provided for @migrationPlanCopilotNextActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next 3 actions'**
  String get migrationPlanCopilotNextActionsTitle;

  /// No description provided for @migrationPlanCopilotNextActionsBody.
  ///
  /// In en, this message translates to:
  /// **'Start with the tasks that unlock the move before you go deeper.'**
  String get migrationPlanCopilotNextActionsBody;

  /// No description provided for @migrationPlanCopilotNextActionStart.
  ///
  /// In en, this message translates to:
  /// **'Reduce the first blockers'**
  String get migrationPlanCopilotNextActionStart;

  /// No description provided for @migrationPlanCopilotNextActionDocuments.
  ///
  /// In en, this message translates to:
  /// **'Put documents in motion'**
  String get migrationPlanCopilotNextActionDocuments;

  /// No description provided for @migrationPlanCopilotNextActionBudget.
  ///
  /// In en, this message translates to:
  /// **'Review reserve and housing entry'**
  String get migrationPlanCopilotNextActionBudget;

  /// No description provided for @migrationPlanCopilotNextActionBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Estimate your first reserve and understand how housing entry may weigh on arrival.'**
  String get migrationPlanCopilotNextActionBudgetBody;

  /// No description provided for @migrationPlanCopilotFallbackActionBody.
  ///
  /// In en, this message translates to:
  /// **'Open this stage to see the first recommended action.'**
  String get migrationPlanCopilotFallbackActionBody;

  /// No description provided for @migrationPlanCopilotRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Main risk now'**
  String get migrationPlanCopilotRiskTitle;

  /// No description provided for @migrationPlanCopilotRiskDocuments.
  ///
  /// In en, this message translates to:
  /// **'The document layer is still the biggest risk. If it stays loose, later steps may feel blocked even with city and budget already decided.'**
  String get migrationPlanCopilotRiskDocuments;

  /// No description provided for @migrationPlanCopilotRiskReadiness.
  ///
  /// In en, this message translates to:
  /// **'The move still needs a stronger starting base. Resolve the first practical blockers before investing more energy in details.'**
  String get migrationPlanCopilotRiskReadiness;

  /// No description provided for @migrationPlanCopilotRiskHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing entry can still create friction on arrival. Review reserve, guarantees, and fallback strategy before treating the move as operational.'**
  String get migrationPlanCopilotRiskHousing;

  /// No description provided for @migrationPlanCopilotStagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a guided stage'**
  String get migrationPlanCopilotStagesTitle;

  /// No description provided for @migrationPlanCopilotStagesBody.
  ///
  /// In en, this message translates to:
  /// **'You can jump directly to the stage you need, but Movaro keeps the order clear so the move does not lose priority.'**
  String get migrationPlanCopilotStagesBody;

  /// No description provided for @migrationPlanCopilotRecommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended next step'**
  String get migrationPlanCopilotRecommendedTitle;

  /// No description provided for @migrationPlanCopilotRecommendedReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Start with this stage to remove the first blockers and give the rest of the plan a stronger base.'**
  String get migrationPlanCopilotRecommendedReadinessBody;

  /// No description provided for @migrationPlanCopilotRecommendedDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'The document layer still deserves attention first. Resolve it now to avoid more expensive blockers later.'**
  String get migrationPlanCopilotRecommendedDocumentsBody;

  /// No description provided for @migrationPlanCopilotRecommendedBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Now it is worth turning the plan into real numbers and reviewing housing entry before arrival gets tight.'**
  String get migrationPlanCopilotRecommendedBudgetBody;

  /// No description provided for @migrationPlanCopilotRecommendedArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'You already have enough base to organize the arrival. Use this stage to move from plan to execution.'**
  String get migrationPlanCopilotRecommendedArrivalBody;

  /// No description provided for @migrationPlanCopilotRecommendedOpen.
  ///
  /// In en, this message translates to:
  /// **'Open recommended stage'**
  String get migrationPlanCopilotRecommendedOpen;

  /// No description provided for @migrationPlanCopilotQuickQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick questions'**
  String get migrationPlanCopilotQuickQuestionsTitle;

  /// No description provided for @migrationPlanCopilotQuickQuestionsBody.
  ///
  /// In en, this message translates to:
  /// **'Use these short answers when a practical doubt shows up before you move forward.'**
  String get migrationPlanCopilotQuickQuestionsBody;

  /// No description provided for @migrationPlanCopilotQuickQuestionDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which documents should I move first?'**
  String get migrationPlanCopilotQuickQuestionDocumentsTitle;

  /// No description provided for @migrationPlanCopilotQuickQuestionDocumentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Start with the documents that take longer to obtain or expire sooner. The document stage helps you separate what unlocks residence, CPF, and practical arrival without pushing you into a full bureaucratic flow all at once.'**
  String get migrationPlanCopilotQuickQuestionDocumentsAnswer;

  /// No description provided for @migrationPlanCopilotQuickQuestionHousingTitle.
  ///
  /// In en, this message translates to:
  /// **'Do I need to solve permanent housing now?'**
  String get migrationPlanCopilotQuickQuestionHousingTitle;

  /// No description provided for @migrationPlanCopilotQuickQuestionHousingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not always. In many cases, it is better to start with a temporary housing plan, understand guarantees, and only then commit to a larger rental. What matters now is estimating your reserve, entry costs, and fallback plan.'**
  String get migrationPlanCopilotQuickQuestionHousingAnswer;

  /// No description provided for @migrationPlanCopilotQuickQuestionArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I solve right after arrival?'**
  String get migrationPlanCopilotQuickQuestionArrivalTitle;

  /// No description provided for @migrationPlanCopilotQuickQuestionArrivalAnswer.
  ///
  /// In en, this message translates to:
  /// **'Think first about what reduces friction in the first days: where to stay, how to move around, what must be solved in the first 7 days, and which tasks cannot slip past the first month. The arrival stage already organizes this by priority.'**
  String get migrationPlanCopilotQuickQuestionArrivalAnswer;

  /// No description provided for @migrationPlanCopilotQuickQuestionOpenStage.
  ///
  /// In en, this message translates to:
  /// **'Go to this stage'**
  String get migrationPlanCopilotQuickQuestionOpenStage;

  /// No description provided for @migrationPlanCopilotActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Resolve now'**
  String get migrationPlanCopilotActionOpen;

  /// No description provided for @migrationPlanCopilotOverviewAction.
  ///
  /// In en, this message translates to:
  /// **'Start guided preparation'**
  String get migrationPlanCopilotOverviewAction;

  /// No description provided for @migrationPlanCopilotOverviewBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back to overview'**
  String get migrationPlanCopilotOverviewBackAction;

  /// No description provided for @migrationPlanCopilotFinishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish for now'**
  String get migrationPlanCopilotFinishAction;

  /// No description provided for @migrationPlanDecisionLabel.
  ///
  /// In en, this message translates to:
  /// **'City choice'**
  String get migrationPlanDecisionLabel;

  /// No description provided for @migrationPlanDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Now compare the cities that best match {goal}'**
  String migrationPlanDecisionTitle(Object goal);

  /// No description provided for @migrationPlanDecisionBody.
  ///
  /// In en, this message translates to:
  /// **'Based on your {timeline} horizon, these options come first because they are closer to the profile you selected.'**
  String migrationPlanDecisionBody(Object timeline);

  /// No description provided for @migrationPlanDecisionSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use this step'**
  String get migrationPlanDecisionSummaryTitle;

  /// No description provided for @migrationPlanDecisionSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the city that makes the most sense first. The detailed checklist only comes after that decision.'**
  String get migrationPlanDecisionSummaryBody;

  /// No description provided for @migrationPlanHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'{city} is your strongest starting city for now'**
  String migrationPlanHeroTitle(Object city);

  /// No description provided for @migrationPlanHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Based on your {timeline} horizon, start by reviewing the 3 cities below and open the one that feels strongest for your move.'**
  String migrationPlanHeroBody(Object timeline);

  /// No description provided for @migrationPlanConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Initial recommendation'**
  String get migrationPlanConfidenceLow;

  /// No description provided for @migrationPlanConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'Strong recommendation'**
  String get migrationPlanConfidenceHigh;

  /// No description provided for @migrationPlanSummaryArchetype.
  ///
  /// In en, this message translates to:
  /// **'Detected profile: {value}'**
  String migrationPlanSummaryArchetype(Object value);

  /// No description provided for @migrationPlanSummaryVariant.
  ///
  /// In en, this message translates to:
  /// **'Mode used: {value}'**
  String migrationPlanSummaryVariant(Object value);

  /// No description provided for @migrationPlanSummaryFunding.
  ///
  /// In en, this message translates to:
  /// **'Initial support: {value}'**
  String migrationPlanSummaryFunding(Object value);

  /// No description provided for @migrationPlanCandidateCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cities more aligned with your profile'**
  String get migrationPlanCandidateCitiesTitle;

  /// No description provided for @migrationPlanCandidateCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'The list is already ordered to keep first what tends to make more sense for Argentinians with this goal.'**
  String get migrationPlanCandidateCitiesBody;

  /// No description provided for @migrationPlanShortlistTitle.
  ///
  /// In en, this message translates to:
  /// **'3 cities to review now'**
  String get migrationPlanShortlistTitle;

  /// No description provided for @migrationPlanShortlistBody.
  ///
  /// In en, this message translates to:
  /// **'These are the 3 strongest starting options right now. Open one city to compare it with your move context.'**
  String get migrationPlanShortlistBody;

  /// No description provided for @migrationPlanCandidateCitiesSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Open the details to understand each city better. City confirmation happens inside the detail screen, after you see more context.'**
  String get migrationPlanCandidateCitiesSheetBody;

  /// No description provided for @migrationPlanSelectedCityBadge.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get migrationPlanSelectedCityBadge;

  /// No description provided for @migrationPlanSuggestedCityBadge.
  ///
  /// In en, this message translates to:
  /// **'Leading now'**
  String get migrationPlanSuggestedCityBadge;

  /// No description provided for @migrationPlanChooseCityAction.
  ///
  /// In en, this message translates to:
  /// **'Choose this city'**
  String get migrationPlanChooseCityAction;

  /// No description provided for @migrationPlanSelectedCityAction.
  ///
  /// In en, this message translates to:
  /// **'City selected'**
  String get migrationPlanSelectedCityAction;

  /// No description provided for @migrationPlanInspectCityAction.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get migrationPlanInspectCityAction;

  /// No description provided for @migrationPlanOpenCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'See suggested cities'**
  String get migrationPlanOpenCitiesAction;

  /// No description provided for @migrationPlanCompareOtherCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'Compare other cities'**
  String get migrationPlanCompareOtherCitiesAction;

  /// No description provided for @migrationPlanSuggestedCityTitle.
  ///
  /// In en, this message translates to:
  /// **'{city} is leading for now'**
  String migrationPlanSuggestedCityTitle(Object city);

  /// No description provided for @migrationPlanSuggestedCityBody.
  ///
  /// In en, this message translates to:
  /// **'{city} is currently leading for the profile you chose, with a housing-entry read of {housing}. Before deciding, open the details and compare it with the other options.'**
  String migrationPlanSuggestedCityBody(Object city, Object housing);

  /// No description provided for @migrationPlanConfirmedCityTitle.
  ///
  /// In en, this message translates to:
  /// **'{city} is the city you selected'**
  String migrationPlanConfirmedCityTitle(Object city);

  /// No description provided for @migrationPlanSelectedCityTitle.
  ///
  /// In en, this message translates to:
  /// **'{city} is leading for now'**
  String migrationPlanSelectedCityTitle(Object city);

  /// No description provided for @migrationPlanSelectedCityBody.
  ///
  /// In en, this message translates to:
  /// **'{city} stands out for your current context, with a housing-entry read of {housing}. If this city feels right, then it makes sense to open the guided preparation.'**
  String migrationPlanSelectedCityBody(Object city, Object housing);

  /// No description provided for @migrationPlanPreparationTitle.
  ///
  /// In en, this message translates to:
  /// **'When to move into preparation'**
  String get migrationPlanPreparationTitle;

  /// No description provided for @migrationPlanPreparationBody.
  ///
  /// In en, this message translates to:
  /// **'If you decide to move forward with {city}, guided preparation opens a checklist, documents, housing, and an arrival reserve focused on that city.'**
  String migrationPlanPreparationBody(Object city);

  /// No description provided for @migrationPlanResultPrimaryCtaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get migrationPlanResultPrimaryCtaEyebrow;

  /// No description provided for @migrationPlanResultStartPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Start my plan'**
  String get migrationPlanResultStartPlanTitle;

  /// No description provided for @migrationPlanResultStartPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Review {city} with a little more context and confirm it when you are ready to unlock the full guided plan.'**
  String migrationPlanResultStartPlanBody(Object city);

  /// No description provided for @migrationPlanResultStartPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Start my plan'**
  String get migrationPlanResultStartPlanAction;

  /// No description provided for @migrationPlanResultOpenPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'View full plan'**
  String get migrationPlanResultOpenPlanTitle;

  /// No description provided for @migrationPlanResultOpenPlanAction.
  ///
  /// In en, this message translates to:
  /// **'View full plan'**
  String get migrationPlanResultOpenPlanAction;

  /// No description provided for @migrationPlanResultCompatibilityHigh.
  ///
  /// In en, this message translates to:
  /// **'High compatibility'**
  String get migrationPlanResultCompatibilityHigh;

  /// No description provided for @migrationPlanResultCompatibilityMedium.
  ///
  /// In en, this message translates to:
  /// **'Good compatibility'**
  String get migrationPlanResultCompatibilityMedium;

  /// No description provided for @migrationPlanResultCompatibilityInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial compatibility'**
  String get migrationPlanResultCompatibilityInitial;

  /// No description provided for @migrationPlanResultCompatibilityHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How compatibility works'**
  String get migrationPlanResultCompatibilityHelpTitle;

  /// No description provided for @migrationPlanResultCompatibilityHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Compatibility combines your priorities, timeline, and migration goal with the signals available for each city. It is a directional match to help you start with the strongest city first.'**
  String get migrationPlanResultCompatibilityHelpBody;

  /// No description provided for @migrationPlanResultUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not load your city result.'**
  String get migrationPlanResultUnavailableTitle;

  /// No description provided for @migrationPlanResultUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Try again to reopen your recommendation and continue from the quick questions.'**
  String get migrationPlanResultUnavailableBody;

  /// No description provided for @migrationPlanResultBasedOnAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers'**
  String get migrationPlanResultBasedOnAnswersTitle;

  /// No description provided for @migrationPlanResultCityDataTitle.
  ///
  /// In en, this message translates to:
  /// **'City data'**
  String get migrationPlanResultCityDataTitle;

  /// No description provided for @migrationPlanResultOtherCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Other compatible cities'**
  String get migrationPlanResultOtherCitiesTitle;

  /// No description provided for @migrationPlanResultReviewsMetricTitle.
  ///
  /// In en, this message translates to:
  /// **'Public reviews'**
  String get migrationPlanResultReviewsMetricTitle;

  /// No description provided for @migrationPlanResultSafetyMetricTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get migrationPlanResultSafetyMetricTitle;

  /// No description provided for @migrationPlanResultPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Start my plan in {city} ->'**
  String migrationPlanResultPrimaryAction(Object city);

  /// No description provided for @migrationPlanResultExploreDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Explore the city in detail'**
  String get migrationPlanResultExploreDetailsAction;

  /// No description provided for @migrationPlanResultReasonFromPriority.
  ///
  /// In en, this message translates to:
  /// **'You chose: {label}'**
  String migrationPlanResultReasonFromPriority(Object label);

  /// No description provided for @migrationPlanResultReasonBudget.
  ///
  /// In en, this message translates to:
  /// **'{city} keeps the entry cost more manageable, which helps you arrive with less pressure.'**
  String migrationPlanResultReasonBudget(Object city);

  /// No description provided for @migrationPlanResultReasonWork.
  ///
  /// In en, this message translates to:
  /// **'{city} shows a {signal} work signal, which gives you more room to move after arrival.'**
  String migrationPlanResultReasonWork(Object city, Object signal);

  /// No description provided for @migrationPlanResultReasonQuality.
  ///
  /// In en, this message translates to:
  /// **'{city} stands out with a {signal} quality-of-life signal, which supports a steadier day-to-day routine.'**
  String migrationPlanResultReasonQuality(Object city, Object signal);

  /// No description provided for @migrationPlanResultReasonClimate.
  ///
  /// In en, this message translates to:
  /// **'{city} aligns well with the lifestyle you signaled, with {signal}.'**
  String migrationPlanResultReasonClimate(Object city, Object signal);

  /// No description provided for @migrationPlanResultReasonTransit.
  ///
  /// In en, this message translates to:
  /// **'{city} gives you a more practical base if you need to move around the city often.'**
  String migrationPlanResultReasonTransit(Object city);

  /// No description provided for @migrationPlanResultReasonUniversity.
  ///
  /// In en, this message translates to:
  /// **'{city} keeps study and qualification paths closer if education is part of your plan.'**
  String migrationPlanResultReasonUniversity(Object city);

  /// No description provided for @migrationPlanResultReasonCommunity.
  ///
  /// In en, this message translates to:
  /// **'{city} has stronger adaptation signals for building routine and support once you arrive.'**
  String migrationPlanResultReasonCommunity(Object city);

  /// No description provided for @migrationPlanResultReasonProximity.
  ///
  /// In en, this message translates to:
  /// **'{city} keeps you on a route that feels easier to coordinate from Argentina.'**
  String migrationPlanResultReasonProximity(Object city);

  /// No description provided for @migrationPlanResultReasonBalanced.
  ///
  /// In en, this message translates to:
  /// **'{city} is the most balanced recommendation for your current profile across the available city signals.'**
  String migrationPlanResultReasonBalanced(Object city);

  /// No description provided for @migrationPlanResultWeatherPending.
  ///
  /// In en, this message translates to:
  /// **'Weather is updating'**
  String get migrationPlanResultWeatherPending;

  /// No description provided for @migrationPlanResultWeatherDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get migrationPlanResultWeatherDay;

  /// No description provided for @migrationPlanResultWeatherNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get migrationPlanResultWeatherNight;

  /// No description provided for @migrationPlanResultWeatherSunny.
  ///
  /// In en, this message translates to:
  /// **'sunny right now'**
  String get migrationPlanResultWeatherSunny;

  /// No description provided for @migrationPlanResultWeatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'more cloudy conditions'**
  String get migrationPlanResultWeatherCloudy;

  /// No description provided for @migrationPlanResultWeatherRain.
  ///
  /// In en, this message translates to:
  /// **'rain in the area'**
  String get migrationPlanResultWeatherRain;

  /// No description provided for @migrationPlanResultWeatherCold.
  ///
  /// In en, this message translates to:
  /// **'cooler conditions'**
  String get migrationPlanResultWeatherCold;

  /// No description provided for @migrationPlanResultWeatherStorm.
  ///
  /// In en, this message translates to:
  /// **'more unstable weather'**
  String get migrationPlanResultWeatherStorm;

  /// No description provided for @migrationPlanResultWeatherMild.
  ///
  /// In en, this message translates to:
  /// **'mild weather'**
  String get migrationPlanResultWeatherMild;

  /// No description provided for @migrationPlanResultWeatherClearNight.
  ///
  /// In en, this message translates to:
  /// **'clear night'**
  String get migrationPlanResultWeatherClearNight;

  /// No description provided for @migrationPlanResultCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get migrationPlanResultCostLabel;

  /// No description provided for @migrationPlanResultWeatherLabel.
  ///
  /// In en, this message translates to:
  /// **'Weather now'**
  String get migrationPlanResultWeatherLabel;

  /// No description provided for @migrationPlanResultWhyLabel.
  ///
  /// In en, this message translates to:
  /// **'Why this city'**
  String get migrationPlanResultWhyLabel;

  /// No description provided for @migrationPlanResultReviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String migrationPlanResultReviewsLabel(Object count);

  /// No description provided for @migrationPlanResultCostSupporting.
  ///
  /// In en, this message translates to:
  /// **'A directional read based on city cost and rent signals.'**
  String get migrationPlanResultCostSupporting;

  /// No description provided for @migrationPlanResultCostLower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get migrationPlanResultCostLower;

  /// No description provided for @migrationPlanResultCostMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get migrationPlanResultCostMedium;

  /// No description provided for @migrationPlanResultCostHigher.
  ///
  /// In en, this message translates to:
  /// **'Higher'**
  String get migrationPlanResultCostHigher;

  /// No description provided for @migrationPlanResultDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty level'**
  String get migrationPlanResultDifficultyLabel;

  /// No description provided for @migrationPlanResultDifficultySupporting.
  ///
  /// In en, this message translates to:
  /// **'How much coordination this plan may need before arrival.'**
  String get migrationPlanResultDifficultySupporting;

  /// No description provided for @migrationPlanResultDifficultyFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get migrationPlanResultDifficultyFocused;

  /// No description provided for @migrationPlanResultDifficultyModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get migrationPlanResultDifficultyModerate;

  /// No description provided for @migrationPlanResultDifficultyStructured.
  ///
  /// In en, this message translates to:
  /// **'Structured'**
  String get migrationPlanResultDifficultyStructured;

  /// No description provided for @migrationPlanResultTimelineLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated timeline'**
  String get migrationPlanResultTimelineLabel;

  /// No description provided for @migrationPlanResultTimelineValue.
  ///
  /// In en, this message translates to:
  /// **'~{days} days'**
  String migrationPlanResultTimelineValue(Object days);

  /// No description provided for @migrationPlanResultCitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this city is leading'**
  String get migrationPlanResultCitySectionTitle;

  /// No description provided for @migrationPlanResultCitySectionBody.
  ///
  /// In en, this message translates to:
  /// **'Open the city context when you want more detail, not before the main decision is clear.'**
  String get migrationPlanResultCitySectionBody;

  /// No description provided for @migrationPlanResultPlanSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens after this result'**
  String get migrationPlanResultPlanSectionTitle;

  /// No description provided for @migrationPlanResultPlanSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Preparation becomes useful only after the city choice feels strong enough to move forward.'**
  String get migrationPlanResultPlanSectionBody;

  /// No description provided for @migrationPlanCompareThreeCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'Compare the 3 cities'**
  String get migrationPlanCompareThreeCitiesAction;

  /// No description provided for @migrationPlanResultProgressSupporting.
  ///
  /// In en, this message translates to:
  /// **'Completed checklist items across the guided plan.'**
  String get migrationPlanResultProgressSupporting;

  /// No description provided for @migrationPlanCopilotProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checklist items completed'**
  String migrationPlanCopilotProgressValue(Object done, Object total);

  /// No description provided for @migrationPlanCopilotProgressHeader.
  ///
  /// In en, this message translates to:
  /// **'Stage {current} of {total} · {percent}% complete'**
  String migrationPlanCopilotProgressHeader(
    Object current,
    Object total,
    Object percent,
  );

  /// No description provided for @migrationPlanCopilotStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get migrationPlanCopilotStatusNotStarted;

  /// No description provided for @migrationPlanCopilotStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get migrationPlanCopilotStatusInProgress;

  /// No description provided for @migrationPlanCopilotStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get migrationPlanCopilotStatusDone;

  /// No description provided for @migrationPlanCopilotToolsButton.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get migrationPlanCopilotToolsButton;

  /// No description provided for @migrationPlanCopilotCityRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Available after confirming your city.'**
  String get migrationPlanCopilotCityRequiredHint;

  /// No description provided for @migrationPlanCopilotGoalRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Available after defining your migration goal.'**
  String get migrationPlanCopilotGoalRequiredHint;

  /// No description provided for @migrationPlanCopilotToolsFlightsHint.
  ///
  /// In en, this message translates to:
  /// **'Flight planner available in Tools.'**
  String get migrationPlanCopilotToolsFlightsHint;

  /// No description provided for @migrationPlanHousingCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking about changing cities?'**
  String get migrationPlanHousingCompareTitle;

  /// No description provided for @migrationPlanHousingCompareBody.
  ///
  /// In en, this message translates to:
  /// **'Compare {cityName} with other options before you decide.'**
  String migrationPlanHousingCompareBody(Object cityName);

  /// No description provided for @migrationPlanHousingCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare cities'**
  String get migrationPlanHousingCompareAction;

  /// No description provided for @migrationPlanScrollHint.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get migrationPlanScrollHint;

  /// No description provided for @languageSelectorSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSelectorSystem;

  /// No description provided for @bmpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This builds a starting point. It is not legal advice.'**
  String get bmpDisclaimer;

  /// No description provided for @bmpProgressStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String bmpProgressStep(Object current, Object total);

  /// No description provided for @bmpCtaBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bmpCtaBack;

  /// No description provided for @bmpCtaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get bmpCtaContinue;

  /// No description provided for @bmpCtaSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get bmpCtaSkip;

  /// No description provided for @bmpCtaGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate my plan'**
  String get bmpCtaGenerate;

  /// No description provided for @bmpExitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to leave this plan?'**
  String get bmpExitDialogTitle;

  /// No description provided for @bmpExitDialogBody.
  ///
  /// In en, this message translates to:
  /// **'If you go back home, you will lose this flow and your current answers.'**
  String get bmpExitDialogBody;

  /// No description provided for @bmpExitDialogStay.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get bmpExitDialogStay;

  /// No description provided for @bmpExitDialogLeave.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get bmpExitDialogLeave;

  /// No description provided for @bmpCtaRefineYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, refine'**
  String get bmpCtaRefineYes;

  /// No description provided for @bmpCtaRefineNo.
  ///
  /// In en, this message translates to:
  /// **'No, generate my plan'**
  String get bmpCtaRefineNo;

  /// No description provided for @bmpVariantTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to build your plan?'**
  String get bmpVariantTitle;

  /// No description provided for @bmpVariantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can go faster or answer one extra question for a more precise recommendation.'**
  String get bmpVariantSubtitle;

  /// No description provided for @bmpVariantLeanTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick plan'**
  String get bmpVariantLeanTitle;

  /// No description provided for @bmpVariantLeanBody.
  ///
  /// In en, this message translates to:
  /// **'4 focused questions to get an initial direction with low friction.'**
  String get bmpVariantLeanBody;

  /// No description provided for @bmpVariantLeanTag.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get bmpVariantLeanTag;

  /// No description provided for @bmpVariantStrategicTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategic plan'**
  String get bmpVariantStrategicTitle;

  /// No description provided for @bmpVariantStrategicBody.
  ///
  /// In en, this message translates to:
  /// **'Adds one extra preference step for a sharper starting recommendation.'**
  String get bmpVariantStrategicBody;

  /// No description provided for @bmpVariantStrategicTag.
  ///
  /// In en, this message translates to:
  /// **'More precise'**
  String get bmpVariantStrategicTag;

  /// No description provided for @bmpGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get bmpGuideEyebrow;

  /// No description provided for @bmpGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How this plan builder works'**
  String get bmpGuideTitle;

  /// No description provided for @bmpGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Start with the mode that matches how much detail you want right now. Both options lead to a suggested city and a first sequence of actions, but they differ in depth.'**
  String get bmpGuideBody;

  /// No description provided for @bmpGuideStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'What changes between the two modes'**
  String get bmpGuideStepsLabel;

  /// No description provided for @bmpGuideStepQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick plan'**
  String get bmpGuideStepQuickTitle;

  /// No description provided for @bmpGuideStepQuickBody.
  ///
  /// In en, this message translates to:
  /// **'This is the fastest path. You answer the core questions, get an initial direction, and can refine later if the first result is still too broad.'**
  String get bmpGuideStepQuickBody;

  /// No description provided for @bmpGuideStepStrategicTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategic plan'**
  String get bmpGuideStepStrategicTitle;

  /// No description provided for @bmpGuideStepStrategicBody.
  ///
  /// In en, this message translates to:
  /// **'This adds one extra layer about how you intend to support yourself after the move, so the recommendation becomes more precise and more practical.'**
  String get bmpGuideStepStrategicBody;

  /// No description provided for @bmpGuideStepUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use the result'**
  String get bmpGuideStepUseTitle;

  /// No description provided for @bmpGuideStepUseBody.
  ///
  /// In en, this message translates to:
  /// **'Use the plan as a starting point, not a final verdict. The best next move is usually to compare the suggested city, confirm documents, and adjust the plan if your priority changes.'**
  String get bmpGuideStepUseBody;

  /// No description provided for @bmpGuideHideNextTime.
  ///
  /// In en, this message translates to:
  /// **'Do not open this explanation automatically again'**
  String get bmpGuideHideNextTime;

  /// No description provided for @bmpGuideDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get bmpGuideDismissAction;

  /// No description provided for @bmpGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Start planning'**
  String get bmpGuidePrimaryAction;

  /// No description provided for @bmpRefineTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to refine the recommendation with 1 more question?'**
  String get bmpRefineTitle;

  /// No description provided for @bmpRefineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Optional) It takes about 5 seconds'**
  String get bmpRefineSubtitle;

  /// No description provided for @qIntentPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for in Brazil right now?'**
  String get qIntentPrompt;

  /// No description provided for @qFundingPrompt.
  ///
  /// In en, this message translates to:
  /// **'How do you plan to support yourself during the first 3 months?'**
  String get qFundingPrompt;

  /// No description provided for @qFundingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us adjust your starting point without asking for personal data.'**
  String get qFundingSubtitle;

  /// No description provided for @qTimelinePrompt.
  ///
  /// In en, this message translates to:
  /// **'When would you like to be in Brazil? (roughly)'**
  String get qTimelinePrompt;

  /// No description provided for @qPrioritiesPrompt.
  ///
  /// In en, this message translates to:
  /// **'What matters most when choosing a city?'**
  String get qPrioritiesPrompt;

  /// No description provided for @qPrioritiesHelper.
  ///
  /// In en, this message translates to:
  /// **'Select up to 3'**
  String get qPrioritiesHelper;

  /// No description provided for @qPrioritiesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total}'**
  String qPrioritiesSelectedCount(Object selected, Object total);

  /// No description provided for @qPrioritiesValidation.
  ///
  /// In en, this message translates to:
  /// **'Pick 2 options to continue'**
  String get qPrioritiesValidation;

  /// No description provided for @qConstraintsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Is there anything you do NOT want to compromise on?'**
  String get qConstraintsPrompt;

  /// No description provided for @qConstraintsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Optional) Pick up to 2'**
  String get qConstraintsSubtitle;

  /// No description provided for @bmpScrollHint.
  ///
  /// In en, this message translates to:
  /// **'See more options'**
  String get bmpScrollHint;

  /// No description provided for @qConstraintsValidation.
  ///
  /// In en, this message translates to:
  /// **'You can pick up to 2 options'**
  String get qConstraintsValidation;

  /// No description provided for @qConstraintsNone.
  ///
  /// In en, this message translates to:
  /// **'I do not have fixed constraints'**
  String get qConstraintsNone;

  /// No description provided for @questionOptionFindJobBr.
  ///
  /// In en, this message translates to:
  /// **'Find a job in Brazil'**
  String get questionOptionFindJobBr;

  /// No description provided for @questionOptionRemoteIncome.
  ///
  /// In en, this message translates to:
  /// **'Work remotely (I already have income)'**
  String get questionOptionRemoteIncome;

  /// No description provided for @questionOptionFundingSavings.
  ///
  /// In en, this message translates to:
  /// **'I have savings to get started'**
  String get questionOptionFundingSavings;

  /// No description provided for @questionOptionFundingJobSearch.
  ///
  /// In en, this message translates to:
  /// **'I will look for a job in Brazil'**
  String get questionOptionFundingJobSearch;

  /// No description provided for @questionOptionFundingJobOffer.
  ///
  /// In en, this message translates to:
  /// **'I already have an offer or contract'**
  String get questionOptionFundingJobOffer;

  /// No description provided for @questionOptionFundingFamilySupport.
  ///
  /// In en, this message translates to:
  /// **'Support from family or partner'**
  String get questionOptionFundingFamilySupport;

  /// No description provided for @questionOptionFundingDontKnow.
  ///
  /// In en, this message translates to:
  /// **'I still do not know'**
  String get questionOptionFundingDontKnow;

  /// No description provided for @questionOptionFamilyPartner.
  ///
  /// In en, this message translates to:
  /// **'Move because of partner or family'**
  String get questionOptionFamilyPartner;

  /// No description provided for @questionOptionFreshStart.
  ///
  /// In en, this message translates to:
  /// **'Better quality of life / start over'**
  String get questionOptionFreshStart;

  /// No description provided for @questionOptionExploreUnsure.
  ///
  /// In en, this message translates to:
  /// **'I just want to understand my options'**
  String get questionOptionExploreUnsure;

  /// No description provided for @questionOptionJustExploring.
  ///
  /// In en, this message translates to:
  /// **'Just exploring'**
  String get questionOptionJustExploring;

  /// No description provided for @questionOptionIn03Months.
  ///
  /// In en, this message translates to:
  /// **'In 0-3 months'**
  String get questionOptionIn03Months;

  /// No description provided for @questionOptionIn36Months.
  ///
  /// In en, this message translates to:
  /// **'In 3-6 months'**
  String get questionOptionIn36Months;

  /// No description provided for @questionOptionIn612Months.
  ///
  /// In en, this message translates to:
  /// **'In 6-12 months'**
  String get questionOptionIn612Months;

  /// No description provided for @questionOptionIn12PlusMonths.
  ///
  /// In en, this message translates to:
  /// **'In more than 12 months'**
  String get questionOptionIn12PlusMonths;

  /// No description provided for @questionOptionDepends.
  ///
  /// In en, this message translates to:
  /// **'It depends / I am still figuring it out'**
  String get questionOptionDepends;

  /// No description provided for @questionOptionLowCost.
  ///
  /// In en, this message translates to:
  /// **'Lower cost of living'**
  String get questionOptionLowCost;

  /// No description provided for @questionOptionJobOpportunities.
  ///
  /// In en, this message translates to:
  /// **'More job opportunities'**
  String get questionOptionJobOpportunities;

  /// No description provided for @questionOptionSafetyPriority.
  ///
  /// In en, this message translates to:
  /// **'Safety / peace of mind'**
  String get questionOptionSafetyPriority;

  /// No description provided for @questionOptionWarmClimateBeach.
  ///
  /// In en, this message translates to:
  /// **'Warmer climate / beach'**
  String get questionOptionWarmClimateBeach;

  /// No description provided for @questionOptionTransitInfra.
  ///
  /// In en, this message translates to:
  /// **'Good infrastructure and transit'**
  String get questionOptionTransitInfra;

  /// No description provided for @questionOptionNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get questionOptionNature;

  /// No description provided for @questionOptionUniversity.
  ///
  /// In en, this message translates to:
  /// **'University environment'**
  String get questionOptionUniversity;

  /// No description provided for @questionOptionCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community / making friends'**
  String get questionOptionCommunity;

  /// No description provided for @questionOptionCloseToArgentina.
  ///
  /// In en, this message translates to:
  /// **'Closer to Argentina'**
  String get questionOptionCloseToArgentina;

  /// No description provided for @questionOptionBalancedUnsure.
  ///
  /// In en, this message translates to:
  /// **'I want balance / I am not sure'**
  String get questionOptionBalancedUnsure;

  /// No description provided for @questionOptionPreferSouth.
  ///
  /// In en, this message translates to:
  /// **'I prefer the South'**
  String get questionOptionPreferSouth;

  /// No description provided for @questionOptionNeedBigCity.
  ///
  /// In en, this message translates to:
  /// **'I need a big city'**
  String get questionOptionNeedBigCity;

  /// No description provided for @questionOptionPreferMidCity.
  ///
  /// In en, this message translates to:
  /// **'I prefer a mid-size or calmer city'**
  String get questionOptionPreferMidCity;

  /// No description provided for @questionOptionWantCoast.
  ///
  /// In en, this message translates to:
  /// **'I want coast or beach'**
  String get questionOptionWantCoast;

  /// No description provided for @questionOptionPreferCooler.
  ///
  /// In en, this message translates to:
  /// **'I prefer cooler weather'**
  String get questionOptionPreferCooler;

  /// No description provided for @questionOptionNeedTransit.
  ///
  /// In en, this message translates to:
  /// **'I need strong public transit'**
  String get questionOptionNeedTransit;

  /// No description provided for @questionOptionAvoidExpensive.
  ///
  /// In en, this message translates to:
  /// **'I want to avoid expensive cities'**
  String get questionOptionAvoidExpensive;

  /// No description provided for @planReasonBudgetFit.
  ///
  /// In en, this message translates to:
  /// **'A better match if you want to protect your budget.'**
  String get planReasonBudgetFit;

  /// No description provided for @planReasonJobMobility.
  ///
  /// In en, this message translates to:
  /// **'More room to search for work and move around.'**
  String get planReasonJobMobility;

  /// No description provided for @planReasonSafety.
  ///
  /// In en, this message translates to:
  /// **'It matches your priority for peace of mind.'**
  String get planReasonSafety;

  /// No description provided for @planReasonClimateNature.
  ///
  /// In en, this message translates to:
  /// **'A good starting point if you want climate and outdoor life.'**
  String get planReasonClimateNature;

  /// No description provided for @planReasonTransit.
  ///
  /// In en, this message translates to:
  /// **'More practical if you want to get around without a car.'**
  String get planReasonTransit;

  /// No description provided for @planReasonProximityArgentina.
  ///
  /// In en, this message translates to:
  /// **'Closer if you want to return to Argentina when needed.'**
  String get planReasonProximityArgentina;

  /// No description provided for @planReasonUniversity.
  ///
  /// In en, this message translates to:
  /// **'More aligned if your plan is to study.'**
  String get planReasonUniversity;

  /// No description provided for @planReasonCommunity.
  ///
  /// In en, this message translates to:
  /// **'Better chances to build network and community.'**
  String get planReasonCommunity;

  /// No description provided for @planReasonBalancedProfile.
  ///
  /// In en, this message translates to:
  /// **'It appears as a balanced place to start.'**
  String get planReasonBalancedProfile;

  /// No description provided for @archetypeJobHunter.
  ///
  /// In en, this message translates to:
  /// **'Job search'**
  String get archetypeJobHunter;

  /// No description provided for @archetypeJobHunterWithOffer.
  ///
  /// In en, this message translates to:
  /// **'Job with offer'**
  String get archetypeJobHunterWithOffer;

  /// No description provided for @archetypeJobHunterSearching.
  ///
  /// In en, this message translates to:
  /// **'Active job search'**
  String get archetypeJobHunterSearching;

  /// No description provided for @archetypeRemoteWorker.
  ///
  /// In en, this message translates to:
  /// **'Remote work'**
  String get archetypeRemoteWorker;

  /// No description provided for @archetypeRemoteStable.
  ///
  /// In en, this message translates to:
  /// **'Stable remote work'**
  String get archetypeRemoteStable;

  /// No description provided for @archetypeStudent.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get archetypeStudent;

  /// No description provided for @archetypeFamilyMove.
  ///
  /// In en, this message translates to:
  /// **'Family move'**
  String get archetypeFamilyMove;

  /// No description provided for @archetypeFreshStart.
  ///
  /// In en, this message translates to:
  /// **'Fresh start'**
  String get archetypeFreshStart;

  /// No description provided for @archetypeExplorer.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get archetypeExplorer;

  /// No description provided for @planStepTitleChooseBaseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your base city'**
  String get planStepTitleChooseBaseCity;

  /// No description provided for @planStepTitleResidencePath.
  ///
  /// In en, this message translates to:
  /// **'Understand the residence path'**
  String get planStepTitleResidencePath;

  /// No description provided for @planStepTitleCpfStart.
  ///
  /// In en, this message translates to:
  /// **'Start your CPF'**
  String get planStepTitleCpfStart;

  /// No description provided for @planStepDescriptionChooseBaseCityExplore.
  ///
  /// In en, this message translates to:
  /// **'Choose 1 city to start with and review neighborhoods, living costs, and basic mobility. It is not final: it is just to begin with clarity.'**
  String get planStepDescriptionChooseBaseCityExplore;

  /// No description provided for @planStepDescriptionChooseBaseCityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Define a base city and compare 2 neighborhoods, rent, and mobility to turn the idea into a practical plan.'**
  String get planStepDescriptionChooseBaseCityBalanced;

  /// No description provided for @planStepDescriptionChooseBaseCityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Define a base city and a tentative date this week to organize the most urgent decisions.'**
  String get planStepDescriptionChooseBaseCityUrgent;

  /// No description provided for @planStepDescriptionChooseBaseCityOffer.
  ///
  /// In en, this message translates to:
  /// **'Since you already have an offer or contract, choose the base city and validate neighborhood, commute, and starting costs.'**
  String get planStepDescriptionChooseBaseCityOffer;

  /// No description provided for @planStepDescriptionResidencePathExplore.
  ///
  /// In en, this message translates to:
  /// **'Review the most common residence path for Argentina to Brazil and which base documents you will need later.'**
  String get planStepDescriptionResidencePathExplore;

  /// No description provided for @planStepDescriptionResidencePathBalanced.
  ///
  /// In en, this message translates to:
  /// **'Understand the residence path and start gathering the base documents before getting into detailed bureaucracy.'**
  String get planStepDescriptionResidencePathBalanced;

  /// No description provided for @planStepDescriptionResidencePathUrgent.
  ///
  /// In en, this message translates to:
  /// **'Review the residence path and separate the base documents now so execution does not get blocked.'**
  String get planStepDescriptionResidencePathUrgent;

  /// No description provided for @planStepDescriptionResidencePathFundingUnknown.
  ///
  /// In en, this message translates to:
  /// **'Before moving ahead, understand the residence path and clarify how you will support yourself during the first months to avoid blockers.'**
  String get planStepDescriptionResidencePathFundingUnknown;

  /// No description provided for @planStepDescriptionCpfStart.
  ///
  /// In en, this message translates to:
  /// **'CPF unlocks many practical steps in Brazil. Start with the official guidance and continue later in Movaro step by step.'**
  String get planStepDescriptionCpfStart;

  /// No description provided for @migrationPlanPrepHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the move without getting lost in the process'**
  String get migrationPlanPrepHeroTitle;

  /// No description provided for @migrationPlanPrepHeroBody.
  ///
  /// In en, this message translates to:
  /// **'The goal here is not to tick checkboxes. First understand what to issue, where to open each topic, and which guide solves your next step.'**
  String get migrationPlanPrepHeroBody;

  /// No description provided for @migrationPlanPrepHeroBodyCompact.
  ///
  /// In en, this message translates to:
  /// **'Open the right stage and prepare the move without losing the order of the plan.'**
  String get migrationPlanPrepHeroBodyCompact;

  /// No description provided for @migrationPlanPrepTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get migrationPlanPrepTabOverview;

  /// No description provided for @migrationPlanPrepTabDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get migrationPlanPrepTabDocuments;

  /// No description provided for @migrationPlanPrepTabHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing and costs'**
  String get migrationPlanPrepTabHousing;

  /// No description provided for @migrationPlanPrepTabWork.
  ///
  /// In en, this message translates to:
  /// **'Work and daily life'**
  String get migrationPlanPrepTabWork;

  /// No description provided for @migrationPlanPrepTabArrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get migrationPlanPrepTabArrival;

  /// No description provided for @migrationPlanPrepOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with what really unlocks the move'**
  String get migrationPlanPrepOverviewTitle;

  /// No description provided for @migrationPlanPrepOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Instead of a long checklist, this area now works as a practical guide. Documents come first, then housing, costs, work, and arrival.'**
  String get migrationPlanPrepOverviewBody;

  /// No description provided for @migrationPlanPrepChooseCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city to unlock preparation'**
  String get migrationPlanPrepChooseCityTitle;

  /// No description provided for @migrationPlanPrepChooseCityBody.
  ///
  /// In en, this message translates to:
  /// **'Preparation only makes sense with a confirmed base city. First choose the city that will guide housing, costs, work, and arrival.'**
  String get migrationPlanPrepChooseCityBody;

  /// No description provided for @migrationPlanPrepChooseCityAction.
  ///
  /// In en, this message translates to:
  /// **'Choose plan city'**
  String get migrationPlanPrepChooseCityAction;

  /// No description provided for @migrationPlanPrepQuestionDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I regularize my documents?'**
  String get migrationPlanPrepQuestionDocsTitle;

  /// No description provided for @migrationPlanPrepQuestionDocsBody.
  ///
  /// In en, this message translates to:
  /// **'Open CPF, registration, banking, and contracts in a more guided way without falling into a loose bureaucratic flow.'**
  String get migrationPlanPrepQuestionDocsBody;

  /// No description provided for @migrationPlanPrepQuestionRentTitle.
  ///
  /// In en, this message translates to:
  /// **'What do I need to rent a place?'**
  String get migrationPlanPrepQuestionRentTitle;

  /// No description provided for @migrationPlanPrepQuestionRentBody.
  ///
  /// In en, this message translates to:
  /// **'See guarantees, deposit, temporary rent, and what is usually requested to enter housing at the beginning.'**
  String get migrationPlanPrepQuestionRentBody;

  /// No description provided for @migrationPlanPrepQuestionMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'How much money should I bring?'**
  String get migrationPlanPrepQuestionMoneyTitle;

  /// No description provided for @migrationPlanPrepQuestionMoneyBody.
  ///
  /// In en, this message translates to:
  /// **'Use a more conservative arrival view with a safety margin instead of unrealistic numbers.'**
  String get migrationPlanPrepQuestionMoneyBody;

  /// No description provided for @migrationPlanPrepQuestionHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Is healthcare public or private?'**
  String get migrationPlanPrepQuestionHealthTitle;

  /// No description provided for @migrationPlanPrepQuestionHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Understand when SUS, a local clinic, a hospital, or a private plan makes sense without mixing everything together.'**
  String get migrationPlanPrepQuestionHealthBody;

  /// No description provided for @migrationPlanPrepQuestionWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Can I work and open a bank account?'**
  String get migrationPlanPrepQuestionWorkTitle;

  /// No description provided for @migrationPlanPrepQuestionWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Open formal work, income, banking, and contracts in a practical way, focused on what unlocks real life.'**
  String get migrationPlanPrepQuestionWorkBody;

  /// No description provided for @migrationPlanPrepQuestionArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I solve right after arrival?'**
  String get migrationPlanPrepQuestionArrivalTitle;

  /// No description provided for @migrationPlanPrepQuestionArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'Organize the first days, the first housing base, and the initial routine so everything is not improvised.'**
  String get migrationPlanPrepQuestionArrivalBody;

  /// No description provided for @migrationPlanPrepQuestionFlightsTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I check flights to this city?'**
  String get migrationPlanPrepQuestionFlightsTitle;

  /// No description provided for @migrationPlanPrepQuestionFlightsBody.
  ///
  /// In en, this message translates to:
  /// **'Open an external flight search to compare routes to the chosen city in Brazil.'**
  String get migrationPlanPrepQuestionFlightsBody;

  /// No description provided for @migrationPlanPrepPrimaryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get migrationPlanPrepPrimaryEyebrow;

  /// No description provided for @migrationPlanPrepCardToneGuide.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get migrationPlanPrepCardToneGuide;

  /// No description provided for @migrationPlanPrepCardTonePractical.
  ///
  /// In en, this message translates to:
  /// **'Solve now'**
  String get migrationPlanPrepCardTonePractical;

  /// No description provided for @migrationPlanPrepCardTonePriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get migrationPlanPrepCardTonePriority;

  /// No description provided for @migrationPlanPrepCardToneArrival.
  ///
  /// In en, this message translates to:
  /// **'First steps'**
  String get migrationPlanPrepCardToneArrival;

  /// No description provided for @migrationPlanPrepOpenSection.
  ///
  /// In en, this message translates to:
  /// **'Open this area'**
  String get migrationPlanPrepOpenSection;

  /// No description provided for @migrationPlanPrepOpenOfficialSource.
  ///
  /// In en, this message translates to:
  /// **'Open official source'**
  String get migrationPlanPrepOpenOfficialSource;

  /// No description provided for @migrationPlanPrepExternalToolHint.
  ///
  /// In en, this message translates to:
  /// **'Use this shortcut as quick orientation. The next step opens the official source inside the app so you can continue without losing context.'**
  String get migrationPlanPrepExternalToolHint;

  /// No description provided for @migrationPlanPrepOpenGuide.
  ///
  /// In en, this message translates to:
  /// **'Open full guide'**
  String get migrationPlanPrepOpenGuide;

  /// No description provided for @migrationPlanPrepBackToOverview.
  ///
  /// In en, this message translates to:
  /// **'Back to overview'**
  String get migrationPlanPrepBackToOverview;

  /// No description provided for @migrationPlanPrepDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents and residence'**
  String get migrationPlanPrepDocumentsTitle;

  /// No description provided for @migrationPlanPrepDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'See what to issue first, how CPF and registration work in practice, and where to open the right guidance without getting lost in scattered research.'**
  String get migrationPlanPrepDocumentsBody;

  /// No description provided for @migrationPlanPrepHousingTitle.
  ///
  /// In en, this message translates to:
  /// **'Housing and costs'**
  String get migrationPlanPrepHousingTitle;

  /// No description provided for @migrationPlanPrepHousingBody.
  ///
  /// In en, this message translates to:
  /// **'Understand reserve, rental entry, guarantees, and a temporary housing plan before arrival gets tight.'**
  String get migrationPlanPrepHousingBody;

  /// No description provided for @migrationPlanPrepWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Work and daily life'**
  String get migrationPlanPrepWorkTitle;

  /// No description provided for @migrationPlanPrepWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Open work, health, and mobility in more direct blocks to solve daily life without excessive reading.'**
  String get migrationPlanPrepWorkBody;

  /// No description provided for @migrationPlanPrepArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'First days in Brazil'**
  String get migrationPlanPrepArrivalTitle;

  /// No description provided for @migrationPlanPrepArrivalBody.
  ///
  /// In en, this message translates to:
  /// **'Organize arrival by short horizon: first week, first month, and the 90 days that stabilize the move.'**
  String get migrationPlanPrepArrivalBody;

  /// No description provided for @migrationPlanPrepDocumentsGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with documents, not with a checklist'**
  String get migrationPlanPrepDocumentsGuideTitle;

  /// No description provided for @migrationPlanPrepDocumentsGuideBody.
  ///
  /// In en, this message translates to:
  /// **'If the document layer is confusing, the rest gets blocked. That is why this area sends you straight to what to issue, how it works, and where to continue.'**
  String get migrationPlanPrepDocumentsGuideBody;

  /// No description provided for @migrationPlanPrepOpenDocumentsTopic.
  ///
  /// In en, this message translates to:
  /// **'Open documents topic'**
  String get migrationPlanPrepOpenDocumentsTopic;

  /// No description provided for @migrationPlanPrepDocumentsCpfTitle.
  ///
  /// In en, this message translates to:
  /// **'CPF and what it really unlocks'**
  String get migrationPlanPrepDocumentsCpfTitle;

  /// No description provided for @migrationPlanPrepDocumentsCpfBody.
  ///
  /// In en, this message translates to:
  /// **'Open this part to understand when CPF helps, what it cannot solve alone, and how it connects to banking, contracts, and daily life.'**
  String get migrationPlanPrepDocumentsCpfBody;

  /// No description provided for @migrationPlanPrepDocumentsResidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration and residence without bureaucratic language'**
  String get migrationPlanPrepDocumentsResidenceTitle;

  /// No description provided for @migrationPlanPrepDocumentsResidenceBody.
  ///
  /// In en, this message translates to:
  /// **'Understand the most common residence path, the role of the protocol, and how that connects with arrival.'**
  String get migrationPlanPrepDocumentsResidenceBody;

  /// No description provided for @migrationPlanPrepDocumentsBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Banking, records, and contracts'**
  String get migrationPlanPrepDocumentsBankTitle;

  /// No description provided for @migrationPlanPrepDocumentsBankBody.
  ///
  /// In en, this message translates to:
  /// **'See what is usually required to open an account, sign a rental agreement, and avoid blocking daily life right at the start.'**
  String get migrationPlanPrepDocumentsBankBody;

  /// No description provided for @migrationPlanPrepTaxesTitle.
  ///
  /// In en, this message translates to:
  /// **'How taxes and tax residence work'**
  String get migrationPlanPrepTaxesTitle;

  /// No description provided for @migrationPlanPrepTaxesBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official Receita guidance to understand entry into Brazil, tax residence, and when this starts to matter.'**
  String get migrationPlanPrepTaxesBody;

  /// No description provided for @migrationPlanPrepDeadlinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Which deadlines you cannot miss'**
  String get migrationPlanPrepDeadlinesTitle;

  /// No description provided for @migrationPlanPrepDeadlinesBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official residence route so you do not discover registration, issuance, and critical deadlines too late.'**
  String get migrationPlanPrepDeadlinesBody;

  /// No description provided for @migrationPlanPrepHousingGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn the move into real numbers'**
  String get migrationPlanPrepHousingGuideTitle;

  /// No description provided for @migrationPlanPrepHousingGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Here you review reserve, entry costs, guarantees, and soft landing with a much more practical structure than a checklist block.'**
  String get migrationPlanPrepHousingGuideBody;

  /// No description provided for @migrationPlanPrepWorkGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily life after the city is chosen'**
  String get migrationPlanPrepWorkGuideTitle;

  /// No description provided for @migrationPlanPrepWorkGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Use these blocks to open work, health, and mobility quickly. These are the topics that most often become doubts after the city decision.'**
  String get migrationPlanPrepWorkGuideBody;

  /// No description provided for @migrationPlanPrepWorkSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Work signals for this city'**
  String get migrationPlanPrepWorkSignalsTitle;

  /// No description provided for @migrationPlanPrepWorkSignalsBody.
  ///
  /// In en, this message translates to:
  /// **'Movaro currently shows labor-market, economic-activity, and unemployment signals. Average income is not integrated into the catalog yet.'**
  String get migrationPlanPrepWorkSignalsBody;

  /// No description provided for @migrationPlanPrepMoneyPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Banking and money in practice'**
  String get migrationPlanPrepMoneyPracticeTitle;

  /// No description provided for @migrationPlanPrepMoneyPracticeBody.
  ///
  /// In en, this message translates to:
  /// **'Open the public Central Bank guidance to understand accounts, Pix, payments, and financial organization for migrants.'**
  String get migrationPlanPrepMoneyPracticeBody;

  /// No description provided for @migrationPlanPrepDiplomaTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognize diploma and profession'**
  String get migrationPlanPrepDiplomaTitle;

  /// No description provided for @migrationPlanPrepDiplomaBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official route to revalidate a foreign diploma and understand when the profession may require an extra step in Brazil.'**
  String get migrationPlanPrepDiplomaBody;

  /// No description provided for @migrationPlanPrepWorkSignalJobs.
  ///
  /// In en, this message translates to:
  /// **'Job market'**
  String get migrationPlanPrepWorkSignalJobs;

  /// No description provided for @migrationPlanPrepWorkSignalEconomic.
  ///
  /// In en, this message translates to:
  /// **'Economic activity'**
  String get migrationPlanPrepWorkSignalEconomic;

  /// No description provided for @migrationPlanPrepWorkSignalUnemployment.
  ///
  /// In en, this message translates to:
  /// **'Unemployment'**
  String get migrationPlanPrepWorkSignalUnemployment;

  /// No description provided for @migrationPlanPrepArrivalGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'What to solve first when you arrive'**
  String get migrationPlanPrepArrivalGuideTitle;

  /// No description provided for @migrationPlanPrepArrivalGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Instead of marking loose tasks, look at arrival as a short sequence: land, stabilize, and consolidate the new routine.'**
  String get migrationPlanPrepArrivalGuideBody;

  /// No description provided for @migrationPlanPrepArrivalWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'First week'**
  String get migrationPlanPrepArrivalWeekTitle;

  /// No description provided for @migrationPlanPrepArrivalWeekBody.
  ///
  /// In en, this message translates to:
  /// **'Focus on where to stay, how to move around, what to buy first, and how to avoid the first housing mistakes.'**
  String get migrationPlanPrepArrivalWeekBody;

  /// No description provided for @migrationPlanPrepArrivalMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'First month'**
  String get migrationPlanPrepArrivalMonthTitle;

  /// No description provided for @migrationPlanPrepArrivalMonthBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust documents, neighborhood routine, bank account, rent, and the points that turn arrival into something less improvised.'**
  String get migrationPlanPrepArrivalMonthBody;

  /// No description provided for @migrationPlanPrepArrivalQuarterTitle.
  ///
  /// In en, this message translates to:
  /// **'First 90 days'**
  String get migrationPlanPrepArrivalQuarterTitle;

  /// No description provided for @migrationPlanPrepArrivalQuarterBody.
  ///
  /// In en, this message translates to:
  /// **'Consolidate work, financial organization, health routine, and the next steps that make the move sustainable.'**
  String get migrationPlanPrepArrivalQuarterBody;

  /// No description provided for @migrationPlanPrepSupportNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to find support networks'**
  String get migrationPlanPrepSupportNetworkTitle;

  /// No description provided for @migrationPlanPrepSupportNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Open public support networks for migrants and refugees to understand where to look for assistance, orientation, and reception.'**
  String get migrationPlanPrepSupportNetworkBody;

  /// No description provided for @migrationPlanPrepArgentineNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Argentine embassy and consulates'**
  String get migrationPlanPrepArgentineNetworkTitle;

  /// No description provided for @migrationPlanPrepArgentineNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official list of the Argentine embassy and consulates in Brazil to check procedures, contact details, and official consular guidance.'**
  String get migrationPlanPrepArgentineNetworkBody;

  /// No description provided for @migrationPlanPrepFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'What about family and children'**
  String get migrationPlanPrepFamilyTitle;

  /// No description provided for @migrationPlanPrepFamilyBody.
  ///
  /// In en, this message translates to:
  /// **'Open the public guidance on school enrollment and rights for migrant children and teenagers in Brazil.'**
  String get migrationPlanPrepFamilyBody;

  /// No description provided for @migrationPlanPrepRiskAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scams and risks to avoid'**
  String get migrationPlanPrepRiskAlertsTitle;

  /// No description provided for @migrationPlanPrepRiskAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'Open public alerts about misleading offers, false promises, and risks that often affect people moving to another country.'**
  String get migrationPlanPrepRiskAlertsBody;

  /// No description provided for @migrationPlanPrepFlightsPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the flight search'**
  String get migrationPlanPrepFlightsPlannerTitle;

  /// No description provided for @migrationPlanPrepFlightsPlannerBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the departure city in Argentina and the date you expect to move to open the search already prepared for {city}.'**
  String migrationPlanPrepFlightsPlannerBody(Object city);

  /// No description provided for @migrationPlanPrepFlightsOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure city'**
  String get migrationPlanPrepFlightsOriginLabel;

  /// No description provided for @migrationPlanPrepFlightsDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated move date'**
  String get migrationPlanPrepFlightsDateLabel;

  /// No description provided for @migrationPlanPrepFlightsDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get migrationPlanPrepFlightsDatePlaceholder;

  /// No description provided for @migrationPlanPrepFlightsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Final prices vary by date, how early you book, and availability. Use this search as a starting point and compare before buying.'**
  String get migrationPlanPrepFlightsDisclaimer;

  /// No description provided for @migrationPlanPrepFlightsOpenGoogle.
  ///
  /// In en, this message translates to:
  /// **'Check on Google Flights'**
  String get migrationPlanPrepFlightsOpenGoogle;

  /// No description provided for @migrationPlanPrepOfficialIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'View official income and city indicators'**
  String get migrationPlanPrepOfficialIncomeTitle;

  /// No description provided for @migrationPlanPrepOfficialIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official IBGE page for this city to consult municipal indicators, including the panorama used as a reliable source.'**
  String get migrationPlanPrepOfficialIncomeBody;

  /// No description provided for @migrationPlanPrepOfficialJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search jobs on Emprega Brasil'**
  String get migrationPlanPrepOfficialJobsTitle;

  /// No description provided for @migrationPlanPrepOfficialJobsBodyNoCity.
  ///
  /// In en, this message translates to:
  /// **'Open the official government employment portal to look for formal jobs and use your region as the basis of the search.'**
  String get migrationPlanPrepOfficialJobsBodyNoCity;

  /// No description provided for @migrationPlanPrepOfficialJobsBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Open the official government employment portal to look for formal jobs and use {city} ({state}) as the basis of the search.'**
  String migrationPlanPrepOfficialJobsBodyWithCity(Object city, Object state);

  /// No description provided for @migrationPlanPrepOfficialStudyCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'View official public universities'**
  String get migrationPlanPrepOfficialStudyCatalogTitle;

  /// No description provided for @migrationPlanPrepOfficialStudyCatalogBodyNoCity.
  ///
  /// In en, this message translates to:
  /// **'Open the official MEC catalog to search public higher education institutions and filter by state or city.'**
  String get migrationPlanPrepOfficialStudyCatalogBodyNoCity;

  /// No description provided for @migrationPlanPrepOfficialStudyCatalogBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Open the official MEC catalog to search public higher education institutions and filter by {city} ({state}) or the nearest region.'**
  String migrationPlanPrepOfficialStudyCatalogBodyWithCity(
    Object city,
    Object state,
  );

  /// No description provided for @migrationPlanPrepOfficialStudyForeignersTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand foreign student admission'**
  String get migrationPlanPrepOfficialStudyForeignersTitle;

  /// No description provided for @migrationPlanPrepOfficialStudyForeignersBody.
  ///
  /// In en, this message translates to:
  /// **'Open the official PEC-G route to understand how foreign student admission works and which participating universities already receive this process.'**
  String get migrationPlanPrepOfficialStudyForeignersBody;

  /// No description provided for @migrationPlanPrepRentalSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search rentals in this city'**
  String get migrationPlanPrepRentalSearchTitle;

  /// No description provided for @migrationPlanPrepRentalSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Open a rental search already filtered for {city} ({state}) inside the app and compare options by area.'**
  String migrationPlanPrepRentalSearchBody(Object city, Object state);

  /// No description provided for @migrationPlanPrepRentalProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Rental portal'**
  String get migrationPlanPrepRentalProviderLabel;

  /// No description provided for @migrationPlanPrepRentalProviderZap.
  ///
  /// In en, this message translates to:
  /// **'ZAP Imóveis'**
  String get migrationPlanPrepRentalProviderZap;

  /// No description provided for @migrationPlanPrepRentalProviderVivaReal.
  ///
  /// In en, this message translates to:
  /// **'Viva Real'**
  String get migrationPlanPrepRentalProviderVivaReal;

  /// No description provided for @migrationPlanPrepRentalProviderChaves.
  ///
  /// In en, this message translates to:
  /// **'Chaves na Mão'**
  String get migrationPlanPrepRentalProviderChaves;

  /// No description provided for @migrationPlanPrepRentalSearchDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Coverage and listings may vary by city and current availability. Check more than one source before deciding.'**
  String get migrationPlanPrepRentalSearchDisclaimer;

  /// No description provided for @migrationPlanPrepRentalSearchOpen.
  ///
  /// In en, this message translates to:
  /// **'Open rental search'**
  String get migrationPlanPrepRentalSearchOpen;

  /// No description provided for @migrationPlanPrepScamsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to avoid rental scams'**
  String get migrationPlanPrepScamsTitle;

  /// No description provided for @migrationPlanPrepScamsBody.
  ///
  /// In en, this message translates to:
  /// **'Open a public alert about common fraud in listings and rentals so you do not decide only on price or urgency.'**
  String get migrationPlanPrepScamsBody;

  /// No description provided for @phase_before_travel.
  ///
  /// In en, this message translates to:
  /// **'Before travel'**
  String get phase_before_travel;

  /// No description provided for @phase_first_days.
  ///
  /// In en, this message translates to:
  /// **'First days'**
  String get phase_first_days;

  /// No description provided for @phase_documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get phase_documentation;

  /// No description provided for @phase_life_working.
  ///
  /// In en, this message translates to:
  /// **'Life working'**
  String get phase_life_working;

  /// No description provided for @phase_integration.
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get phase_integration;

  /// No description provided for @phase_desc_before_travel.
  ///
  /// In en, this message translates to:
  /// **'What to prepare in Argentina so you arrive without surprises'**
  String get phase_desc_before_travel;

  /// No description provided for @phase_desc_first_days.
  ///
  /// In en, this message translates to:
  /// **'You arrived in Brazil. Focus on getting established and being able to communicate.'**
  String get phase_desc_first_days;

  /// No description provided for @phase_desc_documentation.
  ///
  /// In en, this message translates to:
  /// **'The documents that unlock everything. Do them in this exact order.'**
  String get phase_desc_documentation;

  /// No description provided for @phase_desc_life_working.
  ///
  /// In en, this message translates to:
  /// **'With CPF and residence in progress, now you build the structure of daily life.'**
  String get phase_desc_life_working;

  /// No description provided for @phase_desc_integration.
  ///
  /// In en, this message translates to:
  /// **'Adapt your full life to Brazil and secure long-term stay.'**
  String get phase_desc_integration;

  /// No description provided for @item_next_action_tag.
  ///
  /// In en, this message translates to:
  /// **'NEXT ACTION'**
  String get item_next_action_tag;

  /// No description provided for @item_external_tag.
  ///
  /// In en, this message translates to:
  /// **'EXTERNAL ACTION'**
  String get item_external_tag;

  /// No description provided for @item_tool_tag.
  ///
  /// In en, this message translates to:
  /// **'USE A TOOL'**
  String get item_tool_tag;

  /// No description provided for @item_checklist_tag.
  ///
  /// In en, this message translates to:
  /// **'TO COMPLETE'**
  String get item_checklist_tag;

  /// No description provided for @deadline_badge.
  ///
  /// In en, this message translates to:
  /// **'Apply by {date}'**
  String deadline_badge(Object date);

  /// No description provided for @deadline_alert_title.
  ///
  /// In en, this message translates to:
  /// **'Deadline is getting close'**
  String get deadline_alert_title;

  /// No description provided for @deadline_alert_body.
  ///
  /// In en, this message translates to:
  /// **'Your temporary residence expires in {days} days. Apply for permanent residence before that.'**
  String deadline_alert_body(Object days);

  /// No description provided for @guide_completed_title.
  ///
  /// In en, this message translates to:
  /// **'Plan completed!'**
  String get guide_completed_title;

  /// No description provided for @guide_completed_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed every step in your guide for {city}.'**
  String guide_completed_subtitle(Object city);

  /// No description provided for @guide_no_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your city first'**
  String get guide_no_plan_title;

  /// No description provided for @guide_no_plan_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your plan city to start the guide'**
  String get guide_no_plan_subtitle;

  /// No description provided for @infoGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get infoGuideEyebrow;

  /// No description provided for @infoGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Your migration info hub'**
  String get infoGuideTitle;

  /// No description provided for @infoGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Find answers about documents, housing, health, work, and costs for your destination country — all in one place.'**
  String get infoGuideBody;

  /// No description provided for @infoGuideStepOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get infoGuideStepOneTitle;

  /// No description provided for @infoGuideStepOneBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a section card to see detailed guides with official sources for each topic.'**
  String get infoGuideStepOneBody;

  /// No description provided for @infoGuideStepTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Search any topic'**
  String get infoGuideStepTwoTitle;

  /// No description provided for @infoGuideStepTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar to find specific answers about CPF, visa, SUS, or any other subject.'**
  String get infoGuideStepTwoBody;

  /// No description provided for @infoGuideStepThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI assistant'**
  String get infoGuideStepThreeTitle;

  /// No description provided for @infoGuideStepThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the blue button at the bottom right to chat with our assistant and get personalized answers.'**
  String get infoGuideStepThreeBody;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Movaro Assistant'**
  String get aiChatTitle;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get answers about migration'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get aiChatClearTooltip;

  /// No description provided for @aiChatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about migration...'**
  String get aiChatInputHint;

  /// No description provided for @aiChatWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help?'**
  String get aiChatWelcomeTitle;

  /// No description provided for @aiChatWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Ask about documents, housing, health, work and more'**
  String get aiChatWelcomeBody;

  /// No description provided for @aiChatErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Request limit reached. Please wait a moment.'**
  String get aiChatErrorRateLimit;

  /// No description provided for @aiChatErrorApiLimit.
  ///
  /// In en, this message translates to:
  /// **'API limit reached. Please try again in a few minutes.'**
  String get aiChatErrorApiLimit;

  /// No description provided for @aiChatErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error processing your question. Please try again.'**
  String get aiChatErrorGeneric;

  /// No description provided for @aiChatNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Service not initialized. Please try again.'**
  String get aiChatNotInitialized;

  /// No description provided for @aiChatSuggestPassport.
  ///
  /// In en, this message translates to:
  /// **'Do I need a passport to travel to Brazil?'**
  String get aiChatSuggestPassport;

  /// No description provided for @aiChatSuggestCpf.
  ///
  /// In en, this message translates to:
  /// **'How to get a CPF?'**
  String get aiChatSuggestCpf;

  /// No description provided for @aiChatSuggestSus.
  ///
  /// In en, this message translates to:
  /// **'How does SUS (public health) work?'**
  String get aiChatSuggestSus;

  /// No description provided for @aiChatSuggestWork.
  ///
  /// In en, this message translates to:
  /// **'Can I work with a tourist visa?'**
  String get aiChatSuggestWork;

  /// No description provided for @aiChatSuggestCosts.
  ///
  /// In en, this message translates to:
  /// **'How much does it cost to move?'**
  String get aiChatSuggestCosts;

  /// No description provided for @aiChatSuggestLicense.
  ///
  /// In en, this message translates to:
  /// **'How to validate my driver\'s license?'**
  String get aiChatSuggestLicense;

  /// No description provided for @homeAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Movaro Assistant'**
  String get homeAssistantTitle;

  /// No description provided for @homeAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your trip'**
  String get homeAssistantSubtitle;

  /// No description provided for @homeAssistantSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to expand ↑'**
  String get homeAssistantSwipeHint;

  /// No description provided for @homeAssistantInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask something...'**
  String get homeAssistantInputPlaceholder;

  /// No description provided for @homeAssistantInputPlaceholderExpanded.
  ///
  /// In en, this message translates to:
  /// **'Or type your question...'**
  String get homeAssistantInputPlaceholderExpanded;

  /// No description provided for @homeAssistantWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I see you\'re planning {destination}. How can I help with your trip?'**
  String homeAssistantWelcome(String destination);

  /// No description provided for @homeAssistantSectionQuickQuestions.
  ///
  /// In en, this message translates to:
  /// **'Quick questions'**
  String get homeAssistantSectionQuickQuestions;

  /// No description provided for @homeAssistantSectionExploreTopics.
  ///
  /// In en, this message translates to:
  /// **'Explore by topic'**
  String get homeAssistantSectionExploreTopics;

  /// No description provided for @homeAssistantChipVisa.
  ///
  /// In en, this message translates to:
  /// **'Do I need a visa?'**
  String get homeAssistantChipVisa;

  /// No description provided for @homeAssistantChipBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time to go?'**
  String get homeAssistantChipBestTime;

  /// No description provided for @homeAssistantChipPacking.
  ///
  /// In en, this message translates to:
  /// **'What to pack?'**
  String get homeAssistantChipPacking;

  /// No description provided for @homeAssistantChipSafety.
  ///
  /// In en, this message translates to:
  /// **'Is it safe?'**
  String get homeAssistantChipSafety;

  /// No description provided for @homeAssistantChipHowToGet.
  ///
  /// In en, this message translates to:
  /// **'How to get there?'**
  String get homeAssistantChipHowToGet;

  /// No description provided for @homeAssistantCategoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Visa & documents'**
  String get homeAssistantCategoryDocuments;

  /// No description provided for @homeAssistantCategoryCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs & budget'**
  String get homeAssistantCategoryCosts;

  /// No description provided for @homeAssistantCategoryActivities.
  ///
  /// In en, this message translates to:
  /// **'Things to do'**
  String get homeAssistantCategoryActivities;

  /// No description provided for @homeAssistantCategoryStay.
  ///
  /// In en, this message translates to:
  /// **'Where to stay'**
  String get homeAssistantCategoryStay;

  /// No description provided for @homeAssistantMessageDocuments.
  ///
  /// In en, this message translates to:
  /// **'What documents do I need to travel to {destination}?'**
  String homeAssistantMessageDocuments(String destination);

  /// No description provided for @homeAssistantMessageCosts.
  ///
  /// In en, this message translates to:
  /// **'How much does a trip to {destination} cost on average?'**
  String homeAssistantMessageCosts(String destination);

  /// No description provided for @homeAssistantMessageActivities.
  ///
  /// In en, this message translates to:
  /// **'What to do in {destination}? What are the best activities?'**
  String homeAssistantMessageActivities(String destination);

  /// No description provided for @homeAssistantMessageStay.
  ///
  /// In en, this message translates to:
  /// **'What are the best areas to stay in {destination}?'**
  String homeAssistantMessageStay(String destination);

  /// No description provided for @aiChatLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading assistant...'**
  String get aiChatLoading;

  /// No description provided for @aiChatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Assistant unavailable'**
  String get aiChatUnavailable;

  /// No description provided for @aiChatRetry.
  ///
  /// In en, this message translates to:
  /// **'The assistant is still loading. Please try again in a moment.'**
  String get aiChatRetry;

  /// No description provided for @aiChatNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet and try again.'**
  String get aiChatNetworkError;

  /// No description provided for @migrationResultRevealEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your recommended city'**
  String get migrationResultRevealEyebrow;

  /// No description provided for @migrationResultRevealRedoAction.
  ///
  /// In en, this message translates to:
  /// **'Answer quick questions again'**
  String get migrationResultRevealRedoAction;

  /// No description provided for @migrationResultRevealCompatibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'{pct}% compatible'**
  String migrationResultRevealCompatibilityLabel(int pct);

  /// No description provided for @migrationResultRevealWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why {city}?'**
  String migrationResultRevealWhyTitle(String city);

  /// No description provided for @migrationResultRevealOtherOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other options'**
  String get migrationResultRevealOtherOptionsTitle;

  /// No description provided for @migrationResultRevealStartCta.
  ///
  /// In en, this message translates to:
  /// **'Start plan in {city}'**
  String migrationResultRevealStartCta(String city);

  /// No description provided for @migrationResultRevealExploreCity.
  ///
  /// In en, this message translates to:
  /// **'View city details'**
  String get migrationResultRevealExploreCity;

  /// No description provided for @homeVisualTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Thinking about living in '**
  String get homeVisualTitlePrefix;

  /// No description provided for @homeVisualTitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'another country?'**
  String get homeVisualTitleHighlight;

  /// No description provided for @homeVisualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We help you understand what to do, what it may cost, and where to start.'**
  String get homeVisualSubtitle;

  /// No description provided for @homeVisualSupportLine.
  ///
  /// In en, this message translates to:
  /// **'You can start even if you have not decided everything yet.'**
  String get homeVisualSupportLine;

  /// No description provided for @homeVisualCostsAction.
  ///
  /// In en, this message translates to:
  /// **'See what it may cost'**
  String get homeVisualCostsAction;

  /// No description provided for @homeVisualDocumentsAction.
  ///
  /// In en, this message translates to:
  /// **'Understand documents'**
  String get homeVisualDocumentsAction;

  /// No description provided for @homeVisualStartAction.
  ///
  /// In en, this message translates to:
  /// **'Find where to start'**
  String get homeVisualStartAction;

  /// No description provided for @homeVisualPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get homeVisualPrimaryAction;

  /// No description provided for @homeVisualOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'ORIGIN'**
  String get homeVisualOriginLabel;

  /// No description provided for @homeVisualDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'DESTINATION'**
  String get homeVisualDestinationLabel;

  /// No description provided for @homeVisualWaypointDocuments.
  ///
  /// In en, this message translates to:
  /// **'docs'**
  String get homeVisualWaypointDocuments;

  /// No description provided for @homeVisualWaypointCosts.
  ///
  /// In en, this message translates to:
  /// **'costs'**
  String get homeVisualWaypointCosts;

  /// No description provided for @homeVisualWaypointRoute.
  ///
  /// In en, this message translates to:
  /// **'route'**
  String get homeVisualWaypointRoute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

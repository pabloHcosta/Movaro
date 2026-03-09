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
  /// **'Initializing experience'**
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
  /// **'Movaro uses this choice to shape the right experience for you. Today the beta is open for Argentina -> Brazil, but the structure is already global.'**
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
  /// **'Choose the country you want to evaluate. Home and planning will reflect that destination.'**
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
  /// **'Select origin and destination to continue.'**
  String get journeySummaryPlaceholder;

  /// No description provided for @journeyAvailabilityNote.
  ///
  /// In en, this message translates to:
  /// **'Today only the Argentina -> Brazil route is fully available. Other countries are already visible to signal the global direction of the product.'**
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
  /// **'First decide whether you need a guided plan, a city comparison, or just a quick overview of what the product does.'**
  String get publicHomePrimaryQuestionBody;

  /// No description provided for @publicHomeTrustFastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast start'**
  String get publicHomeTrustFastTitle;

  /// No description provided for @publicHomeTrustFastBody.
  ///
  /// In en, this message translates to:
  /// **'You can begin without a long form or a blocked first session.'**
  String get publicHomeTrustFastBody;

  /// No description provided for @publicHomeTrustGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'No login now'**
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
  /// **'Your navigation is now contextualized for {origin} -> {destination}, without pushing irrelevant content before you choose.'**
  String publicHomeTrustSelectedBody(String origin, String destination);

  /// No description provided for @publicHomeFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your first step'**
  String get publicHomeFirstStepTitle;

  /// No description provided for @publicHomeFirstStepBody.
  ///
  /// In en, this message translates to:
  /// **'The home screen should orient entry. Deeper content comes later inside the path you choose.'**
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
  /// **'You can explore all of this without signing in. Sign in appears only when it makes sense to save something personal.'**
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
  /// **'See suggestions by cost, work and popularity among Argentinians.'**
  String get publicHomeCitiesBody;

  /// No description provided for @publicHomeCitiesAction.
  ///
  /// In en, this message translates to:
  /// **'See cities'**
  String get publicHomeCitiesAction;

  /// No description provided for @publicHomePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Build my plan'**
  String get publicHomePlanTitle;

  /// No description provided for @publicHomePlanBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and get a simple starting point.'**
  String get publicHomePlanBody;

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
  /// **'People moving abroad usually want quick first answers about language, cost, paperwork and work. Movaro should make that obvious.'**
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
  /// **'The questionnaire and city ranking help narrow the search to places with better early fit.'**
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
  /// **'Go straight to cities and use cost, rent, language, and work signals as your first reading.'**
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
  /// **'The guided plan reduces uncertainty into one first city and a short order of first steps.'**
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
  /// **'Migration checklist'**
  String get exploreChecklistTitle;

  /// No description provided for @exploreChecklistDescription.
  ///
  /// In en, this message translates to:
  /// **'Guests can answer a short flow and generate an initial migration plan before signing in.'**
  String get exploreChecklistDescription;

  /// No description provided for @exploreQuestionnaireAction.
  ///
  /// In en, this message translates to:
  /// **'Start questionnaire'**
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
  /// **'See rent, SUS, CPF, work, driving, and first costs in clearer blocks with less noise.'**
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
  /// **'Since you already confirmed a city, this track focuses on checklist, documents, housing, and arrival.'**
  String get exploreTrailPrepBodyReady;

  /// No description provided for @exploreSavePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get exploreSavePlanAction;

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
  /// **'What usually unlocks practical life in Brazil'**
  String get documentationHeroTitle;

  /// No description provided for @documentationHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'No endless text. This page covers documents, health, mobility, and approximate costs for the things that usually matter first when someone plans to live in Brazil.'**
  String get documentationHeroDescription;

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
  /// **'Read approximate costs in reais, pesos, and dollars without confusing reference with final price.'**
  String get documentationPathCostsBody;

  /// No description provided for @documentationOpenTopicAction.
  ///
  /// In en, this message translates to:
  /// **'Open topic'**
  String get documentationOpenTopicAction;

  /// No description provided for @documentationQuickAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick answers for the most common doubts'**
  String get documentationQuickAnswersTitle;

  /// No description provided for @documentationQuickAnswersBody.
  ///
  /// In en, this message translates to:
  /// **'Before opening every card, start with these short answers. If one already solves your question, you save time.'**
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
  /// **'No. The protocol already matters while the CRNM is being produced, so the process does not depend on an instant card.'**
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
  /// **'Not necessarily. Registration helps follow-up care, but initial access and especially urgent care should not depend on having everything ready.'**
  String get documentationAnswerSusCardAnswer;

  /// No description provided for @documentationAnswerForeignLicenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I drive at first with my foreign license?'**
  String get documentationAnswerForeignLicenseQuestion;

  /// No description provided for @documentationAnswerForeignLicenseAnswer.
  ///
  /// In en, this message translates to:
  /// **'In general, yes for a limited period, with a valid document and subject to the applicable agreement. After that, it is better to confirm with the state Detran.'**
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
  /// **'Does formal employment still exist and how does it work?'**
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

  /// No description provided for @documentationAnswerInssQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is public retirement in Brazil the INSS?'**
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
  /// **'Public health vs private health'**
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
  /// **'It helps to separate your work model from the way you contribute. Formal employment, CNPJ-based work, and INSS contribution are related, but not the same thing.'**
  String get documentationWorkSectionBody;

  /// No description provided for @documentationDrivingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How to think about driving without overcomplicating it'**
  String get documentationDrivingSectionTitle;

  /// No description provided for @documentationDrivingSectionBody.
  ///
  /// In en, this message translates to:
  /// **'The safest flow is to split this into three questions: can I drive now, what must I validate in the state, and when is it worth starting the Brazilian license process.'**
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
  /// **'When a national value or useful official reference exists, the app shows an approximate conversion to support your first reading.'**
  String get documentationCostsBody;

  /// No description provided for @documentationCostsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Approximate exchange updated at {value}'**
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
  /// **'There is no single national price. Age, coverage, network, and waiting periods can change the final cost a lot.'**
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
  /// **'The CRNM may take around 30 business days to be produced; the official service allows a longer total window and the protocol preserves rights.'**
  String get documentationRegistrationBulletThree;

  /// No description provided for @documentationStayTitle.
  ///
  /// In en, this message translates to:
  /// **'How long can I stay'**
  String get documentationStayTitle;

  /// No description provided for @documentationStaySummary.
  ///
  /// In en, this message translates to:
  /// **'For an Argentinian user, the practical path is usually regular residence instead of relying on visitor stay.'**
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
  /// **'A bank may request additional documents; CPF helps, but a regular migration document usually matters in onboarding.'**
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
  /// **'Public health in Brazil is not a prepaid entry plan. The logic is universal access, with different entry points depending on what you need.'**
  String get documentationHealthPublicSummary;

  /// No description provided for @documentationHealthPublicBulletOne.
  ///
  /// In en, this message translates to:
  /// **'SUS provides universal access, including for foreign nationals in Brazil.'**
  String get documentationHealthPublicBulletOne;

  /// No description provided for @documentationHealthPublicBulletTwo.
  ///
  /// In en, this message translates to:
  /// **'A UBS or local health post is usually the first door for routine care, follow-up, vaccines, and basic care.'**
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
  /// **'Fees and final cost vary by Detran and driving school, so treat the displayed value only as orientation.'**
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
  /// **'Movaro keeps exploration open. Sign in appears only when you want to save something personal.'**
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
  /// **'Your context'**
  String get onboardingPageTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s understand your moment'**
  String get onboardingHeadline;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'This helps make the experience more useful without asking for too much information.'**
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
  /// **'Search city'**
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
  /// **'Your first plan'**
  String get questionnairePageTitle;

  /// No description provided for @questionnaireLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparing your questions'**
  String get questionnaireLoadingLabel;

  /// No description provided for @questionnaireSupportText.
  ///
  /// In en, this message translates to:
  /// **'It takes less than a minute. One question at a time.'**
  String get questionnaireSupportText;

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
  /// **'Separate passport, criminal records, apostille needs, and the documents that may still require translation.'**
  String get readinessItemDocumentsBody;

  /// No description provided for @readinessItemBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress-test your landing budget'**
  String get readinessItemBudgetTitle;

  /// No description provided for @readinessItemBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Estimate what the first 30 to 90 days will demand, not just monthly living cost after you are settled.'**
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
  /// **'Focus on the Portuguese needed for daily friction points like housing, transport, banking, and services.'**
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
  /// **'Prioritize health access, neighborhood routine, recurring costs, and the paperwork that protects a calm arrival.'**
  String get readinessGoalRetireBody;

  /// No description provided for @readinessGoalQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn quality of life into criteria'**
  String get readinessGoalQualityTitle;

  /// No description provided for @readinessGoalQualityBody.
  ///
  /// In en, this message translates to:
  /// **'Convert lifestyle into real filters: safety, daily routine, language adaptation, and the cost of staying longer-term.'**
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
  /// **'CPF helps, but CRNM, protocol, or another regular document can influence approval.'**
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
  /// **'This step works best as a practical validation inside your move preparation.'**
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
  /// **'Temporary saved plans in this session: {count}'**
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

  /// No description provided for @citiesLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading cities'**
  String get citiesLoadingLabel;

  /// No description provided for @citiesMethodologyNote.
  ///
  /// In en, this message translates to:
  /// **'Rankings based on public data and Movaro methodology.'**
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
  /// **'Good if you want a more urban rhythm'**
  String get citiesHighlightMetropolisLabel;

  /// No description provided for @citiesHighlightInlandLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you want a calmer routine'**
  String get citiesHighlightInlandLabel;

  /// No description provided for @citiesHighlightBorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Good if you want a border-city read'**
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

  /// No description provided for @cityLifestyleCoastalLabel.
  ///
  /// In en, this message translates to:
  /// **'Coastal lifestyle'**
  String get cityLifestyleCoastalLabel;

  /// No description provided for @cityLifestyleMetropolisLabel.
  ///
  /// In en, this message translates to:
  /// **'Metropolitan rhythm'**
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

  /// No description provided for @cityDetailSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick view'**
  String get cityDetailSnapshotTitle;

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

  /// No description provided for @citySourceTerritorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Territorial identity'**
  String get citySourceTerritorialTitle;

  /// No description provided for @citySourceTerritorialDescription.
  ///
  /// In en, this message translates to:
  /// **'Official name, state, IBGE code and municipal region.'**
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
  /// **'Official municipal HDI with 2010 Census reference.'**
  String get citySourceHumanDevelopmentDescription;

  /// No description provided for @citySourceCuratedMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Curated product metrics'**
  String get citySourceCuratedMetricsTitle;

  /// No description provided for @citySourceCuratedMetricsDescription.
  ///
  /// In en, this message translates to:
  /// **'It currently comes from Movaro\'s curated dataset. The priority official replacements are Atlas da Violencia (safety), Novo Caged (jobs), FipeZAP (rent) and IBGE PIB dos Municipios (economic activity).'**
  String get citySourceCuratedMetricsDescription;

  /// No description provided for @citySourceRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring methodology'**
  String get citySourceRankingTitle;

  /// No description provided for @citySourceRankingDescription.
  ///
  /// In en, this message translates to:
  /// **'Movaro scores calculated over public data and a curated dataset.'**
  String get citySourceRankingDescription;

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

  /// No description provided for @cityDetailCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare other cities'**
  String get cityDetailCompareAction;

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
  /// **'Movaro helps you compare cities, understand practical bureaucracy, and build a first migration direction without starting from information overload.'**
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
  /// **'Skip introduction'**
  String get introSkipAction;

  /// No description provided for @cityPracticalAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick answers for common doubts'**
  String get cityPracticalAnswersTitle;

  /// No description provided for @cityPracticalLanguageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would daily life feel easier if I still depend on Spanish?'**
  String get cityPracticalLanguageQuestion;

  /// No description provided for @cityPracticalCostQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does this city look manageable in day-to-day cost?'**
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
  /// **'It needs more caution before assuming strong overall structure.'**
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
  /// **'It asks for balance between neighborhood, contract, and routine.'**
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
  /// **'It can work well if you arrive with reserve and validate neighborhood, guarantee, and total setup cost before signing.'**
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
  /// **'Here, rent and entry cost tend to weigh more. Treat housing as a serious filter before choosing the city.'**
  String get cityHousingViabilityHardSupporting;

  /// No description provided for @cityHousingViabilityHardBadge.
  ///
  /// In en, this message translates to:
  /// **'High housing pressure'**
  String get cityHousingViabilityHardBadge;

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
  /// **'It has a reasonable familiarity within the current catalog.'**
  String get citySnapshotPopularityMediumSupporting;

  /// No description provided for @citySnapshotPopularityLow.
  ///
  /// In en, this message translates to:
  /// **'Less recurring'**
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

  /// No description provided for @questionOptionUnknown.
  ///
  /// In en, this message translates to:
  /// **'I still don\'t know'**
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
  /// **'Balanced option within the initial Movaro catalog'**
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
  /// **'It fits better if you are prioritizing quality of life and a gradual adaptation.'**
  String get planReasonGoalQualityOfLife;

  /// No description provided for @planReasonGoalBeachLife.
  ///
  /// In en, this message translates to:
  /// **'It makes more sense if you want to prioritize coast, beach, and a routine more connected to the sea.'**
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
  /// **'It may help with a faster move by combining easier early adaptation and practical daily life.'**
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
  /// **'Set up a local account for your first financial moves.'**
  String get planStepDescriptionBankAccount;

  /// No description provided for @planStepTitleHousing.
  ///
  /// In en, this message translates to:
  /// **'Look for housing'**
  String get planStepTitleHousing;

  /// No description provided for @planStepDescriptionHousing.
  ///
  /// In en, this message translates to:
  /// **'Research neighborhoods, contracts and costs for a safer move.'**
  String get planStepDescriptionHousing;

  /// No description provided for @planStepTitleSettleDocuments.
  ///
  /// In en, this message translates to:
  /// **'Regularize local documents'**
  String get planStepTitleSettleDocuments;

  /// No description provided for @planStepDescriptionSettleDocuments.
  ///
  /// In en, this message translates to:
  /// **'Review additional registrations, proof documents and local administrative steps.'**
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
  /// **'Organize priorities such as cost, paperwork and quality of life.'**
  String get planStepDescriptionDecisionCriteria;

  /// No description provided for @planBeachDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coastline in the decision'**
  String get planBeachDecisionTitle;

  /// No description provided for @planBeachDecisionIntro.
  ///
  /// In en, this message translates to:
  /// **'If beach and coast are part of your criteria, do not look only at beauty or tourism. The real filter is housing entry, city rhythm, and soft landing.'**
  String get planBeachDecisionIntro;

  /// No description provided for @planBeachDecisionCoastalHeadline.
  ///
  /// In en, this message translates to:
  /// **'The recommendation already points to the coast'**
  String get planBeachDecisionCoastalHeadline;

  /// No description provided for @planBeachDecisionCoastalBody.
  ///
  /// In en, this message translates to:
  /// **'{cityName} already fits the coastal city cut. The next filter is understanding whether housing entry and local routine match your current moment.'**
  String planBeachDecisionCoastalBody(Object cityName);

  /// No description provided for @planBeachDecisionNotCoastalHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your beach criterion needs an extra comparison'**
  String get planBeachDecisionNotCoastalHeadline;

  /// No description provided for @planBeachDecisionNotCoastalBody.
  ///
  /// In en, this message translates to:
  /// **'Even with this goal, it is worth comparing beach cities before closing the decision. Not every strong plan city delivers the coastal routine you may be looking for.'**
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

  /// No description provided for @sourceProviderReceitaFederalGovBr.
  ///
  /// In en, this message translates to:
  /// **'Federal Revenue / Gov.br'**
  String get sourceProviderReceitaFederalGovBr;

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
  /// **'Six months is enough to organize the hard documents now and leave the arrival layer lighter.'**
  String get documentReadinessSummarySixMonths;

  /// No description provided for @documentReadinessSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'Since the move is close, focus on the documents that can block residency, banking, and housing before anything else.'**
  String get documentReadinessSummaryAsap;

  /// No description provided for @documentReadinessRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Validate the legal entry route'**
  String get documentReadinessRouteTitle;

  /// No description provided for @documentReadinessRouteBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'Confirm whether your move will rely on the Mercosur residence path and what that route demands before you book around assumptions.'**
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
  /// **'Keep passport, birth records, criminal records, and personal identifiers in one reviewed bundle before opening other fronts.'**
  String get documentReadinessIdentityPackBody;

  /// No description provided for @documentReadinessApostilleTitle.
  ///
  /// In en, this message translates to:
  /// **'Review apostille and validity windows'**
  String get documentReadinessApostilleTitle;

  /// No description provided for @documentReadinessApostilleBodyBrazil.
  ///
  /// In en, this message translates to:
  /// **'For Brazil, check which Argentine documents need apostille, how recent they must be, and what can expire before arrival.'**
  String get documentReadinessApostilleBodyBrazil;

  /// No description provided for @documentReadinessRuleCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check official document rules early'**
  String get documentReadinessRuleCheckTitle;

  /// No description provided for @documentReadinessRuleCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Map which documents must be original, apostilled, translated, or issued again so the move does not depend on assumptions.'**
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
  /// **'Group proof of income, reserve, identification, and any supporting papers that landlords, banks, or guarantee products may ask for in Brazil.'**
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
  /// **'CPF, residency follow-up, and your first local proof often unlock the practical side of arrival. Keep that bundle ready to execute fast.'**
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
  /// **'Review what can block early work in Brazil: identity consistency, residence follow-up, and any profession-specific proof you may need to show fast.'**
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
  /// **'Keep admissions, school records, identity documents, and timing-sensitive paperwork aligned before relying on study as the entry path.'**
  String get documentReadinessGoalStudyBodyBrazil;

  /// No description provided for @documentReadinessGoalStudyBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Keep admissions, school records, identity documents, and timing-sensitive paperwork aligned before relying on study as the base.'**
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
  /// **'Protect calm arrival with reviewed paperwork'**
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
  /// **'Before choosing the city, understand how rent and guarantees work in Brazil. The biggest risk is not only monthly price: it is landing without a viable path for contract, neighborhood, and initial setup.'**
  String get housingDecisionSectionBody;

  /// No description provided for @housingDecisionSectionBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'Before assuming {city} is the best option, validate whether rent, guarantees, and initial setup look viable for your moment. The risk is not only price, but the real path to secure housing.'**
  String housingDecisionSectionBodyWithCity(Object city);

  /// No description provided for @housingDecisionGuaranteesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guarantees can block the lease'**
  String get housingDecisionGuaranteesTitle;

  /// No description provided for @housingDecisionGuaranteesBody.
  ///
  /// In en, this message translates to:
  /// **'A local guarantor still matters in many contracts. If that is not realistic for you, compare deposit, guarantee insurance, capitalization products, and income proof demands before counting on a neighborhood.'**
  String get housingDecisionGuaranteesBody;

  /// No description provided for @housingDecisionSoftLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'A softer landing avoids expensive mistakes'**
  String get housingDecisionSoftLandingTitle;

  /// No description provided for @housingDecisionSoftLandingBody.
  ///
  /// In en, this message translates to:
  /// **'Temporary, furnished, coliving, or short contracts for 30 to 90 days are usually safer than taking a long lease before you understand local routine.'**
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
  /// **'Movaro currently organizes the context to help you decide better. Contract terms, accepted guarantees, and each landlord or platform policy still need to be validated at the source before signing housing.'**
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
  /// **'A rent that looks affordable in the listing can demand much more upfront. Use this view to simulate deposit, guarantee insurance, or a temporary landing before deciding on the city.'**
  String get housingEntrySectionBody;

  /// No description provided for @housingEntrySectionBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'In {city}, do not look only at monthly rent. Use this view to estimate what upfront entry may require with deposit, guarantee insurance, or a temporary landing.'**
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
  /// **'Typical reading when the lease asks for roughly 3 months of deposit plus the first month.'**
  String get housingEntryModeDepositBody;

  /// No description provided for @housingEntryModeInsuranceBody.
  ///
  /// In en, this message translates to:
  /// **'Typical reading when a guarantor is replaced by an annual insurance or digital guarantee fee.'**
  String get housingEntryModeInsuranceBody;

  /// No description provided for @housingEntryModeTemporaryBody.
  ///
  /// In en, this message translates to:
  /// **'A lighter reading for the first 30 to 90 days, prioritizing flexibility before taking a long lease.'**
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
  /// **'Land through short stay or serviced flat'**
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
  /// **'Without a guarantor, the strongest argument is usually deposit, guarantee insurance, capitalization title, or a few months paid upfront. The point is not to overpromise, but to arrive with a credible structure.'**
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
  /// **'Use this as a directional reserve reference so your move is not being designed only around monthly cost after everything is already stable.'**
  String get landingBudgetSummaryResearching;

  /// No description provided for @landingBudgetSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'With more time, the goal is to shape a realistic reserve and remove the shock of setup costs before the move gets close.'**
  String get landingBudgetSummaryTwelveMonths;

  /// No description provided for @landingBudgetSummarySixMonths.
  ///
  /// In en, this message translates to:
  /// **'Six months is enough to turn the move into a budgeted plan instead of a sequence of reactive expenses.'**
  String get landingBudgetSummarySixMonths;

  /// No description provided for @landingBudgetSummaryAsap.
  ///
  /// In en, this message translates to:
  /// **'Since the move is close, the reserve matters as much as the city choice. Use this estimate to avoid arriving with a short runway.'**
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
  /// **'These estimates are directional, not official prices. They combine city signals, setup pressure, and timeline risk to help you plan reserve before the move.'**
  String get landingBudgetDisclaimer;

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
  /// **'This is the execution layer after arrival. Use it now to understand what the first weeks will need from you beyond paperwork.'**
  String get arrivalExecutionSummaryResearching;

  /// No description provided for @arrivalExecutionSummaryTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'With more time, this layer helps you picture what settling in will demand so the move is not planned only on paperwork and budget.'**
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
  /// **'Learn the first transport routine'**
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
  /// **'Validate internet reliability, quiet routine, banking flow, and the real cost of maintaining remote work from the new city.'**
  String get arrivalExecutionGoalRemoteBody;

  /// No description provided for @arrivalExecutionGoalStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn arrival into a study routine'**
  String get arrivalExecutionGoalStudyTitle;

  /// No description provided for @arrivalExecutionGoalStudyBody.
  ///
  /// In en, this message translates to:
  /// **'Use the first month to confirm whether enrollment, commute, classes, and daily cost still support study as the base plan.'**
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
  /// **'Turn arrival into predictable routine'**
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
  /// **'Use the first month to verify whether the city feels good in daily life, not only on paper or in rankings.'**
  String get arrivalExecutionGoalQualityBody;

  /// No description provided for @arrivalExecutionRealityCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Do a reality check at 90 days'**
  String get arrivalExecutionRealityCheckTitle;

  /// No description provided for @arrivalExecutionRealityCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Compare your real cost, routine friction, and city fit against what the plan suggested. This is where the move stops being hypothetical.'**
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
  /// **'If the city, cost, or rhythm is not matching the original plan, adjust direction before temporary friction becomes your default.'**
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
  /// **'Your last plan is still here, with {city} ({state}) as the current city lead. Reopen it to continue the checklist, document readiness, and landing budget.'**
  String publicHomeResumePlanBodyWithCity(String city, String state);

  /// No description provided for @publicHomeRetakePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Rebuild plan'**
  String get publicHomeRetakePlanAction;

  /// No description provided for @migrationPlanCopilotTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided preparation'**
  String get migrationPlanCopilotTitle;

  /// No description provided for @migrationPlanCopilotAction.
  ///
  /// In en, this message translates to:
  /// **'Open preparation'**
  String get migrationPlanCopilotAction;

  /// No description provided for @migrationPlanCopilotIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'When you want to move from decision to execution'**
  String get migrationPlanCopilotIntroTitle;

  /// No description provided for @migrationPlanCopilotIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This stage organizes checklist, documents, housing, and landing reserve. Use it when you are ready to start preparing the move.'**
  String get migrationPlanCopilotIntroBody;

  /// No description provided for @migrationPlanCopilotIntroBodyWithCity.
  ///
  /// In en, this message translates to:
  /// **'This stage organizes checklist, documents, housing, and landing reserve with {city} ({state}) as the main reference of your plan.'**
  String migrationPlanCopilotIntroBodyWithCity(String city, String state);

  /// No description provided for @migrationPlanCopilotResultBody.
  ///
  /// In en, this message translates to:
  /// **'First check whether the recommended city really fits your context. When you want to turn that decision into concrete preparation, open the guided layer with checklist, documents, and arrival reserve.'**
  String get migrationPlanCopilotResultBody;

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
  /// **'If you decide to move forward with {city}, the copilot opens checklist, documents, housing, and arrival reserve focused on that city.'**
  String migrationPlanPreparationBody(Object city);

  /// No description provided for @languageSelectorSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSelectorSystem;
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

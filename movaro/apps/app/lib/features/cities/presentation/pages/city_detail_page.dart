import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/utils/number_formatters.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/city_cost_of_living_card.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_price_insight_service.dart';
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_seasonality_card.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_conflict_service.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_strength_story_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_map_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_insight_sheet.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_public_opinion_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_seasonality_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_snapshot_tile.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_sources_section.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/landing_budget_estimator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';

class CityDetailPage extends StatefulWidget {
  const CityDetailPage({
    required this.cityId,
    required this.citiesController,
    required this.cityInsightsController,
    required this.locationController,
    this.migrationQuestionnaireController,
    this.selectForPlan = false,
    this.fromMigrationResult = false,
    this.validationFlow = false,
    super.key,
  });

  final String cityId;
  final CitiesController citiesController;
  final CityInsightController cityInsightsController;
  final LocationController locationController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;
  final bool selectForPlan;

  /// When `true`, the user arrived from [MigrationResultRevealPage] to explore
  /// an alternative city. A compact confirmation bar is shown at the bottom so
  /// they can start the plan with this city without digging through the UI.
  final bool fromMigrationResult;
  final bool validationFlow;

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  static const _helpPreferenceKey = 'city_detail';
  City? _city;
  List<CityInsightEntity> _cityInsights = const [];
  List<CityInsightExplorePlaceEntity> _neighborhoodPlaces = const [];
  final ScrollController _scrollController = ScrollController();
  late Future<bool> _locationBannerFuture;
  final ExpansibleController _analysisTileController = ExpansibleController();
  final GlobalKey<_SecondaryContentSectionState> _secondaryContentKey =
      GlobalKey<_SecondaryContentSectionState>();
  final _snapshotSectionKey = GlobalKey();
  final _summarySectionKey = GlobalKey();
  final _categoriesSectionKey = GlobalKey();
  final _strengthsSectionKey = GlobalKey();
  final _arrivalSectionKey = GlobalKey();
  final _narrativeSectionKey = GlobalKey();
  final _climateSectionKey = GlobalKey();
  final _socialSectionKey = GlobalKey();
  final _neighborhoodSectionKey = GlobalKey();
  final _compareSectionKey = GlobalKey();
  final _flightBurdenSectionKey = GlobalKey();
  final _mapSectionKey = GlobalKey();
  final _costSectionKey = GlobalKey();
  final _flightsSectionKey = GlobalKey();
  final _seasonalitySectionKey = GlobalKey();
  final _opinionSectionKey = GlobalKey();
  final _analysisSectionKey = GlobalKey();
  final _sourcesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _locationBannerFuture = widget.locationController.shouldShowInlineBanner();
    widget.locationController.addListener(_handleLocationChanged);
    _load();
  }

  @override
  void dispose() {
    widget.locationController.removeListener(_handleLocationChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLocationChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _locationBannerFuture = widget.locationController
          .shouldShowInlineBanner();
    });
  }

  Future<void> _load() async {
    final cityFuture = widget.citiesController.loadCityById(widget.cityId);
    final methodologyFuture = widget.citiesController.loadMethodology();
    final city = await cityFuture;

    if (!mounted) {
      return;
    }

    setState(() {
      _city = city;
    });

    if (city != null) {
      unawaited(_prefetchCitySignals(city));
      unawaited(_loadCityInsightContext(city));
    }

    await methodologyFuture;
  }

  Future<void> _prefetchCitySignals(City city) async {
    final plan = widget.migrationQuestionnaireController?.generatedPlan;
    final savedLocation = widget.locationController.savedLocation;
    final originCountryIso = FlightRouteContextResolver.resolveOriginCountryIso(
      savedCountryCode: savedLocation?.countryCode,
      planOriginCountry: plan?.originCountry,
    );
    final originAirport = FlightRouteContextResolver.resolveOriginAirport(
      savedLocation: savedLocation,
      originCountryIso: originCountryIso,
    );
    final destinationAirport =
        FlightRouteContextResolver.resolveDestinationAirport(
          destinationCityName: city.name,
          destinationCountryIso:
              FlightRouteContextResolver.resolveDestinationCountryIso(
                cityCountryCode: city.countryCode,
                planDestinationCountry: plan?.destinationCountry,
              ),
          destinationLatitude: city.latitude,
          destinationLongitude: city.longitude,
        );

    final requests = <Future<Object?>>[
      widget.citiesController.loadWeatherForCity(city.id),
    ];

    if (originAirport?.iataCode != null &&
        destinationAirport?.iataCode != null) {
      requests.add(
        widget.citiesController.loadTravelInsightForCity(
          city.id,
          originIata: originAirport?.iataCode,
          destIata: destinationAirport?.iataCode,
        ),
      );
    }

    await Future.wait(requests);
  }

  Future<void> _loadCityInsightContext(City city) async {
    final locale = Localizations.localeOf(context).languageCode;
    final plan = widget.migrationQuestionnaireController?.generatedPlan;
    final comparisonIds = _comparisonCitiesFor(
      city,
    ).map((item) => item.id).toList(growable: false);

    try {
      final loadInsights = widget.cityInsightsController.load(
        cityId: city.id,
        goal: plan?.goal,
        timeline: plan?.timeline,
        locale: locale,
      );
      final loadSocialProof = widget.citiesController.loadCityDetailSocialProof(
        city.id,
        locale: locale,
        goal: plan?.goal,
        timeline: plan?.timeline,
      );
      final loadClimate = widget.citiesController.loadCityDetailClimateSummary(
        city.id,
        locale: locale,
      );
      final loadArrival = widget.citiesController.loadCityDetailArrivalStory(
        city.id,
        locale: locale,
        goal: plan?.goal,
        timeline: plan?.timeline,
      );
      final loadComparison = comparisonIds.isEmpty
          ? Future<CityDetailComparison?>.value(null)
          : widget.citiesController.loadCityDetailComparison(
              city.id,
              compareTo: comparisonIds,
              locale: locale,
            );

      await loadInsights;
      final placesFuture = widget.cityInsightsController.getExplorePlaces(
        cityId: city.id,
        theme: CityInsightTheme.neighborhoods,
        locale: locale,
      );
      final places = await placesFuture;
      await Future.wait([
        loadSocialProof,
        loadClimate,
        loadArrival,
        loadComparison,
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _cityInsights = List<CityInsightEntity>.from(
          widget.cityInsightsController.items,
        );
        _neighborhoodPlaces = places;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cityInsights = List<CityInsightEntity>.from(
          widget.cityInsightsController.items,
        );
      });
    }
  }

  Future<void> _showHelp() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
  }

  ContextualHelpContent _helpContent(BuildContext context) {
    return ContextualHelpContent(
      eyebrow: context.l10n.cityDetailGuideEyebrow(),
      contextIcon: Icons.location_city_outlined,
      title: context.l10n.cityDetailGuideTitle(),
      body: context.l10n.cityDetailGuideBody(),
      steps: [
        FeatureGuideStep(
          number: '1',
          title: context.l10n.cityDetailGuideStepOneTitle(),
          body: context.l10n.cityDetailGuideStepOneBody(),
        ),
        FeatureGuideStep(
          number: '2',
          title: context.l10n.cityDetailGuideStepTwoTitle(),
          body: context.l10n.cityDetailGuideStepTwoBody(),
        ),
        FeatureGuideStep(
          number: '3',
          title: context.l10n.cityDetailGuideStepThreeTitle(),
          body: context.l10n.cityDetailGuideStepThreeBody(),
        ),
      ],
    );
  }

  DetectedLocation? _resolvedDetectedLocation() {
    final journeyDetected = widget
        .migrationQuestionnaireController
        ?.journeyContextController
        .detectedLocation;
    if (journeyDetected?.latitude != null &&
        journeyDetected?.longitude != null) {
      return journeyDetected;
    }

    final saved = widget.locationController.savedLocation;
    if (saved == null) {
      return journeyDetected;
    }

    return DetectedLocation(
      countryName: saved.countryName,
      countryId: saved.countryCode,
      city: saved.cityName,
      region: saved.stateName,
      latitude: saved.latitude,
      longitude: saved.longitude,
      detectedAt: null,
    );
  }

  Future<void> _openCityMapSheet(City city) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _CityMapBottomSheet(
          city: city,
          detectedLocation: _resolvedDetectedLocation(),
        ),
      ),
    );
  }

  Future<void> _openAnalysisSection() async {
    await _navigateToSection(
      _analysisSectionKey,
      expandSecondary: true,
      expandAnalysis: true,
    );
  }

  Future<void> _ensureSecondaryExpanded() async {
    final state = _secondaryContentKey.currentState;
    if (state == null || state.isExpanded) {
      return;
    }
    await state.expandAndWait();
  }

  Future<void> _openSecondarySection(GlobalKey key) async {
    await _navigateToSection(key, expandSecondary: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final city = _city;
        final l10n = context.l10n;
        final localeName = Localizations.localeOf(context).toString();
        final planContext = city == null
            ? null
            : _resolvePlanContext(context, city);
        final plan = widget.migrationQuestionnaireController?.generatedPlan;
        final locale = Localizations.localeOf(context).languageCode;
        final savedLocation = widget.locationController.savedLocation;
        final originCountryIso =
            FlightRouteContextResolver.resolveOriginCountryIso(
              savedCountryCode: savedLocation?.countryCode,
              planOriginCountry: plan?.originCountry,
            );
        final originAirport = FlightRouteContextResolver.resolveOriginAirport(
          savedLocation: savedLocation,
          originCountryIso: originCountryIso,
        );
        final destinationAirport = city == null
            ? null
            : FlightRouteContextResolver.resolveDestinationAirport(
                destinationCityName: city.name,
                destinationCountryIso:
                    FlightRouteContextResolver.resolveDestinationCountryIso(
                      cityCountryCode: city.countryCode,
                      planDestinationCountry: plan?.destinationCountry,
                    ),
                destinationLatitude: city.latitude,
                destinationLongitude: city.longitude,
              );
        final routeInsight = city == null
            ? null
            : widget.citiesController.travelInsightFor(
                city.id,
                originIata: originAirport?.iataCode,
                destIata: destinationAirport?.iataCode,
              );
        final budget = city?.budgetSnapshot;
        final strengths = city == null
            ? const <CityStrengthSignal>[]
            : CityStrengthStoryService.strongest(context, city);
        final comparisonCities = city == null
            ? const <City>[]
            : _comparisonCitiesFor(city);
        final detailContextKey = city == null
            ? null
            : widget.citiesController.cityDetailContextKey(
                city.id,
                locale: locale,
                goal: plan?.goal,
                timeline: plan?.timeline,
              );
        final comparisonKey = city == null
            ? null
            : widget.citiesController.cityDetailComparisonKey(
                city.id,
                compareTo: comparisonCities.map((item) => item.id).toList(),
                locale: locale,
              );
        final socialProof = detailContextKey == null
            ? null
            : widget.citiesController.socialProofFor(detailContextKey);
        final climateSummary = detailContextKey == null
            ? null
            : widget.citiesController.climateSummaryFor(detailContextKey);
        final arrivalStory = detailContextKey == null
            ? null
            : widget.citiesController.arrivalStoryFor(detailContextKey);
        final comparison = comparisonKey == null
            ? null
            : widget.citiesController.comparisonFor(comparisonKey);
        final quickActions = city == null
            ? const <_DetailQuickAction>[]
            : _buildQuickActions(
                context,
                city: city,
                strengths: strengths,
                budget: budget,
                routeInsight: routeInsight,
                comparisonCities: comparisonCities,
              );

        return Scaffold(
          bottomNavigationBar: (widget.fromMigrationResult && city != null)
              ? _MigrationResultBar(
                  city: city,
                  controller: widget.migrationQuestionnaireController,
                )
              : null,
          body: Stack(
            children: [
              const AmbientBackground(),

              // ── Main content ───────────────────────────────────────────────
              if (city == null)
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      72,
                      context.pageHorizontalPadding,
                      context.pageVerticalPadding,
                    ),
                    child: widget.citiesController.cityError != null
                        ? Builder(
                            builder: (context) {
                              final error = ErrorHandler.resolve(
                                context,
                                widget.citiesController.cityError!,
                              );
                              return ErrorStateWidget(
                                title: error.title,
                                description: error.description,
                                illustrationAsset: error.illustrationAsset,
                                onRetry: error.isRetryable ? _load : null,
                                onBack: () => Navigator.pop(context),
                              );
                            },
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: const DetailSkeleton(),
                          ),
                  ),
                )
              else
                Column(
                  children: [
                    // ── Full-width hero ─────────────────────────────────────
                    _DetailHeroSection(
                      city: city,
                      scrollController: _scrollController,
                      citiesController: widget.citiesController,
                      onToggleFavorite: () =>
                          _toggleFavoriteCity(context, city),
                    ),
                    if (quickActions.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          12,
                          context.pageHorizontalPadding,
                          0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1160),
                          child: _SecondaryActionsRow(actions: quickActions),
                        ),
                      ),
                    // ── Scrollable panels ───────────────────────────────────
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          16,
                          context.pageHorizontalPadding,
                          context.pageVerticalPadding + 96,
                        ),
                        children: [
                          if (widget.validationFlow && planContext == null) ...[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: FrostedPanel(
                                child: _ValidationFlowBanner(city: city),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // ── Block 1: CTA Principal ──────────────────────
                          // ── Block 1: Decision verdict ───────────────────
                          ConstrainedBox(
                            key: _snapshotSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _DecisionSnapshotPanel(
                              city: city,
                              planContext: planContext,
                              plan: plan,
                              budget: budget,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Block 2: Compact evidence ───────────────────
                          ConstrainedBox(
                            key: _summarySectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _QuickSummaryCard(
                              city: city,
                              plan: plan,
                              alternatives: comparisonCities,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            key: _categoriesSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _CategoryListCard(city: city),
                          ),
                          const SizedBox(height: 12),

                          // ── Block 3: Cost of Living (always visible) ────
                          if (budget case final budget?) ...[
                            ConstrainedBox(
                              key: _costSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityCostOfLivingCard(
                                budget: budget,
                                preferredCountryId: plan?.originCountry,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ── Block 4: Arrival viability (always visible) ─
                          ConstrainedBox(
                            key: _arrivalSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _ArrivalViabilityCard(
                              city: city,
                              budget: budget,
                              preferredCountryId: plan?.originCountry,
                              routeInsight: routeInsight,
                              insights: _cityInsights,
                              arrivalStory: arrivalStory,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ConstrainedBox(
                            key: _narrativeSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _CityNarrativeCard(
                              city: city,
                              plan: plan,
                              planContext: planContext,
                              insights: _cityInsights,
                              arrivalStory: arrivalStory,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ConstrainedBox(
                            key: _climateSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _ClimateSummaryCard(
                              city: city,
                              weather: widget.citiesController.weatherFor(
                                city.id,
                              ),
                              climateSummary: climateSummary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ConstrainedBox(
                            key: _socialSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _PeopleLikeYouCard(
                              city: city,
                              socialProof: socialProof,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ConstrainedBox(
                            key: _neighborhoodSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _NeighborhoodGuidanceCard(
                              city: city,
                              places: _neighborhoodPlaces,
                              insights: _cityInsights,
                              arrivalStory: arrivalStory,
                              socialProof: socialProof,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (strengths.isNotEmpty) ...[
                            ConstrainedBox(
                              key: _strengthsSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _CityStrengthsPanel(
                                city: city,
                                strengths: strengths,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (comparisonCities.isNotEmpty) ...[
                            ConstrainedBox(
                              key: _compareSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _InlineComparisonCard(
                                city: city,
                                plan: plan,
                                alternatives: comparisonCities,
                                comparison: comparison,
                                onCompare: () =>
                                    _handleCompareCity(context, city),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ── Block 5: CTA after evidence ──────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _CtaPrimaryRow(
                              city: city,
                              planContext: planContext,
                              validationFlow: widget.validationFlow,
                              onPrimaryAction: () =>
                                  _handlePrimaryPlanAction(context, city),
                              onCompareAction: () =>
                                  _handleCompareCity(context, city),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Secondary sections (progressive disclosure) ──
                          _SecondaryContentSection(
                            key: _secondaryContentKey,
                            cityName: city.name,
                            children: [
                              if (CitySeasonalityProfile.hasSeason(city)) ...[
                                ConstrainedBox(
                                  key: _seasonalitySectionKey,
                                  constraints: const BoxConstraints(
                                    maxWidth: 1160,
                                  ),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CitySeasonalitySection(
                                        city: city,
                                        locale: localeName.startsWith('pt')
                                            ? 'pt'
                                            : localeName.startsWith('es')
                                            ? 'es'
                                            : 'en',
                                        planTimeline: plan?.timeline,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Flight burden
                              if (routeInsight != null) ...[
                                ConstrainedBox(
                                  key: _flightBurdenSectionKey,
                                  constraints: const BoxConstraints(
                                    maxWidth: 1160,
                                  ),
                                  child: _FlightBurdenCard(
                                    routeInsight: routeInsight,
                                    budget: budget,
                                    preferredCountryId: plan?.originCountry,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Location banner
                              FutureBuilder<bool>(
                                future: _locationBannerFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.data != true) {
                                    return const SizedBox.shrink();
                                  }
                                  return ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1160,
                                    ),
                                    child: LocationBannerWidget(
                                      onActivate: () async {
                                        final granted = await Navigator.pushNamed(
                                          context,
                                          AppRoutes.locationPermission,
                                          arguments:
                                              const LocationPermissionScreenArgs(
                                                returnToPrevious: true,
                                              ),
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          _locationBannerFuture = widget
                                              .locationController
                                              .shouldShowInlineBanner();
                                        });
                                        if (granted == true &&
                                            widget
                                                    .locationController
                                                    .savedLocation !=
                                                null) {
                                          await _load();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              // Map
                              ConstrainedBox(
                                key: _mapSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: _CityLocationPanel(
                                  city: city,
                                  detectedLocation: _resolvedDetectedLocation(),
                                  isActivePlanCity:
                                      widget
                                          .migrationQuestionnaireController
                                          ?.generatedPlan
                                          ?.recommendedCity
                                          ?.id ==
                                      city.id,
                                  onOpenMap: () => _openCityMapSheet(city),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Public opinion
                              if (city.publicOpinion != null) ...[
                                ConstrainedBox(
                                  key: _opinionSectionKey,
                                  constraints: const BoxConstraints(
                                    maxWidth: 1160,
                                  ),
                                  child: CityPublicOpinionSection(
                                    opinion: city.publicOpinion!,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Deep Dive (Analysis)
                              ConstrainedBox(
                                key: _analysisSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: Card(
                                  child: ExpansionTile(
                                    controller: _analysisTileController,
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    childrenPadding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    title: Text(
                                      l10n.cityDetailDeepDiveTitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: _SnapshotPanel(
                                          city: city,
                                          localeName: localeName,
                                          showTitle: false,
                                        ),
                                      ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final wide =
                                              constraints.maxWidth >= 980;
                                          final detailWidth = wide
                                              ? (constraints.maxWidth - 16) / 2
                                              : constraints.maxWidth;
                                          return Wrap(
                                            spacing: 16,
                                            runSpacing: 16,
                                            children: [
                                              SizedBox(
                                                width: detailWidth,
                                                child: _WorkOpportunityPanel(
                                                  city: city,
                                                  budget: budget,
                                                ),
                                              ),
                                              SizedBox(
                                                width: detailWidth,
                                                child: _IdhmContextPanel(
                                                  city: city,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Flights
                              ConstrainedBox(
                                key: _flightsSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: FlightSeasonalityCard(
                                  originCountryIso: originCountryIso,
                                  originIata: originAirport?.iataCode,
                                  destIata: destinationAirport?.iataCode,
                                  routeInsight: routeInsight,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Sources
                              ConstrainedBox(
                                key: _sourcesSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: _DataTransparencyCard(
                                  city: city,
                                  updatedLabel: _formatUpdatedAt(
                                    context,
                                    city.updatedAt,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // ── Floating glass nav bar (always on top) ─────────────────────
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    0,
                  ),
                  child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, _) {
                      final locale = Localizations.localeOf(
                        context,
                      ).languageCode;
                      final breadcrumb = widget.fromMigrationResult
                          ? switch (locale) {
                              'pt' => 'Resultado do plano',
                              'es' => 'Resultado del plan',
                              _ => 'Plan result',
                            }
                          : widget.selectForPlan
                          ? switch (locale) {
                              'pt' => 'Selecionar cidade',
                              'es' => 'Seleccionar ciudad',
                              _ => 'Select city',
                            }
                          : widget.validationFlow
                          ? switch (locale) {
                              'pt' => 'Explorar cidades',
                              'es' => 'Explorar ciudades',
                              _ => 'Explore cities',
                            }
                          : null;
                      return AppGlassHeader(
                        title: l10n.cityDetailHeaderTitle(),
                        subtitle: breadcrumb,
                        onBack: _goBackToCities,
                        onHelp: _showHelp,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goBackToCities() {
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.cities);
  }

  String _formatUpdatedAt(BuildContext context, String updatedAt) {
    final localeName = Localizations.localeOf(context).toString();
    final parsed = DateTime.tryParse(updatedAt);
    if (parsed == null) {
      return updatedAt;
    }

    return DateFormat('dd/MM/yyyy', localeName).format(parsed.toLocal());
  }

  Future<void> _toggleFavoriteCity(BuildContext context, City city) async {
    final result = await widget.citiesController.toggleFavorite(city.id);
    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      CityFavoriteToggleResult.added =>
        context.l10n.cityDetailFavoriteAddedFeedback(city.name),
      CityFavoriteToggleResult.removed =>
        context.l10n.cityDetailFavoriteRemovedFeedback(city.name),
      CityFavoriteToggleResult.limitReached =>
        context.l10n.cityDetailFavoriteLimitFeedback(
          CitiesController.maxFavoriteCities,
        ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleCompareCity(BuildContext context, City city) async {
    final questionnaireController = widget.migrationQuestionnaireController;
    if (questionnaireController == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CityComparisonScreen(
          initialCities: [city],
          citiesController: widget.citiesController,
          migrationQuestionnaireController: questionnaireController,
        ),
      ),
    );
  }

  Future<void> _handlePrimaryPlanAction(BuildContext context, City city) async {
    final plan = widget.migrationQuestionnaireController?.generatedPlan;
    final isConfirmedCity =
        plan?.isCityConfirmed == true && plan?.recommendedCity?.id == city.id;
    if (isConfirmedCity) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.publicHome,
        (route) => false,
      );
      return;
    }

    if (plan != null) {
      final isSamePlanCity = plan.recommendedCity?.id == city.id;
      if (!isSamePlanCity) {
        final choice = await showPlanResetDialog(
          context,
          currentCityName: plan.recommendedCity?.name,
        );
        if (!context.mounted || choice != PlanResetChoice.rebuild) {
          return;
        }
        await widget.migrationQuestionnaireController?.clearCurrentPlan();
        if (!context.mounted) {
          return;
        }
        final generated =
            await widget.migrationQuestionnaireController?.generatePlanFromCity(
              city,
            ) ??
            false;
        if (!context.mounted || !generated) {
          return;
        }
        await widget.migrationQuestionnaireController?.confirmPlanCity(city);
        if (!context.mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.publicHome,
          (route) => false,
        );
        return;
      }

      await widget.migrationQuestionnaireController?.confirmPlanCity(city);
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.publicHome,
        (route) => false,
      );
      return;
    }

    final generated =
        await widget.migrationQuestionnaireController?.generatePlanFromCity(
          city,
        ) ??
        false;
    if (!context.mounted || !generated) {
      return;
    }
    await widget.migrationQuestionnaireController?.confirmPlanCity(city);
    if (!context.mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
      (route) => false,
    );
  }

  _PlanCityContext? _resolvePlanContext(BuildContext context, City city) {
    final plan = widget.migrationQuestionnaireController?.generatedPlan;
    if (plan == null) {
      return null;
    }

    final isRecommended = plan.recommendedCity?.id == city.id;
    final isCandidate = plan.candidateCities.any(
      (candidate) => candidate.id == city.id,
    );
    if (!isRecommended && !isCandidate) {
      return null;
    }

    final primaryPriority = plan.selectedPriorities.isEmpty
        ? null
        : plan.selectedPriorities.first;
    final focusLabel = primaryPriority != null
        ? context.l10n.priorityLabel(primaryPriority)
        : (plan.archetypeKey != null
              ? context.l10n.archetypeLabel(plan.archetypeKey!)
              : context.l10n.cityDetailWorkLabel);
    final reasons = isRecommended && plan.cityRecommendationReasons.isNotEmpty
        ? plan.cityRecommendationReasons
        : city.recommendationReasons;

    return _PlanCityContext(
      isRecommended: isRecommended,
      primaryPriority: primaryPriority,
      focusLabel: focusLabel,
      reasons: reasons,
      heroSummary: isRecommended
          ? context.l10n.cityDetailDecisionSnapshotRecommendedSubtitle(
              focusLabel,
            )
          : context.l10n.cityDetailDecisionSnapshotPlanSubtitle(focusLabel),
      watchout: _planAwareWatchout(context, city, plan),
      priorityChips: plan.selectedPriorities
          .where((value) => value != 'balanced_unsure')
          .take(2)
          .map(context.l10n.priorityLabel)
          .toList(growable: false),
      constraintChips: plan.selectedConstraints
          .where((value) => value != 'no_constraints')
          .take(2)
          .map(context.l10n.constraintLabel)
          .toList(growable: false),
    );
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null || !_scrollController.hasClients) {
      return;
    }

    if (!ctx.mounted) {
      return;
    }

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.02,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  Future<void> _waitForKeyContext(GlobalKey key) async {
    for (var attempt = 0; attempt < 16; attempt++) {
      if (!mounted) {
        return;
      }
      if (key.currentContext != null) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> _navigateToSection(
    GlobalKey key, {
    bool expandSecondary = false,
    bool expandAnalysis = false,
  }) async {
    if (expandSecondary) {
      await _ensureSecondaryExpanded();
    }

    if (expandAnalysis) {
      _analysisTileController.expand();
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 220));
    }

    await _waitForKeyContext(key);
    if (!mounted || key.currentContext == null) {
      return;
    }

    await _scrollToKey(key);

    // Some sections inside the secondary block finish relayout one frame later.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted || key.currentContext == null) {
      return;
    }
    await _scrollToKey(key);
  }

  List<_DetailQuickAction> _buildQuickActions(
    BuildContext context, {
    required City city,
    required List<CityStrengthSignal> strengths,
    required CityBudgetSnapshot? budget,
    required TravelRouteInsight? routeInsight,
    required List<City> comparisonCities,
  }) {
    final actions = <_DetailQuickAction>[
      _DetailQuickAction(
        icon: Icons.lightbulb_outline_rounded,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Decisão',
          es: 'Decisión',
          en: 'Decision',
        ),
        onTap: () => _scrollToKey(_snapshotSectionKey),
        priority: 0,
      ),
      _DetailQuickAction(
        icon: Icons.fact_check_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Resumo',
          es: 'Resumen',
          en: 'Summary',
        ),
        onTap: () => _scrollToKey(_summarySectionKey),
        priority: 1,
      ),
      _DetailQuickAction(
        icon: Icons.tune_rounded,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Critérios',
          es: 'Criterios',
          en: 'Criteria',
        ),
        onTap: () => _scrollToKey(_categoriesSectionKey),
        priority: 2,
      ),
      _DetailQuickAction(
        icon: Icons.login_rounded,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Chegada',
          es: 'Llegada',
          en: 'Arrival',
        ),
        onTap: () => _scrollToKey(_arrivalSectionKey),
        priority: 3,
      ),
      _DetailQuickAction(
        icon: Icons.auto_stories_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Rotina',
          es: 'Rutina',
          en: 'Living',
        ),
        onTap: () => _scrollToKey(_narrativeSectionKey),
        priority: 4,
      ),
      if (budget != null)
        _DetailQuickAction(
          icon: Icons.payments_outlined,
          label: context.l10n.cityDetailCostAction(),
          onTap: () => _scrollToKey(_costSectionKey),
          priority: 5,
        ),
      _DetailQuickAction(
        icon: Icons.cloud_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Clima',
          es: 'Clima',
          en: 'Climate',
        ),
        onTap: () => _scrollToKey(_climateSectionKey),
        priority: 6,
      ),
      _DetailQuickAction(
        icon: Icons.people_alt_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Pessoas',
          es: 'Personas',
          en: 'People',
        ),
        onTap: () => _scrollToKey(_socialSectionKey),
        priority: 7,
      ),
      _DetailQuickAction(
        icon: Icons.place_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Bairros',
          es: 'Barrios',
          en: 'Areas',
        ),
        onTap: () => _scrollToKey(_neighborhoodSectionKey),
        priority: 8,
      ),
      if (strengths.isNotEmpty)
        _DetailQuickAction(
          icon: Icons.thumb_up_alt_outlined,
          label: _cityDetailLocalizedText(
            context,
            pt: 'Pontos fortes',
            es: 'Fortalezas',
            en: 'Strengths',
          ),
          onTap: () => _scrollToKey(_strengthsSectionKey),
          priority: 9,
        ),
      if (comparisonCities.isNotEmpty)
        _DetailQuickAction(
          icon: Icons.compare_arrows_rounded,
          label: _cityDetailLocalizedText(
            context,
            pt: 'Comparar',
            es: 'Comparar',
            en: 'Compare',
          ),
          onTap: () => _scrollToKey(_compareSectionKey),
          priority: 10,
        ),
      if (routeInsight != null)
        _DetailQuickAction(
          icon: Icons.flight_takeoff_rounded,
          label: _cityDetailLocalizedText(
            context,
            pt: 'Passagem',
            es: 'Pasaje',
            en: 'Flight',
          ),
          onTap: () => _openSecondarySection(_flightBurdenSectionKey),
          priority: 11,
        ),
      _DetailQuickAction(
        icon: Icons.map_outlined,
        label: context.l10n.cityDetailMapAction(),
        onTap: () => _openSecondarySection(_mapSectionKey),
        priority: 12,
      ),
      if (CitySeasonalityProfile.hasSeason(city))
        _DetailQuickAction(
          icon: Icons.wb_sunny_outlined,
          label: context.l10n.cityDetailSeasonalityAction(),
          onTap: () => _openSecondarySection(_seasonalitySectionKey),
          priority: 13,
        ),
      if (city.publicOpinion != null)
        _DetailQuickAction(
          icon: Icons.forum_outlined,
          label: _cityDetailLocalizedText(
            context,
            pt: 'Opinião',
            es: 'Opinión',
            en: 'Opinion',
          ),
          onTap: () => _openSecondarySection(_opinionSectionKey),
          priority: 14,
        ),
      _DetailQuickAction(
        icon: Icons.analytics_outlined,
        label: context.l10n.cityDetailAnalysisAction(),
        onTap: _openAnalysisSection,
        priority: 15,
      ),
      _DetailQuickAction(
        icon: Icons.flight_outlined,
        label: context.l10n.cityDetailFlightsAction(),
        onTap: () => _openSecondarySection(_flightsSectionKey),
        priority: 16,
      ),
      _DetailQuickAction(
        icon: Icons.source_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Fontes',
          es: 'Fuentes',
          en: 'Sources',
        ),
        onTap: () => _openSecondarySection(_sourcesSectionKey),
        priority: 17,
      ),
    ];

    actions.sort((a, b) => a.priority.compareTo(b.priority));
    return actions;
  }

  List<City> _comparisonCitiesFor(City city) {
    final plan = widget.migrationQuestionnaireController?.generatedPlan;
    if (plan == null) {
      return const <City>[];
    }

    final candidates = <City>[
      if (plan.recommendedCity != null && plan.recommendedCity!.id != city.id)
        plan.recommendedCity!,
      ...plan.candidateCities.where((candidate) => candidate.id != city.id),
    ];

    final seen = <String>{};
    final unique = <City>[];
    for (final candidate in candidates) {
      if (seen.add(candidate.id)) {
        unique.add(candidate);
      }
    }
    return unique.take(2).toList(growable: false);
  }

  String _planAwareWatchout(
    BuildContext context,
    City city,
    MigrationPlan plan,
  ) {
    // ── Seasonality conflict takes highest priority ────────────────────────
    // If the user is arriving during peak season in a HIGH-severity city,
    // that is the single most important watchout — housing availability will
    // be severely impacted.
    final conflict = CitySeasonalityConflictService.evaluate(
      city: city,
      timeline: plan.timeline,
    );
    if (conflict != null &&
        conflict.level == SeasonalityConflictLevel.critical) {
      final locale = Localizations.localeOf(context).languageCode;
      return conflict.conflictMessage(locale);
    }

    if (plan.selectedPriorities.contains('low_cost') && city.rentScore < 55) {
      return CityHousingViabilityPresenter.resolve(
        context,
        rentScore: city.rentScore,
      ).supporting;
    }
    if (plan.selectedPriorities.contains('safety') && city.safetyScore < 60) {
      return CityMetricPresentation.resolve(
        context,
        kind: CityMetricKind.safety,
        value: city.safetyScore,
      ).supporting;
    }
    if (plan.selectedPriorities.contains('job_opportunities') &&
        city.movaroScores.workOpportunity < 62) {
      return CityMetricPresentation.resolve(
        context,
        kind: CityMetricKind.work,
        value: city.movaroScores.workOpportunity,
      ).supporting;
    }
    if (plan.selectedPriorities.contains('community') &&
        city.argentinaPopularityScore < 60) {
      return _popularitySupporting(context, city.argentinaPopularityScore);
    }
    if (plan.selectedConstraints.contains('avoid_expensive') &&
        city.rentScore < 60) {
      return CityHousingViabilityPresenter.resolve(
        context,
        rentScore: city.rentScore,
      ).supporting;
    }

    return _DecisionSnapshotPanel.defaultWatchoutText(context, city);
  }
}

// ─── Progressive disclosure wrapper ──────────────────────────────────────────
//
// Wraps secondary content sections behind a toggle. Users see a
// "Ver mais sobre {city}" button; expanding reveals all detail sections.
// This keeps the essential info (snapshot, strengths, cost, seasonality)
// immediately visible without overwhelming first-time visitors.

class _SecondaryContentSection extends StatefulWidget {
  const _SecondaryContentSection({
    super.key,
    required this.cityName,
    required this.children,
  });

  final String cityName;
  final List<Widget> children;

  @override
  State<_SecondaryContentSection> createState() =>
      _SecondaryContentSectionState();
}

class _SecondaryContentSectionState extends State<_SecondaryContentSection> {
  bool _expanded = false;

  bool get isExpanded => _expanded;

  void expand() {
    if (_expanded) {
      return;
    }
    setState(() {
      _expanded = true;
    });
  }

  Future<void> expandAndWait() async {
    if (!_expanded) {
      setState(() {
        _expanded = true;
      });
    }
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 320));
  }

  static String _expandLabel(BuildContext context, String cityName) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ver mais sobre $cityName',
      'es' => 'Ver más sobre $cityName',
      _ => 'See more about $cityName',
    };
  }

  static String _collapseLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ver menos',
      'es' => 'Ver menos',
      _ => 'See less',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Expand / collapse toggle
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _expanded
                      ? _collapseLabel(context)
                      : _expandLabel(context, widget.cityName),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated children
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const SizedBox(height: 12), ...widget.children],
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}

// ─── Compact bar shown when arriving from MigrationResultRevealPage ───────────

class _MigrationResultBar extends StatefulWidget {
  const _MigrationResultBar({required this.city, required this.controller});

  final City city;
  final MigrationQuestionnaireController? controller;

  @override
  State<_MigrationResultBar> createState() => _MigrationResultBarState();
}

class _MigrationResultBarState extends State<_MigrationResultBar> {
  bool _isConfirming = false;

  Future<void> _confirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    try {
      final ctrl = widget.controller;
      if (ctrl != null && ctrl.generatedPlan?.isCityConfirmed != true) {
        await ctrl.confirmPlanCity(widget.city);
      }
      if (!mounted) return;
      await _showCelebration();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.publicHome,
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _showCelebration() async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        builder: (_) => _ResultBarCelebration(cityName: widget.city.name),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final plan = widget.controller?.generatedPlan;
    final compatibilityPct = plan != null
        ? (plan.confidence * 100).round().clamp(0, 100)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF07101C).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.migrationResultRevealStartCta(widget.city.name),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (compatibilityPct != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.migrationResultRevealCompatibilityLabel(
                      compatibilityPct,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _isConfirming ? null : _confirm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isConfirming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _cityDetailLocalizedText(
                      context,
                      pt: 'Iniciar →',
                      es: 'Empezar →',
                      en: 'Start →',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultBarCelebration extends StatelessWidget {
  const _ResultBarCelebration({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2818),
          border: Border.all(color: const Color(0xFF1A4428)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _cityDetailLocalizedText(
                context,
                pt: 'Plano iniciado!',
                es: '¡Plan iniciado!',
                en: 'Plan started!',
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cityDetailLocalizedText(
                context,
                pt: 'Você escolheu $cityName.\nVamos transformar isso em realidade.',
                es: 'Elegiste $cityName.\nAhora vamos a convertirlo en un plan real.',
                en: 'You chose $cityName.\nNow let’s turn that into a real plan.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── End of migration result bar ──────────────────────────────────────────────

enum _SnapshotAlertTone { positive, watchout, context }

class _PlanCityContext {
  const _PlanCityContext({
    required this.isRecommended,
    required this.focusLabel,
    required this.reasons,
    required this.heroSummary,
    required this.watchout,
    required this.priorityChips,
    required this.constraintChips,
    this.primaryPriority,
  });

  final bool isRecommended;
  final String? primaryPriority;
  final String focusLabel;
  final List<String> reasons;
  final String heroSummary;
  final String watchout;
  final List<String> priorityChips;
  final List<String> constraintChips;
}

// ── Full-width hero section (matches recommendation screen style) ─────────────

class _DetailHeroSection extends StatelessWidget {
  const _DetailHeroSection({
    required this.city,
    required this.scrollController,
    required this.citiesController,
    required this.onToggleFavorite,
  });

  final City city;
  final ScrollController scrollController;
  final CitiesController citiesController;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final heroHeight = (MediaQuery.of(context).size.height * 0.30).clamp(
      220.0,
      300.0,
    );
    final weather = citiesController.weatherFor(city.id);
    final isFav = citiesController.isFavorite(city.id);
    final tempLabel = weather != null
        ? '${weather.temperatureCelsius.round()}°C'
        : null;

    return CollapsibleCityHero(
      city: city,
      scrollController: scrollController,
      title: city.name,
      subtitle: '${city.stateName} · ${city.stateCode}',
      maxHeight: heroHeight,
      meta: Row(
        children: [
          _LifestyleBadge(city: city),
          const Spacer(),
          if (tempLabel != null) ...[
            Text(
              tempLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.80),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
          ],
          _HeroIconButton(
            icon: isFav
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            active: isFav,
            onTap: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final background = active
        ? const Color(0xFFE5485E)
        : Colors.white.withValues(alpha: 0.12);
    final borderColor = active
        ? const Color(0xFFFF8A9B).withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: active ? 0.18 : 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class _LifestyleBadge extends StatelessWidget {
  const _LifestyleBadge({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final kind = CityCoastalProfile.lifestyleKind(city);
    final (icon, label) = switch (kind) {
      CityLifestyleKind.coastal => (
        Icons.waves_rounded,
        context.l10n.cityLifestyleCoastalLabel,
      ),
      CityLifestyleKind.metropolis => (
        Icons.location_city_rounded,
        context.l10n.cityLifestyleMetropolisLabel,
      ),
      CityLifestyleKind.border => (
        Icons.compare_arrows_rounded,
        context.l10n.cityLifestyleBorderLabel,
      ),
      CityLifestyleKind.inland => (
        Icons.terrain_rounded,
        context.l10n.cityLifestyleInlandLabel,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white : const Color(0xFF183A70),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDark ? Colors.white : const Color(0xFF183A70),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityLocationPanel extends StatelessWidget {
  const _CityLocationPanel({
    required this.city,
    this.detectedLocation,
    this.isActivePlanCity = false,
    required this.onOpenMap,
  });

  final City city;
  final DetectedLocation? detectedLocation;
  final bool isActivePlanCity;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final region = city.regionName;
    final distanceKm = _distanceKm();
    final originCityName = detectedLocation?.city?.trim().isNotEmpty == true
        ? detectedLocation!.city!
        : 'Buenos Aires';

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenMap,
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(child: CityInteractiveMap(city: city)),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.82),
                            ],
                            stops: const [0.2, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          if (region != null && region.isNotEmpty)
                            _MapBadge(
                              label:
                                  '📍 ${context.l10n.cityDetailMapRegionLabel} ${_titleCase(region)}',
                            ),
                          if (distanceKm != null)
                            _MapBadge(
                              label: context.l10n.cityDetailMapDistanceBadge(
                                NumberFormat.decimalPattern(
                                  Localizations.localeOf(context).toString(),
                                ).format(distanceKm),
                                originCityName,
                              ),
                            ),
                          _MapBadge(
                            label: context.l10n.cityDetailMapOpenSheetLabel(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            city.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${city.stateName} · ${context.l10n.cityDetailMapCountryLabel()}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (distanceKm != null)
                      Positioned(
                        right: 12,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.cityDetailMapDistanceMiniLabel(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 7,
                                      color: Colors.white38,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              Text(
                                '${NumberFormat.decimalPattern(Localizations.localeOf(context).toString()).format(distanceKm)} km',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int? _distanceKm() {
    final latitude = detectedLocation?.latitude;
    final longitude = detectedLocation?.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }

    final distanceKm = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(latitude, longitude),
      LatLng(city.latitude, city.longitude),
    );

    return distanceKm.round();
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

class _CityMapBottomSheet extends StatefulWidget {
  const _CityMapBottomSheet({required this.city, this.detectedLocation});

  final City city;
  final DetectedLocation? detectedLocation;

  @override
  State<_CityMapBottomSheet> createState() => _CityMapBottomSheetState();
}

class _CityMapBottomSheetState extends State<_CityMapBottomSheet> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _fitMap();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitMap() {
    final userPoint = _userPoint;
    final cityPoint = LatLng(widget.city.latitude, widget.city.longitude);
    if (userPoint == null) {
      _mapController.move(cityPoint, 9.5);
      return;
    }

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [userPoint, cityPoint],
        padding: const EdgeInsets.fromLTRB(52, 72, 52, 140),
      ),
    );
  }

  LatLng? get _userPoint {
    final lat = widget.detectedLocation?.latitude;
    final lng = widget.detectedLocation?.longitude;
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat, lng);
  }

  int? get _distanceKm {
    final userPoint = _userPoint;
    if (userPoint == null) {
      return null;
    }
    return const Distance()
        .as(
          LengthUnit.Kilometer,
          userPoint,
          LatLng(widget.city.latitude, widget.city.longitude),
        )
        .round();
  }

  @override
  Widget build(BuildContext context) {
    final cityPoint = LatLng(widget.city.latitude, widget.city.longitude);
    final userPoint = _userPoint;
    final originName = widget.detectedLocation?.city?.trim().isNotEmpty == true
        ? widget.detectedLocation!.city!
        : context.l10n.cityDetailMapCurrentLocationLabel();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.cityDetailMapSheetTitle(widget.city.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.cityDetailMapSheetBody(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MapBadge(
                  label:
                      '📍 ${widget.city.stateName} · ${context.l10n.cityDetailMapCountryLabel()}',
                ),
                if (_distanceKm != null)
                  _MapBadge(
                    label: context.l10n.cityDetailMapDistanceBadge(
                      NumberFormat.decimalPattern(
                        Localizations.localeOf(context).toString(),
                      ).format(_distanceKm),
                      originName,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 360,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: cityPoint,
                    initialZoom: 9.5,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.movaro.app',
                    ),
                    if (userPoint != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [userPoint, cityPoint],
                            color: AppColors.primary.withValues(alpha: 0.7),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: cityPoint,
                          width: 48,
                          height: 48,
                          child: const _BottomSheetCityMapMarker(),
                        ),
                        if (userPoint != null)
                          Marker(
                            point: userPoint,
                            width: 20,
                            height: 20,
                            child: const _BottomSheetUserMapMarker(),
                          ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MapInfoTile(
                    label: context.l10n.cityDetailMapSheetDestinationLabel(),
                    value: widget.city.name,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MapInfoTile(
                    label: context.l10n.cityDetailMapDistanceMiniLabel(),
                    value: _distanceKm == null
                        ? context.l10n.cityDetailMapUnknownDistanceLabel()
                        : '${NumberFormat.decimalPattern(Localizations.localeOf(context).toString()).format(_distanceKm)} km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MapInfoTile(
              label: context.l10n.cityDetailMapSheetOriginLabel(),
              value: userPoint == null
                  ? context.l10n.cityDetailMapOriginMissingLabel()
                  : originName,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MapInfoTile extends StatelessWidget {
  const _MapInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetCityMapMarker extends StatelessWidget {
  const _BottomSheetCityMapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x330071E3), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 22),
    );
  }
}

class _BottomSheetUserMapMarker extends StatelessWidget {
  const _BottomSheetUserMapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16324F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 10, spreadRadius: 1),
        ],
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 8,
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExploreMediaCard extends StatefulWidget {
  const _ExploreMediaCard({required this.onTap});

  final Future<void> Function() onTap;

  @override
  State<_ExploreMediaCard> createState() => _ExploreMediaCardState();
}

class _ExploreMediaCardState extends State<_ExploreMediaCard> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.cityDetailMediaTitle;
    final body = l10n.cityDetailMediaBody;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _loading ? null : _handleTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            border: Border.all(color: const Color(0xFF1E2636)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0B0F14),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0B0F14),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF0F6FC),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1F6FEB),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1F6FEB),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

({String label, Color color, IconData icon}) _overallFitSummary(
  BuildContext context,
  City city,
  MigrationPlan? plan,
) {
  final priorities = plan?.selectedPriorities ?? const <String>[];
  final weighted = priorities.isEmpty
      ? [
              city.movaroScores.economical,
              city.rentScore,
              city.safetyScore,
              city.movaroScores.workOpportunity,
              city.movaroScores.languageAdaptation,
            ].reduce((a, b) => a + b) /
            5
      : priorities
                .map(
                  (priority) => switch (priority) {
                    'low_cost' => city.movaroScores.economical,
                    'safety' => city.safetyScore,
                    'job_opportunities' => city.movaroScores.workOpportunity,
                    'community' => city.argentinaPopularityScore,
                    'quality_life' =>
                      ((city.idhmScore * 100).round() + city.safetyScore) ~/ 2,
                    _ => city.movaroScores.languageAdaptation,
                  },
                )
                .reduce((a, b) => a + b) /
            priorities.length;

  if (weighted >= 72) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Boa escolha',
        es: 'Buena opción',
        en: 'Strong fit',
      ),
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }
  if (weighted >= 58) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Pede comparação',
        es: 'Pide comparación',
        en: 'Needs comparison',
      ),
      color: AppColors.warning,
      icon: Icons.balance_rounded,
    );
  }
  return (
    label: _cityDetailLocalizedText(
      context,
      pt: 'Exige validação',
      es: 'Exige validación',
      en: 'Needs proof',
    ),
    color: AppColors.danger,
    icon: Icons.error_outline_rounded,
  );
}

({String label, Color color, IconData icon}) _budgetFitSummary(
  BuildContext context,
  City city,
  MigrationPlan? plan,
) {
  final budget = city.budgetSnapshot;
  if (plan == null || budget == null) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Use o custo base',
        es: 'Usa el costo base',
        en: 'Use base cost',
      ),
      color: AppColors.primary,
      icon: Icons.savings_outlined,
    );
  }

  final estimate = LandingBudgetEstimator.build(
    plan: plan.copyWith(recommendedCity: city),
  );
  final selectedScenario = switch (plan.availableCapital) {
    'low' => LandingBudgetScenario.lean,
    'medium' => LandingBudgetScenario.balanced,
    'high' || 'very_high' => LandingBudgetScenario.comfortable,
    _ => null,
  };

  if (selectedScenario == null) {
    final salaryRatio = budget.fairLivingCoverageRatio;
    if (salaryRatio >= 1.1) {
      return (
        label: _cityDetailLocalizedText(
          context,
          pt: 'Entrada mais viável',
          es: 'Entrada más viable',
          en: 'More viable landing',
        ),
        color: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (salaryRatio >= 0.9) {
      return (
        label: _cityDetailLocalizedText(
          context,
          pt: 'Pede reserva',
          es: 'Pide reserva',
          en: 'Needs reserve',
        ),
        color: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      );
    }
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Entrada apertada',
        es: 'Entrada ajustada',
        en: 'Tight landing',
      ),
      color: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  final requestedEstimate = estimate.scenarios.firstWhere(
    (scenario) => scenario.scenario == selectedScenario,
  );
  final requestedMonthlyBase = requestedEstimate.breakdown.monthlyBaseBrl;
  final cityMonthlyBase = budget.fairLivingTotal;
  final monthlyRatio = requestedMonthlyBase / cityMonthlyBase;

  if (monthlyRatio >= 1.05) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Compatível com seu capital',
        es: 'Compatible con tu capital',
        en: 'Compatible with your capital',
      ),
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }
  if (monthlyRatio >= 0.9) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Pede ajuste de chegada',
        es: 'Pide ajustar la llegada',
        en: 'Needs a tighter landing',
      ),
      color: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }
  return (
    label: _cityDetailLocalizedText(
      context,
      pt: 'Pesado para o capital declarado',
      es: 'Pesado para el capital declarado',
      en: 'Heavy for declared capital',
    ),
    color: AppColors.danger,
    icon: Icons.error_outline_rounded,
  );
}

({String label, Color color, IconData icon}) _safetyBaselineSummary(
  BuildContext context,
  City city,
  List<City> alternatives,
) {
  if (alternatives.isNotEmpty) {
    final avg =
        alternatives.fold<int>(0, (sum, item) => sum + item.safetyScore) /
        alternatives.length;
    final diff = city.safetyScore - avg;
    if (diff >= 6) {
      return (
        label: _cityDetailLocalizedText(
          context,
          pt: 'Acima das opções',
          es: 'Por encima de tus opciones',
          en: 'Above alternatives',
        ),
        color: AppColors.success,
        icon: Icons.shield_outlined,
      );
    }
    if (diff <= -6) {
      return (
        label: _cityDetailLocalizedText(
          context,
          pt: 'Abaixo das opções',
          es: 'Por debajo de tus opciones',
          en: 'Below alternatives',
        ),
        color: AppColors.danger,
        icon: Icons.gpp_bad_outlined,
      );
    }
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Parecida com as opções',
        es: 'Parecida a tus opciones',
        en: 'Close to alternatives',
      ),
      color: AppColors.warning,
      icon: Icons.gpp_maybe_outlined,
    );
  }

  if (city.safetyScore >= 68) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Sinal estável',
        es: 'Señal estable',
        en: 'Stable signal',
      ),
      color: AppColors.success,
      icon: Icons.shield_outlined,
    );
  }
  if (city.safetyScore >= 55) {
    return (
      label: _cityDetailLocalizedText(
        context,
        pt: 'Exige critério',
        es: 'Exige criterio',
        en: 'Needs judgment',
      ),
      color: AppColors.warning,
      icon: Icons.gpp_maybe_outlined,
    );
  }
  return (
    label: _cityDetailLocalizedText(
      context,
      pt: 'Pede rotina mais fechada',
      es: 'Pide rutina más cerrada',
      en: 'Needs tighter routine',
    ),
    color: AppColors.danger,
    icon: Icons.gpp_bad_outlined,
  );
}

// ─── Block 1: CTA Principal ───────────────────────────────────────────────────

class _CtaPrimaryRow extends StatelessWidget {
  const _CtaPrimaryRow({
    required this.city,
    required this.planContext,
    required this.validationFlow,
    required this.onPrimaryAction,
    required this.onCompareAction,
  });

  final City city;
  final _PlanCityContext? planContext;
  final bool validationFlow;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCompareAction;

  static String _chooseCityLabel(BuildContext context) =>
      switch (Localizations.localeOf(context).languageCode) {
        'pt' => 'Escolher esta cidade',
        'es' => 'Elegir esta ciudad',
        _ => 'Choose this city',
      };

  @override
  Widget build(BuildContext context) {
    // Determine the primary CTA label based on plan state.
    // Rule: ONE clear action — always about choosing the city.
    final primaryLabel = planContext?.isRecommended == true
        ? context.l10n.migrationPlanChooseCityAction
        : validationFlow
        ? context.l10n.migrationPlanChooseCityAction
        : _chooseCityLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Single dominant primary action
        FilledButton.icon(
          onPressed: onPrimaryAction,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: Text(primaryLabel),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        // Secondary action: text button — visually subordinate
        TextButton.icon(
          onPressed: onCompareAction,
          icon: const Icon(Icons.compare_arrows_rounded, size: 16),
          label: Text(context.l10n.cityDetailCompareAction),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSoftFor(context),
          ),
        ),
      ],
    );
  }
}

class _ValidationFlowBanner extends StatelessWidget {
  const _ValidationFlowBanner({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.validateCityBannerTitle().toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.validateCityBannerBody(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.cityDetailDecisionSnapshotPlanSubtitle(city.name),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Block 2: Quick Summary ───────────────────────────────────────────────────

class _QuickSummaryCard extends StatelessWidget {
  const _QuickSummaryCard({
    required this.city,
    required this.plan,
    required this.alternatives,
  });

  final City city;
  final MigrationPlan? plan;
  final List<City> alternatives;

  @override
  Widget build(BuildContext context) {
    final fit = _overallFitSummary(context, city, plan);
    final budgetFit = _budgetFitSummary(context, city, plan);
    final safety = _safetyBaselineSummary(context, city, alternatives);
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final cards = [
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'Leitura geral',
          es: 'Lectura general',
          en: 'Overall read',
        ),
        value: fit.label,
        color: fit.color,
        icon: fit.icon,
      ),
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'No seu cenário',
          es: 'En tu escenario',
          en: 'For your setup',
        ),
        value: budgetFit.label,
        color: budgetFit.color,
        icon: budgetFit.icon,
      ),
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'Segurança',
          es: 'Seguridad',
          en: 'Safety',
        ),
        value: safety.label,
        color: safety.color,
        icon: safety.icon,
      ),
    ];

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cityDetailQuickSummaryTitle(),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (isCompact)
            Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i < cards.length - 1) const SizedBox(height: 8),
                ],
              ],
            )
          else
            Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i < cards.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryIndicator extends StatelessWidget {
  const _SummaryIndicator({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;

  /// Semantic icon conveying the metric tone (check / warning / alert).
  /// Shown alongside the value text so color-blind users can read the tone.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Block 3: Category List ───────────────────────────────────────────────────

class _CategoryListCard extends StatelessWidget {
  const _CategoryListCard({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        icon: Icons.home_work_outlined,
        label: context.l10n.cityDetailAffordabilityTitle,
        presentation: CityHousingViabilityPresenter.resolve(
          context,
          rentScore: city.rentScore,
        ),
        onTap: () => showCityMetricInsightSheet(
          context,
          city: city,
          topic: CityMetricInsightTopic.housing,
        ),
      ),
      (
        icon: Icons.shield_outlined,
        label: context.l10n.cityDetailSafetyLabel,
        presentation: CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.safety,
          value: city.safetyScore,
        ),
        onTap: () => showCityMetricInsightSheet(
          context,
          city: city,
          topic: CityMetricInsightTopic.safety,
        ),
      ),
      (
        icon: Icons.work_outline_rounded,
        label: context.l10n.cityDetailWorkLabel,
        presentation: CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.work,
          value: city.movaroScores.workOpportunity,
        ),
        onTap: () => showCityMetricInsightSheet(
          context,
          city: city,
          topic: CityMetricInsightTopic.work,
        ),
      ),
      (
        icon: Icons.language_outlined,
        label: context.l10n.cityDetailLanguageLabel,
        presentation: CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.language,
          value: city.movaroScores.languageAdaptation,
        ),
        onTap: () => showCityMetricInsightSheet(
          context,
          city: city,
          topic: CityMetricInsightTopic.language,
        ),
      ),
    ];

    return FrostedPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _CategoryRow(
                icon: rows[i].icon,
                label: rows[i].label,
                presentation: rows[i].presentation,
                onTap: rows[i].onTap,
                isFirst: i == 0,
                isLast: i == rows.length - 1,
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.borderFor(context),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.presentation,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final dynamic presentation;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tint = presentation.tint as Color;
    final headline = presentation.headline as String;

    final topRadius = isFirst ? const Radius.circular(16) : Radius.zero;
    final bottomRadius = isLast ? const Radius.circular(16) : Radius.zero;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: topRadius,
          topRight: topRadius,
          bottomLeft: bottomRadius,
          bottomRight: bottomRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tint, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                headline,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textSoftFor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrivalViabilityCard extends StatelessWidget {
  const _ArrivalViabilityCard({
    required this.city,
    required this.budget,
    required this.preferredCountryId,
    required this.routeInsight,
    required this.insights,
    required this.arrivalStory,
  });

  final City city;
  final CityBudgetSnapshot? budget;
  final String? preferredCountryId;
  final TravelRouteInsight? routeInsight;
  final List<CityInsightEntity> insights;
  final CityDetailArrivalStory? arrivalStory;

  @override
  Widget build(BuildContext context) {
    final pressure = _entryPressure(context);
    final pressureWhy = _entryPressureWhy(context);
    final firstFocus = _firstFocus(context);
    final firstFocusBody = _firstFocusBody(context);
    final firstMonthStory = _firstMonthStory(
      context,
      insights,
      city,
      arrivalStory,
    );
    final reserveMonths =
        arrivalStory?.firstMonthBudget?.reserveMonths ??
        (city.rentScore >= 70 ? 2 : 3);
    final reserveAmount =
        arrivalStory?.firstMonthBudget?.reserveAmountBrl ??
        (budget == null ? null : budget!.fairLivingTotal * reserveMonths);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.cityDetailArrivalViabilityTitle(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => _showInsightSheet(
                  context,
                  title: context.l10n.cityDetailArrivalViabilityTitle(),
                  summary: context.l10n.cityDetailArrivalViabilityBody(),
                ),
                child: Text(_detailActionLabel(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ArrivalInfoTile(
                    icon: Icons.savings_outlined,
                    label: context.l10n.cityDetailArrivalReserveLabel(),
                    value: reserveAmount == null
                        ? context.l10n.cityDetailArrivalReserveFallback()
                        : null,
                    tint: AppColors.primary,
                    amountInBrl: reserveAmount,
                    preferredCountryId: preferredCountryId,
                    supporting: reserveAmount == null
                        ? context.l10n
                              .cityDetailArrivalReserveSupportingNoData()
                        : context.l10n.cityDetailArrivalReserveSupporting(
                            reserveMonths,
                          ),
                    basis: budget == null
                        ? null
                        : context.l10n.cityDetailArrivalReserveBasis(
                            budget!.cityLabel,
                          ),
                    source: arrivalStory?.firstMonthBudget == null
                        ? (budget == null
                              ? null
                              : '${budget!.sourceLabel} · ${budget!.updatedAt}')
                        : '${arrivalStory!.firstMonthBudget!.sourceLabel} · ${arrivalStory!.firstMonthBudget!.updatedAt}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ArrivalInfoTile(
                    icon: Icons.warning_amber_rounded,
                    label: context.l10n.cityDetailArrivalPressureLabel(),
                    value: pressure.$1,
                    tint: pressure.$2,
                    supporting: pressure.$3,
                    basis: pressureWhy,
                    source:
                        '${city.sources.ranking.provider} · ${city.sources.curatedMetrics.provider}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ArrivalInfoTile(
            icon: Icons.flag_outlined,
            label: context.l10n.cityDetailArrivalFirstFocusLabel(),
            value: firstFocus.$1,
            tint: firstFocus.$2,
            supporting: firstFocusBody,
            basis: _firstFocusBasis(context),
            source: _firstFocusSource(context),
          ),
          if (firstMonthStory != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_view_week_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _cityDetailLocalizedText(
                            context,
                            pt: 'Como tende a ser o primeiro mês',
                            es: 'Cómo tiende a ser el primer mes',
                            en: 'What month one tends to feel like',
                          ),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    firstMonthStory.$1,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    firstMonthStory.$2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  (String, Color, String) _entryPressure(BuildContext context) {
    final flightPenalty = switch (routeInsight == null
        ? 'none'
        : FlightRoutePriceInsightService.classifyPressure(
            route: routeInsight!,
            baseArrivalBudgetBrl: budget?.fairLivingTotal,
          ).label) {
      'high' => 14,
      'medium' => 7,
      _ => 0,
    };
    final base =
        ((city.rentScore +
                city.movaroScores.languageAdaptation +
                city.safetyScore) /
            3) -
        flightPenalty;
    final hasSeasonality = CitySeasonalityProfile.hasSeason(city);

    if (base >= 68 && !hasSeasonality) {
      return (
        context.l10n.cityDetailArrivalPressureLow(),
        AppColors.success,
        context.l10n.cityDetailArrivalPressureLowBody(),
      );
    }
    if (base >= 54) {
      return (
        context.l10n.cityDetailArrivalPressureMedium(),
        AppColors.warning,
        hasSeasonality
            ? context.l10n.cityDetailArrivalPressureSeasonalBody()
            : context.l10n.cityDetailArrivalPressureMediumBody(),
      );
    }
    return (
      context.l10n.cityDetailArrivalPressureHigh(),
      AppColors.danger,
      context.l10n.cityDetailArrivalPressureHighBody(),
    );
  }

  String _entryPressureWhy(BuildContext context) {
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    ).headline;
    final language = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.language,
      value: city.movaroScores.languageAdaptation,
    ).headline;
    final safety = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.safety,
      value: city.safetyScore,
    ).headline;
    final seasonality = CitySeasonalityProfile.hasSeason(city)
        ? context.l10n.cityDetailArrivalSeasonalityBasisActive()
        : context.l10n.cityDetailArrivalSeasonalityBasisStable();
    final flight = routeInsight == null
        ? null
        : _flightPressureHeadline(context);

    return context.l10n.cityDetailArrivalPressureBasis(
      housing,
      language,
      safety,
      seasonality,
      flight,
    );
  }

  String _flightPressureHeadline(BuildContext context) {
    final pressure = FlightRoutePriceInsightService.classifyPressure(
      route: routeInsight!,
      baseArrivalBudgetBrl: budget?.fairLivingTotal,
    ).label;
    switch (pressure) {
      case 'high':
        return context.l10n.cityDetailFlightBurdenPressureHigh();
      case 'medium':
        return context.l10n.cityDetailFlightBurdenPressureMedium();
      default:
        return context.l10n.cityDetailFlightBurdenPressureLow();
    }
  }

  (String, Color) _firstFocus(BuildContext context) {
    final entries = <String, ({int score, Color tint})>{
      context.l10n.cityDetailArrivalFocusHousing(): (
        score: city.rentScore,
        tint: AppColors.warning,
      ),
      context.l10n.cityDetailArrivalFocusLanguage(): (
        score: city.movaroScores.languageAdaptation,
        tint: AppColors.primary,
      ),
      context.l10n.cityDetailArrivalFocusWork(): (
        score: city.movaroScores.workOpportunity,
        tint: AppColors.success,
      ),
      context.l10n.cityDetailArrivalFocusSafety(): (
        score: city.safetyScore,
        tint: AppColors.danger,
      ),
    }.entries.toList()..sort((a, b) => a.value.score.compareTo(b.value.score));

    return (entries.first.key, entries.first.value.tint);
  }

  String _firstFocusBody(BuildContext context) {
    final focus = _firstFocus(context).$1;
    if (focus == context.l10n.cityDetailArrivalFocusHousing()) {
      return context.l10n.cityDetailArrivalFocusHousingBody();
    }
    if (focus == context.l10n.cityDetailArrivalFocusLanguage()) {
      return context.l10n.cityDetailArrivalFocusLanguageBody();
    }
    if (focus == context.l10n.cityDetailArrivalFocusWork()) {
      return context.l10n.cityDetailArrivalFocusWorkBody();
    }
    return context.l10n.cityDetailArrivalFocusSafetyBody();
  }

  String _firstFocusBasis(BuildContext context) {
    final focus = _firstFocus(context).$1;
    if (focus == context.l10n.cityDetailArrivalFocusHousing()) {
      final housing = CityHousingViabilityPresenter.resolve(
        context,
        rentScore: city.rentScore,
      );
      return context.l10n.cityDetailArrivalFocusBasis(
        housing.headline,
        '${city.rentScore}/100',
      );
    }
    if (focus == context.l10n.cityDetailArrivalFocusLanguage()) {
      final language = CityMetricPresentation.resolve(
        context,
        kind: CityMetricKind.language,
        value: city.movaroScores.languageAdaptation,
      );
      return context.l10n.cityDetailArrivalFocusBasis(
        language.headline,
        '${city.movaroScores.languageAdaptation}/100',
      );
    }
    if (focus == context.l10n.cityDetailArrivalFocusWork()) {
      return context.l10n.cityDetailArrivalFocusBasis(
        _unemploymentHeadline(context, city.unemploymentRate),
        '${city.unemploymentRate.toStringAsFixed(1)}%',
      );
    }
    final safety = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.safety,
      value: city.safetyScore,
    );
    return context.l10n.cityDetailArrivalFocusBasis(
      safety.headline,
      '${city.safetyScore}/100',
    );
  }

  String _firstFocusSource(BuildContext context) {
    final focus = _firstFocus(context).$1;
    if (focus == context.l10n.cityDetailArrivalFocusWork()) {
      return city.sources.employment?.provider ??
          'MTE/Novo Caged · ${city.sources.curatedMetrics.provider}';
    }
    if (focus == context.l10n.cityDetailArrivalFocusSafety()) {
      return city.sources.safety?.provider ??
          'Atlas da Violencia · ${city.sources.curatedMetrics.provider}';
    }
    if (focus == context.l10n.cityDetailArrivalFocusLanguage()) {
      return city.sources.curatedMetrics.provider;
    }
    if (focus == context.l10n.cityDetailArrivalFocusHousing()) {
      final budget = city.budgetSnapshot;
      if (budget != null) {
        return '${budget.sourceLabel} · ${budget.updatedAt}';
      }
    }
    return city.sources.curatedMetrics.provider;
  }

  (String, String)? _firstMonthStory(
    BuildContext context,
    List<CityInsightEntity> insights,
    City city,
    CityDetailArrivalStory? arrivalStory,
  ) {
    final apiStory = arrivalStory?.story;
    if (apiStory != null) {
      return (
        _compactInsightCopy(
          apiStory.shortText.isNotEmpty ? apiStory.shortText : apiStory.title,
          maxSentences: 2,
        ),
        _compactInsightCopy(
          apiStory.content.isNotEmpty
              ? apiStory.content
              : _cityDetailLocalizedText(
                  context,
                  pt: 'Use o primeiro mês para validar se ${city.name} funciona melhor no seu ritmo real do que no papel.',
                  es: 'Usa el primer mes para validar si ${city.name} funciona mejor en tu ritmo real que en el papel.',
                  en: 'Use the first month to validate whether ${city.name} works better in your real rhythm than on paper.',
                ),
          maxSentences: 2,
        ),
      );
    }
    if (arrivalStory != null) {
      return null;
    }
    final insight = insights.firstWhere(
      (item) {
        final body = '${item.title} ${item.shortText} ${item.content}'
            .toLowerCase();
        return body.contains('primeiros meses') ||
            body.contains('primeros meses') ||
            body.contains('first months') ||
            body.contains('chegada') ||
            body.contains('arrival') ||
            body.contains('adapt') ||
            item.theme == CityInsightTheme.localRoutine;
      },
      orElse: () => CityInsightEntity(
        id: '',
        cityId: '',
        cityName: '',
        type: CityInsightType.practicalTip,
        title: '',
        shortText: '',
        content: '',
        source: '',
        generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (insight.id.isEmpty) {
      return null;
    }
    final headline = _compactInsightCopy(
      insight.shortText.isNotEmpty ? insight.shortText : insight.title,
      maxSentences: 2,
    );
    final detail = _compactInsightCopy(
      insight.content.isNotEmpty
          ? insight.content
          : _cityDetailLocalizedText(
              context,
              pt: 'Use o primeiro mês para validar se ${city.name} funciona melhor no seu ritmo real do que no papel.',
              es: 'Usa el primer mes para validar si ${city.name} funciona mejor en tu ritmo real que en el papel.',
              en: 'Use the first month to validate whether ${city.name} works better in your real rhythm than on paper.',
            ),
      maxSentences: 2,
    );
    return (headline, detail);
  }
}

class _FlightBurdenCard extends StatelessWidget {
  const _FlightBurdenCard({
    required this.routeInsight,
    required this.budget,
    required this.preferredCountryId,
  });

  final TravelRouteInsight routeInsight;
  final CityBudgetSnapshot? budget;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final routeRange = _usdRange(
      context,
      routeInsight.lowUsdMin,
      routeInsight.lowUsdMax,
    );
    final pressure = FlightRoutePriceInsightService.classifyPressure(
      route: routeInsight,
      baseArrivalBudgetBrl: budget?.fairLivingTotal,
    );
    final (headline, tint, supporting) = switch (pressure.label) {
      'high' => (
        context.l10n.cityDetailFlightBurdenPressureHigh(),
        AppColors.danger,
        context.l10n.cityDetailFlightBurdenPressureHighBody(),
      ),
      'medium' => (
        context.l10n.cityDetailFlightBurdenPressureMedium(),
        AppColors.warning,
        context.l10n.cityDetailFlightBurdenPressureMediumBody(),
      ),
      _ => (
        context.l10n.cityDetailFlightBurdenPressureLow(),
        AppColors.success,
        context.l10n.cityDetailFlightBurdenPressureLowBody(),
      ),
    };

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.cityDetailFlightBurdenTitle(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => _showInsightSheet(
                  context,
                  title: context.l10n.cityDetailFlightBurdenTitle(),
                  summary: context.l10n.cityDetailFlightBurdenBody(),
                ),
                child: Text(_detailActionLabel(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ArrivalInfoTile(
                    icon: Icons.flight_takeoff_rounded,
                    label: context.l10n.cityDetailFlightBurdenRangeLabel(),
                    value: routeRange,
                    tint: AppColors.primary,
                    supporting: context.l10n
                        .cityDetailFlightBurdenRangeSupporting(
                          routeInsight.originIata,
                          routeInsight.destIata,
                        ),
                    basis: context.l10n.cityDetailFlightBurdenPressureBasis(
                      routeRange,
                      '${routeInsight.originIata} -> ${routeInsight.destIata}',
                    ),
                    source: context.l10n.cityDetailFlightBurdenSource(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ArrivalInfoTile(
                    icon: Icons.compare_arrows_rounded,
                    label: context.l10n.cityDetailFlightBurdenPressureLabel(),
                    value: headline,
                    tint: tint,
                    supporting: supporting,
                    basis: context.l10n.cityDetailFlightBurdenPressureBasis(
                      routeRange,
                      '${routeInsight.originIata} -> ${routeInsight.destIata}',
                    ),
                    source: context.l10n.cityDetailFlightBurdenSource(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _usdRange(BuildContext context, int min, int max) {
    final minLabel = NumberFormat.currency(
      locale: 'en_US',
      name: 'USD',
      symbol: 'US\$',
      decimalDigits: 0,
    ).format(min);
    final maxLabel = NumberFormat.currency(
      locale: 'en_US',
      name: 'USD',
      symbol: 'US\$',
      decimalDigits: 0,
    ).format(max);
    return '$minLabel-$maxLabel';
  }
}

class _ArrivalInfoTile extends StatelessWidget {
  const _ArrivalInfoTile({
    required this.icon,
    required this.label,
    required this.tint,
    required this.supporting,
    this.value,
    this.amountInBrl,
    this.preferredCountryId,
    this.basis,
    this.source,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final String supporting;
  final String? value;
  final int? amountInBrl;
  final String? preferredCountryId;
  final String? basis;
  final String? source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (amountInBrl != null)
            DefaultTextStyle(
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800),
              child: MultiCurrencyAmount(
                amountInBrl: amountInBrl!,
                exchangeRates: null,
                preferredCountryId: preferredCountryId,
                compact: true,
              ),
            )
          else
            Text(
              value!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showInsightSheet(
              context,
              title: label,
              summary: supporting,
              basis: basis,
              source: source == null
                  ? null
                  : context.l10n.cityDetailArrivalSourceLabel(source!),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_detailActionLabel(context)),
          ),
        ],
      ),
    );
  }
}

Future<void> _showInsightSheet(
  BuildContext context, {
  required String title,
  required String summary,
  String? basis,
  String? source,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.82,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderFor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            if (basis != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detailBasisLabel(context),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      basis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (source != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detailSourceLabel(context),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      source,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

String _detailActionLabel(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'es':
      return 'Entender mejor';
    case 'en':
      return 'Learn more';
    default:
      return 'Entender melhor';
  }
}

String _detailBasisLabel(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'es':
      return 'Como isso foi lido';
    case 'en':
      return 'How this was read';
    default:
      return 'Como isso foi lido';
  }
}

String _detailSourceLabel(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'es':
      return 'Fuente';
    case 'en':
      return 'Source';
    default:
      return 'Fonte';
  }
}

// ─── Block 4: Secondary Actions ───────────────────────────────────────────────

class _SecondaryActionsRow extends StatelessWidget {
  const _SecondaryActionsRow({required this.actions});

  final List<_DetailQuickAction> actions;
  static const _maxVisibleActions = 5;

  @override
  Widget build(BuildContext context) {
    final visible = actions.take(_maxVisibleActions).toList(growable: false);
    final overflow = actions.skip(_maxVisibleActions).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Acesso rápido aos temas desta página',
              es: 'Acceso rápido a los temas de esta página',
              en: 'Quick access to sections on this page',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length + (overflow.isEmpty ? 0 : 1),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index >= visible.length) {
                return _SecondaryActionChip(
                  icon: Icons.more_horiz_rounded,
                  label: _cityDetailLocalizedText(
                    context,
                    pt: 'Mais',
                    es: 'Más',
                    en: 'More',
                  ),
                  onTap: () => _showMoreActions(context, overflow),
                  isMore: true,
                );
              }
              final action = visible[index];
              return _SecondaryActionChip(
                icon: action.icon,
                label: action.label,
                onTap: action.onTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showMoreActions(
    BuildContext context,
    List<_DetailQuickAction> actions,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cityDetailLocalizedText(
                    context,
                    pt: 'Mais temas',
                    es: 'Más temas',
                    en: 'More topics',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: actions.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: AppColors.borderFor(context), height: 1),
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(action.icon, color: AppColors.primary),
                        title: Text(action.label),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            action.onTap();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailQuickAction {
  const _DetailQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.priority = 100,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int priority;
}

class _SecondaryActionChip extends StatelessWidget {
  const _SecondaryActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isMore = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isMore
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surfaceFor(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minWidth: 78),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isMore
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.borderFor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isMore ? AppColors.primary : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataTransparencyCard extends StatelessWidget {
  const _DataTransparencyCard({required this.city, required this.updatedLabel});

  final City city;
  final String updatedLabel;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_outlined, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cityDetailLocalizedText(
                    context,
                    pt: 'Dados e metodologia',
                    es: 'Datos y metodología',
                    en: 'Data and methodology',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  _cityDetailLocalizedText(
                    context,
                    pt: 'Se quiser auditar a leitura, as fontes completas e a metodologia estão aqui. Atualizado em $updatedLabel.',
                    es: 'Si quieres auditar la lectura, las fuentes completas y la metodología están aquí. Actualizado en $updatedLabel.',
                    en: 'If you want to audit the read, the full sources and methodology are here. Updated on $updatedLabel.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _openSources(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    _cityDetailLocalizedText(
                      context,
                      pt: 'Ver fontes',
                      es: 'Ver fuentes',
                      en: 'View sources',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSources(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.86,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderFor(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CitySourcesSection(sources: city.sources),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionSnapshotPanel extends StatelessWidget {
  const _DecisionSnapshotPanel({
    required this.city,
    this.planContext,
    this.plan,
    this.budget,
  });

  final City city;
  final _PlanCityContext? planContext;
  final MigrationPlan? plan;
  final CityBudgetSnapshot? budget;

  @override
  Widget build(BuildContext context) {
    final verdict = _buildVerdict(context);
    final bestFor = planContext?.focusLabel ?? _bestForLabel(context, city);
    final reasons = (planContext?.reasons ?? city.recommendationReasons)
        .map(context.l10n.recommendationReasonLabel)
        .toSet()
        .take(3)
        .toList(growable: false);
    final watchouts = _buildWatchouts(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: verdict.tint.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: verdict.tint.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: verdict.tint.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(verdict.icon, color: verdict.tint, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verdict.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            verdict.summary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  verdict.nextStep,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: verdict.tint,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Por que esta cidade faz sentido',
              es: 'Por qué esta ciudad tiene sentido',
              en: 'Why this city makes sense',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            bestFor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final reason in reasons) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reason,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  if (reason != reasons.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          if (watchouts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              _cityDetailLocalizedText(
                context,
                pt: 'Antes de decidir, valide isto',
                es: 'Antes de decidir, valida esto',
                en: 'Validate this before deciding',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final watchout in watchouts) ...[
              InsightCard(
                title: context.l10n.cityDetailWatchoutTitle,
                body: watchout,
                icon: Icons.warning_amber_rounded,
                tint: AppColors.warning,
              ),
              if (watchout != watchouts.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  _DecisionVerdict _buildVerdict(BuildContext context) {
    final weightedScore = _weightedDecisionScore();
    final cityName = city.name;
    final focusLabel = planContext?.focusLabel ?? _bestForLabel(context, city);
    final arrivalFit = _arrivalFitLabel(context);

    if (weightedScore >= 72) {
      return _DecisionVerdict(
        title: _cityDetailLocalizedText(
          context,
          pt: 'Boa escolha para seguir',
          es: 'Buena opción para avanzar',
          en: 'Strong option to move forward',
        ),
        summary: _cityDetailLocalizedText(
          context,
          pt: '$cityName parece combinar bem com seu momento atual. O sinal mais forte aqui é $focusLabel, e a leitura de chegada hoje está em $arrivalFit.',
          es: '$cityName parece encajar bien con tu momento actual. La señal más fuerte aquí es $focusLabel, y la lectura de llegada hoy está en $arrivalFit.',
          en: '$cityName looks aligned with your current plan. The strongest signal here is $focusLabel, and the arrival read right now is $arrivalFit.',
        ),
        nextStep: _timelineNextStep(context),
        tint: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (weightedScore >= 58) {
      return _DecisionVerdict(
        title: _cityDetailLocalizedText(
          context,
          pt: 'Vale comparar com calma',
          es: 'Vale compararla con calma',
          en: 'Worth comparing carefully',
        ),
        summary: _cityDetailLocalizedText(
          context,
          pt: '$cityName tem sinais reais de encaixe, mas ainda pede validação prática antes de virar decisão. O melhor caminho é comparar custo, chegada e rotina com mais uma alternativa.',
          es: '$cityName tiene señales reales de encaje, pero todavía pide validación práctica antes de convertirse en decisión. El mejor camino es comparar costo, llegada y rutina con otra alternativa.',
          en: '$cityName shows real fit signals, but it still needs practical validation before becoming the decision. The best next move is to compare cost, arrival, and routine against another option.',
        ),
        nextStep: _timelineNextStep(context),
        tint: AppColors.warning,
        icon: Icons.balance_rounded,
      );
    }
    return _DecisionVerdict(
      title: _cityDetailLocalizedText(
        context,
        pt: 'Precisa de validação extra',
        es: 'Necesita validación extra',
        en: 'Needs extra validation',
      ),
      summary: _cityDetailLocalizedText(
        context,
        pt: '$cityName ainda parece uma aposta mais difícil para o seu cenário. O problema não é um único dado, e sim o conjunto entre chegada, adaptação e custo.',
        es: '$cityName todavía parece una apuesta más difícil para tu escenario. El problema no es un único dato, sino el conjunto entre llegada, adaptación y costo.',
        en: '$cityName still looks like a tougher bet for your current setup. The issue is not one isolated metric, but the combined weight of arrival, adaptation, and cost.',
      ),
      nextStep: _timelineNextStep(context),
      tint: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  double _weightedDecisionScore() {
    final scoreMap = <String, int>{
      'low_cost': city.movaroScores.economical,
      'safety': city.safetyScore,
      'job_opportunities': city.movaroScores.workOpportunity,
      'community': city.argentinaPopularityScore,
      'quality_life': ((city.idhmScore * 100).round() + city.safetyScore) ~/ 2,
      'warm_climate': city.movaroScores.economical,
    };

    final selected =
        plan?.selectedPriorities
            .where((value) => scoreMap.containsKey(value))
            .toList(growable: false) ??
        const <String>[];
    if (selected.isNotEmpty) {
      final total = selected
          .map((value) => scoreMap[value]!)
          .fold<int>(0, (sum, value) => sum + value);
      return total / selected.length;
    }

    final baseline = <int>[
      city.movaroScores.economical,
      city.rentScore,
      city.safetyScore,
      city.movaroScores.workOpportunity,
      city.movaroScores.languageAdaptation,
    ];
    return baseline.fold<int>(0, (sum, value) => sum + value) / baseline.length;
  }

  String _arrivalFitLabel(BuildContext context) {
    final base =
        ((city.rentScore +
                    city.movaroScores.languageAdaptation +
                    city.safetyScore) /
                3)
            .round();
    if (base >= 68) {
      return _cityDetailLocalizedText(
        context,
        pt: 'baixa pressão',
        es: 'baja presión',
        en: 'lower pressure',
      );
    }
    if (base >= 54) {
      return _cityDetailLocalizedText(
        context,
        pt: 'pressão média',
        es: 'presión media',
        en: 'medium pressure',
      );
    }
    return _cityDetailLocalizedText(
      context,
      pt: 'pressão alta',
      es: 'presión alta',
      en: 'high pressure',
    );
  }

  String _timelineNextStep(BuildContext context) {
    return switch (plan?.timeline) {
      'in_0_3m' => _cityDetailLocalizedText(
        context,
        pt: 'Se você pretende chegar logo, foque primeiro em reserva de entrada, moradia temporária e custo real do primeiro mês.',
        es: 'Si planeas llegar pronto, enfócate primero en reserva de entrada, vivienda temporal y costo real del primer mes.',
        en: 'If you plan to arrive soon, focus first on entry reserve, temporary housing, and the real cost of month one.',
      ),
      'in_3_6m' || 'in_6_12m' => _cityDetailLocalizedText(
        context,
        pt: 'Você ainda tem tempo para validar rotina, bairro, custo e passagem sem decidir no impulso.',
        es: 'Todavía tienes tiempo para validar rutina, barrio, costo y vuelo sin decidir por impulso.',
        en: 'You still have time to validate routine, neighborhood, cost, and flight without deciding on impulse.',
      ),
      _ => _cityDetailLocalizedText(
        context,
        pt: 'Trate esta página como filtro: compare com outra cidade antes de transformar curiosidade em plano.',
        es: 'Toma esta página como filtro: compárala con otra ciudad antes de transformar curiosidad en plan.',
        en: 'Treat this page as a filter: compare it with another city before turning curiosity into a plan.',
      ),
    };
  }

  List<String> _buildWatchouts(BuildContext context) {
    final items = <String>[
      if (planContext != null) planContext!.watchout,
      defaultWatchoutText(context, city),
      if (city.rentScore < 60)
        CityHousingViabilityPresenter.resolve(
          context,
          rentScore: city.rentScore,
        ).supporting,
      if (city.safetyScore < 60)
        CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.safety,
          value: city.safetyScore,
        ).supporting,
      if (city.movaroScores.workOpportunity < 62)
        CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.work,
          value: city.movaroScores.workOpportunity,
        ).supporting,
      if (city.movaroScores.languageAdaptation < 62)
        CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.language,
          value: city.movaroScores.languageAdaptation,
        ).supporting,
    ];

    return items.toSet().take(3).toList(growable: false);
  }

  String _bestForLabel(BuildContext context, City city) {
    final scores = <String, int>{
      context.l10n.cityDetailCostLabel: city.movaroScores.economical,
      context.l10n.cityDetailSafetyLabel: city.safetyScore,
      context.l10n.cityDetailLanguageLabel:
          city.movaroScores.languageAdaptation,
      context.l10n.cityDetailWorkLabel: city.movaroScores.workOpportunity,
    };
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static String defaultWatchoutText(BuildContext context, City city) {
    final lowest = <String, int>{
      'housing': city.rentScore,
      'safety': city.safetyScore,
      'language': city.movaroScores.languageAdaptation,
      'work': city.movaroScores.workOpportunity,
    }.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    switch (lowest.first.key) {
      case 'housing':
        return CityHousingViabilityPresenter.resolve(
          context,
          rentScore: city.rentScore,
        ).supporting;
      case 'safety':
        return CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.safety,
          value: city.safetyScore,
        ).supporting;
      case 'language':
        return CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.language,
          value: city.movaroScores.languageAdaptation,
        ).supporting;
      case 'work':
      default:
        return CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.work,
          value: city.movaroScores.workOpportunity,
        ).supporting;
    }
  }
}

class _DecisionVerdict {
  const _DecisionVerdict({
    required this.title,
    required this.summary,
    required this.nextStep,
    required this.tint,
    required this.icon,
  });

  final String title;
  final String summary;
  final String nextStep;
  final Color tint;
  final IconData icon;
}

class _CityNarrativeCard extends StatelessWidget {
  const _CityNarrativeCard({
    required this.city,
    required this.plan,
    required this.planContext,
    required this.insights,
    required this.arrivalStory,
  });

  final City city;
  final MigrationPlan? plan;
  final _PlanCityContext? planContext;
  final List<CityInsightEntity> insights;
  final CityDetailArrivalStory? arrivalStory;

  @override
  Widget build(BuildContext context) {
    final narrative = _cityNarrative(
      context,
      city,
      planContext,
      insights,
      arrivalStory,
    );
    final timeline = _timelineAdvice(context, plan, city);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Como é viver aqui na prática',
              es: 'Cómo es vivir aquí en la práctica',
              en: 'What living here feels like',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            narrative.$1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            narrative.$2,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: timeline.$2.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: timeline.$2.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timeline_rounded, size: 18, color: timeline.$2),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timeline.$1,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: timeline.$2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  timeline.$3,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClimateSummaryCard extends StatelessWidget {
  const _ClimateSummaryCard({
    required this.city,
    required this.weather,
    required this.climateSummary,
  });

  final City city;
  final CityWeather? weather;
  final CityDetailClimateSummary? climateSummary;

  @override
  Widget build(BuildContext context) {
    final summary = _climateSummary(context, city, weather, climateSummary);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Clima e sensação ao longo do ano',
              es: 'Clima y sensación durante el año',
              en: 'Climate through the year',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            summary.$1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InsightPill(icon: Icons.thermostat_rounded, label: summary.$2),
              _InsightPill(icon: Icons.air_rounded, label: summary.$3),
              _InsightPill(
                icon: Icons.event_available_rounded,
                label: summary.$4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeopleLikeYouCard extends StatelessWidget {
  const _PeopleLikeYouCard({required this.city, required this.socialProof});

  final City city;
  final CityDetailSocialProof? socialProof;

  @override
  Widget build(BuildContext context) {
    final read = _peopleLikeYouRead(context, city, socialProof);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Sinal de adaptação para pessoas como você',
              es: 'Señal de adaptación para personas como tú',
              en: 'Adaptation signal for people like you',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            read.$1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: read.$2.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: read.$2.withValues(alpha: 0.16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.people_alt_outlined, size: 18, color: read.$2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    read.$3,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          if (read.$4.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in read.$4)
                  _InsightPill(icon: Icons.check_circle_outline, label: chip),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NeighborhoodGuidanceCard extends StatelessWidget {
  const _NeighborhoodGuidanceCard({
    required this.city,
    required this.places,
    required this.insights,
    required this.arrivalStory,
    required this.socialProof,
  });

  final City city;
  final List<CityInsightExplorePlaceEntity> places;
  final List<CityInsightEntity> insights;
  final CityDetailArrivalStory? arrivalStory;
  final CityDetailSocialProof? socialProof;

  @override
  Widget build(BuildContext context) {
    final guidance = _neighborhoodGuidance(
      context,
      city,
      places,
      insights,
      arrivalStory,
      socialProof,
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Por onde começar a procurar bairro',
              es: 'Por dónde empezar a buscar barrio',
              en: 'Where to start looking for areas',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            guidance.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          if (guidance.recommended.isNotEmpty) ...[
            _AreaLabel(
              title: _cityDetailLocalizedText(
                context,
                pt: 'Bons pontos de partida',
                es: 'Buenas zonas para empezar',
                en: 'Good starting areas',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in guidance.recommended)
                  _InsightPill(icon: Icons.place_outlined, label: item),
              ],
            ),
          ],
          if (guidance.caution != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      guidance.caution!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineComparisonCard extends StatelessWidget {
  const _InlineComparisonCard({
    required this.city,
    required this.plan,
    required this.alternatives,
    required this.comparison,
    required this.onCompare,
  });

  final City city;
  final MigrationPlan? plan;
  final List<City> alternatives;
  final CityDetailComparison? comparison;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final read = _comparisonRead(context, city, alternatives, plan, comparison);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Como esta cidade se compara às suas alternativas',
              es: 'Cómo esta ciudad se compara con tus alternativas',
              en: 'How this city compares with your alternatives',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            read.$1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cityName in alternatives.map((item) => item.name))
                _InsightPill(
                  icon: Icons.compare_arrows_rounded,
                  label: cityName,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  read.$2,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  read.$3,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: Text(context.l10n.cityDetailCompareAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaLabel extends StatelessWidget {
  const _AreaLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textSoftFor(context),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _NeighborhoodGuidance {
  const _NeighborhoodGuidance({
    required this.summary,
    required this.recommended,
    this.caution,
  });

  final String summary;
  final List<String> recommended;
  final String? caution;
}

(String, String) _cityNarrative(
  BuildContext context,
  City city,
  _PlanCityContext? planContext,
  List<CityInsightEntity> insights,
  CityDetailArrivalStory? arrivalStory,
) {
  final apiStory = arrivalStory?.story;
  if (apiStory != null) {
    return (
      _compactInsightCopy(
        apiStory.shortText.isNotEmpty ? apiStory.shortText : apiStory.title,
        maxSentences: 2,
      ),
      _compactInsightCopy(
        apiStory.content.isNotEmpty ? apiStory.content : apiStory.shortText,
        maxSentences: 2,
      ),
    );
  }
  if (arrivalStory != null) {
    return (
      _cityDetailLocalizedText(
        context,
        pt: 'Ainda não há narrativa local validada para esta cidade.',
        es: 'Todavía no hay una narrativa local validada para esta ciudad.',
        en: 'There is no validated local narrative for this city yet.',
      ),
      _cityDetailLocalizedText(
        context,
        pt: 'Use custo, primeiro mês e comparação como base até surgirem sinais editoriais mais específicos vindos da API.',
        es: 'Usa costo, primer mes y comparación como base hasta que aparezcan señales editoriales más específicas desde la API.',
        en: 'Use cost, first month, and comparison as your base until the API provides more specific editorial signals.',
      ),
    );
  }

  final localRoutineInsight = insights.firstWhere(
    (item) =>
        item.theme == CityInsightTheme.localRoutine ||
        item.type == CityInsightType.lifestyle ||
        item.type == CityInsightType.motivation,
    orElse: () => CityInsightEntity(
      id: '',
      cityId: '',
      cityName: '',
      type: CityInsightType.lifestyle,
      title: '',
      shortText: '',
      content: '',
      source: '',
      generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  );
  if (localRoutineInsight.id.isNotEmpty) {
    return (
      _compactInsightCopy(
        localRoutineInsight.shortText.isNotEmpty
            ? localRoutineInsight.shortText
            : localRoutineInsight.title,
        maxSentences: 2,
      ),
      _compactInsightCopy(
        localRoutineInsight.content.isNotEmpty
            ? localRoutineInsight.content
            : localRoutineInsight.shortText,
        maxSentences: 2,
      ),
    );
  }

  final bestFor =
      planContext?.focusLabel ??
      _DecisionSnapshotPanel(city: city)._bestForLabel(context, city);
  final lifestyle = CityCoastalProfile.lifestyleKind(city);
  final lifestyleText = switch (lifestyle) {
    CityLifestyleKind.coastal => _cityDetailLocalizedText(
      context,
      pt: 'uma rotina mais aberta, com deslocamentos que costumam girar em torno de praia, turismo e sazonalidade',
      es: 'una rutina más abierta, con desplazamientos que suelen girar alrededor de playa, turismo y estacionalidad',
      en: 'a more open routine, with daily life often shaped by beach, tourism, and seasonality',
    ),
    CityLifestyleKind.metropolis => _cityDetailLocalizedText(
      context,
      pt: 'uma rotina mais urbana, com ganho de escala, mais opções e também mais atrito no dia a dia',
      es: 'una rutina más urbana, con escala, más opciones y también más fricción en el día a día',
      en: 'a more urban routine, with scale, more options, and also more daily friction',
    ),
    CityLifestyleKind.border => _cityDetailLocalizedText(
      context,
      pt: 'uma rotina de cidade de fronteira, mais pragmática e acostumada a circulação entre culturas',
      es: 'una rutina de ciudad fronteriza, más pragmática y acostumbrada al cruce entre culturas',
      en: 'a border-city routine, more pragmatic and used to movement between cultures',
    ),
    CityLifestyleKind.inland => _cityDetailLocalizedText(
      context,
      pt: 'uma rotina mais estável e local, normalmente com menos ruído turístico e mais previsibilidade',
      es: 'una rutina más estable y local, normalmente con menos ruido turístico y más previsibilidad',
      en: 'a more stable local routine, usually with less tourist noise and more predictability',
    ),
  };

  final practical = _cityDetailLocalizedText(
    context,
    pt: '${city.name} funciona melhor para quem procura $bestFor e aceita $lifestyleText.',
    es: '${city.name} funciona mejor para quien busca $bestFor y acepta $lifestyleText.',
    en: '${city.name} works best for someone prioritizing $bestFor and comfortable with $lifestyleText.',
  );

  final tradeoff = switch (_lowestScoreKey(city)) {
    'housing' => _cityDetailLocalizedText(
      context,
      pt: 'O principal atrito aparece na moradia: vale validar bairro, exigências de entrada e reserva antes de assumir aluguel fixo.',
      es: 'La principal fricción aparece en vivienda: conviene validar barrio, requisitos de entrada y reserva antes de asumir un alquiler fijo.',
      en: 'The main friction shows up in housing: validate area, move-in requirements, and reserve before committing to a long-term rental.',
    ),
    'safety' => _cityDetailLocalizedText(
      context,
      pt: 'O cuidado maior aqui é montar rotina e deslocamento com critério, porque a sensação de segurança pesa mais na adaptação do primeiro mês.',
      es: 'El mayor cuidado aquí es montar rutina y desplazamiento con criterio, porque la sensación de seguridad pesa más en la adaptación del primer mes.',
      en: 'The main caution here is building a deliberate routine and commute, because perceived safety weighs heavily in first-month adaptation.',
    ),
    'language' => _cityDetailLocalizedText(
      context,
      pt: 'A adaptação tende a depender mais de rede, linguagem e paciência prática do que de um encaixe automático.',
      es: 'La adaptación tiende a depender más de red, lenguaje y paciencia práctica que de un encaje automático.',
      en: 'Adaptation here depends more on network, language, and practical patience than on instant fit.',
    ),
    _ => _cityDetailLocalizedText(
      context,
      pt: 'O ponto de atenção é gerar renda com ritmo: vale chegar com reserva e plano mais claro de trabalho ou clientes.',
      es: 'El punto de atención es generar ingresos con ritmo: conviene llegar con reserva y un plan más claro de trabajo o clientes.',
      en: 'The main concern is income pace: arrive with runway and a clearer job or client plan.',
    ),
  };

  return (practical, tradeoff);
}

(String, Color, String) _timelineAdvice(
  BuildContext context,
  MigrationPlan? plan,
  City city,
) {
  return switch (plan?.timeline) {
    'in_0_3m' => (
      _cityDetailLocalizedText(
        context,
        pt: 'Próximas semanas definem a qualidade da chegada',
        es: 'Las próximas semanas definen la calidad de la llegada',
        en: 'The next few weeks define arrival quality',
      ),
      AppColors.danger,
      _cityDetailLocalizedText(
        context,
        pt: 'Se a mudança é em até 3 meses, ${city.name} pede três validações rápidas: custo do primeiro mês, moradia temporária e bairro de entrada. Não vale decidir só pela foto geral da cidade.',
        es: 'Si la mudanza es en hasta 3 meses, ${city.name} pide tres validaciones rápidas: costo del primer mes, vivienda temporal y barrio de entrada. No conviene decidir solo por la foto general de la ciudad.',
        en: 'If the move is within 3 months, ${city.name} needs three fast validations: first-month cost, temporary housing, and your landing area. Do not decide from the high-level picture alone.',
      ),
    ),
    'in_3_6m' => (
      _cityDetailLocalizedText(
        context,
        pt: 'Você ainda consegue testar sem pressa',
        es: 'Todavía puedes validar sin correr',
        en: 'You still have time to validate calmly',
      ),
      AppColors.warning,
      _cityDetailLocalizedText(
        context,
        pt: 'Com 3 a 6 meses, o melhor uso desta fase é comparar ${city.name} com mais uma cidade, simular orçamento real e descobrir em quais bairros faz sentido começar.',
        es: 'Con 3 a 6 meses, el mejor uso de esta fase es comparar ${city.name} con otra ciudad, simular presupuesto real y descubrir en qué barrios tiene sentido empezar.',
        en: 'With 3 to 6 months, the best use of this phase is comparing ${city.name} with one more city, simulating a real budget, and understanding which areas make sense to start in.',
      ),
    ),
    'in_6_12m' => (
      _cityDetailLocalizedText(
        context,
        pt: 'Momento ideal para reduzir risco agora',
        es: 'Momento ideal para reducir riesgo ahora',
        en: 'Best moment to reduce risk early',
      ),
      AppColors.primary,
      _cityDetailLocalizedText(
        context,
        pt: 'Com mais fôlego, use ${city.name} para montar um plano de entrada mais inteligente: trabalho, documentação e bairro podem ser validados antes de virar urgência.',
        es: 'Con más margen, usa ${city.name} para armar un plan de entrada más inteligente: trabajo, documentación y barrio pueden validarse antes de volverse urgencia.',
        en: 'With more runway, use ${city.name} to build a smarter landing plan: work, documents, and area choice can be validated before they become urgent.',
      ),
    ),
    _ => (
      _cityDetailLocalizedText(
        context,
        pt: 'Use esta leitura para filtrar antes de se apegar',
        es: 'Usa esta lectura para filtrar antes de apegarte',
        en: 'Use this read to filter before getting attached',
      ),
      AppColors.primary,
      _cityDetailLocalizedText(
        context,
        pt: 'Sem data fechada, o melhor uso desta página é separar curiosidade de viabilidade. Se ${city.name} continuar forte depois de custo, rotina e bairros, aí sim vale levar adiante.',
        es: 'Sin fecha cerrada, el mejor uso de esta página es separar curiosidad de viabilidad. Si ${city.name} sigue fuerte después de costo, rutina y barrios, recién ahí vale avanzar.',
        en: 'Without a fixed date, the best use of this page is separating curiosity from viability. If ${city.name} stays strong after cost, routine, and area checks, then it is worth taking further.',
      ),
    ),
  };
}

(String, String, String, String) _climateSummary(
  BuildContext context,
  City city,
  CityWeather? weather,
  CityDetailClimateSummary? climateSummary,
) {
  final Object? seasonality =
      climateSummary?.seasonality ?? city.seasonalitySnapshot;
  final liveWeather = climateSummary?.currentWeather;
  final currentTemp =
      liveWeather?.temperatureCelsius ?? weather?.temperatureCelsius;
  final current = currentTemp == null
      ? _cityDetailLocalizedText(
          context,
          pt: 'Sem leitura ao vivo de agora, vale considerar o padrão geral da cidade.',
          es: 'Sin lectura en vivo ahora, conviene mirar el patrón general de la ciudad.',
          en: 'Without a live weather read right now, it is better to use the city’s overall pattern.',
        )
      : _cityDetailLocalizedText(
          context,
          pt: 'Agora ${city.name} está em torno de ${currentTemp.round()}°C${liveWeather == null ? '' : ' e ${liveWeather.conditionLabel.toLowerCase()}'}.',
          es: 'Ahora ${city.name} está alrededor de ${currentTemp.round()}°C${liveWeather == null ? '' : ' y ${liveWeather.conditionLabel.toLowerCase()}'}.',
          en: '${city.name} is currently around ${currentTemp.round()}°C${liveWeather == null ? '' : ' with ${liveWeather.conditionLabel.toLowerCase()}'}.',
        );
  final humidityFeel = switch (CityCoastalProfile.lifestyleKind(city)) {
    CityLifestyleKind.coastal => _cityDetailLocalizedText(
      context,
      pt: 'Sensação mais úmida e vento mais presente',
      es: 'Sensación más húmeda y con más viento',
      en: 'More humidity and more noticeable wind',
    ),
    CityLifestyleKind.metropolis => _cityDetailLocalizedText(
      context,
      pt: 'Calor urbano e deslocamento pesam mais',
      es: 'El calor urbano y los desplazamientos pesan más',
      en: 'Urban heat and commuting matter more',
    ),
    CityLifestyleKind.border ||
    CityLifestyleKind.inland => _cityDetailLocalizedText(
      context,
      pt: 'Ar mais seco e variação térmica mais sentida',
      es: 'Aire más seco y variación térmica más marcada',
      en: 'Drier air and more noticeable temperature swings',
    ),
  };
  final lowMonths = switch (seasonality) {
    CityDetailClimateSeasonality details => details.lowMonths,
    dynamic snapshot when seasonality != null =>
      snapshot.lowMonths as List<int>,
    _ => const <int>[],
  };
  final seasonalWindow = seasonality == null
      ? _cityDetailLocalizedText(
          context,
          pt: 'Sem pico sazonal forte aparente',
          es: 'Sin pico estacional fuerte aparente',
          en: 'No major seasonal spike detected',
        )
      : _cityDetailLocalizedText(
          context,
          pt: 'Meses mais estáveis: ${_formatMonthList(context, lowMonths)}',
          es: 'Meses más estables: ${_formatMonthList(context, lowMonths)}',
          en: 'Most stable months: ${_formatMonthList(context, lowMonths)}',
        );
  final seasonalityRentNote = switch (seasonality) {
    CityDetailClimateSeasonality details => details.rentNotes,
    dynamic snapshot when seasonality != null =>
      snapshot.rentNotes(Localizations.localeOf(context).languageCode)
          as String,
    _ => null,
  };
  final summary = _cityDetailLocalizedText(
    context,
    pt: '$current No ano, a leitura prática é de ${humidityFeel.toLowerCase()}. ${seasonalityRentNote ?? 'A cidade tende a ser mais previsível para se instalar.'}',
    es: '$current En el año, la lectura práctica es de ${humidityFeel.toLowerCase()}. ${seasonalityRentNote ?? 'La ciudad tiende a ser más previsible para instalarse.'}',
    en: '$current Over the year, the practical read is ${humidityFeel.toLowerCase()}. ${seasonalityRentNote ?? 'The city tends to be more predictable to settle into.'}',
  );

  final tempChip = currentTemp == null
      ? _cityDetailLocalizedText(
          context,
          pt: 'Sem temperatura ao vivo',
          es: 'Sin temperatura en vivo',
          en: 'No live temperature',
        )
      : _cityDetailLocalizedText(
          context,
          pt: '${currentTemp.round()}°C agora',
          es: '${currentTemp.round()}°C ahora',
          en: '${currentTemp.round()}°C now',
        );
  final windChip =
      liveWeather?.windSpeedKmh != null || weather?.windSpeedKmh != null
      ? _cityDetailLocalizedText(
          context,
          pt: 'Vento ${(liveWeather?.windSpeedKmh ?? weather!.windSpeedKmh!).round()} km/h',
          es: 'Viento ${(liveWeather?.windSpeedKmh ?? weather!.windSpeedKmh!).round()} km/h',
          en: 'Wind ${(liveWeather?.windSpeedKmh ?? weather!.windSpeedKmh!).round()} km/h',
        )
      : humidityFeel;
  return (summary, tempChip, windChip, seasonalWindow);
}

(String, Color, String, List<String>) _peopleLikeYouRead(
  BuildContext context,
  City city,
  CityDetailSocialProof? socialProofPayload,
) {
  final popularity =
      socialProofPayload?.argentinaPopularityScore ??
      city.argentinaPopularityScore;
  final tone = popularity >= 70
      ? AppColors.success
      : popularity >= 55
      ? AppColors.warning
      : AppColors.danger;
  final headline = popularity >= 70
      ? _cityDetailLocalizedText(
          context,
          pt: 'Entre argentinos, a cidade já desperta afinidade forte.',
          es: 'Entre argentinos, la ciudad ya genera afinidad fuerte.',
          en: 'Among Argentinians, this city already shows strong affinity.',
        )
      : popularity >= 55
      ? _cityDetailLocalizedText(
          context,
          pt: 'Há curiosidade real, mas a adaptação depende mais de execução.',
          es: 'Hay curiosidad real, pero la adaptación depende más de la ejecución.',
          en: 'There is real interest, but adaptation depends more on execution.',
        )
      : _cityDetailLocalizedText(
          context,
          pt: 'O encaixe tende a ser menos automático para quem está chegando.',
          es: 'El encaje tiende a ser menos automático para quien está llegando.',
          en: 'Fit tends to be less automatic for newcomers here.',
        );

  final opinion = socialProofPayload?.publicOpinion ?? city.publicOpinion;
  final routineInsight = socialProofPayload?.routineInsight;
  final socialProofText =
      opinion != null &&
          opinion.rating != null &&
          opinion.userRatingCount != null
      ? _cityDetailLocalizedText(
          context,
          pt: 'Além disso, a leitura pública de ${opinion.placeName ?? city.name} hoje está em ${opinion.rating!.toStringAsFixed(1)}/5 com ${opinion.userRatingCount} avaliações.',
          es: 'Además, la lectura pública de ${opinion.placeName ?? city.name} hoy está en ${opinion.rating!.toStringAsFixed(1)}/5 con ${opinion.userRatingCount} reseñas.',
          en: 'Public sentiment for ${opinion.placeName ?? city.name} currently sits at ${opinion.rating!.toStringAsFixed(1)}/5 across ${opinion.userRatingCount} reviews.',
        )
      : _cityDetailLocalizedText(
          context,
          pt: 'Use esse sinal como termômetro de adaptação, não como prova final.',
          es: 'Usa esta señal como termómetro de adaptación, no como prueba final.',
          en: 'Use this as an adaptation signal, not as final proof.',
        );

  final chips = <String>[
    _cityDetailLocalizedText(
      context,
      pt: 'Afinidade argentina $popularity/100',
      es: 'Afinidad argentina $popularity/100',
      en: 'Argentine affinity $popularity/100',
    ),
    if (socialProofPayload?.socialSignals.isNotEmpty == true)
      for (final signal in socialProofPayload!.socialSignals.take(2))
        '${signal.label} ${signal.value}${signal.unit}',
    if (routineInsight != null && routineInsight.shortText.trim().isNotEmpty)
      _compactInsightCopy(routineInsight.shortText, maxSentences: 1),
    if (opinion?.positivePoints.isNotEmpty == true)
      opinion!.positivePoints.first,
    if (opinion?.criticalPoints.isNotEmpty == true)
      opinion!.criticalPoints.first,
  ];

  return (headline, tone, socialProofText, chips);
}

_NeighborhoodGuidance _neighborhoodGuidance(
  BuildContext context,
  City city,
  List<CityInsightExplorePlaceEntity> places,
  List<CityInsightEntity> insights,
  CityDetailArrivalStory? arrivalStory,
  CityDetailSocialProof? socialProof,
) {
  final neighborhoodInsight = insights.firstWhere(
    (item) => item.theme == CityInsightTheme.neighborhoods,
    orElse: () => CityInsightEntity(
      id: '',
      cityId: '',
      cityName: '',
      type: CityInsightType.housing,
      title: '',
      shortText: '',
      content: '',
      source: '',
      generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  );
  final apiNeighborhoodInsight = socialProof?.neighborhoodInsight;
  final apiNeighborhoods = arrivalStory?.neighborhoods ?? const [];

  if (apiNeighborhoods.isNotEmpty) {
    final recommended = apiNeighborhoods
        .map((place) {
          final location = [place.neighborhood, place.region]
              .where((value) => value != null && value.trim().isNotEmpty)
              .join(' • ');
          return location.isEmpty ? place.name : '${place.name} · $location';
        })
        .toSet()
        .take(4)
        .toList(growable: false);

    return _NeighborhoodGuidance(
      summary: apiNeighborhoodInsight != null
          ? _compactInsightCopy(
              apiNeighborhoodInsight.shortText.isNotEmpty
                  ? apiNeighborhoodInsight.shortText
                  : apiNeighborhoodInsight.title,
              maxSentences: 2,
            )
          : _cityDetailLocalizedText(
              context,
              pt: 'Essas áreas vêm do payload estruturado da cidade e ajudam a reduzir chute na escolha do bairro de entrada.',
              es: 'Estas zonas vienen del payload estructurado de la ciudad y ayudan a reducir intuición en la elección del barrio de entrada.',
              en: 'These areas come from the city detail payload and reduce guesswork around your landing area.',
            ),
      recommended: recommended,
      caution: apiNeighborhoodInsight != null
          ? _compactInsightCopy(apiNeighborhoodInsight.content, maxSentences: 2)
          : _cityDetailLocalizedText(
              context,
              pt: 'Antes de fechar, valide trajeto, exigência de entrada e rotina ao redor do endereço.',
              es: 'Antes de cerrar, valida trayecto, requisito de entrada y rutina alrededor de la dirección.',
              en: 'Before committing, validate commute, move-in requirements, and the routine around the address.',
            ),
    );
  }

  if (arrivalStory != null || socialProof != null) {
    return _NeighborhoodGuidance(
      summary: _cityDetailLocalizedText(
        context,
        pt: 'Ainda não há bairros verificados suficientes para recomendar uma área de entrada com segurança.',
        es: 'Todavía no hay suficientes barrios verificados para recomendar una zona de llegada con seguridad.',
        en: 'There are not enough verified neighborhoods yet to recommend a landing area confidently.',
      ),
      recommended: const [],
      caution: _cityDetailLocalizedText(
        context,
        pt: 'Por enquanto, use esta cidade como leitura macro e valide bairro com pesquisa manual antes de decidir moradia.',
        es: 'Por ahora, usa esta ciudad como lectura macro y valida el barrio con investigación manual antes de decidir vivienda.',
        en: 'For now, use this city as a macro read and validate the neighborhood manually before choosing housing.',
      ),
    );
  }

  if (places.isNotEmpty) {
    final recommended = places
        .map((place) {
          final location = [place.neighborhood, place.region]
              .where((value) => value != null && value.trim().isNotEmpty)
              .join(' • ');
          return location.isEmpty ? place.name : '${place.name} · $location';
        })
        .toSet()
        .take(4)
        .toList(growable: false);

    return _NeighborhoodGuidance(
      summary: neighborhoodInsight.id.isNotEmpty
          ? _compactInsightCopy(
              neighborhoodInsight.shortText.isNotEmpty
                  ? neighborhoodInsight.shortText
                  : neighborhoodInsight.title,
              maxSentences: 2,
            )
          : _cityDetailLocalizedText(
              context,
              pt: 'Esses bairros e recortes vêm de lugares reais mapeados para começar a imaginar a chegada com menos chute.',
              es: 'Estos barrios y recortes vienen de lugares reales mapeados para empezar a imaginar la llegada con menos intuición.',
              en: 'These areas come from real mapped places so you can picture arrival with less guesswork.',
            ),
      recommended: recommended,
      caution: neighborhoodInsight.id.isNotEmpty
          ? _compactInsightCopy(neighborhoodInsight.content, maxSentences: 2)
          : _cityDetailLocalizedText(
              context,
              pt: 'Antes de fechar, valide trajeto, exigência de entrada e rotina ao redor do endereço.',
              es: 'Antes de cerrar, valida trayecto, requisito de entrada y rutina alrededor de la dirección.',
              en: 'Before committing, validate commute, move-in requirements, and the routine around the address.',
            ),
    );
  }

  return _NeighborhoodGuidance(
    summary: neighborhoodInsight.id.isNotEmpty
        ? _compactInsightCopy(
            neighborhoodInsight.shortText.isNotEmpty
                ? neighborhoodInsight.shortText
                : neighborhoodInsight.title,
            maxSentences: 2,
          )
        : _cityDetailLocalizedText(
            context,
            pt: 'Ainda não há bairros reais carregados para esta cidade, então use transporte, mercado e exigência de entrada como filtro inicial.',
            es: 'Todavía no hay barrios reales cargados para esta ciudad, así que usa transporte, mercado y requisito de entrada como filtro inicial.',
            en: 'There are no real areas loaded for this city yet, so use transport, groceries, and move-in requirements as your first filter.',
          ),
    recommended: [
      _cityDetailLocalizedText(
        context,
        pt: 'Perto de transporte principal',
        es: 'Cerca del transporte principal',
        en: 'Near main transport',
      ),
      _cityDetailLocalizedText(
        context,
        pt: 'Com rotina de comércio',
        es: 'Con rutina de comercio',
        en: 'With daily commerce',
      ),
      _cityDetailLocalizedText(
        context,
        pt: 'Com entrada viável',
        es: 'Con entrada viable',
        en: 'With viable move-in terms',
      ),
    ],
    caution: neighborhoodInsight.id.isNotEmpty
        ? _compactInsightCopy(neighborhoodInsight.content, maxSentences: 2)
        : null,
  );
}

(String, String, String) _comparisonRead(
  BuildContext context,
  City city,
  List<City> alternatives,
  MigrationPlan? plan,
  CityDetailComparison? comparison,
) {
  if (alternatives.isEmpty) {
    return ('', '', '');
  }

  if (comparison != null && comparison.metrics.isNotEmpty) {
    final focus = plan?.selectedPriorities.isNotEmpty == true
        ? context.l10n.priorityLabel(plan!.selectedPriorities.first)
        : null;
    final strongest = comparison.metrics.firstWhere(
      (metric) => metric.primaryIsBest,
      orElse: () => comparison.metrics.first,
    );
    final weakest = comparison.metrics.firstWhere(
      (metric) => !metric.primaryIsBest,
      orElse: () => comparison.metrics.last,
    );
    final comparedCities = comparison.compareTo
        .map((item) => item.cityName)
        .join(' · ');
    final safetyMetric = comparison.metrics.where(
      (item) => item.id == 'safety',
    );
    final safetyRead = safetyMetric.isEmpty
        ? null
        : switch (safetyMetric.first.primaryIsBest) {
            true => _cityDetailLocalizedText(
              context,
              pt: 'Em segurança, ela fica acima das alternativas comparadas.',
              es: 'En seguridad, queda por encima de las alternativas comparadas.',
              en: 'On safety, it sits above the compared alternatives.',
            ),
            false => _cityDetailLocalizedText(
              context,
              pt: 'Em segurança, ela perde para pelo menos uma alternativa direta.',
              es: 'En seguridad, pierde frente a al menos una alternativa directa.',
              en: 'On safety, it trails at least one direct alternative.',
            ),
          };

    return (
      _cityDetailLocalizedText(
        context,
        pt: 'A comparação abaixo já vem estruturada da API para ${city.name} contra $comparedCities.',
        es: 'La comparación de abajo ya viene estructurada desde la API para ${city.name} frente a $comparedCities.',
        en: 'The comparison below already comes structured from the API for ${city.name} against $comparedCities.',
      ),
      _cityDetailLocalizedText(
        context,
        pt: strongest.primaryIsBest
            ? '${city.name} ganha em ${strongest.label.toLowerCase()}.'
            : '${city.name} não lidera claramente contra essas alternativas.',
        es: strongest.primaryIsBest
            ? '${city.name} gana en ${strongest.label.toLowerCase()}.'
            : '${city.name} no lidera claramente frente a estas alternativas.',
        en: strongest.primaryIsBest
            ? '${city.name} wins on ${strongest.label.toLowerCase()}.'
            : '${city.name} does not clearly lead against these alternatives.',
      ),
      _cityDetailLocalizedText(
        context,
        pt: 'Na prática, o maior ganho está em ${strongest.label.toLowerCase()}${focus == null ? '' : ' para quem prioriza $focus'}. O principal custo dessa escolha aparece em ${weakest.label.toLowerCase()}.${safetyRead == null ? '' : ' $safetyRead'}',
        es: 'En la práctica, la mayor ventaja está en ${strongest.label.toLowerCase()}${focus == null ? '' : ' para quien prioriza $focus'}. El principal costo de esta elección aparece en ${weakest.label.toLowerCase()}.${safetyRead == null ? '' : ' $safetyRead'}',
        en: 'In practice, the biggest edge is in ${strongest.label.toLowerCase()}${focus == null ? '' : ' for someone prioritizing $focus'}. The main cost of that choice shows up in ${weakest.label.toLowerCase()}.${safetyRead == null ? '' : ' $safetyRead'}',
      ),
    );
  }

  double avg(int Function(City city) selector) {
    final total = alternatives.fold<int>(
      0,
      (sum, item) => sum + selector(item),
    );
    return total / alternatives.length;
  }

  final metrics = <String, double>{
    _cityDetailLocalizedText(
      context,
      pt: 'custo de entrada',
      es: 'costo de entrada',
      en: 'entry cost',
    ): city.rentScore - avg((item) => item.rentScore),
    _cityDetailLocalizedText(
      context,
      pt: 'segurança',
      es: 'seguridad',
      en: 'safety',
    ): city.safetyScore - avg((item) => item.safetyScore),
    _cityDetailLocalizedText(
      context,
      pt: 'trabalho',
      es: 'trabajo',
      en: 'work',
    ): city.movaroScores.workOpportunity -
        avg((item) => item.movaroScores.workOpportunity),
    _cityDetailLocalizedText(
      context,
      pt: 'adaptação',
      es: 'adaptación',
      en: 'adaptation',
    ): city.movaroScores.languageAdaptation -
        avg((item) => item.movaroScores.languageAdaptation),
  };

  final sorted = metrics.entries.toList()
    ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
  final strongest = sorted.firstWhere(
    (entry) => entry.value >= 0,
    orElse: () => sorted.first,
  );
  final weakest = sorted.firstWhere(
    (entry) => entry.value < 0,
    orElse: () => sorted.last,
  );
  final names = alternatives.map((item) => item.name).join(' · ');
  final focus = plan?.selectedPriorities.isNotEmpty == true
      ? context.l10n.priorityLabel(plan!.selectedPriorities.first)
      : null;
  final safetyDelta =
      city.safetyScore -
      (alternatives.fold<int>(0, (sum, item) => sum + item.safetyScore) /
              alternatives.length)
          .round();
  final safetyRead = safetyDelta >= 6
      ? _cityDetailLocalizedText(
          context,
          pt: 'Em segurança, ela fica acima das suas alternativas diretas.',
          es: 'En seguridad, queda por encima de tus alternativas directas.',
          en: 'On safety, it sits above your direct alternatives.',
        )
      : safetyDelta <= -6
      ? _cityDetailLocalizedText(
          context,
          pt: 'Em segurança, ela fica abaixo das suas alternativas diretas.',
          es: 'En seguridad, queda por debajo de tus alternativas directas.',
          en: 'On safety, it sits below your direct alternatives.',
        )
      : _cityDetailLocalizedText(
          context,
          pt: 'Em segurança, ela está na mesma faixa das suas alternativas.',
          es: 'En seguridad, está en la misma franja que tus alternativas.',
          en: 'On safety, it sits in the same band as your alternatives.',
        );

  return (
    _cityDetailLocalizedText(
      context,
      pt: 'Você não precisa sair desta página para entender o trade-off central contra $names.',
      es: 'No necesitas salir de esta página para entender el trade-off central frente a $names.',
      en: 'You do not need to leave this page to understand the key trade-off versus $names.',
    ),
    _cityDetailLocalizedText(
      context,
      pt: strongest.value >= 0
          ? '${city.name} ganha em ${strongest.key}.'
          : '${city.name} não lidera claramente contra essas alternativas.',
      es: strongest.value >= 0
          ? '${city.name} gana en ${strongest.key}.'
          : '${city.name} no lidera claramente frente a estas alternativas.',
      en: strongest.value >= 0
          ? '${city.name} wins on ${strongest.key}.'
          : '${city.name} does not clearly lead against these alternatives.',
    ),
    _cityDetailLocalizedText(
      context,
      pt: 'Na prática, o maior ganho está em ${strongest.key}${focus == null ? '' : ' para quem prioriza $focus'}. O principal custo dessa escolha aparece em ${weakest.key}. $safetyRead',
      es: 'En la práctica, la mayor ventaja está en ${strongest.key}${focus == null ? '' : ' para quien prioriza $focus'}. El principal costo de esta elección aparece en ${weakest.key}. $safetyRead',
      en: 'In practice, the biggest edge is in ${strongest.key}${focus == null ? '' : ' for someone prioritizing $focus'}. The main cost of that choice shows up in ${weakest.key}. $safetyRead',
    ),
  );
}

String _lowestScoreKey(City city) {
  final scores = <String, int>{
    'housing': city.rentScore,
    'safety': city.safetyScore,
    'language': city.movaroScores.languageAdaptation,
    'work': city.movaroScores.workOpportunity,
  }.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  return scores.first.key;
}

String _formatMonthList(BuildContext context, List<int> months) {
  if (months.isEmpty) {
    return _cityDetailLocalizedText(
      context,
      pt: 'sem leitura ainda',
      es: 'sin lectura todavía',
      en: 'not available yet',
    );
  }
  const pt = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  const es = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  const en = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final labels = switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
  return months
      .where((month) => month >= 1 && month <= 12)
      .map((month) => labels[month - 1])
      .join(', ');
}

String _compactInsightCopy(String text, {int maxSentences = 2}) {
  final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) {
    return normalized;
  }
  final matches = RegExp(r'[^.!?]+[.!?]?').allMatches(normalized).toList();
  if (matches.isEmpty) {
    return normalized;
  }
  return matches
      .take(maxSentences)
      .map((match) => match.group(0)!.trim())
      .where((part) => part.isNotEmpty)
      .join(' ');
}

class _CityStrengthsPanel extends StatelessWidget {
  const _CityStrengthsPanel({required this.city, required this.strengths});

  final City city;
  final List<CityStrengthSignal> strengths;

  @override
  Widget build(BuildContext context) {
    if (strengths.isEmpty) {
      return const SizedBox.shrink();
    }

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'O que essa cidade entrega bem',
              es: 'Lo que esta ciudad entrega bien',
              en: 'What this city does well',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Os pontos que mais ajudam essa cidade a funcionar no dia a dia.',
              es: 'Los puntos que más ayudan a que esta ciudad funcione en el día a día.',
              en: 'The strongest signals helping this city work in everyday life.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              final itemWidth = wide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final signal in strengths)
                    SizedBox(
                      width: itemWidth,
                      child: _StrengthSignalCard(signal: signal),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StrengthSignalCard extends StatelessWidget {
  const _StrengthSignalCard({required this.signal});

  final CityStrengthSignal signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  signal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            signal.supporting,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            signal.sourceLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _cityDetailLocalizedText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'es' => es,
    'en' => en,
    _ => pt,
  };
}

class _WorkOpportunityPanel extends StatelessWidget {
  const _WorkOpportunityPanel({required this.city, required this.budget});

  final City city;
  final CityBudgetSnapshot? budget;

  @override
  Widget build(BuildContext context) {
    return _DetailBlock(
      title: context.l10n.cityDetailWorkLabel,
      children: [
        Text(
          _cityDetailLocalizedText(
            context,
            pt: 'Aqui ficam os sinais complementares que ajudam a validar se a cidade sustenta trabalho e renda no dia a dia.',
            es: 'Aquí quedan las señales complementarias que ayudan a validar si la ciudad sostiene trabajo e ingresos en el día a día.',
            en: 'These are the complementary signals that help validate whether the city can sustain work and income day to day.',
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        _InlineMetricRow(
          icon: Icons.query_stats_rounded,
          label: context.l10n.cityDetailUnemploymentLabel,
          headline: _unemploymentHeadline(context, city.unemploymentRate),
          supporting: '${city.unemploymentRate.toStringAsFixed(1)}%',
          tint: _unemploymentTint(city.unemploymentRate),
          detailTitle: context.l10n.cityDetailUnemploymentLabel,
          basis: _cityDetailLocalizedText(
            context,
            pt: 'Quanto menor a taxa de desemprego, mais espaço tende a existir para entrada no mercado. ${city.name} está em ${city.unemploymentRate.toStringAsFixed(1)}%.',
            es: 'Cuanto menor es la tasa de desempleo, más espacio tiende a existir para entrar al mercado. ${city.name} está en ${city.unemploymentRate.toStringAsFixed(1)}%.',
            en: 'The lower the unemployment rate, the more room there tends to be for entering the market. ${city.name} is currently at ${city.unemploymentRate.toStringAsFixed(1)}%.',
          ),
          source: 'Novo Caged / fontes curadas da cidade',
        ),
        if (budget != null) ...[
          const SizedBox(height: 12),
          _InlineMetricRow(
            icon: Icons.account_balance_wallet_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Salário x custo base',
              es: 'Salario vs costo base',
              en: 'Salary vs base cost',
            ),
            headline: _salaryCoverageHeadline(context, budget!),
            supporting: _salaryCoverageSupporting(context, budget!),
            tint: _salaryCoverageTint(budget!),
            detailTitle: _cityDetailLocalizedText(
              context,
              pt: 'Salário x custo base',
              es: 'Salario vs costo base',
              en: 'Salary vs base cost',
            ),
            basis: _cityDetailLocalizedText(
              context,
              pt: 'Salário líquido médio ${budget!.averageMonthlyNetSalary} BRL contra custo base de ${budget!.fairLivingTotal} BRL em ${budget!.cityLabel}.',
              es: 'Salario neto medio ${budget!.averageMonthlyNetSalary} BRL contra costo base de ${budget!.fairLivingTotal} BRL en ${budget!.cityLabel}.',
              en: 'Average net salary ${budget!.averageMonthlyNetSalary} BRL versus base cost of ${budget!.fairLivingTotal} BRL in ${budget!.cityLabel}.',
            ),
            source: '${budget!.sourceLabel} · ${budget!.updatedAt}',
          ),
        ],
        const SizedBox(height: 14),
        Text(
          context.l10n.cityDetailIndustriesTitle,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          city.topIndustries.map(context.l10n.industryLabel).join(', '),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _IdhmContextPanel extends StatelessWidget {
  const _IdhmContextPanel({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final idhm = CityIdhmPresentation.resolve(context, value: city.idhmScore);

    return _DetailBlock(
      title: context.l10n.cityDetailContextTitle,
      children: [
        _InlineMetricRow(
          icon: Icons.public_rounded,
          label:
              '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
          headline: idhm.headline,
          supporting: idhm.supporting,
          tint: idhm.tint,
          detailTitle: context.l10n.cityDetailContextTitle,
          basis: _cityDetailLocalizedText(
            context,
            pt: 'O IDHM de ${city.name} está em ${city.idhmScore.toStringAsFixed(3)} e usa a referência ${city.idhmReferenceYear}.',
            es: 'El IDHM de ${city.name} está en ${city.idhmScore.toStringAsFixed(3)} y usa la referencia ${city.idhmReferenceYear}.',
            en: 'The HDI for ${city.name} is ${city.idhmScore.toStringAsFixed(3)} using the ${city.idhmReferenceYear} reference.',
          ),
          source: 'Atlas do Desenvolvimento Humano / ${city.idhmReferenceYear}',
        ),
        const SizedBox(height: 12),
        _InlineMetricRow(
          icon: Icons.groups_rounded,
          label: context.l10n.cityDetailPopulationLabel,
          headline: NumberFormatters.compactPopulation(
            value: city.population,
            locale: Localizations.localeOf(context).toString(),
          ),
          supporting: NumberFormatters.fullInteger(
            value: city.population,
            locale: Localizations.localeOf(context).toString(),
          ),
          tint: AppColors.primary,
          detailTitle: context.l10n.cityDetailPopulationLabel,
          basis: _cityDetailLocalizedText(
            context,
            pt: 'População estimada de ${NumberFormatters.fullInteger(value: city.population, locale: Localizations.localeOf(context).toString())} habitantes.',
            es: 'Población estimada de ${NumberFormatters.fullInteger(value: city.population, locale: Localizations.localeOf(context).toString())} habitantes.',
            en: 'Estimated population of ${NumberFormatters.fullInteger(value: city.population, locale: Localizations.localeOf(context).toString())} inhabitants.',
          ),
          source: 'IBGE / fontes demográficas da cidade',
        ),
      ],
    );
  }
}

String _salaryCoverageHeadline(
  BuildContext context,
  CityBudgetSnapshot budget,
) {
  final ratio = budget.fairLivingCoverageRatio;
  if (ratio >= 1.2) {
    return _cityDetailLocalizedText(
      context,
      pt: 'Cobre com folga',
      es: 'Cubre con margen',
      en: 'Covers with margin',
    );
  }
  if (ratio >= 1.0) {
    return _cityDetailLocalizedText(
      context,
      pt: 'Cobre no limite',
      es: 'Cubre al limite',
      en: 'Covers tightly',
    );
  }
  return _cityDetailLocalizedText(
    context,
    pt: 'Nao cobre sozinho',
    es: 'No cubre solo',
    en: 'Does not cover alone',
  );
}

String _salaryCoverageSupporting(
  BuildContext context,
  CityBudgetSnapshot budget,
) {
  final ratioPercent = (budget.fairLivingCoverageRatio * 100).round();
  if (budget.fairLivingGap >= 0) {
    return _cityDetailLocalizedText(
      context,
      pt: 'O salario medio cobre cerca de $ratioPercent% do custo base e ainda sobra caixa.',
      es: 'El salario medio cubre cerca de $ratioPercent% del costo base y aun deja margen.',
      en: 'The average salary covers about $ratioPercent% of the base cost and still leaves room.',
    );
  }
  return _cityDetailLocalizedText(
    context,
    pt: 'O salario medio cobre cerca de $ratioPercent% do custo base e tende a apertar a chegada.',
    es: 'El salario medio cubre cerca de $ratioPercent% del costo base y tiende a apretar la llegada.',
    en: 'The average salary covers about $ratioPercent% of the base cost and tends to tighten the arrival budget.',
  );
}

Color _salaryCoverageTint(CityBudgetSnapshot budget) {
  final ratio = budget.fairLivingCoverageRatio;
  if (ratio >= 1.2) {
    return AppColors.success;
  }
  if (ratio >= 1.0) {
    return AppColors.warning;
  }
  return AppColors.danger;
}

_SnapshotAlertTone _toneForScore(int value) {
  if (value >= 67) {
    return _SnapshotAlertTone.positive;
  }
  if (value < 55) {
    return _SnapshotAlertTone.watchout;
  }
  return _SnapshotAlertTone.context;
}

String _snapshotFooter(BuildContext context, _SnapshotAlertTone tone) {
  switch (tone) {
    case _SnapshotAlertTone.positive:
      return context.l10n.cityDetailSnapshotPositiveTag;
    case _SnapshotAlertTone.watchout:
      return context.l10n.cityDetailSnapshotWatchoutTag;
    case _SnapshotAlertTone.context:
      return context.l10n.cityDetailSnapshotContextTag;
  }
}

class _InlineMetricRow extends StatelessWidget {
  const _InlineMetricRow({
    required this.icon,
    required this.label,
    required this.headline,
    required this.supporting,
    required this.tint,
    this.detailTitle,
    this.basis,
    this.source,
  });

  final IconData icon;
  final String label;
  final String headline;
  final String supporting;
  final Color tint;
  final String? detailTitle;
  final String? basis;
  final String? source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headline,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => _showInsightSheet(
                    context,
                    title: detailTitle ?? label,
                    summary: supporting,
                    basis: basis,
                    source: source,
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_detailActionLabel(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _popularitySupporting(BuildContext context, int score) {
  if (score >= 80) {
    return context.l10n.citySnapshotPopularityHighSupporting;
  }
  if (score >= 60) {
    return context.l10n.citySnapshotPopularityMediumSupporting;
  }
  return context.l10n.citySnapshotPopularityLowSupporting;
}

String _unemploymentHeadline(BuildContext context, double value) {
  if (value <= 5.5) {
    return context.l10n.citySnapshotUnemploymentLower;
  }
  if (value <= 7.0) {
    return context.l10n.citySnapshotUnemploymentModerate;
  }
  return context.l10n.citySnapshotUnemploymentHigher;
}

Color _unemploymentTint(double value) {
  if (value <= 5.5) {
    return AppColors.success;
  }
  if (value <= 7.0) {
    return AppColors.warning;
  }
  return AppColors.danger;
}

class _SnapshotPanel extends StatelessWidget {
  const _SnapshotPanel({
    required this.city,
    required this.localeName,
    this.showTitle = true,
  });

  final City city;
  final String localeName;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final idhm = CityIdhmPresentation.resolve(context, value: city.idhmScore);
    final cost = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.cost,
      value: city.movaroScores.economical,
    );
    final safety = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.safety,
      value: city.safetyScore,
    );
    final language = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.language,
      value: city.movaroScores.languageAdaptation,
    );
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final work = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            Text(
              context.l10n.cityDetailSnapshotTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 680;
              return GridView.count(
                crossAxisCount: wide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: wide ? 1.08 : 0.92,
                children: [
                  CitySnapshotTile(
                    label:
                        '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
                    value: idhm.headline,
                    footer: _snapshotFooter(
                      context,
                      city.idhmScore >= 0.8
                          ? _SnapshotAlertTone.positive
                          : city.idhmScore < 0.7
                          ? _SnapshotAlertTone.watchout
                          : _SnapshotAlertTone.context,
                    ),
                    tint: idhm.tint,
                    background: idhm.background,
                    icon: Icons.public_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailCostLabel,
                    value: cost.headline,
                    footer: _snapshotFooter(
                      context,
                      _toneForScore(city.movaroScores.economical),
                    ),
                    tint: cost.tint,
                    background: cost.background,
                    icon: Icons.payments_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityHousingViabilityTileLabel,
                    value: housing.headline,
                    footer: _snapshotFooter(
                      context,
                      city.rentScore >= 67
                          ? _SnapshotAlertTone.positive
                          : city.rentScore < 55
                          ? _SnapshotAlertTone.watchout
                          : _SnapshotAlertTone.context,
                    ),
                    tint: housing.tint,
                    background: housing.background,
                    icon: Icons.home_work_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailSafetyLabel,
                    value: safety.headline,
                    footer: _snapshotFooter(
                      context,
                      _toneForScore(city.safetyScore),
                    ),
                    tint: safety.tint,
                    background: safety.background,
                    icon: Icons.shield_outlined,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailLanguageLabel,
                    value: language.headline,
                    footer: _snapshotFooter(
                      context,
                      _toneForScore(city.movaroScores.languageAdaptation),
                    ),
                    tint: language.tint,
                    background: language.background,
                    icon: Icons.translate_rounded,
                  ),
                  CitySnapshotTile(
                    label: context.l10n.cityDetailWorkLabel,
                    value: work.headline,
                    footer: _snapshotFooter(
                      context,
                      _toneForScore(city.movaroScores.workOpportunity),
                    ),
                    tint: work.tint,
                    background: work.background,
                    icon: Icons.work_outline_rounded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/exit_flow_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/journey_stage_banner.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_image_catalog.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_conflict_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_logistics_assessment_service.dart';
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_seasonality_card.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/location/location_controller.dart';

/// Shown immediately after the questionnaire completes.
///
/// Surfaces the current shortlist with a cinematic hero image, compatibility
/// signals, leading reasons, and alternative cities the user can explore
/// before choosing how to continue the guided plan.
class MigrationResultRevealPage extends StatefulWidget {
  const MigrationResultRevealPage({
    required this.controller,
    required this.citiesController,
    required this.locationController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final CitiesController citiesController;
  final LocationController locationController;

  @override
  State<MigrationResultRevealPage> createState() =>
      _MigrationResultRevealPageState();
}

class _MigrationResultRevealPageState extends State<MigrationResultRevealPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.controller.initialize();
      await _prefetchRecommendationSignals();
      if (!mounted) return;
      _anim.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _anim.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  Future<void> _openCityDetail(City city) async {
    if (!mounted) return;
    await precacheCityImage(context, city);
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.cityDetail(city.id),
      arguments: <String, dynamic>{'fromMigrationResult': true},
    );
  }

  Future<void> _compareAlternatives(
    City highlightedCity,
    List<City> alternatives,
  ) async {
    _showCityComparisonSheet(
      context,
      widget.controller.generatedPlan!,
      highlightedCity,
      alternatives,
    );
  }

  Future<void> _startPreparation(City city) async {
    await widget.controller.confirmPlanCity(city);
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
      (route) => false,
    );
  }

  Future<void> _goHomeWithConfirmation() async {
    final shouldLeave = await ExitFlowDialog.show(
      context,
      title: context.l10n.bmpExitDialogTitle,
      body: context.l10n.bmpExitDialogBody,
      stayLabel: context.l10n.bmpExitDialogStay,
      leaveLabel: context.l10n.bmpExitDialogLeave,
    );

    if (!mounted || !shouldLeave) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
      (route) => false,
    );
  }

  void _showCompatibilityBreakdown(City city, int compatibilityPct) {
    final l10n = context.l10n;
    final dims = MigrationPlanGenerator.cityDimensionsPublic(city);
    final overallStars = _pctToStars(compatibilityPct);

    final overallStarColor = compatibilityPct >= 80
        ? AppColors.success
        : compatibilityPct >= 60
        ? AppColors.warning
        : const Color(0xFF0088FF);

    final compatLabel = compatibilityPct >= 80
        ? l10n.migrationPlanResultCompatibilityHigh
        : compatibilityPct >= 60
        ? l10n.migrationPlanResultCompatibilityMedium
        : l10n.migrationPlanResultCompatibilityInitial;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: FrostedPanel(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.migrationResultRevealBreakdownTitle(city.name),
                          style: Theme.of(sheetCtx).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Overall star score ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: overallStarColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: overallStarColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.migrationResultRevealBreakdownOverall(),
                          style: Theme.of(sheetCtx).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.textSoftFor(sheetCtx),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StarRow(
                                  stars: overallStars,
                                  size: 28,
                                  color: overallStarColor,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: overallStarColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                compatLabel,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(sheetCtx).textTheme.labelSmall
                                    ?.copyWith(
                                      color: overallStarColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Dimension breakdown ──────────────────────────────
                  Text(
                    _dimensionSectionTitle(sheetCtx),
                    style: Theme.of(sheetCtx).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSoftFor(sheetCtx),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...dims.entries.map(
                    (entry) => _DimensionRow(
                      icon: _dimensionIcon(entry.key),
                      label: l10n.dimensionLabel(entry.key),
                      value: entry.value,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── How compatibility works ───────────────────────────
                  const _CompatibilityExplanationCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _prefetchRecommendationSignals() async {
    final plan = widget.controller.generatedPlan;
    final primaryCity = plan?.currentPlanCity;
    if (plan == null || primaryCity == null) {
      return;
    }

    final destinationAirport =
        FlightRouteContextResolver.resolveDestinationAirport(
          destinationCityName: primaryCity.name,
          destinationCountryIso:
              FlightRouteContextResolver.resolveDestinationCountryIso(
                cityCountryCode: primaryCity.countryCode,
                planDestinationCountry: plan.destinationCountry,
              ),
          destinationLatitude: primaryCity.latitude,
          destinationLongitude: primaryCity.longitude,
        );
    final originCountryIso = FlightRouteContextResolver.resolveOriginCountryIso(
      savedCountryCode: widget.locationController.savedLocation?.countryCode,
      planOriginCountry: plan.originCountry,
    );
    final originAirport = FlightRouteContextResolver.resolveOriginAirport(
      savedLocation: widget.locationController.savedLocation,
      originCountryIso: originCountryIso,
    );
    final originIata = originAirport?.iataCode;

    final requests = <Future<Object?>>[];
    if (originIata != null && destinationAirport?.iataCode != null) {
      requests.add(
        widget.citiesController.loadTravelInsightForCity(
          primaryCity.id,
          originIata: originIata,
          destIata: destinationAirport?.iataCode,
        ),
      );
      for (final city in plan.reviewCities) {
        final altDestination =
            FlightRouteContextResolver.resolveDestinationAirport(
              destinationCityName: city.name,
              destinationCountryIso:
                  FlightRouteContextResolver.resolveDestinationCountryIso(
                    cityCountryCode: city.countryCode,
                    planDestinationCountry: plan.destinationCountry,
                  ),
              destinationLatitude: city.latitude,
              destinationLongitude: city.longitude,
            );
        if (altDestination?.iataCode == null) {
          continue;
        }
        requests.add(
          widget.citiesController.loadTravelInsightForCity(
            city.id,
            originIata: originIata,
            destIata: altDestination?.iataCode,
          ),
        );
      }
    }

    await Future.wait(requests);
  }

  String _dimensionSectionTitle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'pt' => 'Pontuação por dimensão',
      'es' => 'Puntuación por dimensión',
      _ => 'Score by dimension',
    };
  }

  static IconData _dimensionIcon(String key) => switch (key) {
    'affordability' => Icons.savings_outlined,
    'job_market' => Icons.work_outline_rounded,
    'safety' => Icons.shield_outlined,
    'climate_warmth' => Icons.wb_sunny_outlined,
    'transit_infra' => Icons.directions_transit_outlined,
    'nature' => Icons.park_outlined,
    'community' => Icons.people_outline_rounded,
    _ => Icons.tune_rounded,
  };

  void _showCityComparisonSheet(
    BuildContext context,
    MigrationPlan plan,
    City highlightedCity,
    List<City> alternatives,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityComparisonSheet(
        plan: plan,
        highlightedCity: highlightedCity,
        alternatives: alternatives,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final plan = widget.controller.generatedPlan;
        final primaryCity = plan?.currentPlanCity;

        if (widget.controller.isInitializing ||
            plan == null ||
            primaryCity == null) {
          return const Scaffold(
            body: Stack(
              children: [
                AmbientBackground(),
                SafeArea(child: _RevealSkeleton()),
              ],
            ),
          );
        }

        final alternatives = plan.reviewCities
            .where((c) => c.id != primaryCity.id)
            .toList(growable: false);

        final compatibilityPct = (plan.confidence * 100).round().clamp(0, 100);

        final reasons = plan.cityRecommendationReasons.isNotEmpty
            ? plan.cityRecommendationReasons
            : primaryCity.recommendationReasons;

        final preferredCity = plan.preferredCity;
        final hasPreferred = preferredCity != null;
        final preferredMatchesHighlighted =
            hasPreferred && preferredCity.id == primaryCity.id;
        final destinationAirport =
            FlightRouteContextResolver.resolveDestinationAirport(
              destinationCityName: primaryCity.name,
              destinationCountryIso:
                  FlightRouteContextResolver.resolveDestinationCountryIso(
                    cityCountryCode: primaryCity.countryCode,
                    planDestinationCountry: plan.destinationCountry,
                  ),
              destinationLatitude: primaryCity.latitude,
              destinationLongitude: primaryCity.longitude,
            );
        final originCountryIso =
            FlightRouteContextResolver.resolveOriginCountryIso(
              savedCountryCode:
                  widget.locationController.savedLocation?.countryCode,
              planOriginCountry: plan.originCountry,
            );
        final originAirport = FlightRouteContextResolver.resolveOriginAirport(
          savedLocation: widget.locationController.savedLocation,
          originCountryIso: originCountryIso,
        );
        final originIata = originAirport?.iataCode;
        final primaryRoute =
            originIata == null || destinationAirport?.iataCode == null
            ? null
            : widget.citiesController.travelInsightFor(
                primaryCity.id,
                originIata: originIata,
                destIata: destinationAirport?.iataCode,
              );
        final alternativeTradeoff = _FlightTradeoffData.resolve(
          primaryRoute: primaryRoute,
          citiesController: widget.citiesController,
          planDestinationCountry: plan.destinationCountry,
          highlightedCity: primaryCity,
          alternatives: alternatives,
        );
        final logisticsAssessment = FlightLogisticsAssessmentService.assess(
          originLocation: widget.locationController.savedLocation,
          originAirport: originAirport,
          destinationAirport: destinationAirport,
        );
        return Scaffold(
          body: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Stack(
                children: [
                  const AmbientBackground(),
                  // ── Main scrollable content ─────────────────────────
                  Column(
                    children: [
                      _HeroSection(
                        city: primaryCity,
                        scrollController: _scrollController,
                      ),
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 224),
                          children: [
                            JourneyStageBanner(
                              title: context.l10n.stageDecisionTitle,
                              body: context.l10n.stageDecisionBody,
                              action: context.l10n.stageDecisionAction,
                              icon: Icons.explore_rounded,
                            ),
                            const SizedBox(height: 16),
                            if (hasPreferred && preferredMatchesHighlighted)
                              _AntiAnchorReinforcementBanner(
                                cityName: primaryCity.name,
                              ),

                            if (hasPreferred && !preferredMatchesHighlighted)
                              _AntiAnchorComparisonSection(
                                preferredCity: preferredCity,
                                highlightedCity: primaryCity,
                                onGoWithPreferred: () =>
                                    _openCityDetail(preferredCity),
                                onTryHighlighted: () =>
                                    _openCityDetail(primaryCity),
                              ),

                            if (hasPreferred) const SizedBox(height: 16),

                            _CompatibilityCard(
                              city: primaryCity,
                              compatibilityPct: compatibilityPct,
                              onTap: () => _showCompatibilityBreakdown(
                                primaryCity,
                                compatibilityPct,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FlightPriceBadge(
                              originCountryIso: originCountryIso,
                              originIata: originIata,
                              destIata: destinationAirport?.iataCode,
                              routeInsight: primaryRoute,
                            ),
                            if (logisticsAssessment?.shouldHighlight ==
                                true) ...[
                              const SizedBox(height: 12),
                              _OriginLogisticsAlert(
                                assessment: logisticsAssessment!,
                                destinationCityName: primaryCity.name,
                              ),
                            ],
                            if (alternativeTradeoff != null) ...[
                              const SizedBox(height: 12),
                              _FlightTradeoffCard(data: alternativeTradeoff),
                            ],
                            const SizedBox(height: 16),
                            _TimelineContextBar(plan: plan),
                            if (reasons.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _WhyCitySection(
                                cityName: primaryCity.name,
                                reasons: reasons,
                              ),
                            ],
                            if (alternatives.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _AlternativesSection(
                                cities: alternatives,
                                confidence: plan.confidence,
                                highlightedCity: primaryCity,
                                planTimeline: plan.timeline,
                                onTap: (city) => _openCityDetail(city),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _GuidePreviewSection(
                              plan: plan,
                              cityName: primaryCity.name,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ── Fixed footer ───────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _FooterCta(
                      city: primaryCity,
                      hasAlternatives: alternatives.isNotEmpty,
                      onViewDetails: () => _openCityDetail(primaryCity),
                      onCompare: () =>
                          _compareAlternatives(primaryCity, alternatives),
                      onStartPreparation: () => _startPreparation(primaryCity),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: AppGlassHeader(
                        title: context.l10n.migrationResultRevealHeaderTitle,
                        onBack: _goHomeWithConfirmation,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.city, required this.scrollController});

  final City city;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.38;

    return CollapsibleCityHero(
      city: city,
      scrollController: scrollController,
      title: city.name,
      eyebrow: context.l10n.migrationResultRevealEyebrow,
      subtitle: '${city.stateName} · ${city.stateCode}',
      maxHeight: heroHeight,
    );
  }
}

class _FlightTradeoffData {
  const _FlightTradeoffData({
    required this.highlightedCityName,
    required this.highlightedUsdMin,
    required this.highlightedUsdMax,
    required this.cheaperCityName,
    required this.cheaperUsdMin,
    required this.cheaperUsdMax,
  });

  final String highlightedCityName;
  final int highlightedUsdMin;
  final int highlightedUsdMax;
  final String cheaperCityName;
  final int cheaperUsdMin;
  final int cheaperUsdMax;

  String highlightedRange(BuildContext context) =>
      MultiCurrencyAmount.formatRangeFromUsd(
        context: context,
        minUsd: highlightedUsdMin,
        maxUsd: highlightedUsdMax,
      );

  String cheaperRange(BuildContext context) =>
      MultiCurrencyAmount.formatRangeFromUsd(
        context: context,
        minUsd: cheaperUsdMin,
        maxUsd: cheaperUsdMax,
      );

  static _FlightTradeoffData? resolve({
    required TravelRouteInsight? primaryRoute,
    required CitiesController citiesController,
    required String? planDestinationCountry,
    required City highlightedCity,
    required List<City> alternatives,
  }) {
    if (primaryRoute == null) {
      return null;
    }

    City? cheapestCity;
    TravelRouteInsight? cheapestRoute;
    for (final city in alternatives) {
      final altDestination =
          FlightRouteContextResolver.resolveDestinationAirport(
            destinationCityName: city.name,
            destinationCountryIso:
                FlightRouteContextResolver.resolveDestinationCountryIso(
                  cityCountryCode: city.countryCode,
                  planDestinationCountry: planDestinationCountry,
                ),
            destinationLatitude: city.latitude,
            destinationLongitude: city.longitude,
          );
      final route = citiesController.travelInsightFor(
        city.id,
        originIata: primaryRoute.originIata,
        destIata: altDestination?.iataCode,
      );
      if (route == null) {
        continue;
      }
      if (cheapestRoute == null ||
          route.lowUsdAverage < cheapestRoute.lowUsdAverage) {
        cheapestRoute = route;
        cheapestCity = city;
      }
    }

    if (cheapestCity == null || cheapestRoute == null) {
      return null;
    }

    final delta = primaryRoute.lowUsdAverage - cheapestRoute.lowUsdAverage;
    if (delta < 30) {
      return null;
    }

    return _FlightTradeoffData(
      highlightedCityName: highlightedCity.name,
      highlightedUsdMin: primaryRoute.lowUsdMin,
      highlightedUsdMax: primaryRoute.lowUsdMax,
      cheaperCityName: cheapestCity.name,
      cheaperUsdMin: cheapestRoute.lowUsdMin,
      cheaperUsdMax: cheapestRoute.lowUsdMax,
    );
  }
}

class _FlightTradeoffCard extends StatelessWidget {
  const _FlightTradeoffCard({required this.data});

  final _FlightTradeoffData data;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.flight_takeoff_rounded,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.migrationResultFlightTradeoffTitle(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.migrationResultFlightTradeoffBody(
                    data.highlightedCityName,
                    data.highlightedRange(context),
                    data.cheaperCityName,
                    data.cheaperRange(context),
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginLogisticsAlert extends StatelessWidget {
  const _OriginLogisticsAlert({
    required this.assessment,
    required this.destinationCityName,
  });

  final FlightLogisticsAssessment assessment;
  final String destinationCityName;

  @override
  Widget build(BuildContext context) {
    final isHigh =
        assessment.connectionPressure == FlightConnectionPressure.high;
    final tint = isHigh ? AppColors.danger : AppColors.warning;
    final originIata = assessment.originAirport.iataCode;
    final destinationIata = assessment.destinationAirport.iataCode;

    return FrostedPanel(
      backgroundColor: tint.withValues(alpha: 0.08),
      borderColor: tint.withValues(alpha: 0.24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.connecting_airports_rounded, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  _body(
                    context,
                    originIata: originIata,
                    destinationIata: destinationIata,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
                if (assessment.airportAccessKm >= 80) ...[
                  const SizedBox(height: 8),
                  Text(
                    _airportAccess(context),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) => _localized(
    context,
    pt: 'Atenção à saída de ${assessment.originCity}',
    es: 'Atención a la salida desde ${assessment.originCity}',
    en: 'Travel alert from ${assessment.originCity}',
  );

  String _body(
    BuildContext context, {
    required String originIata,
    required String destinationIata,
  }) {
    final high = assessment.connectionPressure == FlightConnectionPressure.high;
    if (high) {
      return _localized(
        context,
        pt: 'Para chegar a $destinationCityName ($destinationIata) saindo de $originIata, a rota tende a depender de conexão e pode pesar mais no orçamento inicial. Compare também as cidades alternativas do plano e confirme datas e escalas no preço ao vivo.',
        es: 'Para llegar a $destinationCityName ($destinationIata) saliendo de $originIata, la ruta suele depender de conexión y puede pesar más en el presupuesto inicial. Compará también las ciudades alternativas del plan y confirmá fechas y escalas con precios en vivo.',
        en: 'Reaching $destinationCityName ($destinationIata) from $originIata will often involve a connection and may weigh more on the initial budget. Compare the plan alternatives and confirm dates and stops with live pricing.',
      );
    }
    return _localized(
      context,
      pt: 'A rota $originIata → $destinationIata merece comparação: a oferta pode variar por temporada e uma conexão pode mudar bastante o custo total. Use a faixa como referência e confirme no preço ao vivo.',
      es: 'Conviene comparar la ruta $originIata → $destinationIata: la oferta puede variar por temporada y una conexión puede cambiar bastante el costo total. Usá el rango como referencia y confirmá el precio en vivo.',
      en: 'The $originIata → $destinationIata route is worth comparing: seasonal supply and a connection can materially change the total cost. Use the range as a guide and confirm with live pricing.',
    );
  }

  String _airportAccess(BuildContext context) => _localized(
    context,
    pt: 'Aeroporto sugerido: ${assessment.originAirport.chipLabel}, a cerca de ${assessment.airportAccessKm} km da origem informada.',
    es: 'Aeropuerto sugerido: ${assessment.originAirport.chipLabel}, a unos ${assessment.airportAccessKm} km del origen informado.',
    en: 'Suggested airport: ${assessment.originAirport.chipLabel}, about ${assessment.airportAccessKm} km from the confirmed origin.',
  );

  String _localized(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}

// ─── Compatibility star rating helper ─────────────────────────────────────────

/// Converts a 0–100 compatibility percentage to a 0.0–5.0 star rating,
/// snapped to the nearest half-star.
double _pctToStars(int pct) {
  final raw = (pct / 100) * 5;
  return (raw * 2).round() / 2; // snap to 0.5 increments
}

// ─── Star row widget ─────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars, this.size = 22, this.color});

  final double stars; // 0.0 – 5.0 in 0.5 increments
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i + 1;
        final half = i + 0.5;
        IconData icon;
        if (stars >= full) {
          icon = Icons.star_rounded;
        } else if (stars >= half) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: size, color: starColor);
      }),
    );
  }
}

// ─── Compatibility card ────────────────────────────────────────────────────────

class _CompatibilityCard extends StatelessWidget {
  const _CompatibilityCard({
    required this.city,
    required this.compatibilityPct,
    required this.onTap,
  });

  final City city;
  final int compatibilityPct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stars = _pctToStars(compatibilityPct);

    final compatLabel = compatibilityPct >= 80
        ? l10n.migrationPlanResultCompatibilityHigh
        : compatibilityPct >= 60
        ? l10n.migrationPlanResultCompatibilityMedium
        : l10n.migrationPlanResultCompatibilityInitial;

    final starColor = compatibilityPct >= 80
        ? AppColors.success
        : compatibilityPct >= 60
        ? AppColors.warning
        : const Color(0xFF0088FF);

    return GestureDetector(
      onTap: onTap,
      child: FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    compatLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSoftFor(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StarRow(stars: stars, size: 26, color: starColor),
            const SizedBox(height: 6),
            Text(
              l10n.migrationResultRevealTapToSeeDetails(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Why this city ─────────────────────────────────────────────────────────────

class _WhyCitySection extends StatelessWidget {
  const _WhyCitySection({required this.cityName, required this.reasons});

  final String cityName;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.migrationResultRevealWhyTitle(cityName),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ...reasons
            .take(3)
            .map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FrostedPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 5, right: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          // Resolve l10n key → human-readable text
                          l10n.recommendationReasonLabel(reason),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

// ─── Alternatives ──────────────────────────────────────────────────────────────

class _AlternativesSection extends StatelessWidget {
  const _AlternativesSection({
    required this.cities,
    required this.confidence,
    required this.highlightedCity,
    required this.onTap,
    this.planTimeline,
  });

  final List<City> cities;
  final double confidence;
  final City highlightedCity;
  final void Function(City) onTap;

  /// When provided, each alternative city is checked for a seasonality
  /// conflict with the user's planned arrival window.
  final String? planTimeline;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    final recDims = MigrationPlanGenerator.cityDimensionsPublic(
      highlightedCity,
    );
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.migrationResultRevealOtherOptionsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ...cities.take(2).indexed.map((entry) {
          final (index, city) = entry;
          final imageUrl = cityImageUrlFor(city.id);
          final altPct = ((confidence * (index == 0 ? 0.85 : 0.70)) * 100)
              .round()
              .clamp(0, 100);

          // Seasonality conflict check
          final seasonConflict = planTimeline != null
              ? CitySeasonalityConflictService.evaluate(
                  city: city,
                  timeline: planTimeline,
                )
              : null;

          // Compute dimension diff chips
          final altDims = MigrationPlanGenerator.cityDimensionsPublic(city);
          // Biggest advantage of alt over highlighted city
          String? altWinsDim;
          double altWinsDelta = 0;
          // Biggest advantage of highlighted city over alt
          String? recWinsDim;
          double recWinsDelta = 0;
          for (final key in recDims.keys) {
            final rec = recDims[key] ?? 0;
            final alt = altDims[key] ?? 0;
            final delta = alt - rec;
            if (delta > altWinsDelta) {
              altWinsDelta = delta;
              altWinsDim = key;
            } else if (-delta > recWinsDelta) {
              recWinsDelta = -delta;
              recWinsDim = key;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => onTap(city),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // City thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) =>
                                          _AltCityPlaceholder(city: city),
                                    )
                                  : _AltCityPlaceholder(city: city),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${city.stateName} · ${city.stateCode}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSoftFor(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _StarRow(
                            stars: _pctToStars(altPct),
                            size: 13,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: AppColors.textSoftFor(context),
                          ),
                        ],
                      ),
                      // Diff chips row + seasonality conflict chip
                      if (altWinsDim != null ||
                          recWinsDim != null ||
                          (seasonConflict?.hasConflict == true)) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (altWinsDim != null)
                              _DiffChip(
                                label: _dimensionLabel(context, altWinsDim),
                                wins: true,
                                cityName: city.name,
                              ),
                            if (recWinsDim != null)
                              _DiffChip(
                                label: _dimensionLabel(context, recWinsDim),
                                wins: false,
                                cityName: highlightedCity.name,
                              ),
                            if (seasonConflict?.hasConflict == true)
                              _SeasonalityConflictChip(
                                conflict: seasonConflict!,
                                locale: locale,
                                isDark: isDark,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Seasonality conflict chip ────────────────────────────────────────────────

class _SeasonalityConflictChip extends StatelessWidget {
  const _SeasonalityConflictChip({
    required this.conflict,
    required this.locale,
    required this.isDark,
  });

  final SeasonalityConflict conflict;
  final String locale;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isCritical = conflict.level == SeasonalityConflictLevel.critical;
    final color = isCritical ? AppColors.danger : AppColors.caution;
    final label = conflict.overlapLabel(locale);
    final chipLabel = switch (locale) {
      'pt' => isCritical ? '⚠ Alta temporada ($label)' : 'Temporada ($label)',
      'es' => isCritical ? '⚠ Temporada alta ($label)' : 'Temporada ($label)',
      _ => isCritical ? '⚠ Peak season ($label)' : 'Season ($label)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.45 : 0.35),
        ),
      ),
      child: Text(
        chipLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─── Dimension helpers ────────────────────────────────────────────────────────

String _dimensionLabel(BuildContext context, String key) {
  final locale = Localizations.localeOf(context).languageCode;
  return switch (key) {
    'affordability' => switch (locale) {
      'pt' => 'Custo de vida',
      'es' => 'Costo de vida',
      _ => 'Cost of living',
    },
    'job_market' => switch (locale) {
      'pt' => 'Mercado de trabalho',
      'es' => 'Mercado laboral',
      _ => 'Job market',
    },
    'safety' => switch (locale) {
      'pt' => 'Segurança',
      'es' => 'Seguridad',
      _ => 'Safety',
    },
    'climate_warmth' => switch (locale) {
      'pt' => 'Clima',
      'es' => 'Clima',
      _ => 'Climate',
    },
    'transit_infra' => switch (locale) {
      'pt' => 'Infraestrutura',
      'es' => 'Infraestructura',
      _ => 'Infrastructure',
    },
    'nature' => switch (locale) {
      'pt' => 'Natureza',
      'es' => 'Naturaleza',
      _ => 'Nature',
    },
    'community' => switch (locale) {
      'pt' => 'Comunidade AR',
      'es' => 'Comunidad AR',
      _ => 'AR Community',
    },
    _ => key,
  };
}

IconData _dimensionIcon(String key) => switch (key) {
  'affordability' => Icons.account_balance_wallet_outlined,
  'job_market' => Icons.work_outline_rounded,
  'safety' => Icons.shield_outlined,
  'climate_warmth' => Icons.wb_sunny_outlined,
  'transit_infra' => Icons.directions_transit_outlined,
  'nature' => Icons.park_outlined,
  'community' => Icons.people_outline_rounded,
  _ => Icons.tune_rounded,
};

// ─── Timeline context bar ─────────────────────────────────────────────────────

/// Compact bar showing the user's declared timeline and how many guide steps
/// must be completed before boarding.
class _TimelineContextBar extends StatelessWidget {
  const _TimelineContextBar({required this.plan});

  final MigrationPlan plan;

  static (String label, Color color) _timelineInfo(
    String timeline,
    String locale,
  ) => switch (timeline) {
    'in_0_3m' => (
      switch (locale) {
        'pt' => '0–3 meses · urgente',
        'es' => '0–3 meses · urgente',
        _ => '0–3 months · urgent',
      },
      AppColors.danger,
    ),
    'in_3_6m' => (
      switch (locale) {
        'pt' => '3–6 meses',
        'es' => '3–6 meses',
        _ => '3–6 months',
      },
      AppColors.caution,
    ),
    'in_6_12m' => (
      switch (locale) {
        'pt' => '6–12 meses',
        'es' => '6–12 meses',
        _ => '6–12 months',
      },
      AppColors.success,
    ),
    'just_exploring' || 'depends' => (
      switch (locale) {
        'pt' => 'Apenas explorando',
        'es' => 'Solo explorando',
        _ => 'Just exploring',
      },
      AppColors.primary,
    ),
    _ => (
      switch (locale) {
        'pt' => 'Mais de 1 ano',
        'es' => 'Más de 1 año',
        _ => 'Over 1 year',
      },
      AppColors.success,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = AppColors.isDark(context);
    final (timelineLabel, color) = _timelineInfo(plan.timeline, locale);

    final guideItems = MigrationGuideRegistry.build(
      l10n: context.l10n,
      plan: plan,
      localeCode: locale,
    );
    final preArrivalCount = guideItems
        .where((i) => i.preArrivalRequired)
        .length;

    final preArrivalText = switch (locale) {
      'pt' => '$preArrivalCount etapas antes de embarcar',
      'es' => '$preArrivalCount pasos antes de embarcar',
      _ => '$preArrivalCount steps before you board',
    };
    final timelinePrefix = switch (locale) {
      'pt' => 'Prazo:',
      'es' => 'Plazo:',
      _ => 'Timeline:',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.24 : 0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: '$timelinePrefix '),
                  TextSpan(
                    text: timelineLabel,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                  const TextSpan(text: ' · '),
                  TextSpan(text: preArrivalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diff chip ────────────────────────────────────────────────────────────────

/// Shows a single dimension where a city wins (green) or loses (orange).
class _DiffChip extends StatelessWidget {
  const _DiffChip({
    required this.label,
    required this.wins,
    required this.cityName,
  });

  final String label;
  final bool wins; // true = this city wins on this dimension
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final color = wins ? AppColors.success : AppColors.caution;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wins ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── City Comparison Sheet ────────────────────────────────────────────────────

class _CityComparisonSheet extends StatefulWidget {
  const _CityComparisonSheet({
    required this.plan,
    required this.highlightedCity,
    required this.alternatives,
  });

  final MigrationPlan plan;
  final City highlightedCity;
  final List<City> alternatives;

  @override
  State<_CityComparisonSheet> createState() => _CityComparisonSheetState();
}

class _CityComparisonSheetState extends State<_CityComparisonSheet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = AppColors.isDark(context);
    final alternatives = widget.alternatives.take(2).toList(growable: false);
    if (alternatives.isEmpty) return const SizedBox.shrink();

    final compareCity =
        alternatives[_selectedIndex.clamp(0, alternatives.length - 1)];
    final recDims = MigrationPlanGenerator.cityDimensionsPublic(
      widget.highlightedCity,
    );
    final altDims = MigrationPlanGenerator.cityDimensionsPublic(compareCity);

    // Sort by absolute delta — most decisive dimensions first
    final keys = recDims.keys.toList();
    keys.sort((a, b) {
      final da = ((recDims[a] ?? 0) - (altDims[a] ?? 0)).abs();
      final db = ((recDims[b] ?? 0) - (altDims[b] ?? 0)).abs();
      return db.compareTo(da);
    });

    // Overall average score gap
    final recAvg = recDims.values.fold(0.0, (s, v) => s + v) / recDims.length;
    final altAvg = altDims.values.fold(0.0, (s, v) => s + v) / altDims.length;
    final gapPct = ((recAvg - altAvg) * 100).round().abs();
    final recWinsOverall = recAvg >= altAvg;

    final titleText = switch (locale) {
      'pt' => 'Comparar cidades',
      'es' => 'Comparar ciudades',
      _ => 'Compare cities',
    };

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titleText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSoftFor(context),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── City tabs (when >1 alternative) ─────────────────────────
                if (alternatives.length > 1) ...[
                  Row(
                    children: alternatives.indexed.map((entry) {
                      final (i, city) = entry;
                      final selected = i == _selectedIndex;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i < alternatives.length - 1 ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(
                                      alpha: isDark ? 0.18 : 0.10,
                                    )
                                  : AppColors.surfaceMutedFor(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.40)
                                    : AppColors.borderFor(context),
                              ),
                            ),
                            child: Text(
                              city.name,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSoftFor(context),
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Score gap banner ─────────────────────────────────────────
                _ScoreGapBanner(
                  highlightedCity: widget.highlightedCity,
                  compareCity: compareCity,
                  gapPct: gapPct,
                  recWins: recWinsOverall,
                  locale: locale,
                ),
                const SizedBox(height: 14),

                // ── Legend ───────────────────────────────────────────────────
                Row(
                  children: [
                    _LegendDot(color: AppColors.primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.highlightedCity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.caution),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        compareCity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.caution,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Dimension bars ────────────────────────────────────────────
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...keys.map(
                          (key) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DimensionComparisonRow(
                              label: _dimensionLabel(context, key),
                              icon: _dimensionIcon(key),
                              recScore: recDims[key] ?? 0,
                              altScore: altDims[key] ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _ArchetypeContextRow(
                          archetypeKey: widget.plan.archetypeKey,
                          selectedPriorities: widget.plan.selectedPriorities,
                          locale: locale,
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
    );
  }
}

// ─── Score gap banner ─────────────────────────────────────────────────────────

class _ScoreGapBanner extends StatelessWidget {
  const _ScoreGapBanner({
    required this.highlightedCity,
    required this.compareCity,
    required this.gapPct,
    required this.recWins,
    required this.locale,
  });

  final City highlightedCity;
  final City compareCity;
  final int gapPct;
  final bool recWins;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final winner = recWins ? highlightedCity.name : compareCity.name;

    final gapLabel = switch (gapPct) {
      <= 3 => switch (locale) {
        'pt' => 'empate técnico',
        'es' => 'empate técnico',
        _ => 'statistical tie',
      },
      <= 8 => switch (locale) {
        'pt' => 'diferença leve',
        'es' => 'diferencia leve',
        _ => 'slight edge',
      },
      <= 15 => switch (locale) {
        'pt' => 'vantagem clara',
        'es' => 'ventaja clara',
        _ => 'clear advantage',
      },
      _ => switch (locale) {
        'pt' => 'vantagem decisiva',
        'es' => 'ventaja decisiva',
        _ => 'decisive advantage',
      },
    };

    final bodyText = switch (locale) {
      'pt' => '$winner tem $gapPct pt a mais no índice geral — $gapLabel.',
      'es' => '$winner tiene $gapPct pt más en el índice general — $gapLabel.',
      _ => '$winner scores $gapPct pt higher overall — $gapLabel.',
    };

    final color = recWins ? AppColors.primary : AppColors.caution;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Text(
        bodyText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimaryFor(context),
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Dimension comparison row ─────────────────────────────────────────────────

class _DimensionComparisonRow extends StatelessWidget {
  const _DimensionComparisonRow({
    required this.label,
    required this.icon,
    required this.recScore,
    required this.altScore,
  });

  final String label;
  final IconData icon;
  final double recScore; // 0–1
  final double altScore; // 0–1

  @override
  Widget build(BuildContext context) {
    final recWins = recScore >= altScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.textSoftFor(context)),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _BarRow(score: recScore, color: AppColors.primary, wins: recWins),
        const SizedBox(height: 3),
        _BarRow(score: altScore, color: AppColors.caution, wins: !recWins),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.score, required this.color, required this.wins});

  final double score;
  final Color color;
  final bool wins;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final effectiveColor = wins ? color : color.withValues(alpha: 0.40);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '${(score * 100).round()}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: wins ? FontWeight.w700 : FontWeight.w400,
              color: wins ? color : AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 3),
        SizedBox(
          width: 14,
          child: wins
              ? Icon(Icons.check_rounded, size: 12, color: color)
              : null,
        ),
      ],
    );
  }
}

// ─── Archetype context row ────────────────────────────────────────────────────

class _ArchetypeContextRow extends StatelessWidget {
  const _ArchetypeContextRow({
    required this.archetypeKey,
    required this.selectedPriorities,
    required this.locale,
  });

  final String? archetypeKey;
  final List<String> selectedPriorities;
  final String locale;

  String _archetypeExplanation() {
    final key = archetypeKey ?? '';
    if (locale == 'pt') {
      return switch (key) {
        'job_hunter' || 'job_hunter_searching' =>
          'Para buscadores de emprego, mercado de trabalho pesou mais na decisão.',
        'job_hunter_with_offer' =>
          'Você já tem oferta — foco em infraestrutura e custo de vida.',
        'remote_worker' || 'remote_stable' =>
          'Para trabalho remoto, custo de vida, natureza e segurança pesaram mais.',
        'student' =>
          'Para estudantes, qualidade acadêmica e custo de vida foram priorizados.',
        'family_move' =>
          'Para família, segurança e comunidade argentina pesaram mais.',
        'fresh_start' =>
          'Para recomeço, custo de vida e segurança foram os fatores decisivos.',
        _ =>
          'A pontuação reflete um equilíbrio entre custo, oportunidades e qualidade de vida.',
      };
    } else if (locale == 'es') {
      return switch (key) {
        'job_hunter' || 'job_hunter_searching' =>
          'Para buscadores de empleo, el mercado laboral pesó más en la decisión.',
        'job_hunter_with_offer' =>
          'Ya tenés oferta — foco en infraestructura y costo de vida.',
        'remote_worker' || 'remote_stable' =>
          'Para trabajo remoto, costo de vida, naturaleza y seguridad pesaron más.',
        'student' =>
          'Para estudiantes, calidad académica y costo de vida fueron priorizados.',
        'family_move' =>
          'Para familia, seguridad y comunidad argentina pesaron más.',
        'fresh_start' =>
          'Para nuevo comienzo, costo de vida y seguridad fueron decisivos.',
        _ =>
          'El puntaje refleja un equilibrio entre costo, oportunidades y calidad de vida.',
      };
    } else {
      return switch (key) {
        'job_hunter' || 'job_hunter_searching' =>
          'For job seekers, the job market dimension carried the most weight.',
        'job_hunter_with_offer' =>
          'You have an offer — infrastructure and cost of living drove the score.',
        'remote_worker' || 'remote_stable' =>
          'For remote workers, cost, nature, and safety were the main factors.',
        'student' =>
          'For students, academic quality and affordability were prioritized.',
        'family_move' =>
          'For families, safety and Argentine community carried the most weight.',
        'fresh_start' =>
          'For fresh starts, cost of living and safety were decisive.',
        _ => 'The score balances cost, opportunities, and quality of life.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final explanation = _archetypeExplanation();

    final priorityPrefix = switch (locale) {
      'pt' => 'Suas prioridades:',
      'es' => 'Tus prioridades:',
      _ => 'Your priorities:',
    };

    final priorityLabels = selectedPriorities
        .where((p) => p != 'balanced_unsure')
        .map(
          (p) => switch (p) {
            'low_cost' => switch (locale) {
              'pt' => 'Custo baixo',
              'es' => 'Bajo costo',
              _ => 'Low cost',
            },
            'job_opportunities' => switch (locale) {
              'pt' => 'Emprego',
              'es' => 'Empleo',
              _ => 'Jobs',
            },
            'safety' => switch (locale) {
              'pt' => 'Segurança',
              'es' => 'Seguridad',
              _ => 'Safety',
            },
            'warm_climate_beach' => switch (locale) {
              'pt' => 'Praia/clima',
              'es' => 'Playa/clima',
              _ => 'Beach/climate',
            },
            'transit_infra' => switch (locale) {
              'pt' => 'Transporte',
              'es' => 'Transporte',
              _ => 'Transit',
            },
            'nature' => switch (locale) {
              'pt' => 'Natureza',
              'es' => 'Naturaleza',
              _ => 'Nature',
            },
            'community' => switch (locale) {
              'pt' => 'Comunidade AR',
              'es' => 'Comunidad AR',
              _ => 'AR Community',
            },
            'close_to_argentina' => switch (locale) {
              'pt' => 'Próximo à AR',
              'es' => 'Cerca de AR',
              _ => 'Near Argentina',
            },
            _ => p,
          },
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: AppColors.textSoftFor(context),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (priorityLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              priorityPrefix,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSoftFor(context),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: priorityLabels
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.14 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Legend dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _AltCityPlaceholder extends StatelessWidget {
  const _AltCityPlaceholder({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.isDark(context)
          ? const Color(0xFF1A3A5C)
          : const Color(0xFF2E5C8A),
      alignment: Alignment.center,
      child: Text(
        city.name[0],
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.6),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Dimension row (icon + label + mini-stars) ────────────────────────────────

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final double value; // 0.0 – 1.0

  @override
  Widget build(BuildContext context) {
    final stars = _pctToStars((value * 100).round());
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          _StarRow(stars: stars, size: 14, color: AppColors.warning),
        ],
      ),
    );
  }
}

// ─── Compatibility explanation card ──────────────────────────────────────────

class _CompatibilityExplanationCard extends StatelessWidget {
  const _CompatibilityExplanationCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = AppColors.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.textSoftFor(context),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.migrationPlanResultCompatibilityHelpTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.migrationPlanResultCompatibilityHelpBody,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _HowStarsWorkExplanation(),
        ],
      ),
    );
  }
}

// ─── How stars work row ───────────────────────────────────────────────────────

class _HowStarsWorkExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final rows = switch (lang) {
      'pt' => const [
        (5.0, '★★★★★', 'Excelente match para o seu perfil'),
        (4.0, '★★★★☆', 'Muito boa compatibilidade'),
        (3.0, '★★★☆☆', 'Boa compatibilidade'),
        (2.0, '★★☆☆☆', 'Compatibilidade inicial'),
      ],
      'es' => const [
        (5.0, '★★★★★', 'Excelente match con tu perfil'),
        (4.0, '★★★★☆', 'Muy buena compatibilidad'),
        (3.0, '★★★☆☆', 'Buena compatibilidad'),
        (2.0, '★★☆☆☆', 'Compatibilidad inicial'),
      ],
      _ => const [
        (5.0, '★★★★★', 'Excellent match for your profile'),
        (4.0, '★★★★☆', 'Very good compatibility'),
        (3.0, '★★★☆☆', 'Good compatibility'),
        (2.0, '★★☆☆☆', 'Initial compatibility'),
      ],
    };

    return Column(
      children: rows.map((row) {
        final (_, stars, label) = row;
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                stars,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.warning,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Footer CTA ────────────────────────────────────────────────────────────────

class _FooterCta extends StatefulWidget {
  const _FooterCta({
    required this.city,
    required this.hasAlternatives,
    required this.onViewDetails,
    required this.onCompare,
    required this.onStartPreparation,
  });

  final City city;
  final bool hasAlternatives;
  final Future<void> Function() onViewDetails;
  final Future<void> Function() onCompare;
  final Future<void> Function() onStartPreparation;

  @override
  State<_FooterCta> createState() => _FooterCtaState();
}

class _FooterCtaState extends State<_FooterCta> {
  bool _isOpeningDetails = false;
  bool _isComparing = false;
  bool _isStartingPreparation = false;

  Future<void> _handleViewDetails() async {
    if (_isOpeningDetails) return;
    setState(() => _isOpeningDetails = true);
    try {
      await widget.onViewDetails();
    } finally {
      if (mounted) setState(() => _isOpeningDetails = false);
    }
  }

  Future<void> _handleCompare() async {
    if (_isComparing) return;
    setState(() => _isComparing = true);
    try {
      await widget.onCompare();
    } finally {
      if (mounted) setState(() => _isComparing = false);
    }
  }

  Future<void> _handleStartPreparation() async {
    if (_isStartingPreparation) return;
    setState(() => _isStartingPreparation = true);
    try {
      await widget.onStartPreparation();
    } finally {
      if (mounted) setState(() => _isStartingPreparation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;

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
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isStartingPreparation
                  ? null
                  : _handleStartPreparation,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isStartingPreparation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.migrationResultRevealStartPreparationCta(
                        widget.city.name,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isOpeningDetails ? null : _handleViewDetails,
                  icon: _isOpeningDetails
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_city_outlined, size: 16),
                  label: Text(
                    l10n.migrationResultRevealExploreCity,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.hasAlternatives && !_isComparing
                      ? _handleCompare
                      : null,
                  icon: _isComparing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compare_arrows_rounded, size: 16),
                  label: Text(
                    l10n.migrationResultRevealCompareCta,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Guide Preview ────────────────────────────────────────────────────────────

/// Shows a teaser of the guided migration plan — one item per phase — to give
/// the user a sense of what awaits after they confirm the city.
class _GuidePreviewSection extends StatelessWidget {
  const _GuidePreviewSection({required this.plan, required this.cityName});

  final MigrationPlan plan;
  final String cityName;

  // Accent colors keyed to each phase.
  static const _phaseColor = {
    GuidePhase.preparation: Color(0xFF4F46E5),
    GuidePhase.housing: Color(0xFF0891B2),
    GuidePhase.documents: Color(0xFF2563EB),
    GuidePhase.work: Color(0xFF16A34A),
    GuidePhase.arrival: Color(0xFFEA580C),
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final allItems = MigrationGuideRegistry.build(
      l10n: context.l10n,
      plan: plan,
      localeCode: locale,
    );

    // Pick the first item from each phase (preserves natural order).
    final Map<GuidePhase, GuideActionItem> byPhase = {};
    for (final item in allItems) {
      byPhase.putIfAbsent(item.phase, () => item);
    }
    final preview = GuidePhase.values
        .where(byPhase.containsKey)
        .map((p) => byPhase[p]!)
        .toList(growable: false);

    if (preview.isEmpty) return const SizedBox.shrink();

    final isDark = AppColors.isDark(context);
    final headerLabel = switch (locale) {
      'pt' => 'SEU PLANO DE MIGRAÇÃO',
      'es' => 'TU PLAN DE MIGRACIÓN',
      _ => 'YOUR MIGRATION PLAN',
    };
    final stepCountLabel = switch (locale) {
      'pt' => '${allItems.length} passos',
      'es' => '${allItems.length} pasos',
      _ => '${allItems.length} steps',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  headerLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0x590A0F1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stepCountLabel,
                  style: AppTypography.compactBadge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Preview items
        ...preview.indexed.map((entry) {
          final (index, item) = entry;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < preview.length - 1 ? 8 : 0,
            ),
            child: _GuidePreviewItem(
              item: item,
              phaseColor: _phaseColor[item.phase] ?? AppColors.primary,
              index: index + 1,
            ),
          );
        }),
      ],
    );
  }
}

/// A single compact row card representing one guide step.
class _GuidePreviewItem extends StatelessWidget {
  const _GuidePreviewItem({
    required this.item,
    required this.phaseColor,
    required this.index,
  });

  final GuideActionItem item;
  final Color phaseColor;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;

    final phaseLabel = switch (item.phase) {
      GuidePhase.preparation => switch (locale) {
        'pt' => 'Preparação',
        'es' => 'Preparación',
        _ => 'Preparation',
      },
      GuidePhase.housing => switch (locale) {
        'pt' => 'Moradia',
        'es' => 'Vivienda',
        _ => 'Housing',
      },
      GuidePhase.documents => switch (locale) {
        'pt' => 'Documentos',
        'es' => 'Documentos',
        _ => 'Documents',
      },
      GuidePhase.work => switch (locale) {
        'pt' => 'Trabalho',
        'es' => 'Trabajo',
        _ => 'Work',
      },
      GuidePhase.arrival => switch (locale) {
        'pt' => 'Chegada',
        'es' => 'Llegada',
        _ => 'Arrival',
      },
    };

    final effortLabel = switch (item.estimatedEffort) {
      GuideEstimatedEffort.fast => switch (locale) {
        'pt' => '< 1h',
        'es' => '< 1h',
        _ => '< 1h',
      },
      GuideEstimatedEffort.medium => switch (locale) {
        'pt' => '1–3h',
        'es' => '1–3h',
        _ => '1–3h',
      },
      GuideEstimatedEffort.longer => switch (locale) {
        'pt' => '3h+',
        'es' => '3h+',
        _ => '3h+',
      },
      null => null,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTypography.compactBadge.copyWith(
                  color: phaseColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryFor(context),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // Meta row: phase pill + effort + pre-arrival flag
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    // Phase pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: phaseColor.withValues(
                          alpha: isDark ? 0.18 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        phaseLabel,
                        style: AppTypography.compactBadge.copyWith(
                          color: phaseColor,
                        ),
                      ),
                    ),
                    // Effort badge
                    if (effortLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          effortLabel,
                          style: AppTypography.compactBadge.copyWith(
                            color: AppColors.textSoftFor(context),
                          ),
                        ),
                      ),
                    // Pre-arrival flag
                    if (item.preArrivalRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flight_takeoff_rounded,
                              size: 9,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              switch (locale) {
                                'pt' => 'Antes de viajar',
                                'es' => 'Antes de viajar',
                                _ => 'Before flying',
                              },
                              style: AppTypography.compactBadge.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ──────────────────────────────────────────────────────────

class _RevealSkeleton extends StatelessWidget {
  const _RevealSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final shimmer = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Column(
      children: [
        // Hero placeholder
        Container(
          height: MediaQuery.of(context).size.height * 0.38,
          color: shimmer,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AntiAnchorReinforcementBanner extends StatelessWidget {
  const _AntiAnchorReinforcementBanner({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.thumb_up_alt_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.antiAnchorReinforcementTitle(cityName),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.antiAnchorReinforcementBody(cityName),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AntiAnchorComparisonSection extends StatelessWidget {
  const _AntiAnchorComparisonSection({
    required this.preferredCity,
    required this.highlightedCity,
    required this.onGoWithPreferred,
    required this.onTryHighlighted,
  });

  final City preferredCity;
  final City highlightedCity;
  final VoidCallback onGoWithPreferred;
  final VoidCallback onTryHighlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);

    final prefDims = MigrationPlanGenerator.cityDimensionsPublic(preferredCity);
    final recDims = MigrationPlanGenerator.cityDimensionsPublic(
      highlightedCity,
    );

    final strengths = <String>[];
    final attentionPoints = <String>[];

    for (final key in recDims.keys) {
      final recVal = recDims[key] ?? 0;
      final prefVal = prefDims[key] ?? 0;
      final diff = recVal - prefVal;
      if (diff > 0.10) {
        strengths.add(l10n.dimensionLabel(key));
      } else if (diff < -0.10) {
        attentionPoints.add(l10n.dimensionLabel(key));
      }
    }

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.antiAnchorComparisonTitle(preferredCity.name),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.antiAnchorComparisonBody(
                        preferredCity.name,
                        highlightedCity.name,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (strengths.isNotEmpty) ...[
            Text(
              '${l10n.antiAnchorStrength()} · ${highlightedCity.name}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 6),
            ...strengths.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (attentionPoints.isNotEmpty) ...[
            Text(
              '${l10n.antiAnchorAttention()} · ${highlightedCity.name}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 6),
            ...attentionPoints.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onGoWithPreferred,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.antiAnchorGoWithPreferred(preferredCity.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onTryHighlighted,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.antiAnchorTryRecommended(highlightedCity.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

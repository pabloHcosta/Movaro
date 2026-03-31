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
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_seasonality_card.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_conflict_service.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_map_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_insight_sheet.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_public_opinion_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_seasonality_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_snapshot_tile.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_sources_section.dart';
import 'package:movaro_app/features/cities/presentation/pages/city_explore_screen.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/application/city_budget_data.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';

class CityDetailPage extends StatefulWidget {
  const CityDetailPage({
    required this.cityId,
    required this.citiesController,
    required this.locationController,
    this.migrationQuestionnaireController,
    this.selectForPlan = false,
    this.fromMigrationResult = false,
    this.validationFlow = false,
    super.key,
  });

  final String cityId;
  final CitiesController citiesController;
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
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;
  late Future<bool> _locationBannerFuture;
  final ExpansibleController _analysisTileController =
      ExpansibleController();
  final _mapSectionKey = GlobalKey();
  final _costSectionKey = GlobalKey();
  final _flightsSectionKey = GlobalKey();
  final _seasonalitySectionKey = GlobalKey();
  final _analysisSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _locationBannerFuture = widget.locationController.shouldShowInlineBanner();
    widget.locationController.addListener(_handleLocationChanged);
    _scrollController.addListener(_handleScroll);
    _load();
  }

  @override
  void dispose() {
    widget.locationController.removeListener(_handleLocationChanged);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleLocationChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _locationBannerFuture = widget.locationController.shouldShowInlineBanner();
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
    _refreshScrollHint();

    if (city != null) {
      unawaited(widget.citiesController.loadWeatherForCity(city.id));
    }

    await methodologyFuture;
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
    final journeyDetected =
        widget.migrationQuestionnaireController
            ?.journeyContextController
            .detectedLocation;
    if (journeyDetected?.latitude != null && journeyDetected?.longitude != null) {
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
    _analysisTileController.expand();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) {
      return;
    }
    _scrollToKey(_analysisSectionKey);
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

                          // ── Block 2: Quick Summary ──────────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _QuickSummaryCard(city: city),
                          ),
                          const SizedBox(height: 12),

                          // ── Block 3: Category List ──────────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _CategoryListCard(city: city),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _ArrivalViabilityCard(
                              city: city,
                              budget: CityBudgetData.forCity(city.id),
                              preferredCountryId: plan?.originCountry,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Block 4: Secondary Actions ──────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _SecondaryActionsRow(
                              onPhotos: () => _openMediaExplore(city),
                              onMap: () => _scrollToKey(_mapSectionKey),
                              onCost: () => _scrollToKey(_costSectionKey),
                              onFlights: () => _scrollToKey(_flightsSectionKey),
                              onSeasonality: () =>
                                  _scrollToKey(_seasonalitySectionKey),
                              onAnalysis: _openAnalysisSection,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (CityBudgetData.forCity(city.id) case final budget?)
                            ...[
                              ConstrainedBox(
                                key: _costSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: CityCostOfLivingCard(
                                  budget: budget,
                                  preferredCountryId: plan?.originCountry,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          const SizedBox(height: 16),

                          // ── Location banner ─────────────────────────────
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

                                    if (!mounted) {
                                      return;
                                    }

                                    setState(() {
                                      _locationBannerFuture = widget
                                          .locationController
                                          .shouldShowInlineBanner();
                                    });

                                    if (granted == true &&
                                        widget.locationController.savedLocation !=
                                            null) {
                                      await _load();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Map section ─────────────────────────────────
                          ConstrainedBox(
                            key: _mapSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
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
                          const SizedBox(height: 16),

                          // ── Seasonality Alert ────────────────────────────
                          if (CitySeasonalityProfile.hasSeason(city)) ...[
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              key: _seasonalitySectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
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
                          ],

                          if (city.publicOpinion != null) ...[
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: CityPublicOpinionSection(
                                opinion: city.publicOpinion!,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // ── Deep Dive (Analysis) ────────────────────────
                          ConstrainedBox(
                            key: _analysisSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
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
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _SnapshotPanel(
                                      city: city,
                                      localeName: localeName,
                                      showTitle: false,
                                    ),
                                  ),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final wide = constraints.maxWidth >= 980;
                                      final detailWidth = wide
                                          ? (constraints.maxWidth - 16) / 2
                                          : constraints.maxWidth;

                                      return Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          SizedBox(
                                            width: detailWidth,
                                            child: _AffordabilityHousingPanel(
                                              city: city,
                                            ),
                                          ),
                                          SizedBox(
                                            width: detailWidth,
                                            child: _WorkOpportunityPanel(
                                              city: city,
                                            ),
                                          ),
                                          SizedBox(
                                            width: detailWidth,
                                            child: _SettleInPanel(city: city),
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
                          const SizedBox(height: 16),

                          // ── Decision Snapshot ───────────────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _DecisionSnapshotPanel(
                              city: city,
                              planContext: planContext,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Flights ─────────────────────────────────────
                          ConstrainedBox(
                            key: _flightsSectionKey,
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: FlightSeasonalityCard(
                              originCountryIso: originCountryIso,
                              originIata: originAirport?.iataCode,
                              destIata: destinationAirport?.iataCode,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: CitySourcesSection(sources: city.sources),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              '${l10n.citiesMethodologyNote} · ${l10n.cityDetailUpdatedLabel(_formatUpdatedAt(context, city.updatedAt))}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    height: 1.4,
                                  ),
                            ),
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
                      return AppGlassHeader(
                        title: l10n.cityDetailHeaderTitle(),
                        onBack: _goBackToCities,
                        onHelp: _showHelp,
                      );
                    },
                  ),
                ),
              ),

              // ── Scroll hint ────────────────────────────────────────────────
              if (city != null)
                _ScrollHintOverlay(
                  visible: _showScrollHint,
                  label: context.l10n.bmpScrollHint,
                  onTap: _scrollDown,
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

  void _handleScroll() {
    _refreshScrollHint();
  }

  void _refreshScrollHint() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final nextValue =
        position.maxScrollExtent > 40 &&
        position.pixels < position.maxScrollExtent - 32;
    if (nextValue != _showScrollHint && mounted) {
      setState(() {
        _showScrollHint = nextValue;
      });
    }
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final nextOffset = _scrollController.offset + 360;
    _scrollController.animateTo(
      nextOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
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

  Future<void> _openCityGoogleOverview(City city) async {
    final uri = PreparationResourceLinks.buildCityGoogleSearch(city);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: context.l10n.cityDetailDiscoverAction,
          uri: uri,
        ),
      ),
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

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.1,
    );
  }

  Future<void> _openMediaExplore(City city) async {
    await precacheCityImage(context, city);
    if (!mounted) return;
    final isPlanCity =
        widget
            .migrationQuestionnaireController
            ?.generatedPlan
            ?.recommendedCity
            ?.id ==
        city.id;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CityExploreScreen(city: city, isPlanCity: isPlanCity),
      ),
    );
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
                : const Text(
                    'Iniciar →',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
              'Plano iniciado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFF0F6FC),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você escolheu $cityName.\nVamos transformar isso em realidade.',
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
    final heroHeight = MediaQuery.of(context).size.height * 0.38;
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

class _SummaryTableRow extends StatelessWidget {
  const _SummaryTableRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return const Distance().as(
      LengthUnit.Kilometer,
      userPoint,
      LatLng(widget.city.latitude, widget.city.longitude),
    ).round();
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
              value: userPoint == null ? context.l10n.cityDetailMapOriginMissingLabel() : originName,
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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

class _CompareCitiesStrip extends StatelessWidget {
  const _CompareCitiesStrip({
    required this.city,
    required this.onCompareAction,
  });

  final City city;
  final VoidCallback onCompareAction;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cityDetailCompareAction,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.cityDetailCompareSelectedBody(city.name),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onCompareAction,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: Text(context.l10n.cityComparisonCompareAction),
          ),
        ],
      ),
    );
  }
}

// ─── Score helper functions (shared by summary card + original panel) ─────────

String _costLabelForCity(BuildContext context, City city) {
  if (city.rentScore >= 70) return context.l10n.migrationPlanResultCostLower;
  if (city.rentScore >= 45) return context.l10n.migrationPlanResultCostMedium;
  return context.l10n.migrationPlanResultCostHigher;
}

Color _costColorForCity(City city) {
  if (city.rentScore >= 70) return AppColors.success;
  if (city.rentScore >= 45) return AppColors.warning;
  return AppColors.danger;
}

String _qualityLabelForCity(BuildContext context, City city) {
  final average =
      ((city.idhmScore * 100).round() +
          city.safetyScore +
          city.spanishSupportScore) /
      3;
  if (average >= 72) return context.l10n.cityDetailQualityHigh;
  if (average >= 56) return context.l10n.cityDetailQualityBalanced;
  return context.l10n.cityDetailQualityDeveloping;
}

Color _qualityColorForCity(City city) {
  final average =
      ((city.idhmScore * 100).round() +
          city.safetyScore +
          city.spanishSupportScore) /
      3;
  if (average >= 72) return AppColors.success;
  if (average >= 56) return AppColors.primary;
  return AppColors.warning;
}

String _difficultyLabelForCity(BuildContext context, City city) {
  final average =
      (city.rentScore +
          city.movaroScores.languageAdaptation +
          city.movaroScores.workOpportunity) /
      3;
  if (average >= 68) return context.l10n.cityDetailDifficultyEasy;
  if (average >= 52) return context.l10n.cityDetailDifficultyBalanced;
  return context.l10n.cityDetailDifficultyChallenging;
}

Color _difficultyColorForCity(City city) {
  final average =
      (city.rentScore +
          city.movaroScores.languageAdaptation +
          city.movaroScores.workOpportunity) /
      3;
  if (average >= 68) return AppColors.success;
  if (average >= 52) return AppColors.warning;
  return AppColors.danger;
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

  @override
  Widget build(BuildContext context) {
    final primaryLabel = planContext?.isRecommended == true
        ? context.l10n.migrationPlanChooseCityAction
        : validationFlow
        ? context.l10n.migrationPlanChooseCityAction
        : context.l10n.cityDetailAddToPlanAction;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(primaryLabel),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCompareAction,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: Text(context.l10n.cityDetailCompareAction),
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
  const _QuickSummaryCard({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: _SummaryIndicator(
                  label: context.l10n.cityDetailAffordabilityTitle,
                  value: _costLabelForCity(context, city),
                  color: _costColorForCity(city),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryIndicator(
                  label: context.l10n.cityDetailQualityLabel,
                  value: _qualityLabelForCity(context, city),
                  color: _qualityColorForCity(city),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryIndicator(
                  label: context.l10n.cityDetailDifficultyLabel,
                  value: _difficultyLabelForCity(context, city),
                  color: _difficultyColorForCity(city),
                ),
              ),
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
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  });

  final City city;
  final CityBudget? budget;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final pressure = _entryPressure(context);
    final pressureWhy = _entryPressureWhy(context);
    final firstFocus = _firstFocus(context);
    final firstFocusBody = _firstFocusBody(context);
    final reserveMonths = city.rentScore >= 70 ? 2 : 3;
    final reserveAmount = budget == null
        ? null
        : budget!.fairLivingTotal * reserveMonths;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cityDetailArrivalViabilityTitle(),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.cityDetailArrivalViabilityBody(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
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
                        ? context.l10n.cityDetailArrivalReserveSupportingNoData()
                        : context.l10n.cityDetailArrivalReserveSupporting(
                            reserveMonths,
                          ),
                    basis: budget == null
                        ? null
                        : context.l10n.cityDetailArrivalReserveBasis(
                            budget!.cityLabel,
                          ),
                    source: budget == null
                        ? null
                        : '${budget!.sourceLabel} · ${budget!.updatedAt}',
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
                    source: city.sources.curatedMetrics.provider,
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
        ],
      ),
    );
  }

  (String, Color, String) _entryPressure(BuildContext context) {
    final base = (city.rentScore + city.movaroScores.languageAdaptation + city.safetyScore) / 3;
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

    return context.l10n.cityDetailArrivalPressureBasis(
      housing,
      language,
      safety,
      seasonality,
    );
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
    }.entries.toList()
      ..sort((a, b) => a.value.score.compareTo(b.value.score));

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
      return 'IBGE · ${city.sources.curatedMetrics.provider}';
    }
    if (focus == context.l10n.cityDetailArrivalFocusSafety()) {
      return 'Atlas da Violencia · ${city.sources.curatedMetrics.provider}';
    }
    return city.sources.curatedMetrics.provider;
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
          Text(
            supporting,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          if (basis != null) ...[
            const SizedBox(height: 8),
            Text(
              basis!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (source != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.cityDetailArrivalSourceLabel(source!),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Block 4: Secondary Actions ───────────────────────────────────────────────

class _SecondaryActionsRow extends StatelessWidget {
  const _SecondaryActionsRow({
    required this.onPhotos,
    required this.onMap,
    required this.onCost,
    required this.onFlights,
    required this.onSeasonality,
    required this.onAnalysis,
  });

  final VoidCallback onPhotos;
  final VoidCallback onMap;
  final VoidCallback onCost;
  final VoidCallback onFlights;
  final VoidCallback onSeasonality;
  final VoidCallback onAnalysis;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        icon: Icons.photo_library_outlined,
        label: context.l10n.cityDetailPhotosAction(),
        onTap: onPhotos,
      ),
      (
        icon: Icons.map_outlined,
        label: context.l10n.cityDetailMapAction(),
        onTap: onMap,
      ),
      (
        icon: Icons.payments_outlined,
        label: context.l10n.cityDetailCostAction(),
        onTap: onCost,
      ),
      (
        icon: Icons.flight_outlined,
        label: context.l10n.cityDetailFlightsAction(),
        onTap: onFlights,
      ),
      (
        icon: Icons.wb_sunny_outlined,
        label: context.l10n.cityDetailSeasonalityAction(),
        onTap: onSeasonality,
      ),
      (
        icon: Icons.analytics_outlined,
        label: context.l10n.cityDetailAnalysisAction(),
        onTap: onAnalysis,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _SecondaryActionButton(
            icon: action.icon,
            label: action.label,
            onTap: action.onTap,
          );
        },
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceFor(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
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

// ─── Legacy panels (kept for reference, no longer used in main ListView) ──────

class _CitySummaryPanel extends StatelessWidget {
  const _CitySummaryPanel({
    required this.city,
    required this.planContext,
    required this.onPrimaryAction,
    required this.onCompareAction,
  });

  final City city;
  final _PlanCityContext? planContext;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCompareAction;

  @override
  Widget build(BuildContext context) {
    final plan = planContext;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.cityDetailSummaryTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (plan?.isRecommended == true)
                _ContextChip(label: context.l10n.cityDetailPlanLeadingChip),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryTableRow(
            label: context.l10n.cityDetailAffordabilityTitle,
            value: _costLabel(context),
            color: _costColor(),
          ),
          const SizedBox(height: 10),
          _SummaryTableRow(
            label: context.l10n.cityDetailQualityLabel,
            value: _qualityLabel(context),
            color: _qualityColor(),
          ),
          const SizedBox(height: 10),
          _SummaryTableRow(
            label: context.l10n.cityDetailDifficultyLabel,
            value: _difficultyLabel(context),
            color: _difficultyColor(),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onPrimaryAction,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  plan?.isRecommended == true
                      ? context.l10n.migrationPlanChooseCityAction
                      : context.l10n.cityDetailAddToPlanAction,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCompareAction,
                icon: const Icon(Icons.compare_arrows_rounded),
                label: Text(context.l10n.cityDetailCompareAction),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _costLabel(BuildContext context) {
    if (city.rentScore >= 70) {
      return context.l10n.migrationPlanResultCostLower;
    }
    if (city.rentScore >= 45) {
      return context.l10n.migrationPlanResultCostMedium;
    }
    return context.l10n.migrationPlanResultCostHigher;
  }

  Color _costColor() {
    if (city.rentScore >= 70) {
      return AppColors.success;
    }
    if (city.rentScore >= 45) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  String _qualityLabel(BuildContext context) {
    final average =
        ((city.idhmScore * 100).round() +
            city.safetyScore +
            city.spanishSupportScore) /
        3;
    if (average >= 72) {
      return context.l10n.cityDetailQualityHigh;
    }
    if (average >= 56) {
      return context.l10n.cityDetailQualityBalanced;
    }
    return context.l10n.cityDetailQualityDeveloping;
  }

  Color _qualityColor() {
    final average =
        ((city.idhmScore * 100).round() +
            city.safetyScore +
            city.spanishSupportScore) /
        3;
    if (average >= 72) {
      return AppColors.success;
    }
    if (average >= 56) {
      return AppColors.primary;
    }
    return AppColors.warning;
  }

  String _difficultyLabel(BuildContext context) {
    final average =
        (city.rentScore +
            city.movaroScores.languageAdaptation +
            city.movaroScores.workOpportunity) /
        3;
    if (average >= 68) {
      return context.l10n.cityDetailDifficultyEasy;
    }
    if (average >= 52) {
      return context.l10n.cityDetailDifficultyBalanced;
    }
    return context.l10n.cityDetailDifficultyChallenging;
  }

  Color _difficultyColor() {
    final average =
        (city.rentScore +
            city.movaroScores.languageAdaptation +
            city.movaroScores.workOpportunity) /
        3;
    if (average >= 68) {
      return AppColors.success;
    }
    if (average >= 52) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }
}

class _DecisionSnapshotPanel extends StatelessWidget {
  const _DecisionSnapshotPanel({required this.city, this.planContext});

  final City city;
  final _PlanCityContext? planContext;

  @override
  Widget build(BuildContext context) {
    final bestFor = planContext?.focusLabel ?? _bestForLabel(context, city);
    final reasons = (planContext?.reasons ?? city.recommendationReasons)
        .map(context.l10n.recommendationReasonLabel)
        .toSet()
        .take(3)
        .toList(growable: false);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cityDetailDecisionSnapshotTitle,
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
          if (planContext != null) ...[
            const SizedBox(height: 12),
            InsightCard(
              title: context.l10n.cityDetailWatchoutTitle,
              body: planContext!.watchout,
              icon: Icons.warning_amber_rounded,
              tint: AppColors.warning,
            ),
          ],
        ],
      ),
    );
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

class _EssentialsGrid extends StatelessWidget {
  const _EssentialsGrid({required this.city, this.primaryPriority});

  final City city;
  final String? primaryPriority;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 760
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items) SizedBox(width: cardWidth, child: item),
          ],
        );
      },
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final entries = <({String key, Widget tile})>[
      (
        key: 'low_cost',
        tile: _EssentialMetricTile(
          label: context.l10n.cityDetailAffordabilityTitle,
          presentation: CityHousingViabilityPresenter.resolve(
            context,
            rentScore: city.rentScore,
          ),
          icon: Icons.home_work_outlined,
          onTap: () => showCityMetricInsightSheet(
            context,
            city: city,
            topic: CityMetricInsightTopic.housing,
          ),
        ),
      ),
      (
        key: 'safety',
        tile: _EssentialMetricTile(
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
      ),
      (
        key: 'job_opportunities',
        tile: _EssentialMetricTile(
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
      ),
      (
        key: 'community',
        tile: _EssentialMetricTile(
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
      ),
    ];

    if (primaryPriority == null) {
      return entries.map((entry) => entry.tile).toList(growable: false);
    }

    entries.sort((a, b) {
      if (a.key == primaryPriority) {
        return -1;
      }
      if (b.key == primaryPriority) {
        return 1;
      }
      return 0;
    });

    return entries.map((entry) => entry.tile).toList(growable: false);
  }
}

class _CityExternalOverviewPanel extends StatelessWidget {
  const _CityExternalOverviewPanel({
    required this.city,
    required this.onOpenGoogleOverview,
  });

  final City city;
  final VoidCallback onOpenGoogleOverview;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cityDetailDiscoverAction,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${city.name}, ${city.stateCode}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: onOpenGoogleOverview,
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text(context.l10n.cityDetailDiscoverAction),
          ),
        ],
      ),
    );
  }
}

class _EssentialMetricTile extends StatelessWidget {
  const _EssentialMetricTile({
    required this.label,
    required this.presentation,
    required this.onTap,
    this.icon,
  });

  final String label;
  final dynamic presentation;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = icon ?? presentation.icon as IconData;
    final tint = presentation.tint as Color;
    final background = presentation.background as Color;
    final headline = presentation.headline as String;
    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.alphaBlend(tint.withValues(alpha: 0.16), background),
        background,
        Color.alphaBlend(tint.withValues(alpha: 0.07), background),
      ],
      stops: const [0, 0.45, 1],
    );

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: FrostedPanel(
              backgroundColor: background,
              gradient: cardGradient,
              borderColor: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(
                    alpha: AppColors.isDark(context) ? 0.12 : 0.10,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Stack(
                children: [
                  Positioned(
                    top: -34,
                    right: -12,
                    child: IgnorePointer(
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              tint.withValues(alpha: 0.22),
                              tint.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -52,
                    left: -28,
                    child: IgnorePointer(
                      child: Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha: AppColors.isDark(context) ? 0.06 : 0.24,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: tint.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: tint.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Icon(resolvedIcon, color: tint, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: tint,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  headline,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: tint,
                                        height: 1.05,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: tint.withValues(alpha: 0.92),
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AffordabilityHousingPanel extends StatelessWidget {
  const _AffordabilityHousingPanel({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final cost = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.cost,
      value: city.movaroScores.economical,
    );
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );

    return _DetailBlock(
      title: context.l10n.cityDetailAffordabilityTitle,
      children: [
        Text(
          context.l10n.housingDecisionSectionBodyWithCity(city.name),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        _InlineMetricRow(
          icon: Icons.payments_outlined,
          label: context.l10n.cityDetailCostLabel,
          headline: cost.headline,
          supporting: cost.supporting,
          tint: cost.tint,
        ),
        const SizedBox(height: 12),
        _InlineMetricRow(
          icon: Icons.house_rounded,
          label: context.l10n.cityHousingViabilityTileLabel,
          headline: housing.headline,
          supporting: housing.supporting,
          tint: housing.tint,
        ),
      ],
    );
  }
}

class _WorkOpportunityPanel extends StatelessWidget {
  const _WorkOpportunityPanel({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final work = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );

    return _DetailBlock(
      title: context.l10n.cityDetailWorkLabel,
      children: [
        _InlineMetricRow(
          icon: Icons.work_outline_rounded,
          label: context.l10n.cityDetailWorkLabel,
          headline: work.headline,
          supporting: work.supporting,
          tint: work.tint,
        ),
        const SizedBox(height: 12),
        _InlineMetricRow(
          icon: Icons.query_stats_rounded,
          label: context.l10n.cityDetailUnemploymentLabel,
          headline: _unemploymentHeadline(context, city.unemploymentRate),
          supporting: '${city.unemploymentRate.toStringAsFixed(1)}%',
          tint: _unemploymentTint(city.unemploymentRate),
        ),
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

class _SettleInPanel extends StatelessWidget {
  const _SettleInPanel({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final language = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.language,
      value: city.movaroScores.languageAdaptation,
    );

    return _DetailBlock(
      title: context.l10n.cityDetailSettleInTitle,
      children: [
        _InlineMetricRow(
          icon: Icons.translate_rounded,
          label: context.l10n.cityDetailLanguageLabel,
          headline: language.headline,
          supporting: language.supporting,
          tint: language.tint,
        ),
        const SizedBox(height: 12),
        _InlineMetricRow(
          icon: Icons.groups_2_outlined,
          label: context.l10n.cityDetailCommunityTitle,
          headline: _popularityHeadline(context, city.argentinaPopularityScore),
          supporting: _popularitySupporting(
            context,
            city.argentinaPopularityScore,
          ),
          tint: _popularityTint(city.argentinaPopularityScore),
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
        ),
      ],
    );
  }
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

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryFor(context),
        ),
      ),
    );
  }
}

class _ScrollHintOverlay extends StatelessWidget {
  const _ScrollHintOverlay({
    required this.visible,
    required this.label,
    required this.onTap,
  });

  final bool visible;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: visible ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.isDark(context)
                      ? const Color(0xE6152232)
                      : const Color(0xF9FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineMetricRow extends StatelessWidget {
  const _InlineMetricRow({
    required this.icon,
    required this.label,
    required this.headline,
    required this.supporting,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String headline;
  final String supporting;
  final Color tint;

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
                const SizedBox(height: 4),
                Text(
                  supporting,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.35,
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

String _popularityHeadline(BuildContext context, int score) {
  if (score >= 80) {
    return context.l10n.citySnapshotPopularityHigh;
  }
  if (score >= 60) {
    return context.l10n.citySnapshotPopularityMedium;
  }
  return context.l10n.citySnapshotPopularityLow;
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

Color _popularityTint(int score) {
  if (score >= 80) {
    return AppColors.success;
  }
  if (score >= 60) {
    return AppColors.warning;
  }
  return AppColors.caution;
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
                    label: context.l10n.cityDetailPopulationLabel,
                    value: NumberFormatters.compactPopulation(
                      value: city.population,
                      locale: localeName,
                    ),
                    footer: _snapshotFooter(
                      context,
                      _SnapshotAlertTone.context,
                    ),
                    tint: AppColors.primary,
                    background: AppColors.surfaceMutedFor(context),
                    icon: Icons.groups_rounded,
                  ),
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
                    label: context.l10n.cityDetailRentLabel,
                    value: _rentHeadline(context, city.rentScore),
                    footer: _snapshotFooter(
                      context,
                      city.rentScore >= 67
                          ? _SnapshotAlertTone.positive
                          : city.rentScore < 55
                          ? _SnapshotAlertTone.watchout
                          : _SnapshotAlertTone.context,
                    ),
                    tint: _rentTint(city.rentScore),
                    background: _rentBackground(context, city.rentScore),
                    icon: Icons.house_rounded,
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
                    label: context.l10n.cityDetailPopularityLabel,
                    value: _popularityHeadline(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    footer: _snapshotFooter(
                      context,
                      _toneForScore(city.argentinaPopularityScore),
                    ),
                    tint: _popularityTint(city.argentinaPopularityScore),
                    background: _popularityBackground(
                      context,
                      city.argentinaPopularityScore,
                    ),
                    icon: Icons.favorite_border_rounded,
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
                  CitySnapshotTile(
                    label: context.l10n.cityDetailUnemploymentLabel,
                    value: _unemploymentHeadline(
                      context,
                      city.unemploymentRate,
                    ),
                    footer: _snapshotFooter(
                      context,
                      city.unemploymentRate <= 6
                          ? _SnapshotAlertTone.positive
                          : city.unemploymentRate >= 9
                          ? _SnapshotAlertTone.watchout
                          : _SnapshotAlertTone.context,
                    ),
                    tint: _unemploymentTint(city.unemploymentRate),
                    background: _unemploymentBackground(
                      context,
                      city.unemploymentRate,
                    ),
                    icon: Icons.query_stats_rounded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _rentHeadline(BuildContext context, int score) {
    if (score >= 72) {
      return context.l10n.citySnapshotRentLower;
    }
    if (score >= 55) {
      return context.l10n.citySnapshotRentModerate;
    }
    return context.l10n.citySnapshotRentHigher;
  }

  Color _rentTint(int score) {
    if (score >= 72) {
      return AppColors.success;
    }
    if (score >= 55) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  Color _rentBackground(BuildContext context, int score) {
    if (score >= 72) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (score >= 55) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.danger,
      lightColor: const Color(0xFFFDEEE8),
    );
  }

  String _popularityHeadline(BuildContext context, int score) {
    if (score >= 80) {
      return context.l10n.citySnapshotPopularityHigh;
    }
    if (score >= 60) {
      return context.l10n.citySnapshotPopularityMedium;
    }
    return context.l10n.citySnapshotPopularityLow;
  }

  Color _popularityTint(int score) {
    if (score >= 80) {
      return AppColors.success;
    }
    if (score >= 60) {
      return AppColors.warning;
    }
    return AppColors.caution;
  }

  Color _popularityBackground(BuildContext context, int score) {
    if (score >= 80) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (score >= 60) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.caution,
      lightColor: const Color(0xFFFFF1E8),
    );
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

  Color _unemploymentBackground(BuildContext context, double value) {
    if (value <= 5.5) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.success,
        lightColor: const Color(0xFFF1F8F3),
      );
    }
    if (value <= 7.0) {
      return AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.warning,
        lightColor: const Color(0xFFFFF8E7),
      );
    }
    return AppColors.tintedSurfaceFor(
      context,
      tint: AppColors.danger,
      lightColor: const Color(0xFFFDEEE8),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/location/location_controller.dart';
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
import 'package:movaro_app/core/utils/share_card_service.dart';
import 'package:movaro_app/core/widgets/practical_info_disclaimer.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_price_insight_service.dart';
import 'package:movaro_app/features/cities/application/services/city_affordability_check.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/application/services/city_strength_story_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_map_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_public_opinion_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_seasonality_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_share_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_sources_section.dart';
import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';

enum _SameCityPlanChoice { continuePlan, restartPlan }

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
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  City? _city;
  List<CityInsightEntity> _cityInsights = const [];
  List<CityInsightExplorePlaceEntity> _neighborhoodPlaces = const [];
  final ScrollController _scrollController = ScrollController();
  final ExpansibleController _analysisTileController = ExpansibleController();
  final GlobalKey<_SecondaryContentSectionState> _secondaryContentKey =
      GlobalKey<_SecondaryContentSectionState>();
  final _snapshotSectionKey = GlobalKey();
  final _summarySectionKey = GlobalKey();
  final _advantagesSectionKey = GlobalKey();
  final _workSectionKey = GlobalKey();
  final _dailyLifeSectionKey = GlobalKey();
  final _climateSectionKey = GlobalKey();
  final _neighborhoodSectionKey = GlobalKey();
  final _mobilitySectionKey = GlobalKey();
  final _compareSectionKey = GlobalKey();
  final _mapSectionKey = GlobalKey();
  final _costSectionKey = GlobalKey();
  final _seasonalitySectionKey = GlobalKey();
  final _opinionSectionKey = GlobalKey();
  final _analysisSectionKey = GlobalKey();
  final _sourcesSectionKey = GlobalKey();
  bool _isCreatingPlan = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    await widget.citiesController.loadWeatherForCity(city.id);
  }

  Future<void> _loadCityInsightContext(City city) async {
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final loadInsights = widget.cityInsightsController.load(
        cityId: city.id,
        locale: locale,
      );
      final loadSocialProof = widget.citiesController.loadCityDetailSocialProof(
        city.id,
        locale: locale,
      );
      final loadClimate = widget.citiesController.loadCityDetailClimateSummary(
        city.id,
        locale: locale,
      );
      final loadArrival = widget.citiesController.loadCityDetailArrivalStory(
        city.id,
        locale: locale,
      );

      await loadInsights;
      final placesFuture = widget.cityInsightsController.getExplorePlaces(
        cityId: city.id,
        theme: CityInsightTheme.neighborhoods,
        locale: locale,
      );
      final places = await placesFuture;
      await Future.wait([loadSocialProof, loadClimate, loadArrival]);
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

  Future<void> _openCityMapSheet(City city) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _CityMapBottomSheet(city: city, detectedLocation: null),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final city = _city;
        final l10n = context.l10n;
        final localeName = Localizations.localeOf(context).toString();
        final locale = Localizations.localeOf(context).languageCode;
        final budget = city?.budgetSnapshot;
        final strengths = city == null
            ? const <CityStrengthSignal>[]
            : CityStrengthStoryService.strongest(context, city);
        final detailContextKey = city == null
            ? null
            : widget.citiesController.cityDetailContextKey(
                city.id,
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
        final quickActions = city == null
            ? const <_DetailQuickAction>[]
            : _buildQuickActions(context, budget: budget);

        return Scaffold(
          bottomNavigationBar: city == null
              ? null
              : widget.fromMigrationResult
              ? _MigrationResultBar(
                  city: city,
                  controller: widget.migrationQuestionnaireController,
                )
              : widget.validationFlow
              ? _ValidationCityActionBar(
                  cityName: city.name,
                  isLoading: _isCreatingPlan,
                  onConfirm: () => _runPrimaryPlanAction(context, city),
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
                    Expanded(
                      child: NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(
                            pinned: true,
                            centerTitle: true,
                            toolbarHeight: 68,
                            expandedHeight: _DetailHeroSection.heightFor(
                              context,
                            ),
                            backgroundColor: const Color(0xFF0A1628),
                            surfaceTintColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            systemOverlayStyle: SystemUiOverlayStyle.light,
                            title: Text(
                              l10n.cityDetailHeaderTitle(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x66000000),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                            ),
                            leadingWidth: 76,
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _HeroNavIconButton(
                                icon: Icons.arrow_back_rounded,
                                tooltip: MaterialLocalizations.of(
                                  context,
                                ).backButtonTooltip,
                                onTap: _goBackToCities,
                              ),
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _HeroNavIconButton(
                                  icon: Icons.help_outline_rounded,
                                  tooltip: _cityDetailLocalizedText(
                                    context,
                                    pt: 'Ajuda',
                                    es: 'Ayuda',
                                    en: 'Help',
                                  ),
                                  onTap: _showHelp,
                                ),
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background: _DetailHeroSection(
                                city: city,
                                scrollController: _scrollController,
                                citiesController: widget.citiesController,
                                onToggleFavorite: () =>
                                    _toggleFavoriteCity(context, city),
                                onShare: () =>
                                    unawaited(_shareCityCard(context, city)),
                              ),
                            ),
                          ),
                          if (quickActions.isNotEmpty)
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _PinnedSectionNavDelegate(
                                actions: quickActions,
                                horizontalPadding:
                                    context.pageHorizontalPadding,
                              ),
                            ),
                        ],
                        body: ListView(
                          padding: EdgeInsets.fromLTRB(
                            context.pageHorizontalPadding,
                            16,
                            context.pageHorizontalPadding,
                            context.pageVerticalPadding + 96,
                          ),
                          children: [
                            // The city detail is deliberately profile-neutral.
                            // Recommendation, fit and migration-plan context
                            // belong to the suggested-cities and plan screens.
                            ConstrainedBox(
                              key: _snapshotSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _CityOverviewPanel(
                                city: city,
                                strengths: strengths,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ConstrainedBox(
                              key: _summarySectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _QuickSummaryCard(city: city),
                            ),
                            const SizedBox(height: 12),

                            ConstrainedBox(
                              key: _advantagesSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _CityStrengthsAndChallengesCard(
                                city: city,
                                strengths: strengths,
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (budget case final budget?) ...[
                              ConstrainedBox(
                                key: _costSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: CityCostOfLivingCard(
                                  budget: budget,
                                  preferredCountryId: null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: _AffordabilityNote(city: city),
                              ),
                              const SizedBox(height: 12),
                            ],

                            ConstrainedBox(
                              key: _workSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _WorkAndEconomyCard(city: city),
                            ),
                            const SizedBox(height: 12),

                            ConstrainedBox(
                              key: _dailyLifeSectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _DailyLifeCard(
                                city: city,
                                insights: _cityInsights,
                                arrivalStory: arrivalStory,
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
                                      planTimeline: null,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            ConstrainedBox(
                              key: _mobilitySectionKey,
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _MobilityAndConnectionsCard(
                                city: city,
                                insights: _cityInsights,
                                budget: budget,
                                onOpenMap: () => _openCityMapSheet(city),
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (widget.migrationQuestionnaireController !=
                                null) ...[
                              ConstrainedBox(
                                key: _compareSectionKey,
                                constraints: const BoxConstraints(
                                  maxWidth: 1160,
                                ),
                                child: _InlineComparisonCard(
                                  city: city,
                                  onCompare: () =>
                                      _handleCompareCity(context, city),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: _MoreAboutCityCard(
                                cityName: city.name,
                                onExploreMore: () => _navigateToSection(
                                  _secondaryContentKey,
                                  expandSecondary: true,
                                ),
                                onJumpToAnalysis: _openAnalysisSection,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _SecondaryContentSection(
                              key: _secondaryContentKey,
                              cityName: city.name,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1160,
                                  ),
                                  child: _ArrivalViabilityCard(
                                    city: city,
                                    budget: budget,
                                    preferredCountryId: null,
                                    routeInsight: null,
                                    insights: _cityInsights,
                                    arrivalStory: arrivalStory,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ConstrainedBox(
                                  key: _mapSectionKey,
                                  constraints: const BoxConstraints(
                                    maxWidth: 1160,
                                  ),
                                  child: _CityLocationPanel(
                                    city: city,
                                    detectedLocation: null,
                                    isActivePlanCity: false,
                                    onOpenMap: () => _openCityMapSheet(city),
                                  ),
                                ),
                                const SizedBox(height: 12),

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
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              l10n.cityDetailDeepDiveTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _OverallScoreChip(
                                            score: city.movaroScores.overall,
                                          ),
                                        ],
                                      ),
                                      children: [
                                        _CityAnalysisContent(
                                          city: city,
                                          budget: budget,
                                          localeName: localeName,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                    ),
                  ],
                ),

              // ── Floating glass nav bar (always on top) ─────────────────────
              if (city == null)
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
    final isConfirmedCity = plan?.confirmedCity?.id == city.id;
    if (isConfirmedCity) {
      final choice = await _showSameCityPlanDialog(city: city, plan: plan!);
      if (!context.mounted || choice == null) {
        return;
      }
      if (choice == _SameCityPlanChoice.continuePlan) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.publicHome,
          (route) => false,
        );
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

    final savedPlan = widget.migrationQuestionnaireController
        ?.findSavedPlanForCity(city.id);
    if (savedPlan != null) {
      final choice = await _showSameCityPlanDialog(city: city, plan: savedPlan);
      if (!context.mounted || choice == null) {
        return;
      }
      if (choice == _SameCityPlanChoice.continuePlan) {
        await widget.migrationQuestionnaireController?.resumePlan(savedPlan);
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

    if (plan != null) {
      final isSamePlanCity = plan.currentPlanCity?.id == city.id;
      if (!isSamePlanCity) {
        final choice = await showPlanResetDialog(
          context,
          currentCityName: plan.currentPlanCity?.name,
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

  Future<void> _runPrimaryPlanAction(BuildContext context, City city) async {
    if (_isCreatingPlan) {
      return;
    }

    setState(() => _isCreatingPlan = true);
    final hadPlan =
        widget.migrationQuestionnaireController?.generatedPlan != null;
    try {
      await _handlePrimaryPlanAction(context, city);
      if (context.mounted &&
          widget.validationFlow &&
          !hadPlan &&
          widget.migrationQuestionnaireController?.generatedPlan == null) {
        final locale = Localizations.localeOf(context).languageCode;
        final message = switch (locale) {
          'pt' =>
            'Confirme seu país de origem para criar um plano para ${city.name}.',
          'es' =>
            'Confirmá tu país de origen para crear un plan para ${city.name}.',
          _ => 'Confirm your origin country to create a plan for ${city.name}.',
        };
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      final locale = Localizations.localeOf(context).languageCode;
      final message = switch (locale) {
        'pt' =>
          'Não conseguimos criar o plano agora. Confira a conexão e tente novamente.',
        'es' =>
          'No pudimos crear el plan ahora. Revisá la conexión e intentá de nuevo.',
        _ =>
          'We could not create the plan right now. Check your connection and try again.',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isCreatingPlan = false);
      }
    }
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final ctx = key.currentContext;
    if (ctx == null) return;

    final target = ctx.findRenderObject();
    if (target is! RenderBox || !target.hasSize) return;

    // Find the ListView's RenderObject so we can calculate relative offset.
    final listRO = _scrollController.position.context.storageContext
        .findRenderObject();
    if (listRO is! RenderBox) return;

    // y-offset of the target's top edge relative to the viewport's top.
    final relativeOffset = target.localToGlobal(Offset.zero, ancestor: listRO);
    final newOffset = (_scrollController.offset + relativeOffset.dy).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _waitForKeyContext(GlobalKey key) async {
    // expandAndWait already waited for the expand animation. We just need the
    // element to exist in the tree (AnimatedCrossFade keeps both children in
    // tree, so this typically resolves on the first attempt).
    for (var attempt = 0; attempt < 10; attempt++) {
      if (!mounted) return;
      if (key.currentContext != null) return;
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<_SameCityPlanChoice?> _showSameCityPlanDialog({
    required City city,
    required MigrationPlan plan,
  }) async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final currentLocation = widget.locationController.savedLocation;
    final snapshot = await _progressStore.read(plan);
    if (!mounted) {
      return null;
    }
    final guideItems = MigrationGuideRegistry.build(
      l10n: l10n,
      plan: plan,
      currentLocation: currentLocation,
      localeCode: locale,
      completedIds: snapshot.getAllCompletedIds(),
    );
    final completedCount = snapshot.completedItemsCount;
    final totalCount = guideItems.length;
    final isComplete = totalCount > 0 && completedCount >= totalCount;
    final title = switch (locale) {
      'pt' =>
        isComplete
            ? 'Já existe um plano concluído para ${city.name}'
            : 'Já existe um plano em andamento para ${city.name}',
      'es' =>
        isComplete
            ? 'Ya existe un plan completado para ${city.name}'
            : 'Ya existe un plan en curso para ${city.name}',
      _ =>
        isComplete
            ? 'There is already a completed plan for ${city.name}'
            : 'There is already an active plan for ${city.name}',
    };
    final body = switch (locale) {
      'pt' =>
        isComplete
            ? 'Detectamos que esta cidade já tem um plano finalizado. Você pode revisar o que já foi feito ou começar tudo de novo do zero.'
            : 'Detectamos que esta cidade já tem um plano com progresso salvo. Você pode continuar de onde parou ou recomeçar do zero.',
      'es' =>
        isComplete
            ? 'Detectamos que esta ciudad ya tiene un plan finalizado. Puedes revisar lo que ya hiciste o empezar otra vez desde cero.'
            : 'Detectamos que esta ciudad ya tiene un plan con progreso guardado. Puedes seguir donde lo dejaste o empezar desde cero.',
      _ =>
        isComplete
            ? 'We found a finished plan for this city. You can review what is already done or start over from zero.'
            : 'We found saved progress for this city. You can continue where you left off or start over from zero.',
    };
    final progressLabel = switch (locale) {
      'pt' =>
        isComplete
            ? 'Plano concluído'
            : '$completedCount de $totalCount etapas concluídas',
      'es' =>
        isComplete
            ? 'Plan completado'
            : '$completedCount de $totalCount etapas completadas',
      _ =>
        isComplete
            ? 'Plan completed'
            : '$completedCount of $totalCount steps completed',
    };

    return showDialog<_SameCityPlanChoice>(
      context: context,
      builder: (dialogContext) {
        final isDark = AppColors.isDark(dialogContext);
        final borderColor = AppColors.borderFor(dialogContext);
        final titleColor = AppColors.textPrimaryFor(dialogContext);
        final bodyColor = AppColors.textSoftFor(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(dialogContext),
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.48)
                      : Colors.black.withValues(alpha: 0.10),
                  blurRadius: isDark ? 48 : 26,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.tintedSurfaceFor(
                            dialogContext,
                            tint: AppColors.primary,
                            lightColor: const Color(0xFFEEF4FF),
                            darkAlpha: 0.16,
                          ),
                          border: Border.all(
                            color: AppColors.tintedBorderFor(
                              dialogContext,
                              tint: AppColors.primary,
                              lightColor: const Color(0xFFB9D2FF),
                              darkAlpha: 0.30,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: Theme.of(dialogContext).textTheme.titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: Theme.of(dialogContext).textTheme.bodyLarge
                            ?.copyWith(color: bodyColor, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedFor(dialogContext),
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                progressLabel,
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: borderColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(
                          dialogContext,
                        ).pop(_SameCityPlanChoice.continuePlan),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F6FEB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            switch (locale) {
                              'pt' => 'Continuar esse plano',
                              'es' => 'Continuar este plan',
                              _ => 'Continue this plan',
                            },
                            textAlign: TextAlign.center,
                            style: Theme.of(dialogContext).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.of(
                          dialogContext,
                        ).pop(_SameCityPlanChoice.restartPlan),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMutedFor(dialogContext),
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            switch (locale) {
                              'pt' => 'Começar do zero nessa cidade',
                              'es' => 'Empezar desde cero en esta ciudad',
                              _ => 'Start over in this city',
                            },
                            textAlign: TextAlign.center,
                            style: Theme.of(dialogContext).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: bodyColor,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            switch (locale) {
                              'pt' => 'Cancelar',
                              'es' => 'Cancelar',
                              _ => 'Cancel',
                            },
                            style: Theme.of(
                              dialogContext,
                            ).textTheme.bodyMedium?.copyWith(color: bodyColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    required CityBudgetSnapshot? budget,
  }) {
    return <_DetailQuickAction>[
      _DetailQuickAction(
        icon: Icons.location_city_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Resumo',
          es: 'Resumen',
          en: 'Summary',
        ),
        onTap: () => _scrollToKey(_snapshotSectionKey),
        priority: 0,
      ),
      _DetailQuickAction(
        icon: Icons.payments_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Custo e moradia',
          es: 'Costo y vivienda',
          en: 'Cost & housing',
        ),
        onTap: () =>
            _scrollToKey(budget == null ? _workSectionKey : _costSectionKey),
        priority: 1,
      ),
      _DetailQuickAction(
        icon: Icons.work_outline_rounded,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Trabalho',
          es: 'Trabajo',
          en: 'Work',
        ),
        onTap: () => _scrollToKey(_workSectionKey),
        priority: 2,
      ),
      _DetailQuickAction(
        icon: Icons.directions_bus_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Vida cotidiana',
          es: 'Vida cotidiana',
          en: 'Daily life',
        ),
        onTap: () => _scrollToKey(_dailyLifeSectionKey),
        priority: 3,
      ),
      _DetailQuickAction(
        icon: Icons.holiday_village_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Bairros',
          es: 'Barrios',
          en: 'Areas',
        ),
        onTap: () => _scrollToKey(_neighborhoodSectionKey),
        priority: 4,
      ),
      _DetailQuickAction(
        icon: Icons.wb_sunny_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Clima',
          es: 'Clima',
          en: 'Climate',
        ),
        onTap: () => _scrollToKey(_climateSectionKey),
        priority: 5,
      ),
      _DetailQuickAction(
        icon: Icons.fact_check_outlined,
        label: _cityDetailLocalizedText(
          context,
          pt: 'Dados e fontes',
          es: 'Datos y fuentes',
          en: 'Data & sources',
        ),
        onTap: () =>
            _navigateToSection(_secondaryContentKey, expandSecondary: true),
        priority: 6,
      ),
    ];
  }

  Future<void> _shareCityCard(BuildContext context, City city) async {
    final l10n = context.l10n;
    final affordability = CityAffordabilityCheck.forLocalSalary(city);

    String? verdictLine;
    Color? verdictColor;
    if (affordability != null) {
      final amount = _formatMoney(context, affordability.gap.abs());
      final income = _formatMoney(context, affordability.monthlyIncome);
      (verdictColor, verdictLine) = switch (affordability.verdict) {
        AffordabilityVerdict.comfortable => (
          AppColors.success,
          _cityDetailLocalizedText(
            context,
            pt: 'Salário médio: $income · acima do custo típico (~$amount/mês). Referência.',
            es: 'Sueldo promedio: $income · por encima del costo típico (~$amount/mes). Referencia.',
            en: 'Average salary: $income · above typical cost (~$amount/mo). Reference.',
          ),
        ),
        AffordabilityVerdict.tight => (
          AppColors.warning,
          _cityDetailLocalizedText(
            context,
            pt: 'Salário médio: $income · perto do custo típico (~$amount/mês). Referência.',
            es: 'Sueldo promedio: $income · cerca del costo típico (~$amount/mes). Referencia.',
            en: 'Average salary: $income · near typical cost (~$amount/mo). Reference.',
          ),
        ),
        AffordabilityVerdict.insufficient => (
          AppColors.danger,
          _cityDetailLocalizedText(
            context,
            pt: 'Salário médio: $income · abaixo do custo típico (~$amount/mês). Referência.',
            es: 'Sueldo promedio: $income · por debajo del costo típico (~$amount/mes). Referencia.',
            en: 'Average salary: $income · below typical cost (~$amount/mo). Reference.',
          ),
        ),
      };
    }

    final region = city.regionName;
    final subtitle = (region == null || region.isEmpty)
        ? city.stateName
        : '${city.stateName} · $region';

    final card = CityShareCard(
      cityName: city.name,
      subtitle: subtitle,
      verdictLine: verdictLine,
      verdictColor: verdictColor,
      areasTitle: _cityDetailLocalizedText(
        context,
        pt: 'Áreas que empregam',
        es: 'Áreas que emplean',
        en: 'Industries hiring',
      ),
      areas: city.topIndustries.take(3).map(l10n.workAreaLabel).toList(),
      footer: _cityDetailLocalizedText(
        context,
        pt: 'Custo, trabalho e trâmites para morar no Brasil — app Movaro.',
        es: 'Costo, trabajo y trámites para vivir en Brasil — app Movaro.',
        en: 'Cost, work, and paperwork to live in Brazil — Movaro app.',
      ),
    );

    final caption = _cityDetailLocalizedText(
      context,
      pt: 'Pensando em morar em ${city.name}/${city.stateCode}? Veja custo e trabalho no Movaro.',
      es: '¿Pensás vivir en ${city.name}/${city.stateCode}? Mirá costo y trabajo en Movaro.',
      en: 'Thinking of moving to ${city.name}/${city.stateCode}? See cost and work on Movaro.',
    );

    await ShareCardService.shareWidget(
      context: context,
      card: card,
      logicalSize: const Size(340, 440),
      caption: caption,
      fileName: 'movaro_${city.id}.png',
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 480));
  }

  static String _expandLabel(BuildContext context, String cityName) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ver detalhes completos de $cityName',
      'es' => 'Ver detalles completos de $cityName',
      _ => 'See full details for $cityName',
    };
  }

  static String _collapseLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ocultar detalhes completos',
      'es' => 'Ocultar detalles completos',
      _ => 'Hide full details',
    };
  }

  static String _description(BuildContext context, String cityName) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' =>
        'Sazonalidade, mapa, opinião pública, indicadores, metodologia e fontes para conhecer $cityName com mais profundidade.',
      'es' =>
        'Estacionalidad, mapa, opinión pública, indicadores, metodología y fuentes para conocer $cityName con más profundidad.',
      _ =>
        'Seasonality, map, public opinion, indicators, methodology, and sources for a deeper view of $cityName.',
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _expanded
                            ? _collapseLabel(context)
                            : _expandLabel(context, widget.cityName),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimaryFor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _description(context, widget.cityName),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
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

class _MoreAboutCityCard extends StatelessWidget {
  const _MoreAboutCityCard({
    required this.cityName,
    required this.onExploreMore,
    required this.onJumpToAnalysis,
  });

  final String cityName;
  final VoidCallback onExploreMore;
  final VoidCallback onJumpToAnalysis;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title(context),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _body(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onExploreMore,
                icon: const Icon(Icons.explore_outlined),
                label: Text(_primaryAction(context)),
              ),
              OutlinedButton.icon(
                onPressed: onJumpToAnalysis,
                icon: const Icon(Icons.analytics_outlined),
                label: Text(_secondaryAction(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Quer conhecer $cityName em profundidade?',
      'es' => '¿Quieres conocer $cityName en profundidad?',
      _ => 'Want a deeper view of $cityName?',
    };
  }

  String _body(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' =>
        'A camada principal fica curta. Aqui você abre sazonalidade, mapa, opinião pública, indicadores detalhados e todas as fontes.',
      'es' =>
        'La capa principal se mantiene breve. Aquí puedes abrir estacionalidad, mapa, opinión pública, indicadores detallados y todas las fuentes.',
      _ =>
        'The main layer stays concise. Open seasonality, map, public opinion, detailed indicators, and every source here.',
    };
  }

  String _primaryAction(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Abrir detalhes completos',
      'es' => 'Abrir detalles completos',
      _ => 'Open full details',
    };
  }

  String _secondaryAction(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Ir para análise',
      'es' => 'Ir al análisis',
      _ => 'Jump to analysis',
    };
  }
}

// ─── Persistent action for the "I already know my city" flow ─────────────────

class _ValidationCityActionBar extends StatelessWidget {
  const _ValidationCityActionBar({
    required this.cityName,
    required this.isLoading,
    required this.onConfirm,
  });

  final String cityName;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;
    final label = switch (locale) {
      'pt' => 'Criar meu plano para $cityName',
      'es' => 'Crear mi plan para $cityName',
      _ => 'Create my plan for $cityName',
    };

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF07101C).withValues(alpha: 0.97)
              : Colors.white.withValues(alpha: 0.97),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onConfirm,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.route_rounded),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
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
    final matchScore = plan?.candidateCityMatchScores[widget.city.id];

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
                if (matchScore != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _cityMatchBandLabel(context, matchScore),
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

// ── Full-width hero section (matches recommendation screen style) ─────────────

class _DetailHeroSection extends StatelessWidget {
  const _DetailHeroSection({
    required this.city,
    required this.scrollController,
    required this.citiesController,
    required this.onToggleFavorite,
    required this.onShare,
  });

  final City city;
  final ScrollController scrollController;
  final CitiesController citiesController;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

  static double heightFor(BuildContext context) {
    return (MediaQuery.sizeOf(context).height * 0.34).clamp(290.0, 340.0);
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight = heightFor(context);
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
      metaBelowTitle: true,
      showCollapseControl: false,
      maxHeight: heroHeight,
      minHeight: heroHeight,
      topContentInset: 88,
      bottomContentOffset: -10,
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
          _HeroIconButton(icon: Icons.ios_share_rounded, onTap: onShare),
          const SizedBox(width: 8),
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

class _HeroNavIconButton extends StatelessWidget {
  const _HeroNavIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: const Color(0xFF111827)),
          ),
        ),
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

class _QuickSummaryCard extends StatelessWidget {
  const _QuickSummaryCard({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final budget = city.budgetSnapshot;
    final industries = city.topIndustries
        .take(2)
        .map(context.l10n.workAreaLabel)
        .join(' · ');
    final cards = [
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'População',
          es: 'Población',
          en: 'Population',
        ),
        value: NumberFormat.compact(
          locale: Localizations.localeOf(context).toString(),
        ).format(city.population),
        color: AppColors.primary,
        icon: Icons.groups_outlined,
      ),
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'Custo mensal estimado',
          es: 'Costo mensual estimado',
          en: 'Estimated monthly cost',
        ),
        value: budget == null
            ? _cityDetailLocalizedText(
                context,
                pt: 'Sem referência',
                es: 'Sin referencia',
                en: 'No reference',
              )
            : '${_formatMoney(context, budget.fairLivingTotal)}–${_formatMoney(context, budget.wellLivingTotal)}',
        color: AppColors.warning,
        icon: Icons.payments_outlined,
      ),
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'Aluguel de referência',
          es: 'Alquiler de referencia',
          en: 'Reference rent',
        ),
        value: budget == null
            ? _cityDetailLocalizedText(
                context,
                pt: 'Sem referência',
                es: 'Sin referencia',
                en: 'No reference',
              )
            : '${_formatMoney(context, budget.planningRentLow)}–${_formatMoney(context, budget.planningRentHigh)}',
        color: AppColors.success,
        icon: Icons.home_work_outlined,
      ),
      _SummaryIndicator(
        label: _cityDetailLocalizedText(
          context,
          pt: 'Base econômica',
          es: 'Base económica',
          en: 'Economic base',
        ),
        value: industries.isEmpty
            ? _cityDetailLocalizedText(
                context,
                pt: 'Dados limitados',
                es: 'Datos limitados',
                en: 'Limited data',
              )
            : industries,
        color: AppColors.primary,
        icon: Icons.business_center_outlined,
      ),
    ];

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Números principais',
              es: 'Números principales',
              en: 'Key figures',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820 ? 4 : 2;
              final itemWidth =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final card in cards)
                    SizedBox(width: itemWidth, child: card),
                ],
              );
            },
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

class _CityStrengthsAndChallengesCard extends StatelessWidget {
  const _CityStrengthsAndChallengesCard({
    required this.city,
    required this.strengths,
  });

  final City city;
  final List<CityStrengthSignal> strengths;

  @override
  Widget build(BuildContext context) {
    final strengthItems = strengths.isNotEmpty
        ? strengths.take(4).map((item) => item.title).toList(growable: false)
        : <String>[
            CityMetricPresentation.resolve(
              context,
              kind: CityMetricKind.safety,
              value: city.safetyScore,
            ).headline,
            if (city.topIndustries.isNotEmpty)
              _cityDetailLocalizedText(
                context,
                pt: 'Economia apoiada em ${city.topIndustries.take(2).map(context.l10n.workAreaLabel).join(' e ')}',
                es: 'Economía apoyada en ${city.topIndustries.take(2).map(context.l10n.workAreaLabel).join(' y ')}',
                en: 'Economy supported by ${city.topIndustries.take(2).map(context.l10n.workAreaLabel).join(' and ')}',
              ),
          ];
    final challenges = <String>[
      if (city.budgetSnapshot != null)
        _cityDetailLocalizedText(
          context,
          pt: 'Moradia representa uma parte relevante do custo mensal e muda entre regiões.',
          es: 'La vivienda representa una parte relevante del costo mensual y cambia entre zonas.',
          en: 'Housing is a meaningful part of monthly cost and varies by area.',
        ),
      if (city.seasonalitySnapshot case final seasonality?)
        seasonality.rentNotes(Localizations.localeOf(context).languageCode),
      if (CityCoastalProfile.lifestyleKind(city) == CityLifestyleKind.coastal)
        _cityDetailLocalizedText(
          context,
          pt: 'Turismo, distâncias entre regiões e trânsito podem alterar a rotina.',
          es: 'El turismo, las distancias entre zonas y el tránsito pueden alterar la rutina.',
          en: 'Tourism, distance between areas, and traffic can reshape daily routines.',
        ),
      _cityDetailLocalizedText(
        context,
        pt: 'Os indicadores municipais não descrevem igualmente todos os bairros.',
        es: 'Los indicadores municipales no describen por igual todos los barrios.',
        en: 'Citywide indicators do not describe every area equally.',
      ),
    ];

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Principais vantagens e desafios',
              es: 'Principales ventajas y desafíos',
              en: 'Main strengths and challenges',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Uma leitura equilibrada dos trade-offs da cidade, sem classificar se ela é boa ou ruim para uma pessoa.',
              es: 'Una lectura equilibrada de los trade-offs de la ciudad, sin clasificar si es buena o mala para una persona.',
              en: 'A balanced read of city trade-offs, without labeling it good or bad for any one person.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final panels = [
                _EditorialListPanel(
                  title: _cityDetailLocalizedText(
                    context,
                    pt: 'Pontos fortes',
                    es: 'Puntos fuertes',
                    en: 'Strengths',
                  ),
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.success,
                  items: strengthItems,
                ),
                _EditorialListPanel(
                  title: _cityDetailLocalizedText(
                    context,
                    pt: 'Pontos de atenção',
                    es: 'Puntos de atención',
                    en: 'Watch-outs',
                  ),
                  icon: Icons.error_outline_rounded,
                  color: AppColors.warning,
                  items: challenges.take(4).toList(growable: false),
                ),
              ];
              if (constraints.maxWidth < 680) {
                return Column(
                  children: [
                    panels.first,
                    const SizedBox(height: 10),
                    panels.last,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: panels.first),
                  const SizedBox(width: 10),
                  Expanded(child: panels.last),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EditorialListPanel extends StatelessWidget {
  const _EditorialListPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < items.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[index],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
            if (index != items.length - 1) const SizedBox(height: 7),
          ],
        ],
      ),
    );
  }
}

class _WorkAndEconomyCard extends StatelessWidget {
  const _WorkAndEconomyCard({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final budget = city.budgetSnapshot;
    final source = city.sources.employment;
    final presentation = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Trabalho e economia',
              es: 'Trabajo y economía',
              en: 'Work and economy',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'O mercado é apresentado por setores, salário, desemprego e sazonalidade — não apenas por um score.',
              es: 'El mercado se presenta por sectores, salario, desempleo y estacionalidad, no solo por un puntaje.',
              en: 'The market is described through industries, salary, unemployment, and seasonality—not just a score.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _DetailFactRow(
            icon: Icons.business_center_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Leitura do mercado',
              es: 'Lectura del mercado',
              en: 'Market read',
            ),
            value: presentation.headline,
            supporting: presentation.supporting,
          ),
          _DetailFactRow(
            icon: Icons.payments_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Salário líquido médio de referência',
              es: 'Salario neto medio de referencia',
              en: 'Reference average net salary',
            ),
            value: budget == null
                ? _cityDetailLocalizedText(
                    context,
                    pt: 'Sem dado verificado',
                    es: 'Sin dato verificado',
                    en: 'No verified data',
                  )
                : _formatMoney(context, budget.averageMonthlyNetSalary),
          ),
          _DetailFactRow(
            icon: Icons.trending_down_rounded,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Desemprego de referência',
              es: 'Desempleo de referencia',
              en: 'Reference unemployment',
            ),
            value: '${city.unemploymentRate.toStringAsFixed(1)}%',
            supporting: source?.referencePeriod,
          ),
          if (city.topIndustries.isNotEmpty) ...[
            const SizedBox(height: 4),
            _AreaLabel(
              title: _cityDetailLocalizedText(
                context,
                pt: 'Setores predominantes',
                es: 'Sectores predominantes',
                en: 'Main industries',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: city.topIndustries
                  .map(
                    (industry) => _InsightPill(
                      icon: Icons.apartment_rounded,
                      label: context.l10n.workAreaLabel(industry),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (city.seasonalitySnapshot case final seasonality?) ...[
            const SizedBox(height: 14),
            _CoverageNotice(
              icon: Icons.calendar_month_outlined,
              text: seasonality.jobNotes(
                Localizations.localeOf(context).languageCode,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            source == null
                ? _cityDetailLocalizedText(
                    context,
                    pt: 'Ainda não há fonte oficial de emprego vinculada. Áreas empresariais e formalização não são exibidas para evitar falsa precisão.',
                    es: 'Todavía no hay una fuente oficial de empleo vinculada. Las áreas empresariales y la formalización no se muestran para evitar falsa precisión.',
                    en: 'No official employment source is linked yet. Business districts and formalization are omitted to avoid false precision.',
                  )
                : '${source.provider} · ${source.referencePeriod ?? source.updatedAt ?? city.updatedAt}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyLifeCard extends StatelessWidget {
  const _DailyLifeCard({
    required this.city,
    required this.insights,
    required this.arrivalStory,
  });

  final City city;
  final List<CityInsightEntity> insights;
  final CityDetailArrivalStory? arrivalStory;

  @override
  Widget build(BuildContext context) {
    final narrative = _cityNarrative(context, city, insights, arrivalStory);
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
    final safetySource = city.sources.safety;
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Vida cotidiana',
              es: 'Vida cotidiana',
              en: 'Daily life',
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
          const SizedBox(height: 10),
          _DetailFactRow(
            icon: Icons.shield_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Segurança',
              es: 'Seguridad',
              en: 'Safety',
            ),
            value: safety.headline,
            supporting: safetySource == null
                ? safety.supporting
                : '${safety.supporting} ${safetySource.description} ${safetySource.referencePeriod ?? ''}'
                      .trim(),
          ),
          _DetailFactRow(
            icon: Icons.directions_bus_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Mobilidade e ritmo',
              es: 'Movilidad y ritmo',
              en: 'Mobility and pace',
            ),
            value: narrative.$2,
          ),
          _DetailFactRow(
            icon: Icons.translate_rounded,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Idioma e serviços',
              es: 'Idioma y servicios',
              en: 'Language and services',
            ),
            value: language.headline,
            supporting: language.supporting,
          ),
          _DetailFactRow(
            icon: Icons.insights_outlined,
            label: 'IDHM ${city.idhmReferenceYear}',
            value: city.idhmScore.toStringAsFixed(3),
            supporting: _cityDetailLocalizedText(
              context,
              pt: 'Contexto histórico amplo; não substitui indicadores atuais de saúde, educação ou infraestrutura.',
              es: 'Contexto histórico amplio; no reemplaza indicadores actuales de salud, educación o infraestructura.',
              en: 'Broad historical context; it does not replace current health, education, or infrastructure indicators.',
            ),
          ),
          const SizedBox(height: 8),
          _CoverageNotice(
            icon: Icons.fact_check_outlined,
            text: _cityDetailLocalizedText(
              context,
              pt: 'Saúde, educação e internet ainda não têm indicadores comparáveis e verificados neste conjunto de dados. Eles não são inferidos a partir do IDHM.',
              es: 'Salud, educación e internet todavía no tienen indicadores comparables y verificados en este conjunto de datos. No se infieren a partir del IDHM.',
              en: 'Health, education, and internet do not yet have comparable verified indicators in this dataset. They are not inferred from HDI.',
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilityAndConnectionsCard extends StatelessWidget {
  const _MobilityAndConnectionsCard({
    required this.city,
    required this.insights,
    required this.budget,
    required this.onOpenMap,
  });

  final City city;
  final List<CityInsightEntity> insights;
  final CityBudgetSnapshot? budget;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final airport = AirportDatabase.forCityName(city.name, city.countryCode);
    final airportDistance = airport == null
        ? null
        : const Distance().as(
            LengthUnit.Kilometer,
            LatLng(city.latitude, city.longitude),
            LatLng(airport.latitude, airport.longitude),
          );
    final mobilityInsights = insights.where(
      (item) =>
          item.theme == CityInsightTheme.localRoutine ||
          item.theme == CityInsightTheme.neighborhoods,
    );
    final mobilityText = mobilityInsights.isEmpty
        ? _cityDetailLocalizedText(
            context,
            pt: 'A forma urbana e as distâncias entre regiões devem ser lidas junto do mapa e do transporte local.',
            es: 'La forma urbana y las distancias entre zonas deben leerse junto con el mapa y el transporte local.',
            en: 'Urban form and distances between areas should be read alongside the map and local transport.',
          )
        : _compactInsightCopy(
            mobilityInsights.first.shortText.isNotEmpty
                ? mobilityInsights.first.shortText
                : mobilityInsights.first.content,
            maxSentences: 2,
          );
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Mobilidade e conexões',
              es: 'Movilidad y conexiones',
              en: 'Mobility and connections',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            mobilityText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _DetailFactRow(
            icon: Icons.flight_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Aeroporto da cidade',
              es: 'Aeropuerto de la ciudad',
              en: 'City airport',
            ),
            value: airport == null
                ? _cityDetailLocalizedText(
                    context,
                    pt: 'Sem aeroporto vinculado',
                    es: 'Sin aeropuerto vinculado',
                    en: 'No linked airport',
                  )
                : '${airport.name} (${airport.iataCode})',
            supporting: airportDistance == null
                ? null
                : _cityDetailLocalizedText(
                    context,
                    pt: 'Aproximadamente ${airportDistance.round()} km do ponto central usado no mapa.',
                    es: 'Aproximadamente a ${airportDistance.round()} km del punto central usado en el mapa.',
                    en: 'Approximately ${airportDistance.round()} km from the central point used on the map.',
                  ),
          ),
          _DetailFactRow(
            icon: Icons.directions_bus_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Passe mensal de transporte',
              es: 'Pase mensual de transporte',
              en: 'Monthly transport pass',
            ),
            value: budget == null
                ? _cityDetailLocalizedText(
                    context,
                    pt: 'Sem dado verificado',
                    es: 'Sin dato verificado',
                    en: 'No verified data',
                  )
                : _formatMoney(context, budget!.monthlyTransportPass),
          ),
          const SizedBox(height: 8),
          _CoverageNotice(
            icon: Icons.route_outlined,
            text: _cityDetailLocalizedText(
              context,
              pt: 'A tela mostra conexões próprias da cidade. Voo desde a origem do usuário não entra aqui. Rodoviária e rotas diretas só serão exibidas quando houver fonte estruturada.',
              es: 'La pantalla muestra conexiones propias de la ciudad. El vuelo desde el origen del usuario no aparece aquí. La terminal y las rutas directas solo se mostrarán con una fuente estructurada.',
              en: 'This screen shows city-level connections. Flights from a user’s origin do not belong here. Bus terminals and direct routes are shown only when structured sources exist.',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenMap,
            icon: const Icon(Icons.map_outlined),
            label: Text(
              _cityDetailLocalizedText(
                context,
                pt: 'Abrir mapa da cidade',
                es: 'Abrir mapa de la ciudad',
                en: 'Open city map',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailFactRow extends StatelessWidget {
  const _DetailFactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.supporting,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                if (supporting?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    supporting!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
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
}

class _CoverageNotice extends StatelessWidget {
  const _CoverageNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Block 3: Category List ───────────────────────────────────────────────────

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
          // ── Header ────────────────────────────────────────────────────
          Text(
            context.l10n.cityDetailArrivalViabilityTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Reserve, pressão de chegada e foco inicial',
              es: 'Reserva, presión de llegada y foco inicial',
              en: 'Reserve, arrival pressure and initial focus',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
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
            fullWidth: true,
          ),
          if (firstMonthStory != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _cityDetailLocalizedText(
                            context,
                            pt: 'Como tende a ser o primeiro mês',
                            es: 'Cómo tiende a ser el primer mes',
                            en: 'What the first month tends to feel like',
                          ),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    firstMonthStory.$1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
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
    this.fullWidth = false,
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
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon + label in one row
        Row(
          children: [
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        // Value
        if (amountInBrl != null)
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
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
              height: 1.15,
            ),
          ),
        const SizedBox(height: 8),
        // "Ver mais" link
        GestureDetector(
          onTap: () => _showInsightSheet(
            context,
            title: label,
            summary: supporting,
            basis: basis,
            source: source == null
                ? null
                : context.l10n.cityDetailArrivalSourceLabel(source!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _detailActionLabel(context),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: AppColors.textSoftFor(context),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: content,
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
      return 'Cómo se interpretó esto';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Explore por tema',
              es: 'Explora por tema',
              en: 'Explore by topic',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (context, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = actions[index];
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
}

class _PinnedSectionNavDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedSectionNavDelegate({
    required this.actions,
    required this.horizontalPadding,
  });

  final List<_DetailQuickAction> actions;
  final double horizontalPadding;

  @override
  double get minExtent => 84;

  @override
  double get maxExtent => 84;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundFor(context).withValues(alpha: 0.97),
        border: Border(bottom: BorderSide(color: AppColors.borderFor(context))),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          6,
          horizontalPadding,
          4,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: _SecondaryActionsRow(actions: actions),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSectionNavDelegate oldDelegate) {
    return oldDelegate.actions != actions ||
        oldDelegate.horizontalPadding != horizontalPadding;
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceFor(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minWidth: 78),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
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

class _CityOverviewPanel extends StatelessWidget {
  const _CityOverviewPanel({required this.city, required this.strengths});

  final City city;
  final List<CityStrengthSignal> strengths;

  @override
  Widget build(BuildContext context) {
    final verdict = _buildVerdict(context);
    final watchouts = _buildWatchouts(context);
    final location = city.regionName?.trim().isNotEmpty == true
        ? '${city.stateCode} · ${city.regionName!.trim()}'
        : '${city.stateName} · ${city.countryCode}';

    return Semantics(
      container: true,
      label: verdict.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.heroStart,
                Color(0xFF123B6D),
                Color(0xFF0B6A8A),
              ],
              stops: [0, 0.58, 1],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A4B78).withValues(alpha: 0.24),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -88,
                right: -56,
                child: _OverviewHeroGlow(size: 220, color: Color(0xFF67D6F5)),
              ),
              const Positioned(
                bottom: -120,
                left: -72,
                child: _OverviewHeroGlow(size: 250, color: Color(0xFF587CFF)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                verdict.icon,
                                size: 14,
                                color: const Color(0xFF8DE4FF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _cityDetailLocalizedText(
                                  context,
                                  pt: 'VISÃO GERAL',
                                  es: 'VISTA GENERAL',
                                  en: 'CITY OVERVIEW',
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.68),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final overview = _OverviewHeroCopy(verdict: verdict);
                        final map = _BrazilLocationMiniMap(city: city);

                        if (constraints.maxWidth >= 680) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: overview),
                              const SizedBox(width: 24),
                              SizedBox(width: 210, height: 166, child: map),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            overview,
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 154,
                              child: map,
                            ),
                          ],
                        );
                      },
                    ),
                    if (watchouts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFFCE54),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _cityDetailLocalizedText(
                                    context,
                                    pt: 'Ponto de atenção',
                                    es: 'Punto de atención',
                                    en: 'Worth noting',
                                  ),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFFFFCE54),
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  watchouts.first,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DecisionVerdict _buildVerdict(BuildContext context) {
    final population = NumberFormat.compact(
      locale: Localizations.localeOf(context).toString(),
    ).format(city.population);
    final industries = city.topIndustries
        .take(3)
        .map(context.l10n.workAreaLabel)
        .join(' · ');
    final strongest = strengths.isEmpty ? null : strengths.first.title;
    final region = city.regionName?.trim();
    final location = region == null || region.isEmpty
        ? '${city.stateName} · ${city.countryCode}'
        : '${city.stateName} · $region';

    return _DecisionVerdict(
      title: _cityDetailLocalizedText(
        context,
        pt: '${city.name} em resumo',
        es: '${city.name} en resumen',
        en: '${city.name} at a glance',
      ),
      summary: _cityDetailLocalizedText(
        context,
        pt: 'Cidade de aproximadamente $population habitantes em $location. Esta página reúne uma leitura geral de custo, moradia, trabalho, rotina e infraestrutura.',
        es: 'Ciudad de aproximadamente $population habitantes en $location. Esta página reúne una lectura general de costo, vivienda, trabajo, rutina e infraestructura.',
        en: 'A city of roughly $population people in $location. This page brings together a general view of cost, housing, work, daily life, and infrastructure.',
      ),
      nextStep: strongest != null
          ? _cityDetailLocalizedText(
              context,
              pt: 'Destaque nos dados: $strongest.',
              es: 'Aspecto destacado en los datos: $strongest.',
              en: 'A standout in the available data: $strongest.',
            )
          : industries.isEmpty
          ? _cityDetailLocalizedText(
              context,
              pt: 'Os indicadores abaixo são referências da cidade, não uma recomendação pessoal.',
              es: 'Los indicadores de abajo son referencias de la ciudad, no una recomendación personal.',
              en: 'The indicators below describe the city; they are not a personal recommendation.',
            )
          : _cityDetailLocalizedText(
              context,
              pt: 'Setores em destaque: $industries.',
              es: 'Sectores destacados: $industries.',
              en: 'Key sectors: $industries.',
            ),
      icon: Icons.location_city_outlined,
    );
  }

  List<String> _buildWatchouts(BuildContext context) {
    final items = <String>[
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

class _OverviewHeroGlow extends StatelessWidget {
  const _OverviewHeroGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _OverviewHeroCopy extends StatelessWidget {
  const _OverviewHeroCopy({required this.verdict});

  final _DecisionVerdict verdict;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          verdict.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            verdict.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF8DE4FF).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8DE4FF).withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF8DE4FF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  verdict.nextStep,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrazilLocationMiniMap extends StatelessWidget {
  const _BrazilLocationMiniMap({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final cityPoint = LatLng(city.latitude, city.longitude);

    return Semantics(
      image: true,
      label: _cityDetailLocalizedText(
        context,
        pt: 'Localização de ${city.name} no mapa do Brasil',
        es: 'Ubicación de ${city.name} en el mapa de Brasil',
        en: '${city.name} on the map of Brazil',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: LatLngBounds(
                      const LatLng(-34.2, -74.0),
                      const LatLng(5.5, -32.0),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                    minZoom: 1.5,
                    maxZoom: 4,
                  ),
                  minZoom: 1.5,
                  maxZoom: 4,
                  backgroundColor: const Color(0xFFDCEAF1),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.movaro.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: cityPoint,
                        width: 38,
                        height: 38,
                        child: const _OverviewMapMarker(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0A2540).withValues(alpha: 0.05),
                        const Color(0xFF0A2540).withValues(alpha: 0.22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 9,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xE60A2540),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _cityDetailLocalizedText(
                    context,
                    pt: 'NO BRASIL',
                    es: 'EN BRASIL',
                    en: 'IN BRAZIL',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 5,
              child: Text(
                '© OpenStreetMap',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF102A43).withValues(alpha: 0.72),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMapMarker extends StatelessWidget {
  const _OverviewMapMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF0071E3).withValues(alpha: 0.24),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x660071E3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionVerdict {
  const _DecisionVerdict({
    required this.title,
    required this.summary,
    required this.nextStep,
    required this.icon,
  });

  final String title;
  final String summary;
  final String nextStep;
  final IconData icon;
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
    final apiPlaces = arrivalStory?.neighborhoods.take(4).toList() ?? const [];
    final explorePlaces = places.take(4).toList(growable: false);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Bairros e regiões',
              es: 'Barrios y zonas',
              en: 'Areas and neighborhoods',
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
          if (apiPlaces.isNotEmpty || explorePlaces.isNotEmpty) ...[
            _AreaLabel(
              title: _cityDetailLocalizedText(
                context,
                pt: 'Áreas mapeadas',
                es: 'Zonas mapeadas',
                en: 'Mapped areas',
              ),
            ),
            const SizedBox(height: 8),
            if (apiPlaces.isNotEmpty)
              for (final place in apiPlaces) ...[
                _NeighborhoodDetailTile(
                  name: _formatNeighborhoodPlace(place),
                  description: place.shortText,
                  source: place.source,
                ),
                const SizedBox(height: 8),
              ]
            else
              for (final place in explorePlaces) ...[
                _NeighborhoodDetailTile(
                  name: _formatExplorePlace(place),
                  description: place.shortText,
                  source: place.source,
                ),
                const SizedBox(height: 8),
              ],
            _CoverageNotice(
              icon: Icons.home_work_outlined,
              text: _cityDetailLocalizedText(
                context,
                pt: 'Faixa de aluguel, tempo de deslocamento e cobertura de transporte por bairro ainda não têm dados comparáveis verificados; por isso, não são estimados nesta lista.',
                es: 'El alquiler, el tiempo de viaje y la cobertura de transporte por barrio aún no tienen datos comparables verificados; por eso no se estiman en esta lista.',
                en: 'Area-level rent, commute time, and transit coverage do not yet have comparable verified data, so they are not estimated here.',
              ),
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

class _NeighborhoodDetailTile extends StatelessWidget {
  const _NeighborhoodDetailTile({
    required this.name,
    required this.description,
    required this.source,
  });

  final String name;
  final String description;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place_outlined, size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                    ),
                  ),
                ],
                if (source.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    source,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSoftFor(context),
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
}

class _InlineComparisonCard extends StatelessWidget {
  const _InlineComparisonCard({required this.city, required this.onCompare});

  final City city;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Quer colocar os dados lado a lado?',
              es: '¿Quieres ver los datos lado a lado?',
              en: 'Want to see the data side by side?',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Compare ${city.name} com qualquer outra cidade. Custo, moradia, trabalho e qualidade de vida serão mostrados com os mesmos critérios.',
              es: 'Compara ${city.name} con cualquier otra ciudad. Costo, vivienda, trabajo y calidad de vida se mostrarán con los mismos criterios.',
              en: 'Compare ${city.name} with any other city. Cost, housing, work, and quality of life will use the same criteria.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
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
        pt: 'Os blocos de custo, bairros e indicadores continuam disponíveis como referências objetivas da cidade.',
        es: 'Los bloques de costo, barrios e indicadores siguen disponibles como referencias objetivas de la ciudad.',
        en: 'Cost, areas, and indicator sections remain available as objective city references.',
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
    pt: 'A vida cotidiana em ${city.name} costuma ter $lifestyleText.',
    es: 'La vida cotidiana en ${city.name} suele tener $lifestyleText.',
    en: 'Everyday life in ${city.name} tends to have $lifestyleText.',
  );

  final tradeoff = switch (_lowestScoreKey(city)) {
    'housing' => _cityDetailLocalizedText(
      context,
      pt: 'A moradia é o indicador que merece mais contexto: preço, disponibilidade e deslocamento mudam bastante entre bairros.',
      es: 'La vivienda es el indicador que merece más contexto: precio, disponibilidad y desplazamiento cambian bastante entre barrios.',
      en: 'Housing is the indicator needing the most context: price, availability, and commute vary widely by area.',
    ),
    'safety' => _cityDetailLocalizedText(
      context,
      pt: 'O indicador de segurança é municipal e não representa igualmente todos os bairros, horários ou tipos de ocorrência.',
      es: 'El indicador de seguridad es municipal y no representa por igual todos los barrios, horarios o tipos de hechos.',
      en: 'The safety indicator is citywide and does not represent every area, time of day, or type of incident equally.',
    ),
    'language' => _cityDetailLocalizedText(
      context,
      pt: 'O português concentra trabalho, contratos e serviços; os índices de idioma são referências gerais, não garantias de adaptação.',
      es: 'El portugués concentra trabajo, contratos y servicios; los índices de idioma son referencias generales, no garantías de adaptación.',
      en: 'Portuguese dominates work, contracts, and services; language indexes are broad references, not guarantees of adaptation.',
    ),
    _ => _cityDetailLocalizedText(
      context,
      pt: 'O mercado de trabalho precisa ser lido junto dos setores econômicos, salários e sazonalidade, não apenas por um score agregado.',
      es: 'El mercado laboral debe leerse junto con los sectores económicos, salarios y estacionalidad, no solo con un puntaje agregado.',
      en: 'The job market should be read alongside industries, salaries, and seasonality, not through an aggregate score alone.',
    ),
  };

  return (practical, tradeoff);
}

(String, String, String, String) _climateSummary(
  BuildContext context,
  City city,
  CityWeather? weather,
  CityDetailClimateSummary? climateSummary,
) {
  final Object? rawSeasonality =
      climateSummary?.seasonality ?? city.seasonalitySnapshot;
  final Object? seasonality = switch (rawSeasonality) {
    CityDetailClimateSeasonality details
        when details.sourceUrl?.isNotEmpty == true =>
      details,
    CitySeasonalitySnapshot snapshot
        when snapshot.sourceUrl?.isNotEmpty == true =>
      snapshot,
    _ => null,
  };
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

String _formatNeighborhoodPlace(CityDetailNeighborhoodPlace place) {
  final values = <String?>[place.name, place.neighborhood, place.region];
  final seen = <String>{};
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty && seen.add(value.toLowerCase()))
      .join(' · ');
}

String _formatExplorePlace(CityInsightExplorePlaceEntity place) {
  final values = <String?>[place.name, place.neighborhood, place.region];
  final seen = <String>{};
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty && seen.add(value.toLowerCase()))
      .join(' · ');
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
        .map(_formatNeighborhoodPlace)
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
        .map(_formatExplorePlace)
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

String _cityMatchBandLabel(BuildContext context, double score) {
  if (score >= 0.72) {
    return context.l10n.migrationPlanResultCompatibilityHigh;
  }
  if (score >= 0.55) {
    return context.l10n.migrationPlanResultCompatibilityMedium;
  }
  return context.l10n.migrationPlanResultCompatibilityInitial;
}

/// "Dá pra viver com o salário daqui?" — compact, always-on affordability
/// Neutral city-level comparison between local average salary and typical cost.
class _AffordabilityNote extends StatelessWidget {
  const _AffordabilityNote({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    if (!CityAffordabilityCheck.isAvailable(city)) {
      return const SizedBox.shrink();
    }

    final result = CityAffordabilityCheck.forLocalSalary(city);
    if (result == null) {
      return const SizedBox.shrink();
    }

    final amount = _formatMoney(context, result.gap.abs());
    final incomeLabel = _formatMoney(context, result.monthlyIncome);

    final incomeLead = _cityDetailLocalizedText(
      context,
      pt: 'Como referência da cidade, o salário médio local ($incomeLabel) ',
      es: 'Como referencia de la ciudad, el salario promedio local ($incomeLabel) ',
      en: 'As a city-level reference, the local average salary ($incomeLabel) ',
    );

    // Neutral, reference-style comparison (not a verdict / not advice). The
    // color is just a visual cue; the wording stays descriptive.
    final (Color color, IconData icon, String body) = switch (result.verdict) {
      AffordabilityVerdict.comfortable => (
        AppColors.success,
        Icons.trending_up_rounded,
        _cityDetailLocalizedText(
          context,
          pt: 'fica acima do custo de vida típico (referência: ~$amount/mês de margem).',
          es: 'queda por encima del costo de vida típico (referencia: ~$amount/mes de margen).',
          en: 'is above the typical cost of living (reference: ~$amount/mo margin).',
        ),
      ),
      AffordabilityVerdict.tight => (
        AppColors.warning,
        Icons.trending_flat_rounded,
        _cityDetailLocalizedText(
          context,
          pt: 'fica perto do custo de vida típico (referência: ~$amount/mês de margem).',
          es: 'queda cerca del costo de vida típico (referencia: ~$amount/mes de margen).',
          en: 'is close to the typical cost of living (reference: ~$amount/mo margin).',
        ),
      ),
      AffordabilityVerdict.insufficient => (
        AppColors.danger,
        Icons.trending_down_rounded,
        _cityDetailLocalizedText(
          context,
          pt: 'fica abaixo do custo de vida típico (referência: diferença de ~$amount/mês).',
          es: 'queda por debajo del costo de vida típico (referencia: diferencia de ~$amount/mes).',
          en: 'is below the typical cost of living (reference: ~$amount/mo gap).',
        ),
      ),
    };

    final title = _cityDetailLocalizedText(
      context,
      pt: 'Dá pra viver com o salário daqui?',
      es: '¿Se puede vivir con el sueldo de acá?',
      en: 'Can you live on the local salary?',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$incomeLead$body',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const PracticalInfoDisclaimer(compact: true),
        ],
      ),
    );
  }
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

// ─── New: Redesigned City Analysis ────────────────────────────────────────────

// Overall score chip shown in the ExpansionTile header.
class _OverallScoreChip extends StatelessWidget {
  const _OverallScoreChip({required this.score});
  final int score;

  Color _tint() {
    if (score >= 72) return AppColors.success;
    if (score >= 55) return AppColors.warning;
    return AppColors.danger;
  }

  String _label(BuildContext context) {
    if (score >= 72) {
      return _cityDetailLocalizedText(
        context,
        pt: 'Forte',
        es: 'Fuerte',
        en: 'Strong',
      );
    }
    if (score >= 55) {
      return _cityDetailLocalizedText(
        context,
        pt: 'Médio',
        es: 'Medio',
        en: 'Fair',
      );
    }
    return _cityDetailLocalizedText(
      context,
      pt: 'Atenção',
      es: 'Atención',
      en: 'Caution',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tint();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tint.withValues(alpha: 0.28)),
      ),
      child: Text(
        _label(context),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Root widget that composes the full analysis content.
class _CityAnalysisContent extends StatelessWidget {
  const _CityAnalysisContent({
    required this.city,
    required this.budget,
    required this.localeName,
  });

  final City city;
  final CityBudgetSnapshot? budget;
  final String localeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Indicators ───────────────────────────────────────────────
        _AnalysisIndicatorsSection(city: city),
        const SizedBox(height: 12),

        // ── 2. Financial reality (only when budget data is available) ───
        if (budget != null) ...[
          _AnalysisFinancialSection(budget: budget!, city: city),
          const SizedBox(height: 12),
        ],

        // ── 3. Work & economy ───────────────────────────────────────────
        _AnalysisWorkSection(city: city),
        const SizedBox(height: 12),

        // ── 4. City context ─────────────────────────────────────────────
        _AnalysisContextSection(city: city, localeName: localeName),
      ],
    );
  }
}

// ── Section 1: score bars ─────────────────────────────────────────────────────

class _AnalysisIndicatorsSection extends StatelessWidget {
  const _AnalysisIndicatorsSection({required this.city});
  final City city;

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
    final housing = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );
    final work = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.work,
      value: city.movaroScores.workOpportunity,
    );
    final language = CityMetricPresentation.resolve(
      context,
      kind: CityMetricKind.language,
      value: city.movaroScores.languageAdaptation,
    );

    return _AnalysisBlock(
      icon: Icons.bar_chart_rounded,
      title: _cityDetailLocalizedText(
        context,
        pt: 'Indicadores',
        es: 'Indicadores',
        en: 'Indicators',
      ),
      child: Column(
        children: [
          _AnalysisScoreBar(
            icon: Icons.public_rounded,
            label:
                '${context.l10n.cityDetailIdhmLabel} ${city.idhmReferenceYear}',
            headline: idhm.headline,
            score: (city.idhmScore * 100).round(),
            tint: idhm.tint,
          ),
          const SizedBox(height: 10),
          _AnalysisScoreBar(
            icon: Icons.shield_outlined,
            label: context.l10n.cityDetailSafetyLabel,
            headline: safety.headline,
            score: city.safetyScore,
            tint: safety.tint,
          ),
          const SizedBox(height: 10),
          _AnalysisScoreBar(
            icon: Icons.payments_outlined,
            label: context.l10n.cityDetailCostLabel,
            headline: cost.headline,
            score: city.movaroScores.economical,
            tint: cost.tint,
          ),
          const SizedBox(height: 10),
          _AnalysisScoreBar(
            icon: Icons.home_work_outlined,
            label: context.l10n.cityHousingViabilityTileLabel,
            headline: housing.headline,
            score: city.rentScore,
            tint: housing.tint,
          ),
          const SizedBox(height: 10),
          _AnalysisScoreBar(
            icon: Icons.work_outline_rounded,
            label: context.l10n.cityDetailWorkLabel,
            headline: work.headline,
            score: city.movaroScores.workOpportunity,
            tint: work.tint,
          ),
          const SizedBox(height: 10),
          _AnalysisScoreBar(
            icon: Icons.translate_rounded,
            label: context.l10n.cityDetailLanguageLabel,
            headline: language.headline,
            score: city.movaroScores.languageAdaptation,
            tint: language.tint,
          ),
        ],
      ),
    );
  }
}

// ── Section 2: Financial reality ─────────────────────────────────────────────

class _AnalysisFinancialSection extends StatelessWidget {
  const _AnalysisFinancialSection({required this.budget, required this.city});

  final CityBudgetSnapshot budget;
  final City city;

  @override
  Widget build(BuildContext context) {
    final coverageColor = _salaryCoverageTint(budget);
    final coverageRatio = budget.fairLivingCoverageRatio;

    return _AnalysisBlock(
      icon: Icons.account_balance_wallet_outlined,
      title: _cityDetailLocalizedText(
        context,
        pt: 'Realidade financeira',
        es: 'Realidad financiera',
        en: 'Financial reality',
      ),
      subtitle: budget.updatedAt,
      child: Column(
        children: [
          // Salary — emphasis row
          _AnalysisBudgetRow(
            icon: Icons.payments_rounded,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Salário líquido médio',
              es: 'Salario neto medio',
              en: 'Average net salary',
            ),
            value: _formatMoney(context, budget.averageMonthlyNetSalary),
            tint: AppColors.success,
            emphasis: true,
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const SizedBox(height: 10),
          // Rent outside centre
          _AnalysisBudgetRow(
            icon: Icons.home_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Aluguel fora do centro',
              es: 'Alquiler fuera del centro',
              en: 'Rent outside centre',
            ),
            value: _formatMoney(context, budget.oneBedroomOutsideCentre),
            tint: AppColors.primary,
          ),
          const SizedBox(height: 8),
          // Rent city centre
          _AnalysisBudgetRow(
            icon: Icons.apartment_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Aluguel no centro',
              es: 'Alquiler en el centro',
              en: 'Rent in city centre',
            ),
            value: _formatMoney(context, budget.oneBedroomCityCentre),
            tint: AppColors.primary,
          ),
          const SizedBox(height: 8),
          // Living costs excl. rent
          _AnalysisBudgetRow(
            icon: Icons.restaurant_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Custo de vida (sem aluguel)',
              es: 'Costo de vida (sin alquiler)',
              en: 'Cost of living (ex-rent)',
            ),
            value: _formatMoney(context, budget.singlePersonExcludingRent),
            tint: AppColors.primary,
          ),
          if (budget.monthlyTransportPass > 0) ...[
            const SizedBox(height: 8),
            _AnalysisBudgetRow(
              icon: Icons.directions_bus_outlined,
              label: _cityDetailLocalizedText(
                context,
                pt: 'Passe de transporte',
                es: 'Pase de transporte',
                en: 'Transport pass',
              ),
              value: _formatMoney(context, budget.monthlyTransportPass),
              tint: AppColors.primary,
            ),
          ],
          if (budget.utilities > 0) ...[
            const SizedBox(height: 8),
            _AnalysisBudgetRow(
              icon: Icons.bolt_outlined,
              label: _cityDetailLocalizedText(
                context,
                pt: 'Utilidades (água, luz, internet)',
                es: 'Servicios (agua, luz, internet)',
                en: 'Utilities (water, power, internet)',
              ),
              value: _formatMoney(context, budget.utilities),
              tint: AppColors.primary,
            ),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const SizedBox(height: 10),
          // Cost range summary
          _AnalysisBudgetRow(
            icon: Icons.calculate_outlined,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Custo total estimado',
              es: 'Costo total estimado',
              en: 'Estimated total cost',
            ),
            value:
                '${MultiCurrencyAmount.formatRangeFromBrl(context: context, minBrl: budget.fairLivingTotal, maxBrl: budget.wellLivingTotal)}/mês',
            tint: AppColors.textSoftFor(context),
          ),
          const SizedBox(height: 14),
          // Coverage ratio card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: coverageColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: coverageColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.donut_large_rounded,
                      size: 15,
                      color: coverageColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _cityDetailLocalizedText(
                          context,
                          pt: 'Cobertura salarial',
                          es: 'Cobertura salarial',
                          en: 'Salary coverage',
                        ),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: coverageColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Text(
                      '${(coverageRatio * 100).round()}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: coverageColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (coverageRatio / 2.0).clamp(0.0, 1.0),
                    backgroundColor: coverageColor.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(coverageColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _salaryCoverageSupporting(context, budget),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: coverageColor.withValues(alpha: 0.90),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _cityDetailLocalizedText(
              context,
              pt: 'Fonte: ${budget.sourceLabel} · ${budget.updatedAt}',
              es: 'Fuente: ${budget.sourceLabel} · ${budget.updatedAt}',
              en: 'Source: ${budget.sourceLabel} · ${budget.updatedAt}',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 3: Work & economy ─────────────────────────────────────────────────

class _AnalysisWorkSection extends StatelessWidget {
  const _AnalysisWorkSection({required this.city});
  final City city;

  @override
  Widget build(BuildContext context) {
    final unemploymentTint = _unemploymentTint(city.unemploymentRate);
    final ecoTint = city.economicActivityScore >= 70
        ? AppColors.success
        : city.economicActivityScore >= 50
        ? AppColors.warning
        : AppColors.danger;

    return _AnalysisBlock(
      icon: Icons.work_outline_rounded,
      title: _cityDetailLocalizedText(
        context,
        pt: 'Trabalho & economia',
        es: 'Trabajo & economía',
        en: 'Work & economy',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unemployment pill row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: unemploymentTint.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: unemploymentTint.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.query_stats_rounded,
                      size: 17,
                      color: unemploymentTint,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.cityDetailUnemploymentLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${city.unemploymentRate.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: unemploymentTint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: unemploymentTint.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _unemploymentHeadline(context, city.unemploymentRate),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: unemploymentTint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (city.economicActivityScore > 0) ...[
            const SizedBox(height: 10),
            _AnalysisScoreBar(
              icon: Icons.auto_graph_rounded,
              label: _cityDetailLocalizedText(
                context,
                pt: 'Atividade econômica',
                es: 'Actividad económica',
                en: 'Economic activity',
              ),
              headline: city.economicActivityScore >= 70
                  ? _cityDetailLocalizedText(
                      context,
                      pt: 'Forte',
                      es: 'Fuerte',
                      en: 'Strong',
                    )
                  : city.economicActivityScore >= 50
                  ? _cityDetailLocalizedText(
                      context,
                      pt: 'Moderada',
                      es: 'Moderada',
                      en: 'Moderate',
                    )
                  : _cityDetailLocalizedText(
                      context,
                      pt: 'Limitada',
                      es: 'Limitada',
                      en: 'Limited',
                    ),
              score: city.economicActivityScore,
              tint: ecoTint,
            ),
          ],
          if (city.topIndustries.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              context.l10n.cityDetailIndustriesTitle,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: city.topIndustries.map((industry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    context.l10n.industryLabel(industry),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Section 4: City context ───────────────────────────────────────────────────

class _AnalysisContextSection extends StatelessWidget {
  const _AnalysisContextSection({required this.city, required this.localeName});

  final City city;
  final String localeName;

  @override
  Widget build(BuildContext context) {
    final popularityScore = city.movaroScores.popularForArgentinians;
    final popularityTint = popularityScore >= 80
        ? AppColors.success
        : popularityScore >= 60
        ? AppColors.warning
        : AppColors.danger;
    final popularityLabel = popularityScore >= 80
        ? _cityDetailLocalizedText(context, pt: 'Alta', es: 'Alta', en: 'High')
        : popularityScore >= 60
        ? _cityDetailLocalizedText(
            context,
            pt: 'Moderada',
            es: 'Moderada',
            en: 'Moderate',
          )
        : _cityDetailLocalizedText(context, pt: 'Baixa', es: 'Baja', en: 'Low');

    return _AnalysisBlock(
      icon: Icons.location_city_rounded,
      title: _cityDetailLocalizedText(
        context,
        pt: 'Contexto da cidade',
        es: 'Contexto de la ciudad',
        en: 'City context',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Population
          _AnalysisInfoRow(
            icon: Icons.groups_rounded,
            label: context.l10n.cityDetailPopulationLabel,
            value: NumberFormatters.compactPopulation(
              value: city.population,
              locale: localeName,
            ),
            detail: NumberFormatters.fullInteger(
              value: city.population,
              locale: localeName,
            ),
            tint: AppColors.primary,
          ),
          const SizedBox(height: 10),
          // Argentina popularity bar
          _AnalysisScoreBar(
            icon: Icons.favorite_border_rounded,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Popular entre argentinos',
              es: 'Popular entre argentinos',
              en: 'Popular among Argentinians',
            ),
            headline: popularityLabel,
            score: popularityScore,
            tint: popularityTint,
          ),
          const SizedBox(height: 10),
          // Spanish support
          if (city.spanishSupportScore > 0) ...[
            _AnalysisScoreBar(
              icon: Icons.record_voice_over_outlined,
              label: _cityDetailLocalizedText(
                context,
                pt: 'Suporte ao espanhol',
                es: 'Soporte al español',
                en: 'Spanish support',
              ),
              headline: city.spanishSupportScore >= 75
                  ? _cityDetailLocalizedText(
                      context,
                      pt: 'Bom',
                      es: 'Bueno',
                      en: 'Good',
                    )
                  : city.spanishSupportScore >= 55
                  ? _cityDetailLocalizedText(
                      context,
                      pt: 'Parcial',
                      es: 'Parcial',
                      en: 'Partial',
                    )
                  : _cityDetailLocalizedText(
                      context,
                      pt: 'Limitado',
                      es: 'Limitado',
                      en: 'Limited',
                    ),
              score: city.spanishSupportScore,
              tint: city.spanishSupportScore >= 75
                  ? AppColors.success
                  : city.spanishSupportScore >= 55
                  ? AppColors.warning
                  : AppColors.danger,
            ),
            const SizedBox(height: 10),
          ],
          // IBGE code
          _AnalysisInfoRow(
            icon: Icons.tag_rounded,
            label: _cityDetailLocalizedText(
              context,
              pt: 'Código IBGE',
              es: 'Código IBGE',
              en: 'IBGE Code',
            ),
            value: city.ibgeCode.toString(),
            tint: AppColors.textSoftFor(context),
          ),
          if (city.regionName != null) ...[
            const SizedBox(height: 8),
            _AnalysisInfoRow(
              icon: Icons.map_outlined,
              label: _cityDetailLocalizedText(
                context,
                pt: 'Região',
                es: 'Región',
                en: 'Region',
              ),
              value: city.regionName!,
              tint: AppColors.textSoftFor(context),
            ),
          ],
          // Recommendation reasons
          if (city.recommendationReasons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              _cityDetailLocalizedText(
                context,
                pt: 'Por que ${city.name} se destaca',
                es: 'Por qué destaca ${city.name}',
                en: 'Why ${city.name} stands out',
              ),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...city.recommendationReasons
                .take(4)
                .map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 15,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
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
                ),
          ],
        ],
      ),
    );
  }
}

// ── Shared block wrapper ──────────────────────────────────────────────────────

class _AnalysisBlock extends StatelessWidget {
  const _AnalysisBlock({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Score bar ─────────────────────────────────────────────────────────────────

class _AnalysisScoreBar extends StatelessWidget {
  const _AnalysisScoreBar({
    required this.icon,
    required this.label,
    required this.headline,
    required this.score,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String headline;
  final int score;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final fraction = (score / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    headline,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: tint.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(tint),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Budget amount row ─────────────────────────────────────────────────────────

class _AnalysisBudgetRow extends StatelessWidget {
  const _AnalysisBudgetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: tint.withValues(alpha: 0.75)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: emphasis
              ? Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tint,
                )
              : Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Info row (label + value + optional detail) ────────────────────────────────

class _AnalysisInfoRow extends StatelessWidget {
  const _AnalysisInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (detail != null)
              Text(
                detail!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _formatMoney(BuildContext context, int amount) {
  return MultiCurrencyAmount.formatPreferredCurrency(
    context: context,
    amountInBrl: amount,
    exchangeRates: null,
  );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/utils/number_formatters.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/error_state_widget.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_map_card.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_insight_sheet.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_public_opinion_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_snapshot_tile.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_sources_section.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_weather_badge.dart';
import 'package:movaro_app/features/cities/presentation/widgets/methodology_info_banner.dart';
import 'package:movaro_app/features/cities/presentation/widgets/recommendation_reason_list.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class CityDetailPage extends StatefulWidget {
  const CityDetailPage({
    required this.cityId,
    required this.citiesController,
    this.migrationQuestionnaireController,
    this.selectForPlan = false,
    super.key,
  });

  final String cityId;
  final CitiesController citiesController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;
  final bool selectForPlan;

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  City? _city;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
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
    _refreshScrollHint();

    await methodologyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final city = _city;
        final methodology = widget.citiesController.methodology;
        final l10n = context.l10n;
        final localeName = Localizations.localeOf(context).toString();
        final planContext = city == null
            ? null
            : _resolvePlanContext(context, city);

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Stack(
                  children: [
                    ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 96,
                      ),
                      children: [
                        if (city == null &&
                            widget.citiesController.isLoadingCity)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1160),
                            child: DetailSkeleton(),
                          )
                        else if (city == null &&
                            widget.citiesController.cityError != null)
                          Builder(
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
                        else if (city == null)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1160),
                            child: DetailSkeleton(),
                          )
                        else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: _goBackToCities,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(l10n.citiesExploreTitle),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 28,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: CityImageBackdrop(
                                city: city,
                                borderRadius: BorderRadius.circular(32),
                                padding: const EdgeInsets.all(28),
                                overlayOpacity: 0.8,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compactHero =
                                        constraints.maxWidth < 760;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          height: 0.96,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${city.stateName} (${city.stateCode})',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                    alpha: 0.84,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      _LifestyleBadge(
                                                        city: city,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            _HeroIconButton(
                                              icon:
                                                  widget.citiesController
                                                      .isFavorite(city.id)
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                        .favorite_border_rounded,
                                              active: widget.citiesController
                                                  .isFavorite(city.id),
                                              onTap: () => _toggleFavoriteCity(
                                                context,
                                                city,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 12,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            CityWeatherBadge(
                                              cityId: city.id,
                                              citiesController:
                                                  widget.citiesController,
                                              prominent: true,
                                            ),
                                            _HeroActionPill(
                                              icon:
                                                  Icons.travel_explore_rounded,
                                              label:
                                                  l10n.cityDetailDiscoverAction,
                                              onTap: () =>
                                                  _openCityGoogleOverview(city),
                                            ),
                                            if (widget.selectForPlan)
                                              _HeroActionPill(
                                                icon:
                                                    Icons.check_circle_rounded,
                                                label: l10n
                                                    .migrationPlanChooseCityAction,
                                                onTap: () => _confirmPlanCity(
                                                  context,
                                                  city,
                                                ),
                                                emphasized: true,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: compactHero
                                                    ? constraints.maxWidth
                                                    : 620,
                                              ),
                                              child: Text(
                                                planContext?.heroSummary ??
                                                    context.l10n
                                                        .recommendationReasonLabel(
                                                          city
                                                              .recommendationReasons
                                                              .first,
                                                        ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.72,
                                                          ),
                                                      height: 1.4,
                                                    ),
                                              ),
                                            ),
                                            _TrustChip(
                                              icon: Icons.schedule_rounded,
                                              label: l10n
                                                  .cityDetailUpdatedLabel(
                                                    _formatUpdatedAt(
                                                      context,
                                                      city.updatedAt,
                                                    ),
                                                  ),
                                            ),
                                            _TrustChip(
                                              icon: Icons.verified_outlined,
                                              label: l10n
                                                  .cityDetailSourcesSummary(
                                                    city.sources.all.length,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _DecisionSnapshotPanel(
                              city: city,
                              planContext: planContext,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _EssentialsGrid(
                              city: city,
                              primaryPriority: planContext?.primaryPriority,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: _CityExternalOverviewPanel(
                              city: city,
                              onOpenGoogleOverview: () =>
                                  _openCityGoogleOverview(city),
                            ),
                          ),
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: Card(
                              child: ExpansionTile(
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
                                subtitle: Text(l10n.cityDetailDeepDiveSummary),
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: CityMapCard(city: city),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: SectionLoadingOverlay(
                              isLoading: methodology == null,
                              label: l10n.cityDetailLoadingLabel,
                              child: MethodologyInfoBanner(
                                message: l10n.citiesMethodologyNote,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: CitySourcesSection(sources: city.sources),
                          ),
                        ],
                      ],
                    ),
                    _ScrollHintOverlay(
                      visible: _showScrollHint,
                      label: context.l10n.bmpScrollHint,
                      onTap: _scrollDown,
                    ),
                  ],
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

  Future<void> _confirmPlanCity(BuildContext context, City city) async {
    await widget.migrationQuestionnaireController?.confirmPlanCity(city);
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.migrationPlanCopilot);
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

  String _planAwareWatchout(
    BuildContext context,
    City city,
    MigrationPlan plan,
  ) {
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

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
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
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDark ? Colors.white : const Color(0xFF183A70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionPill extends StatelessWidget {
  const _HeroActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: emphasized
                ? Colors.white
                : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: emphasized
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: emphasized ? AppColors.heroMiddle : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: emphasized ? AppColors.heroMiddle : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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

class _DecisionSnapshotPanel extends StatelessWidget {
  const _DecisionSnapshotPanel({required this.city, this.planContext});

  final City city;
  final _PlanCityContext? planContext;

  @override
  Widget build(BuildContext context) {
    final bestFor = planContext?.focusLabel ?? _bestForLabel(context, city);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cityDetailDecisionSnapshotTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            planContext?.isRecommended == true
                ? context.l10n.cityDetailDecisionSnapshotRecommendedSubtitle(
                    bestFor,
                  )
                : planContext != null
                ? context.l10n.cityDetailDecisionSnapshotPlanSubtitle(bestFor)
                : context.l10n.cityDetailDecisionSnapshotSubtitle(bestFor),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          if (planContext != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextChip(
                  label: planContext!.isRecommended
                      ? context.l10n.cityDetailPlanLeadingChip
                      : context.l10n.cityDetailPlanMatchChip,
                ),
                for (final label in planContext!.priorityChips)
                  _ContextChip(label: label),
                for (final label in planContext!.constraintChips)
                  _ContextChip(label: label),
              ],
            ),
          ],
          const SizedBox(height: 14),
          RecommendationReasonList(
            reasons: planContext?.reasons ?? city.recommendationReasons,
            maxItems: 3,
          ),
          const SizedBox(height: 14),
          _WatchoutCard(
            title: context.l10n.cityDetailWatchoutTitle,
            body: planContext?.watchout ?? defaultWatchoutText(context, city),
          ),
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

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          items[index],
          if (index != items.length - 1) const SizedBox(height: 12),
        ],
      ],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cityDetailDiscoverTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.cityDetailDiscoverBody(city.name, city.stateName),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          );

          return Flex(
            direction: stacked ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: stacked
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (stacked) textContent else Expanded(child: textContent),
              SizedBox(width: stacked ? 0 : 20, height: stacked ? 16 : 0),
              FilledButton.icon(
                onPressed: onOpenGoogleOverview,
                icon: const Icon(Icons.open_in_browser_rounded),
                label: Text(context.l10n.cityDetailDiscoverAction),
              ),
            ],
          );
        },
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
    final hintColor = AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : tint.withValues(alpha: 0.10);
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
                                  label,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.textSoftFor(context),
                                        fontWeight: FontWeight.w700,
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
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: hintColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: tint.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: hintColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tint.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              size: 16,
                              color: tint.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.cityMetricInsightTapHint,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      height: 1.25,
                                      fontWeight: FontWeight.w600,
                                    ),
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

class _WatchoutCard extends StatelessWidget {
  const _WatchoutCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.warning,
          lightColor: const Color(0xFFFFF8E7),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.warning,
            lightColor: const Color(0xFFEFCF84),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.visibility_outlined,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/presentation/widgets/city_insights_section.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/home/application/streak_service.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/home_visual_layout.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({
    required this.cityInsightsController,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
    required this.environment,
    super.key,
  });

  final CityInsightController cityInsightsController;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final LocationController locationController;
  final AppEnvironment environment;

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage>
    with WidgetsBindingObserver {
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  final StreakService _streakService = StreakService();
  MigrationCopilotProgressSnapshot _progressSnapshot =
      const MigrationCopilotProgressSnapshot();
  int _streakDays = 0;
  String? _loadedPlanKey;
  String? _loadedWeatherCityId;
  bool _didTryPromptLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.journeyContextController.addListener(_handleControllerUpdate);
    widget.migrationQuestionnaireController.addListener(
      _handleControllerUpdate,
    );
    widget.citiesController.addListener(_handleControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncPlanState());
      unawaited(_maybePromptLocationPermission());
      unawaited(_recordStreak());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.journeyContextController.removeListener(_handleControllerUpdate);
    widget.migrationQuestionnaireController.removeListener(
      _handleControllerUpdate,
    );
    widget.citiesController.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshProgress());
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.isDesktopLayout ? 520.0 : double.infinity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.isDark(context)
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        backgroundColor: _screenBackground(context),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              widget.cityInsightsController,
              widget.journeyContextController,
              widget.migrationQuestionnaireController,
              widget.citiesController,
            ]),
            builder: (context, _) {
              final plan =
                  widget.migrationQuestionnaireController.generatedPlan;
              final city = plan?.isCityConfirmed == true
                  ? plan?.recommendedCity
                  : null;
              final hasActivePlan = city != null;
              final guideState = city == null || plan == null
                  ? null
                  : _buildGuideState(plan, _progressSnapshot);

              return Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        children: [
                          FutureBuilder<bool>(
                            future: widget.locationController
                                .shouldShowInlineBanner(),
                            builder: (context, snapshot) {
                              if (snapshot.data != true) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  12,
                                  0,
                                ),
                                child: LocationBannerWidget(
                                  onActivate: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.locationPermission,
                                    arguments:
                                        const LocationPermissionScreenArgs(
                                          returnToPrevious: true,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: hasActivePlan
                                  ? _ActiveHomeState(
                                      key: const ValueKey('active-home'),
                                      city: city,
                                      weather: widget.citiesController
                                          .weatherFor(city.id),
                                      guideState: guideState!,
                                      cityInsightsController:
                                          widget.cityInsightsController,
                                      planGoal: plan!.goal,
                                      planTimeline: plan.timeline,
                                      recommendationReasons:
                                          plan.cityRecommendationReasons,
                                      streakDays: _streakDays,
                                      onOpenSettings: _openSettings,
                                      onViewAction: (item) =>
                                          _showActionDetails(context, item),
                                      onCompare: () => _openComparison(city),
                                      onViewCity: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.cityDetail(city.id),
                                      ),
                                      onNewPlan: () =>
                                          _handleManagePlan(context),
                                    )
                                  : _EmptyHomeState(
                                      key: const ValueKey('empty-home'),
                                      onActionTap: (index) =>
                                          _handleEmptyStateAction(
                                            context,
                                            index,
                                          ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: MainNavigationBar(
          currentIndex: 0,
          journeyContextController: widget.journeyContextController,
          citiesController: widget.citiesController,
          migrationQuestionnaireController:
              widget.migrationQuestionnaireController,
        ),
      ),
    );
  }

  Color _screenBackground(BuildContext context) => AppColors.isDark(context)
      ? const Color(0xFF07090E)
      : const Color(0xFFF4F6FA);

  void _handleControllerUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_syncPlanState());
      }
    });
  }

  Future<void> _syncPlanState() async {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final city = plan?.isCityConfirmed == true ? plan?.recommendedCity : null;

    if (plan == null || city == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadedPlanKey = null;
        _loadedWeatherCityId = null;
        _progressSnapshot = const MigrationCopilotProgressSnapshot();
      });
      widget.cityInsightsController.clear();
      return;
    }

    if (_loadedWeatherCityId != city.id) {
      _loadedWeatherCityId = city.id;
      unawaited(widget.citiesController.loadWeatherForCity(city.id));
    }

    final planKey = _planKey(plan);
    if (_loadedPlanKey == planKey) {
      return;
    }

    final snapshot = await _progressStore.read(plan);
    if (!mounted) {
      return;
    }

    setState(() {
      _loadedPlanKey = planKey;
      _progressSnapshot = snapshot;
    });

    unawaited(
      widget.cityInsightsController.load(
        cityId: city.id,
        goal: plan.goal,
        timeline: plan.timeline,
        locale: Localizations.localeOf(context).languageCode,
      ),
    );
  }

  Future<void> _maybePromptLocationPermission() async {
    if (_didTryPromptLocation || !mounted) {
      return;
    }
    _didTryPromptLocation = true;

    await widget.locationController.initialize();
    final shouldAsk = await widget.locationController.shouldRequestAgain();
    if (!mounted || !shouldAsk) {
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.locationPermission,
      arguments: const LocationPermissionScreenArgs(returnToPrevious: true),
    );
  }

  Future<void> _startPlanFlow(BuildContext context) async {
    await widget.migrationQuestionnaireController.initialize();
    if (!context.mounted) {
      return;
    }
    Navigator.pushNamed(context, AppRoutes.migrationStart);
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  Future<void> _handleEmptyStateAction(BuildContext context, int index) async {
    switch (index) {
      case 0:
        await Navigator.pushNamed(
          context,
          AppRoutes.documentationGuide,
          arguments: DocumentationGuideSection.costs,
        );
      case 1:
        await Navigator.pushNamed(
          context,
          AppRoutes.documentationGuide,
          arguments: DocumentationGuideSection.documents,
        );
      case 2:
        await Navigator.pushNamed(context, AppRoutes.cities);
      case 3:
        await _startPlanFlow(context);
    }
  }

  void _openComparison(City city) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CityComparisonScreen(
          initialCities: [city],
          citiesController: widget.citiesController,
          migrationQuestionnaireController:
              widget.migrationQuestionnaireController,
        ),
      ),
    );
  }

  Future<void> _handleManagePlan(BuildContext context) async {
    final choice = await showPlanResetDialog(
      context,
      currentCityName: widget
          .migrationQuestionnaireController
          .generatedPlan
          ?.recommendedCity
          ?.name,
    );
    if (!context.mounted || choice == null) {
      return;
    }

    await widget.migrationQuestionnaireController.clearCurrentPlan();
    if (!context.mounted) {
      return;
    }

    if (choice == PlanResetChoice.rebuild) {
      Navigator.pushNamed(context, AppRoutes.migrationStart);
    }
  }

  Future<void> _showActionDetails(
    BuildContext context,
    GuideActionItem? item,
  ) async {
    if (item == null) {
      return;
    }

    final body = [
      item.summaryText,
      if (item.whyItMatters != null) item.whyItMatters!,
      if (item.doneCriteria != null) item.doneCriteria!,
      if (item.fullContent?.trim().isNotEmpty == true) item.fullContent!,
    ].join('\n\n');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBackground(sheetContext),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cardBorder(sheetContext)),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(sheetContext).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.45,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        body,
                        style: Theme.of(sheetContext).textTheme.bodyMedium
                            ?.copyWith(
                              color: _secondaryText(sheetContext),
                              height: 1.5,
                            ),
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

  _HomeGuideState _buildGuideState(
    MigrationPlan plan,
    MigrationCopilotProgressSnapshot snapshot,
  ) {
    final completedIds = snapshot.getAllCompletedIds();
    final items =
        ArgentinaBrazilGuideDataSource.build(
              plan,
              currentLocation: widget.locationController.savedLocation,
              localeCode: Localizations.localeOf(context).languageCode,
            )
            .map(
              (item) =>
                  item.copyWith(isCompleted: completedIds.contains(item.id)),
            )
            .toList(growable: false)
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    GuideActionItem? currentItem;
    for (final item in items) {
      final unlocked = item.dependencies.every(completedIds.contains);
      if (!item.isCompleted && unlocked) {
        currentItem = item;
        break;
      }
    }

    currentItem ??= items.firstWhere(
      (item) => !item.isCompleted,
      orElse: () => const GuideActionItem(
        id: 'completed',
        title: '',
        shortDescription: '',
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 0,
        isCompleted: true,
      ),
    );

    final currentPhaseIndex = currentItem.id == 'completed'
        ? GuidePhase.values.length
        : GuidePhase.values.indexOf(currentItem.phase) + 1;

    return _HomeGuideState(
      items: items,
      completedIds: completedIds,
      currentItem: currentItem.id == 'completed' ? null : currentItem,
      completedCount: completedIds.length,
      totalItems: items.length,
      progressPercent: items.isEmpty
          ? 0
          : ((completedIds.length / items.length) * 100).round(),
      currentPhaseIndex: currentPhaseIndex,
      totalPhases: GuidePhase.values.length,
    );
  }

  Future<void> _recordStreak() async {
    final days = await _streakService.recordActivity();
    if (!mounted) return;
    setState(() => _streakDays = days);
  }

  /// Force-refreshes the progress snapshot from disk (e.g. after returning
  /// from the guide page where the user may have completed items).
  Future<void> _refreshProgress() async {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    if (plan == null) return;

    // Record activity — user was actively using the guide.
    final days = await _streakService.recordActivity();
    final snapshot = await _progressStore.read(plan);
    if (!mounted) return;

    setState(() {
      _progressSnapshot = snapshot;
      _streakDays = days;
    });
  }

  String _planKey(MigrationPlan plan) {
    return [
      plan.originCountry,
      plan.destinationCountry,
      plan.goal,
      plan.timeline,
      plan.recommendedCity?.id ?? 'no-city',
    ].join('::');
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({required this.onActionTap, super.key});

  final ValueChanged<int> onActionTap;

  @override
  Widget build(BuildContext context) {
    return HomeVisualLayout(onActionTap: onActionTap);
  }
}

class _ActiveHomeState extends StatelessWidget {
  const _ActiveHomeState({
    required this.city,
    required this.weather,
    required this.guideState,
    required this.cityInsightsController,
    required this.planGoal,
    required this.planTimeline,
    required this.recommendationReasons,
    required this.streakDays,
    required this.onOpenSettings,
    required this.onViewAction,
    required this.onCompare,
    required this.onViewCity,
    required this.onNewPlan,
    super.key,
  });

  final City city;
  final CityWeather? weather;
  final _HomeGuideState guideState;
  final CityInsightController cityInsightsController;
  final String planGoal;
  final String planTimeline;
  final List<String> recommendationReasons;
  final int streakDays;
  final VoidCallback onOpenSettings;
  final ValueChanged<GuideActionItem> onViewAction;
  final VoidCallback onCompare;
  final VoidCallback onViewCity;
  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) {
    final hero = _ActiveHero(
      city: city,
      weather: weather,
      onOpenSettings: onOpenSettings,
    );

    final progressCard = _MigrationProgressCard(
      state: guideState,
      streakDays: streakDays,
    );

    final actionRow = _SecondaryActionRow(
      onCompare: onCompare,
      onViewCity: onViewCity,
      onNewPlan: onNewPlan,
    );
    final insightsSection = CityInsightsSection(
      controller: cityInsightsController,
      city: city,
      weather: weather,
      goal: planGoal,
      timeline: planTimeline,
      recommendationReasons: recommendationReasons,
    );

    return Column(
      children: [
        hero,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                progressCard,
                const SizedBox(height: 5),
                _NextActionsSection(
                  state: guideState,
                  onTap: onViewAction,
                ),
                const SizedBox(height: 5),
                actionRow,
                const SizedBox(height: 5),
                Expanded(child: insightsSection),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveHero extends StatelessWidget {
  const _ActiveHero({
    required this.city,
    required this.weather,
    required this.onOpenSettings,
  });

  final City city;
  final CityWeather? weather;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final stateLabel = city.stateName.isNotEmpty
        ? city.stateName
        : city.stateCode;

    return SizedBox(
      height: MediaQuery.of(context).padding.top + 156,
      child: Stack(
        children: [
          Positioned.fill(child: _HeroCityImage(city: city)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? const Color(0x33090C12) : const Color(0x26F0F6FC),
                    isDark ? const Color(0x8C090C12) : const Color(0x99F0F6FC),
                    isDark ? const Color(0xFF07090E) : const Color(0xFFF4F6FA),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _badgeBackground(context),
                border: Border.all(color: _badgeBorder(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.l10n.homeActivePlanBadge,
                    style: AppTypography.compactBadge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _accentText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            right: 14,
            child: _SettingsButton(onTap: onOpenSettings),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        city.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: isDark
                                  ? Colors.white
                                  : _primaryText(context),
                              shadows: isDark
                                  ? const [
                                      Shadow(
                                        blurRadius: 12,
                                        color: Color(0x80000000),
                                      ),
                                    ]
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$stateLabel, ${context.l10n.countryLabel('brazil')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : _secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  weather == null
                      ? '--'
                      : '${weather!.temperatureCelsius.round()}°C',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : _secondaryText(context),
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

// ─── Unified migration progress + next-action card ────────────────────────────
//
// Replaces the old _ProgressCard + _NextActionCard pair.
// Only rendered when the plan is active (progress > 0 or guide started).

class _MigrationProgressCard extends StatelessWidget {
  const _MigrationProgressCard({
    required this.state,
    required this.streakDays,
  });

  final _HomeGuideState state;
  final int streakDays;

  // Canonical display order for the 5 phases.
  static const _phaseOrder = [
    GuidePhase.preparation,
    GuidePhase.documents,
    GuidePhase.housing,
    GuidePhase.work,
    GuidePhase.arrival,
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = _screenSizeOf(context);
    final cardPadding = switch (screenSize) {
      _ScreenSize.small => 7.0,
      _ScreenSize.medium => 9.0,
      _ScreenSize.large => 11.0,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _progressBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BLOCK 1: Header ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.homeJourneyTitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.40),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (streakDays > 0) _StreakBadge(days: streakDays),
            ],
          ),
          const SizedBox(height: 5),

          // ── BLOCK 2: Journey list + Metrics ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phase list
              Expanded(
                child: _PhaseList(state: state, phases: _phaseOrder),
              ),
              // Vertical divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 60,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Metrics column
              _MetricsColumn(state: state),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Streak badge ──────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days == 1
        ? context.l10n.homeJourneyActiveDaySingle
        : context.l10n.homeJourneyActiveDayPlural;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Text(
        '🔥 $days $label',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: _accentText(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Phase list (Block 2, left column) ─────────────────────────────────────────

enum _PhaseStatus { completed, current, future }

class _PhaseList extends StatelessWidget {
  const _PhaseList({required this.state, required this.phases});

  final _HomeGuideState state;
  final List<GuidePhase> phases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < phases.length; i++) ...[
          _PhaseRow(phase: phases[i], status: _status(phases[i])),
          if (i < phases.length - 1) const SizedBox(height: 1),
        ],
      ],
    );
  }

  _PhaseStatus _status(GuidePhase phase) {
    final phaseItems = state.items.where((it) => it.phase == phase).toList();
    if (phaseItems.isEmpty) return _PhaseStatus.future;
    if (phaseItems.every((it) => state.completedIds.contains(it.id))) {
      return _PhaseStatus.completed;
    }
    if (state.currentItem?.phase == phase) return _PhaseStatus.current;
    return _PhaseStatus.future;
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.phase, required this.status});

  final GuidePhase phase;
  final _PhaseStatus status;

  @override
  Widget build(BuildContext context) {
    final label = _phaseLabel(context, phase);

    final nameStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: switch (status) {
        _PhaseStatus.completed => Colors.white.withValues(alpha: 0.45),
        _PhaseStatus.current => Colors.white,
        _PhaseStatus.future => Colors.white.withValues(alpha: 0.25),
      },
      fontWeight: status == _PhaseStatus.current
          ? FontWeight.w700
          : FontWeight.w400,
    );

    final Widget indicator = switch (status) {
      _PhaseStatus.completed => Icon(
        Icons.check_rounded,
        size: 13,
        color: _accentText(context),
      ),
      _PhaseStatus.current => Text(
        context.l10n.homeJourneyCurrentPhaseMarker,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      _PhaseStatus.future => Text(
        context.l10n.homeJourneyLockedPhaseMarker,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
    };

    final rowContent = Row(
      children: [
        Expanded(child: Text(label, style: nameStyle)),
        indicator,
      ],
    );

    if (status == _PhaseStatus.current) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: rowContent,
      );
    }
    return rowContent;
  }

  String _phaseLabel(BuildContext context, GuidePhase phase) => switch (phase) {
    GuidePhase.preparation => context.l10n.homeJourneyPhasePreparation,
    GuidePhase.documents => context.l10n.homeJourneyPhaseDocuments,
    GuidePhase.housing => context.l10n.homeJourneyPhaseHousing,
    GuidePhase.work => context.l10n.homeJourneyPhaseWork,
    GuidePhase.arrival => context.l10n.homeJourneyPhaseArrival,
  };
}

// ─── Metrics column (Block 2, right column) ────────────────────────────────────

class _MetricsColumn extends StatelessWidget {
  const _MetricsColumn({required this.state});

  final _HomeGuideState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${state.completedCount}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _accentText(context),
              height: 1.1,
            ),
          ),
          Text(
            'de ${state.totalItems} ítems',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.40),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Próximas Acciones section ─────────────────────────────────────────────────

class _NextActionsSection extends StatelessWidget {
  const _NextActionsSection({
    required this.state,
    required this.onTap,
  });

  final _HomeGuideState state;
  final ValueChanged<GuideActionItem> onTap;

  @override
  Widget build(BuildContext context) {
    final pendingItems = state.items
        .where((it) => !it.isCompleted)
        .take(3)
        .toList(growable: false);

    if (pendingItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PRÓXIMAS ACCIONES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSoftFor(context),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        for (var i = 0; i < pendingItems.length; i++) ...[
          _NextActionItem(
            item: pendingItems[i],
            priorityIndex: i,
            onTap: () => onTap(pendingItems[i]),
          ),
          if (i < pendingItems.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _NextActionItem extends StatelessWidget {
  const _NextActionItem({
    required this.item,
    required this.priorityIndex,
    required this.onTap,
  });

  final GuideActionItem item;
  final int priorityIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (borderColor, badgeText) = switch (priorityIndex) {
      0 => (AppColors.danger, 'URGENTE'),
      1 => (AppColors.warning, 'Próximo paso'),
      _ => (AppColors.primary, 'Pendiente'),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: _cardBackground(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _cardBorder(context)),
          ),
          child: SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left priority border
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _primaryText(context),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Priority badge
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.compactBadge.copyWith(
                        color: borderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionRow extends StatelessWidget {
  const _SecondaryActionRow({
    required this.onCompare,
    required this.onViewCity,
    required this.onNewPlan,
  });

  final VoidCallback onCompare;
  final VoidCallback onViewCity;
  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.compare_arrows_rounded,
            label: context.l10n.homeActionCompare,
            onTap: onCompare,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.location_city_outlined,
            label: context.l10n.homeActionViewCity,
            onTap: onViewCity,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.restart_alt_rounded,
            label: context.l10n.homeActionNewPlan,
            onTap: onNewPlan,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sz = _screenSizeOf(context);
    final containerSize = switch (sz) {
      _ScreenSize.small => 26.0,
      _ScreenSize.medium => 30.0,
      _ScreenSize.large => 36.0,
    };
    final iconSize = switch (sz) {
      _ScreenSize.small => 14.0,
      _ScreenSize.medium => 16.0,
      _ScreenSize.large => 18.0,
    };
    final verticalPadding = switch (sz) {
      _ScreenSize.small => 10.0,
      _ScreenSize.medium => 12.0,
      _ScreenSize.large => 14.0,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? const Color(0xFF0E1825)
                : const Color(0xFFF0F4FA),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _cardBorder(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: _badgeBackground(context),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: iconSize, color: _accentText(context)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: _tertiaryText(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCityImage extends StatelessWidget {
  const _HeroCityImage({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return CityResolvedImage(
      city: city,
      fit: BoxFit.cover,
      placeholder: _HeroImageFallback(isDark: AppColors.isDark(context)),
      errorWidget: _HeroImageFallback(isDark: AppColors.isDark(context)),
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1A3A5C), Color(0xFF0D1E30)]
              : const [Color(0xFFC8DDEF), Color(0xFFE8F4FF)],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.08),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.10),
            ),
          ),
          child: Icon(
            Icons.settings_outlined,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.60)
                : Colors.black.withValues(alpha: 0.50),
          ),
        ),
      ),
    );
  }
}

class _HomeGuideState {
  const _HomeGuideState({
    required this.items,
    required this.completedIds,
    required this.currentItem,
    required this.completedCount,
    required this.totalItems,
    required this.progressPercent,
    required this.currentPhaseIndex,
    required this.totalPhases,
  });

  final List<GuideActionItem> items;
  final Set<String> completedIds;
  final GuideActionItem? currentItem;
  final int completedCount;
  final int totalItems;
  final int progressPercent;
  final int currentPhaseIndex;
  final int totalPhases;

  String currentTitle(BuildContext context) {
    final item = currentItem;
    if (item == null) {
      return context.l10n.homeJourneyComplete;
    }
    final prefix = switch (Localizations.localeOf(context).languageCode) {
      'es' => 'Siguiente paso',
      'pt' => 'Próximo passo',
      _ => 'Next step',
    };
    return '$prefix: ${item.title}';
  }

  String phaseName(BuildContext context) {
    final phase = currentItem?.phase ?? GuidePhase.arrival;
    final locale = Localizations.localeOf(context).languageCode;
    return switch (phase) {
      GuidePhase.preparation =>
        locale == 'es'
            ? 'Empezando'
            : locale == 'pt'
            ? 'Começando'
            : 'Getting started',
      GuidePhase.housing =>
        locale == 'es'
            ? 'Donde quedarte'
            : locale == 'pt'
            ? 'Onde ficar'
            : 'Where to stay',
      GuidePhase.documents =>
        locale == 'es'
            ? 'Documentos esenciales'
            : locale == 'pt'
            ? 'Documentos essenciais'
            : 'Essential documents',
      GuidePhase.work =>
        locale == 'es'
            ? 'Dinero y trabajo'
            : locale == 'pt'
            ? 'Dinheiro e trabalho'
            : 'Money and work',
      GuidePhase.arrival =>
        locale == 'es'
            ? 'Estabilizandote'
            : locale == 'pt'
            ? 'Estabilizando'
            : 'Settling in',
    };
  }

  Color segmentColor(BuildContext context, int index) {
    final item = items[index];
    if (completedIds.contains(item.id)) {
      return AppColors.isDark(context)
          ? const Color(0xFF0EA5E9)
          : const Color(0xFF0284C7);
    }
    if (currentItem?.id == item.id) {
      return AppColors.isDark(context)
          ? const Color(0x660EA5E9)
          : const Color(0x590EA5E9);
    }
    return AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
  }
}

Color _cardBackground(BuildContext context) =>
    AppColors.isDark(context) ? const Color(0xFF0E1825) : Colors.white;

Color _cardBorder(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.08)
    : Colors.black.withValues(alpha: 0.08);

Color _progressBorder(BuildContext context) => AppColors.isDark(context)
    ? const Color(0x2E0EA5E9)
    : const Color(0x330EA5E9);

Color _primaryText(BuildContext context) =>
    AppColors.isDark(context) ? Colors.white : const Color(0xFF0A0F1E);

Color _secondaryText(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.40)
    : const Color(0x800A0F1E);

Color _tertiaryText(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.25)
    : const Color(0x590A0F1E);

Color _badgeBackground(BuildContext context) => AppColors.isDark(context)
    ? const Color(0x2E0284C7)
    : const Color(0x1F0284C7);

Color _badgeBorder(BuildContext context) => AppColors.isDark(context)
    ? const Color(0x4D0EA5E9)
    : const Color(0x660EA5E9);

Color _accentText(BuildContext context) => AppColors.isDark(context)
    ? const Color(0xFF38BDF8)
    : const Color(0xFF0369A1);

// ─── Screen-size breakpoints ─────────────────────────────────────────────────
//
// Used by the journey card widgets to adapt padding, icon sizes, and spacing
// to the available vertical real estate without hardcoding pixel values.

enum _ScreenSize { small, medium, large }

_ScreenSize _screenSizeOf(BuildContext context) {
  final h = MediaQuery.of(context).size.height;
  if (h < 700) return _ScreenSize.small;
  if (h < 850) return _ScreenSize.medium;
  return _ScreenSize.large;
}

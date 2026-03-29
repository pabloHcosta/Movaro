import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/home/application/city_budget_data.dart';
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
import 'package:movaro_app/features/home/presentation/widgets/city_feed_widget.dart';
import 'package:movaro_app/features/home/presentation/widgets/journey_stepper_widget.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                      plan: plan!,
                                      guideState: guideState!,
                                      cityInsightsController:
                                          widget.cityInsightsController,
                                      planGoal: plan.goal,
                                      planTimeline: plan.timeline,
                                      recommendationReasons:
                                          plan.cityRecommendationReasons,
                                      onOpenSettings: _openSettings,
                                      onViewAction: (_) => Navigator.pushNamed(
                                        context,
                                        AppRoutes.migrationPlanCopilot,
                                      ),
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
    await _streakService.recordActivity();
  }

  /// Force-refreshes the progress snapshot from disk (e.g. after returning
  /// from the guide page where the user may have completed items).
  Future<void> _refreshProgress() async {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    if (plan == null) return;

    // Record activity — user was actively using the guide.
    await _streakService.recordActivity();
    final snapshot = await _progressStore.read(plan);
    if (!mounted) return;

    setState(() {
      _progressSnapshot = snapshot;
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
    required this.plan,
    required this.guideState,
    required this.cityInsightsController,
    required this.planGoal,
    required this.planTimeline,
    required this.recommendationReasons,
    required this.onOpenSettings,
    required this.onViewAction,
    required this.onCompare,
    required this.onViewCity,
    required this.onNewPlan,
    super.key,
  });

  final City city;
  final CityWeather? weather;
  final MigrationPlan plan;
  final _HomeGuideState guideState;
  final CityInsightController cityInsightsController;
  final String planGoal;
  final String planTimeline;
  final List<String> recommendationReasons;
  final VoidCallback onOpenSettings;
  final ValueChanged<GuideActionItem> onViewAction;
  final VoidCallback onCompare;
  final VoidCallback onViewCity;
  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final stage = UserJourneyStageDetector.detect(
      timeline: planTimeline,
      completedSteps: guideState.completedCount,
      totalSteps: guideState.totalItems,
    );
    final isDark = AppColors.isDark(context);
    final topPad = MediaQuery.of(context).padding.top;

    // ── Adaptive Focus Mode layout ────────────────────────────────────────
    // LayoutBuilder gives the actual height available to this widget
    // (= screen height − nav bar − location banner if visible).
    // All section heights are derived from this, so the layout fills
    // the screen on any device — small (SE) to large (Pro Max).
    return LayoutBuilder(
      builder: (context, constraints) {
        final avail = constraints.maxHeight;

        // ── Hero ──────────────────────────────────────────────────────
        // Content portion below status bar scales linearly from 130 pt
        // (compact) up to 195 pt (large screen), centered around the
        // iPhone 11 baseline of 156 pt at ~765 pt available height.
        final heroContent =
            (130.0 + (avail - 580.0) * 0.20).clamp(130.0, 195.0);
        final heroH = topPad + heroContent;

        // ── Feed card height ──────────────────────────────────────────
        // Measured heights of every fixed-height section (from render tree):
        //   primary card wrapper (8 top padding + ~156 card)  : 165
        //   SizedBox(6) between primary card and stepper       :   6
        //   JourneyStepperWidget (showTaskCard: false)         :  68
        //   Padding(5) + compact SecondaryActionRow            :  40
        //   CityFeed section label + bottom padding            :  22
        const kFixed = 165.0 + 6.0 + 68.0 + 40.0 + 22.0; // = 301 pt

        // rawRemaining = space available for the feed card + gap above it.
        final rawRemaining = avail - heroH - kFixed;

        // Reserve at least 6 pt for the gap; feed card gets the rest.
        // Lower minimum (110 pt) prevents overflow on compact available
        // heights (e.g. when the location banner is visible on a Pro Max).
        final feedCardH = (rawRemaining - 6.0).clamp(110.0, 178.0);

        // Remainder becomes the breathing gap — guaranteed no overflow.
        final paraGap = (rawRemaining - feedCardH).clamp(4.0, 30.0);

        // ── Typography scale ──────────────────────────────────────────
        // Enable slightly larger text on phones with avail > 760 pt
        // (iPhone 11 / 14 Pro and above).
        final bigScreen = avail > 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. City header — height grows with screen size
            _ActiveHero(
              city: city,
              weather: weather,
              height: heroH,
              onOpenSettings: onOpenSettings,
            ),

            // 2. Primary action card — the single current guide step
            if (guideState.currentItem != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _PrimaryActionCard(
                  item: guideState.currentItem!,
                  phaseName: guideState.phaseName(context),
                  isDark: isDark,
                  bigScreen: bigScreen,
                  onTap: () => onViewAction(guideState.currentItem!),
                ),
              ),

            // 3. Tu Jornada — compact phase stepper + quick-action chips
            const SizedBox(height: 6),
            JourneyStepperWidget(
              plan: plan,
              allItems: guideState.items,
              showTaskCard: false,
              onTapActiveTask: guideState.currentItem != null
                  ? () => onViewAction(guideState.currentItem!)
                  : null,
              onTapSeeMore: guideState.currentItem != null
                  ? () => onViewAction(guideState.currentItem!)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
              child: _SecondaryActionRow(
                onCompare: onCompare,
                onViewCity: onViewCity,
                onNewPlan: onNewPlan,
                compact: true,
              ),
            ),

            // 4. Para Ti — horizontal card carousel (height fills screen)
            SizedBox(height: paraGap),
            CityFeedWidget(
              cityCode: city.id,
              stage: stage,
              locale: locale,
              cardHeight: feedCardH,
            ),
          ],
        );
      },
    );
  }
}

// ─── Primary Action Card ──────────────────────────────────────────────────────
//
// Displays the single current guide step as a prominent card with a phase-tag
// pill, large title, short description, and a full-width CTA button.
// Used by the Focus Mode no-scroll layout.

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.item,
    required this.phaseName,
    required this.isDark,
    required this.onTap,
    this.bigScreen = false,
  });

  final GuideActionItem item;
  final String phaseName;
  final bool isDark;
  final VoidCallback? onTap;
  /// When true, slightly increases title and body font sizes for taller screens.
  final bool bigScreen;

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) =>
      switch (Localizations.localeOf(context).languageCode) {
        'pt' => pt,
        'es' => es,
        _ => en,
      };

  @override
  Widget build(BuildContext context) {
    final phaseTag = item.preArrivalRequired
        ? _localizedText(
            context,
            pt: '✈ Antes de viajar',
            es: '✈ Antes de viajar',
            en: '✈ Before traveling',
          )
        : phaseName;
    final tagColor = item.preArrivalRequired
        ? const Color(0xFFE24B4A)
        : _accentText(context);
    final tagBg = item.preArrivalRequired
        ? (isDark ? const Color(0xFF3D1010) : const Color(0xFFFFF1F2))
        : _badgeBackground(context);
    final tagBorder = item.preArrivalRequired
        ? const Color(0xFFE24B4A).withValues(alpha: 0.35)
        : _badgeBorder(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1825) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phase tag pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagBorder),
            ),
            child: Text(
              phaseTag,
              style: AppTypography.tinyLabel.copyWith(
                fontWeight: FontWeight.w700,
                color: tagColor,
              ),
            ),
          ),
          const SizedBox(height: 9),
          // Title — scales from 15 to 16 sp on tall screens
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: bigScreen ? 16 : 15,
              fontWeight: FontWeight.w800,
              color: _primaryText(context),
              height: 1.25,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Short description — up to 3 lines on tall screens
          Text(
            item.shortDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: bigScreen ? 12.5 : null,
              color: _secondaryText(context),
              height: bigScreen ? 1.5 : 1.4,
              fontWeight: FontWeight.w400,
            ),
            maxLines: bigScreen ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 11),
          // Full-width CTA button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF3B7CC8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                _localizedText(
                  context,
                  pt: 'Fazer agora',
                  es: 'Hacer ahora',
                  en: 'Do it now',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveHero extends StatelessWidget {
  const _ActiveHero({
    required this.city,
    required this.weather,
    required this.height,
    required this.onOpenSettings,
  });

  final City city;
  final CityWeather? weather;
  /// Total hero height in logical pixels, including the top safe-area inset.
  final double height;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final stateLabel = city.stateName.isNotEmpty
        ? city.stateName
        : city.stateCode;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: _HeroCityImage(city: city)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x55000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.45, 1.0],
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
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Color(0x80000000),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$stateLabel, ${context.l10n.countryLabel('brazil')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.65),
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
                    color: Colors.white.withValues(alpha: 0.75),
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

class _SecondaryActionRow extends StatelessWidget {
  const _SecondaryActionRow({
    required this.onCompare,
    required this.onViewCity,
    required this.onNewPlan,
    this.compact = false,
  });

  final VoidCallback onCompare;
  final VoidCallback onViewCity;
  final VoidCallback onNewPlan;
  /// When true renders compact horizontal icon+label chips instead of vertical
  /// icon-over-label chips. Used by the Focus Mode layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.compare_arrows_rounded,
            label: context.l10n.homeActionCompare,
            onTap: onCompare,
            compact: compact,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.location_city_outlined,
            label: context.l10n.homeActionViewCity,
            onTap: onViewCity,
            compact: compact,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.restart_alt_rounded,
            label: context.l10n.homeActionNewPlan,
            onTap: onNewPlan,
            compact: compact,
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
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  /// Compact mode renders a horizontal Row(icon, label) chip with reduced
  /// padding — fits in the Focus Mode "Tu Jornada" quick-actions row.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderFor(context),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: AppColors.textSoftFor(context)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
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

// ─── PF Appointment Nudge ─────────────────────────────────────────────────────

class _PFAppointmentNudge extends StatelessWidget {
  const _PFAppointmentNudge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D0A0A) : const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF7A1F1F) : const Color(0xFFFECACA),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.assignment_late_rounded,
              size: 18,
              color: Color(0xFFE24B4A),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedText(
                      context,
                      pt: 'Agende a Polícia Federal agora',
                      es: 'Saca el turno de la Policía Federal ahora',
                      en: 'Book your Federal Police appointment now',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFE24B4A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _localizedText(
                      context,
                      pt: 'Fila de 60–90 dias em SP e RJ. Agende pelo site antes de embarcar.',
                      es: 'Cola de 60–90 días en SP y RJ. Saca el turno antes de viajar.',
                      en: '60–90 day backlog in SP and RJ. Book online before you board.',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? const Color(0xFFD4716F)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => launchUrl(
                      Uri.parse(
                        'https://www.gov.br/pf/pt-br/assuntos/imigracao/agendamento',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE24B4A),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        _localizedText(
                          context,
                          pt: 'Agendar no site da PF →',
                          es: 'Pedir turno en el sitio de la PF →',
                          en: 'Book on PF website →',
                        ),
                        style: AppTypography.compactBadge.copyWith(
                          color: Colors.white,
                        ),
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
  }

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) =>
      switch (Localizations.localeOf(context).languageCode) {
        'pt' => pt,
        'es' => es,
        _ => en,
      };
}

// ─── Planner Countdown Chip ───────────────────────────────────────────────────

class _PlannerCountdownChip extends StatelessWidget {
  const _PlannerCountdownChip({required this.timeline});

  final String timeline;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final label = _timelineLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3B7CC8) : const Color(0xFF93C5FD),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 13,
            color: isDark ? const Color(0xFF90C4F8) : const Color(0xFF1D4ED8),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.compactBadge.copyWith(
              color:
                  isDark ? const Color(0xFF90C4F8) : const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }

  String _timelineLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (timeline) {
      'in_0_3m' => switch (locale) {
          'pt' => 'Mudança em até 3 meses',
          'es' => 'Mudanza en menos de 3 meses',
          _ => 'Move within 3 months',
        },
      'in_3_6m' => switch (locale) {
          'pt' => 'Mudança em 3–6 meses',
          'es' => 'Mudanza en 3–6 meses',
          _ => 'Move in 3–6 months',
        },
      'in_6_12m' => switch (locale) {
          'pt' => 'Mudança em 6–12 meses',
          'es' => 'Mudanza en 6–12 meses',
          _ => 'Move in 6–12 months',
        },
      _ => switch (locale) {
          'pt' => 'Ainda planejando',
          'es' => 'Todavía planificando',
          _ => 'Still planning',
        },
    };
  }
}

// ─── Explorer Stage Card ──────────────────────────────────────────────────────

class _ExplorerStageCard extends StatelessWidget {
  const _ExplorerStageCard({
    required this.city,
    required this.onCreatePlan,
    this.cityBudget,
  });

  final City city;
  final CityBudget? cityBudget;
  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1825) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.explore_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF90C4F8)
                      : const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _localizedText(
                    context,
                    pt: 'Você está explorando ${city.name}',
                    es: 'Estás explorando ${city.name}',
                    en: 'You\'re exploring ${city.name}',
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _localizedText(
              context,
              pt: 'Antes de decidir, verifique se consegue se sustentar aqui.',
              es: 'Antes de decidir, verifica si puedes sostenerte aquí.',
              en: 'Before deciding, check if you can sustain yourself here.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _affordabilityRow(context),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onCreatePlan,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B7CC8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                _localizedText(
                  context,
                  pt: 'Criar meu plano de migração',
                  es: 'Crear mi plan de migración',
                  en: 'Create my migration plan',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _affordabilityRow(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final budget = cityBudget;

    final rentLabel = budget != null
        ? 'R\$${budget.rent.min}–${budget.rent.max}'
        : 'R\$1.800–3.500';
    final totalLabel = budget != null
        ? 'R\$${budget.leanTotal}–${budget.comfortableTotal}'
        : 'R\$4.000–6.000';

    return Row(
      children: [
        _AffordabilityChip(
          icon: Icons.home_outlined,
          label: _localizedText(
            context,
            pt: 'Aluguel $rentLabel',
            es: 'Alquiler $rentLabel',
            en: 'Rent $rentLabel',
          ),
          isDark: isDark,
        ),
        const SizedBox(width: 6),
        _AffordabilityChip(
          icon: Icons.attach_money_rounded,
          label: _localizedText(
            context,
            pt: 'Total $totalLabel/mês',
            es: 'Total $totalLabel/mes',
            en: 'Total $totalLabel/mo',
          ),
          isDark: isDark,
        ),
      ],
    );
  }

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) =>
      switch (Localizations.localeOf(context).languageCode) {
        'pt' => pt,
        'es' => es,
        _ => en,
      };
}

class _AffordabilityChip extends StatelessWidget {
  const _AffordabilityChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1525) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDark ? const Color(0xFF1A2840) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: AppColors.textSoftFor(context),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.tinyLabel.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pre-arrival Warning Banner ───────────────────────────────────────────────

class _PreArrivalWarningBanner extends StatelessWidget {
  const _PreArrivalWarningBanner({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = count == 1
        ? _localizedText(
            context,
            pt: '1 etapa obrigatória antes de viajar',
            es: '1 etapa obligatoria antes de viajar',
            en: '1 required step before traveling',
          )
        : _localizedText(
            context,
            pt: '$count etapas obrigatórias antes de viajar',
            es: '$count etapas obligatorias antes de viajar',
            en: '$count required steps before traveling',
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1A08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7A3A0A)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.flight_takeoff_rounded,
              size: 16,
              color: Color(0xFFE8873A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFE8873A),
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFFE8873A),
              ),
          ],
        ),
      ),
    );
  }

  static String _localizedText(
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

// ─── Budget Quick-Access Card ─────────────────────────────────────────────────

class _BudgetQuickAccessCard extends StatelessWidget {
  const _BudgetQuickAccessCard({
    required this.locale,
    required this.onTap,
  });

  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1829) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF1A2840) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A5F)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calculate_outlined,
                size: 18,
                color: Color(0xFF3B7CC8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(locale),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  Text(
                    _subtitle(locale),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? const Color(0xFF3B7CC8)
                  : const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  String _title(String locale) => switch (locale) {
        'pt' => 'Calcule seu orçamento',
        'es' => 'Calcula tu presupuesto',
        _ => 'Calculate your budget',
      };

  String _subtitle(String locale) => switch (locale) {
        'pt' => 'Quanto você precisa para os primeiros 30–90 dias',
        'es' => 'Cuanto necesitas para los primeros 30–90 dias',
        _ => 'How much you need for the first 30–90 days',
      };
}

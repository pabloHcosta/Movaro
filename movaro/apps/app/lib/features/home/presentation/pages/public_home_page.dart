import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/presentation/pages/journey_setup_page.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/presentation/widgets/origin_city_flow_sheet.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_conflict_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/home_visual_layout.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_focus_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_identity.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/city_feed_widget.dart';
import 'package:movaro_app/features/home/presentation/widgets/journey_stepper_widget.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_personalization_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({
    required this.cityInsightsController,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
    required this.environment,
    this.redirectMessage,
    super.key,
  });

  final CitiesController citiesController;
  final CityInsightController cityInsightsController;
  final AppEnvironment environment;
  final JourneyContextController journeyContextController;
  final LocationController locationController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  /// When the router silently redirected to this page, this message is shown
  /// as a floating snackbar on the first frame so the user understands why.
  final String? redirectMessage;

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage>
    with WidgetsBindingObserver, RouteAware {
  // Stage transition tracking — used to show a one-time celebration modal
  // when the user advances from explorer → planner or planner → executor.
  bool _isFirstPlanLoad = true;

  String? _loadedPlanKey;
  String? _loadedWeatherCityId;
  int _prevCompletedCount = 0;
  String _prevTimeline = '';
  MigrationCopilotProgressSnapshot _progressSnapshot =
      const MigrationCopilotProgressSnapshot();

  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();

  ModalRoute<dynamic>? _route;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshProgress());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == null || identical(route, _route)) {
      return;
    }
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    _route = route;
    appRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    unawaited(_syncPlanState());
    unawaited(_refreshProgress());
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    widget.journeyContextController.removeListener(_handleControllerUpdate);
    widget.migrationQuestionnaireController.removeListener(
      _handleControllerUpdate,
    );
    widget.citiesController.removeListener(_handleControllerUpdate);
    super.dispose();
  }

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
      final msg = widget.redirectMessage;
      if (msg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
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
    final city = plan?.confirmedCity;

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
    final isFreshPlanLoad = _loadedPlanKey != planKey;

    final snapshot = await _progressStore.read(plan);
    if (!mounted) {
      return;
    }

    setState(() {
      _loadedPlanKey = planKey;
      _progressSnapshot = snapshot;
    });
    final currentItem = _buildGuideState(plan, snapshot).currentItem;
    unawaited(
      PlanNotificationService.instance
          .scheduleContextualResumeReminder(
            plan: plan,
            currentItem: currentItem,
          )
          .catchError((_) {}),
    );

    // ── Stage transition detection ───────────────────────────────────────
    // Skip on the very first load (user already in that state, not advancing).
    if (isFreshPlanLoad && !_isFirstPlanLoad) {
      final newCount = snapshot.completedItemsCount;
      final newTimeline = plan.timeline;
      final wasExplorer =
          _prevTimeline.isEmpty ||
          _prevTimeline == 'later' ||
          _prevTimeline == 'undecided';
      final nowPlanner = newTimeline == 'in_3_6m' || newTimeline == 'in_6_12m';
      final nowExecutor =
          newTimeline == 'in_0_3m' || newCount > _prevCompletedCount;

      if (_prevCompletedCount == 0 && newCount > 0) {
        // First step completed → executor mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showStageTransitionSheet(UserJourneyStage.executor);
        });
      } else if (wasExplorer && nowPlanner && !nowExecutor) {
        // Timeline committed → planner mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showStageTransitionSheet(UserJourneyStage.planner);
        });
      }
      _prevCompletedCount = newCount;
      _prevTimeline = newTimeline;
    } else if (isFreshPlanLoad) {
      _isFirstPlanLoad = false;
      _prevCompletedCount = snapshot.completedItemsCount;
      _prevTimeline = plan.timeline;
    }

    if (isFreshPlanLoad) {
      final locale = Localizations.localeOf(context).languageCode;
      final compareTo = plan.reviewCities
          .where((candidate) => candidate.id != city.id)
          .map((candidate) => candidate.id)
          .take(2)
          .toList(growable: false);

      unawaited(
        widget.cityInsightsController.load(
          cityId: city.id,
          goal: plan.goal,
          timeline: plan.timeline,
          locale: locale,
        ),
      );
      unawaited(
        widget.citiesController.loadCityDetailSocialProof(
          city.id,
          locale: locale,
          goal: plan.goal,
          timeline: plan.timeline,
        ),
      );
      unawaited(
        widget.citiesController.loadCityDetailClimateSummary(
          city.id,
          locale: locale,
        ),
      );
      unawaited(
        widget.citiesController.loadCityDetailArrivalStory(
          city.id,
          locale: locale,
          goal: plan.goal,
          timeline: plan.timeline,
        ),
      );
      if (compareTo.isNotEmpty) {
        unawaited(
          widget.citiesController.loadCityDetailComparison(
            city.id,
            compareTo: compareTo,
            locale: locale,
          ),
        );
      }
    }
  }

  Future<void> _startPlanFlow() async {
    final hasOriginCity = await _confirmOriginCity();
    if (!hasOriginCity || !mounted) {
      return;
    }
    await widget.migrationQuestionnaireController.initializeForQuestionnaire(
      variant: QuestionnaireVariant.lean,
    );
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
  }

  Future<void> _startKnownCityFlow() async {
    final hasOriginCity = await _confirmOriginCity();
    if (!hasOriginCity || !mounted) {
      return;
    }
    await widget.journeyContextController.initialize();
    final journey = widget.journeyContextController;

    if (journey.isJourneyReadyForPlanning) {
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(context, AppRoutes.citiesSearch);
      return;
    }

    final destinations = journey.availableDestinations
        .where((country) => country.coverage.canPlanAsDestination)
        .toList(growable: false);
    final origins = journey.availableOrigins
        .where((country) => country.coverage.canPlanAsOrigin)
        .toList(growable: false);

    if (destinations.length == 1) {
      final destination = destinations.first;
      final compatibleOrigins = origins
          .where(
            (origin) => origin.coverage.supportsDestination(destination.id),
          )
          .toList(growable: false);

      if (compatibleOrigins.length == 1) {
        await journey.completeJourney(
          originCountryId: compatibleOrigins.first.id,
          destinationCountryId: destination.id,
        );
        if (!mounted) {
          return;
        }
        Navigator.pushNamed(context, AppRoutes.citiesSearch);
        return;
      }
    }

    if (!mounted) {
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.journeySetup,
      arguments: const JourneySetupPageArgs(
        continueRoute: AppRoutes.citiesSearch,
      ),
    );
  }

  Future<bool> _confirmOriginCity() async {
    await widget.journeyContextController.initialize();
    if (!mounted) return false;

    final confirmed = await showOriginCityFlowSheet(
      context: context,
      locationController: widget.locationController,
    );
    if (!confirmed || !mounted) return false;

    await widget.journeyContextController.completeJourney(
      originCountryId: 'argentina',
      destinationCountryId: 'brasil',
    );
    return true;
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
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
          ?.currentPlanCity
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
      Navigator.pushNamed(context, AppRoutes.publicHome);
    }
  }

  _HomeGuideState _buildGuideState(
    MigrationPlan plan,
    MigrationCopilotProgressSnapshot snapshot,
  ) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final explicitCompletedIds = snapshot.getAllCompletedIds();
    final items =
        GuidePersonalizationService.personalize(
            plan: plan,
            items: MigrationGuideRegistry.build(
              l10n: context.l10n,
              plan: plan,
              currentLocation: widget.locationController.savedLocation,
              localeCode: localeCode,
              completedIds: explicitCompletedIds,
            ),
            explicitCompletedIds: explicitCompletedIds,
            explicitDismissedReasons: snapshot.dismissedReasonsById,
            localeCode: localeCode,
          ).toList(growable: false)
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final completedIds = items
        .where((item) => item.isCompleted)
        .map((item) => item.id)
        .toSet();
    final focus = GuideFocusEngine.build(
      plan: plan,
      items: items,
      activeItemId: snapshot.activeItemId,
    );
    final currentItem = focus.current;

    final currentPhaseIndex = currentItem == null
        ? GuidePhase.values.length
        : GuidePhase.values.indexOf(currentItem.phase) + 1;

    return _HomeGuideState(
      items: items,
      completedIds: completedIds,
      currentItem: currentItem,
      completedCount: focus.coreCompletedCount,
      totalItems: focus.coreTotalCount,
      progressPercent: focus.coreProgressPercent,
      currentPhaseIndex: currentPhaseIndex,
      totalPhases: GuidePhase.values.length,
    );
  }

  /// Force-refreshes the progress snapshot from disk (e.g. after returning
  /// from the guide page where the user may have completed items).
  Future<void> _refreshProgress() async {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    if (plan == null) return;

    final snapshot = await _progressStore.read(plan);
    if (!mounted) return;

    setState(() {
      _progressSnapshot = snapshot;
    });
  }

  void _showStageTransitionSheet(UserJourneyStage newStage) {
    final locale = Localizations.localeOf(context).languageCode;

    final (icon, title, body, action) = switch (newStage) {
      UserJourneyStage.executor => (
        Icons.rocket_launch_rounded,
        switch (locale) {
          'pt' => '🚀 Você entrou no modo execução!',
          'es' => '🚀 ¡Entraste en modo ejecución!',
          _ => '🚀 You\'re in execution mode!',
        },
        switch (locale) {
          'pt' =>
            'Seu primeiro passo está concluído. O guia agora acompanha cada etapa da sua mudança em tempo real.',
          'es' =>
            'Tu primer paso está completado. La guía ahora sigue cada etapa de tu mudanza en tiempo real.',
          _ =>
            'Your first step is done. The guide now tracks every step of your move in real time.',
        },
        switch (locale) {
          'pt' =>
            'Continue — cada passo que você conclui desbloqueia o próximo.',
          'es' => 'Seguí — cada paso que completás desbloquea el siguiente.',
          _ => 'Keep going — every step you complete unlocks the next.',
        },
      ),
      UserJourneyStage.planner => (
        Icons.calendar_month_rounded,
        switch (locale) {
          'pt' => '📅 Você está no modo planejamento!',
          'es' => '📅 ¡Estás en modo planificación!',
          _ => '📅 You\'re in planning mode!',
        },
        switch (locale) {
          'pt' =>
            'Você definiu sua janela de mudança. O guia vai te ajudar a se preparar nos próximos meses.',
          'es' =>
            'Definiste tu ventana de mudanza. La guía te ayudará a prepararte en los próximos meses.',
          _ =>
            'You\'ve set your move window. The guide will help you prepare over the coming months.',
        },
        switch (locale) {
          'pt' =>
            'Comece pelos documentos — alguns levam semanas para ficarem prontos.',
          'es' =>
            'Empezá por los documentos — algunos tardan semanas en estar listos.',
          _ => 'Start with documents — some take weeks to be ready.',
        },
      ),
      _ => (
        Icons.explore_rounded,
        switch (locale) {
          'pt' => '🗺️ Você está explorando!',
          'es' => '🗺️ ¡Estás explorando!',
          _ => '🗺️ You\'re exploring!',
        },
        switch (locale) {
          'pt' => 'Compare cidades e descubra onde você quer viver.',
          'es' => 'Comparás ciudades y descubrís dónde querés vivir.',
          _ => 'Compare cities and discover where you want to live.',
        },
        switch (locale) {
          'pt' => 'Quando decidir, crie seu plano personalizado.',
          'es' => 'Cuando decidas, creá tu plan personalizado.',
          _ => 'When you decide, create your personalized plan.',
        },
      ),
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (sheetCtx) {
        final isDark = AppColors.isDark(sheetCtx);
        final accent = switch (newStage) {
          UserJourneyStage.executor => AppColors.success,
          UserJourneyStage.planner => AppColors.primary,
          _ => AppColors.caution,
        };
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(sheetCtx),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderFor(sheetCtx)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 26, color: accent),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryFor(sheetCtx),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(sheetCtx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoftFor(sheetCtx),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action,
                    style: Theme.of(sheetCtx).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: Text(switch (locale) {
                        'pt' => 'Entendido!',
                        'es' => '¡Entendido!',
                        _ => 'Got it!',
                      }),
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

  String _planKey(MigrationPlan plan) {
    return MigrationPlanIdentity.storageKeyFor(plan);
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
              final city = plan?.confirmedCity;
              final hasActivePlan = city != null;
              final hasPlanDraft = plan != null && city == null;
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
                                      citiesController: widget.citiesController,
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
                                  : hasPlanDraft
                                  ? _PlannerHomeState(
                                      key: const ValueKey('planner-home'),
                                      plan: plan,
                                      citiesController: widget.citiesController,
                                      onContinuePlan: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.migrationResultReveal,
                                      ),
                                      onCompareCities: () {
                                        final candidates = plan.reviewCities;
                                        if (candidates.isEmpty) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) => CityComparisonScreen(
                                              initialCities: candidates
                                                  .take(3)
                                                  .toList(),
                                              citiesController:
                                                  widget.citiesController,
                                              migrationQuestionnaireController:
                                                  widget
                                                      .migrationQuestionnaireController,
                                            ),
                                          ),
                                        );
                                      },
                                      onBrowseCities: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.cities,
                                      ),
                                    )
                                  : _EmptyHomeState(
                                      key: const ValueKey('empty-home'),
                                      onDiscoverDirectionTap: () =>
                                          _startPlanFlow(),
                                      onKnownCityTap: () =>
                                          _startKnownCityFlow(),
                                      onExploreCitiesTap: () =>
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.cities,
                                          ),
                                      onOpenCostsTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.documentationTopic,
                                        arguments:
                                            DocumentationGuideSection.costs,
                                      ),
                                      onOpenDocumentsTap: () =>
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.documentationGuide,
                                          ),
                                      onOpenHousingTap: () =>
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.documentationTopic,
                                            arguments: DocumentationGuideSection
                                                .housing,
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
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({
    required this.onDiscoverDirectionTap,
    required this.onKnownCityTap,
    required this.onExploreCitiesTap,
    required this.onOpenCostsTap,
    required this.onOpenDocumentsTap,
    required this.onOpenHousingTap,
    super.key,
  });

  final VoidCallback onDiscoverDirectionTap;
  final VoidCallback onExploreCitiesTap;
  final VoidCallback onKnownCityTap;
  final VoidCallback onOpenHousingTap;
  final VoidCallback onOpenCostsTap;
  final VoidCallback onOpenDocumentsTap;

  @override
  Widget build(BuildContext context) {
    return HomeVisualLayout(
      onDiscoverDirectionTap: onDiscoverDirectionTap,
      onKnownCityTap: onKnownCityTap,
      onExploreCitiesTap: onExploreCitiesTap,
      onOpenCostsTap: onOpenCostsTap,
      onOpenDocumentsTap: onOpenDocumentsTap,
      onOpenHousingTap: onOpenHousingTap,
    );
  }
}

// ─── Planner Home State ───────────────────────────────────────────────────────
//
// Shown when the user has completed the questionnaire (plan exists) but has
// NOT yet confirmed a destination city. Bridges the gap between
// _EmptyHomeState and _ActiveHomeState.
//
// Prompt: "Você tem um plano — agora escolha sua cidade."
// CTAs: Compare candidate cities · Continue to reveal · Browse all cities

class _PlannerHomeState extends StatelessWidget {
  const _PlannerHomeState({
    required this.plan,
    required this.citiesController,
    required this.onContinuePlan,
    required this.onCompareCities,
    required this.onBrowseCities,
    super.key,
  });

  final CitiesController citiesController;
  final VoidCallback onBrowseCities;
  final VoidCallback onCompareCities;
  final VoidCallback onContinuePlan;
  final MigrationPlan plan;

  static String _t(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final candidates = plan.reviewCities.take(3).toList(growable: false);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 24,
        16,
        96,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stage badge ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3B7CC8)
                    : const Color(0xFF93C5FD),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_rounded,
                  size: 13,
                  color: isDark
                      ? const Color(0xFF90C4F8)
                      : const Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 5),
                Text(
                  _t(
                    context,
                    pt: 'Escolhendo cidade',
                    es: 'Eligiendo ciudad',
                    en: 'Choosing city',
                  ),
                  style: AppTypography.compactBadge.copyWith(
                    color: isDark
                        ? const Color(0xFF90C4F8)
                        : const Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // ── Headline ─────────────────────────────────────────────────────
          Text(
            _t(
              context,
              pt: 'Seu plano está pronto.\nAgora escolha sua cidade.',
              es: 'Tu plan está listo.\nAhora elige tu ciudad.',
              en: 'Your plan is ready.\nNow choose your city.',
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t(
              context,
              pt: 'Compare as cidades recomendadas e confirme onde vai morar.',
              es: 'Compara las ciudades recomendadas y confirma donde vas a vivir.',
              en: 'Compare recommended cities and confirm where you\'ll live.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // ── Primary CTA ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCompareCities,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: Text(
                _t(
                  context,
                  pt: 'Ver cidades recomendadas',
                  es: 'Ver ciudades recomendadas',
                  en: 'See recommended cities',
                ),
              ),
            ),
          ),
          if (candidates.length >= 2) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onContinuePlan,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _t(
                    context,
                    pt: 'Ver cidade em destaque no momento',
                    es: 'Ver ciudad destacada por ahora',
                    en: 'See the city highlighted right now',
                  ),
                ),
              ),
            ),
          ],
          // ── Candidate city chips ──────────────────────────────────────────
          if (candidates.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              _t(
                context,
                pt: 'Candidatas para você',
                es: 'Candidatas para ti',
                en: 'Your candidates',
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < candidates.length; index++) ...[
              _CandidateCityTile(
                city: candidates[index],
                rank: index + 1,
                matchScore: plan.candidateCityMatchScores[candidates[index].id],
                isDark: isDark,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cityDetail(candidates[index].id),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          // ── Browse all link ───────────────────────────────────────────────
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: onBrowseCities,
              icon: const Icon(Icons.location_city_outlined, size: 16),
              label: Text(
                _t(
                  context,
                  pt: 'Explorar outras cidades',
                  es: 'Explorar otras ciudades',
                  en: 'Explore other cities',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateCityTile extends StatelessWidget {
  const _CandidateCityTile({
    required this.city,
    required this.rank,
    required this.isDark,
    required this.onTap,
    this.matchScore,
  });

  final City city;
  final bool isDark;
  final double? matchScore;
  final VoidCallback onTap;
  final int rank;

  static String _t(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  @override
  Widget build(BuildContext context) {
    final matchPct = matchScore == null
        ? null
        : (matchScore! * 100).round().clamp(0, 100);
    final subtitle = matchPct == null
        ? _t(
            context,
            pt: '${city.stateName} · $rankª mais indicada para o seu plano',
            es: '${city.stateName} · $rankª más indicada para tu plan',
            en: '${city.stateName} · #$rank for your plan',
          )
        : _t(
            context,
            pt: '${city.stateName} · $matchPct% de encaixe no seu plano',
            es: '${city.stateName} · $matchPct% de encaje con tu plan',
            en: '${city.stateName} · $matchPct% plan fit',
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E1825) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSoftFor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveHomeState extends StatelessWidget {
  const _ActiveHomeState({
    required this.city,
    required this.weather,
    required this.citiesController,
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

  final CitiesController citiesController;
  final City city;
  final CityInsightController cityInsightsController;
  final _HomeGuideState guideState;
  final VoidCallback onCompare;
  final VoidCallback onNewPlan;
  final VoidCallback onOpenSettings;
  final ValueChanged<GuideActionItem> onViewAction;
  final VoidCallback onViewCity;
  final MigrationPlan plan;
  final String planGoal;
  final String planTimeline;
  final List<String> recommendationReasons;
  final CityWeather? weather;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final socialProofKey = citiesController.cityDetailContextKey(
      city.id,
      locale: locale,
      goal: planGoal,
      timeline: planTimeline,
    );
    final climateKey = citiesController.cityDetailContextKey(
      city.id,
      locale: locale,
    );
    final arrivalKey = citiesController.cityDetailContextKey(
      city.id,
      locale: locale,
      goal: planGoal,
      timeline: planTimeline,
    );
    final compareTo = plan.reviewCities
        .where((candidate) => candidate.id != city.id)
        .map((candidate) => candidate.id)
        .take(2)
        .toList(growable: false);
    final comparisonKey = compareTo.isEmpty
        ? null
        : citiesController.cityDetailComparisonKey(
            city.id,
            compareTo: compareTo,
            locale: locale,
          );
    final socialProof = citiesController.socialProofFor(socialProofKey);
    final climateSummary = citiesController.climateSummaryFor(climateKey);
    final arrivalStory = citiesController.arrivalStoryFor(arrivalKey);
    final comparison = comparisonKey == null
        ? null
        : citiesController.comparisonFor(comparisonKey);
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
        final heroContent = (130.0 + (avail - 580.0) * 0.20).clamp(
          130.0,
          195.0,
        );
        final heroH = topPad + heroContent;

        // ── Typography scale ──────────────────────────────────────────
        // Enable slightly larger text on phones with avail > 760 pt
        // (iPhone 11 / 14 Pro and above).
        final bigScreen = avail > 760;

        // ── Computed per-stage flags ──────────────────────────────────────
        final residenciaComplete =
            guideState.completedIds.contains('item_2_1_cpf') &&
            guideState.completedIds.contains('item_2_2_residencia');
        final pfItem = guideState.items.cast<GuideActionItem?>().firstWhere(
          (item) => item?.id == 'item_2_2_residencia',
          orElse: () => null,
        );
        final pfUnlocked =
            pfItem != null &&
            pfItem.dependencies.every(guideState.completedIds.contains);
        final currentPhase = guideState.currentItem?.phase;
        final showPFNudge =
            !residenciaComplete &&
            stage != UserJourneyStage.explorer &&
            pfUnlocked &&
            (guideState.currentItem?.id == 'item_2_2_residencia' ||
                currentPhase == GuidePhase.documents);
        final preArrivalCount = guideState.items
            .where(
              (it) =>
                  it.preArrivalRequired &&
                  !guideState.completedIds.contains(it.id),
            )
            .length;
        final showPreArrivalWarning =
            !showPFNudge &&
            stage == UserJourneyStage.executor &&
            preArrivalCount > 0;

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. PF Appointment Nudge — shown for planner/executor stages
                    //    before residência is complete. Highest-impact failure point.
                    if (showPFNudge)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _PFAppointmentNudge(city: city),
                      ),

                    // 3. Explorer stage: affordability card replaces action card
                    if (stage == UserJourneyStage.explorer) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _ExplorerStageCard(
                          city: city,
                          cityBudget: null,
                          onCreatePlan: () => Navigator.pushNamed(
                            context,
                            AppRoutes.migrationQuestionnaire,
                          ),
                        ),
                      ),
                    ] else ...[
                      // 4. Primary action card — the single current guide step
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
                    ],

                    // 5. Seasonality conflict warning (only for critical timing)
                    if (!showPFNudge && !showPreArrivalWarning)
                      _SeasonalityConflictBanner(
                        city: city,
                        planTimeline: planTimeline,
                      ),

                    // 6. Pre-arrival warning banner — executor stage, pending steps
                    if (showPreArrivalWarning)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: _PreArrivalWarningBanner(
                          count: preArrivalCount,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.migrationPlanCopilot,
                          ),
                        ),
                      ),

                    // 7. Tu Jornada — compact phase stepper + quick-action chips
                    const SizedBox(height: 6),
                    if (stage == UserJourneyStage.planner)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: _PlannerCountdownChip(timeline: planTimeline),
                      ),
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
                      onTapItem: onViewAction,
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

                    // 8. Para Ti — horizontal card carousel
                    const SizedBox(height: 18),
                    CityFeedWidget(
                      cityCode: city.id,
                      stage: stage,
                      locale: locale,
                      city: city,
                      weather: weather,
                      socialProof: socialProof,
                      climateSummary: climateSummary,
                      arrivalStory: arrivalStory,
                      comparison: comparison,
                      guideCurrentItem: guideState.currentItem,
                      cardHeight: 118,
                      onOpenGuideItem: (guideItemId) => Navigator.pushNamed(
                        context,
                        AppRoutes.migrationPlanCopilot,
                        arguments: guideItemId == null
                            ? null
                            : <String, dynamic>{
                                'focusGuideItemId': guideItemId,
                              },
                      ),
                    ),
                  ],
                ),
              ),
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

  /// When true, slightly increases title and body font sizes for taller screens.
  final bool bigScreen;

  final bool isDark;
  final GuideActionItem item;
  final VoidCallback? onTap;
  final String phaseName;

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
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
    final nextStepLabel = _localizedText(
      context,
      pt: 'PRÓXIMO PASSO',
      es: 'PRÓXIMO PASO',
      en: 'NEXT STEP',
    );
    final timeLabel = item.estimatedTimeLabel ?? item.estimatedTime;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF111F30), Color(0xFF0B1522)]
                  : const [Colors.white, Color(0xFFF4F9FF)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tagColor.withValues(alpha: isDark ? 0.24 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: tagColor.withValues(alpha: isDark ? 0.09 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tagBorder),
                ),
                child: Icon(item.icon, size: 20, color: tagColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$nextStepLabel  ·  $phaseTag',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tagColor,
                        letterSpacing: 0.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: bigScreen ? 17 : 16,
                        fontWeight: FontWeight.w800,
                        color: _primaryText(context),
                        height: 1.2,
                        letterSpacing: -0.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.shortDescription,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  color: _secondaryText(context),
                                  height: 1.3,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeLabel != null && timeLabel.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: _secondaryText(context),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              timeLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: _secondaryText(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF168BFF), Color(0xFF15B8FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF168BFF).withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _localizedText(
                        context,
                        pt: 'Abrir',
                        es: 'Abrir',
                        en: 'Open',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  /// Total hero height in logical pixels, including the top safe-area inset.
  final double height;

  final VoidCallback onOpenSettings;
  final CityWeather? weather;

  @override
  Widget build(BuildContext context) {
    final stateLabel = city.stateName.isNotEmpty
        ? city.stateName
        : city.stateCode;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.045, end: 1),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, scale, image) =>
                    Transform.scale(scale: scale, child: image),
                child: _HeroCityImage(city: city),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.50),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.34, 0.68, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.34),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.72],
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
                  color: Colors.black.withValues(alpha: 0.28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.l10n.stageExecutionTitle,
                      style: AppTypography.compactBadge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.92),
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
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    city.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                      color: Colors.white,
                      height: 1.02,
                      shadows: const [
                        Shadow(blurRadius: 14, color: Color(0x99000000)),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _HeroMetaChip(
                        icon: Icons.location_on_outlined,
                        label:
                            '$stateLabel, ${context.l10n.countryLabel(city.countryCode)}',
                      ),
                      _HeroMetaChip(
                        icon: weather == null
                            ? Icons.cloud_outlined
                            : Icons.wb_sunny_outlined,
                        label: weather == null
                            ? '--'
                            : '${weather!.temperatureCelsius.round()}°C',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.72)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w600,
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

  final bool compact;
  final VoidCallback onCompare;
  final VoidCallback onNewPlan;
  final VoidCallback onViewCity;

  Future<bool?> _showPlanOptionsSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.68),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = AppColors.isDark(sheetContext);
        final border = AppColors.borderFor(sheetContext);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(sheetContext),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.46 : 0.14),
                blurRadius: 40,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSoftFor(
                      sheetContext,
                    ).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF238BFF), Color(0xFF0068E8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sheetContext.l10n.planMenuTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimaryFor(sheetContext),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          sheetContext.l10n.planMenuSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSoftFor(sheetContext),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: sheetContext.l10n.planResetCancelLabel,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSoftFor(sheetContext),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(sheetContext).pop(true);
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tintedSurfaceFor(
                        sheetContext,
                        tint: AppColors.primary,
                        lightColor: const Color(0xFFF1F7FF),
                        darkAlpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.tintedBorderFor(
                          sheetContext,
                          tint: AppColors.primary,
                          lightColor: const Color(0xFFBCD8FF),
                          darkAlpha: 0.32,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: isDark ? 0.22 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.restart_alt_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sheetContext.l10n.homeActionNewPlan,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimaryFor(sheetContext),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sheetContext.l10n.planMenuNewPlanBody,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSoftFor(sheetContext),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 17,
                    color: AppColors.textSoftFor(sheetContext),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sheetContext.l10n.planMenuSafetyNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(sheetContext),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.location_city_outlined,
            label: context.l10n.homeActionViewCity,
            onTap: onViewCity,
            compact: compact,
            emphasized: true,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.compare_arrows_rounded,
            label: context.l10n.homeActionCompare,
            onTap: onCompare,
            compact: compact,
          ),
        ),
        const SizedBox(width: 7),
        Semantics(
          button: true,
          label: context.l10n.planMenuTitle,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                HapticFeedback.selectionClick();
                final shouldStartNewPlan = await _showPlanOptionsSheet(context);
                if (shouldStartNewPlan == true) {
                  onNewPlan();
                }
              },
              child: Ink(
                width: 42,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderFor(context),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ),
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
    this.emphasized = false,
  });

  /// Compact mode renders a horizontal Row(icon, label) chip with reduced
  /// padding — fits in the Focus Mode "Tu Jornada" quick-actions row.
  final bool compact;

  final bool emphasized;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              gradient: emphasized
                  ? LinearGradient(
                      colors: AppColors.isDark(context)
                          ? const [Color(0xFF152B42), Color(0xFF102238)]
                          : const [Color(0xFFEAF5FF), Color(0xFFF4FAFF)],
                    )
                  : null,
              color: emphasized ? null : AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: emphasized
                    ? AppColors.primary.withValues(alpha: 0.28)
                    : AppColors.borderFor(context),
                width: emphasized ? 0.8 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: emphasized
                      ? AppColors.primary
                      : AppColors.textSoftFor(context),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: emphasized
                          ? AppColors.primary
                          : AppColors.textPrimaryFor(context),
                      fontWeight: emphasized
                          ? FontWeight.w700
                          : FontWeight.w600,
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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

  final int completedCount;
  final Set<String> completedIds;
  final GuideActionItem? currentItem;
  final int currentPhaseIndex;
  final List<GuideActionItem> items;
  final int progressPercent;
  final int totalItems;
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
  const _PFAppointmentNudge({required this.city});

  final City city;

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final contact = PreparationResourceLinks.resolvePfUnitContact(city);
    return Container(
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
                    pt: 'Confira cedo a etapa da Polícia Federal',
                    es: 'Revisa temprano la etapa de la Policía Federal',
                    en: 'Review the Federal Police step early',
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
                    pt: 'Confirme primeiro a base legal da sua residência. Para argentinos elegíveis, o acordo bilateral pode permitir residência permanente direta; agendar cedo é apenas uma recomendação prática.',
                    es: 'Confirmá primero la base legal de tu residencia. Para argentinos elegibles, el acuerdo bilateral puede permitir residencia permanente directa; agendar temprano es solo una recomendación práctica.',
                    en: 'Confirm the legal basis for residence first. Eligible Argentines may qualify for direct permanent residence under the bilateral agreement; booking early is only practical guidance.',
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
                    PreparationResourceLinks.pfScheduling,
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
                        pt: 'Abrir agenda oficial da PF →',
                        es: 'Abrir agenda oficial de la PF →',
                        en: 'Open official PF booking →',
                      ),
                      style: AppTypography.compactBadge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                    contact?.buildMailtoUri(city) ??
                        PreparationResourceLinks.pfUnitDirectory,
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    contact == null
                        ? _localizedText(
                            context,
                            pt: 'Sem vaga? abra a lista oficial da unidade responsável →',
                            es: '¿Sin turno? abre la lista oficial de la unidad responsable →',
                            en: 'No slots? open the official responsible-unit list →',
                          )
                        : _localizedText(
                            context,
                            pt: 'Sem vaga? falar com ${contact.label} (${contact.email}) →',
                            es: '¿Sin turno? hablar con ${contact.label} (${contact.email}) →',
                            en: 'No slots? contact ${contact.label} (${contact.email}) →',
                          ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? const Color(0xFFF6B6B4)
                          : const Color(0xFF991B1B),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _localizedText(
                    context,
                    pt: 'A agenda é nacional. Se não aparecer horário, a unidade migratória da sua cidade orienta o próximo passo.',
                    es: 'La agenda es nacional. Si no aparece turno, la unidad migratoria de tu ciudad indica el siguiente paso.',
                    en: 'The booking portal is national. If no slot appears, the migration unit for your city can guide the next step.',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFD4716F)
                        : const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w400,
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

// ─── Planner Countdown Chip ───────────────────────────────────────────────────

class _PlannerCountdownChip extends StatelessWidget {
  const _PlannerCountdownChip({required this.timeline});

  final String timeline;

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
              color: isDark ? const Color(0xFF90C4F8) : const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
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
  final CityBudgetSnapshot? cityBudget;
  final VoidCallback onCreatePlan;

  Widget _affordabilityRow(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final budget = cityBudget;

    final locale = Localizations.localeOf(context).toString();
    final rentLabel = budget != null
        ? MultiCurrencyAmount.formatRangeFromBrl(
            context: context,
            minBrl: budget.planningRentLow,
            maxBrl: budget.planningRentHigh,
            primaryLocale: locale,
          )
        : MultiCurrencyAmount.formatRangeFromBrl(
            context: context,
            minBrl: 1800,
            maxBrl: 3500,
            primaryLocale: locale,
          );
    final totalLabel = budget != null
        ? MultiCurrencyAmount.formatRangeFromBrl(
            context: context,
            minBrl: budget.fairLivingTotal,
            maxBrl: budget.wellLivingTotal,
            primaryLocale: locale,
          )
        : MultiCurrencyAmount.formatRangeFromBrl(
            context: context,
            minBrl: 4000,
            maxBrl: 6000,
            primaryLocale: locale,
          );

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
            pt: 'Viver justo/bem $totalLabel',
            es: 'Vivir justo/bien $totalLabel',
            en: 'Live fair/well $totalLabel',
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
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

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
}

class _AffordabilityChip extends StatelessWidget {
  const _AffordabilityChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final bool isDark;
  final String label;

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
          Icon(icon, size: 11, color: AppColors.textSoftFor(context)),
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

// ─── Seasonality Conflict Banner ──────────────────────────────────────────────
//
// Shown on the home screen between the primary action card and the journey
// stepper when the user's planned arrival months overlap with their confirmed
// city's peak tourist season.
//
// Only renders for CRITICAL conflicts (2+ overlap months, high-severity city).
// Caution-level conflicts are less alarming and are surfaced in the city detail
// page instead.

class _SeasonalityConflictBanner extends StatelessWidget {
  const _SeasonalityConflictBanner({
    required this.city,
    required this.planTimeline,
  });

  final City city;
  final String planTimeline;

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) => switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  @override
  Widget build(BuildContext context) {
    final conflict = CitySeasonalityConflictService.evaluate(
      city: city,
      timeline: planTimeline,
    );

    // Only surface critical conflicts on the home screen
    if (conflict == null ||
        conflict.level != SeasonalityConflictLevel.critical) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context).languageCode;
    final overlapLabel = conflict.overlapLabel(locale);
    final headline = _localizedText(
      context,
      pt: '⚠ Chegada na alta temporada — $overlapLabel',
      es: '⚠ Llegada en temporada alta — $overlapLabel',
      en: '⚠ Arrival during peak season — $overlapLabel',
    );
    final body = _localizedText(
      context,
      pt: 'Garanta moradia antes de embarcar. Preços explodem na alta temporada.',
      es: 'Asegura vivienda antes de embarcar. Los precios explotan en temporada alta.',
      en: 'Secure housing before you travel. Prices spike during peak season.',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF3D0A0A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD32F2F)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Color(0xFFFF5252),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFFF5252),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF8A80),
                      fontSize: 11,
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
}

// ─── Pre-arrival Warning Banner ───────────────────────────────────────────────

class _PreArrivalWarningBanner extends StatelessWidget {
  const _PreArrivalWarningBanner({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

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
}

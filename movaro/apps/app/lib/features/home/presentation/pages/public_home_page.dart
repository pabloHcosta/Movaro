import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/core/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';

enum HomeHeroState { noPlan, withPlan }

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final LocationController locationController;

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();
  MigrationCopilotProgressSnapshot _progressSnapshot =
      const MigrationCopilotProgressSnapshot();
  String? _loadedPlanKey;
  String? _loadedWeatherCityId;
  bool _didTryPromptLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybePromptLocationPermission());
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.isDesktopLayout ? 1160.0 : 920.0;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                widget.journeyContextController,
                widget.migrationQuestionnaireController,
                widget.citiesController,
              ]),
              builder: (context, _) {
                unawaited(_syncPlanHeroState());
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 24,
                      ),
                      children: [
                        _LandingHero(
                          journeyContextController:
                              widget.journeyContextController,
                          citiesController: widget.citiesController,
                          migrationQuestionnaireController:
                              widget.migrationQuestionnaireController,
                          locationController: widget.locationController,
                          progressSnapshot: _progressSnapshot,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 0,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }

  Future<void> _syncPlanHeroState() async {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final confirmedCity = plan?.isCityConfirmed == true
        ? plan?.recommendedCity
        : null;

    if (plan == null || confirmedCity == null) {
      if (_loadedPlanKey != null ||
          _progressSnapshot.readinessCompletedIds.isNotEmpty ||
          _progressSnapshot.documentCompletedIds.isNotEmpty ||
          _progressSnapshot.arrivalCompletedIds.isNotEmpty) {
        setState(() {
          _loadedPlanKey = null;
          _loadedWeatherCityId = null;
          _progressSnapshot = const MigrationCopilotProgressSnapshot();
        });
      }
      return;
    }

    if (_loadedWeatherCityId != confirmedCity.id) {
      _loadedWeatherCityId = confirmedCity.id;
      unawaited(widget.citiesController.loadWeatherForCity(confirmedCity.id));
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

class _LandingHero extends StatelessWidget {
  const _LandingHero({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
    required this.progressSnapshot,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final LocationController locationController;
  final MigrationCopilotProgressSnapshot progressSnapshot;

  @override
  Widget build(BuildContext context) {
    return _HomeContent(
      journeyContextController: journeyContextController,
      citiesController: citiesController,
      migrationQuestionnaireController: migrationQuestionnaireController,
      locationController: locationController,
      progressSnapshot: progressSnapshot,
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.locationController,
    required this.progressSnapshot,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final LocationController locationController;
  final MigrationCopilotProgressSnapshot progressSnapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = migrationQuestionnaireController.generatedPlan;
    final confirmedCity = plan?.isCityConfirmed == true
        ? plan?.recommendedCity
        : null;
    final heroState = confirmedCity != null
        ? HomeHeroState.withPlan
        : HomeHeroState.noPlan;
    final weather = confirmedCity == null
        ? null
        : citiesController.weatherFor(confirmedCity.id);
    final planHeroData = confirmedCity == null
        ? null
        : _buildPlanHeroData(context, plan: plan!, snapshot: progressSnapshot);

    final citiesCard = _VisualActionCard(
      title: l10n.publicHomeCitiesTitle,
      description: heroState == HomeHeroState.withPlan
          ? l10n.homeHeroDiscoverCitiesBodyWithCity(confirmedCity!.name)
          : l10n.homeHeroDiscoverCitiesBody,
      actionLabel: heroState == HomeHeroState.withPlan
          ? l10n.homeHeroExploreAction
          : l10n.publicHomeCitiesAction,
      onTap: () => Navigator.pushNamed(context, AppRoutes.cities),
      scene: const _CitiesScene(),
      icon: Icons.location_city_rounded,
      accent: const Color(0xFF35A8FF),
      highlights: [
        _CardHighlight(
          icon: Icons.payments_outlined,
          label: l10n.cityDetailAffordabilityTitle,
        ),
        _CardHighlight(
          icon: Icons.work_outline_rounded,
          label: l10n.cityDetailWorkLabel,
        ),
      ],
    );

    final questionsCard = _VisualActionCard(
      title: l10n.publicHomeQuestionsTitle,
      description: l10n.homeHeroGuideBody,
      actionLabel: heroState == HomeHeroState.withPlan
          ? l10n.homeHeroOpenShortAction
          : l10n.homeHeroOpenGuideAction,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.documentationGuide,
        arguments: DocumentationGuideSection.documents,
      ),
      scene: const _QuestionsScene(),
      icon: Icons.folder_open_rounded,
      accent: const Color(0xFF4DC2A8),
      highlights: [
        _CardHighlight(
          icon: Icons.badge_outlined,
          label: l10n.documentationPathDocumentsTitle,
        ),
        _CardHighlight(
          icon: Icons.home_work_outlined,
          label: l10n.documentationHousingArrivalSectionTitle,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<bool>(
          future: locationController.shouldShowInlineBanner(),
          builder: (context, snapshot) {
            if (snapshot.data != true) {
              return const SizedBox.shrink();
            }

            return LocationBannerWidget(
              onActivate: () => Navigator.pushNamed(
                context,
                AppRoutes.locationPermission,
                arguments: const LocationPermissionScreenArgs(
                  returnToPrevious: true,
                ),
              ),
            );
          },
        ),
        _HomeGreeting(state: heroState, displayName: null),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: heroState == HomeHeroState.withPlan
              ? _WithPlanHeroCard(
                  key: const ValueKey('with-plan-hero'),
                  city: confirmedCity!,
                  weather: weather,
                  planData: planHeroData!,
                  citiesController: citiesController,
                  onFavoriteToggle: () =>
                      _toggleFavorite(context, confirmedCity),
                  onOpenPlan: () => Navigator.pushNamed(
                    context,
                    AppRoutes.migrationPlanCopilot,
                  ),
                  onOpenNextStep: () => Navigator.pushNamed(
                    context,
                    AppRoutes.migrationPlanCopilot,
                  ),
                  onCompare: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CityComparisonScreen(
                        initialCities: [confirmedCity],
                        citiesController: citiesController,
                        migrationQuestionnaireController:
                            migrationQuestionnaireController,
                      ),
                    ),
                  ),
                  onManagePlan: () => _handleManagePlan(context),
                )
              : _NoPlanHeroCard(
                  key: const ValueKey('no-plan-hero'),
                  originLabel:
                      journeyContextController.selectedOrigin?.name ??
                      'Argentina',
                  originFlag:
                      journeyContextController.selectedOrigin?.flagEmoji ??
                      '🇦🇷',
                  destinationLabel:
                      journeyContextController.selectedDestination?.name ??
                      'Brasil',
                  destinationFlag:
                      journeyContextController.selectedDestination?.flagEmoji ??
                      '🇧🇷',
                  onStart: () =>
                      _startPlanFlow(context, journeyContextController),
                ),
        ),
        const SizedBox(height: 16),
        if (heroState == HomeHeroState.withPlan) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.homeHeroExploreSectionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
        _SecondaryCardsGrid(cards: [citiesCard, questionsCard]),
      ],
    );
  }

  _HomePlanHeroData _buildPlanHeroData(
    BuildContext context, {
    required MigrationPlan plan,
    required MigrationCopilotProgressSnapshot snapshot,
  }) {
    final l10n = context.l10n;
    final readinessChecklist = MigrationReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final documentChecklist = MigrationDocumentReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final arrivalChecklist = ArrivalExecutionBuilder.build(
      l10n: l10n,
      plan: plan,
    );

    final totalItems =
        readinessChecklist.items.length +
        documentChecklist.items.length +
        arrivalChecklist.items.length;
    final completedItems =
        snapshot.readinessCompletedIds.length +
        snapshot.documentCompletedIds.length +
        snapshot.arrivalCompletedIds.length;
    final percent = totalItems == 0
        ? 0
        : ((completedItems / totalItems) * 100).round();

    final nextReadiness = readinessChecklist.items.where(
      (item) => !snapshot.readinessCompletedIds.contains(item.id),
    );
    final nextDocument = documentChecklist.items.where(
      (item) => !snapshot.documentCompletedIds.contains(item.id),
    );
    final nextArrival = arrivalChecklist.items.where(
      (item) => !snapshot.arrivalCompletedIds.contains(item.id),
    );

    if (nextReadiness.isNotEmpty) {
      return _HomePlanHeroData(
        progressPercent: percent,
        currentStage: 1,
        nextPendingTask: nextReadiness.first.title,
      );
    }
    if (nextDocument.isNotEmpty) {
      return _HomePlanHeroData(
        progressPercent: percent,
        currentStage: 2,
        nextPendingTask: nextDocument.first.title,
      );
    }
    if (nextArrival.isNotEmpty) {
      return _HomePlanHeroData(
        progressPercent: percent,
        currentStage: 5,
        nextPendingTask: nextArrival.first.title,
      );
    }

    return _HomePlanHeroData(
      progressPercent: percent,
      currentStage: 5,
      nextPendingTask: l10n.homeHeroPlanCompleteTask,
    );
  }

  Future<void> _toggleFavorite(BuildContext context, City city) async {
    final result = await citiesController.toggleFavorite(city.id);
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

  Future<void> _startPlanFlow(
    BuildContext context,
    JourneyContextController journeyContextController,
  ) async {
    await migrationQuestionnaireController.initialize();
    if (!context.mounted) {
      return;
    }

    Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
  }

  Future<void> _handleManagePlan(BuildContext context) async {
    final choice = await showPlanResetDialog(context);
    if (!context.mounted || choice == null) {
      return;
    }

    await migrationQuestionnaireController.clearCurrentPlan();
    if (!context.mounted) {
      return;
    }

    if (choice == PlanResetChoice.rebuild) {
      Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
    }
  }
}

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting({required this.state, required this.displayName});

  final HomeHeroState state;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    final salutation = displayName == null || displayName!.trim().isEmpty
        ? (state == HomeHeroState.withPlan
              ? l10n.homeHeroWelcomeBack
              : l10n.homeHeroWelcomeDefault)
        : hour < 12
        ? l10n.homeHeroGreetingMorning(displayName!)
        : hour < 18
        ? l10n.homeHeroGreetingAfternoon(displayName!)
        : l10n.homeHeroGreetingEvening(displayName!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salutation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoftFor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state == HomeHeroState.withPlan
              ? l10n.homeHeroSubtitleWithPlan
              : l10n.homeHeroSubtitleNoPlan,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _NoPlanHeroCard extends StatelessWidget {
  const _NoPlanHeroCard({
    required this.originLabel,
    required this.originFlag,
    required this.destinationLabel,
    required this.destinationFlag,
    required this.onStart,
    super.key,
  });

  final String originLabel;
  final String originFlag;
  final String destinationLabel;
  final String destinationFlag;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.heroStart.withValues(
        alpha: isDark ? 0.34 : 0.20,
      ),
      borderColor: AppColors.primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned(top: -30, right: -18, child: _HeroOrb(size: 124)),
          Positioned(bottom: -38, left: -16, child: _HeroOrb(size: 136)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _JourneyRouteStrip(
                originLabel: originLabel,
                originFlag: originFlag,
                destinationLabel: destinationLabel,
                destinationFlag: destinationFlag,
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.homeHeroNoPlanTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.homeHeroNoPlanBody,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PlanStepTile(
                      number: '01',
                      label: context.l10n.homeHeroStepQuestionnaire,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanStepTile(
                      number: '02',
                      label: context.l10n.homeHeroStepCity,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanStepTile(
                      number: '03',
                      label: context.l10n.homeHeroStepGuide,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(context.l10n.homeHeroStartAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithPlanHeroCard extends StatelessWidget {
  const _WithPlanHeroCard({
    required this.city,
    required this.weather,
    required this.planData,
    required this.citiesController,
    required this.onFavoriteToggle,
    required this.onOpenPlan,
    required this.onOpenNextStep,
    required this.onCompare,
    required this.onManagePlan,
    super.key,
  });

  final City city;
  final CityWeather? weather;
  final _HomePlanHeroData planData;
  final CitiesController citiesController;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenNextStep;
  final VoidCallback onCompare;
  final VoidCallback onManagePlan;

  @override
  Widget build(BuildContext context) {
    final planResetCopy = PlanResetDialogCopy.fromContext(context);
    final cost = CityHousingViabilityPresenter.resolve(
      context,
      rentScore: city.rentScore,
    );

    return FrostedPanel(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HomeHeroImage(city: city),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _StatusBadge(
                      label: context.l10n.homeHeroPlanActiveBadge,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _HeroCircleButton(
                      icon: citiesController.isFavorite(city.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      active: citiesController.isFavorite(city.id),
                      onTap: onFavoriteToggle,
                    ),
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
                                context.l10n.homeHeroSelectedCityEyebrow,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                city.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                '${city.stateName} (${city.stateCode})',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.homeHeroProgressLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                      ),
                      Text(
                        '${planData.progressPercent}%',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (planData.progressPercent / 100).clamp(0, 1),
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceMutedFor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricMiniCard(
                          label: context.l10n.homeHeroStageMetricLabel,
                          value:
                              '${planData.currentStage} / ${context.l10n.homeHeroStageTotalValue}',
                          valueColor: AppColors.textPrimaryFor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricMiniCard(
                          label: context.l10n.homeHeroCostMetricLabel,
                          value: cost.headline,
                          valueColor: cost.tint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricMiniCard(
                          label: context.l10n.homeHeroClimateMetricLabel,
                          value: weather == null
                              ? '--'
                              : '${weather!.temperatureCelsius.round()}°C',
                          valueColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onOpenNextStep,
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedFor(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.borderFor(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.checklist_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.homeHeroNextStepLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSoftFor(context),
                                          letterSpacing: 0.6,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    planData.nextPendingTask,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSoftFor(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: onOpenPlan,
                          child: Text(context.l10n.homeHeroContinueAction),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.compare_rounded),
                        label: Text(context.l10n.cityComparisonCompareAction),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onManagePlan,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(planResetCopy.manageActionLabel),
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

class _SecondaryCardsGrid extends StatelessWidget {
  const _SecondaryCardsGrid({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _HomePlanHeroData {
  const _HomePlanHeroData({
    required this.progressPercent,
    required this.currentStage,
    required this.nextPendingTask,
  });

  final int progressPercent;
  final int currentStage;
  final String nextPendingTask;
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.15),
      ),
    );
  }
}

class _JourneyRouteStrip extends StatelessWidget {
  const _JourneyRouteStrip({
    required this.originLabel,
    required this.originFlag,
    required this.destinationLabel,
    required this.destinationFlag,
  });

  final String originLabel;
  final String originFlag;
  final String destinationLabel;
  final String destinationFlag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RouteEndpoint(
            flag: originFlag,
            caption: context.l10n.homeHeroOriginLabel,
            country: originLabel,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.flight_takeoff_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        Expanded(
          child: _RouteEndpoint(
            flag: destinationFlag,
            caption: context.l10n.homeHeroDestinationLabel,
            country: destinationLabel,
          ),
        ),
      ],
    );
  }
}

class _RouteEndpoint extends StatelessWidget {
  const _RouteEndpoint({
    required this.flag,
    required this.caption,
    required this.country,
  });

  final String flag;
  final String caption;
  final String country;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Text(flag, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanStepTile extends StatelessWidget {
  const _PlanStepTile({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeroImage extends StatelessWidget {
  const _HomeHeroImage({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final imageUrl = cityImageUrlFor(city.id);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const SkeletonBox(height: 100),
            errorWidget: (_, _, _) => const _HomeHeroImageFallback(),
          )
        else
          const _HomeHeroImageFallback(),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF08111E).withValues(alpha: 0.74),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeroImageFallback extends StatelessWidget {
  const _HomeHeroImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1828),
      alignment: Alignment.center,
      child: const Icon(
        Icons.location_city_outlined,
        color: Colors.white70,
        size: 28,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE5485E)
                : Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHighlight {
  const _CardHighlight({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _VisualActionCard extends StatelessWidget {
  const _VisualActionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    required this.scene,
    required this.icon,
    required this.accent,
    this.highlights = const [],
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final Widget scene;
  final IconData icon;
  final Color accent;
  final List<_CardHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final borderColor = AppColors.borderFor(context);
    final cardGradient = LinearGradient(
      colors: isDark
          ? [AppColors.surfaceFor(context), AppColors.surfaceMutedFor(context)]
          : const [Color(0xFFFFFFFF), Color(0xFFF4F7FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? borderColor
                  : Colors.white.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : accent).withValues(
                  alpha: isDark ? 0.14 : 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 208),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Opacity(
                      opacity: isDark ? 0.12 : 0.14,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(width: 190, child: scene),
                      ),
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.72 : 0.50),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.withValues(
                                          alpha: isDark ? 0.24 : 0.16,
                                        ),
                                        accent.withValues(
                                          alpha: isDark ? 0.14 : 0.08,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: accent.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      ),
                                    ),
                                  ),
                                  child: Icon(icon, color: accent, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: textPrimary,
                                              height: 1.05,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    height: 1.25,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),

                            if (highlights.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final highlight in highlights.take(2))
                                    _CardHighlightChip(
                                      icon: highlight.icon,
                                      label: highlight.label,
                                      tint: accent,
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    actionLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 20,
                                  color: accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHighlightChip extends StatelessWidget {
  const _CardHighlightChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryFor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionsScene extends StatelessWidget {
  const _QuestionsScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: -8,
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -12,
          bottom: -16,
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(240, 68),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 178,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: _QuestionSheet(accent: const Color(0xFF2B7BE8)),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 10,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: _QuestionSheet(accent: const Color(0xFF7E4DFF)),
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

class _QuestionSheet extends StatelessWidget {
  const _QuestionSheet({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.question_answer_rounded, size: 15, color: accent),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0x332B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _CitiesScene extends StatelessWidget {
  const _CitiesScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 20,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -12,
          top: -6,
          child: Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -18,
          bottom: -24,
          child: Container(
            width: 102,
            height: 102,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(260, 74),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 190,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Positioned(
                  left: 10,
                  top: 24,
                  child: _MiniCityCard(
                    titleWidth: 44,
                    accent: Color(0xFF35C6F4),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _MiniCityCard(
                    titleWidth: 52,
                    accent: Color(0xFF2B7BE8),
                  ),
                ),
                Positioned(bottom: 8, child: _LocationPinCard()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniCityCard extends StatelessWidget {
  const _MiniCityCard({required this.titleWidth, required this.accent});

  final double titleWidth;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Container(
              width: titleWidth,
              height: 8,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPinCard extends StatelessWidget {
  const _LocationPinCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.location_on_rounded,
          size: 34,
          color: Color(0xFF7E4DFF),
        ),
      ),
    );
  }
}

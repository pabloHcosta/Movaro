import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_text_styles.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/core/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:movaro_app/features/home/presentation/pages/city_comparison_screen.dart';
import 'package:movaro_app/features/home/presentation/widgets/assistant_bottom_sheet.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/plan_reset_dialog.dart';

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
    widget.journeyContextController.addListener(_handleControllerUpdate);
    widget.migrationQuestionnaireController.addListener(
      _handleControllerUpdate,
    );
    widget.citiesController.addListener(_handleControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncPlanState());
      unawaited(_maybePromptLocationPermission());
    });
  }

  @override
  void dispose() {
    widget.journeyContextController.removeListener(_handleControllerUpdate);
    widget.migrationQuestionnaireController.removeListener(
      _handleControllerUpdate,
    );
    widget.citiesController.removeListener(_handleControllerUpdate);
    super.dispose();
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

              // Height of the floating pill nav bar above which the assistant
              // sheet is anchored (bottom safe area + pill container height).
              final navBarH =
                  MediaQuery.of(context).padding.bottom + 76.0;
              // Extra bottom padding so the scroll content clears the sheet.
              const sheetCollapsedH = 170.0;

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
                                padding:
                                    const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                                      weather:
                                          widget.citiesController.weatherFor(
                                        city.id,
                                      ),
                                      guideState: guideState!,
                                      extraBottomPadding:
                                          navBarH + sheetCollapsedH,
                                      onOpenSettings: _openSettings,
                                      onOpenGuide: _openGuide,
                                      onViewCurrentAction: () =>
                                          _showActionDetails(
                                        context,
                                        guideState.currentItem,
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
                                      onOpenSettings: _openSettings,
                                      onStart: () => _startPlanFlow(context),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Assistant sheet — anchored above the floating nav bar.
                  if (hasActivePlan)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: navBarH,
                      child: AssistantBottomSheet(
                        destination: city.name,
                        originCountry: plan!.originCountry,
                        destinationCountry: plan.destinationCountry,
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
    Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  void _openGuide() {
    Navigator.pushNamed(context, AppRoutes.migrationPlanCopilot);
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
      Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
    }
  }

  Future<void> _showActionDetails(
    BuildContext context,
    GuideActionItem? item,
  ) async {
    if (item == null) {
      return;
    }

    final body = item.fullContent?.trim().isNotEmpty == true
        ? item.fullContent!
        : item.shortDescription;

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
        ArgentinaBrazilGuideDataSource.build(plan)
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
  const _EmptyHomeState({
    required this.onOpenSettings,
    required this.onStart,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmptyHero(onOpenSettings: onOpenSettings),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const _StepTimeline(),
                const SizedBox(height: 12),
                _StartPlanCta(onTap: onStart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SizedBox(
      height: MediaQuery.of(context).padding.top + 240,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: isDark ? const Color(0xFF07090E) : const Color(0xFFEEF2F9),
            ),
          ),
          const Positioned(top: -70, right: -50, child: _BlueOrb()),
          const Positioned(bottom: -40, left: -50, child: _IndigoOrb()),
          const Positioned(top: 80, left: 60, child: _BlueLightOrb()),
          Positioned.fill(
            child: CustomPaint(painter: _HeroGridPainter(isDark)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark
                          ? const Color(0xFF07090E)
                          : const Color(0xFFF4F6FA),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 14,
            child: _SettingsButton(onTap: onOpenSettings),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _badgeBackground(context),
                        border: Border.all(color: _badgeBorder(context)),
                      ),
                      child: Icon(
                        Icons.route_rounded,
                        size: 22,
                        color: _accentText(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _greeting(context),
                      textAlign: TextAlign.center,
                      style: context.textStyles.sectionLabel.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _tertiaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${_text(context, pt: 'Planeje sua', es: 'Planeá tu', en: 'Plan your')}\n',
                            style: TextStyle(color: _primaryText(context)),
                          ),
                          TextSpan(
                            text: _text(
                              context,
                              pt: 'mudança',
                              es: 'mudanza',
                              en: 'move',
                            ),
                            style: TextStyle(color: _accentText(context)),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _text(
                        context,
                        pt: 'Do questionário ao guia passo a passo',
                        es: 'Del cuestionario a la guía paso a paso',
                        en: 'From questionnaire to step-by-step guide',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: _tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return _text(context, pt: 'Bom dia', es: 'Buen día', en: 'Good morning');
    }
    if (hour < 18) {
      return _text(
        context,
        pt: 'Boa tarde',
        es: 'Buenas tardes',
        en: 'Good afternoon',
      );
    }
    return _text(
      context,
      pt: 'Boa noite',
      es: 'Buenas noches',
      en: 'Good evening',
    );
  }
}

class _ActiveHomeState extends StatelessWidget {
  const _ActiveHomeState({
    required this.city,
    required this.weather,
    required this.guideState,
    required this.onOpenSettings,
    required this.onOpenGuide,
    required this.onViewCurrentAction,
    required this.onCompare,
    required this.onViewCity,
    required this.onNewPlan,
    this.extraBottomPadding = 0,
    super.key,
  });

  final City city;
  final CityWeather? weather;
  final _HomeGuideState guideState;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenGuide;
  final VoidCallback onViewCurrentAction;
  final VoidCallback onCompare;
  final VoidCallback onViewCity;
  final VoidCallback onNewPlan;
  final double extraBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActiveHero(
          city: city,
          weather: weather,
          onOpenSettings: onOpenSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 16 + extraBottomPadding),
            child: Column(
              children: [
                _ProgressCard(state: guideState),
                const SizedBox(height: 8),
                _NextActionCard(
                  state: guideState,
                  onOpenGuide: onOpenGuide,
                  onViewAction: onViewCurrentAction,
                ),
                const SizedBox(height: 8),
                _SecondaryActionRow(
                  onCompare: onCompare,
                  onViewCity: onViewCity,
                  onNewPlan: onNewPlan,
                ),
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
      height: MediaQuery.of(context).padding.top + 200,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                    _text(
                      context,
                      pt: 'PLANO ATIVO',
                      es: 'PLAN ACTIVO',
                      en: 'ACTIVE PLAN',
                    ),
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
            bottom: 14,
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
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0x80000000),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$stateLabel, ${_text(context, pt: 'Brasil', es: 'Brasil', en: 'Brazil')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.70),
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
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.75),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});

  final _HomeGuideState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _progressBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(
                        context,
                        pt: 'PROGRESSO GERAL',
                        es: 'PROGRESO GENERAL',
                        en: 'GENERAL PROGRESS',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: _tertiaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: context.textStyles.displayNumber.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _primaryText(context),
                            ),
                        children: [
                          TextSpan(text: '${state.progressPercent}'),
                          TextSpan(
                            text: '%',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _tertiaryText(context),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _badgeBackground(context),
                      border: Border.all(color: _badgeBorder(context)),
                    ),
                    child: Text(
                      '${_text(context, pt: 'Etapa', es: 'Etapa', en: 'Stage')} ${state.currentPhaseIndex} / ${state.totalPhases}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _accentText(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.completedCount} ${_text(context, pt: 'de', es: 'de', en: 'of')} ${state.totalItems} ${_text(context, pt: 'feitas', es: 'hechas', en: 'done')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _progressTrack(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: 4,
                    width: constraints.maxWidth * (state.progressPercent / 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var index = 0; index < state.totalItems; index++) ...[
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (50 * index)),
                    builder: (context, value, _) {
                      return Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: state
                              .segmentColor(context, index)
                              .withValues(alpha: value),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
                if (index != state.totalItems - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.state,
    required this.onOpenGuide,
    required this.onViewAction,
  });

  final _HomeGuideState state;
  final VoidCallback onOpenGuide;
  final VoidCallback onViewAction;

  @override
  Widget build(BuildContext context) {
    final isComplete =
        state.currentItem == null || state.progressPercent == 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isComplete
                ? _text(
                    context,
                    pt: 'PLANO CONCLUÍDO',
                    es: 'PLAN COMPLETADO',
                    en: 'PLAN COMPLETED',
                  )
                : '${_text(context, pt: 'Próxima ação', es: 'Próxima acción', en: 'Next action')} · ${state.phaseName(context)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: _accentText(context),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isComplete
                ? _text(
                    context,
                    pt: 'Seu plano já está completo',
                    es: 'Tu plan ya está completo',
                    en: 'Your plan is already complete',
                  )
                : state.currentItem!.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
              height: 1.3,
              color: _primaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onOpenGuide,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    isComplete
                        ? _text(
                            context,
                            pt: 'Ver resumo do plano',
                            es: 'Ver resumen del plan',
                            en: 'See plan summary',
                          )
                        : _text(
                            context,
                            pt: 'Continuar o guia →',
                            es: 'Continuar la guía →',
                            en: 'Continue guide →',
                          ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              TextButton(
                onPressed: onViewAction,
                style: TextButton.styleFrom(
                  backgroundColor: _mutedButtonBackground(context),
                  foregroundColor: _mutedButtonForeground(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  _text(context, pt: 'Ver', es: 'Ver', en: 'View'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
            label: _text(
              context,
              pt: 'Comparar',
              es: 'Comparar',
              en: 'Compare',
            ),
            onTap: onCompare,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.location_city_outlined,
            label: _text(
              context,
              pt: 'Ver cidade',
              es: 'Ver ciudad',
              en: 'View city',
            ),
            onTap: onViewCity,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionChip(
            icon: Icons.restart_alt_rounded,
            label: _text(
              context,
              pt: 'Novo plano',
              es: 'Nuevo plan',
              en: 'New plan',
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _badgeBackground(context),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 16, color: _accentText(context)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: context.textStyles.navLabel.copyWith(
                  color: _tertiaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTimeline extends StatelessWidget {
  const _StepTimeline();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        title: _text(
          context,
          pt: 'Responder o questionário',
          es: 'Responder el cuestionario',
          en: 'Answer the questionnaire',
        ),
        subtitle: _text(
          context,
          pt: '5 minutos · seu perfil de vida e objetivos',
          es: '5 minutos · tu perfil de vida y objetivos',
          en: '5 minutes · your life profile and goals',
        ),
      ),
      (
        title: _text(
          context,
          pt: 'Receber a cidade ideal',
          es: 'Recibir la ciudad ideal',
          en: 'Get your ideal city',
        ),
        subtitle: _text(
          context,
          pt: 'Indicação personalizada para o seu perfil',
          es: 'Recomendación personalizada para tu perfil',
          en: 'Personalized recommendation for your profile',
        ),
      ),
      (
        title: _text(
          context,
          pt: 'Executar com o guia GPS',
          es: 'Ejecutar con la guía GPS',
          en: 'Execute with the GPS guide',
        ),
        subtitle: _text(
          context,
          pt: 'Passo a passo da mudança, do zero',
          es: 'Paso a paso de la mudanza, desde cero',
          en: 'Step by step from zero',
        ),
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _badgeBackground(context),
                          border: Border.all(color: _badgeBorder(context)),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: context.textStyles.badgeLabel.copyWith(
                                fontWeight: FontWeight.w900,
                                color: _accentText(context),
                              ),
                        ),
                      ),
                      if (index != steps.length - 1)
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.isDark(context)
                              ? const Color(0x330EA5E9)
                              : const Color(0x400EA5E9),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index].title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _primaryText(context),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[index].subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _tertiaryText(context),
                              ),
                        ),
                      ],
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

class _StartPlanCta extends StatefulWidget {
  const _StartPlanCta({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_StartPlanCta> createState() => _StartPlanCtaState();
}

class _StartPlanCtaState extends State<_StartPlanCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.97 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text(
                      context,
                      pt: 'Montar meu plano',
                      es: 'Armar mi plan',
                      en: 'Build my plan',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _text(
                      context,
                      pt: 'Leva cerca de 5 minutos',
                      es: 'Toma unos 5 minutos',
                      en: 'Takes about 5 minutes',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
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

class _BlueOrb extends StatelessWidget {
  const _BlueOrb();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? const [Color(0x8C0284C7), Color(0x260284C7), Colors.transparent]
              : const [
                  Color(0x400284C7),
                  Color(0x140284C7),
                  Colors.transparent,
                ],
          stops: const [0, 0.45, 0.70],
        ),
      ),
    );
  }
}

class _IndigoOrb extends StatelessWidget {
  const _IndigoOrb();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? const [Color(0x596366F1), Color(0x146366F1), Colors.transparent]
              : const [
                  Color(0x266366F1),
                  Color(0x0A6366F1),
                  Colors.transparent,
                ],
          stops: const [0, 0.50, 0.70],
        ),
      ),
    );
  }
}

class _BlueLightOrb extends StatelessWidget {
  const _BlueLightOrb();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? const [Color(0x330EA5E9), Colors.transparent]
              : const [Color(0x1A0EA5E9), Colors.transparent],
          stops: const [0, 0.65],
        ),
      ),
    );
  }
}

class _HeroGridPainter extends CustomPainter {
  const _HeroGridPainter(this.isDark);

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0x0A0EA5E9) : const Color(0x0F0EA5E9)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
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

  String phaseName(BuildContext context) {
    final phase = currentItem?.phase ?? GuidePhase.arrival;
    return switch (phase) {
      GuidePhase.preparation => _text(
        context,
        pt: 'Antes de viajar',
        es: 'Antes de viajar',
        en: 'Before travel',
      ),
      GuidePhase.housing => _text(
        context,
        pt: 'Primeiros dias',
        es: 'Primeros días',
        en: 'First days',
      ),
      GuidePhase.documents => _text(
        context,
        pt: 'Documentação',
        es: 'Documentación',
        en: 'Documentation',
      ),
      GuidePhase.work => _text(
        context,
        pt: 'Vida funcionando',
        es: 'Vida funcionando',
        en: 'Life working',
      ),
      GuidePhase.arrival => _text(
        context,
        pt: 'Integração',
        es: 'Integración',
        en: 'Integration',
      ),
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

Color _progressTrack(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.07)
    : Colors.black.withValues(alpha: 0.07);

Color _mutedButtonBackground(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.07)
    : Colors.black.withValues(alpha: 0.06);

Color _mutedButtonForeground(BuildContext context) => AppColors.isDark(context)
    ? Colors.white.withValues(alpha: 0.35)
    : Colors.black.withValues(alpha: 0.35);

String _text(
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

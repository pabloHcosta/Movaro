import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/journey/country_coverage.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/journey/journey_country_metadata.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/features/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/exit_flow_dialog.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/available_capital_ranges_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/recommendation_reveal_timing.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/question_progress_indicator.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    required this.controller,
    required this.locationController,
    required this.citiesController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final LocationController locationController;
  final CitiesController citiesController;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  static const _helpPreferenceKey = 'questionnaire_flow';
  String? _inlineHint;
  bool _showProcessingScreen = false;
  Object? _processingError;
  Future<bool> Function()? _retryGeneration;
  bool _didPromptOriginLocation = false;
  final ScrollController _optionsScrollController = ScrollController();
  String? _scrollScopeKey;
  bool _showScrollHint = false;

  MigrationQuestionnaireController get controller => widget.controller;
  LocationController get locationController => widget.locationController;

  @override
  void initState() {
    super.initState();
    _optionsScrollController.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeQuestionnaire());
    });
  }

  Future<void> _initializeQuestionnaire() async {
    await controller.initializeForQuestionnaire();
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
      eyebrow: context.l10n.questionnaireGuideEyebrow(),
      contextIcon: Icons.route_outlined,
      title: context.l10n.questionnaireGuideTitle(),
      body: context.l10n.questionnaireGuideBody(),
      showHideAgainControl: false,
      steps: [
        FeatureGuideStep(
          number: '1',
          icon: Icons.tune_rounded,
          title: context.l10n.questionnaireGuideStepOneTitle(),
          body: context.l10n.questionnaireGuideStepOneBody(),
        ),
        FeatureGuideStep(
          number: '2',
          icon: Icons.filter_alt_outlined,
          title: context.l10n.questionnaireGuideStepTwoTitle(),
          body: context.l10n.questionnaireGuideStepTwoBody(),
        ),
        FeatureGuideStep(
          number: '3',
          icon: Icons.fact_check_outlined,
          title: context.l10n.questionnaireGuideStepThreeTitle(),
          body: context.l10n.questionnaireGuideStepThreeBody(),
        ),
        FeatureGuideStep(
          number: '4',
          icon: Icons.balance_outlined,
          title: context.l10n.questionnaireGuideStepFourTitle(),
          body: context.l10n.questionnaireGuideStepFourBody(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _optionsScrollController
      ..removeListener(_updateScrollHint)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final question = controller.currentQuestion;
        final l10n = context.l10n;

        if (question?.id == 'origin_country' && !_didPromptOriginLocation) {
          _didPromptOriginLocation = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_handleOriginAutoDetection(question!));
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppGlassHeader(
                            title: l10n.questionnaireVariantPageTitle(),
                            onBack: () => _handleExitFlow(context),
                            onHelp: _showHelp,
                          ),
                          const SizedBox(height: 16),
                          // Context bridge: show when user arrived from
                          // favorites/explore (≥2 favorites present)
                          AnimatedBuilder(
                            animation: widget.citiesController,
                            builder: (context, child) {
                              final favorites =
                                  widget.citiesController.favoriteCities;
                              if (favorites.length < 2) {
                                return const SizedBox(height: 4);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _FavoritesContextBanner(
                                  favorites: favorites,
                                ),
                              );
                            },
                          ),
                          if (_showProcessingScreen)
                            Expanded(
                              child: _ProcessingState(
                                error: _processingError,
                                onRetry: _retryGeneration == null
                                    ? null
                                    : _retryPlanGeneration,
                                onBack: _cancelProcessing,
                              ),
                            )
                          else if (controller.isInitializing ||
                              !controller.hasSelectedVariant)
                            const Expanded(
                              child: SingleChildScrollView(
                                child: FormSkeleton(
                                  fieldCount: 4,
                                  compact: true,
                                ),
                              ),
                            )
                          else if (controller.isRefinePromptVisible)
                            Expanded(child: _buildRefinePrompt(context))
                          else if (question != null)
                            Expanded(
                              child: _buildQuestionFlow(context, question),
                            )
                          else
                            const Expanded(
                              child: SingleChildScrollView(
                                child: FormSkeleton(
                                  fieldCount: 4,
                                  compact: true,
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
          ),
        );
      },
    );
  }

  Widget _buildRefinePrompt(BuildContext context) {
    final l10n = context.l10n;
    _prepareScrollableScope('refine_prompt');

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _optionsScrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: FrostedPanel(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RefinementHero(
                  eyebrow: l10n.adaptiveRefinementEyebrow(),
                  optionalLabel: l10n.adaptiveRefinementOptional(),
                  title: l10n.adaptiveRefinementTitle(
                    controller.adaptiveQuestionId,
                  ),
                  body: l10n.adaptiveRefinementBody(
                    controller.adaptiveQuestionId,
                  ),
                  questionCount: l10n.adaptiveRefinementQuestionCount(),
                  time: l10n.adaptiveRefinementTime(),
                  beforeLabel: l10n.adaptiveRefinementPreviewBefore(),
                  afterLabel: l10n.adaptiveRefinementPreviewAfter(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RefinementBenefits(
                        title: l10n.adaptiveRefinementImpactTitle(),
                        rankingBenefit: l10n.adaptiveRefinementImpactRanking(),
                        contextBenefit: l10n.adaptiveRefinementImpactContext(),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        style: _primaryButtonStyle(context).copyWith(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),
                        onPressed: controller.acceptRefine,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                        label: Text(l10n.adaptiveRefinementAction()),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        style: _secondaryButtonStyle(context),
                        onPressed: () =>
                            _generateAndReveal(controller.skipRefine),
                        child: Text(l10n.adaptiveRefinementSkipAction()),
                      ),
                      const SizedBox(height: 2),
                      TextButton.icon(
                        onPressed: controller.goBack,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(l10n.bmpCtaBack),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSoftFor(context),
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExitFlow(BuildContext context) async {
    final shouldLeave = await ExitFlowDialog.show(
      context,
      title: context.l10n.bmpExitDialogTitle,
      body: context.l10n.bmpExitDialogBody,
      stayLabel: context.l10n.bmpExitDialogStay,
      leaveLabel: context.l10n.bmpExitDialogLeave,
    );

    if (!context.mounted || !shouldLeave) {
      return;
    }

    var foundHome = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == AppRoutes.publicHome) {
        foundHome = true;
        return true;
      }
      return false;
    });

    if (!foundHome && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.publicHome,
        (route) => false,
      );
    }
  }

  Future<void> _handleOriginAutoDetection(Question question) async {
    if (!mounted || controller.answerFor(question.id) != null) {
      return;
    }

    final savedLocation = locationController.savedLocation;
    if (savedLocation == null || savedLocation.countryCode.isEmpty) {
      return;
    }

    final detected = _toDetectedLocation(savedLocation);
    await _handleDetectedOriginResult(question, detected);
  }

  DetectedLocation _toDetectedLocation(LocationData location) {
    return DetectedLocation(
      countryId: locationController.matchedCountryId,
      countryName: location.countryName,
      city: location.cityName.isEmpty ? null : location.cityName,
      region: location.stateName.isEmpty ? null : location.stateName,
      latitude: location.latitude,
      longitude: location.longitude,
      detectedAt: DateTime.now(),
    );
  }

  Future<void> _openLocationPermissionScreen() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.locationPermission,
      arguments: const LocationPermissionScreenArgs(returnToPrevious: true),
    );
    if (!mounted) {
      return;
    }
    _didPromptOriginLocation = false;
    setState(() {});
  }

  Future<void> _handleDetectedOriginResult(
    Question question,
    DetectedLocation detected,
  ) async {
    final journey = controller.journeyContextController;
    final matchedCountry = journey.countries
        .where((country) => country.id == detected.countryId)
        .firstOrNull;

    if (matchedCountry != null && journey.canUseAsOrigin(matchedCountry)) {
      await _showDetectedOriginDialog(question, detected, matchedCountry);
      return;
    }

    await _showUnsupportedLocationDialog(detected);
  }

  Future<void> _showDetectedOriginDialog(
    Question question,
    DetectedLocation detected,
    CatalogCountry matchedCountry,
  ) async {
    final locationLabel = [
      if ((detected.city ?? '').isNotEmpty) detected.city!,
      if ((detected.region ?? '').isNotEmpty) detected.region!,
      detected.countryName,
    ].join(' · ');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _QuestionLocationDialog(
        title: context.l10n.questionnaireOriginAutoDetectTitle,
        body:
            '${context.l10n.journeyDetectedLocationLabel(locationLabel)}\n\n${context.l10n.journeyDetectedConfirmBody(detected.countryName)}',
        secondaryLabel: context.l10n.journeyDetectedManualAction,
        primaryLabel: context.l10n.journeyDetectedConfirmAction(
          detected.countryName,
        ),
      ),
    );

    if (confirmed == true) {
      final matchedOption = question.options
          .where(
            (option) =>
                option.value ==
                controller.journeyContextController.journeyValueFor(
                  matchedCountry,
                ),
          )
          .firstOrNull;
      if (matchedOption != null) {
        _handleSingleSelect(question, matchedOption);
      }
    }
  }

  Future<void> _showUnsupportedLocationDialog(DetectedLocation detected) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _QuestionLocationDialog(
        title: context.l10n.questionnaireOriginUnsupportedTitle,
        body: context.l10n.locationQuestionnaireUnsupportedBody(
          detected.countryName,
        ),
        secondaryLabel: null,
        primaryLabel: context.l10n.journeyDetectedManualAction,
      ),
    );
  }

  Widget _buildQuestionFlow(BuildContext context, Question question) {
    final l10n = context.l10n;
    final showPrimaryAction = !_shouldAutoAdvance(question);
    _prepareScrollableScope(question.id);
    final questionTitle = l10n.questionTitleForJourney(
      question.id,
      destinationLabel: _destinationLabel(),
    );

    return Column(
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionProgressIndicator(
                currentStep: controller.currentStepForProgress,
                totalSteps: controller.totalStepsForProgress,
                label:
                    '${l10n.bmpProgressStep(controller.currentStepForProgress, controller.totalStepsForProgress)} · ${_remainingTimeLabel(context)}',
              ),
              const SizedBox(height: 14),
              Text(
                questionTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              if (question.type == 'multi_chip') ...[
                const SizedBox(height: 10),
                _SelectionStatusCard(
                  label: _selectionHelperLabel(context, question),
                  counter: _selectionCounterLabel(
                    controller.answerValuesFor(question.id).length,
                    question.maxSelections,
                  ),
                  isComplete: controller
                      .answerValuesFor(question.id)
                      .isNotEmpty,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: FrostedPanel(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildQuestionOptions(context, question),
                      ),
                      // Scroll indicator — simple arrow (no popover)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _showScrollHint ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              height: 36,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_inlineHint != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _inlineHint!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _buildFooter(context, question),
              ],
            ),
          ),
        ),
        if (showPrimaryAction) ...[
          const SizedBox(height: 12),
          _buildStickyPrimaryAction(context, question),
        ],
      ],
    );
  }

  String _remainingTimeLabel(BuildContext context) {
    final total = controller.totalStepsForProgress;
    final current = controller.currentStepForProgress;
    final remaining = (total - current).clamp(0, total);
    final secondsPerQuestion =
        controller.selectedVariant == QuestionnaireVariant.lean ? 18 : 25;
    final minutes = ((remaining * secondsPerQuestion) / 60).ceil();
    return minutes <= 1
        ? context.l10n.questionRemainingTimeUnderOneMinute
        : context.l10n.questionRemainingTimeMinutes(minutes);
  }

  String? _destinationLabel() {
    final destination = controller.journeyContextController.selectedDestination;
    if (destination == null) {
      return null;
    }
    return destination.name;
  }

  Widget _buildQuestionOptions(BuildContext context, Question question) {
    // Special renderers ─────────────────────────────────────────────────────
    if (question.id == 'origin_country') {
      return SingleChildScrollView(
        controller: _optionsScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<bool>(
              future: locationController.shouldShowInlineBanner(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return LocationBannerWidget(
                  onActivate: _openLocationPermissionScreen,
                );
              },
            ),
            _OriginDestinationStep(
              controller: controller,
              question: question,
              onOriginTap: (option) => _handleSingleSelect(question, option),
              onDestinationTap: controller.setJourneyDestination,
            ),
          ],
        ),
      );
    }

    if (question.id == 'preferred_city') {
      return _buildPreferredCityOptions(context, question);
    }

    // travel_group needs children-count sliver below the grid
    if (question.id == 'travel_group') {
      return _buildTravelGroupGrid(context, question);
    }

    // priorities → pill chip layout
    if (question.id == 'priorities') {
      return _buildPriorityChips(context, question);
    }

    if (question.type == 'multi_chip') {
      return _buildMultiSelectList(context, question);
    }

    // All other questions → horizontal compact list
    return _buildIconicGrid(context, question);
  }

  Widget _buildMultiSelectList(BuildContext context, Question question) {
    final options = question.options;
    final selectedValues = controller.answerValuesFor(question.id).toSet();

    return CustomScrollView(
      controller: _optionsScrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((ctx, index) {
            final option = options[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < options.length - 1 ? 8 : 0,
              ),
              child: _CompactOptionRow(
                icon: _iconDataFor(question.id, option.value),
                label: _displayOptionLabel(context, question.id, option.value),
                isSelected: selectedValues.contains(option.value),
                onTap: () {
                  HapticFeedback.selectionClick();
                  _handleMultiSelect(question, option);
                },
              ),
            );
          }, childCount: options.length),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 4)),
      ],
    );
  }

  // ── Horizontal compact list for standard single-select questions ──────────
  Widget _buildIconicGrid(BuildContext context, Question question) {
    final options = question.options;

    return CustomScrollView(
      controller: _optionsScrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((ctx, index) {
            final option = options[index];
            final selectedValue = controller.answerFor(question.id) ?? '';
            final isSelected = selectedValue == option.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < options.length - 1 ? 8 : 0,
              ),
              child: _CompactOptionRow(
                icon: _iconDataFor(question.id, option.value),
                label: _displayOptionLabel(context, question.id, option.value),
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _handleSingleSelect(question, option);
                },
              ),
            );
          }, childCount: options.length),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 4)),
      ],
    );
  }

  // ── Priority pill chips (multi-select) ────────────────────────────────────
  Widget _buildPriorityChips(BuildContext context, Question question) {
    final options = question.options;
    final selectedValues = controller.answerValuesFor(question.id).toSet();

    return SingleChildScrollView(
      controller: _optionsScrollController,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selectedValues.contains(option.value);
          return _PriorityChip(
            icon: _iconDataFor(question.id, option.value),
            label: _displayOptionLabel(context, question.id, option.value),
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              _handleMultiSelect(question, option);
            },
          );
        }).toList(),
      ),
    );
  }

  // ── travel_group: compact list + optional children-count selector ────────
  Widget _buildTravelGroupGrid(BuildContext context, Question question) {
    final selectedValue = controller.answerFor(question.id);
    final selectedChildrenCount = controller.answerFor(
      'travel_group_children_count',
    );
    final options = question.options;
    final showChildrenSelector =
        selectedValue == 'family_kids' || selectedValue == 'solo_parent';

    return CustomScrollView(
      controller: _optionsScrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((ctx, index) {
            final option = options[index];
            final isSelected = selectedValue == option.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < options.length - 1 ? 8 : 0,
              ),
              child: _CompactOptionRow(
                icon: _iconDataFor(question.id, option.value),
                label: _displayOptionLabel(context, question.id, option.value),
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _handleTravelGroupSelect(option);
                },
              ),
            );
          }, childCount: options.length),
        ),
        if (showChildrenSelector)
          SliverPadding(
            padding: const EdgeInsets.only(top: 12),
            sliver: SliverToBoxAdapter(
              child: _TravelGroupChildrenSelector(
                selectedValue: selectedChildrenCount,
                onSelected: _handleTravelGroupChildrenSelect,
              ),
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 4)),
      ],
    );
  }

  IconData _iconDataFor(String questionId, String value) {
    switch (questionId) {
      case 'intent':
        return switch (value) {
          'find_job_br' => Icons.work_outline_rounded,
          'remote_income' => Icons.laptop_mac_rounded,
          'study' => Icons.school_outlined,
          'family_partner' => Icons.favorite_border_rounded,
          'fresh_start' => Icons.wb_sunny_outlined,
          _ => Icons.explore_outlined,
        };
      case 'timeline':
        return switch (value) {
          'just_exploring' => Icons.travel_explore_rounded,
          'in_0_3m' => Icons.bolt_outlined,
          'in_3_6m' => Icons.event_available_rounded,
          'in_6_12m' => Icons.calendar_month_outlined,
          'in_12m_plus' => Icons.event_note_outlined,
          _ => Icons.all_inclusive_outlined,
        };
      case 'priorities':
        return switch (value) {
          'low_cost' => Icons.savings_outlined,
          'job_opportunities' => Icons.work_outline_rounded,
          'safety' => Icons.shield_outlined,
          'warm_climate_beach' => Icons.wb_sunny_outlined,
          'transit_infra' => Icons.directions_transit_outlined,
          'nature' => Icons.park_outlined,
          'university' => Icons.school_outlined,
          'community' => Icons.people_outline_rounded,
          'close_to_argentina' => Icons.near_me_outlined,
          _ => Icons.tune_rounded,
        };
      case 'funding':
        return switch (value) {
          'savings' => Icons.savings_outlined,
          'remote_income' => Icons.attach_money_rounded,
          'job_search' => Icons.manage_search_rounded,
          'job_offer' => Icons.badge_outlined,
          'family_support' => Icons.groups_2_outlined,
          _ => Icons.help_outline_rounded,
        };
      case 'travel_group':
        return switch (value) {
          'solo' => Icons.person_outline_rounded,
          'partner' => Icons.favorite_border_rounded,
          'family_kids' => Icons.family_restroom_rounded,
          'solo_parent' => Icons.escalator_warning_rounded,
          _ => Icons.help_outline_rounded,
        };
      case 'work_arrangement':
        return switch (value) {
          'remote' => Icons.laptop_outlined,
          'local_job' => Icons.business_center_outlined,
          'both_open' => Icons.swap_horiz_outlined,
          _ => Icons.help_outline_rounded,
        };
      case 'available_capital':
        return switch (value) {
          'low' => Icons.savings_outlined,
          'medium' => Icons.account_balance_wallet_outlined,
          'high' => Icons.payments_outlined,
          'very_high' => Icons.trending_up_rounded,
          _ => Icons.lock_outline_rounded,
        };
      case 'constraints':
        return switch (value) {
          'prefer_south' => Icons.south_america_outlined,
          'need_big_city' => Icons.location_city_outlined,
          'prefer_mid_city' => Icons.apartment_outlined,
          'want_coast' => Icons.beach_access_outlined,
          'prefer_cooler' => Icons.ac_unit_rounded,
          'need_transit' => Icons.tram_outlined,
          'avoid_expensive' => Icons.price_change_outlined,
          _ => Icons.adjust_rounded,
        };
      case 'support_needs':
        return switch (value) {
          'children_school' => Icons.family_restroom_rounded,
          'travel_with_pet' => Icons.pets_outlined,
          'continuous_medication' => Icons.medication_outlined,
          'will_drive' => Icons.directions_car_outlined,
          'foreign_income' => Icons.public_rounded,
          _ => Icons.check_circle_outline_rounded,
        };
      case 'preferred_city':
        return switch (value) {
          'choose_on_map' => Icons.map_outlined,
          _ => Icons.explore_outlined,
        };
    }
    return Icons.circle_outlined;
  }

  Widget _buildFooter(BuildContext context, Question question) {
    final l10n = context.l10n;

    if (question.id == 'origin_country' || !controller.canGoBack) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        TextButton.icon(
          onPressed: controller.canGoBack ? controller.goBack : null,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(l10n.bmpCtaBack),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSoftFor(context),
            textStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyPrimaryAction(BuildContext context, Question question) {
    final l10n = context.l10n;
    final isEnabled = controller.canGoNext && !controller.isLoading;
    final isGenerate = controller.isLastQuestion;
    final isMulti = question.type == 'multi_chip';
    final selectedCount = isMulti
        ? controller.answerValuesFor(question.id).length
        : 0;
    final maxSelections = question.maxSelections;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isMulti && maxSelections > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '$selectedCount/$maxSelections ${_selectionCounterSuffix(context)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: FrostedPanel(
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(24),
            backgroundColor: AppColors.isDark(context)
                ? const Color(0xE6101824)
                : const Color(0xEFFFFFFF),
            borderColor: AppColors.isDark(context)
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: AppColors.isDark(context) ? 0.22 : 0.16,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: _primaryButtonStyle(context).copyWith(
                    padding: WidgetStatePropertyAll(
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  onPressed: isEnabled
                      ? () async {
                          if (!controller.isLastQuestion) {
                            await controller.goNext();
                            return;
                          }
                          if (controller.selectedVariant ==
                                  QuestionnaireVariant.lean &&
                              !controller.isRefineResolved) {
                            await _generateAndReveal(controller.goNext);
                            return;
                          }
                          await _generateAndReveal(controller.goNext);
                        }
                      : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: controller.isGeneratingPlan
                        ? Row(
                            key: const ValueKey('loading'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.96),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.bmpCtaGenerate,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          )
                        : Row(
                            key: ValueKey(isGenerate ? 'generate' : 'continue'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isGenerate
                                    ? l10n.bmpCtaGenerate
                                    : l10n.bmpCtaContinue,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedSlide(
                                duration: const Duration(milliseconds: 220),
                                offset: isEnabled
                                    ? const Offset(0.08, 0)
                                    : Offset.zero,
                                curve: Curves.easeOutCubic,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isGenerate
                                        ? Icons.auto_awesome_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ), // FrostedPanel
        ), // AnimatedOpacity
      ],
    ); // Column
  }

  String _selectionCounterSuffix(BuildContext context) =>
      context.l10n.questionSelectionCounterSelected;

  bool _shouldAutoAdvance(Question question) {
    // Recommendation inputs are consequential and easy to tap accidentally
    // on mobile. Keep the chosen state visible and let the user confirm it
    // with the primary action before changing context.
    return false;
  }

  Future<void> _handleSingleSelect(Question question, Option option) async {
    setState(() {
      _inlineHint = null;
    });

    // Special handling: preferred_city → open city picker map.
    if (question.id == 'preferred_city' && option.value == 'choose_on_map') {
      await _openPreferredCityPicker(question);
      return;
    }

    controller.selectAnswer(question.id, option.value);
    await _advanceAfterSelection(question);
  }

  Widget _buildPreferredCityOptions(BuildContext context, Question question) {
    final l10n = context.l10n;
    final selectedCity = controller.preferredCity;
    final answer = controller.answerFor(question.id);
    final hasCitySelected =
        selectedCity != null &&
        answer != null &&
        answer != 'dont_know' &&
        answer != 'choose_on_map';
    final isSuggestionsSelected = answer == 'dont_know';

    return SingleChildScrollView(
      controller: _optionsScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreferredCityStartCard(
            city: hasCitySelected ? selectedCity : null,
            onChooseTap: () => _openPreferredCityPicker(question),
          ),
          const SizedBox(height: 12),
          _SuggestionStartCard(
            title: l10n.preferredCitySuggestionsTitle(),
            subtitle: l10n.preferredCitySuggestionsSubtitle(),
            isSelected: isSuggestionsSelected,
            onTap: () {
              controller.selectAnswer(question.id, 'dont_know');
              controller.setPreferredCity(null);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openPreferredCityPicker(Question question) async {
    // Ensure cities are loaded.
    await widget.citiesController.loadCatalog();
    if (!mounted) return;

    final cities = widget.citiesController.catalog;
    if (cities.isEmpty) return;

    final selected = await CityPickerBottomSheet.show(
      context: context,
      cities: cities,
      title: context.l10n.preferredCityQuestionTitle(),
      subtitle: context.l10n.cityPickerSearchHint(),
      showSkipOption: false,
    );

    if (!mounted) return;

    if (selected != null) {
      // Store the city name as the answer value so the generator can look it up.
      controller.selectAnswer(question.id, selected.id);
      controller.setPreferredCity(selected);
    }
  }

  void _handleTravelGroupSelect(Option option) {
    setState(() {
      _inlineHint = null;
    });
    controller.selectAnswer('travel_group', option.value);
  }

  void _handleTravelGroupChildrenSelect(String value) {
    setState(() {
      _inlineHint = null;
    });
    controller.selectAnswer('travel_group_children_count', value);
  }

  Future<void> _advanceAfterSelection(Question question) async {
    if (!_shouldAutoAdvance(question) ||
        !controller.canGoNext ||
        controller.isGeneratingPlan) {
      return;
    }

    if (!controller.isLastQuestion) {
      await controller.goNext();
      return;
    }

    if (controller.selectedVariant == QuestionnaireVariant.lean &&
        !controller.isRefineResolved) {
      await _generateAndReveal(controller.goNext);
      return;
    }

    await _generateAndReveal(controller.goNext);
  }

  Future<void> _generateAndReveal(Future<bool> Function() generation) async {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final stopwatch = Stopwatch()..start();

    setState(() {
      _showProcessingScreen = true;
      _processingError = null;
      _retryGeneration = generation;
    });

    try {
      final completed = await generation();
      if (!mounted) return;
      if (!completed) {
        setState(() {
          _showProcessingScreen = false;
          _retryGeneration = null;
        });
        return;
      }

      final remaining = RecommendationRevealTiming.remaining(
        elapsed: stopwatch.elapsed,
        reduceMotion: reduceMotion,
      );
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.migrationResultReveal);
    } catch (error, stackTrace) {
      debugPrint('Plan generation failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _processingError = error;
      });
    }
  }

  Future<void> _retryPlanGeneration() async {
    final retry = _retryGeneration;
    if (retry == null) return;
    await _generateAndReveal(retry);
  }

  void _cancelProcessing() {
    if (controller.isGeneratingPlan) return;
    setState(() {
      _showProcessingScreen = false;
      _processingError = null;
      _retryGeneration = null;
    });
  }

  void _handleMultiSelect(Question question, Option option) {
    final changed = controller.toggleAnswer(question.id, option.value);
    if (changed) {
      setState(() {
        _inlineHint = null;
      });
      return;
    }

    setState(() {
      _inlineHint = _selectionValidationLabel(context, question);
    });
  }

  String _selectionHelperLabel(BuildContext context, Question question) {
    if (question.id == 'support_needs') {
      return switch (Localizations.localeOf(context).languageCode) {
        'pt' => 'Marque todas as situações que se aplicam',
        'es' => 'Marcá todas las situaciones que correspondan',
        _ => 'Select every situation that applies',
      };
    }
    return context.l10n.questionnaireSelectionHelper(question.maxSelections);
  }

  String _selectionValidationLabel(BuildContext context, Question question) {
    return context.l10n.questionnaireSelectionValidation(
      question.maxSelections,
    );
  }

  String _selectionCounterLabel(int selected, int total) => '$selected/$total';
  String _displayOptionLabel(
    BuildContext context,
    String questionId,
    String value,
  ) {
    if (questionId == 'available_capital' && value != 'prefer_not_say') {
      return _availableCapitalOptionLabel(context, value);
    }
    if (const {
      'intent',
      'funding',
      'work_arrangement',
      'travel_group',
      'support_needs',
      'constraints',
    }.contains(questionId)) {
      return context.l10n.questionOptionLabel(questionId, value);
    }
    return context.l10n.questionnaireCompactOptionLabel(questionId, value);
  }

  String _availableCapitalOptionLabel(BuildContext context, String value) {
    final rangeSet = AvailableCapitalRangesStore.rangesForOrigin(
      controller.answerFor('origin_country'),
    );
    final language = Localizations.localeOf(context).languageCode;
    final first = MultiCurrencyAmount.formatAmount(
      context: context,
      sourceCurrencyCode: rangeSet.currencyCode,
      amount: rangeSet.bands[0],
    );
    final second = MultiCurrencyAmount.formatAmount(
      context: context,
      sourceCurrencyCode: rangeSet.currencyCode,
      amount: rangeSet.bands[1],
    );
    final third = MultiCurrencyAmount.formatAmount(
      context: context,
      sourceCurrencyCode: rangeSet.currencyCode,
      amount: rangeSet.bands[2],
    );

    return switch (value) {
      'low' =>
        language == 'en'
            ? 'Up to $first'
            : '${language == 'pt' ? 'Até' : 'Hasta'} $first',
      'medium' => '$first a $second',
      'high' => '$second a $third',
      'very_high' =>
        language == 'en'
            ? 'More than $third'
            : '${language == 'pt' ? 'Mais de' : 'Más de'} $third',
      _ => value,
    };
  }

  ButtonStyle _primaryButtonStyle(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return FilledButton.styleFrom(
      backgroundColor: isDark ? const Color(0xFF3D9CFF) : AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: isDark
          ? const Color(0xFF223246)
          : const Color(0xFFD8E6F6),
      disabledForegroundColor: isDark
          ? Colors.white.withValues(alpha: 0.46)
          : AppColors.textSoft.withValues(alpha: 0.70),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimaryFor(context),
      disabledForegroundColor: AppColors.textSoftFor(
        context,
      ).withValues(alpha: 0.55),
      backgroundColor: isDark
          ? const Color(0xFF162131).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.92),
      disabledBackgroundColor: isDark
          ? const Color(0xFF101822).withValues(alpha: 0.82)
          : const Color(0xFFF1F5FA).withValues(alpha: 0.86),
      side: BorderSide(
        color: isDark
            ? AppColors.accent.withValues(alpha: 0.24)
            : AppColors.primary.withValues(alpha: 0.18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  void _prepareScrollableScope(String key) {
    if (_scrollScopeKey == key) {
      return;
    }

    _scrollScopeKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_optionsScrollController.hasClients) {
        if (mounted && _showScrollHint) {
          setState(() {
            _showScrollHint = false;
          });
        }
        return;
      }

      _optionsScrollController.jumpTo(0);
      _updateScrollHint();
    });
  }

  void _updateScrollHint() {
    if (!_optionsScrollController.hasClients) {
      return;
    }

    final position = _optionsScrollController.position;
    final nextValue =
        position.maxScrollExtent > 24 &&
        position.pixels < position.maxScrollExtent - 24;
    if (nextValue != _showScrollHint && mounted) {
      setState(() {
        _showScrollHint = nextValue;
      });
    }
  }
}

class _SelectedPreferredCityCard extends StatelessWidget {
  const _SelectedPreferredCityCard({
    required this.city,
    required this.onChangeTap,
  });

  final City city;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      borderColor: isDark ? const Color(0xFF5BB6FF) : AppColors.primary,
      backgroundColor: AppColors.tintedSurfaceFor(
        context,
        tint: AppColors.primary,
        lightColor: const Color(0xFFEAF4FF),
        darkAlpha: 0.28,
        darkBase: const Color(0xFF162235),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                      .withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: isDark ? const Color(0xFF76C3FF) : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${city.stateName} · ${city.stateCode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? const Color(0xFF76C3FF) : AppColors.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChangeTap,
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text(l10n.preferredCityChangeLabel()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: (isDark ? const Color(0xFF5BB6FF) : AppColors.primary)
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferredCityStartCard extends StatelessWidget {
  const _PreferredCityStartCard({
    required this.city,
    required this.onChooseTap,
  });

  final City? city;
  final VoidCallback onChooseTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = AppColors.isDark(context);
    final hasCity = city != null;

    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      borderColor: hasCity
          ? (isDark ? const Color(0xFF5BB6FF) : AppColors.primary)
          : (isDark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0x14071B3A)),
      backgroundColor: hasCity
          ? AppColors.tintedSurfaceFor(
              context,
              tint: AppColors.primary,
              lightColor: const Color(0xFFEAF4FF),
              darkAlpha: 0.28,
              darkBase: const Color(0xFF162235),
            )
          : (isDark
                ? const Color(0xFF131C29).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasCity
                      ? (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                            .withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF0F5FA)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: hasCity
                      ? (isDark ? const Color(0xFF76C3FF) : AppColors.primary)
                      : AppColors.textSoftFor(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.preferredCityStartWithCityTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.preferredCityStartWithCitySubtitle(),
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
          const SizedBox(height: 14),
          if (hasCity)
            _SelectedPreferredCityCard(city: city!, onChangeTap: onChooseTap)
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onChooseTap,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(l10n.preferredCityChooseCityLabel()),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionStartCard extends StatelessWidget {
  const _SuggestionStartCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardBackground = isSelected
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFEAF4FF),
            darkAlpha: 0.28,
            darkBase: const Color(0xFF162235),
          )
        : (isDark
              ? const Color(0xFF131C29).withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: 0.96));
    final cardBorder = isSelected
        ? (isDark ? const Color(0xFF5BB6FF) : AppColors.primary)
        : (isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0x14071B3A));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: FrostedPanel(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(24),
          borderColor: cardBorder,
          backgroundColor: cardBackground,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                            .withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF0F5FA)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.explore_outlined,
                  color: isSelected
                      ? (isDark ? const Color(0xFF76C3FF) : AppColors.primary)
                      : AppColors.textSoftFor(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                      : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: (isDark ? Colors.white : AppColors.primary)
                              .withValues(alpha: 0.3),
                        ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact horizontal option row (~44px) ────────────────────────────────────
class _CompactOptionRow extends StatelessWidget {
  const _CompactOptionRow({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHighest,
            border: isSelected
                ? Border.all(color: cs.primary, width: 1.5)
                : Border.all(color: cs.outline.withValues(alpha: 0.20)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? cs.primary : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(color: cs.outline.withValues(alpha: 0.35)),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Priority pill chip (multi-select) ────────────────────────────────────────
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          border: isSelected
              ? Border.all(color: cs.primary, width: 1.5)
              : Border.all(color: cs.outline.withValues(alpha: 0.20)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionStatusCard extends StatelessWidget {
  const _SelectionStatusCard({
    required this.label,
    required this.counter,
    required this.isComplete,
  });

  final String label;
  final String counter;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final tint = isComplete ? AppColors.success : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: tint,
          lightColor: isComplete
              ? const Color(0xFFF1F8F3)
              : const Color(0xFFEFF5FF),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: tint,
            lightColor: tint.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              counter,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginDestinationStep extends StatefulWidget {
  const _OriginDestinationStep({
    required this.controller,
    required this.question,
    required this.onOriginTap,
    required this.onDestinationTap,
  });

  final MigrationQuestionnaireController controller;
  final Question question;
  final ValueChanged<Option> onOriginTap;
  final Future<void> Function(String countryId) onDestinationTap;

  @override
  State<_OriginDestinationStep> createState() => _OriginDestinationStepState();
}

class _OriginDestinationStepState extends State<_OriginDestinationStep> {
  MigrationQuestionnaireController get controller => widget.controller;
  bool _didAutoSelectDestination = false;

  @override
  Widget build(BuildContext context) {
    final journey = controller.journeyContextController;
    final selectedOrigin = controller.answerFor(widget.question.id);
    final selectedDestination = journey.destinationCountryId;
    final originCountries = _availableOriginCountries();
    final destinationCountries = _availableDestinationCountries();

    if (!_didAutoSelectDestination &&
        selectedDestination == null &&
        destinationCountries.length == 1) {
      _didAutoSelectDestination = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(widget.onDestinationTap(destinationCountries.first.id));
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionRoutePanel(
          title: context.l10n.journeyDestinationSectionTitle,
          body: context.l10n.journeyDestinationSectionBody,
          pickerTitle: context.l10n.journeyPickerChooseDestinationTitle,
          countries: destinationCountries,
          selectedCountryId: selectedDestination,
          availabilityLabelFor: (country) =>
              _coverageLabel(context, country.coverage.destinationStatus),
          isSelectable: journey.canChooseAsDestination,
          useQuickChoices: destinationCountries.length <= 4,
          onOpenPicker: () => _openCountryPicker(
            title: context.l10n.journeyPickerChooseDestinationTitle,
            countries: destinationCountries,
            selectedCountryId: selectedDestination,
            availabilityLabelFor: (country) =>
                _coverageLabel(context, country.coverage.destinationStatus),
            isSelectable: journey.canChooseAsDestination,
            onSelect: (country) => widget.onDestinationTap(country.id),
          ),
          onTap: (country) => widget.onDestinationTap(country.id),
        ),
        const SizedBox(height: 16),
        _QuestionRoutePanel(
          title: context.l10n.journeyOriginSectionTitle,
          body: context.l10n.journeyOriginSectionBody,
          pickerTitle: context.l10n.journeyPickerChooseOriginTitle,
          countries: originCountries,
          selectedCountryId: _countryIdForJourneyValue(selectedOrigin),
          availabilityLabelFor: (country) =>
              _coverageLabel(context, country.coverage.originStatus),
          isSelectable: journey.canChooseAsOrigin,
          onOpenPicker: () => _openCountryPicker(
            title: context.l10n.journeyPickerChooseOriginTitle,
            countries: originCountries,
            selectedCountryId: _countryIdForJourneyValue(selectedOrigin),
            availabilityLabelFor: (country) =>
                _coverageLabel(context, country.coverage.originStatus),
            isSelectable: journey.canChooseAsOrigin,
            onSelect: _selectOriginCountry,
          ),
          onTap: _selectOriginCountry,
        ),
      ],
    );
  }

  List<CatalogCountry> _availableOriginCountries() {
    final allowedValues = widget.question.options
        .map((option) => option.value)
        .toSet();
    return controller.journeyContextController.availableOrigins
        .where(
          (country) =>
              controller.journeyContextController.journeyValueFor(country) ==
                  'argentina' &&
              allowedValues.contains(
                controller.journeyContextController.journeyValueFor(country),
              ),
        )
        .toList(growable: false);
  }

  List<CatalogCountry> _availableDestinationCountries() {
    return controller.journeyContextController.availableDestinations
        .where(
          (country) =>
              controller.journeyContextController.journeyValueFor(country) ==
              'brazil',
        )
        .toList(growable: false);
  }

  String? _countryIdForJourneyValue(String? value) {
    if (value == null) {
      return null;
    }

    for (final country
        in controller.journeyContextController.availableOrigins) {
      if (controller.journeyContextController.journeyValueFor(country) ==
          value) {
        return country.id;
      }
    }

    return null;
  }

  Future<void> _selectOriginCountry(CatalogCountry country) async {
    final option = widget.question.options
        .where(
          (item) =>
              item.value ==
              controller.journeyContextController.journeyValueFor(country),
        )
        .firstOrNull;
    if (option == null) {
      return;
    }

    widget.onOriginTap(option);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openCountryPicker({
    required String title,
    required List<CatalogCountry> countries,
    required String? selectedCountryId,
    required String Function(CatalogCountry country) availabilityLabelFor,
    required bool Function(CatalogCountry country) isSelectable,
    required Future<void> Function(CatalogCountry country) onSelect,
  }) async {
    final selected = await showModalBottomSheet<CatalogCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _QuestionCountryPickerSheet(
        title: title,
        countries: countries,
        selectedCountryId: selectedCountryId,
        availabilityLabelFor: availabilityLabelFor,
        isSelectable: isSelectable,
      ),
    );

    if (selected == null) {
      return;
    }

    await onSelect(selected);
  }

  String _coverageLabel(BuildContext context, CoverageStatus status) {
    return switch (status) {
      CoverageStatus.full => context.l10n.journeyCoverageFull,
      CoverageStatus.partial => context.l10n.journeyCoveragePartial,
      CoverageStatus.unsupported => context.l10n.journeyCoverageUnsupported,
    };
  }
}

class _QuestionRoutePanel extends StatelessWidget {
  const _QuestionRoutePanel({
    required this.title,
    required this.body,
    required this.pickerTitle,
    required this.countries,
    required this.selectedCountryId,
    required this.availabilityLabelFor,
    required this.isSelectable,
    required this.onOpenPicker,
    required this.onTap,
    this.useQuickChoices = false,
  });

  final String title;
  final String body;
  final String pickerTitle;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final String Function(CatalogCountry country) availabilityLabelFor;
  final bool Function(CatalogCountry country) isSelectable;
  final VoidCallback onOpenPicker;
  final ValueChanged<CatalogCountry> onTap;
  final bool useQuickChoices;

  @override
  Widget build(BuildContext context) {
    CatalogCountry? selectedCountry;
    for (final country in countries) {
      if (country.id == selectedCountryId) {
        selectedCountry = country;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        if (useQuickChoices)
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 300 ? 1 : 2;
              const spacing = 10.0;
              final tileWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final country in countries)
                    SizedBox(
                      width: tileWidth,
                      child: _QuestionInlineCountryCard(
                        country: country,
                        isSelected: selectedCountryId == country.id,
                        isEnabled: isSelectable(country),
                        availabilityLabel: availabilityLabelFor(country),
                        onTap: isSelectable(country)
                            ? () => onTap(country)
                            : null,
                      ),
                    ),
                ],
              );
            },
          )
        else
          _QuestionCountryPickerSummaryCard(
            title: pickerTitle,
            placeholder: title,
            selectedCountry: selectedCountry,
            availabilityLabel: selectedCountry == null
                ? null
                : availabilityLabelFor(selectedCountry),
            onTap: onOpenPicker,
          ),
      ],
    );
  }
}

class _QuestionInlineCountryCard extends StatelessWidget {
  const _QuestionInlineCountryCard({
    required this.country,
    required this.isSelected,
    required this.isEnabled,
    required this.availabilityLabel,
    required this.onTap,
  });

  final CatalogCountry country;
  final bool isSelected;
  final bool isEnabled;
  final String availabilityLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final localizedCountryName = context.l10n.countryLabel(
      country.journeyValue,
    );
    final isDark = AppColors.isDark(context);
    final background = isSelected
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFEAF4FF),
            darkAlpha: 0.24,
            darkBase: const Color(0xFF182536),
          )
        : (isDark
              ? const Color(
                  0xFF131C29,
                ).withValues(alpha: isEnabled ? 0.95 : 0.74)
              : Colors.white.withValues(alpha: isEnabled ? 0.96 : 0.84));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0x16071B3A)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(country.flagEmoji, style: const TextStyle(fontSize: 22)),
                  const Spacer(),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : isEnabled
                        ? Icons.radio_button_unchecked_rounded
                        : Icons.schedule_rounded,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSoftFor(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                localizedCountryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isEnabled
                      ? AppColors.textPrimaryFor(context)
                      : AppColors.textSoftFor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                availabilityLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isEnabled
                      ? AppColors.primary
                      : AppColors.textSoftFor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCountryPickerSummaryCard extends StatelessWidget {
  const _QuestionCountryPickerSummaryCard({
    required this.title,
    required this.placeholder,
    required this.selectedCountry,
    required this.availabilityLabel,
    required this.onTap,
  });

  final String title;
  final String placeholder;
  final CatalogCountry? selectedCountry;
  final String? availabilityLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final country = selectedCountry;
    final localizedCountryName = country == null
        ? placeholder
        : context.l10n.countryLabel(country.journeyValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedFor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  country?.flagEmoji ?? '🌎',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizedCountryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (availabilityLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        availabilityLabel!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCountryPickerSheet extends StatefulWidget {
  const _QuestionCountryPickerSheet({
    required this.title,
    required this.countries,
    required this.selectedCountryId,
    required this.availabilityLabelFor,
    required this.isSelectable,
  });

  final String title;
  final List<CatalogCountry> countries;
  final String? selectedCountryId;
  final String Function(CatalogCountry country) availabilityLabelFor;
  final bool Function(CatalogCountry country) isSelectable;

  @override
  State<_QuestionCountryPickerSheet> createState() =>
      _QuestionCountryPickerSheetState();
}

class _QuestionCountryPickerSheetState
    extends State<_QuestionCountryPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.countries
            .where((country) {
              final normalizedQuery = _query.trim().toLowerCase();
              if (normalizedQuery.isEmpty) {
                return true;
              }
              final localizedName = context.l10n.countryLabel(
                country.journeyValue,
              );
              return localizedName.toLowerCase().contains(normalizedQuery);
            })
            .toList(growable: false)
          ..sort((left, right) {
            final leftSelected = left.id == widget.selectedCountryId ? 1 : 0;
            final rightSelected = right.id == widget.selectedCountryId ? 1 : 0;
            if (leftSelected != rightSelected) {
              return rightSelected.compareTo(leftSelected);
            }

            final leftSelectable = widget.isSelectable(left) ? 1 : 0;
            final rightSelectable = widget.isSelectable(right) ? 1 : 0;
            if (leftSelectable != rightSelectable) {
              return rightSelectable.compareTo(leftSelectable);
            }

            return context.l10n
                .countryLabel(left.journeyValue)
                .compareTo(context.l10n.countryLabel(right.journeyValue));
          });

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return FrostedPanel(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSoftFor(
                      context,
                    ).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: context.l10n.journeyPickerSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.journeyPickerNoResults,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final country = filtered[index];
                          return _QuestionInlineCountryCard(
                            country: country,
                            isSelected: widget.selectedCountryId == country.id,
                            isEnabled: widget.isSelectable(country),
                            availabilityLabel: widget.availabilityLabelFor(
                              country,
                            ),
                            onTap: widget.isSelectable(country)
                                ? () => Navigator.of(context).pop(country)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TravelGroupChildrenSelector extends StatelessWidget {
  const _TravelGroupChildrenSelector({
    required this.selectedValue,
    required this.onSelected,
  });

  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final title = switch (language) {
      'pt' => 'Quantos filhos?',
      'es' => '¿Cuántos hijos?',
      _ => 'How many kids?',
    };

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
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final value in const ['1', '2', '3+'])
                ChoiceChip(
                  label: Text(value),
                  selected: selectedValue == value,
                  onSelected: (_) => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProcessingState extends StatefulWidget {
  const _ProcessingState({
    required this.error,
    required this.onRetry,
    required this.onBack,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final VoidCallback onBack;

  @override
  State<_ProcessingState> createState() => _ProcessingStateState();
}

class _ProcessingStateState extends State<_ProcessingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _stageTimer;
  int _stage = 0;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _stageTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!mounted || _stage >= 3 || widget.error != null) return;
      setState(() => _stage += 1);
    });
  }

  @override
  void didUpdateWidget(covariant _ProcessingState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != null && widget.error == null) {
      _stage = 0;
    }
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  List<String> _stageLabels(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => const [
        'Entendendo suas prioridades',
        'Comparando cidades com o seu perfil',
        'Encontrando os melhores encaixes',
        'Preparando sua shortlist',
      ],
      'es' => const [
        'Entendiendo tus prioridades',
        'Comparando ciudades con tu perfil',
        'Encontrando las mejores coincidencias',
        'Preparando tu lista final',
      ],
      _ => const [
        'Understanding your priorities',
        'Comparing cities with your profile',
        'Finding the strongest matches',
        'Preparing your shortlist',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final labels = _stageLabels(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (widget.error != null) {
      final title = switch (locale) {
        'pt' => 'Não conseguimos concluir a comparação',
        'es' => 'No pudimos completar la comparación',
        _ => 'We could not finish the comparison',
      };
      final body = switch (locale) {
        'pt' =>
          'Suas respostas continuam salvas. Tente novamente quando quiser.',
        'es' =>
          'Tus respuestas siguen guardadas. Inténtalo de nuevo cuando quieras.',
        _ => 'Your answers are still saved. Try again whenever you are ready.',
      };
      final retryLabel = switch (locale) {
        'pt' => 'Tentar novamente',
        'es' => 'Intentar de nuevo',
        _ => 'Try again',
      };
      final backLabel = switch (locale) {
        'pt' => 'Voltar às respostas',
        'es' => 'Volver a las respuestas',
        _ => 'Back to answers',
      };

      return Semantics(
        liveRegion: true,
        label: '$title. $body',
        child: Center(
          child: FrostedPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: AppColors.danger,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(retryLabel),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: widget.onBack, child: Text(backLabel)),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      label: labels[_stage],
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _motion,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RecommendationConstellationPainter(
                    progress: reduceMotion ? 0.72 : _motion.value,
                    stage: _stage,
                    isDark: AppColors.isDark(context),
                  ),
                  child: Center(
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5BA8FF), Color(0xFF315BEA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.30),
                            blurRadius: 42,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_pin_circle_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            labels[_stage],
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            switch (locale) {
              'pt' => 'Cruzando suas respostas com sinais reais das cidades',
              'es' =>
                'Cruzando tus respuestas con señales reales de las ciudades',
              _ => 'Matching your answers with real city signals',
            },
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final active = index <= _stage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 22 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : AppColors.textSoftFor(context).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _RecommendationConstellationPainter extends CustomPainter {
  const _RecommendationConstellationPainter({
    required this.progress,
    required this.stage,
    required this.isDark,
  });

  final double progress;
  final int stage;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF5BA8FF).withValues(alpha: 0.18);
    final activeRoutePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5BA8FF).withValues(alpha: 0.58);

    for (var index = 0; index < 8; index += 1) {
      final angle = (math.pi * 2 * index / 8) - math.pi / 2;
      final orbit = radius * (index.isEven ? 1 : 0.78);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * orbit;
      final selected = index < math.min(stage + 1, 3);
      final reveal = ((progress * 1.5) - (index * 0.06)).clamp(0.0, 1.0);
      final routeEnd = Offset.lerp(center, point, reveal)!;
      canvas.drawLine(
        center,
        routeEnd,
        selected ? activeRoutePaint : routePaint,
      );

      final pulse = 1 + (math.sin((progress * math.pi * 2) + index) * 0.12);
      final dotRadius = (selected ? 7.0 : 4.0) * pulse * reveal;
      canvas.drawCircle(
        point,
        dotRadius + (selected ? 6 : 2),
        Paint()
          ..color = (selected ? const Color(0xFF37D39A) : Colors.white)
              .withValues(alpha: selected ? 0.10 : 0.04),
      );
      canvas.drawCircle(
        point,
        dotRadius,
        Paint()
          ..color = (selected ? const Color(0xFF37D39A) : Colors.white)
              .withValues(alpha: selected ? 0.92 : (isDark ? 0.44 : 0.60)),
      );
    }

    canvas.drawCircle(
      center,
      radius * (0.34 + (0.03 * math.sin(progress * math.pi * 2))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF5BA8FF).withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant _RecommendationConstellationPainter old) =>
      old.progress != progress || old.stage != stage || old.isDark != isDark;
}

class _RefinementHero extends StatelessWidget {
  const _RefinementHero({
    required this.eyebrow,
    required this.optionalLabel,
    required this.title,
    required this.body,
    required this.questionCount,
    required this.time,
    required this.beforeLabel,
    required this.afterLabel,
  });

  final String eyebrow;
  final String optionalLabel;
  final String title;
  final String body;
  final String questionCount;
  final String time;
  final String beforeLabel;
  final String afterLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07162B), Color(0xFF0E3769), Color(0xFF0877C9)],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -76,
            top: -84,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF86D9FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      eyebrow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF9FDDFF),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.25,
                      ),
                    ),
                  ),
                  _RefinementPill(
                    icon: Icons.check_circle_outline_rounded,
                    label: optionalLabel,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 570),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 590),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                    height: 1.42,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RefinementPill(
                    icon: Icons.help_outline_rounded,
                    label: questionCount,
                  ),
                  _RefinementPill(icon: Icons.schedule_rounded, label: time),
                ],
              ),
              const SizedBox(height: 20),
              _RefinementPreview(
                beforeLabel: beforeLabel,
                afterLabel: afterLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefinementPill extends StatelessWidget {
  const _RefinementPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefinementPreview extends StatelessWidget {
  const _RefinementPreview({
    required this.beforeLabel,
    required this.afterLabel,
  });

  final String beforeLabel;
  final String afterLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF041225).withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RefinementRanking(
              label: beforeLabel,
              widths: const [0.76, 0.72, 0.68],
              emphasizeFirst: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF43C6FF).withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF8BE0FF),
              ),
            ),
          ),
          Expanded(
            child: _RefinementRanking(
              label: afterLabel,
              widths: const [0.94, 0.69, 0.48],
              emphasizeFirst: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefinementRanking extends StatelessWidget {
  const _RefinementRanking({
    required this.label,
    required this.widths,
    required this.emphasizeFirst,
  });

  final String label;
  final List<double> widths;
  final bool emphasizeFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.62),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        for (var index = 0; index < widths.length; index++) ...[
          FractionallySizedBox(
            widthFactor: widths[index],
            child: Container(
              height: index == 0 && emphasizeFirst ? 7 : 5,
              decoration: BoxDecoration(
                color: index == 0 && emphasizeFirst
                    ? const Color(0xFF55D6B0)
                    : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (index != widths.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _RefinementBenefits extends StatelessWidget {
  const _RefinementBenefits({
    required this.title,
    required this.rankingBenefit,
    required this.contextBenefit,
  });

  final String title;
  final String rankingBenefit;
  final String contextBenefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF2F7FD),
          darkBase: const Color(0xFF121D2B),
          darkAlpha: 0.18,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.tintedBorderFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFDCEAF8),
            darkAlpha: 0.20,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          _RefinementBenefitRow(
            icon: Icons.swap_vert_rounded,
            label: rankingBenefit,
          ),
          const SizedBox(height: 10),
          _RefinementBenefitRow(
            icon: Icons.person_pin_circle_outlined,
            label: contextBenefit,
          ),
        ],
      ),
    );
  }
}

class _RefinementBenefitRow extends StatelessWidget {
  const _RefinementBenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: AppColors.isDark(context) ? 0.20 : 0.10,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionLocationDialog extends StatelessWidget {
  const _QuestionLocationDialog({
    required this.title,
    required this.body,
    this.secondaryLabel,
    required this.primaryLabel,
  });

  final String title;
  final String body;
  final String? secondaryLabel;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: FrostedPanel(
        padding: const EdgeInsets.all(22),
        borderRadius: BorderRadius.circular(28),
        backgroundColor: AppColors.isDark(context)
            ? const Color(0xEE0F1722)
            : const Color(0xF7FFFFFF),
        borderColor: AppColors.isDark(context)
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (secondaryLabel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(secondaryLabel!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location pre-check screen (shown before step 1 in strategic flow) ─────────
//
// Case A: GPS already granted + city detected → confirmation
// Case B: Not asked yet → permission request
// Case C: Denied / permanently denied → manual Argentine city picker
class _LocationPrecheck extends StatefulWidget {
  const _LocationPrecheck({
    required this.locationController,
    required this.onComplete,
  });

  final LocationController locationController;

  /// Called when the user completes this screen.
  /// [argentineOrigin] is non-null only in Case C when user picks a city.
  final void Function(String? argentineOrigin) onComplete;

  @override
  State<_LocationPrecheck> createState() => _LocationPrecheckState();
}

class _LocationPrecheckState extends State<_LocationPrecheck> {
  bool _isRequesting = false;
  String? _selectedOrigin;

  // Argentine origin options (same as removed argentina_origin question)
  static const _argentineOrigins = [
    ('buenos_aires', Icons.location_city_outlined),
    ('cordoba', Icons.place_outlined),
    ('mendoza', Icons.landscape_outlined),
    ('rosario', Icons.anchor_outlined),
    ('salta_jujuy', Icons.forest_outlined),
    ('litoral', Icons.water_outlined),
    ('other_origin', Icons.add_location_alt_outlined),
  ];

  String _originLabel(BuildContext context, String value) {
    return switch (value) {
      'buenos_aires' => 'Buenos Aires',
      'cordoba' => 'Córdoba',
      'mendoza' => 'Mendoza',
      'rosario' => 'Rosario',
      'salta_jujuy' => 'Salta / Jujuy',
      'litoral' => context.l10n.questionArgentinaOriginLitoral,
      _ => context.l10n.questionArgentinaOriginOther,
    };
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    await widget.locationController.requestPermissionAndCapture();
    if (mounted) setState(() => _isRequesting = false);
    // After requesting, rebuild will show Case A or C
  }

  @override
  Widget build(BuildContext context) {
    final lc = widget.locationController;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasGranted = lc.hasGrantedPermission;
    final isPermanentlyDenied = lc.isPermanentlyDenied;
    final hasSavedLocation = lc.savedLocation != null;

    // Case A: GPS granted + city detected
    if (hasGranted && hasSavedLocation) {
      final city = lc.savedLocation!.cityName.isNotEmpty
          ? lc.savedLocation!.cityName
          : lc.savedLocation!.stateName;
      final country = lc.savedLocation!.countryName;
      return _buildConfirmation(context, cs, tt, city, country);
    }

    // Case C: permanently denied → manual picker
    if (isPermanentlyDenied || lc.permissionStatus == 'denied') {
      return _buildManualPicker(context, cs, tt);
    }

    // Case B: not asked yet → show request UI
    return _buildRequestScreen(context, cs, tt);
  }

  Widget _buildConfirmation(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    String city,
    String country,
  ) {
    final title = context.l10n.questionLocationDetectedTitle;
    final subtitle = context.l10n.questionLocationDetectedBody(city, country);
    final ctaLabel = context.l10n.questionLocationContinueAction;

    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Icon(Icons.my_location_rounded, size: 40, color: cs.primary),
          const SizedBox(height: 20),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: tt.bodyMedium),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => widget.onComplete(null),
              child: Text(ctaLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestScreen(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final title = context.l10n.questionLocationRequestTitle;
    final subtitle = context.l10n.questionLocationRequestBody;
    final ctaLabel = context.l10n.questionLocationUseAction;
    final skipLabel = context.l10n.questionLocationChooseManualAction;

    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Icon(Icons.location_on_outlined, size: 40, color: cs.primary),
          const SizedBox(height: 20),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: tt.bodyMedium),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isRequesting ? null : _requestPermission,
              child: _isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(ctaLabel),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showManualPickerSheet(context),
              child: Text(skipLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualPicker(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final title = context.l10n.questionLocationManualTitle;
    final ctaLabel = context.l10n.questionLocationContinueAction;

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _argentineOrigins.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final (value, iconData) = _argentineOrigins[index];
                final isSelected = _selectedOrigin == value;
                return _CompactOptionRow(
                  icon: iconData,
                  label: _originLabel(context, value),
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedOrigin = value);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedOrigin != null
                  ? () => widget.onComplete(_selectedOrigin)
                  : null,
              child: Text(ctaLabel),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualPickerSheet(BuildContext context) async {
    // Dismiss current and go to manual picker by simulating a permanent deny
    await widget.locationController.deferPermission();
    if (mounted) setState(() {});
  }
}

// ─── Favorites context banner ─────────────────────────────────────────────────

/// Shown at the top of the questionnaire when the user has ≥2 favorites.
/// Communicates that the answers will be used to compare known cities —
/// reduces the sense of answering "blind" questions with no visible outcome.
class _FavoritesContextBanner extends StatelessWidget {
  const _FavoritesContextBanner({required this.favorites});

  final List<City> favorites;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = AppColors.isDark(context);

    final cityNames = favorites.map((c) => c.name).join(' · ');
    final body = switch (locale) {
      'pt' =>
        'Suas respostas vão comparar $cityNames e encontrar a melhor para você.',
      'es' =>
        'Tus respuestas van a comparar $cityNames y encontrar la mejor para vos.',
      _ =>
        'Your answers will compare $cityNames and find the best match for you.',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

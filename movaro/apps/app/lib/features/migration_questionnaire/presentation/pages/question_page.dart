import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/country_coverage.dart';
import 'package:movaro_app/core/journey/detected_location.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/location/location_data.dart';
import 'package:movaro_app/core/location/presentation/pages/location_permission_screen.dart';
import 'package:movaro_app/core/location/presentation/widgets/location_banner_widget.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/available_capital_ranges_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/question_progress_indicator.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    required this.controller,
    required this.locationController,
    super.key,
  });

  final MigrationQuestionnaireController controller;
  final LocationController locationController;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  static const _helpPreferenceKey = 'questionnaire_flow';
  String? _inlineHint;
  bool _showProcessingScreen = false;
  bool _didPromptOriginLocation = false;
  final ScrollController _optionsScrollController = ScrollController();
  String? _scrollScopeKey;
  bool _showScrollHint = false;
  bool _didTryAutoHelp = false;

  MigrationQuestionnaireController get controller => widget.controller;
  LocationController get locationController => widget.locationController;

  @override
  void initState() {
    super.initState();
    _optionsScrollController.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.initialize());
      unawaited(_maybeShowHelp());
    });
  }

  Future<void> _maybeShowHelp() async {
    if (_didTryAutoHelp) {
      return;
    }
    _didTryAutoHelp = true;
    await maybeShowContextualHelpGuide(
      context,
      preferenceKey: _helpPreferenceKey,
      content: _helpContent(context),
    );
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
      eyebrow: context.l10n.questionnairePageTitle,
      contextIcon: Icons.quiz_outlined,
      title: context.l10n.questionnaireGuideTitle(),
      body: context.l10n.questionnaireGuideBody(),
      steps: [
        FeatureGuideStep(
          number: '1',
          title: context.l10n.questionnaireGuideStepOneTitle(),
          body: context.l10n.questionnaireGuideStepOneBody(),
        ),
        FeatureGuideStep(
          number: '2',
          title: context.l10n.questionnaireGuideStepTwoTitle(),
          body: context.l10n.questionnaireGuideStepTwoBody(),
        ),
        FeatureGuideStep(
          number: '3',
          title: context.l10n.questionnaireGuideStepThreeTitle(),
          body: context.l10n.questionnaireGuideStepThreeBody(),
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
                      child: !controller.hasSelectedVariant
                          ? _buildVariantSelectionScreen(context)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppGlassHeader(
                                  title: l10n.questionnairePageTitle,
                                  onBack: () => _handleExitFlow(context),
                                  onHelp: _showHelp,
                                ),
                                const SizedBox(height: 20),
                                if (_showProcessingScreen)
                                  Expanded(
                                    child: _ProcessingState(
                                      title: l10n.questionnaireProcessingTitle,
                                    ),
                                  )
                                else if (controller.isInitializing)
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
                                    child: _buildQuestionFlow(
                                      context,
                                      question,
                                    ),
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

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bmpRefineTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _RefineIllustration(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: _secondaryButtonStyle(context),
                  onPressed: controller.goBack,
                  child: Text(l10n.bmpCtaBack),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: _secondaryButtonStyle(context),
                  onPressed: () async {
                    final completed = await controller.skipRefine();
                    if (completed && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.migrationPlanResult,
                      );
                    }
                  },
                  child: Text(l10n.bmpCtaRefineNo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: _primaryButtonStyle(context),
              onPressed: controller.acceptRefine,
              child: Text(l10n.bmpCtaRefineYes),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExitFlow(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ExitFlowDialog(
        title: context.l10n.bmpExitDialogTitle,
        body: context.l10n.bmpExitDialogBody,
        stayLabel: context.l10n.bmpExitDialogStay,
        leaveLabel: context.l10n.bmpExitDialogLeave,
      ),
    );

    if (!context.mounted || shouldLeave != true) {
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

  Widget _buildVariantSelector(BuildContext context) {
    final l10n = context.l10n;
    _prepareScrollableScope('variant_selector');

    return SingleChildScrollView(
      child: Column(
        children: [
          _QuestionnaireVariantHeader(
            eyebrow: l10n.questionnaireVariantEyebrow(),
            title: l10n.questionnaireVariantHeroTitle(),
            body: l10n.questionnaireVariantHeroBody(),
          ),
          const SizedBox(height: 10),
          _QuestionnaireVariantPrimaryCard(
            badge: l10n.questionnaireVariantLeanBadge(),
            title: l10n.bmpVariantLeanTitle,
            body: l10n.questionnaireVariantLeanDescription(),
            timeValue: l10n.questionnaireVariantLeanTime(),
            timeLabel: l10n.questionnaireVariantTimeLabel(),
            questionValue: l10n.questionnaireVariantLeanQuestionCount(),
            questionLabel: l10n.questionnaireVariantCountLabel(),
            actionLabel: l10n.questionnaireVariantLeanAction(),
            onTap: () => controller.selectVariant(QuestionnaireVariant.lean),
          ),
          const SizedBox(height: 14),
          _QuestionnaireVariantSeparator(
            label: l10n.questionnaireVariantSeparator(),
          ),
          const SizedBox(height: 14),
          _QuestionnaireVariantSecondaryCard(
            badge: l10n.questionnaireVariantStrategicBadge(),
            title: l10n.bmpVariantStrategicTitle,
            body: l10n.questionnaireVariantStrategicDescription(),
            timeValue: l10n.questionnaireVariantStrategicTime(),
            timeLabel: l10n.questionnaireVariantTimeLabel(),
            questionValue: l10n.questionnaireVariantStrategicQuestionCount(),
            questionLabel: l10n.questionnaireVariantCountLabel(),
            actionLabel: l10n.questionnaireVariantStrategicAction(),
            onTap: () =>
                controller.selectVariant(QuestionnaireVariant.strategic),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVariantSelectionScreen(BuildContext context) {
    return Column(
      children: [
        _QuestionnaireVariantAppBar(
          title: context.l10n.questionnaireVariantPageTitle(),
          onBack: () => _handleExitFlow(context),
          onHelp: _showHelp,
        ),
        Expanded(child: _buildVariantSelector(context)),
      ],
    );
  }

  Widget _buildQuestionFlow(BuildContext context, Question question) {
    final l10n = context.l10n;
    const showPrimaryAction = true;
    _prepareScrollableScope(question.id);

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
                l10n.questionTitle(question.id),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              if (question.id == 'priorities') ...[
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
              ] else if (question.id == 'constraints') ...[
                const SizedBox(height: 10),
                _QuestionSubnote(
                  label: _selectionHelperLabel(context, question),
                ),
              ] else if (question.id == 'funding') ...[
                const SizedBox(height: 10),
                _QuestionSubnote(label: _compactHintLabel(context, question)),
              ] else if (_sectionTransitionHint(context, question)
                  case final hint?) ...[
                const SizedBox(height: 10),
                _QuestionSubnote(label: hint),
              ] else if (question.id == 'intent' ||
                  question.id == 'timeline') ...[
                const SizedBox(height: 10),
                _QuestionSubnote(label: l10n.bmpScrollHint),
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
                  child: _ScrollableOptionsViewport(
                    controller: _optionsScrollController,
                    showHint: _showScrollHint,
                    hintLabel: l10n.bmpScrollHint,
                    child: _buildQuestionOptions(context, question),
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
        controller.selectedVariant == QuestionnaireVariant.lean ? 30 : 40;
    final minutes = ((remaining * secondsPerQuestion) / 60).ceil();
    return _localizedText(
      context,
      pt: minutes <= 1 ? 'menos de 1 min' : '~$minutes min restantes',
      es: minutes <= 1 ? 'menos de 1 min' : '~$minutes min restantes',
      en: minutes <= 1 ? 'under 1 min left' : '~$minutes min left',
    );
  }

  Widget _buildQuestionOptions(BuildContext context, Question question) {
    if (question.id == 'origin_country') {
      return SingleChildScrollView(
        controller: _optionsScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<bool>(
              future: locationController.shouldShowInlineBanner(),
              builder: (context, snapshot) {
                if (snapshot.data != true) {
                  return const SizedBox.shrink();
                }

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

    if (question.id == 'travel_group') {
      final selectedValue = controller.answerFor(question.id);
      final selectedChildrenCount = controller.answerFor(
        'travel_group_children_count',
      );
      final labels = question.options
          .map(
            (option) => _displayOptionLabel(context, question.id, option.value),
          )
          .toList(growable: false);
      final layout = _resolveQuestionOptionLayout(question, labels);

      return SingleChildScrollView(
        controller: _optionsScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactOptionGrid(
              context: context,
              question: question,
              labels: labels,
              selectedValues: {selectedValue ?? ''},
              isMultiSelect: false,
              compact: layout == _QuestionOptionLayout.compactGrid,
            ),
            if (selectedValue == 'family_kids') ...[
              const SizedBox(height: 12),
              _TravelGroupChildrenSelector(
                selectedValue: selectedChildrenCount,
                onSelected: _handleTravelGroupChildrenSelect,
              ),
            ],
          ],
        ),
      );
    }

    if (question.id == 'priorities') {
      final values = controller.answerValuesFor(question.id);
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 300 ? 1 : 2;
          final spacing = 10.0;
          final tileWidth =
              (constraints.maxWidth - (spacing * (columns - 1))) / columns;

          return SingleChildScrollView(
            controller: _optionsScrollController,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final option in question.options)
                  SizedBox(
                    width: tileWidth,
                    child: _PriorityOptionCard(
                      label: _displayOptionLabel(
                        context,
                        question.id,
                        option.value,
                      ),
                      icon: _priorityIcon(option.value),
                      isSelected: values.contains(option.value),
                      onTap: () => _handleMultiSelect(question, option),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    final labels = question.options
        .map(
          (option) => _displayOptionLabel(context, question.id, option.value),
        )
        .toList(growable: false);
    final layout = _resolveQuestionOptionLayout(question, labels);

    switch (question.type) {
      case 'single_card':
        if (layout == _QuestionOptionLayout.list) {
          return ListView.separated(
            controller: _optionsScrollController,
            itemCount: question.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = question.options[index];
              return _LargeOptionCard(
                icon: _optionIcon(question.id, option.value),
                label: labels[index],
                isSelected: controller.answerFor(question.id) == option.value,
                onTap: () => _handleSingleSelect(question, option),
              );
            },
          );
        }
        return _buildCompactOptionGrid(
          context: context,
          question: question,
          labels: labels,
          selectedValues: {controller.answerFor(question.id) ?? ''},
          isMultiSelect: false,
          compact: layout == _QuestionOptionLayout.compactGrid,
        );
      case 'single_chip':
      case 'multi_chip':
        final values = controller.answerValuesFor(question.id);
        if (layout == _QuestionOptionLayout.list) {
          return ListView.separated(
            controller: _optionsScrollController,
            itemCount: question.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = question.options[index];
              return _ChoiceChipCard(
                icon: _optionIcon(question.id, option.value),
                label: labels[index],
                isSelected: values.contains(option.value),
                onTap: () => question.type == 'single_chip'
                    ? _handleSingleSelect(question, option)
                    : _handleMultiSelect(question, option),
              );
            },
          );
        }
        return _buildCompactOptionGrid(
          context: context,
          question: question,
          labels: labels,
          selectedValues: values.toSet(),
          isMultiSelect: question.type == 'multi_chip',
          compact: layout == _QuestionOptionLayout.compactGrid,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompactOptionGrid({
    required BuildContext context,
    required Question question,
    required List<String> labels,
    required Set<String> selectedValues,
    required bool isMultiSelect,
    required bool compact,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 300 ? 1 : 2;
        final spacing = 10.0;
        final tileWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return SingleChildScrollView(
          controller: _optionsScrollController,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var index = 0; index < question.options.length; index++)
                SizedBox(
                  width: tileWidth,
                  child: _GridOptionCard(
                    icon: _optionIcon(
                      question.id,
                      question.options[index].value,
                    ),
                    label: labels[index],
                    isSelected: selectedValues.contains(
                      question.options[index].value,
                    ),
                    compact: compact,
                    onTap: () => isMultiSelect
                        ? _handleMultiSelect(question, question.options[index])
                        : question.id == 'travel_group'
                        ? _handleTravelGroupSelect(question.options[index])
                        : _handleSingleSelect(
                            question,
                            question.options[index],
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  _QuestionOptionLayout _resolveQuestionOptionLayout(
    Question question,
    List<String> labels,
  ) {
    final shortLabel = labels.every((label) => label.length <= 22);
    final mediumLabel = labels.every((label) => label.length <= 32);
    final gridFirstIds = {
      'intent',
      'timeline',
      'travel_group',
      'priorities',
      'funding',
      'constraints',
      'available_capital',
    };

    if (gridFirstIds.contains(question.id) && shortLabel) {
      return _QuestionOptionLayout.compactGrid;
    }

    if (gridFirstIds.contains(question.id) && mediumLabel) {
      return _QuestionOptionLayout.grid;
    }

    if (question.options.length <= 4 && mediumLabel) {
      return _QuestionOptionLayout.grid;
    }

    if (question.options.length <= 6 && shortLabel) {
      return _QuestionOptionLayout.compactGrid;
    }

    return _QuestionOptionLayout.list;
  }

  IconData _priorityIcon(String value) {
    switch (value) {
      case 'low_cost':
        return Icons.savings_rounded;
      case 'job_opportunities':
        return Icons.work_outline_rounded;
      case 'safety':
        return Icons.shield_outlined;
      case 'warm_climate_beach':
        return Icons.wb_sunny_outlined;
      case 'transit_infra':
        return Icons.train_rounded;
      case 'nature':
        return Icons.park_outlined;
      case 'university':
        return Icons.school_outlined;
      case 'community':
        return Icons.groups_2_outlined;
      case 'close_to_argentina':
        return Icons.near_me_outlined;
      case 'balanced_unsure':
        return Icons.tune_rounded;
      default:
        return Icons.radio_button_checked;
    }
  }

  IconData _optionIcon(String questionId, String value) {
    switch (questionId) {
      case 'origin_country':
        switch (value) {
          case 'argentina':
            return Icons.flag_rounded;
          case 'chile':
            return Icons.flag_outlined;
          case 'uruguai':
          case 'uruguay':
            return Icons.explore_outlined;
          case 'paraguai':
          case 'paraguay':
            return Icons.public_rounded;
        }
      case 'intent':
        switch (value) {
          case 'find_job_br':
            return Icons.work_outline_rounded;
          case 'remote_income':
            return Icons.laptop_mac_rounded;
          case 'study':
            return Icons.school_outlined;
          case 'family_partner':
            return Icons.favorite_border_rounded;
          case 'fresh_start':
            return Icons.wb_sunny_outlined;
          case 'explore_unsure':
            return Icons.explore_outlined;
        }
      case 'timeline':
        switch (value) {
          case 'just_exploring':
            return Icons.travel_explore_rounded;
          case 'in_0_3m':
            return Icons.flash_on_outlined;
          case 'in_3_6m':
            return Icons.event_available_rounded;
          case 'in_6_12m':
            return Icons.calendar_month_outlined;
          case 'in_12m_plus':
            return Icons.event_note_outlined;
          case 'depends':
            return Icons.tune_rounded;
        }
      case 'funding':
        switch (value) {
          case 'savings':
            return Icons.savings_outlined;
          case 'remote_income':
            return Icons.attach_money_rounded;
          case 'job_search':
            return Icons.manage_search_rounded;
          case 'job_offer':
            return Icons.badge_outlined;
          case 'family_support':
            return Icons.groups_2_outlined;
          case 'dont_know':
            return Icons.help_outline_rounded;
        }
      case 'travel_group':
        switch (value) {
          case 'solo':
            return Icons.person_outline_rounded;
          case 'partner':
            return Icons.favorite_border_rounded;
          case 'family_no_kids':
            return Icons.people_outline_rounded;
          case 'family_kids':
            return Icons.family_restroom_rounded;
          case 'undecided':
            return Icons.help_outline_rounded;
        }
      case 'available_capital':
        switch (value) {
          case 'low':
            return Icons.savings_outlined;
          case 'medium':
            return Icons.account_balance_wallet_outlined;
          case 'high':
            return Icons.payments_outlined;
          case 'very_high':
            return Icons.trending_up_rounded;
          case 'prefer_not_say':
            return Icons.lock_outline_rounded;
        }
      case 'constraints':
        switch (value) {
          case 'prefer_south':
            return Icons.south_america_outlined;
          case 'need_big_city':
            return Icons.location_city_outlined;
          case 'prefer_mid_city':
            return Icons.apartment_outlined;
          case 'want_coast':
            return Icons.beach_access_outlined;
          case 'prefer_cooler':
            return Icons.ac_unit_rounded;
          case 'need_transit':
            return Icons.tram_outlined;
          case 'avoid_expensive':
            return Icons.price_change_outlined;
          case 'no_constraints':
            return Icons.adjust_rounded;
        }
    }

    return Icons.radio_button_checked;
  }

  Widget _buildFooter(BuildContext context, Question question) {
    final l10n = context.l10n;

    if (question.id == 'origin_country') {
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
    final isEnabled = controller.canGoNext && !controller.isGeneratingPlan;
    final isGenerate = controller.isLastQuestion;

    return FrostedPanel(
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            onPressed: isEnabled
                ? () async {
                    setState(() {
                      _showProcessingScreen = controller.isLastQuestion;
                    });
                    final completed = await controller.goNext();
                    if (!mounted) {
                      return;
                    }
                    if (!completed) {
                      setState(() {
                        _showProcessingScreen = false;
                      });
                    }
                    if (completed && context.mounted) {
                      await Future<void>.delayed(
                        const Duration(milliseconds: 700),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.migrationPlanResult,
                      );
                    }
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
    );
  }

  Future<void> _handleSingleSelect(Question question, Option option) async {
    setState(() {
      _inlineHint = null;
    });

    controller.selectAnswer(question.id, option.value);
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

  String _supportTextForQuestion(BuildContext context, Question question) {
    switch (question.id) {
      case 'origin_country':
        return context.l10n.journeyEntryOriginPending;
      default:
        return context.l10n.questionnaireSupportText;
    }
  }

  String _sectionLabel(BuildContext context, Question question) {
    switch (question.id) {
      case 'origin_country':
        return context.l10n.questionnaireSectionOrigin;
      case 'timeline':
      case 'travel_group':
        return context.l10n.questionnaireSectionBasicProfile;
      case 'priorities':
      case 'constraints':
        return context.l10n.questionnaireSectionPreferences;
      case 'funding':
      case 'available_capital':
        return context.l10n.questionnaireSectionFinancial;
      case 'intent':
        return context.l10n.questionnaireSectionGoal;
      default:
        return _supportTextForQuestion(context, question);
    }
  }

  String? _sectionTransitionHint(BuildContext context, Question question) {
    final nextIndex = controller.currentIndex + 1;
    if (nextIndex >= controller.totalStepsForProgress) {
      return context.l10n.questionnaireReadyForPlan;
    }

    final nextQuestion = controller.activeQuestions[nextIndex];
    final currentSection = _sectionLabel(context, question);
    final nextSection = _sectionLabel(context, nextQuestion);
    if (currentSection == nextSection) {
      return null;
    }

    return context.l10n.questionnaireNextSection(nextSection);
  }

  String _selectionHelperLabel(BuildContext context, Question question) {
    return context.l10n.questionnaireSelectionHelper(question.maxSelections);
  }

  String _selectionValidationLabel(BuildContext context, Question question) {
    return context.l10n.questionnaireSelectionValidation(
      question.maxSelections,
    );
  }

  String _selectionCounterLabel(int selected, int total) => '$selected/$total';

  String _compactHintLabel(BuildContext context, Question question) {
    return context.l10n.questionnaireCompactHint(question.id);
  }

  String _displayOptionLabel(
    BuildContext context,
    String questionId,
    String value,
  ) {
    if (questionId == 'available_capital' && value != 'prefer_not_say') {
      return _availableCapitalOptionLabel(context, value);
    }
    return context.l10n.questionnaireCompactOptionLabel(questionId, value);
  }

  String _availableCapitalOptionLabel(BuildContext context, String value) {
    final rangeSet = AvailableCapitalRangesStore.rangesForOrigin(
      controller.answerFor('origin_country'),
    );
    final language = Localizations.localeOf(context).languageCode;
    final first = _formatCapitalAmount(
      rangeSet.currencyCode,
      rangeSet.bands[0],
    );
    final second = _formatCapitalAmount(
      rangeSet.currencyCode,
      rangeSet.bands[1],
    );
    final third = _formatCapitalAmount(
      rangeSet.currencyCode,
      rangeSet.bands[2],
    );
    final unit = _capitalUnitLabel(language, rangeSet.currencyCode);

    return switch (value) {
      'low' =>
        language == 'en'
            ? 'Up to $first $unit'
            : '${language == 'pt' ? 'Até' : 'Hasta'} $first $unit',
      'medium' => '$first a $second $unit',
      'high' => '$second a $third $unit',
      'very_high' =>
        language == 'en'
            ? 'More than $third $unit'
            : '${language == 'pt' ? 'Mais de' : 'Más de'} $third $unit',
      _ => value,
    };
  }

  String _formatCapitalAmount(String currencyCode, num amount) {
    final value = amount.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    if (currencyCode == 'BRL') {
      return 'R\$ $value';
    }
    return '\$$value';
  }

  String _capitalUnitLabel(String language, String currencyCode) {
    switch (currencyCode) {
      case 'ARS':
        return language == 'en' ? 'Argentine pesos' : 'pesos';
      case 'CLP':
        return language == 'pt'
            ? 'pesos chilenos'
            : language == 'en'
            ? 'Chilean pesos'
            : 'pesos chilenos';
      case 'UYU':
        return language == 'pt'
            ? 'pesos uruguaios'
            : language == 'en'
            ? 'Uruguayan pesos'
            : 'pesos uruguayos';
      case 'BRL':
        return language == 'en'
            ? 'reais'
            : language == 'es'
            ? 'reales'
            : 'reais';
      default:
        return language == 'en' ? 'USD' : 'dólares';
    }
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

enum _QuestionOptionLayout { list, grid, compactGrid }

class _QuestionnaireVariantAppBar extends StatelessWidget {
  const _QuestionnaireVariantAppBar({
    required this.title,
    required this.onBack,
    required this.onHelp,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          _QuestionnaireVariantIconButton(
            icon: Icons.chevron_left_rounded,
            iconColor: const Color(0xFF8B949E),
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF0F6FC),
              ),
            ),
          ),
          _QuestionnaireVariantIconButton(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF6B7280),
            onTap: onHelp,
          ),
        ],
      ),
    );
  }
}

class _QuestionnaireVariantIconButton extends StatelessWidget {
  const _QuestionnaireVariantIconButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: const Color(0xFF1E2636)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _QuestionnaireVariantHeader extends StatelessWidget {
  const _QuestionnaireVariantHeader({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF58A6FF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF0F6FC),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _QuestionnaireVariantPrimaryCard extends StatelessWidget {
  const _QuestionnaireVariantPrimaryCard({
    required this.badge,
    required this.title,
    required this.body,
    required this.timeValue,
    required this.timeLabel,
    required this.questionValue,
    required this.questionLabel,
    required this.actionLabel,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String body;
  final String timeValue;
  final String timeLabel;
  final String questionValue;
  final String questionLabel;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F38),
          border: Border.all(color: const Color(0xFF1D4A70), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4A70).withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionnaireVariantBadge(
                  backgroundColor: const Color(0xFF0A1A2E),
                  borderColor: const Color(0xFF1D4A70),
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF58A6FF),
                  label: badge,
                ),
                const SizedBox(height: 14),
                const SizedBox(
                  height: 54,
                  child: CustomPaint(painter: _FastPlanPainter()),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF0F6FC),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B949E),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _QuestionnaireVariantStat(
                      icon: Icons.access_time_rounded,
                      value: timeValue,
                      label: timeLabel,
                      color: const Color(0xFF58A6FF),
                    ),
                    const SizedBox(width: 8),
                    _QuestionnaireVariantStat(
                      icon: Icons.help_outline_rounded,
                      value: questionValue,
                      label: questionLabel,
                      color: const Color(0xFF58A6FF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F6FEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
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

class _QuestionnaireVariantSeparator extends StatelessWidget {
  const _QuestionnaireVariantSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0xFF1E2636)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2D333B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0xFF1E2636)),
        ),
      ],
    );
  }
}

class _QuestionnaireVariantSecondaryCard extends StatelessWidget {
  const _QuestionnaireVariantSecondaryCard({
    required this.badge,
    required this.title,
    required this.body,
    required this.timeValue,
    required this.timeLabel,
    required this.questionValue,
    required this.questionLabel,
    required this.actionLabel,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String body;
  final String timeValue;
  final String timeLabel;
  final String questionValue;
  final String questionLabel;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: const Color(0xFF1E2636), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuestionnaireVariantBadge(
              backgroundColor: const Color(0xFF1A1200),
              borderColor: const Color(0xFF3D2800),
              icon: Icons.star_outline_rounded,
              color: const Color(0xFFF59E0B),
              label: badge,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF0F6FC),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B949E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _QuestionnaireVariantStat(
                  icon: Icons.access_time_rounded,
                  value: timeValue,
                  label: timeLabel,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                _QuestionnaireVariantStat(
                  icon: Icons.help_outline_rounded,
                  value: questionValue,
                  label: questionLabel,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF2D333B)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                actionLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B949E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionnaireVariantBadge extends StatelessWidget {
  const _QuestionnaireVariantBadge({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.color,
    required this.label,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionnaireVariantStat extends StatelessWidget {
  const _QuestionnaireVariantStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0F6FC),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FastPlanPainter extends CustomPainter {
  const _FastPlanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final foreground = Paint()
      ..color = const Color(0xFF1F6FEB)
      ..style = PaintingStyle.fill;
    final circlePaint = Paint()
      ..color = const Color(0xFF1D4A70).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final circleBorder = Paint()
      ..color = const Color(0xFF1D4A70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final iconPaint = Paint()
      ..color = const Color(0xFF58A6FF)
      ..style = PaintingStyle.fill;

    RRect bar(double top, double width) => RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, width, 8),
      const Radius.circular(4),
    );

    canvas.drawRRect(bar(0, size.width * 0.72), background);
    canvas.drawRRect(bar(0, size.width * 0.72), foreground);
    canvas.drawRRect(bar(16, size.width * 0.72), background);
    canvas.drawRRect(bar(16, size.width * 0.50), foreground);
    canvas.drawRRect(bar(32, size.width * 0.72), background);
    canvas.drawRRect(bar(32, size.width * 0.28), foreground);

    final cx = size.width - 20;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), 18, circlePaint);
    canvas.drawCircle(Offset(cx, cy), 18, circleBorder);

    final path = Path()
      ..moveTo(cx + 3, cy - 7)
      ..lineTo(cx - 2, cy + 1)
      ..lineTo(cx + 1, cy + 1)
      ..lineTo(cx - 3, cy + 7)
      ..lineTo(cx + 2, cy - 1)
      ..lineTo(cx - 1, cy - 1)
      ..close();
    canvas.drawPath(path, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LargeOptionCard extends StatelessWidget {
  const _LargeOptionCard({
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
                  icon,
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
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ScoreBadge(
                      label: isSelected ? '✓' : '•',
                      tone: isSelected ? ScoreTone.positive : ScoreTone.neutral,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFEFF4FA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  color: isSelected
                      ? Colors.white
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

class _ChoiceChipCard extends StatelessWidget {
  const _ChoiceChipCard({
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
    final isDark = AppColors.isDark(context);
    final background = isSelected
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFE9F4FF),
            darkAlpha: 0.24,
            darkBase: const Color(0xFF182536),
          )
        : (isDark
              ? const Color(0xFF131C29).withValues(alpha: 0.94)
              : Colors.white.withValues(alpha: 0.94));
    final border = isSelected
        ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
        : (isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0x18071B3A));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                            .withValues(alpha: isDark ? 0.18 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF4AA7FF) : AppColors.primary)
                          .withValues(alpha: isDark ? 0.18 : 0.10)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF0F5FA)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
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
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ScoreBadge(
                    label: isSelected ? '✓' : '•',
                    tone: isSelected ? ScoreTone.positive : ScoreTone.neutral,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 20,
              color: isSelected
                  ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                  : AppColors.textSoftFor(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityOptionCard extends StatelessWidget {
  const _PriorityOptionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              ? const Color(0xFF131C29).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.96));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0x16071B3A)),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.20 : 0.10,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF4AA7FF)
                                : AppColors.primary)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF0F5FA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSoftFor(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 18,
                    color: isSelected
                        ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                        : AppColors.textSoftFor(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridOptionCard extends StatelessWidget {
  const _GridOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
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
              ? const Color(0xFF131C29).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.96));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: compact ? 74 : 88),
          padding: EdgeInsets.all(compact ? 10 : 12),
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
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.20 : 0.10,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 28 : 32,
                    height: compact ? 28 : 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF4AA7FF)
                                : AppColors.primary)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF0F5FA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: compact ? 14 : 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSoftFor(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: compact ? 16 : 18,
                    color: isSelected
                        ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                        : AppColors.textSoftFor(context),
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                label,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w700,
                  height: 1.16,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
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

class _QuestionSubnote extends StatelessWidget {
  const _QuestionSubnote({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSoftFor(context),
        fontWeight: FontWeight.w600,
      ),
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

class _ProcessingState extends StatelessWidget {
  const _ProcessingState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FrostedPanel(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableOptionsViewport extends StatelessWidget {
  const _ScrollableOptionsViewport({
    required this.controller,
    required this.showHint,
    required this.hintLabel,
    required this.child,
  });

  final ScrollController controller;
  final bool showHint;
  final String hintLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        IgnorePointer(
          ignoring: !showHint,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showHint ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    if (!controller.hasClients) {
                      return;
                    }

                    final nextOffset = controller.offset + 180;
                    controller.animateTo(
                      nextOffset.clamp(0, controller.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.72),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 22, 10, 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.isDark(context)
                              ? const Color(0xE6152232)
                              : const Color(0xF9FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hintLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimaryFor(context),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefineIllustration extends StatelessWidget {
  const _RefineIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return AspectRatio(
      aspectRatio: 1.15,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.26 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 170,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF142132)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 38,
            left: 54,
            right: 54,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.tintedSurfaceFor(
                  context,
                  tint: AppColors.primary,
                  lightColor: const Color(0xFFEAF4FF),
                  darkBase: const Color(0xFF19283B),
                  darkAlpha: 0.26,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          Positioned(
            left: 66,
            right: 66,
            bottom: 42,
            child: Row(
              children: const [
                Expanded(
                  child: _RefineMiniCard(
                    icon: Icons.map_outlined,
                    tint: Color(0xFF0D7ACC),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _RefineMiniCard(
                    icon: Icons.location_city_outlined,
                    tint: Color(0xFF1F9F79),
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

class _RefineMiniCard extends StatelessWidget {
  const _RefineMiniCard({required this.icon, required this.tint});

  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, color: tint, size: 28),
    );
  }
}

class _ExitFlowDialog extends StatelessWidget {
  const _ExitFlowDialog({
    required this.title,
    required this.body,
    required this.stayLabel,
    required this.leaveLabel,
  });

  final String title;
  final String body;
  final String stayLabel;
  final String leaveLabel;

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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(stayLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(leaveLabel),
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

String _localizedText(
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/question_progress_indicator.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({required this.controller, super.key});

  final MigrationQuestionnaireController controller;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String? _inlineHint;
  bool _isAutoAdvancing = false;
  final ScrollController _optionsScrollController = ScrollController();
  String? _scrollScopeKey;
  bool _showScrollHint = false;

  MigrationQuestionnaireController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _optionsScrollController.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.initialize());
    });
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
                            title: l10n.questionnairePageTitle,
                            onBack: () => _handleExitFlow(context),
                          ),
                          const SizedBox(height: 20),
                          if (controller.isInitializing)
                            const Expanded(
                              child: SingleChildScrollView(
                                child: FormSkeleton(
                                  fieldCount: 4,
                                  compact: true,
                                ),
                              ),
                            )
                          else if (!controller.hasSelectedVariant)
                            Expanded(child: _buildVariantSelector(context))
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

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bmpRefineTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.bmpRefineSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
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

  Widget _buildVariantSelector(BuildContext context) {
    final l10n = context.l10n;
    _prepareScrollableScope('variant_selector');

    return FrostedPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bmpVariantTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.bmpVariantSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView(
              children: [
                _VariantOptionCard(
                  title: l10n.bmpVariantLeanTitle,
                  body: l10n.bmpVariantLeanBody,
                  tag: l10n.bmpVariantLeanTag,
                  onTap: () =>
                      controller.selectVariant(QuestionnaireVariant.lean),
                ),
                const SizedBox(height: 12),
                _VariantOptionCard(
                  title: l10n.bmpVariantStrategicTitle,
                  body: l10n.bmpVariantStrategicBody,
                  tag: l10n.bmpVariantStrategicTag,
                  onTap: () =>
                      controller.selectVariant(QuestionnaireVariant.strategic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFlow(BuildContext context, Question question) {
    final l10n = context.l10n;
    final showPrimaryAction =
        question.type == 'multi_chip' || question.isOptional;
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
                label: l10n.bmpProgressStep(
                  controller.currentStepForProgress,
                  controller.totalStepsForProgress,
                ),
              ),
              const SizedBox(height: 14),
              _QuestionSupportPill(
                label: _supportTextForQuestion(context, question),
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
                  label: l10n.qPrioritiesHelper,
                  counter: l10n.qPrioritiesSelectedCount(
                    controller.answerValuesFor(question.id).length,
                    question.maxSelections,
                  ),
                  isComplete:
                      controller
                          .answerValuesFor(question.id)
                          .contains('balanced_unsure') ||
                      controller.answerValuesFor(question.id).length ==
                          question.maxSelections,
                ),
              ] else if (question.id == 'constraints') ...[
                const SizedBox(height: 10),
                _QuestionSubnote(label: l10n.qConstraintsSubtitle),
              ] else if (question.id == 'funding') ...[
                const SizedBox(height: 10),
                _QuestionSubnote(label: l10n.qFundingSubtitle),
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

  Widget _buildQuestionOptions(BuildContext context, Question question) {
    if (question.id == 'priorities') {
      final values = controller.answerValuesFor(question.id);
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 1 : 2;
          final spacing = 12.0;
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
                      label: context.l10n.questionOptionLabel(
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

    switch (question.type) {
      case 'single_card':
        return ListView.separated(
          controller: _optionsScrollController,
          itemCount: question.options.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final option = question.options[index];
            return _LargeOptionCard(
              icon: _optionIcon(question.id, option.value),
              label: context.l10n.questionOptionLabel(
                question.id,
                option.value,
              ),
              isSelected: controller.answerFor(question.id) == option.value,
              onTap: () => _handleSingleSelect(question, option),
            );
          },
        );
      case 'single_chip':
      case 'multi_chip':
        final values = controller.answerValuesFor(question.id);
        return ListView.separated(
          controller: _optionsScrollController,
          itemCount: question.options.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final option = question.options[index];
            return _ChoiceChipCard(
              icon: _optionIcon(question.id, option.value),
              label: context.l10n.questionOptionLabel(
                question.id,
                option.value,
              ),
              isSelected: values.contains(option.value),
              onTap: () => question.type == 'single_chip'
                  ? _handleSingleSelect(question, option)
                  : _handleMultiSelect(question, option),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
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
                    final completed = await controller.goNext();
                    if (completed && context.mounted) {
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
    if (_isAutoAdvancing) {
      return;
    }

    setState(() {
      _inlineHint = null;
      _isAutoAdvancing = true;
    });

    controller.selectAnswer(question.id, option.value);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final completed = await controller.goNext();

    if (!mounted) {
      return;
    }

    setState(() {
      _isAutoAdvancing = false;
    });

    if (completed) {
      Navigator.pushReplacementNamed(context, AppRoutes.migrationPlanResult);
    }
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
      _inlineHint = question.id == 'priorities'
          ? context.l10n.qPrioritiesValidation
          : context.l10n.qConstraintsValidation;
    });
  }

  String _supportTextForQuestion(BuildContext context, Question question) {
    switch (question.id) {
      case 'intent':
      case 'funding':
      case 'timeline':
      case 'priorities':
      case 'constraints':
        return context.l10n.bmpDisclaimer;
      default:
        return context.l10n.questionnaireSupportText;
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

class _VariantOptionCard extends StatelessWidget {
  const _VariantOptionCard({
    required this.title,
    required this.body,
    required this.tag,
    required this.onTap,
  });

  final String title;
  final String body;
  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: FrostedPanel(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(26),
          backgroundColor: isDark
              ? const Color(0xCC152131)
              : Colors.white.withValues(alpha: 0.94),
          borderColor: isDark
              ? AppColors.accent.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
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
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2,
                ),
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
          constraints: const BoxConstraints(minHeight: 98),
          padding: const EdgeInsets.all(14),
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
                    width: 34,
                    height: 34,
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
                      size: 18,
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
                    size: 20,
                    color: isSelected
                        ? (isDark ? const Color(0xFF57B1FF) : AppColors.primary)
                        : AppColors.textSoftFor(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w600,
                  height: 1.18,
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

class _QuestionSupportPill extends StatelessWidget {
  const _QuestionSupportPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF2F7FF),
          darkBase: const Color(0xFF162131),
          darkAlpha: 0.28,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.textSoftFor(context),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

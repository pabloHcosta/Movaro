import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_focus_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

/// Horizontal phase stepper + active-task card shown on the home screen
/// when the user has an active migration plan.
class JourneyStepperWidget extends StatelessWidget {
  const JourneyStepperWidget({
    required this.plan,
    required this.allItems,
    this.onTapActiveTask,
    this.onTapSeeMore,
    this.onTapItem,
    this.showTaskCard = true,
    super.key,
  });

  final MigrationPlan plan;
  final List<GuideActionItem> allItems;
  final VoidCallback? onTapActiveTask;
  final VoidCallback? onTapSeeMore;
  final ValueChanged<GuideActionItem>? onTapItem;

  /// When false the active-task card is omitted — used by the Focus Mode
  /// layout where the card is rendered separately as a primary action card.
  final bool showTaskCard;

  @override
  Widget build(BuildContext context) {
    final focus = GuideFocusEngine.build(plan: plan, items: allItems);
    final completedCount = focus.coreCompletedCount;
    final totalCount = focus.coreTotalCount;
    final currentPhase = focus.current?.phase ?? GuidePhase.arrival;
    final journeyStage = UserJourneyStageDetector.detect(
      timeline: plan.timeline,
      completedSteps: completedCount,
      totalSteps: totalCount,
    );
    final isDark = AppColors.isDark(context);

    final activeTask = focus.current;
    final remainingInPhase = focus.upcoming.length + focus.later.length;
    final cpfUnlockCount = allItems
        .where(
          (it) => it.dependencies.contains('item_2_1_cpf') && !it.isCompleted,
        )
        .length;
    final nextPhase = focus.upcoming.firstOrNull?.phase;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                (onTapSeeMore ?? onTapActiveTask)?.call();
              },
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderFor(context)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.homeJourneyTitle,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSoftFor(context),
                              ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.homeStepperProgress(
                            '$completedCount',
                            '$totalCount',
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? const Color(0xFF1A2840)
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(
                          child: _JourneyPhaseSummary(
                            icon: _phaseIcon(currentPhase),
                            eyebrow: _localizedText(
                              context,
                              pt: 'AGORA',
                              es: 'AHORA',
                              en: 'NOW',
                            ),
                            label: _phaseLabel(
                              context,
                              currentPhase,
                              journeyStage,
                            ),
                            highlighted: true,
                          ),
                        ),
                        if (nextPhase != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: AppColors.textSoftFor(context),
                            ),
                          ),
                          Expanded(
                            child: _JourneyPhaseSummary(
                              icon: _phaseIcon(nextPhase),
                              eyebrow: _localizedText(
                                context,
                                pt: 'DEPOIS',
                                es: 'DESPUÉS',
                                en: 'NEXT',
                              ),
                              label: _phaseLabel(
                                context,
                                nextPhase,
                                journeyStage,
                              ),
                              highlighted: false,
                            ),
                          ),
                        ] else
                          const Spacer(),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSoftFor(context),
                        ),
                      ],
                    ),
                    if (focus.upcoming.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Divider(height: 1, color: AppColors.borderFor(context)),
                      const SizedBox(height: 6),
                      for (
                        var index = 0;
                        index < focus.upcoming.length;
                        index++
                      )
                        _CompactUpcomingRow(
                          item: focus.upcoming[index],
                          index: index + 1,
                          onTap: onTapItem == null
                              ? onTapSeeMore
                              : () => onTapItem!(focus.upcoming[index]),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showTaskCard && activeTask != null)
          _ActiveTaskCard(
            item: activeTask,
            remainingCount: remainingInPhase - 1,
            journeyStage: journeyStage,
            isDark: isDark,
            cpfUnlockCount: activeTask.id == 'item_2_1_cpf'
                ? cpfUnlockCount
                : 0,
            onTapActiveTask: onTapActiveTask,
            onTapSeeMore: onTapSeeMore,
          ),
      ],
    );
  }

  static IconData _phaseIcon(GuidePhase phase) => switch (phase) {
    GuidePhase.preparation => Icons.explore_rounded,
    GuidePhase.housing => Icons.bed_rounded,
    GuidePhase.documents => Icons.badge_outlined,
    GuidePhase.work => Icons.work_outline_rounded,
    GuidePhase.arrival => Icons.home_rounded,
  };

  static String _phaseLabel(
    BuildContext context,
    GuidePhase phase,
    UserJourneyStage journeyStage,
  ) {
    if (journeyStage == UserJourneyStage.executor) {
      return switch (phase) {
        GuidePhase.preparation => context.l10n.homeJourneyPhaseBeforeTravel,
        GuidePhase.housing => context.l10n.homeJourneyPhaseFirstDays,
        GuidePhase.documents => context.l10n.homeJourneyPhaseDocumentation,
        GuidePhase.work => context.l10n.homeJourneyPhaseLifeWorking,
        GuidePhase.arrival => context.l10n.homeJourneyPhaseIntegration,
      };
    }
    return switch (phase) {
      GuidePhase.preparation => context.l10n.homeJourneyPhasePreparation,
      GuidePhase.housing => context.l10n.homeJourneyPhaseHousing,
      GuidePhase.documents => context.l10n.homeJourneyPhaseDocuments,
      GuidePhase.work => context.l10n.homeJourneyPhaseWork,
      GuidePhase.arrival => context.l10n.homeJourneyPhaseArrival,
    };
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
}

class _CompactUpcomingRow extends StatelessWidget {
  const _CompactUpcomingRow({
    required this.item,
    required this.index,
    required this.onTap,
  });

  final GuideActionItem item;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (item.estimatedTimeLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                item.estimatedTimeLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: AppColors.textSoftFor(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyPhaseSummary extends StatelessWidget {
  const _JourneyPhaseSummary({
    required this.icon,
    required this.eyebrow,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String eyebrow;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? AppColors.primary
        : AppColors.textSoftFor(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: highlighted ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Active task card ──────────────────────────────────────────────────────────

class _ActiveTaskCard extends StatelessWidget {
  const _ActiveTaskCard({
    required this.item,
    required this.remainingCount,
    required this.journeyStage,
    required this.isDark,
    required this.cpfUnlockCount,
    this.onTapActiveTask,
    this.onTapSeeMore,
  });

  final GuideActionItem item;
  final int remainingCount;
  final UserJourneyStage journeyStage;
  final bool isDark;
  final int cpfUnlockCount;
  final VoidCallback? onTapActiveTask;
  final VoidCallback? onTapSeeMore;

  bool get _isUrgent =>
      item.preArrivalRequired ||
      (item.urgencyLevel != null &&
          item.urgencyLevel != GuideUrgencyLevel.normal);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111E35) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF3B7CC8), width: 3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Urgency chip — only shown when item is actually urgent
          if (_isUrgent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3D1010)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.preArrivalRequired
                    ? _localizedText(
                        context,
                        pt: '✈ Antes de viajar',
                        es: '✈ Antes de viajar',
                        en: '✈ Before traveling',
                      )
                    : context.l10n.homeStepperUrgent,
                style: AppTypography.tinyLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE24B4A),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          // Icon + title + description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    _typeEmoji(item.type),
                    style: const TextStyle(fontSize: 14, height: 1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.compactBadge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFE8EAED)
                            : const Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.shortDescription,
                      style: AppTypography.tinyLabel.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF4A5980)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // CPF unlock pill
          if (cpfUnlockCount > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F2D18)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _unlockCopy(context, cpfUnlockCount),
                    style: AppTypography.tinyLabel.copyWith(
                      color: isDark
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onTapActiveTask,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B7CC8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      _primaryActionLabel(context),
                      textAlign: TextAlign.center,
                      style: AppTypography.compactBadge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (remainingCount > 0) ...[
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: onTapSeeMore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D1829)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        _moreInPhaseLabel(context, remainingCount),
                        textAlign: TextAlign.center,
                        style: AppTypography.tinyLabel.copyWith(
                          color: isDark
                              ? const Color(0xFF4A5980)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _typeEmoji(GuideActionType type) => switch (type) {
    GuideActionType.informative => '📋',
    GuideActionType.external => '🔗',
    GuideActionType.tool => '🛠',
    GuideActionType.checklist => '✅',
  };

  String _primaryActionLabel(BuildContext context) {
    if (journeyStage == UserJourneyStage.executor) {
      return _localizedText(
        context,
        pt: 'Abrir etapa',
        es: 'Abrir etapa',
        en: 'Open step',
      );
    }
    return context.l10n.homeStepperDoNow;
  }

  String _moreInPhaseLabel(BuildContext context, int count) {
    if (journeyStage == UserJourneyStage.executor) {
      return _localizedText(
        context,
        pt: '+ $count desta fase',
        es: '+ $count de esta etapa',
        en: '+ $count in this stage',
      );
    }
    return context.l10n.homeStepperSeeMore('$count');
  }

  String _unlockCopy(BuildContext context, int count) {
    return _localizedText(
      context,
      pt: '✦ Desbloqueia $count passos',
      es: '✦ Desbloquea $count pasos',
      en: '✦ Unlocks $count steps',
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
}

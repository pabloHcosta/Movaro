import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum _PhaseNodeStatus { done, now, lock }

/// Horizontal phase stepper + active-task card shown on the home screen
/// when the user has an active migration plan.
class JourneyStepperWidget extends StatelessWidget {
  const JourneyStepperWidget({
    required this.plan,
    required this.allItems,
    this.onTapActiveTask,
    this.onTapSeeMore,
    super.key,
  });

  final MigrationPlan plan;
  final List<GuideActionItem> allItems;
  final VoidCallback? onTapActiveTask;
  final VoidCallback? onTapSeeMore;

  static const _phases = [
    GuidePhase.preparation,
    GuidePhase.documents,
    GuidePhase.housing,
    GuidePhase.work,
    GuidePhase.arrival,
  ];

  GuidePhase _currentPhase() {
    for (final phase in _phases) {
      final phaseItems = allItems.where((it) => it.phase == phase).toList();
      if (phaseItems.isEmpty) continue;
      if (!phaseItems.every((it) => it.isCompleted)) return phase;
    }
    return GuidePhase.arrival;
  }

  _PhaseNodeStatus _phaseStatus(GuidePhase phase, GuidePhase currentPhase) {
    final phaseItems = allItems.where((it) => it.phase == phase).toList();
    if (phaseItems.isNotEmpty && phaseItems.every((it) => it.isCompleted)) {
      return _PhaseNodeStatus.done;
    }
    if (phase == currentPhase && phaseItems.isNotEmpty) {
      return _PhaseNodeStatus.now;
    }
    return _PhaseNodeStatus.lock;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = allItems.where((it) => it.isCompleted).length;
    final totalCount = allItems.length;
    final currentPhase = _currentPhase();

    final currentPhaseItems = allItems
        .where((it) => it.phase == currentPhase)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final activeTask =
        currentPhaseItems.where((it) => !it.isCompleted).firstOrNull;
    final remainingInPhase =
        currentPhaseItems.where((it) => !it.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Part 1: Label row ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                context.l10n.homeJourneyTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Color(0xFF6B7A99),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.homeStepperProgress(
                  '$completedCount',
                  '$totalCount',
                ),
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF3B7CC8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Part 2: Horizontal stepper ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _phases.length; i++) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PhaseNode(
                        phase: _phases[i],
                        status: _phaseStatus(_phases[i], currentPhase),
                      ),
                      const SizedBox(height: 3),
                      _PhaseLabel(
                        phase: _phases[i],
                        isCurrent: _phases[i] == currentPhase,
                      ),
                    ],
                  ),
                ),
                if (i < _phases.length - 1)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _PhaseConnector(
                        isDone: _phaseStatus(_phases[i], currentPhase) ==
                            _PhaseNodeStatus.done,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        // ── Part 3: Active task card ──────────────────────────────────
        if (activeTask != null)
          _ActiveTaskCard(
            item: activeTask,
            remainingCount: remainingInPhase - 1,
            onTapActiveTask: onTapActiveTask,
            onTapSeeMore: onTapSeeMore,
          ),
      ],
    );
  }
}

// ─── Phase node (circle with icon) ────────────────────────────────────────────

class _PhaseNode extends StatelessWidget {
  const _PhaseNode({required this.phase, required this.status});

  final GuidePhase phase;
  final _PhaseNodeStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, border, textColor, icon) = switch (status) {
      _PhaseNodeStatus.done => (
          const Color(0xFF0F3020),
          const Color(0xFF1D9E75),
          const Color(0xFF5DCAA5),
          '✓',
        ),
      _PhaseNodeStatus.now => (
          const Color(0xFF1E3A5F),
          const Color(0xFF3B7CC8),
          const Color(0xFF90C4F8),
          '→',
        ),
      _PhaseNodeStatus.lock => (
          const Color(0xFF0A1525),
          const Color(0xFF1A2840),
          const Color(0xFF2A3555),
          _lockEmoji(phase),
        ),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }

  static String _lockEmoji(GuidePhase phase) => switch (phase) {
        GuidePhase.preparation => '📋',
        GuidePhase.documents => '📄',
        GuidePhase.housing => '🏠',
        GuidePhase.work => '💼',
        GuidePhase.arrival => '✈',
      };
}

// ─── Phase label (compact text below node) ────────────────────────────────────

class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({required this.phase, required this.isCurrent});

  final GuidePhase phase;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Text(
      _label(context),
      style: TextStyle(
        fontSize: 7,
        color: isCurrent ? const Color(0xFF90C4F8) : const Color(0xFF6B7A99),
        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _label(BuildContext context) => switch (phase) {
        GuidePhase.preparation => context.l10n.homeJourneyPhasePreparation,
        GuidePhase.documents => context.l10n.homeJourneyPhaseDocuments,
        GuidePhase.housing => context.l10n.homeJourneyPhaseHousing,
        GuidePhase.work => context.l10n.homeJourneyPhaseWork,
        GuidePhase.arrival => context.l10n.homeJourneyPhaseArrival,
      };
}

// ─── Phase connector (horizontal line between nodes) ──────────────────────────

class _PhaseConnector extends StatelessWidget {
  const _PhaseConnector({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: isDone ? const Color(0xFF1D9E75) : const Color(0xFF1A2840),
    );
  }
}

// ─── Active task card ──────────────────────────────────────────────────────────

class _ActiveTaskCard extends StatelessWidget {
  const _ActiveTaskCard({
    required this.item,
    required this.remainingCount,
    this.onTapActiveTask,
    this.onTapSeeMore,
  });

  final GuideActionItem item;
  final int remainingCount;
  final VoidCallback? onTapActiveTask;
  final VoidCallback? onTapSeeMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111E35),
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
          // Urgency chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF3D1010),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              context.l10n.homeStepperUrgent,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE24B4A),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Icon + title + description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    _typeEmoji(item.type),
                    style: const TextStyle(fontSize: 13, height: 1),
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
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8EAED),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.shortDescription,
                      style: const TextStyle(
                        fontSize: 7,
                        color: Color(0xFF4A5980),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onTapActiveTask,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B7CC8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      context.l10n.homeStepperDoNow,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
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
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1829),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        context.l10n.homeStepperSeeMore('$remainingCount'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF4A5980),
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
}

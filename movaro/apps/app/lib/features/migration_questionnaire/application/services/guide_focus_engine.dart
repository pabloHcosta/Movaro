import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum GuideFocusBucket { now, later, onArrival, optional, completed }

enum GuideFocusReason {
  userPriority,
  legalDeadline,
  beforeTravel,
  unlocksOtherSteps,
  goalMatch,
  recommended,
}

class GuideFocusSnapshot {
  const GuideFocusSnapshot({
    required this.current,
    required this.upcoming,
    required this.now,
    required this.later,
    required this.onArrival,
    required this.optional,
    required this.completed,
    required this.coreCompletedCount,
    required this.coreTotalCount,
    required this.pendingBeforeTravelCount,
    required this.currentReason,
  });

  final GuideActionItem? current;
  final List<GuideActionItem> upcoming;
  final List<GuideActionItem> now;
  final List<GuideActionItem> later;
  final List<GuideActionItem> onArrival;
  final List<GuideActionItem> optional;
  final List<GuideActionItem> completed;
  final int coreCompletedCount;
  final int coreTotalCount;
  final int pendingBeforeTravelCount;
  final GuideFocusReason? currentReason;

  double get coreProgress => coreTotalCount == 0
      ? 0
      : (coreCompletedCount / coreTotalCount).clamp(0, 1);

  int get coreProgressPercent => (coreProgress * 100).round();

  int get coreRemainingCount => coreTotalCount - coreCompletedCount;

  List<GuideActionItem> itemsFor(GuideFocusBucket bucket) => switch (bucket) {
    GuideFocusBucket.now => now,
    GuideFocusBucket.later => later,
    GuideFocusBucket.onArrival => onArrival,
    GuideFocusBucket.optional => optional,
    GuideFocusBucket.completed => completed,
  };
}

/// Produces the small, deterministic working set shown to the user.
///
/// The guide may know dozens of actions, but the interface should expose no
/// more than one primary action and two immediate follow-ups. This engine is
/// shared by Home and the execution guide so both surfaces make the same
/// recommendation without generative AI.
class GuideFocusEngine {
  const GuideFocusEngine._();

  static GuideFocusSnapshot build({
    required MigrationPlan plan,
    required List<GuideActionItem> items,
    String? activeItemId,
  }) {
    final completedIds = <String>{
      for (final item in items)
        if (item.isCompleted) item.id,
    };
    final pending = items
        .where((item) => !item.isCompleted && !_isQuestionnaireMilestone(item))
        .toList(growable: false);
    final unlockImpact = <String, int>{
      for (final item in items)
        item.id: items
            .where(
              (candidate) =>
                  !candidate.isCompleted &&
                  candidate.dependencies.contains(item.id),
            )
            .length,
    };

    bool isUnlocked(GuideActionItem item) =>
        item.dependencies.every(completedIds.contains);

    final actionable = pending.where(isUnlocked).toList()
      ..sort(
        (a, b) => _compare(plan: plan, a: a, b: b, unlockImpact: unlockImpact),
      );

    final active = activeItemId == null
        ? null
        : actionable.cast<GuideActionItem?>().firstWhere(
            (item) => item?.id == activeItemId,
            orElse: () => null,
          );
    final current =
        active ??
        actionable.cast<GuideActionItem?>().firstWhere(
          (item) => item != null && !_belongsOnArrival(item),
          orElse: () => actionable.firstOrNull,
        );

    final rankedForNow = <GuideActionItem>[
      ?current,
      ...actionable.where(
        (item) =>
            item.id != current?.id &&
            _tierForFocus(item) != GuideItemTier.optional &&
            !_belongsOnArrival(item),
      ),
    ];
    final now = rankedForNow.take(3).toList(growable: false);
    final nowIds = now.map((item) => item.id).toSet();

    final onArrival = pending.where(_belongsOnArrival).toList(growable: false)
      ..sort(
        (a, b) => _compare(plan: plan, a: a, b: b, unlockImpact: unlockImpact),
      );
    final onArrivalIds = onArrival.map((item) => item.id).toSet();

    final optional =
        pending
            .where(
              (item) =>
                  _tierForFocus(item) == GuideItemTier.optional &&
                  !onArrivalIds.contains(item.id) &&
                  !nowIds.contains(item.id),
            )
            .toList(growable: false)
          ..sort(
            (a, b) =>
                _compare(plan: plan, a: a, b: b, unlockImpact: unlockImpact),
          );
    final optionalIds = optional.map((item) => item.id).toSet();

    final later =
        pending
            .where(
              (item) =>
                  !nowIds.contains(item.id) &&
                  !onArrivalIds.contains(item.id) &&
                  !optionalIds.contains(item.id),
            )
            .toList(growable: false)
          ..sort(
            (a, b) =>
                _compare(plan: plan, a: a, b: b, unlockImpact: unlockImpact),
          );

    final completed =
        items
            .where(
              (item) =>
                  item.isCompleted &&
                  !_isQuestionnaireMilestone(item) &&
                  item.dismissReason != GuideDismissReason.notApplicable,
            )
            .toList(growable: false)
          ..sort((a, b) => b.orderIndex.compareTo(a.orderIndex));

    final coreItems = items.where(_countsTowardsCoreProgress).toList();
    final coreCompletedCount = coreItems
        .where(
          (item) =>
              item.isCompleted &&
              item.dismissReason != GuideDismissReason.later &&
              item.dismissReason != GuideDismissReason.notApplicable,
        )
        .length;

    return GuideFocusSnapshot(
      current: current,
      upcoming: now
          .where((item) => item.id != current?.id)
          .take(2)
          .toList(growable: false),
      now: now,
      later: later,
      onArrival: onArrival,
      optional: optional,
      completed: completed,
      coreCompletedCount: coreCompletedCount,
      coreTotalCount: coreItems.length,
      pendingBeforeTravelCount: items
          .where(
            (item) =>
                item.preArrivalRequired &&
                !item.isCompleted &&
                item.dismissReason == null,
          )
          .length,
      currentReason: current == null
          ? null
          : _reasonFor(current, unlockImpact[current.id] ?? 0),
    );
  }

  static bool _countsTowardsCoreProgress(GuideActionItem item) {
    if (_isQuestionnaireMilestone(item) ||
        _tierForFocus(item) == GuideItemTier.optional ||
        item.dismissReason == GuideDismissReason.notApplicable) {
      return false;
    }
    return true;
  }

  static bool _isQuestionnaireMilestone(GuideActionItem item) =>
      item.id.startsWith('questionnaire_');

  static bool _belongsOnArrival(GuideActionItem item) =>
      item.phase == GuidePhase.arrival && !item.preArrivalRequired;

  static int _compare({
    required MigrationPlan plan,
    required GuideActionItem a,
    required GuideActionItem b,
    required Map<String, int> unlockImpact,
  }) {
    final scoreCompare = _score(
      plan,
      b,
      unlockImpact[b.id] ?? 0,
    ).compareTo(_score(plan, a, unlockImpact[a.id] ?? 0));
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return a.orderIndex.compareTo(b.orderIndex);
  }

  static int _score(MigrationPlan plan, GuideActionItem item, int unlockCount) {
    var score = switch (_tierForFocus(item)) {
      GuideItemTier.critical => 300,
      GuideItemTier.recommended => 150,
      GuideItemTier.optional => 10,
    };
    if (item.preArrivalRequired) {
      score += _isNearTerm(plan.timeline) ? 180 : 110;
    }
    score += switch (item.urgencyLevel) {
      GuideUrgencyLevel.critical => 140,
      GuideUrgencyLevel.urgent => 90,
      GuideUrgencyLevel.watch => 35,
      GuideUrgencyLevel.normal || null => 0,
    };
    if (item.isUserPrioritized) {
      score += 120;
    }
    score += (unlockCount.clamp(0, 4) * 20);
    score += _goalPhaseBonus(plan.goal, item.phase);
    score += _timelinePhaseBonus(plan.timeline, item.phase);
    score += switch (item.estimatedEffort) {
      GuideEstimatedEffort.fast => 12,
      GuideEstimatedEffort.medium => 5,
      GuideEstimatedEffort.longer || null => 0,
    };
    score -= item.orderIndex.clamp(0, 100);
    return score;
  }

  static GuideFocusReason _reasonFor(GuideActionItem item, int unlockCount) {
    if (item.isUserPrioritized) {
      return GuideFocusReason.userPriority;
    }
    if (item.urgencyLevel == GuideUrgencyLevel.critical ||
        item.urgencyLevel == GuideUrgencyLevel.urgent) {
      return GuideFocusReason.legalDeadline;
    }
    if (item.preArrivalRequired) {
      return GuideFocusReason.beforeTravel;
    }
    if (unlockCount > 0) {
      return GuideFocusReason.unlocksOtherSteps;
    }
    if (_tierForFocus(item) == GuideItemTier.critical) {
      return GuideFocusReason.goalMatch;
    }
    return GuideFocusReason.recommended;
  }

  static bool _isNearTerm(String timeline) =>
      timeline == 'in_0_3m' || timeline == 'in_3_6m';

  static GuideItemTier _tierForFocus(GuideActionItem item) {
    if (item.tier != null) {
      return item.tier!;
    }
    if (item.preArrivalRequired ||
        item.urgencyLevel == GuideUrgencyLevel.critical) {
      return GuideItemTier.critical;
    }
    if (item.urgencyLevel == GuideUrgencyLevel.urgent ||
        item.urgencyLevel == GuideUrgencyLevel.watch) {
      return GuideItemTier.recommended;
    }
    // Legacy and fallback guide items predate explicit tiers. Treating them as
    // optional would make the focus engine hide the entire journey.
    return GuideItemTier.recommended;
  }

  static int _goalPhaseBonus(String goal, GuidePhase phase) {
    return switch ((goal, phase)) {
      ('find_job_br' || 'work', GuidePhase.work) => 55,
      ('remote_income' || 'remote_work' || 'entrepreneur', GuidePhase.work) =>
        45,
      ('study', GuidePhase.documents) => 55,
      ('family_partner', GuidePhase.documents) => 45,
      ('fresh_start', GuidePhase.housing) => 35,
      _ => 0,
    };
  }

  static int _timelinePhaseBonus(String timeline, GuidePhase phase) {
    return switch ((timeline, phase)) {
      ('in_0_3m', GuidePhase.documents) => 60,
      ('in_0_3m', GuidePhase.housing) => 45,
      ('in_3_6m', GuidePhase.preparation) => 40,
      ('in_3_6m', GuidePhase.documents) => 35,
      ('in_6_12m' || 'in_12m_plus', GuidePhase.preparation) => 25,
      ('just_exploring' || 'depends', GuidePhase.arrival) => -40,
      _ => 0,
    };
  }
}

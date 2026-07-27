import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

/// Derives time-based urgency context from the migration plan timeline and
/// the current state of guide items.
///
/// Usage:
/// ```dart
/// final engine = MigrationTimingEngine(plan: plan, items: items);
/// final preArrival = engine.incompletePreArrivalItems();
/// final urgent = engine.urgentItems();
/// ```
class MigrationTimingEngine {
  const MigrationTimingEngine({required this.plan, required this.items});

  final MigrationPlan plan;
  final List<GuideActionItem> items;

  /// Returns all items that must be done before arriving in Brazil and are
  /// not yet completed.
  List<GuideActionItem> incompletePreArrivalItems() {
    return items
        .where((it) => it.preArrivalRequired && !it.isCompleted)
        .toList();
  }

  /// Returns all items at or above the given urgency threshold that are
  /// not yet completed.
  List<GuideActionItem> urgentItems({
    GuideUrgencyLevel threshold = GuideUrgencyLevel.urgent,
  }) {
    return items
        .where((it) => !it.isCompleted && _meetsThreshold(it, threshold))
        .toList();
  }

  /// Returns critical items (highest urgency) that are not yet completed.
  List<GuideActionItem> criticalItems() {
    return urgentItems(threshold: GuideUrgencyLevel.critical);
  }

  /// True when the user is planning to move within 3 months.
  bool get isMoveImminent {
    return plan.timeline == 'in_0_3m';
  }

  /// True when the user is in active planning for 3-6 months.
  bool get isMoveNearTerm {
    return plan.timeline == 'in_3_6m';
  }

  /// Returns the count of pre-arrival items the user still needs to complete.
  int get preArrivalRemainingCount => incompletePreArrivalItems().length;

  /// Returns the highest urgency level across all incomplete items.
  GuideUrgencyLevel get highestPendingUrgency {
    final incomplete = items.where((it) => !it.isCompleted).toList();
    if (incomplete.any((it) => it.urgencyLevel == GuideUrgencyLevel.critical)) {
      return GuideUrgencyLevel.critical;
    }
    if (incomplete.any((it) => it.urgencyLevel == GuideUrgencyLevel.urgent)) {
      return GuideUrgencyLevel.urgent;
    }
    if (incomplete.any((it) => it.urgencyLevel == GuideUrgencyLevel.watch)) {
      return GuideUrgencyLevel.watch;
    }
    return GuideUrgencyLevel.normal;
  }

  static bool _meetsThreshold(
    GuideActionItem item,
    GuideUrgencyLevel threshold,
  ) {
    final level = item.urgencyLevel;
    if (level == null) return false;
    return _urgencyRank(level) >= _urgencyRank(threshold);
  }

  static int _urgencyRank(GuideUrgencyLevel level) => switch (level) {
    GuideUrgencyLevel.normal => 0,
    GuideUrgencyLevel.watch => 1,
    GuideUrgencyLevel.urgent => 2,
    GuideUrgencyLevel.critical => 3,
  };
}

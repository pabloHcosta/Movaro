import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_focus_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class GuideGpsController extends ChangeNotifier {
  GuideGpsController({
    required MigrationPlan plan,
    required MigrationCopilotProgressStore progressStore,
    required List<GuideActionItem> items,
    required Set<String> readinessCompletedIds,
    required Set<String> documentCompletedIds,
    required Set<String> arrivalCompletedIds,
    Map<String, String> completedAtById = const <String, String>{},
    Set<String> prioritizedItemIds = const <String>{},
    Map<String, GuideDismissReason> dismissedReasonsById =
        const <String, GuideDismissReason>{},
    Map<String, GuideTaskState> taskStatesById =
        const <String, GuideTaskState>{},
    String? activeItemId,
    GuideFlowMetricsStore? metricsStore,
  }) : _plan = plan,
       _progressStore = progressStore,
       _metricsStore = metricsStore ?? GuideFlowMetricsStore.instance,
       _readinessCompletedIds = Set<String>.from(readinessCompletedIds),
       _documentCompletedIds = Set<String>.from(documentCompletedIds),
       _arrivalCompletedIds = Set<String>.from(arrivalCompletedIds),
       _completedAtById = Map<String, String>.from(completedAtById),
       _prioritizedItemIds = Set<String>.from(prioritizedItemIds),
       _dismissedReasonsById = Map<String, GuideDismissReason>.from(
         dismissedReasonsById,
       ),
       _taskStatesById = Map<String, GuideTaskState>.from(taskStatesById),
       _items = List<GuideActionItem>.from(items)
         ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
       _activeItemId = activeItemId {
    _hydrateDynamicItems();
  }

  final MigrationPlan _plan;
  final MigrationCopilotProgressStore _progressStore;
  final GuideFlowMetricsStore _metricsStore;

  Set<String> _readinessCompletedIds;
  Set<String> _documentCompletedIds;
  Set<String> _arrivalCompletedIds;
  Map<String, String> _completedAtById;
  Set<String> _prioritizedItemIds;
  final Map<String, GuideDismissReason> _dismissedReasonsById;
  final Map<String, GuideTaskState> _taskStatesById;
  final List<GuideActionItem> _items;
  String? _activeItemId;
  bool _currentItemStarted = false;
  bool _awaitingConfirmation = false;

  List<GuideActionItem> get items => List<GuideActionItem>.unmodifiable(_items);

  Set<String> get readinessCompletedIds => _readinessCompletedIds;
  Set<String> get documentCompletedIds => _documentCompletedIds;
  Set<String> get arrivalCompletedIds => _arrivalCompletedIds;
  Map<String, String> get completedAtById =>
      Map<String, String>.unmodifiable(_completedAtById);
  Set<String> get prioritizedItemIds =>
      Set<String>.unmodifiable(_prioritizedItemIds);
  Map<String, GuideDismissReason> get dismissedReasonsById =>
      Map<String, GuideDismissReason>.unmodifiable(_dismissedReasonsById);
  Map<String, GuideTaskState> get taskStatesById =>
      Map<String, GuideTaskState>.unmodifiable(_taskStatesById);

  Set<String> get allCompletedIds => <String>{
    for (final item in _items)
      if (item.isCompleted && item.dismissReason != GuideDismissReason.later)
        item.id,
  };

  GuideFocusSnapshot get focusSnapshot => GuideFocusEngine.build(
    plan: _plan,
    items: _items,
    activeItemId: _activeItemId,
  );

  int get completedCount => focusSnapshot.coreCompletedCount;
  int get totalItems => focusSnapshot.coreTotalCount;
  int get remainingCount => focusSnapshot.coreRemainingCount;
  double get progress => focusSnapshot.coreProgress;
  int get progressPercent => focusSnapshot.coreProgressPercent;

  GuideActionItem? get currentItem => focusSnapshot.current;

  List<GuideActionItem> get upcomingItems => focusSnapshot.upcoming;

  List<GuideActionItem> itemsForPhase(GuidePhase phase) {
    final phaseItems = _items.where((item) => item.phase == phase).toList();
    phaseItems.sort(_compareItemsForDisplay);
    return List<GuideActionItem>.unmodifiable(phaseItems);
  }

  bool isItemUnlocked(GuideActionItem item) {
    if (item.isCompleted && item.dismissReason != GuideDismissReason.later) {
      return true;
    }
    if (item.dependencies.isEmpty) {
      return true;
    }
    final completed = allCompletedIds;
    return item.dependencies.every(completed.contains);
  }

  List<String> unmetDependencyTitles(GuideActionItem item) {
    final completed = allCompletedIds;
    final titlesById = <String, String>{
      for (final candidate in _items) candidate.id: candidate.title,
    };
    return item.dependencies
        .where((dependencyId) => !completed.contains(dependencyId))
        .map((dependencyId) => titlesById[dependencyId] ?? dependencyId)
        .toList(growable: false);
  }

  bool get currentItemStarted => _currentItemStarted;
  bool get awaitingConfirmation => _awaitingConfirmation;
  String? get activeItemId => _activeItemId;
  GuideTaskState stateFor(String itemId) {
    final item = _items.cast<GuideActionItem?>().firstWhere(
      (entry) => entry?.id == itemId,
      orElse: () => null,
    );
    if ((item?.isCompleted ?? false) &&
        item?.dismissReason != GuideDismissReason.later) {
      return GuideTaskState.completed;
    }
    return _taskStatesById[itemId] ?? GuideTaskState.notStarted;
  }

  GuideTaskState get currentTaskState => currentItem == null
      ? GuideTaskState.completed
      : stateFor(currentItem!.id);

  GuidePhase get currentPhase => currentItem?.phase ?? GuidePhase.arrival;

  void startCurrentItem() {
    if (currentItem == null) {
      return;
    }
    _activeItemId = currentItem!.id;
    _currentItemStarted = true;
    _taskStatesById[currentItem!.id] = GuideTaskState.inProgress;
    notifyListeners();
    unawaited(
      _metricsStore.record(
        GuideFlowMetric.taskStarted,
        referenceId: currentItem!.id,
      ),
    );
    unawaited(_persist());
  }

  Future<void> markCurrentItemWaiting() async {
    final item = currentItem;
    if (item == null || item.isCompleted) {
      return;
    }
    _activeItemId = item.id;
    _taskStatesById[item.id] = GuideTaskState.waiting;
    _currentItemStarted = false;
    notifyListeners();
    unawaited(
      _metricsStore.record(GuideFlowMetric.taskWaiting, referenceId: item.id),
    );
    await _persist();
  }

  Future<void> resumeCurrentItem() async {
    final item = currentItem;
    if (item == null || item.isCompleted) {
      return;
    }
    _activeItemId = item.id;
    _taskStatesById[item.id] = GuideTaskState.inProgress;
    _currentItemStarted = true;
    notifyListeners();
    unawaited(
      _metricsStore.record(GuideFlowMetric.taskResumed, referenceId: item.id),
    );
    await _persist();
  }

  void markNeedsConfirmation() {
    _awaitingConfirmation = true;
    notifyListeners();
  }

  Future<void> confirmCurrentItem() async {
    final item = currentItem;
    if (item == null) {
      return;
    }
    await completeActionItem(item.id);
  }

  Future<void> completeActionItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    _items[index] = item.copyWith(
      isCompleted: true,
      dismissReason: null,
      isUserPrioritized: false,
    );
    _dismissedReasonsById.remove(item.id);
    _taskStatesById[item.id] = GuideTaskState.completed;
    _prioritizedItemIds.remove(item.id);
    _setCompleted(item);
    _setCompletedAt(itemId);
    await _handlePostCompletion(item);
    _currentItemStarted = false;
    _awaitingConfirmation = false;
    _activeItemId = null;
    notifyListeners();
    unawaited(
      _metricsStore.record(GuideFlowMetric.taskCompleted, referenceId: item.id),
    );
    await _persist();
  }

  Future<void> jumpToItem(String itemId) async {
    final item = _items.cast<GuideActionItem?>().firstWhere(
      (entry) => entry?.id == itemId,
      orElse: () => null,
    );
    if (item == null || item.isCompleted || !isItemUnlocked(item)) {
      return;
    }
    _activeItemId = item.id;
    _currentItemStarted = false;
    _awaitingConfirmation = false;
    notifyListeners();
    unawaited(
      _metricsStore.record(GuideFlowMetric.taskSelected, referenceId: item.id),
    );
    await _persist();
  }

  Future<void> dismissItem(String itemId, GuideDismissReason reason) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    if (!item.isDismissible || (item.isCompleted && !item.isDismissed)) {
      return;
    }

    final isPostponed = reason == GuideDismissReason.later;
    _items[index] = item.copyWith(
      isCompleted: !isPostponed,
      dismissReason: reason,
      isUserPrioritized: false,
    );
    _dismissedReasonsById[itemId] = reason;
    if (isPostponed) {
      _taskStatesById[itemId] = GuideTaskState.waiting;
      _unsetCompleted(item);
      _completedAtById = <String, String>{..._completedAtById}..remove(itemId);
    } else {
      _taskStatesById[itemId] = GuideTaskState.completed;
      _setCompleted(item);
      _setCompletedAt(itemId);
    }
    _prioritizedItemIds.remove(itemId);
    if (_activeItemId == itemId) {
      _activeItemId = null;
      _currentItemStarted = false;
      _awaitingConfirmation = false;
    }
    notifyListeners();
    unawaited(
      _metricsStore.record(
        GuideFlowMetric.taskDismissed,
        referenceId: '${item.id}:${reason.name}',
      ),
    );
    await _persist();
  }

  Future<void> dismissItems(
    Iterable<String> itemIds,
    GuideDismissReason reason,
  ) async {
    final normalizedIds = itemIds.toSet();
    if (normalizedIds.isEmpty) {
      return;
    }

    var changed = false;
    for (final itemId in normalizedIds) {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index == -1) {
        continue;
      }

      final item = _items[index];
      if (!item.isDismissible || (item.isCompleted && !item.isDismissed)) {
        continue;
      }

      final isPostponed = reason == GuideDismissReason.later;
      _items[index] = item.copyWith(
        isCompleted: !isPostponed,
        dismissReason: reason,
        isUserPrioritized: false,
      );
      _dismissedReasonsById[itemId] = reason;
      if (isPostponed) {
        _taskStatesById[itemId] = GuideTaskState.waiting;
        _unsetCompleted(item);
        _completedAtById = <String, String>{..._completedAtById}
          ..remove(itemId);
      } else {
        _taskStatesById[itemId] = GuideTaskState.completed;
        _setCompleted(item);
        _setCompletedAt(itemId);
      }
      _prioritizedItemIds.remove(itemId);
      if (_activeItemId == itemId) {
        _activeItemId = null;
        _currentItemStarted = false;
        _awaitingConfirmation = false;
      }
      changed = true;
      unawaited(
        _metricsStore.record(
          GuideFlowMetric.taskDismissed,
          referenceId: '${item.id}:${reason.name}',
        ),
      );
    }

    if (!changed) {
      return;
    }

    notifyListeners();
    await _persist();
  }

  Future<void> restoreDismissedItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    if (!item.isDismissed) {
      return;
    }

    _items[index] = item.copyWith(isCompleted: false, dismissReason: null);
    _dismissedReasonsById.remove(itemId);
    _taskStatesById.remove(itemId);
    _unsetCompleted(item);
    _completedAtById = <String, String>{..._completedAtById}..remove(itemId);
    notifyListeners();
    await _persist();
  }

  Future<void> togglePrioritizeItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    if (item.isCompleted ||
        item.isDismissed ||
        item.resolvedTier == GuideItemTier.critical) {
      return;
    }

    final shouldPrioritize = !_prioritizedItemIds.contains(itemId);
    if (shouldPrioritize) {
      _prioritizedItemIds = <String>{..._prioritizedItemIds, itemId};
    } else {
      _prioritizedItemIds = <String>{..._prioritizedItemIds}..remove(itemId);
    }
    _items[index] = item.copyWith(isUserPrioritized: shouldPrioritize);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleChecklistSubItem(String itemId, String subItemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return;
    }
    final item = _items[itemIndex];
    final subItems = item.checklistItems;
    if (subItems == null || subItems.isEmpty) {
      return;
    }

    final updatedSubItems = subItems
        .map(
          (subItem) => subItem.id == subItemId
              ? subItem.copyWith(isCompleted: !subItem.isCompleted)
              : subItem,
        )
        .toList(growable: false);

    final allDone = updatedSubItems.every((subItem) => subItem.isCompleted);
    _items[itemIndex] = item.copyWith(
      checklistItems: updatedSubItems,
      isCompleted: allDone,
    );
    if (allDone) {
      _taskStatesById[item.id] = GuideTaskState.completed;
      _setCompleted(item);
      _setCompletedAt(item.id);
      await _handlePostCompletion(item);
      _activeItemId = null;
    }
    notifyListeners();
    await _persist();
  }

  void _setCompleted(GuideActionItem item) {
    switch (item.phase) {
      case GuidePhase.documents:
        _documentCompletedIds = <String>{..._documentCompletedIds, item.id};
      case GuidePhase.arrival:
        _arrivalCompletedIds = <String>{..._arrivalCompletedIds, item.id};
      case GuidePhase.preparation:
      case GuidePhase.housing:
      case GuidePhase.work:
        _readinessCompletedIds = <String>{..._readinessCompletedIds, item.id};
    }
  }

  void _unsetCompleted(GuideActionItem item) {
    switch (item.phase) {
      case GuidePhase.documents:
        _documentCompletedIds = <String>{..._documentCompletedIds}
          ..remove(item.id);
      case GuidePhase.arrival:
        _arrivalCompletedIds = <String>{..._arrivalCompletedIds}
          ..remove(item.id);
      case GuidePhase.preparation:
      case GuidePhase.housing:
      case GuidePhase.work:
        _readinessCompletedIds = <String>{..._readinessCompletedIds}
          ..remove(item.id);
    }
  }

  void _setCompletedAt(String itemId) {
    _completedAtById = <String, String>{
      ..._completedAtById,
      itemId: _completedAtById[itemId] ?? DateTime.now().toIso8601String(),
    };
  }

  void _hydrateDynamicItems() {
    _hydrateUserState();
    _applyResidenceDeadlineBadge();
  }

  void _hydrateUserState() {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final dismissReason = _dismissedReasonsById[item.id];
      final isPostponed = dismissReason == GuideDismissReason.later;
      if (isPostponed) {
        _unsetCompleted(item);
        _completedAtById = <String, String>{..._completedAtById}
          ..remove(item.id);
        _taskStatesById[item.id] = GuideTaskState.waiting;
      }
      _items[i] = item.copyWith(
        isCompleted: isPostponed ? false : item.isCompleted,
        dismissReason: dismissReason,
        isUserPrioritized: _prioritizedItemIds.contains(item.id),
      );
    }
  }

  int _compareItemsForDisplay(GuideActionItem a, GuideActionItem b) {
    final aPending = !a.isCompleted;
    final bPending = !b.isCompleted;
    if (aPending != bPending) {
      return aPending ? -1 : 1;
    }
    if (!aPending && !bPending) {
      return a.orderIndex.compareTo(b.orderIndex);
    }
    final unlockCompare = _boolPriority(isItemUnlocked(b), isItemUnlocked(a));
    if (unlockCompare != 0) {
      return unlockCompare;
    }
    return _comparePriorityDescending(a, b);
  }

  int _comparePriorityDescending(GuideActionItem a, GuideActionItem b) {
    final scoreCompare = _priorityScore(b).compareTo(_priorityScore(a));
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return a.orderIndex.compareTo(b.orderIndex);
  }

  int _priorityScore(GuideActionItem item) {
    var score = 0;
    switch (item.resolvedTier) {
      case GuideItemTier.critical:
        score += 100;
      case GuideItemTier.recommended:
        score += 45;
      case GuideItemTier.optional:
        score += 10;
    }
    if (item.preArrivalRequired) {
      score += 50;
    }
    switch (item.urgencyLevel) {
      case GuideUrgencyLevel.critical:
        score += 40;
      case GuideUrgencyLevel.urgent:
        score += 25;
      case GuideUrgencyLevel.watch:
        score += 10;
      case GuideUrgencyLevel.normal:
      case null:
        break;
    }
    if (item.isUserPrioritized) {
      score += 30;
    }
    if (item.phase == _phaseContextForPriority()) {
      score += 5;
    }
    score -= item.orderIndex;
    return score;
  }

  GuidePhase _phaseContextForPriority() {
    final activeItem = _items.cast<GuideActionItem?>().firstWhere(
      (item) => item?.id == _activeItemId,
      orElse: () => null,
    );
    if (activeItem != null && !activeItem.isCompleted) {
      return activeItem.phase;
    }

    final nextBySequence = _items.cast<GuideActionItem?>().firstWhere(
      (item) => item != null && !item.isCompleted,
      orElse: () => null,
    );
    return nextBySequence?.phase ?? GuidePhase.arrival;
  }

  int _boolPriority(bool left, bool right) {
    if (left == right) {
      return 0;
    }
    return left ? -1 : 1;
  }

  Future<void> _handlePostCompletion(GuideActionItem item) async {
    await PlanNotificationService.instance.cancelPlanReminders();
    if (item.id == 'item_2_2_residencia') {
      await PlanNotificationService.instance.cancelPFReminder();
    }
    if (item.id == 'item_4_5_registro_rnm') {
      _applyResidenceDeadlineBadge();
      final completedAt = _completedAtById[item.id];
      if (completedAt != null) {
        final completedDate = DateTime.tryParse(completedAt);
        if (completedDate != null) {
          final deadlineDate = completedDate.add(const Duration(days: 730));
          final scheduledDate = deadlineDate.subtract(const Duration(days: 30));
          await PlanNotificationService.instance
              .scheduleResidenceDeadlineReminder(
                deadlineDate: deadlineDate,
                scheduledDate: scheduledDate,
              );
        }
      }
    }
  }

  void _applyResidenceDeadlineBadge() {
    final residenceCompletedAt =
        _completedAtById['item_4_5_registro_rnm'] ??
        _completedAtById['item_2_2_residencia'];
    if (residenceCompletedAt == null) {
      return;
    }

    final completedDate = DateTime.tryParse(residenceCompletedAt);
    if (completedDate == null) {
      return;
    }

    final requestByDate = completedDate
        .add(const Duration(days: 730))
        .subtract(const Duration(days: 90));
    final formatted = _formatDate(requestByDate);
    final badge = PlatformDispatcher.instance.locale.languageCode == 'es'
        ? 'Solicitar antes del $formatted'
        : PlatformDispatcher.instance.locale.languageCode == 'pt'
        ? 'Solicitar até $formatted'
        : 'Apply by $formatted';

    final index = _items.indexWhere(
      (item) => item.id == 'item_4_3_permanencia',
    );
    if (index == -1) {
      return;
    }
    _items[index] = _items[index].copyWith(badgeLabel: badge);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _persist() {
    return _progressStore.write(
      plan: _plan,
      readinessCompletedIds: _readinessCompletedIds,
      documentCompletedIds: _documentCompletedIds,
      arrivalCompletedIds: _arrivalCompletedIds,
      activeItemId: _activeItemId,
      completedAtById: _completedAtById,
      prioritizedItemIds: _prioritizedItemIds,
      dismissedReasonsById: _dismissedReasonsById,
      taskStatesById: _taskStatesById,
    );
  }
}

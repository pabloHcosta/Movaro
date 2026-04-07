import 'dart:async';

import 'package:flutter/foundation.dart';
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
    String? activeItemId,
  }) : _plan = plan,
       _progressStore = progressStore,
       _readinessCompletedIds = Set<String>.from(readinessCompletedIds),
       _documentCompletedIds = Set<String>.from(documentCompletedIds),
       _arrivalCompletedIds = Set<String>.from(arrivalCompletedIds),
       _completedAtById = Map<String, String>.from(completedAtById),
       _prioritizedItemIds = Set<String>.from(prioritizedItemIds),
       _dismissedReasonsById = Map<String, GuideDismissReason>.from(
         dismissedReasonsById,
       ),
       _items = List<GuideActionItem>.from(items)
         ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
       _activeItemId = activeItemId {
    _hydrateDynamicItems();
  }

  final MigrationPlan _plan;
  final MigrationCopilotProgressStore _progressStore;

  Set<String> _readinessCompletedIds;
  Set<String> _documentCompletedIds;
  Set<String> _arrivalCompletedIds;
  Map<String, String> _completedAtById;
  Set<String> _prioritizedItemIds;
  final Map<String, GuideDismissReason> _dismissedReasonsById;
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

  Set<String> get allCompletedIds => <String>{
    for (final item in _items)
      if (item.isCompleted) item.id,
  };

  int get completedCount => allCompletedIds.length;
  int get totalItems => _items.length;
  int get remainingCount => totalItems - completedCount;
  double get progress =>
      totalItems == 0 ? 0 : (completedCount / totalItems).clamp(0, 1);
  int get progressPercent => (progress * 100).round();

  GuideActionItem? get currentItem {
    final availableItems = _rankedAvailablePendingItems();
    if (availableItems.isEmpty) {
      return null;
    }
    if (_activeItemId == null) {
      return availableItems.first;
    }
    return availableItems.firstWhere(
      (item) => item.id == _activeItemId,
      orElse: () => availableItems.first,
    );
  }

  List<GuideActionItem> get upcomingItems {
    final current = currentItem;
    final excludedIds = current == null
        ? const <String>{}
        : <String>{current.id};
    return _rankedAvailablePendingItems(
      excludeIds: excludedIds,
    ).take(3).toList(growable: false);
  }

  List<GuideActionItem> itemsForPhase(GuidePhase phase) {
    final phaseItems = _items.where((item) => item.phase == phase).toList();
    phaseItems.sort(_compareItemsForDisplay);
    return List<GuideActionItem>.unmodifiable(phaseItems);
  }

  bool isItemUnlocked(GuideActionItem item) {
    if (item.isCompleted) {
      return true;
    }
    if (item.dependencies.isEmpty) {
      return true;
    }
    final completed = allCompletedIds;
    return item.dependencies.every(completed.contains);
  }

  bool get currentItemStarted => _currentItemStarted;
  bool get awaitingConfirmation => _awaitingConfirmation;
  String? get activeItemId => _activeItemId;

  GuidePhase get currentPhase => currentItem?.phase ?? GuidePhase.arrival;

  void startCurrentItem() {
    if (currentItem == null) {
      return;
    }
    _activeItemId = currentItem!.id;
    _currentItemStarted = true;
    notifyListeners();
    unawaited(_persist());
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
    _prioritizedItemIds.remove(item.id);
    _setCompleted(item);
    _setCompletedAt(itemId);
    await _handlePostCompletion(item);
    _currentItemStarted = false;
    _awaitingConfirmation = false;
    _activeItemId = null;
    notifyListeners();
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

    _items[index] = item.copyWith(
      isCompleted: true,
      dismissReason: reason,
      isUserPrioritized: false,
    );
    _dismissedReasonsById[itemId] = reason;
    _prioritizedItemIds.remove(itemId);
    _setCompleted(item);
    _setCompletedAt(itemId);
    if (_activeItemId == itemId) {
      _activeItemId = null;
      _currentItemStarted = false;
      _awaitingConfirmation = false;
    }
    notifyListeners();
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

      _items[index] = item.copyWith(
        isCompleted: true,
        dismissReason: reason,
        isUserPrioritized: false,
      );
      _dismissedReasonsById[itemId] = reason;
      _prioritizedItemIds.remove(itemId);
      _setCompleted(item);
      _setCompletedAt(itemId);
      if (_activeItemId == itemId) {
        _activeItemId = null;
        _currentItemStarted = false;
        _awaitingConfirmation = false;
      }
      changed = true;
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
      _items[i] = item.copyWith(
        dismissReason: _dismissedReasonsById[item.id],
        isUserPrioritized: _prioritizedItemIds.contains(item.id),
      );
    }
  }

  List<GuideActionItem> _rankedAvailablePendingItems({
    Set<String> excludeIds = const <String>{},
  }) {
    final pendingItems = _items.where((item) {
      return !item.isCompleted &&
          !excludeIds.contains(item.id) &&
          isItemUnlocked(item);
    }).toList();
    pendingItems.sort(_comparePriorityDescending);
    return pendingItems;
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
    );
  }
}

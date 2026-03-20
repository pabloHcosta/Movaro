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
    String? activeItemId,
  }) : _plan = plan,
       _progressStore = progressStore,
       _readinessCompletedIds = Set<String>.from(readinessCompletedIds),
       _documentCompletedIds = Set<String>.from(documentCompletedIds),
       _arrivalCompletedIds = Set<String>.from(arrivalCompletedIds),
       _completedAtById = Map<String, String>.from(completedAtById),
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

  Set<String> get allCompletedIds => <String>{
    ..._readinessCompletedIds,
    ..._documentCompletedIds,
    ..._arrivalCompletedIds,
  };

  int get completedCount => allCompletedIds.length;
  int get totalItems => _items.length;
  int get remainingCount => totalItems - completedCount;
  double get progress =>
      totalItems == 0 ? 0 : (completedCount / totalItems).clamp(0, 1);
  int get progressPercent => (progress * 100).round();

  GuideActionItem? get currentItem {
    final remainingItems = _items.where((item) => !item.isCompleted).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (remainingItems.isEmpty) {
      return null;
    }
    final availableItems = remainingItems.where(isItemUnlocked).toList();
    if (availableItems.isEmpty) {
      return remainingItems.first;
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
    if (current == null) {
      return const [];
    }
    return _items
        .where(
          (item) => !item.isCompleted && item.orderIndex > current.orderIndex,
        )
        .take(3)
        .toList(growable: false);
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
    _items[index] = item.copyWith(isCompleted: true);
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

  void _setCompletedAt(String itemId) {
    _completedAtById = <String, String>{
      ..._completedAtById,
      itemId: _completedAtById[itemId] ?? DateTime.now().toIso8601String(),
    };
  }

  void _hydrateDynamicItems() {
    _applyResidenceDeadlineBadge();
  }

  Future<void> _handlePostCompletion(GuideActionItem item) async {
    await PlanNotificationService.instance.cancelPlanReminders();
    if (item.id == 'item_2_2_residencia') {
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
    final residenceCompletedAt = _completedAtById['item_2_2_residencia'];
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
    );
  }
}

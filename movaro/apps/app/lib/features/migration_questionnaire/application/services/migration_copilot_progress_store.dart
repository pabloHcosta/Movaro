import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_identity.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

typedef CopilotDirectoryProvider = Future<Directory> Function();

class MigrationCopilotProgressSnapshot {
  const MigrationCopilotProgressSnapshot({
    this.readinessCompletedIds = const <String>{},
    this.documentCompletedIds = const <String>{},
    this.arrivalCompletedIds = const <String>{},
    this.activeItemId,
    this.completedAtById = const <String, String>{},
    this.prioritizedItemIds = const <String>{},
    this.dismissedReasonsById = const <String, GuideDismissReason>{},
    this.taskStatesById = const <String, GuideTaskState>{},
    this.taskDecisionDataById = const <String, Map<String, dynamic>>{},
  });

  final Set<String> readinessCompletedIds;
  final Set<String> documentCompletedIds;
  final Set<String> arrivalCompletedIds;
  final String? activeItemId;
  final Map<String, String> completedAtById;
  final Set<String> prioritizedItemIds;
  final Map<String, GuideDismissReason> dismissedReasonsById;
  final Map<String, GuideTaskState> taskStatesById;
  final Map<String, Map<String, dynamic>> taskDecisionDataById;

  GuideTaskState stateFor(String itemId) {
    if (getAllCompletedIds().contains(itemId)) {
      return GuideTaskState.completed;
    }
    return taskStatesById[itemId] ?? GuideTaskState.notStarted;
  }

  Set<String> getAllCompletedIds() => <String>{
    ...readinessCompletedIds,
    ...documentCompletedIds,
    ...arrivalCompletedIds,
  };

  int get completedItemsCount => getAllCompletedIds().length;

  double getProgressPercent(int totalItems) {
    if (totalItems <= 0) {
      return 0;
    }
    return completedItemsCount / totalItems;
  }
}

class MigrationCopilotProgressStore {
  static const _storageKey = 'movaro_copilot_progress';

  MigrationCopilotProgressStore({CopilotDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CopilotDirectoryProvider _directoryProvider;

  Future<MigrationCopilotProgressSnapshot> read(MigrationPlan plan) async {
    try {
      final decoded = await exportState();
      if (decoded is! Map<String, dynamic>) {
        return const MigrationCopilotProgressSnapshot();
      }

      final key = MigrationPlanIdentity.storageKeyFor(plan);
      final value = decoded[key];
      if (value is! Map<String, dynamic>) {
        return const MigrationCopilotProgressSnapshot();
      }

      return MigrationCopilotProgressSnapshot(
        readinessCompletedIds: _readStringSet(value['readinessCompletedIds']),
        documentCompletedIds: _readStringSet(value['documentCompletedIds']),
        arrivalCompletedIds: _readStringSet(value['arrivalCompletedIds']),
        activeItemId: value['activeItemId'] as String?,
        completedAtById: _readStringMap(value['completedAtById']),
        prioritizedItemIds: _readStringSet(value['prioritizedItemIds']),
        dismissedReasonsById: _readDismissReasons(
          value['dismissedReasonsById'],
        ),
        taskStatesById: _readTaskStates(value['taskStatesById']),
        taskDecisionDataById: _readNestedDynamicMap(
          value['taskDecisionDataById'],
        ),
      );
    } catch (_) {
      return const MigrationCopilotProgressSnapshot();
    }
  }

  Future<Map<String, dynamic>?> exportState() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required MigrationPlan plan,
    required Set<String> readinessCompletedIds,
    required Set<String> documentCompletedIds,
    required Set<String> arrivalCompletedIds,
    String? activeItemId,
    Map<String, String>? completedAtById,
    Set<String>? prioritizedItemIds,
    Map<String, GuideDismissReason>? dismissedReasonsById,
    Map<String, GuideTaskState>? taskStatesById,
    Map<String, Map<String, dynamic>>? taskDecisionDataById,
  }) async {
    Map<String, dynamic> current = <String, dynamic>{};
    final existing = await PersistentJsonStore.read(
      key: _storageKey,
      fileProvider: _file,
    );
    if (existing is Map<String, dynamic>) {
      current = existing;
    }

    final planKey = MigrationPlanIdentity.storageKeyFor(plan);
    final existingPlanState = current[planKey];
    final existingMap = existingPlanState is Map<String, dynamic>
        ? existingPlanState
        : const <String, dynamic>{};

    current[planKey] = <String, dynamic>{
      'readinessCompletedIds': readinessCompletedIds.toList()..sort(),
      'documentCompletedIds': documentCompletedIds.toList()..sort(),
      'arrivalCompletedIds': arrivalCompletedIds.toList()..sort(),
      'activeItemId': activeItemId,
      'completedAtById': completedAtById ?? const <String, String>{},
      'prioritizedItemIds':
          (prioritizedItemIds ??
                  _readStringSet(existingMap['prioritizedItemIds']))
              .toList()
            ..sort(),
      'dismissedReasonsById': _encodeDismissReasons(
        dismissedReasonsById ??
            _readDismissReasons(existingMap['dismissedReasonsById']),
      ),
      'taskStatesById': _encodeTaskStates(
        taskStatesById ?? _readTaskStates(existingMap['taskStatesById']),
      ),
      'taskDecisionDataById':
          taskDecisionDataById ??
          _readNestedDynamicMap(existingMap['taskDecisionDataById']),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await PersistentJsonStore.write(
      key: _storageKey,
      data: current,
      fileProvider: _file,
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> importState(Map<String, dynamic>? value) async {
    if (value == null || value.isEmpty) {
      await clear();
      return;
    }

    await PersistentJsonStore.write(
      key: _storageKey,
      data: value,
      fileProvider: _file,
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> clear() async {
    await PersistentJsonStore.delete(key: _storageKey, fileProvider: _file);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<bool> hasLocalData() async {
    final value = await exportState();
    return value != null && value.isNotEmpty;
  }

  Map<String, String> _readStringMap(Object? rawValue) {
    if (rawValue is! Map) {
      return <String, String>{};
    }
    final result = <String, String>{};
    rawValue.forEach((key, value) {
      if (key is String && value is String) {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, Map<String, dynamic>> _readNestedDynamicMap(Object? rawValue) {
    if (rawValue is! Map) {
      return <String, Map<String, dynamic>>{};
    }
    final result = <String, Map<String, dynamic>>{};
    rawValue.forEach((key, value) {
      if (key is String && value is Map) {
        result[key] = Map<String, dynamic>.from(value);
      }
    });
    return result;
  }

  Set<String> _readStringSet(Object? rawValue) {
    if (rawValue is! List) {
      return <String>{};
    }

    return rawValue.whereType<String>().toSet();
  }

  Map<String, GuideDismissReason> _readDismissReasons(Object? rawValue) {
    if (rawValue is! Map) {
      return <String, GuideDismissReason>{};
    }

    final result = <String, GuideDismissReason>{};
    rawValue.forEach((key, value) {
      if (key is! String || value is! String) {
        return;
      }
      for (final reason in GuideDismissReason.values) {
        if (reason.name == value) {
          result[key] = reason;
          break;
        }
      }
    });
    return result;
  }

  Map<String, String> _encodeDismissReasons(
    Map<String, GuideDismissReason> dismissedReasonsById,
  ) {
    final result = <String, String>{};
    dismissedReasonsById.forEach((key, value) {
      result[key] = value.name;
    });
    return result;
  }

  Map<String, GuideTaskState> _readTaskStates(Object? rawValue) {
    if (rawValue is! Map) {
      return <String, GuideTaskState>{};
    }
    final result = <String, GuideTaskState>{};
    rawValue.forEach((key, value) {
      if (key is! String || value is! String) {
        return;
      }
      final state = GuideTaskState.values.cast<GuideTaskState?>().firstWhere(
        (candidate) => candidate?.name == value,
        orElse: () => null,
      );
      if (state != null) {
        result[key] = state;
      }
    });
    return result;
  }

  Map<String, String> _encodeTaskStates(
    Map<String, GuideTaskState> taskStatesById,
  ) => <String, String>{
    for (final entry in taskStatesById.entries) entry.key: entry.value.name,
  };

  Set<String> getAllCompletedIds(MigrationCopilotProgressSnapshot snapshot) {
    return snapshot.getAllCompletedIds();
  }

  int getTotalItems({
    required int readinessItems,
    required int documentItems,
    required int arrivalItems,
  }) {
    return readinessItems + documentItems + arrivalItems;
  }

  double getProgressPercent({
    required MigrationCopilotProgressSnapshot snapshot,
    required int totalItems,
  }) {
    return snapshot.getProgressPercent(totalItems);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_copilot_progress.json');
  }
}

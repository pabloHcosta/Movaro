import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
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
  });

  final Set<String> readinessCompletedIds;
  final Set<String> documentCompletedIds;
  final Set<String> arrivalCompletedIds;
  final String? activeItemId;
  final Map<String, String> completedAtById;
  final Set<String> prioritizedItemIds;
  final Map<String, GuideDismissReason> dismissedReasonsById;

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
  MigrationCopilotProgressStore({CopilotDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CopilotDirectoryProvider _directoryProvider;

  Future<MigrationCopilotProgressSnapshot> read(MigrationPlan plan) async {
    try {
      final decoded = await exportState();
      if (decoded is! Map<String, dynamic>) {
        return const MigrationCopilotProgressSnapshot();
      }

      final key = _planKey(plan);
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
      );
    } catch (_) {
      return const MigrationCopilotProgressSnapshot();
    }
  }

  Future<Map<String, dynamic>?> exportState() async {
    try {
      final file = await _file();
      final decoded = await VersionedJsonFileStore.read(file);
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
  }) async {
    final file = await _file();
    Map<String, dynamic> current = <String, dynamic>{};
    final existing = await VersionedJsonFileStore.read(file);
    if (existing is Map<String, dynamic>) {
      current = existing;
    }

    final existingPlanState = current[_planKey(plan)];
    final existingMap = existingPlanState is Map<String, dynamic>
        ? existingPlanState
        : const <String, dynamic>{};

    current[_planKey(plan)] = <String, dynamic>{
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
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await VersionedJsonFileStore.write(file, current);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> importState(Map<String, dynamic>? value) async {
    if (value == null || value.isEmpty) {
      await clear();
      return;
    }

    final file = await _file();
    await VersionedJsonFileStore.write(file, value);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> clear() async {
    final file = await _file();
    await VersionedJsonFileStore.delete(file);
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

  String _planKey(MigrationPlan plan) {
    final cityId = plan.currentPlanCity?.id ?? 'no-city';
    return [
      plan.originCountry,
      plan.destinationCountry,
      plan.goal,
      plan.timeline,
      cityId,
    ].join('::');
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_copilot_progress.json');
  }
}

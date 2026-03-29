import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/migration_plan_repository.dart';

typedef MigrationPlanDirectoryProvider = Future<Directory> Function();

class LocalMigrationPlanRepository implements MigrationPlanRepository {
  LocalMigrationPlanRepository({
    MigrationPlanDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final MigrationPlanDirectoryProvider _directoryProvider;

  @override
  Future<MigrationPlan?> getCurrentPlan() async {
    final state = await _readState();
    return state.currentPlan;
  }

  @override
  Future<void> setCurrentPlan(MigrationPlan? plan) async {
    final state = await _readState();
    await _writeState(state.copyWith(currentPlan: plan));
  }

  @override
  Future<void> savePlan(MigrationPlan plan) async {
    final state = await _readState();
    final nextSavedPlans = [...state.savedPlans];
    final encodedPlan = MigrationPlanModel.fromEntity(plan).toJson();

    nextSavedPlans.removeWhere(
      (savedPlan) => _jsonEquals(
        MigrationPlanModel.fromEntity(savedPlan).toJson(),
        encodedPlan,
      ),
    );
    nextSavedPlans.insert(0, plan);

    await _writeState(
      _MigrationPlansState(
        currentPlan: state.currentPlan,
        savedPlans: nextSavedPlans,
      ),
    );
  }

  @override
  Future<List<MigrationPlan>> getSavedPlans() async {
    final state = await _readState();
    return List<MigrationPlan>.unmodifiable(state.savedPlans);
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

  Future<void> importState(Map<String, dynamic>? value) async {
    if (value == null || value.isEmpty) {
      final file = await _file();
      await VersionedJsonFileStore.delete(file);
      MigrationStateSyncCoordinator.scheduleSync();
      return;
    }

    final file = await _file();
    await VersionedJsonFileStore.write(file, value);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<bool> hasLocalData() async {
    final state = await _readState();
    return state.currentPlan != null || state.savedPlans.isNotEmpty;
  }

  Future<_MigrationPlansState> _readState() async {
    try {
      final decoded = await exportState();
      if (decoded is! Map<String, dynamic>) {
        return const _MigrationPlansState();
      }

      final currentJson = decoded['currentPlan'];
      final savedJson = decoded['savedPlans'];

      return _MigrationPlansState(
        currentPlan: currentJson is Map<String, dynamic>
            ? MigrationPlanModel.fromJson(currentJson).toEntity()
            : null,
        savedPlans: savedJson is List
            ? savedJson
                  .whereType<Map<String, dynamic>>()
                  .map(MigrationPlanModel.fromJson)
                  .map((model) => model.toEntity())
                  .toList(growable: false)
            : const [],
      );
    } catch (_) {
      return const _MigrationPlansState();
    }
  }

  Future<void> _writeState(_MigrationPlansState state) async {
    final file = await _file();
    await VersionedJsonFileStore.write(file, {
      'currentPlan': state.currentPlan == null
          ? null
          : MigrationPlanModel.fromEntity(state.currentPlan!).toJson(),
      'savedPlans': state.savedPlans
          .map((plan) => MigrationPlanModel.fromEntity(plan).toJson())
          .toList(),
    });
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_migration_plans.json');
  }
}

class _MigrationPlansState {
  const _MigrationPlansState({this.currentPlan, this.savedPlans = const []});

  final MigrationPlan? currentPlan;
  final List<MigrationPlan> savedPlans;

  _MigrationPlansState copyWith({
    Object? currentPlan = _sentinel,
    List<MigrationPlan>? savedPlans,
  }) {
    return _MigrationPlansState(
      currentPlan: identical(currentPlan, _sentinel)
          ? this.currentPlan
          : currentPlan as MigrationPlan?,
      savedPlans: savedPlans ?? this.savedPlans,
    );
  }
}

const Object _sentinel = Object();

bool _jsonEquals(Map<String, dynamic> left, Map<String, dynamic> right) {
  if (left.length != right.length) {
    return false;
  }

  for (final entry in left.entries) {
    if (!_jsonValueEquals(entry.value, right[entry.key])) {
      return false;
    }
  }

  return true;
}

bool _jsonValueEquals(Object? left, Object? right) {
  if (left is Map<String, dynamic> && right is Map<String, dynamic>) {
    return _jsonEquals(left, right);
  }

  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (!_jsonValueEquals(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }

  return left == right;
}

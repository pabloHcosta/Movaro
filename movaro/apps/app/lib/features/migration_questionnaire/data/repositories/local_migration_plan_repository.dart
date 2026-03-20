import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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
    final encodedPlan = jsonEncode(
      MigrationPlanModel.fromEntity(plan).toJson(),
    );

    nextSavedPlans.removeWhere(
      (savedPlan) =>
          jsonEncode(MigrationPlanModel.fromEntity(savedPlan).toJson()) ==
          encodedPlan,
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

  Future<_MigrationPlansState> _readState() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return const _MigrationPlansState();
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const _MigrationPlansState();
      }

      final decoded = jsonDecode(raw);
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
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'currentPlan': state.currentPlan == null
            ? null
            : MigrationPlanModel.fromEntity(state.currentPlan!).toJson(),
        'savedPlans': state.savedPlans
            .map((plan) => MigrationPlanModel.fromEntity(plan).toJson())
            .toList(),
      }),
    );
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

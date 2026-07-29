import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

typedef MigrationPlanDirectoryProvider = Future<Directory> Function();

class LatestMigrationPlanStore {
  static const _storageKey = 'movaro_latest_migration_plan';

  LatestMigrationPlanStore({MigrationPlanDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final MigrationPlanDirectoryProvider _directoryProvider;

  Future<MigrationPlan?> read() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return MigrationPlanModel.fromJson(decoded).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(MigrationPlan plan) async {
    final model = MigrationPlanModel.fromEntity(plan);
    await PersistentJsonStore.write(
      key: _storageKey,
      data: model.toJson(),
      fileProvider: _file,
    );
  }

  Future<void> clear() async {
    await PersistentJsonStore.delete(key: _storageKey, fileProvider: _file);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_latest_migration_plan.json');
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

typedef MigrationPlanDirectoryProvider = Future<Directory> Function();

class LatestMigrationPlanStore {
  LatestMigrationPlanStore({MigrationPlanDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final MigrationPlanDirectoryProvider _directoryProvider;

  Future<MigrationPlan?> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return null;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return MigrationPlanModel.fromJson(decoded).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(MigrationPlan plan) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final model = MigrationPlanModel.fromEntity(plan);
    await file.writeAsString(jsonEncode(model.toJson()));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_latest_migration_plan.json');
  }
}

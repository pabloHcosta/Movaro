import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

typedef CopilotDirectoryProvider = Future<Directory> Function();

class MigrationCopilotProgressSnapshot {
  const MigrationCopilotProgressSnapshot({
    this.readinessCompletedIds = const <String>{},
    this.documentCompletedIds = const <String>{},
    this.arrivalCompletedIds = const <String>{},
  });

  final Set<String> readinessCompletedIds;
  final Set<String> documentCompletedIds;
  final Set<String> arrivalCompletedIds;
}

class MigrationCopilotProgressStore {
  MigrationCopilotProgressStore({CopilotDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CopilotDirectoryProvider _directoryProvider;

  Future<MigrationCopilotProgressSnapshot> read(MigrationPlan plan) async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return const MigrationCopilotProgressSnapshot();
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const MigrationCopilotProgressSnapshot();
      }

      final decoded = jsonDecode(raw);
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
      );
    } catch (_) {
      return const MigrationCopilotProgressSnapshot();
    }
  }

  Future<void> write({
    required MigrationPlan plan,
    required Set<String> readinessCompletedIds,
    required Set<String> documentCompletedIds,
    required Set<String> arrivalCompletedIds,
  }) async {
    final file = await _file();
    await file.parent.create(recursive: true);

    Map<String, dynamic> current = <String, dynamic>{};
    if (file.existsSync()) {
      try {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          current = decoded;
        }
      } catch (_) {
        current = <String, dynamic>{};
      }
    }

    current[_planKey(plan)] = <String, dynamic>{
      'readinessCompletedIds': readinessCompletedIds.toList()..sort(),
      'documentCompletedIds': documentCompletedIds.toList()..sort(),
      'arrivalCompletedIds': arrivalCompletedIds.toList()..sort(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await file.writeAsString(jsonEncode(current));
  }

  Set<String> _readStringSet(Object? rawValue) {
    if (rawValue is! List) {
      return <String>{};
    }

    return rawValue.whereType<String>().toSet();
  }

  String _planKey(MigrationPlan plan) {
    final cityId = plan.recommendedCity?.id ?? 'no-city';
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

import 'dart:convert';

import 'package:mudavi_app/features/journey/journey_preferences_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';

class MigrationBackupBundle {
  const MigrationBackupBundle({
    required this.exportedAt,
    required this.journey,
    required this.migrationPlans,
    required this.questionnaireDraft,
    required this.copilotProgress,
  });

  static const format = 'mudavi-migration-backup';
  static const schemaVersion = 1;

  final DateTime exportedAt;
  final Map<String, dynamic> journey;
  final Map<String, dynamic>? migrationPlans;
  final Map<String, dynamic>? questionnaireDraft;
  final Map<String, dynamic>? copilotProgress;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'format': format,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'payload': <String, dynamic>{
      'journey': journey,
      'migrationPlans': migrationPlans,
      'questionnaireDraft': questionnaireDraft,
      'copilotProgress': copilotProgress,
    },
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory MigrationBackupBundle.decode(String rawValue) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawValue);
    } on FormatException {
      throw const FormatException('invalid_json');
    }

    final root = _stringMap(decoded);
    if (root == null || root['format'] != format) {
      throw const FormatException('invalid_format');
    }
    if (root['schemaVersion'] != schemaVersion) {
      throw const FormatException('unsupported_version');
    }

    final rawExportedAt = root['exportedAt'];
    final exportedAt = rawExportedAt is String
        ? DateTime.tryParse(rawExportedAt)
        : null;
    if (exportedAt == null) {
      throw const FormatException('invalid_export_date');
    }

    final payload = _stringMap(root['payload']);
    if (payload == null ||
        !payload.containsKey('journey') ||
        !payload.containsKey('migrationPlans') ||
        !payload.containsKey('questionnaireDraft') ||
        !payload.containsKey('copilotProgress')) {
      throw const FormatException('invalid_payload');
    }

    final journey = _stringMap(payload['journey']);
    final migrationPlans = _nullableStringMap(
      payload['migrationPlans'],
      field: 'migrationPlans',
    );
    final questionnaireDraft = _nullableStringMap(
      payload['questionnaireDraft'],
      field: 'questionnaireDraft',
    );
    final copilotProgress = _nullableStringMap(
      payload['copilotProgress'],
      field: 'copilotProgress',
    );
    if (journey == null) {
      throw const FormatException('invalid_payload');
    }

    return MigrationBackupBundle(
      exportedAt: exportedAt.toUtc(),
      journey: journey,
      migrationPlans: migrationPlans,
      questionnaireDraft: questionnaireDraft,
      copilotProgress: copilotProgress,
    );
  }
}

class MigrationBackupService {
  const MigrationBackupService({
    required JourneyPreferencesStore journeyPreferencesStore,
    required LocalMigrationPlanRepository migrationPlanRepository,
    required QuestionnaireFlowDraftStore flowDraftStore,
    required MigrationCopilotProgressStore copilotProgressStore,
  }) : _journeyPreferencesStore = journeyPreferencesStore,
       _migrationPlanRepository = migrationPlanRepository,
       _flowDraftStore = flowDraftStore,
       _copilotProgressStore = copilotProgressStore;

  final JourneyPreferencesStore _journeyPreferencesStore;
  final LocalMigrationPlanRepository _migrationPlanRepository;
  final QuestionnaireFlowDraftStore _flowDraftStore;
  final MigrationCopilotProgressStore _copilotProgressStore;

  Future<String> exportBackup() async {
    final bundle = MigrationBackupBundle(
      exportedAt: DateTime.now().toUtc(),
      journey: await _journeyPreferencesStore.read(),
      migrationPlans: await _migrationPlanRepository.exportState(),
      questionnaireDraft: await _flowDraftStore.exportState(),
      copilotProgress: await _copilotProgressStore.exportState(),
    );
    return bundle.encode();
  }

  Future<MigrationBackupBundle> restoreBackup(String rawValue) async {
    final bundle = MigrationBackupBundle.decode(rawValue.trim());
    final previousJourney = await _journeyPreferencesStore.read();
    final previousPlans = await _migrationPlanRepository.exportState();
    final previousDraft = await _flowDraftStore.exportState();
    final previousProgress = await _copilotProgressStore.exportState();

    try {
      await MigrationStateSyncCoordinator.suspend(() async {
        await _journeyPreferencesStore.write(bundle.journey);
        await _migrationPlanRepository.importState(bundle.migrationPlans);
        await _flowDraftStore.importState(bundle.questionnaireDraft);
        await _copilotProgressStore.importState(bundle.copilotProgress);
      });
    } catch (_) {
      await MigrationStateSyncCoordinator.suspend(() async {
        await _journeyPreferencesStore.write(previousJourney);
        await _migrationPlanRepository.importState(previousPlans);
        await _flowDraftStore.importState(previousDraft);
        await _copilotProgressStore.importState(previousProgress);
      });
      rethrow;
    }

    MigrationStateSyncCoordinator.scheduleSync();
    return bundle;
  }
}

Map<String, dynamic>? _stringMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  if (value.keys.any((key) => key is! String)) {
    return null;
  }
  return value.cast<String, dynamic>();
}

Map<String, dynamic>? _nullableStringMap(
  Object? value, {
  required String field,
}) {
  if (value == null) {
    return null;
  }
  final map = _stringMap(value);
  if (map == null) {
    throw FormatException('invalid_$field');
  }
  return map;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/features/journey/journey_preferences_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_backup_service.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('backup bundle round-trips every supported data block', () {
    final exportedAt = DateTime.utc(2026, 9, 11, 12, 30);
    final bundle = MigrationBackupBundle(
      exportedAt: exportedAt,
      journey: const {'originCountryId': 'argentina'},
      migrationPlans: const {
        'currentPlan': {'id': 'plan-1'},
        'savedPlans': [],
      },
      questionnaireDraft: const {'currentIndex': 2, 'answers': []},
      copilotProgress: const {
        'plan-1': {
          'landingBudgetOverrides': {'monthlyBaseBrl': 6400},
        },
      },
    );

    final restored = MigrationBackupBundle.decode(bundle.encode());

    expect(restored.exportedAt, exportedAt);
    expect(restored.journey, bundle.journey);
    expect(restored.migrationPlans, bundle.migrationPlans);
    expect(restored.questionnaireDraft, bundle.questionnaireDraft);
    expect(restored.copilotProgress, bundle.copilotProgress);
  });

  test('decoder rejects foreign, incomplete and newer backups', () {
    expect(
      () => MigrationBackupBundle.decode('{"hello":"world"}'),
      throwsFormatException,
    );
    expect(
      () => MigrationBackupBundle.decode(
        jsonEncode({
          'format': MigrationBackupBundle.format,
          'schemaVersion': 1,
          'exportedAt': '2026-09-11T12:30:00Z',
          'payload': {'journey': {}},
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => MigrationBackupBundle.decode(
        jsonEncode({
          'format': MigrationBackupBundle.format,
          'schemaVersion': 2,
          'exportedAt': '2026-09-11T12:30:00Z',
          'payload': {},
        }),
      ),
      throwsFormatException,
    );
  });

  test('service replaces local state with the selected backup', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mudavi_backup_test',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });
    Future<Directory> directoryProvider() async => directory;
    final journeyStore = JourneyPreferencesStore(
      directoryProvider: directoryProvider,
    );
    final planRepository = LocalMigrationPlanRepository(
      directoryProvider: directoryProvider,
    );
    final draftStore = QuestionnaireFlowDraftStore(
      directoryProvider: directoryProvider,
    );
    final progressStore = MigrationCopilotProgressStore(
      directoryProvider: directoryProvider,
    );
    final service = MigrationBackupService(
      journeyPreferencesStore: journeyStore,
      migrationPlanRepository: planRepository,
      flowDraftStore: draftStore,
      copilotProgressStore: progressStore,
    );

    await journeyStore.write(const {'originCountryId': 'argentina'});
    await planRepository.importState(const {
      'currentPlan': null,
      'savedPlans': [],
    });
    await progressStore.importState(const {
      'plan-1': {
        'landingBudgetOverrides': {'monthlyBaseBrl': 6400},
      },
    });
    final backup = await service.exportBackup();

    await journeyStore.write(const {'originCountryId': 'chile'});
    await progressStore.clear();
    await service.restoreBackup(backup);

    expect(
      await journeyStore.read(),
      containsPair('originCountryId', 'argentina'),
    );
    expect(
      await progressStore.exportState(),
      containsPair('plan-1', isA<Map<String, dynamic>>()),
    );
  });
}

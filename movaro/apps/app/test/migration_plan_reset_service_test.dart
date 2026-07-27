import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/latest_migration_plan_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_reset_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new plan clears progress and plan-scoped cached data', () async {
    final directory = await Directory.systemTemp.createTemp(
      'movaro_plan_reset_test',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final progressStore = MigrationCopilotProgressStore(
      directoryProvider: () async => directory,
    );
    final suggestionStore = GuideEventSuggestionStore(
      directoryProvider: () async => directory,
    );
    final latestPlanStore = LatestMigrationPlanStore(
      directoryProvider: () async => directory,
    );
    final resetService = MigrationPlanResetService(
      copilotProgressStore: progressStore,
      eventSuggestionStore: suggestionStore,
      latestPlanStore: latestPlanStore,
    );
    const previousPlan = MigrationPlan(
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      goal: 'remote_income',
      timeline: 'in_3_6m',
      steps: [],
    );

    await progressStore.write(
      plan: previousPlan,
      readinessCompletedIds: const {'old_step'},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      activeItemId: 'old_step',
    );
    await suggestionStore.markPresented(
      plan: previousPlan,
      suggestionId: 'old_suggestion',
    );
    await latestPlanStore.write(previousPlan);

    expect(
      (await progressStore.read(previousPlan)).getAllCompletedIds(),
      contains('old_step'),
    );
    expect(
      (await suggestionStore.readPreference(
        plan: previousPlan,
        suggestionId: 'old_suggestion',
      )).presentedAt,
      isNotNull,
    );
    expect(await latestPlanStore.read(), isNotNull);

    await resetService.clearPreviousPlanData();

    expect(
      (await progressStore.read(previousPlan)).getAllCompletedIds(),
      isEmpty,
    );
    expect(
      (await suggestionStore.readPreference(
        plan: previousPlan,
        suggestionId: 'old_suggestion',
      )).presentedAt,
      isNull,
    );
    expect(await latestPlanStore.read(), isNull);
  });

  test('different plan ids never share completed steps', () async {
    final directory = await Directory.systemTemp.createTemp(
      'movaro_plan_identity_test',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final progressStore = MigrationCopilotProgressStore(
      directoryProvider: () async => directory,
    );
    const florianopolisPlan = MigrationPlan(
      id: 'plan-florianopolis',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      goal: 'remote_income',
      timeline: 'in_3_6m',
      steps: [],
    );
    const saoPauloPlan = MigrationPlan(
      id: 'plan-sao-paulo',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      goal: 'remote_income',
      timeline: 'in_3_6m',
      steps: [],
    );

    await progressStore.write(
      plan: florianopolisPlan,
      readinessCompletedIds: const {'florianopolis_housing'},
      documentCompletedIds: const {'florianopolis_documents'},
      arrivalCompletedIds: const {},
    );

    expect(
      (await progressStore.read(florianopolisPlan)).getAllCompletedIds(),
      containsAll({'florianopolis_housing', 'florianopolis_documents'}),
    );
    expect(
      (await progressStore.read(saoPauloPlan)).getAllCompletedIds(),
      isEmpty,
    );
  });
}

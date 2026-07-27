import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  test('persists waiting and completed task states compatibly', () async {
    final directory = await Directory.systemTemp.createTemp(
      'movaro_task_state_test',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = MigrationCopilotProgressStore(
      directoryProvider: () async => directory,
    );
    const plan = MigrationPlan(
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      goal: 'work',
      timeline: 'in_3_6m',
      steps: [],
    );

    await store.write(
      plan: plan,
      readinessCompletedIds: const {'done'},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      taskStatesById: const {
        'waiting': GuideTaskState.waiting,
        'done': GuideTaskState.completed,
      },
    );
    final snapshot = await store.read(plan);

    expect(snapshot.stateFor('waiting'), GuideTaskState.waiting);
    expect(snapshot.stateFor('done'), GuideTaskState.completed);
    expect(snapshot.stateFor('new'), GuideTaskState.notStarted);
  });
}

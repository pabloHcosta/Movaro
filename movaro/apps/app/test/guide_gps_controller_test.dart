import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/guide_gps_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('leaving an item for later does not complete or unlock it', () async {
    SharedPreferences.setMockInitialValues({});
    final metrics = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await metrics.setConsent(ProductAnalyticsConsent.denied);
    final directory = await Directory.systemTemp.createTemp(
      'movaro-guide-gps-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = MigrationCopilotProgressStore(
      directoryProvider: () async => directory,
    );
    final controller = GuideGpsController(
      plan: _plan,
      progressStore: store,
      items: [_item, _dependentItem],
      readinessCompletedIds: const {},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      metricsStore: metrics,
    );

    await controller.dismissItem(_item.id, GuideDismissReason.later);

    final postponed = controller.items.firstWhere(
      (item) => item.id == _item.id,
    );
    expect(postponed.isCompleted, isFalse);
    expect(postponed.dismissReason, GuideDismissReason.later);
    expect(controller.allCompletedIds, isNot(contains(_item.id)));
    expect(controller.isItemUnlocked(_dependentItem), isFalse);
    expect(
      controller.focusSnapshot.later.map((item) => item.id),
      contains(_item.id),
    );

    final persisted = await store.read(_plan);
    expect(persisted.getAllCompletedIds(), isNot(contains(_item.id)));
    expect(persisted.dismissedReasonsById[_item.id], GuideDismissReason.later);
    expect(persisted.taskStatesById[_item.id], GuideTaskState.waiting);
  });

  test('legacy postponed completion is normalized while hydrating', () async {
    SharedPreferences.setMockInitialValues({});
    final metrics = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await metrics.setConsent(ProductAnalyticsConsent.denied);
    final directory = await Directory.systemTemp.createTemp(
      'movaro-guide-gps-legacy-',
    );
    addTearDown(() => directory.delete(recursive: true));

    final controller = GuideGpsController(
      plan: _plan,
      progressStore: MigrationCopilotProgressStore(
        directoryProvider: () async => directory,
      ),
      items: [_item.copyWith(isCompleted: true), _dependentItem],
      readinessCompletedIds: {_item.id},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      dismissedReasonsById: {_item.id: GuideDismissReason.later},
      taskStatesById: {_item.id: GuideTaskState.completed},
      metricsStore: metrics,
    );

    expect(controller.items.first.isCompleted, isFalse);
    expect(controller.readinessCompletedIds, isNot(contains(_item.id)));
    expect(controller.allCompletedIds, isNot(contains(_item.id)));
    expect(controller.isItemUnlocked(_dependentItem), isFalse);
  });

  test('hydration preserves automatic not-applicable dismissals', () async {
    SharedPreferences.setMockInitialValues({});
    final metrics = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await metrics.setConsent(ProductAnalyticsConsent.denied);
    final directory = await Directory.systemTemp.createTemp(
      'movaro-guide-gps-applicability-',
    );
    addTearDown(() => directory.delete(recursive: true));

    final controller = GuideGpsController(
      plan: _plan,
      progressStore: MigrationCopilotProgressStore(
        directoryProvider: () async => directory,
      ),
      items: [
        _item.copyWith(
          isCompleted: true,
          dismissReason: GuideDismissReason.notApplicable,
        ),
      ],
      readinessCompletedIds: const {},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      metricsStore: metrics,
    );

    expect(
      controller.items.single.dismissReason,
      GuideDismissReason.notApplicable,
    );
    expect(controller.focusSnapshot.completed, isEmpty);
    expect(controller.allCompletedIds, contains(_item.id));
  });

  test('persists decision-assistant answers with the current plan', () async {
    SharedPreferences.setMockInitialValues({});
    final metrics = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await metrics.setConsent(ProductAnalyticsConsent.denied);
    final directory = await Directory.systemTemp.createTemp(
      'movaro-guide-decision-data-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = MigrationCopilotProgressStore(
      directoryProvider: () async => directory,
    );
    final controller = GuideGpsController(
      plan: _plan,
      progressStore: store,
      items: [_item],
      readinessCompletedIds: const {},
      documentCompletedIds: const {},
      arrivalCompletedIds: const {},
      metricsStore: metrics,
    );

    await controller.saveTaskDecisionData(_item.id, {
      'ageGroup': 'adult',
      'countries': ['Argentina', 'Chile'],
    });

    final persisted = await store.read(_plan);
    expect(
      persisted.taskDecisionDataById[_item.id],
      containsPair('ageGroup', 'adult'),
    );
    expect(persisted.taskDecisionDataById[_item.id]?['countries'], [
      'Argentina',
      'Chile',
    ]);
  });
}

const _plan = MigrationPlan(
  originCountry: 'Argentina',
  destinationCountry: 'Brasil',
  goal: 'find_job_br',
  timeline: 'in_0_3m',
  steps: [],
);

const _item = GuideActionItem(
  id: 'item_0_2_document_folder',
  title: 'Pasta migratória',
  shortDescription: 'Organize documentos',
  type: GuideActionType.checklist,
  phase: GuidePhase.preparation,
  orderIndex: 0,
  isCompleted: false,
  tier: GuideItemTier.critical,
);

const _dependentItem = GuideActionItem(
  id: 'dependent',
  title: 'Dependente',
  shortDescription: 'Só depois da pasta',
  type: GuideActionType.informative,
  phase: GuidePhase.documents,
  orderIndex: 1,
  isCompleted: false,
  tier: GuideItemTier.recommended,
  dependencies: ['item_0_2_document_folder'],
);

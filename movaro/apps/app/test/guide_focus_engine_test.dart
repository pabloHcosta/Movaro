import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_focus_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  test('shows one focus action, two follow-ups, and meaningful buckets', () {
    final snapshot = GuideFocusEngine.build(
      plan: _plan(),
      items: [
        _item(id: 'optional', order: 0, tier: GuideItemTier.optional),
        _item(
          id: 'before_travel',
          order: 3,
          tier: GuideItemTier.critical,
          preArrival: true,
        ),
        _item(id: 'recommended', order: 1, tier: GuideItemTier.recommended),
        _item(
          id: 'arrival',
          order: 2,
          tier: GuideItemTier.recommended,
          phase: GuidePhase.arrival,
        ),
        _item(
          id: 'done',
          order: 4,
          tier: GuideItemTier.critical,
          completed: true,
        ),
        _item(
          id: 'milestone',
          order: -1,
          tier: GuideItemTier.optional,
          completed: true,
        ).copyWith(id: 'questionnaire_goal_defined'),
      ],
    );

    expect(snapshot.current?.id, 'before_travel');
    expect(snapshot.now.length, lessThanOrEqualTo(3));
    expect(
      snapshot.now
          .map((item) => item.id)
          .toSet()
          .intersection(snapshot.onArrival.map((item) => item.id).toSet()),
      isEmpty,
    );
    expect(snapshot.upcoming.length, lessThanOrEqualTo(2));
    expect(snapshot.onArrival.map((item) => item.id), contains('arrival'));
    expect(snapshot.optional.map((item) => item.id), contains('optional'));
    expect(snapshot.completed.map((item) => item.id), contains('done'));
    expect(
      snapshot.completed.map((item) => item.id),
      isNot(contains('questionnaire_goal_defined')),
    );
    expect(snapshot.coreTotalCount, 0);
    expect(snapshot.coreCompletedCount, 0);
    expect(snapshot.pendingBeforeTravelCount, 1);
  });

  test('respects a selected unlocked item without losing the focus list', () {
    final snapshot = GuideFocusEngine.build(
      plan: _plan(),
      activeItemId: 'chosen',
      items: [
        _item(id: 'critical', order: 0, tier: GuideItemTier.critical),
        _item(id: 'chosen', order: 1, tier: GuideItemTier.recommended),
      ],
    );

    expect(snapshot.current?.id, 'chosen');
    expect(snapshot.now.first.id, 'chosen');
  });

  test(
    'focuses arrival-day work without duplicating it in arrival backlog',
    () {
      final snapshot = GuideFocusEngine.build(
        plan: _plan(),
        items: [
          _item(
            id: 'arrival',
            order: 0,
            tier: GuideItemTier.recommended,
            phase: GuidePhase.arrival,
          ),
        ],
      );

      expect(snapshot.current?.id, 'arrival');
      expect(snapshot.now.map((item) => item.id), ['arrival']);
      expect(snapshot.onArrival, isEmpty);
    },
  );

  test('execution window outranks thematic phase and generic score', () {
    final snapshot = GuideFocusEngine.build(
      plan: _plan(),
      items: [
        _item(
          id: 'first_week_critical',
          order: 0,
          tier: GuideItemTier.critical,
          phase: GuidePhase.documents,
        ).copyWith(executionWindow: GuideExecutionWindow.firstWeek),
        _item(
          id: 'arrival_day',
          order: 1,
          tier: GuideItemTier.recommended,
          phase: GuidePhase.arrival,
        ).copyWith(executionWindow: GuideExecutionWindow.arrivalDay),
        _item(
          id: 'before_travel',
          order: 2,
          tier: GuideItemTier.recommended,
          phase: GuidePhase.work,
        ).copyWith(executionWindow: GuideExecutionWindow.beforeTravel),
      ],
    );

    expect(snapshot.current?.id, 'before_travel');
    expect(snapshot.now.map((item) => item.id), ['before_travel']);
  });

  test('counts a compact set of outcome milestones instead of every task', () {
    final snapshot = GuideFocusEngine.build(
      plan: _plan(),
      items: [
        _item(
          id: 'item_0_2_document_folder',
          order: 0,
          tier: GuideItemTier.critical,
        ),
        _item(
          id: 'item_2_1_cpf',
          order: 1,
          tier: GuideItemTier.critical,
          completed: true,
        ),
        _item(
          id: 'item_0_5_mercado_trabalho',
          order: 2,
          tier: GuideItemTier.recommended,
        ),
        _item(id: 'supporting_tip', order: 3, tier: GuideItemTier.recommended),
      ],
    );

    expect(snapshot.coreTotalCount, 3);
    expect(snapshot.coreCompletedCount, 1);
  });

  test('foundational preparation stays ahead of specialized study work', () {
    final snapshot = GuideFocusEngine.build(
      plan: _plan(goal: 'study', timeline: 'in_6_12m'),
      items: [
        _item(
          id: 'item_0_2_document_folder',
          order: 0,
          tier: GuideItemTier.critical,
          preArrival: true,
        ),
        _item(
          id: 'item_0_7_ingresso_ensino_superior',
          order: 20,
          tier: GuideItemTier.critical,
          preArrival: true,
        ),
        _item(
          id: 'item_2_7_documentos_academicos',
          order: 21,
          tier: GuideItemTier.critical,
          preArrival: true,
        ),
      ],
    );

    expect(snapshot.current?.id, 'item_0_2_document_folder');
    expect(
      snapshot.upcoming.map((item) => item.id),
      contains('item_0_7_ingresso_ensino_superior'),
    );
    expect(
      snapshot.upcoming.map((item) => item.id),
      contains('item_2_7_documentos_academicos'),
    );
  });

  test('postponed work stays pending and never unlocks dependencies', () {
    final postponed = _item(
      id: 'item_0_2_document_folder',
      order: 0,
      tier: GuideItemTier.critical,
      completed: true,
    ).copyWith(dismissReason: GuideDismissReason.later);
    final dependent = GuideActionItem(
      id: 'dependent',
      title: 'dependent',
      shortDescription: 'dependent',
      type: GuideActionType.informative,
      phase: GuidePhase.documents,
      orderIndex: 1,
      isCompleted: false,
      tier: GuideItemTier.recommended,
      dependencies: const ['item_0_2_document_folder'],
    );

    final snapshot = GuideFocusEngine.build(
      plan: _plan(),
      items: [postponed, dependent],
    );

    expect(snapshot.current, isNull);
    expect(snapshot.later.map((item) => item.id), contains(postponed.id));
    expect(
      snapshot.completed.map((item) => item.id),
      isNot(contains(postponed.id)),
    );
    expect(snapshot.coreTotalCount, 1);
    expect(snapshot.coreCompletedCount, 0);
  });
}

MigrationPlan _plan({
  String goal = 'find_job_br',
  String timeline = 'in_0_3m',
}) {
  return MigrationPlan(
    originCountry: 'Argentina',
    destinationCountry: 'Brasil',
    goal: goal,
    timeline: timeline,
    steps: const [],
  );
}

GuideActionItem _item({
  required String id,
  required int order,
  required GuideItemTier tier,
  GuidePhase phase = GuidePhase.preparation,
  bool preArrival = false,
  bool completed = false,
}) {
  return GuideActionItem(
    id: id,
    title: id,
    shortDescription: id,
    type: GuideActionType.informative,
    phase: phase,
    orderIndex: order,
    isCompleted: completed,
    tier: tier,
    preArrivalRequired: preArrival,
  );
}

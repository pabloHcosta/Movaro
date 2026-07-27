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
    expect(snapshot.upcoming.length, lessThanOrEqualTo(2));
    expect(snapshot.onArrival.map((item) => item.id), contains('arrival'));
    expect(snapshot.optional.map((item) => item.id), contains('optional'));
    expect(snapshot.completed.map((item) => item.id), contains('done'));
    expect(
      snapshot.completed.map((item) => item.id),
      isNot(contains('questionnaire_goal_defined')),
    );
    expect(snapshot.coreTotalCount, 4);
    expect(snapshot.coreCompletedCount, 1);
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
}

MigrationPlan _plan() {
  return const MigrationPlan(
    originCountry: 'Argentina',
    destinationCountry: 'Brasil',
    goal: 'find_job_br',
    timeline: 'in_0_3m',
    steps: [],
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

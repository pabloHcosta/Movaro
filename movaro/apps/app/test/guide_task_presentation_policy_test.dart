import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/models/guide_task_presentation_policy.dart';

void main() {
  test('opens exactly one working section for a content-rich task', () {
    final item = GuideActionItem(
      id: 'rich',
      title: 'Rich',
      shortDescription: 'Rich task',
      type: GuideActionType.external,
      phase: GuidePhase.documents,
      orderIndex: 0,
      isCompleted: false,
      primaryActionType: GuidePrimaryActionType.external,
      primaryActionTarget: 'https://example.gov',
      decisionOptions: [
        GuideDecisionOption(title: 'Online', description: 'Use online'),
      ],
      steps: ['Choose', 'Submit'],
      checklistItems: [
        ChecklistSubItem(id: 'one', title: 'Done', isCompleted: false),
      ],
      requirements: ['Document'],
      warningFlags: ['Check the official source'],
      doneCriteria: 'Receipt saved',
      evidence: GuideEvidence(
        type: GuideEvidenceType.official,
        sourceLabel: 'Official',
        sourceUrl: 'https://example.gov',
        lastVerified: DateTime(2026, 7, 29),
      ),
    );

    final policy = GuideTaskPresentationPolicy.fromItem(
      item,
      deferChecklist: true,
    );
    final expanded = GuideTaskSectionKind.values
        .where(policy.startsExpanded)
        .toList();

    expect(policy.density, GuideTaskContentDensity.rich);
    expect(expanded, [GuideTaskSectionKind.route]);
  });

  test('prioritizes the checklist when the task has no route choice', () {
    const item = GuideActionItem(
      id: 'checklist',
      title: 'Checklist',
      shortDescription: 'Do three things',
      type: GuideActionType.checklist,
      phase: GuidePhase.preparation,
      orderIndex: 0,
      isCompleted: false,
      checklistItems: [
        ChecklistSubItem(id: 'one', title: 'One', isCompleted: false),
      ],
      requirements: ['Document'],
    );

    final policy = GuideTaskPresentationPolicy.fromItem(
      item,
      deferChecklist: false,
    );

    expect(policy.startsExpanded(GuideTaskSectionKind.checklist), isTrue);
    expect(
      GuideTaskSectionKind.values.where(policy.startsExpanded),
      hasLength(1),
    );
  });
}

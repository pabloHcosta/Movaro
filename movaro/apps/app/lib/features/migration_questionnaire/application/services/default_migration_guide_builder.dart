import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/document_checklist_adapter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class DefaultMigrationGuideBuilder {
  const DefaultMigrationGuideBuilder._();

  static List<GuideActionItem> build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
    Set<String> completedIds = const <String>{},
  }) {
    final readinessChecklist = MigrationReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final documentChecklist = MigrationDocumentReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );
    final adaptedDocumentItems = DocumentChecklistAdapter.getItems(
      l10n: l10n,
      originCountry: plan.originCountry,
      destinationCountry: plan.destinationCountry,
      goal: plan.goal,
      travelGroup: plan.travelGroup,
      fallbackChecklist: documentChecklist,
    );
    final arrivalChecklist = ArrivalExecutionBuilder.build(
      l10n: l10n,
      plan: plan,
    );

    var orderIndex = 0;
    final items = <GuideActionItem>[];

    for (final item in readinessChecklist.items) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: item.description,
          type: switch (item.id) {
            'landing_budget' => GuideActionType.tool,
            'housing' => GuideActionType.tool,
            _ => GuideActionType.informative,
          },
          toolType: switch (item.id) {
            'landing_budget' => GuideToolType.budget,
            'housing' => GuideToolType.housing,
            _ => null,
          },
          phase: switch (item.id) {
            'housing' => GuidePhase.housing,
            'goal_layer' || 'cpf_bank' => GuidePhase.work,
            'arrival_plan' => GuidePhase.arrival,
            _ => GuidePhase.preparation,
          },
          orderIndex: orderIndex++,
          isCompleted: completedIds.contains(item.id),
          icon: item.icon,
        ),
      );
    }

    for (final item in adaptedDocumentItems) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: [
            item.description,
            if (item.tip != null) item.tip!,
            item.timeEstimate,
          ].join('\n\n'),
          type: item.link != null
              ? GuideActionType.external
              : GuideActionType.informative,
          externalUrl: item.link,
          phase: GuidePhase.documents,
          orderIndex: orderIndex++,
          isCompleted: completedIds.contains(item.id),
        ),
      );
    }

    for (final item in arrivalChecklist.items) {
      items.add(
        GuideActionItem(
          id: item.id,
          title: item.title,
          shortDescription: item.description,
          fullContent: item.description,
          type: GuideActionType.informative,
          phase: GuidePhase.arrival,
          orderIndex: orderIndex++,
          isCompleted: completedIds.contains(item.id),
          icon: item.icon,
        ),
      );
    }

    return items;
  }
}

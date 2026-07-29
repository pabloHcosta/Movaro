import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';

enum GuideTaskContentDensity { light, balanced, rich }

enum GuideTaskSectionKind {
  checklist,
  preparation,
  route,
  instructions,
  confirmation,
  details,
  completionCriteria,
}

/// Deterministic progressive-disclosure policy shared by every guide task.
///
/// The catalog can remain comprehensive without turning the initial task view
/// into a wall of content. Exactly one working section may start expanded;
/// secondary and reference material remains available on demand.
class GuideTaskPresentationPolicy {
  const GuideTaskPresentationPolicy({
    required this.density,
    required this.primarySection,
    required this.informationBlockCount,
  });

  factory GuideTaskPresentationPolicy.fromItem(
    GuideActionItem item, {
    required bool deferChecklist,
  }) {
    var blockCount = 0;
    if (item.urgencySignal != null || item.preArrivalRequired) blockCount++;
    if (item.resolvedPrimaryActionType != GuidePrimaryActionType.none) {
      blockCount++;
    }
    if (item.hasChecklist) blockCount++;
    if (item.hasRequirements || item.hasSurvivalPhrases) blockCount++;
    if (item.hasDecisionOptions) blockCount++;
    if (item.hasSteps || item.hasLocationAwareOptions) blockCount++;
    if (item.costInfo != null ||
        item.estimatedTime != null ||
        item.evidence != null ||
        item.hasTips ||
        item.hasSupportLinks ||
        item.hasCommunityTips) {
      blockCount++;
    }
    if (item.hasWarningFlags) blockCount++;
    if (item.doneCriteria != null) blockCount++;

    final primarySection = item.hasDecisionOptions
        ? GuideTaskSectionKind.route
        : item.hasChecklist && !deferChecklist
        ? GuideTaskSectionKind.checklist
        : item.hasSteps || item.hasLocationAwareOptions
        ? GuideTaskSectionKind.instructions
        : item.hasChecklist
        ? GuideTaskSectionKind.confirmation
        : item.hasRequirements || item.hasSurvivalPhrases
        ? GuideTaskSectionKind.preparation
        : null;

    return GuideTaskPresentationPolicy(
      density: blockCount >= 7
          ? GuideTaskContentDensity.rich
          : blockCount >= 4
          ? GuideTaskContentDensity.balanced
          : GuideTaskContentDensity.light,
      primarySection: primarySection,
      informationBlockCount: blockCount,
    );
  }

  final GuideTaskContentDensity density;
  final GuideTaskSectionKind? primarySection;
  final int informationBlockCount;

  bool startsExpanded(GuideTaskSectionKind section) =>
      primarySection == section;
}

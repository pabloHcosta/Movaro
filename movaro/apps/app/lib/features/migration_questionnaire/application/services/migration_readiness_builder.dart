import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum MigrationReadinessStage { now, soon, landing }

class MigrationReadinessItem {
  const MigrationReadinessItem({
    required this.id,
    required this.stage,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final MigrationReadinessStage stage;
  final IconData icon;
  final String title;
  final String description;
}

class MigrationReadinessChecklist {
  const MigrationReadinessChecklist({
    required this.summary,
    required this.items,
  });

  final String summary;
  final List<MigrationReadinessItem> items;

  List<MigrationReadinessItem> itemsFor(MigrationReadinessStage stage) =>
      items.where((item) => item.stage == stage).toList(growable: false);
}

class MigrationReadinessBuilder {
  const MigrationReadinessBuilder._();

  static MigrationReadinessChecklist build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
  }) {
    final cityName = plan.recommendedCity?.name;

    return MigrationReadinessChecklist(
      summary: _summaryForTimeline(l10n, plan.timeline),
      items: [
        MigrationReadinessItem(
          id: 'migration_path',
          stage: MigrationReadinessStage.now,
          icon: Icons.badge_outlined,
          title: l10n.readinessItemMigrationPathTitle,
          description: l10n.readinessItemMigrationPathBody,
        ),
        MigrationReadinessItem(
          id: 'documents_pack',
          stage: MigrationReadinessStage.now,
          icon: Icons.folder_open_outlined,
          title: l10n.readinessItemDocumentsTitle,
          description: l10n.readinessItemDocumentsBody,
        ),
        MigrationReadinessItem(
          id: 'landing_budget',
          stage: MigrationReadinessStage.now,
          icon: Icons.savings_outlined,
          title: l10n.readinessItemBudgetTitle,
          description: l10n.readinessItemBudgetBody,
        ),
        MigrationReadinessItem(
          id: 'city_filter',
          stage: MigrationReadinessStage.soon,
          icon: Icons.location_city_outlined,
          title: l10n.readinessItemCityTitle,
          description: cityName == null
              ? l10n.readinessItemCityBody
              : l10n.readinessItemCityBodyWithCity(cityName),
        ),
        MigrationReadinessItem(
          id: 'language_layer',
          stage: MigrationReadinessStage.soon,
          icon: Icons.translate_rounded,
          title: l10n.readinessItemLanguageTitle,
          description: _languageBodyForGoal(l10n, plan.goal),
        ),
        MigrationReadinessItem(
          id: 'goal_layer',
          stage: MigrationReadinessStage.soon,
          icon: _goalIcon(plan.goal),
          title: _goalTitle(l10n, plan.goal),
          description: _goalBody(l10n, plan.goal),
        ),
        MigrationReadinessItem(
          id: 'cpf_bank',
          stage: MigrationReadinessStage.landing,
          icon: Icons.account_balance_outlined,
          title: l10n.readinessItemCpfBankTitle,
          description: l10n.readinessItemCpfBankBody,
        ),
        MigrationReadinessItem(
          id: 'housing',
          stage: MigrationReadinessStage.landing,
          icon: Icons.house_outlined,
          title: l10n.readinessItemHousingTitle,
          description: l10n.readinessItemHousingBody,
        ),
        MigrationReadinessItem(
          id: 'arrival_plan',
          stage: MigrationReadinessStage.landing,
          icon: Icons.health_and_safety_outlined,
          title: l10n.readinessItemArrivalTitle,
          description: l10n.readinessItemArrivalBody,
        ),
      ],
    );
  }

  static String _summaryForTimeline(AppLocalizations l10n, String timeline) {
    switch (timeline) {
      case 'asap':
        return l10n.readinessSummaryAsap;
      case '6_months':
        return l10n.readinessSummarySixMonths;
      case '12_months':
        return l10n.readinessSummaryTwelveMonths;
      case 'researching':
      default:
        return l10n.readinessSummaryResearching;
    }
  }

  static IconData _goalIcon(String goal) {
    switch (goal) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'remote_work':
        return Icons.laptop_mac_outlined;
      case 'study':
        return Icons.school_outlined;
      case 'entrepreneur':
        return Icons.storefront_outlined;
      case 'retire':
        return Icons.deck_outlined;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return Icons.favorite_border_rounded;
    }
  }

  static String _goalTitle(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.readinessGoalWorkTitle;
      case 'remote_work':
        return l10n.readinessGoalRemoteTitle;
      case 'study':
        return l10n.readinessGoalStudyTitle;
      case 'entrepreneur':
        return l10n.readinessGoalEntrepreneurTitle;
      case 'retire':
        return l10n.readinessGoalRetireTitle;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.readinessGoalQualityTitle;
    }
  }

  static String _goalBody(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.readinessGoalWorkBody;
      case 'remote_work':
        return l10n.readinessGoalRemoteBody;
      case 'study':
        return l10n.readinessGoalStudyBody;
      case 'entrepreneur':
        return l10n.readinessGoalEntrepreneurBody;
      case 'retire':
        return l10n.readinessGoalRetireBody;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.readinessGoalQualityBody;
    }
  }

  static String _languageBodyForGoal(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
      case 'entrepreneur':
        return l10n.readinessItemLanguageWorkBody;
      case 'study':
        return l10n.readinessItemLanguageStudyBody;
      default:
        return l10n.readinessItemLanguageBody;
    }
  }
}

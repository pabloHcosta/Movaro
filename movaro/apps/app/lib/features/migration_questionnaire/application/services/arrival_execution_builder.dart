import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum ArrivalExecutionStage { firstWeek, firstMonth, firstQuarter }

class ArrivalExecutionItem {
  const ArrivalExecutionItem({
    required this.id,
    required this.stage,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final ArrivalExecutionStage stage;
  final IconData icon;
  final String title;
  final String description;
}

class ArrivalExecutionChecklist {
  const ArrivalExecutionChecklist({required this.summary, required this.items});

  final String summary;
  final List<ArrivalExecutionItem> items;

  List<ArrivalExecutionItem> itemsFor(ArrivalExecutionStage stage) =>
      items.where((item) => item.stage == stage).toList(growable: false);
}

class ArrivalExecutionBuilder {
  const ArrivalExecutionBuilder._();

  static ArrivalExecutionChecklist build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
  }) {
    final cityName = plan.currentPlanCity?.name;

    return ArrivalExecutionChecklist(
      summary: _summaryForTimeline(l10n, plan.timeline),
      items: [
        ArrivalExecutionItem(
          id: 'arrival_connectivity',
          stage: ArrivalExecutionStage.firstWeek,
          icon: Icons.sim_card_outlined,
          title: l10n.arrivalExecutionConnectivityTitle,
          description: l10n.arrivalExecutionConnectivityBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_transport',
          stage: ArrivalExecutionStage.firstWeek,
          icon: Icons.directions_bus_outlined,
          title: l10n.arrivalExecutionTransportTitle,
          description: cityName == null
              ? l10n.arrivalExecutionTransportBody
              : l10n.arrivalExecutionTransportBodyWithCity(cityName),
        ),
        ArrivalExecutionItem(
          id: 'arrival_health',
          stage: ArrivalExecutionStage.firstWeek,
          icon: Icons.local_hospital_outlined,
          title: l10n.arrivalExecutionHealthTitle,
          description: l10n.arrivalExecutionHealthBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_bank_payments',
          stage: ArrivalExecutionStage.firstMonth,
          icon: Icons.account_balance_wallet_outlined,
          title: l10n.arrivalExecutionBankTitle,
          description: l10n.arrivalExecutionBankBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_housing_routine',
          stage: ArrivalExecutionStage.firstMonth,
          icon: Icons.home_work_outlined,
          title: l10n.arrivalExecutionHousingTitle,
          description: l10n.arrivalExecutionHousingBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_goal_track',
          stage: ArrivalExecutionStage.firstMonth,
          icon: _goalIcon(plan.goal),
          title: _goalTitle(l10n, plan.goal),
          description: _goalBody(l10n, plan.goal),
        ),
        ArrivalExecutionItem(
          id: 'arrival_reality_check',
          stage: ArrivalExecutionStage.firstQuarter,
          icon: Icons.analytics_outlined,
          title: l10n.arrivalExecutionRealityCheckTitle,
          description: l10n.arrivalExecutionRealityCheckBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_documents_follow_up',
          stage: ArrivalExecutionStage.firstQuarter,
          icon: Icons.folder_copy_outlined,
          title: l10n.arrivalExecutionDocumentsTitle,
          description: l10n.arrivalExecutionDocumentsBody,
        ),
        ArrivalExecutionItem(
          id: 'arrival_replan',
          stage: ArrivalExecutionStage.firstQuarter,
          icon: Icons.alt_route_outlined,
          title: l10n.arrivalExecutionReplanTitle,
          description: cityName == null
              ? l10n.arrivalExecutionReplanBody
              : l10n.arrivalExecutionReplanBodyWithCity(cityName),
        ),
      ],
    );
  }

  static String _summaryForTimeline(AppLocalizations l10n, String timeline) {
    switch (timeline) {
      case 'asap':
        return l10n.arrivalExecutionSummaryAsap;
      case '6_months':
        return l10n.arrivalExecutionSummarySixMonths;
      case '12_months':
        return l10n.arrivalExecutionSummaryTwelveMonths;
      case 'researching':
      default:
        return l10n.arrivalExecutionSummaryResearching;
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
        return l10n.arrivalExecutionGoalWorkTitle;
      case 'remote_work':
        return l10n.arrivalExecutionGoalRemoteTitle;
      case 'study':
        return l10n.arrivalExecutionGoalStudyTitle;
      case 'entrepreneur':
        return l10n.arrivalExecutionGoalEntrepreneurTitle;
      case 'retire':
        return l10n.arrivalExecutionGoalRetireTitle;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.arrivalExecutionGoalQualityTitle;
    }
  }

  static String _goalBody(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.arrivalExecutionGoalWorkBody;
      case 'remote_work':
        return l10n.arrivalExecutionGoalRemoteBody;
      case 'study':
        return l10n.arrivalExecutionGoalStudyBody;
      case 'entrepreneur':
        return l10n.arrivalExecutionGoalEntrepreneurBody;
      case 'retire':
        return l10n.arrivalExecutionGoalRetireBody;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.arrivalExecutionGoalQualityBody;
    }
  }
}

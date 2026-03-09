import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

enum MigrationDocumentReadinessPriority { critical, prepare, arrival }
enum MigrationDocumentReadinessRisk { blocking, caution, review }
enum MigrationDocumentReadinessReviewMoment {
  beforeBooking,
  closeToMove,
  onArrival,
}

class MigrationDocumentReadinessItem {
  const MigrationDocumentReadinessItem({
    required this.id,
    required this.priority,
    required this.risk,
    required this.reviewMoment,
    required this.sourceLabel,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final MigrationDocumentReadinessPriority priority;
  final MigrationDocumentReadinessRisk risk;
  final MigrationDocumentReadinessReviewMoment reviewMoment;
  final String sourceLabel;
  final IconData icon;
  final String title;
  final String description;
}

class MigrationDocumentReadinessChecklist {
  const MigrationDocumentReadinessChecklist({
    required this.summary,
    required this.items,
  });

  final String summary;
  final List<MigrationDocumentReadinessItem> items;

  List<MigrationDocumentReadinessItem> itemsFor(
    MigrationDocumentReadinessPriority priority,
  ) => items.where((item) => item.priority == priority).toList(growable: false);
}

class MigrationDocumentReadinessBuilder {
  const MigrationDocumentReadinessBuilder._();

  static MigrationDocumentReadinessChecklist build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
  }) {
    if (_isBrazilJourney(plan.destinationCountry)) {
      return _buildBrazilChecklist(l10n: l10n, plan: plan);
    }

    return _buildGenericChecklist(l10n: l10n, plan: plan);
  }

  static MigrationDocumentReadinessChecklist _buildBrazilChecklist({
    required AppLocalizations l10n,
    required MigrationPlan plan,
  }) {
    return MigrationDocumentReadinessChecklist(
      summary: _summaryForTimeline(l10n, plan.timeline),
      items: [
        MigrationDocumentReadinessItem(
          id: 'route_brazil',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMrePoliciaFederal,
          icon: Icons.account_box_outlined,
          title: l10n.documentReadinessRouteTitle,
          description: l10n.documentReadinessRouteBodyBrazil,
        ),
        MigrationDocumentReadinessItem(
          id: 'identity_pack',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.perm_identity_outlined,
          title: l10n.documentReadinessIdentityPackTitle,
          description: l10n.documentReadinessIdentityPackBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'apostille_brazil',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMrePoliciaFederal,
          icon: Icons.gavel_outlined,
          title: l10n.documentReadinessApostilleTitle,
          description: l10n.documentReadinessApostilleBodyBrazil,
        ),
        MigrationDocumentReadinessItem(
          id: 'translation_brazil',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: l10n.sourceProviderPoliciaFederalGovBr,
          icon: Icons.translate_outlined,
          title: l10n.documentReadinessTranslationTitle,
          description: l10n.documentReadinessTranslationBodyBrazil,
        ),
        MigrationDocumentReadinessItem(
          id: 'housing_proof_brazil',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: l10n.sourceProviderBancoCentralBrasil,
          icon: Icons.house_siding_outlined,
          title: l10n.documentReadinessHousingProofTitle,
          description: l10n.documentReadinessHousingProofBodyBrazil,
        ),
        MigrationDocumentReadinessItem(
          id: 'goal_document_layer',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: _goalSourceLabel(l10n, plan.goal),
          icon: _goalIcon(plan.goal),
          title: _goalTitle(l10n, plan.goal),
          description: _goalBody(l10n, plan.goal),
        ),
        MigrationDocumentReadinessItem(
          id: 'cpf_layer_brazil',
          priority: MigrationDocumentReadinessPriority.arrival,
          risk: MigrationDocumentReadinessRisk.review,
          reviewMoment: MigrationDocumentReadinessReviewMoment.onArrival,
          sourceLabel: l10n.sourceProviderReceitaFederalGovBr,
          icon: Icons.badge_outlined,
          title: l10n.documentReadinessCpfTitle,
          description: l10n.documentReadinessCpfBodyBrazil,
        ),
        MigrationDocumentReadinessItem(
          id: 'copies_backup',
          priority: MigrationDocumentReadinessPriority.arrival,
          risk: MigrationDocumentReadinessRisk.review,
          reviewMoment: MigrationDocumentReadinessReviewMoment.onArrival,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.cloud_done_outlined,
          title: l10n.documentReadinessCopiesTitle,
          description: l10n.documentReadinessCopiesBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'arrival_folder_brazil',
          priority: MigrationDocumentReadinessPriority.arrival,
          risk: MigrationDocumentReadinessRisk.review,
          reviewMoment: MigrationDocumentReadinessReviewMoment.onArrival,
          sourceLabel: l10n.sourceProviderPoliciaFederalGovBr,
          icon: Icons.folder_shared_outlined,
          title: l10n.documentReadinessArrivalFolderTitle,
          description: l10n.documentReadinessArrivalFolderBodyBrazil,
        ),
      ],
    );
  }

  static MigrationDocumentReadinessChecklist _buildGenericChecklist({
    required AppLocalizations l10n,
    required MigrationPlan plan,
  }) {
    return MigrationDocumentReadinessChecklist(
      summary: _summaryForTimeline(l10n, plan.timeline),
      items: [
        MigrationDocumentReadinessItem(
          id: 'route_generic',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.account_box_outlined,
          title: l10n.documentReadinessRouteTitle,
          description: l10n.documentReadinessRouteBodyGeneric,
        ),
        MigrationDocumentReadinessItem(
          id: 'identity_pack',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.perm_identity_outlined,
          title: l10n.documentReadinessIdentityPackTitle,
          description: l10n.documentReadinessIdentityPackBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'rule_check_generic',
          priority: MigrationDocumentReadinessPriority.critical,
          risk: MigrationDocumentReadinessRisk.blocking,
          reviewMoment: MigrationDocumentReadinessReviewMoment.beforeBooking,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.rule_folder_outlined,
          title: l10n.documentReadinessRuleCheckTitle,
          description: l10n.documentReadinessRuleCheckBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'translation_generic',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.translate_outlined,
          title: l10n.documentReadinessTranslationTitle,
          description: l10n.documentReadinessTranslationBodyGeneric,
        ),
        MigrationDocumentReadinessItem(
          id: 'proof_pack_generic',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.wallet_outlined,
          title: l10n.documentReadinessProofPackTitle,
          description: l10n.documentReadinessProofPackBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'goal_document_layer',
          priority: MigrationDocumentReadinessPriority.prepare,
          risk: MigrationDocumentReadinessRisk.caution,
          reviewMoment: MigrationDocumentReadinessReviewMoment.closeToMove,
          sourceLabel: _goalSourceLabel(l10n, plan.goal),
          icon: _goalIcon(plan.goal),
          title: _goalTitle(l10n, plan.goal),
          description: _goalBodyGeneric(l10n, plan.goal),
        ),
        MigrationDocumentReadinessItem(
          id: 'copies_backup',
          priority: MigrationDocumentReadinessPriority.arrival,
          risk: MigrationDocumentReadinessRisk.review,
          reviewMoment: MigrationDocumentReadinessReviewMoment.onArrival,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.cloud_done_outlined,
          title: l10n.documentReadinessCopiesTitle,
          description: l10n.documentReadinessCopiesBody,
        ),
        MigrationDocumentReadinessItem(
          id: 'arrival_folder_generic',
          priority: MigrationDocumentReadinessPriority.arrival,
          risk: MigrationDocumentReadinessRisk.review,
          reviewMoment: MigrationDocumentReadinessReviewMoment.onArrival,
          sourceLabel: l10n.sourceProviderMovaro,
          icon: Icons.inventory_2_outlined,
          title: l10n.documentReadinessArrivalFolderTitle,
          description: l10n.documentReadinessArrivalFolderBodyGeneric,
        ),
      ],
    );
  }

  static bool _isBrazilJourney(String destinationCountry) {
    return destinationCountry.toUpperCase() == 'BR';
  }

  static String _summaryForTimeline(AppLocalizations l10n, String timeline) {
    switch (timeline) {
      case 'asap':
        return l10n.documentReadinessSummaryAsap;
      case '6_months':
        return l10n.documentReadinessSummarySixMonths;
      case '12_months':
        return l10n.documentReadinessSummaryTwelveMonths;
      case 'researching':
      default:
        return l10n.documentReadinessSummaryResearching;
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
        return l10n.documentReadinessGoalWorkTitle;
      case 'remote_work':
        return l10n.documentReadinessGoalRemoteTitle;
      case 'study':
        return l10n.documentReadinessGoalStudyTitle;
      case 'entrepreneur':
        return l10n.documentReadinessGoalEntrepreneurTitle;
      case 'retire':
        return l10n.documentReadinessGoalRetireTitle;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.documentReadinessGoalQualityTitle;
    }
  }

  static String _goalBody(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.documentReadinessGoalWorkBodyBrazil;
      case 'remote_work':
        return l10n.documentReadinessGoalRemoteBodyBrazil;
      case 'study':
        return l10n.documentReadinessGoalStudyBodyBrazil;
      case 'entrepreneur':
        return l10n.documentReadinessGoalEntrepreneurBodyBrazil;
      case 'retire':
        return l10n.documentReadinessGoalRetireBodyBrazil;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.documentReadinessGoalQualityBodyBrazil;
    }
  }

  static String _goalBodyGeneric(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.documentReadinessGoalWorkBodyGeneric;
      case 'remote_work':
        return l10n.documentReadinessGoalRemoteBodyGeneric;
      case 'study':
        return l10n.documentReadinessGoalStudyBodyGeneric;
      case 'entrepreneur':
        return l10n.documentReadinessGoalEntrepreneurBodyGeneric;
      case 'retire':
        return l10n.documentReadinessGoalRetireBodyGeneric;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.documentReadinessGoalQualityBodyGeneric;
    }
  }

  static String _goalSourceLabel(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'work':
        return l10n.sourceProviderMteCtps;
      case 'remote_work':
        return l10n.sourceProviderBancoCentralBrasil;
      case 'study':
        return l10n.sourceProviderMinisterioJustica;
      case 'entrepreneur':
        return l10n.sourceProviderPortalEmpreendedorInss;
      case 'retire':
        return l10n.sourceProviderMinisterioPrevidenciaInss;
      case 'quality_of_life':
      case 'beach_life':
      default:
        return l10n.sourceProviderMovaro;
    }
  }
}

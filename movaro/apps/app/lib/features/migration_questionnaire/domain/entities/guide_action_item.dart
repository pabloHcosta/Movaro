import 'package:flutter/material.dart';

enum GuideActionType { informative, external, tool, checklist }

enum GuideToolType { budget, housing, flight }

enum GuidePhase { preparation, housing, documents, work, arrival }

enum GuidePrimaryActionType { none, external, tool, checklist }

enum GuideEstimatedEffort { fast, medium, longer }

enum GuideExecutionMode { online, inPerson }

/// Urgency level for guide items — drives visual indicators.
enum GuideUrgencyLevel {
  /// Normal flow — no urgency.
  normal,

  /// Attention recommended — doing this late adds friction.
  watch,

  /// Time-sensitive — delays cause real problems.
  urgent,

  /// Must act now — missing this causes migration failure.
  critical,
}

/// A key phrase to say in Portuguese, with a localized translation/context.
/// Used for the "Como falar isso em português" survival language layer.
class SurvivalPhrase {
  const SurvivalPhrase({required this.phrase, this.translation});

  /// The actual Portuguese phrase to say (always in PT).
  final String phrase;

  /// Localized explanation or context for when/why to use it.
  final String? translation;
}

class GuideDecisionOption {
  const GuideDecisionOption({
    required this.title,
    required this.description,
    this.pros = const <String>[],
    this.cons = const <String>[],
    this.recommended = false,
  });

  final String title;
  final String description;
  final List<String> pros;
  final List<String> cons;
  final bool recommended;
}

class GuideSupportLink {
  const GuideSupportLink({required this.label, required this.url});

  final String label;
  final String url;
}

class GuideLocationAwareOption {
  const GuideLocationAwareOption({
    required this.title,
    this.subtitle,
    this.address,
    this.distanceKm,
    this.mapUrl,
    this.officialUrl,
    this.officialLabel,
  });

  final String title;
  final String? subtitle;
  final String? address;
  final int? distanceKm;
  final String? mapUrl;
  final String? officialUrl;
  final String? officialLabel;
}

class ChecklistSubItem {
  const ChecklistSubItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  ChecklistSubItem copyWith({String? id, String? title, bool? isCompleted}) {
    return ChecklistSubItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class GuideActionItem {
  const GuideActionItem({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.type,
    required this.phase,
    required this.orderIndex,
    required this.isCompleted,
    this.fullContent,
    this.externalUrl,
    this.externalLabel,
    this.toolType,
    this.checklistItems,
    this.icon,
    this.dependencies = const <String>[],
    this.badgeLabel,
    this.context,
    this.whyItMatters,
    this.primaryActionLabel,
    this.primaryActionType,
    this.primaryActionTarget,
    this.steps,
    this.doneCriteria,
    this.tips,
    this.blockingReason,
    this.decisionOptions,
    this.supportLinks,
    this.estimatedEffort,
    this.estimatedTimeLabel,
    this.locationAwareOptions,
    this.costInfo,
    this.requirements,
    this.estimatedTime,
    this.executionModes,
    this.mapLinks,
    this.externalOfficialLinks,
    this.urgencyLevel,
    this.urgencySignal,
    this.preArrivalRequired = false,
    this.warningFlags,
    this.survivalPhrases,
    this.communityTips,
  });

  final String id;
  final String title;
  final String shortDescription;
  @Deprecated('Use steps, decisionOptions, and structured fields instead')
  final String? fullContent;
  final GuideActionType type;
  final String? externalUrl;
  final String? externalLabel;
  final GuideToolType? toolType;
  final List<ChecklistSubItem>? checklistItems;
  final GuidePhase phase;
  final int orderIndex;
  final bool isCompleted;
  final IconData? icon;
  final List<String> dependencies;
  final String? badgeLabel;
  final String? context;
  final String? whyItMatters;
  final String? primaryActionLabel;
  final GuidePrimaryActionType? primaryActionType;
  final String? primaryActionTarget;
  final List<String>? steps;
  final String? doneCriteria;
  final List<String>? tips;
  final String? blockingReason;
  final List<GuideDecisionOption>? decisionOptions;
  final List<GuideSupportLink>? supportLinks;
  final GuideEstimatedEffort? estimatedEffort;
  final String? estimatedTimeLabel;
  final List<GuideLocationAwareOption>? locationAwareOptions;
  final String? costInfo;
  final List<String>? requirements;
  final String? estimatedTime;
  final List<GuideExecutionMode>? executionModes;
  final List<GuideSupportLink>? mapLinks;
  final List<GuideSupportLink>? externalOfficialLinks;

  /// Urgency level drives visual indicators (badge color, warning banner).
  final GuideUrgencyLevel? urgencyLevel;

  /// One-line urgency message shown prominently in the execution sheet.
  /// Example: "Book the PF appointment before arriving — 60-day backlog expected."
  final String? urgencySignal;

  /// True when this step must be completed before arriving in Brazil.
  /// Drives the "Pre-arrival" section in the copilot and home warnings.
  final bool preArrivalRequired;

  /// Red-flag warnings (scam protection, real-world failure modes).
  /// Displayed as a distinct warning section in the execution sheet.
  final List<String>? warningFlags;

  /// Key Portuguese phrases to use in real interactions (rental office, bank,
  /// hospital). Drives the "Como falar isso em português" survival layer.
  final List<SurvivalPhrase>? survivalPhrases;

  /// Curated first-person tips from real migration cases.
  /// Drives the "Dica de quem já fez isso" community layer.
  final List<String>? communityTips;

  bool get hasWarningFlags =>
      warningFlags != null && warningFlags!.isNotEmpty;
  bool get hasSurvivalPhrases =>
      survivalPhrases != null && survivalPhrases!.isNotEmpty;
  bool get hasCommunityTips =>
      communityTips != null && communityTips!.isNotEmpty;

  bool get hasChecklist => checklistItems != null && checklistItems!.isNotEmpty;
  bool get hasSteps => steps != null && steps!.isNotEmpty;
  bool get hasTips => tips != null && tips!.isNotEmpty;
  bool get hasDecisionOptions =>
      decisionOptions != null && decisionOptions!.isNotEmpty;
  bool get hasSupportLinks => supportLinks != null && supportLinks!.isNotEmpty;
  bool get hasLocationAwareOptions =>
      locationAwareOptions != null && locationAwareOptions!.isNotEmpty;
  bool get hasRequirements => requirements != null && requirements!.isNotEmpty;
  bool get hasMapLinks => mapLinks != null && mapLinks!.isNotEmpty;
  bool get hasExternalOfficialLinks =>
      externalOfficialLinks != null && externalOfficialLinks!.isNotEmpty;

  String get summaryText => context ?? shortDescription;

  GuidePrimaryActionType get resolvedPrimaryActionType {
    if (primaryActionType != null) {
      return primaryActionType!;
    }
    if (hasChecklist) {
      return GuidePrimaryActionType.checklist;
    }
    return switch (type) {
      GuideActionType.external => GuidePrimaryActionType.external,
      GuideActionType.tool => GuidePrimaryActionType.tool,
      GuideActionType.checklist => GuidePrimaryActionType.checklist,
      GuideActionType.informative => GuidePrimaryActionType.none,
    };
  }

  String? get resolvedPrimaryActionTarget => primaryActionTarget ?? externalUrl;

  bool get hasExecutionContent =>
      whyItMatters != null ||
      hasSteps ||
      doneCriteria != null ||
      hasTips ||
      blockingReason != null ||
      hasDecisionOptions ||
      hasSupportLinks;

  GuideActionItem copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? fullContent,
    GuideActionType? type,
    String? externalUrl,
    String? externalLabel,
    GuideToolType? toolType,
    List<ChecklistSubItem>? checklistItems,
    GuidePhase? phase,
    int? orderIndex,
    bool? isCompleted,
    IconData? icon,
    List<String>? dependencies,
    String? badgeLabel,
    String? context,
    String? whyItMatters,
    String? primaryActionLabel,
    GuidePrimaryActionType? primaryActionType,
    String? primaryActionTarget,
    List<String>? steps,
    String? doneCriteria,
    List<String>? tips,
    String? blockingReason,
    List<GuideDecisionOption>? decisionOptions,
    List<GuideSupportLink>? supportLinks,
    GuideEstimatedEffort? estimatedEffort,
    String? estimatedTimeLabel,
    List<GuideLocationAwareOption>? locationAwareOptions,
    String? costInfo,
    List<String>? requirements,
    String? estimatedTime,
    List<GuideExecutionMode>? executionModes,
    List<GuideSupportLink>? mapLinks,
    List<GuideSupportLink>? externalOfficialLinks,
    GuideUrgencyLevel? urgencyLevel,
    String? urgencySignal,
    bool? preArrivalRequired,
    List<String>? warningFlags,
    List<SurvivalPhrase>? survivalPhrases,
    List<String>? communityTips,
  }) {
    return GuideActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      fullContent: fullContent ?? this.fullContent,
      type: type ?? this.type,
      externalUrl: externalUrl ?? this.externalUrl,
      externalLabel: externalLabel ?? this.externalLabel,
      toolType: toolType ?? this.toolType,
      checklistItems: checklistItems ?? this.checklistItems,
      phase: phase ?? this.phase,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
      dependencies: dependencies ?? this.dependencies,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      context: context ?? this.context,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      primaryActionLabel: primaryActionLabel ?? this.primaryActionLabel,
      primaryActionType: primaryActionType ?? this.primaryActionType,
      primaryActionTarget: primaryActionTarget ?? this.primaryActionTarget,
      steps: steps ?? this.steps,
      doneCriteria: doneCriteria ?? this.doneCriteria,
      tips: tips ?? this.tips,
      blockingReason: blockingReason ?? this.blockingReason,
      decisionOptions: decisionOptions ?? this.decisionOptions,
      supportLinks: supportLinks ?? this.supportLinks,
      estimatedEffort: estimatedEffort ?? this.estimatedEffort,
      estimatedTimeLabel: estimatedTimeLabel ?? this.estimatedTimeLabel,
      locationAwareOptions: locationAwareOptions ?? this.locationAwareOptions,
      costInfo: costInfo ?? this.costInfo,
      requirements: requirements ?? this.requirements,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      executionModes: executionModes ?? this.executionModes,
      mapLinks: mapLinks ?? this.mapLinks,
      externalOfficialLinks:
          externalOfficialLinks ?? this.externalOfficialLinks,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      urgencySignal: urgencySignal ?? this.urgencySignal,
      preArrivalRequired: preArrivalRequired ?? this.preArrivalRequired,
      warningFlags: warningFlags ?? this.warningFlags,
      survivalPhrases: survivalPhrases ?? this.survivalPhrases,
      communityTips: communityTips ?? this.communityTips,
    );
  }
}

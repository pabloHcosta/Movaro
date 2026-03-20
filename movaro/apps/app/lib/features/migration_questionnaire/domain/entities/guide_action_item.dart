import 'package:flutter/material.dart';

enum GuideActionType { informative, external, tool, checklist }

enum GuideToolType { budget, housing, flight }

enum GuidePhase { preparation, housing, documents, work, arrival }

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
  });

  final String id;
  final String title;
  final String shortDescription;
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

  bool get hasChecklist => checklistItems != null && checklistItems!.isNotEmpty;

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
    );
  }
}

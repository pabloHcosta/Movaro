import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/persistence/feature_guide_preferences_store.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/help_bottom_sheet.dart';

class ContextualHelpContent {
  const ContextualHelpContent({
    required this.eyebrow,
    required this.contextIcon,
    required this.title,
    required this.body,
    required this.steps,
  });

  final String eyebrow;
  final IconData contextIcon;
  final String title;
  final String body;
  final List<FeatureGuideStep> steps;
}

Future<void> maybeShowContextualHelpGuide(
  BuildContext context, {
  required String preferenceKey,
  required ContextualHelpContent content,
  FeatureGuidePreferencesStore? store,
}) async {
  final guideStore = store ?? FeatureGuidePreferencesStore();
  final shouldShow = await guideStore.shouldShowGuide(preferenceKey);
  if (!context.mounted || !shouldShow) {
    return;
  }

  await guideStore.markIntroSeen(preferenceKey);
  if (!context.mounted) {
    return;
  }

  await showContextualHelpGuide(
    context,
    preferenceKey: preferenceKey,
    content: content,
    store: guideStore,
  );
}

Future<void> showContextualHelpGuide(
  BuildContext context, {
  required String preferenceKey,
  required ContextualHelpContent content,
  FeatureGuidePreferencesStore? store,
}) async {
  final l10n = context.l10n;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) => HelpBottomSheet(
      contextLabel: content.eyebrow,
      contextIcon: content.contextIcon,
      title: content.title,
      description: content.body,
      steps: content.steps
          .map((step) => HelpStep(title: step.title, body: step.body))
          .toList(growable: false),
      preferenceKey: preferenceKey,
      hideAgainLabel: l10n.helpHideAgainLabel(),
      confirmLabel: l10n.documentationGuidePrimaryAction,
    ),
  );
}

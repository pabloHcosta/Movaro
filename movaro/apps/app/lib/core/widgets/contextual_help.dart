import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/persistence/feature_guide_preferences_store.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';

class ContextualHelpContent {
  const ContextualHelpContent({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.steps,
  });

  final String eyebrow;
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
  final guideStore = store ?? FeatureGuidePreferencesStore();

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => FeatureGuideDialog(
      eyebrow: content.eyebrow,
      title: content.title,
      body: content.body,
      stepsLabel: l10n.documentationGuideStepsLabel,
      steps: content.steps,
      hideNextTimeLabel: l10n.documentationGuideHideNextTime,
      dismissLabel: l10n.documentationGuideDismissAction,
      primaryLabel: l10n.documentationGuidePrimaryAction,
      onClose: (hideNextTime) async {
        await guideStore.setHideGuide(preferenceKey, hideNextTime);
      },
    ),
  );
}

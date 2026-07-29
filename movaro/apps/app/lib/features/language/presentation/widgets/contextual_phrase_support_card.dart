import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/language/application/portuguese_phrasebook.dart';

/// Small, passive language support placed inside the task where it is useful.
///
/// It is intentionally not a course and does not create progress or compete
/// with the migration plan.
class ContextualPhraseSupportCard extends StatelessWidget {
  const ContextualPhraseSupportCard({
    required this.groupKey,
    this.maxPhrases = 3,
    super.key,
  });

  final String groupKey;
  final int maxPhrases;

  @override
  Widget build(BuildContext context) {
    final group = PortuguesePhrasebook.groups
        .where((candidate) => candidate.key == groupKey)
        .firstOrNull;
    if (group == null) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context).languageCode;
    final title = switch (locale) {
      'pt' => 'Português para este momento',
      'es' => 'Portugués para este momento',
      _ => 'Portuguese for this moment',
    };
    final body = switch (locale) {
      'pt' => 'Frases prontas para usar — apoio contextual, não um curso.',
      'es' => 'Frases listas para usar: apoyo contextual, no un curso.',
      _ => 'Ready-to-use phrases — contextual support, not a course.',
    };

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(group.icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${group.title(locale)} · $body',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (final phrase in group.phrases.take(maxPhrases))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${phrase.pt}”',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (locale != 'pt') ...[
                      const SizedBox(height: 5),
                      Text(
                        phrase.translation(locale),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

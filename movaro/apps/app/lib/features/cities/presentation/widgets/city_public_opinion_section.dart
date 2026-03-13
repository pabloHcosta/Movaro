import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/cities/domain/entities/city_public_opinion.dart';

class CityPublicOpinionSection extends StatelessWidget {
  const CityPublicOpinionSection({required this.opinion, super.key});

  final CityPublicOpinion opinion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.cityDetailPublicOpinionTitle,
                  style: theme.textTheme.titleMedium,
                ),
                if (opinion.rating != null)
                  _MetaChip(
                    icon: Icons.star_rounded,
                    label: l10n.cityDetailPublicOpinionRating(
                      opinion.rating!.toStringAsFixed(1),
                    ),
                  ),
                if (opinion.userRatingCount != null)
                  _MetaChip(
                    icon: Icons.groups_rounded,
                    label: l10n.cityDetailPublicOpinionSample(
                      opinion.userRatingCount!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cityDetailPublicOpinionSubtitle(opinion.provider),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              opinion.summary ?? l10n.cityDetailPublicOpinionFallbackSummary,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 860;
                final panelWidth = wide
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: panelWidth,
                      child: _OpinionColumn(
                        icon: Icons.thumb_up_alt_outlined,
                        title: l10n.cityDetailPublicOpinionPositiveTitle,
                        items: opinion.positivePoints,
                        tint: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(
                      width: panelWidth,
                      child: _OpinionColumn(
                        icon: Icons.warning_amber_rounded,
                        title: l10n.cityDetailPublicOpinionCriticalTitle,
                        items: opinion.criticalPoints,
                        tint: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cityDetailPublicOpinionNote(
                _formatCollectedAt(context, opinion.collectedAt),
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCollectedAt(BuildContext context, String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    return DateFormat(
      'dd/MM/yyyy',
      Localizations.localeOf(context).toString(),
    ).format(parsed.toLocal());
  }
}

class _OpinionColumn extends StatelessWidget {
  const _OpinionColumn({
    required this.icon,
    required this.title,
    required this.items,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: tint),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              ],
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 7, color: tint),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

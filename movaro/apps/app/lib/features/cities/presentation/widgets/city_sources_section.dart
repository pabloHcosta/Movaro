import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';

class CitySourcesSection extends StatelessWidget {
  const CitySourcesSection({required this.sources, super.key});

  final CitySources sources;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          l10n.cityDetailSourcesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(l10n.cityDetailSourcesSummary(sources.all.length)),
        children: [
          for (final source in sources.all) ...[
            _SourceItem(
              title: l10n.citySourceTitle(source.id),
              description: l10n.citySourceDescription(source.id),
              provider: l10n.citySourceProvider(source.id),
              isOfficial: source.isOfficial,
              url: source.url,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SourceItem extends StatelessWidget {
  const _SourceItem({
    required this.title,
    required this.description,
    required this.provider,
    required this.isOfficial,
    required this.url,
  });

  final String title;
  final String description;
  final String provider;
  final bool isOfficial;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOfficial
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isOfficial
                      ? l10n.cityDetailSourceOfficialBadge
                      : l10n.cityDetailSourceCuratedBadge,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 8),
          Text(
            '${l10n.cityDetailSourceProviderLabel}: $provider',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (url != null && url!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l10n.cityDetailSourceUrlLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            SelectableText(url!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

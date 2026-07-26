import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';

class CitySourcesSection extends StatelessWidget {
  const CitySourcesSection({required this.sources, super.key});

  final CitySources sources;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          context.l10n.cityDetailSourcesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          context.l10n.cityDetailSourcesSummary(sources.all.length),
        ),
        children: [
          for (final source in sources.all) ...[
            _SourceItem(
              title: source.title,
              description: source.description,
              provider: source.provider,
              sourceType: source.sourceType,
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
    required this.sourceType,
    required this.url,
  });

  final String title;
  final String description;
  final String provider;
  final String sourceType;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeColor) = switch (sourceType) {
      'official' => (
        _copy(context, pt: 'Oficial', es: 'Oficial', en: 'Official'),
        Theme.of(context).colorScheme.primaryContainer,
      ),
      'community' => (
        _copy(context, pt: 'Comunidade', es: 'Comunidad', en: 'Community'),
        Theme.of(context).colorScheme.tertiaryContainer,
      ),
      'derived' => (
        _copy(
          context,
          pt: 'Estimativa derivada',
          es: 'Estimación derivada',
          en: 'Derived estimate',
        ),
        Theme.of(context).colorScheme.secondaryContainer,
      ),
      _ => (
        _copy(context, pt: 'Não oficial', es: 'No oficial', en: 'Not official'),
        Theme.of(context).colorScheme.secondaryContainer,
      ),
    };

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
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.cityDetailSourceProviderLabel}: $provider',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (url != null && url!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.cityDetailSourceUrlLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            SelectableText(url!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  String _copy(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}

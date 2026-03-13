import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_housing_viability_presenter.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_presenter.dart';
import 'package:url_launcher/url_launcher.dart';

enum CityMetricInsightTopic { housing, safety, work, language }

Future<void> showCityMetricInsightSheet(
  BuildContext context, {
  required City city,
  required CityMetricInsightTopic topic,
}) {
  final content = _CityMetricInsightContent.resolve(context, city, topic);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _CityMetricInsightSheet(content: content),
  );
}

class _CityMetricInsightSheet extends StatelessWidget {
  const _CityMetricInsightSheet({required this.content});

  final _CityMetricInsightContent content;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: content.tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(content.icon, color: content.tint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSoftFor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.headline,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: content.tint,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionBlock(
              title: context.l10n.cityMetricInsightMeaningTitle,
              child: Text(
                content.meaning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionBlock(
              title: context.l10n.cityMetricInsightMethodTitle,
              child: Text(
                content.method,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionBlock(
              title: context.l10n.cityMetricInsightFactsTitle,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final fact in content.facts)
                    _FactChip(label: fact.label, value: fact.value),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionBlock(
              title: context.l10n.cityMetricInsightValidateTitle,
              child: Text(
                content.validate,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionBlock(
              title: context.l10n.cityMetricInsightSourcesTitle,
              child: Column(
                children: [
                  for (final source in content.sources) ...[
                    _SourceCard(source: source),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.cityMetricInsightDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final _InsightSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  source.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: source.isOfficial
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  source.badge,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            source.provider,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            source.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          if (source.url != null && source.url!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openSource(context, source.url!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(context.l10n.cityMetricInsightOpenSourceAction),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CityMetricInsightContent {
  const _CityMetricInsightContent({
    required this.label,
    required this.headline,
    required this.icon,
    required this.tint,
    required this.meaning,
    required this.method,
    required this.validate,
    required this.facts,
    required this.sources,
  });

  final String label;
  final String headline;
  final IconData icon;
  final Color tint;
  final String meaning;
  final String method;
  final String validate;
  final List<_InsightFact> facts;
  final List<_InsightSource> sources;

  static _CityMetricInsightContent resolve(
    BuildContext context,
    City city,
    CityMetricInsightTopic topic,
  ) {
    final l10n = context.l10n;

    switch (topic) {
      case CityMetricInsightTopic.housing:
        final housing = CityHousingViabilityPresenter.resolve(
          context,
          rentScore: city.rentScore,
        );
        return _CityMetricInsightContent(
          label: l10n.cityDetailAffordabilityTitle,
          headline: housing.headline,
          icon: Icons.home_work_outlined,
          tint: housing.tint,
          meaning: l10n.cityMetricInsightHousingMeaning,
          method: l10n.cityMetricInsightHousingMethod,
          validate: l10n.cityMetricInsightHousingValidate,
          facts: [
            _InsightFact(
              label: l10n.cityHousingViabilityTileLabel,
              value: '${city.rentScore}/100',
            ),
            _InsightFact(
              label: l10n.cityDetailCostLabel,
              value: '${city.movaroScores.economical}/100',
            ),
            _InsightFact(
              label: l10n.cityMetricInsightRangeLabel,
              value: _housingRange(city.rentScore),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightCurrentBaseBadge,
            ),
            _InsightSource(
              title: 'FipeZAP',
              provider: 'FIPE',
              description: l10n.cityMetricInsightHousingMappedSource,
              badge: l10n.cityMetricInsightMappedBaseBadge,
              isOfficial: true,
              url: 'https://www.fipe.org.br/pt-br/indices/fipezap/',
            ),
          ],
        );
      case CityMetricInsightTopic.safety:
        final safety = CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.safety,
          value: city.safetyScore,
        );
        return _CityMetricInsightContent(
          label: l10n.cityDetailSafetyLabel,
          headline: safety.headline,
          icon: safety.icon,
          tint: safety.tint,
          meaning: l10n.cityMetricInsightSafetyMeaning,
          method: l10n.cityMetricInsightSafetyMethod,
          validate: l10n.cityMetricInsightSafetyValidate,
          facts: [
            _InsightFact(
              label: l10n.cityDetailSafetyLabel,
              value: '${city.safetyScore}/100',
            ),
            _InsightFact(
              label: l10n.cityMetricInsightRangeLabel,
              value: _trafficLightRange(city.safetyScore, mediumStartsAt: 55),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightCurrentBaseBadge,
            ),
            _InsightSource(
              title: 'Atlas da Violencia',
              provider: 'Ipea + FBSP',
              description: l10n.cityMetricInsightSafetyMappedSource,
              badge: l10n.cityMetricInsightMappedBaseBadge,
              isOfficial: true,
              url:
                  'https://www.ipea.gov.br/atlasviolencia/publicacoes/287/atlas-da-violencia-2024',
            ),
          ],
        );
      case CityMetricInsightTopic.work:
        final work = CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.work,
          value: city.movaroScores.workOpportunity,
        );
        return _CityMetricInsightContent(
          label: l10n.cityDetailWorkLabel,
          headline: work.headline,
          icon: work.icon,
          tint: work.tint,
          meaning: l10n.cityMetricInsightWorkMeaning,
          method: l10n.cityMetricInsightWorkMethod,
          validate: l10n.cityMetricInsightWorkValidate,
          facts: [
            _InsightFact(
              label: l10n.cityDetailWorkLabel,
              value: '${city.movaroScores.workOpportunity}/100',
            ),
            _InsightFact(
              label: l10n.migrationPlanPrepWorkSignalJobs,
              value: '${city.jobMarketScore}/100',
            ),
            _InsightFact(
              label: l10n.migrationPlanPrepWorkSignalEconomic,
              value: '${city.economicActivityScore}/100',
            ),
            _InsightFact(
              label: l10n.cityDetailUnemploymentLabel,
              value: '${city.unemploymentRate.toStringAsFixed(1)}%',
            ),
            _InsightFact(
              label: l10n.cityMetricInsightRangeLabel,
              value: _trafficLightRange(
                city.movaroScores.workOpportunity,
                mediumStartsAt: 62,
                highStartsAt: 78,
              ),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightCurrentBaseBadge,
            ),
            _InsightSource(
              title: 'Novo Caged',
              provider: 'Ministerio do Trabalho e Emprego',
              description: l10n.cityMetricInsightWorkMappedSource,
              badge: l10n.cityMetricInsightMappedBaseBadge,
              isOfficial: true,
              url:
                  'https://www.gov.br/trabalho-e-emprego/pt-br/servicos/empregador/caged',
            ),
            _InsightSource(
              title: 'PIB dos Municipios',
              provider: 'IBGE',
              description: l10n.cityMetricInsightWorkEconomicMappedSource,
              badge: l10n.cityMetricInsightMappedBaseBadge,
              isOfficial: true,
              url:
                  'https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/2036-np-produto-interno-bruto-dos-municipios.html',
            ),
          ],
        );
      case CityMetricInsightTopic.language:
        final language = CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.language,
          value: city.movaroScores.languageAdaptation,
        );
        return _CityMetricInsightContent(
          label: l10n.cityDetailLanguageLabel,
          headline: language.headline,
          icon: language.icon,
          tint: language.tint,
          meaning: l10n.cityMetricInsightLanguageMeaning,
          method: l10n.cityMetricInsightLanguageMethod,
          validate: l10n.cityMetricInsightLanguageValidate,
          facts: [
            _InsightFact(
              label: l10n.cityDetailLanguageLabel,
              value: '${city.movaroScores.languageAdaptation}/100',
            ),
            _InsightFact(
              label: l10n.cityMetricInsightSpanishSupportLabel,
              value: '${city.spanishSupportScore}/100',
            ),
            _InsightFact(
              label: l10n.cityDetailPopularityLabel,
              value: '${city.argentinaPopularityScore}/100',
            ),
            _InsightFact(
              label: l10n.cityMetricInsightRangeLabel,
              value: _trafficLightRange(
                city.movaroScores.languageAdaptation,
                mediumStartsAt: 65,
                highStartsAt: 82,
              ),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightCurrentBaseBadge,
            ),
            _InsightSource(
              title: l10n.cityMetricInsightLanguageCurrentBaseTitle,
              provider: 'Movaro',
              description: l10n.cityMetricInsightLanguageMappedSource,
              badge: l10n.cityMetricInsightMappedBaseBadge,
              isOfficial: false,
            ),
          ],
        );
    }
  }

  static _InsightSource _fromCitySource(
    BuildContext context,
    CitySource source, {
    required String badge,
  }) {
    return _InsightSource(
      title: source.title,
      provider: source.provider,
      description: source.description,
      badge: badge,
      isOfficial: source.isOfficial,
      url: source.url,
    );
  }

  static String _housingRange(int score) {
    if (score >= 72) {
      return '72+';
    }
    if (score >= 55) {
      return '55-71';
    }
    return '0-54';
  }

  static String _trafficLightRange(
    int score, {
    required int mediumStartsAt,
    int highStartsAt = 72,
  }) {
    if (score >= highStartsAt) {
      return '$highStartsAt+';
    }
    if (score >= mediumStartsAt) {
      return '$mediumStartsAt-${highStartsAt - 1}';
    }
    return '0-${mediumStartsAt - 1}';
  }
}

class _InsightFact {
  const _InsightFact({required this.label, required this.value});

  final String label;
  final String value;
}

class _InsightSource {
  const _InsightSource({
    required this.title,
    required this.provider,
    required this.description,
    required this.badge,
    required this.isOfficial,
    this.url,
  });

  final String title;
  final String provider;
  final String description;
  final String badge;
  final bool isOfficial;
  final String? url;
}

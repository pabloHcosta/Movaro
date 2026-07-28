import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/utils/cost_estimate_formatter.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card_metric_classifier.dart';
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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: content.tint.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: content.tint.withValues(alpha: 0.16)),
              ),
              child: Row(
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
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
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
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionBlock(
              title: context.l10n.cityMetricInsightQuickReadTitle,
              child: Text(
                content.whyThisCity,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _InsightCallout(
              icon: Icons.lightbulb_outline_rounded,
              tint: content.tint,
              text: content.meaning,
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
            _ValidationCard(
              tint: content.tint,
              title: context.l10n.cityMetricInsightValidateTitle,
              text: content.validate,
            ),
            const SizedBox(height: 14),
            _ExpandableInsightSection(
              icon: Icons.tune_rounded,
              title: context.l10n.cityMetricInsightMethodTitle,
              child: Text(
                content.method,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ExpandableInsightSection(
              icon: Icons.verified_outlined,
              title: context.l10n.cityMetricInsightSourcesTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final source in content.sources) ...[
                    _SourceCard(source: source),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 2),
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
          ],
        ),
      ),
    );
  }
}

class _InsightCallout extends StatelessWidget {
  const _InsightCallout({
    required this.icon,
    required this.tint,
    required this.text,
  });

  final IconData icon;
  final Color tint;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({
    required this.tint,
    required this.title,
    required this.text,
  });

  final Color tint;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.checklist_rounded, color: tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableInsightSection extends StatelessWidget {
  const _ExpandableInsightSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary, size: 21),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [child],
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
          Text(
            source.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    required this.cityName,
    required this.label,
    required this.headline,
    required this.icon,
    required this.tint,
    required this.whyThisCity,
    required this.meaning,
    required this.method,
    required this.validate,
    required this.facts,
    required this.sources,
  });

  final String cityName;
  final String label;
  final String headline;
  final IconData icon;
  final Color tint;
  final String whyThisCity;
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
        final budget = city.budgetSnapshot;
        return _CityMetricInsightContent(
          cityName: city.name,
          label: l10n.cityDetailAffordabilityTitle,
          headline: housing.headline,
          icon: Icons.home_work_outlined,
          tint: housing.tint,
          whyThisCity: _localizedText(
            context,
            pt: budget == null
                ? 'A entrada em ${city.name} parece ${housing.headline.toLowerCase()} na comparação com o catálogo. Ainda não há uma faixa mensal externa integrada para esta cidade.'
                : 'Em ${city.name}, a referência disponível aponta uma rotina mensal entre ${_monthlyCostRange(context, city)}. É uma faixa de planejamento, não um preço garantido.',
            es: budget == null
                ? 'La entrada en ${city.name} parece ${housing.headline.toLowerCase()} frente al catálogo. Todavía no hay un rango mensual externo integrado para esta ciudad.'
                : 'En ${city.name}, la referencia disponible estima una rutina mensual entre ${_monthlyCostRange(context, city)}. Es un rango para planificar, no un precio garantizado.',
            en: budget == null
                ? 'Entry into ${city.name} looks ${housing.headline.toLowerCase()} against the catalog. There is no integrated external monthly range for this city yet.'
                : 'In ${city.name}, the available reference estimates a monthly routine between ${_monthlyCostRange(context, city)}. This is a planning range, not a guaranteed price.',
          ),
          meaning: l10n.cityMetricInsightHousingMeaning,
          method: l10n.cityMetricInsightHousingMethod,
          validate: l10n.cityMetricInsightHousingValidate,
          facts: budget == null
              ? [
                  _InsightFact(
                    label: l10n.cityHousingViabilityTileLabel,
                    value: housing.headline,
                  ),
                  _InsightFact(
                    label: l10n.cityDetailCostLabel,
                    value: _costLevel(context, city),
                  ),
                  _InsightFact(
                    label: _localizedText(
                      context,
                      pt: 'Tipo de dado',
                      es: 'Tipo de dato',
                      en: 'Data type',
                    ),
                    value: _localizedText(
                      context,
                      pt: 'Comparação interna',
                      es: 'Comparación interna',
                      en: 'Internal comparison',
                    ),
                  ),
                ]
              : [
                  _InsightFact(
                    label: _localizedText(
                      context,
                      pt: 'Rotina mensal',
                      es: 'Rutina mensual',
                      en: 'Monthly routine',
                    ),
                    value: _monthlyCostRange(context, city),
                  ),
                  _InsightFact(
                    label: _localizedText(
                      context,
                      pt: 'Aluguel de 1 quarto',
                      es: 'Alquiler de 1 dormitorio',
                      en: '1-bedroom rent',
                    ),
                    value: _rentRange(context, city),
                  ),
                  _InsightFact(
                    label: _localizedText(
                      context,
                      pt: 'Referência',
                      es: 'Referencia',
                      en: 'Reference',
                    ),
                    value: budget.updatedAt,
                  ),
                ],
          sources: [
            if (budget != null) _fromBudgetSnapshot(context, city),
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightInternalMethodBadge,
              description: _localizedText(
                context,
                pt: 'Organiza a estimativa externa em uma leitura comparável com o catálogo. Não é um índice oficial de moradia.',
                es: 'Organiza la estimación externa en una lectura comparable con el catálogo. No es un índice oficial de vivienda.',
                en: 'Turns the external estimate into a catalog comparison. It is not an official housing index.',
              ),
            ),
          ],
        );
      case CityMetricInsightTopic.safety:
        final safety = CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.safety,
          value: city.safetyScore,
        );
        final safetySource = city.sources.safety;
        final officialRate = safetySource?.referenceValue;
        final hasObservedRate = officialRate != null;
        return _CityMetricInsightContent(
          cityName: city.name,
          label: l10n.cityDetailSafetyLabel,
          headline: hasObservedRate
              ? _safetyLevel(context, city.safetyScore)
              : l10n.cityCardDataUnavailable,
          icon: safety.icon,
          tint: safety.tint,
          whyThisCity: _localizedText(
            context,
            pt: hasObservedRate
                ? 'A leitura de ${city.name} é ${_safetyLevel(context, city.safetyScore).toLowerCase()} com base em ${_formatDecimal(context, officialRate)} homicídios registrados por 100 mil habitantes/ano. Isso observa violência letal, não todos os crimes nem cada bairro.'
                : 'Ainda não há uma taxa municipal integrada suficiente para resumir a segurança de ${city.name} com responsabilidade.',
            es: hasObservedRate
                ? 'La lectura de ${city.name} es ${_safetyLevel(context, city.safetyScore).toLowerCase()} con base en ${_formatDecimal(context, officialRate)} homicidios registrados por cada 100 mil habitantes/año. Esto observa violencia letal, no todos los delitos ni cada barrio.'
                : 'Todavía no hay una tasa municipal integrada suficiente para resumir la seguridad de ${city.name} con responsabilidad.',
            en: hasObservedRate
                ? 'The ${city.name} read is ${_safetyLevel(context, city.safetyScore).toLowerCase()} based on ${_formatDecimal(context, officialRate)} registered homicides per 100k residents/year. This observes lethal violence, not every crime or neighborhood.'
                : 'There is not yet enough integrated municipal data to summarize safety in ${city.name} responsibly.',
          ),
          meaning: l10n.cityMetricInsightSafetyMeaning,
          method: l10n.cityMetricInsightSafetyMethod,
          validate: l10n.cityMetricInsightSafetyValidate,
          facts: [
            _InsightFact(
              label: _localizedText(
                context,
                pt: 'Leitura municipal',
                es: 'Lectura municipal',
                en: 'Municipal read',
              ),
              value: hasObservedRate
                  ? _safetyLevel(context, city.safetyScore)
                  : l10n.cityCardDataUnavailable,
            ),
            if (officialRate != null)
              _InsightFact(
                label: l10n.cityMetricInsightSafetyOfficialRateLabel,
                value: l10n.cityMetricInsightSafetyRateValue(
                  _formatDecimal(context, officialRate),
                ),
              ),
            if (safetySource?.referencePeriod != null)
              _InsightFact(
                label: l10n.cityMetricInsightReferencePeriodLabel,
                value: safetySource!.referencePeriod!,
              ),
          ],
          sources: safetySource != null
              ? [
                  _fromCitySource(
                    context,
                    safetySource,
                    badge: l10n.cityMetricInsightDerivedOfficialBadge,
                    description: _localizedText(
                      context,
                      pt: 'Taxa municipal de violência letal baseada no Atlas da Violência/Ipea e SIM/MS. A categoria exibida é uma interpretação do app; não cobre crimes patrimoniais nem diferenças entre bairros.',
                      es: 'Tasa municipal de violencia letal basada en Atlas da Violência/Ipea y SIM/MS. La categoría mostrada es una interpretación de la app; no cubre delitos contra la propiedad ni diferencias entre barrios.',
                      en: 'Municipal lethal-violence rate based on Atlas da Violência/Ipea and SIM/MS. The displayed category is an app interpretation; it does not cover property crime or neighborhood differences.',
                    ),
                  ),
                ]
              : [
                  _fromCitySource(
                    context,
                    city.sources.curatedMetrics,
                    badge: l10n.cityMetricInsightInternalMethodBadge,
                    description: _localizedText(
                      context,
                      pt: 'Sem taxa municipal integrada, o app não apresenta uma conclusão numérica de segurança.',
                      es: 'Sin una tasa municipal integrada, la app no muestra una conclusión numérica de seguridad.',
                      en: 'Without an integrated municipal rate, the app does not present a numerical safety conclusion.',
                    ),
                  ),
                ],
        );
      case CityMetricInsightTopic.work:
        final work = CityMetricPresentation.resolve(
          context,
          kind: CityMetricKind.work,
          value: city.movaroScores.workOpportunity,
        );
        final employmentSource = city.sources.employment;
        final hasOfficialEmployment = employmentSource != null;
        return _CityMetricInsightContent(
          cityName: city.name,
          label: l10n.cityDetailWorkLabel,
          headline: hasOfficialEmployment
              ? work.headline
              : _localizedText(
                  context,
                  pt: 'Leitura preliminar',
                  es: 'Lectura preliminar',
                  en: 'Preliminary read',
                ),
          icon: work.icon,
          tint: hasOfficialEmployment ? work.tint : AppColors.warning,
          whyThisCity: _localizedText(
            context,
            pt: hasOfficialEmployment
                ? 'A leitura de trabalho em ${city.name} usa a base municipal integrada e os setores econômicos disponíveis. Ainda assim, sua área e senioridade podem mudar completamente o resultado.'
                : 'O catálogo ainda não integrou emprego formal municipal para ${city.name}. Os setores disponíveis são apenas pistas; confirme vagas reais antes de planejar renda local.',
            es: hasOfficialEmployment
                ? 'La lectura laboral de ${city.name} usa la base municipal integrada y los sectores económicos disponibles. Aun así, tu área y seniority pueden cambiar por completo el resultado.'
                : 'El catálogo todavía no integró empleo formal municipal para ${city.name}. Los sectores disponibles son solo pistas; confirmá vacantes reales antes de planificar ingresos locales.',
            en: hasOfficialEmployment
                ? 'The ${city.name} work read uses integrated municipal data and available economic sectors. Your field and seniority can still change the outcome completely.'
                : 'The catalog has not yet integrated municipal formal-employment data for ${city.name}. Available sectors are only clues; confirm real openings before planning local income.',
          ),
          meaning: l10n.cityMetricInsightWorkMeaning,
          method: l10n.cityMetricInsightWorkMethod,
          validate: l10n.cityMetricInsightWorkValidate,
          facts: [
            _InsightFact(
              label: _localizedText(
                context,
                pt: 'Setores indicativos',
                es: 'Sectores indicativos',
                en: 'Indicative sectors',
              ),
              value: city.topIndustries.isEmpty
                  ? l10n.cityCardDataUnavailable
                  : city.topIndustries.take(2).join(' · '),
            ),
            _InsightFact(
              label: _localizedText(
                context,
                pt: 'Emprego municipal oficial',
                es: 'Empleo municipal oficial',
                en: 'Official municipal employment',
              ),
              value: hasOfficialEmployment
                  ? _localizedText(
                      context,
                      pt: 'Integrado',
                      es: 'Integrado',
                      en: 'Integrated',
                    )
                  : _localizedText(
                      context,
                      pt: 'Ainda não integrado',
                      es: 'Todavía no integrado',
                      en: 'Not yet integrated',
                    ),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              employmentSource ?? city.sources.curatedMetrics,
              badge: hasOfficialEmployment
                  ? l10n.cityMetricInsightCurrentBaseBadge
                  : l10n.cityMetricInsightInternalMethodBadge,
              description: hasOfficialEmployment
                  ? null
                  : _localizedText(
                      context,
                      pt: 'Organiza setores indicativos do catálogo. Não substitui dados municipais de emprego, salário ou vagas abertas.',
                      es: 'Organiza sectores indicativos del catálogo. No reemplaza datos municipales de empleo, salario o vacantes abiertas.',
                      en: 'Organizes indicative catalog sectors. It does not replace municipal employment, salary, or live-opening data.',
                    ),
            ),
            _InsightSource(
              title: 'Novo Caged',
              provider: 'Ministério do Trabalho e Emprego',
              description: _localizedText(
                context,
                pt: 'Consulta oficial de admissões, desligamentos e emprego formal por município. Esta base ainda não compõe automaticamente a leitura exibida acima.',
                es: 'Consulta oficial de altas, bajas y empleo formal por municipio. Esta base todavía no forma parte automáticamente de la lectura mostrada arriba.',
                en: 'Official municipal admissions, dismissals, and formal-employment reference. This base does not yet automatically feed the read above.',
              ),
              badge: l10n.cityMetricInsightOfficialConsultationBadge,
              isOfficial: true,
              url:
                  'https://www.gov.br/trabalho-e-emprego/pt-br/assuntos/estatisticas-trabalho/novo-caged',
            ),
            _InsightSource(
              title: 'Censo 2022: Trabalho e Rendimento',
              provider: 'IBGE',
              description: _localizedText(
                context,
                pt: 'Referência oficial com ocupação, atividade e rendimento em recorte municipal. Serve para validação; ainda não compõe automaticamente este resumo.',
                es: 'Referencia oficial con ocupación, actividad e ingresos por municipio. Sirve para validar; todavía no forma parte automáticamente de este resumen.',
                en: 'Official municipal occupation, activity, and income reference. It supports validation but does not yet automatically feed this summary.',
              ),
              badge: l10n.cityMetricInsightOfficialConsultationBadge,
              isOfficial: true,
              url:
                  'https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html',
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
          cityName: city.name,
          label: l10n.cityDetailLanguageLabel,
          headline: _languageLevel(
            context,
            city.movaroScores.languageAdaptation,
          ),
          icon: language.icon,
          tint: language.tint,
          whyThisCity: _localizedText(
            context,
            pt: 'A adaptação inicial em ${city.name} parece ${_languageLevel(context, city.movaroScores.languageAdaptation).toLowerCase()}. Isso considera presença argentina e apoio percebido ao espanhol, não uma medição oficial de idioma.',
            es: 'La adaptación inicial en ${city.name} parece ${_languageLevel(context, city.movaroScores.languageAdaptation).toLowerCase()}. Esto considera presencia argentina y apoyo percibido en español, no una medición oficial de idioma.',
            en: 'Early adaptation in ${city.name} looks ${_languageLevel(context, city.movaroScores.languageAdaptation).toLowerCase()}. This considers Argentine presence and perceived Spanish support, not an official language measure.',
          ),
          meaning: l10n.cityMetricInsightLanguageMeaning,
          method: l10n.cityMetricInsightLanguageMethod,
          validate: l10n.cityMetricInsightLanguageValidate,
          facts: [
            _InsightFact(
              label: _localizedText(
                context,
                pt: 'Adaptação inicial',
                es: 'Adaptación inicial',
                en: 'Early adaptation',
              ),
              value: _languageLevel(
                context,
                city.movaroScores.languageAdaptation,
              ),
            ),
            _InsightFact(
              label: l10n.cityMetricInsightSpanishSupportLabel,
              value: _genericLevel(context, city.spanishSupportScore),
            ),
            _InsightFact(
              label: l10n.cityDetailPopularityLabel,
              value: _genericLevel(context, city.argentinaPopularityScore),
            ),
          ],
          sources: [
            _fromCitySource(
              context,
              city.sources.curatedMetrics,
              badge: l10n.cityMetricInsightInternalMethodBadge,
              description: _localizedText(
                context,
                pt: 'Heurística não oficial para comparar a adaptação inicial de falantes de espanhol. Não mede proficiência individual.',
                es: 'Heurística no oficial para comparar la adaptación inicial de hispanohablantes. No mide el dominio individual.',
                en: 'Non-official heuristic for comparing early adaptation among Spanish speakers. It does not measure individual proficiency.',
              ),
            ),
          ],
        );
    }
  }

  static _InsightSource _fromCitySource(
    BuildContext context,
    CitySource source, {
    required String badge,
    String? description,
  }) {
    return _InsightSource(
      title: source.title,
      provider: source.provider,
      description: description ?? source.description,
      badge: badge,
      isOfficial: source.isOfficial,
      url: source.url,
    );
  }

  static _InsightSource _fromBudgetSnapshot(BuildContext context, City city) {
    final budget = city.budgetSnapshot!;
    return _InsightSource(
      title: _localizedText(
        context,
        pt: 'Estimativa mensal para ${city.name}',
        es: 'Estimación mensual para ${city.name}',
        en: 'Monthly estimate for ${city.name}',
      ),
      provider: budget.sourceLabel,
      description: _localizedText(
        context,
        pt: 'Referência externa e derivada para planejamento. Pode divergir de anúncios atuais, bairro, câmbio e perfil de consumo; não é um preço oficial.',
        es: 'Referencia externa y derivada para planificar. Puede diferir de anuncios actuales, barrio, cambio y perfil de consumo; no es un precio oficial.',
        en: 'External derived planning reference. It may differ from current listings, neighborhood, exchange rate, and spending profile; it is not an official price.',
      ),
      badge: context.l10n.cityMetricInsightExternalEstimateBadge,
      isOfficial: false,
      url: budget.sourceUrl,
    );
  }

  static String _monthlyCostRange(BuildContext context, City city) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return context.l10n.cityCardDataUnavailable;
    }
    final range = CostEstimateFormatter.brlRange(
      budget.fairLivingTotal,
      budget.wellLivingTotal,
      locale: Localizations.localeOf(context).toString(),
      compact: true,
    );
    return context.l10n.cityCardMonthlyEstimate(range);
  }

  static String _rentRange(BuildContext context, City city) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return context.l10n.cityCardDataUnavailable;
    }
    final range = CostEstimateFormatter.brlRange(
      budget.planningRentLow,
      budget.planningRentHigh,
      locale: Localizations.localeOf(context).toString(),
      compact: true,
    );
    return context.l10n.cityCardMonthlyEstimate(range);
  }

  static String _costLevel(BuildContext context, City city) {
    return switch (CityCardMetricClassifier.levelFor(
      city.movaroScores.economical,
    )) {
      CityCardMetricLevel.high => context.l10n.cityCardCostLow,
      CityCardMetricLevel.medium => context.l10n.cityCardCostMedium,
      CityCardMetricLevel.low => context.l10n.cityCardCostHigh,
    };
  }

  static String _safetyLevel(BuildContext context, int value) {
    return switch (CityCardMetricClassifier.levelFor(value)) {
      CityCardMetricLevel.high => context.l10n.cityCardSafetyHigh,
      CityCardMetricLevel.medium => context.l10n.cityCardSafetyMedium,
      CityCardMetricLevel.low => context.l10n.cityCardSafetyLow,
    };
  }

  static String _languageLevel(BuildContext context, int value) {
    return switch (CityCardMetricClassifier.levelFor(value)) {
      CityCardMetricLevel.high => context.l10n.cityCardLanguageEasy,
      CityCardMetricLevel.medium => context.l10n.cityCardLanguageModerate,
      CityCardMetricLevel.low => context.l10n.cityCardLanguageChallenging,
    };
  }

  static String _genericLevel(BuildContext context, int value) {
    return switch (CityCardMetricClassifier.levelFor(value)) {
      CityCardMetricLevel.high => _localizedText(
        context,
        pt: 'Alto',
        es: 'Alto',
        en: 'High',
      ),
      CityCardMetricLevel.medium => _localizedText(
        context,
        pt: 'Médio',
        es: 'Medio',
        en: 'Medium',
      ),
      CityCardMetricLevel.low => _localizedText(
        context,
        pt: 'Baixo',
        es: 'Bajo',
        en: 'Low',
      ),
    };
  }

  static String _formatDecimal(BuildContext context, num value) {
    final formatter =
        NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
          ..minimumFractionDigits = 1
          ..maximumFractionDigits = 1;
    return formatter.format(value);
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

String _localizedText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'es':
      return es;
    case 'en':
      return en;
    default:
      return pt;
  }
}

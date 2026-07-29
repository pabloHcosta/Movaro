import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/trust/source_freshness_policy.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/explore/application/services/pre_plan_budget_estimator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class PracticalCostEstimator extends StatefulWidget {
  const PracticalCostEstimator({
    required this.exchangeRatesService,
    this.preferredCountryId,
    super.key,
  });

  final CopilotExchangeRatesService exchangeRatesService;
  final String? preferredCountryId;

  @override
  State<PracticalCostEstimator> createState() => _PracticalCostEstimatorState();
}

class _PracticalCostEstimatorState extends State<PracticalCostEstimator> {
  late final Future<CopilotExchangeRates?> _exchangeFuture;
  PrePlanBudgetProfile _profile = const PrePlanBudgetProfile();

  @override
  void initState() {
    super.initState();
    _exchangeFuture = widget.exchangeRatesService.fetchLatest();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FutureBuilder<CopilotExchangeRates?>(
      future: _exchangeFuture,
      builder: (context, snapshot) {
        final exchange = snapshot.data;
        final hasExchange = exchange != null;
        final items = _items(context);
        final estimate = PrePlanBudgetEstimator.build(_profile);

        return FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.documentationCostsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.documentationCostsBody,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textSoft),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  hasExchange
                      ? _exchangeStatus(context, exchange)
                      : _localizedText(
                          context,
                          pt: 'Conversão indisponível agora · valores convertidos ficam ocultos, sem usar cotação antiga',
                          es: 'Conversión no disponible ahora · los valores convertidos se ocultan, sin usar una cotización antigua',
                          en: 'Conversion unavailable now · converted values stay hidden instead of using an old rate',
                        ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSoft),
                ),
              ),
              const SizedBox(height: 18),
              _PrePlanBudgetPanel(
                profile: _profile,
                estimate: estimate,
                exchange: exchange,
                preferredCountryId: widget.preferredCountryId,
                onChanged: (profile) => setState(() => _profile = profile),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  final medium = constraints.maxWidth >= 640;
                  final cardWidth = wide
                      ? (constraints.maxWidth - 24) / 3
                      : medium
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: cardWidth,
                          child: _CostItemCard(
                            item: item,
                            exchange: exchange,
                            preferredCountryId: widget.preferredCountryId,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.documentationCostsDisclaimer,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: textSoft),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CostItem> _items(BuildContext context) {
    final l10n = context.l10n;

    return [
      _CostItem(
        icon: Icons.account_balance_outlined,
        title: l10n.documentationCostMigrationTitle,
        headline: l10n.documentationCostMigrationValue,
        amountInBrl: 372.90,
        costType: _CostType.fee,
        supporting: l10n.documentationCostMigrationSupporting,
        sourceLabel: 'Polícia Federal',
        sourceUrl:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina',
      ),
      _CostItem(
        icon: Icons.badge_outlined,
        title: l10n.documentationCostCpfTitle,
        headline: l10n.documentationCostCpfValue,
        amountInBrl: 7,
        costType: _CostType.freeOrFee,
        supporting: l10n.documentationCostCpfSupporting,
        sourceLabel: 'Receita Federal',
        sourceUrl:
            'https://www.gov.br/pt-br/servicos/inscrever-no-cpf?id=10416&origem=servico',
      ),
      _CostItem(
        icon: Icons.health_and_safety_outlined,
        title: l10n.documentationCostSusCardTitle,
        headline: l10n.documentationCostFreeValue,
        costType: _CostType.free,
        supporting: l10n.documentationCostSusCardSupporting,
        sourceLabel: 'Ministério da Saúde',
        sourceUrl:
            'https://www.gov.br/saude/pt-br/centrais-de-conteudo/publicacoes/cartilhas/2024/conheca-seus-direitos-no-sus.pdf',
      ),
      _CostItem(
        icon: Icons.home_work_outlined,
        title: l10n.documentationCostHousingTitle,
        headline: l10n.documentationCostHousingValue,
        costType: _CostType.reserve,
        supporting: l10n.documentationCostHousingSupporting,
        sourceLabel: l10n.documentationCostHousingSource,
        sourceUrl:
            'https://www.planalto.gov.br/ccivil_03/leis/l8245compilado.htm',
      ),
      _CostItem(
        icon: Icons.folder_copy_outlined,
        title: l10n.documentationCostDocumentsTitle,
        headline: l10n.documentationCostVariableValue,
        costType: _CostType.variable,
        supporting: l10n.documentationCostDocumentsSupporting,
        sourceLabel: 'Polícia Federal',
        sourceUrl:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/organizar/duvidas-frequentes2/mais-informacoes/legalizacao-apostilamento-e-traducao',
      ),
      _CostItem(
        icon: Icons.favorite_outline_rounded,
        title: l10n.documentationCostPrivateHealthTitle,
        headline: l10n.documentationCostVariableValue,
        costType: _CostType.optionalMonthly,
        supporting: l10n.documentationCostPrivateHealthSupporting,
        sourceLabel: 'ANS',
        sourceUrl:
            'https://www.gov.br/ans/pt-br/publicidade-ans/contratacao-plano-de-saude',
      ),
    ];
  }

  String _formatUpdatedAt(BuildContext context, String rawValue) {
    final localeName = Localizations.localeOf(context).toString();
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    final pattern = rawValue.contains('T') ? 'dd/MM HH:mm' : 'dd/MM/yyyy';
    return DateFormat(pattern, localeName).format(parsed.toLocal());
  }

  String _exchangeStatus(BuildContext context, CopilotExchangeRates exchange) {
    final reference = exchange.referenceDate ?? exchange.fetchedAt;
    return _localizedText(
      context,
      pt: 'Câmbio indicativo BCB + BCRA · referência ${_formatUpdatedAt(context, reference)} · valores arredondados',
      es: 'Cambio indicativo BCB + BCRA · referencia ${_formatUpdatedAt(context, reference)} · valores redondeados',
      en: 'Indicative BCB + BCRA exchange · reference ${_formatUpdatedAt(context, reference)} · rounded values',
    );
  }

  String _localizedText(
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

class _PrePlanBudgetPanel extends StatelessWidget {
  const _PrePlanBudgetPanel({
    required this.profile,
    required this.estimate,
    required this.exchange,
    required this.preferredCountryId,
    required this.onChanged,
  });

  final PrePlanBudgetProfile profile;
  final PrePlanBudgetEstimate estimate;
  final CopilotExchangeRates? exchange;
  final String? preferredCountryId;
  final ValueChanged<PrePlanBudgetProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);
    final locale = Localizations.localeOf(context).languageCode;

    String tr({required String pt, required String es, required String en}) =>
        switch (locale) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        pt: 'Simulação antes de escolher a cidade',
                        es: 'Simulación antes de elegir la ciudad',
                        en: 'Preview before choosing a city',
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        pt: 'Esta prévia não cria etapas nem altera seu plano. Depois de confirmar a cidade, o orçamento usa custos locais.',
                        es: 'Esta vista previa no crea etapas ni modifica tu plan. Después de confirmar la ciudad, el presupuesto usa costos locales.',
                        en: 'This preview creates no tasks and does not change your plan. Once a city is confirmed, the budget uses local costs.',
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: textSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: [
              _CountControl(
                label: tr(pt: 'Adultos', es: 'Adultos', en: 'Adults'),
                value: profile.adults,
                minimum: 1,
                maximum: 4,
                onChanged: (value) =>
                    onChanged(profile.copyWith(adults: value)),
              ),
              _CountControl(
                label: tr(pt: 'Crianças', es: 'Niños', en: 'Children'),
                value: profile.children,
                minimum: 0,
                maximum: 4,
                onChanged: (value) =>
                    onChanged(profile.copyWith(children: value)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tr(
              pt: 'Hospedagem temporária: ${profile.temporaryStayDays} dias',
              es: 'Alojamiento temporal: ${profile.temporaryStayDays} días',
              en: 'Temporary accommodation: ${profile.temporaryStayDays} days',
            ),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Slider(
            value: profile.temporaryStayDays.toDouble(),
            min: 7,
            max: 45,
            divisions: 38,
            onChanged: (value) =>
                onChanged(profile.copyWith(temporaryStayDays: value.round())),
          ),
          Text(
            tr(
              pt: 'Aluguel mensal planejado: ${_money(context, profile.plannedMonthlyRentBrl)}',
              es: 'Alquiler mensual previsto: ${_money(context, profile.plannedMonthlyRentBrl)}',
              en: 'Planned monthly rent: ${_money(context, profile.plannedMonthlyRentBrl)}',
            ),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Slider(
            value: profile.plannedMonthlyRentBrl.toDouble(),
            min: 1200,
            max: 5000,
            divisions: 19,
            onChanged: (value) => onChanged(
              profile.copyWith(plannedMonthlyRentBrl: value.round()),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                selected: profile.includePublicTransit,
                label: Text(
                  tr(
                    pt: 'Transporte público',
                    es: 'Transporte público',
                    en: 'Public transit',
                  ),
                ),
                onSelected: (value) =>
                    onChanged(profile.copyWith(includePublicTransit: value)),
              ),
              FilterChip(
                selected: profile.includePrivateHealth,
                label: Text(
                  tr(
                    pt: 'Saúde privada',
                    es: 'Salud privada',
                    en: 'Private health',
                  ),
                ),
                onSelected: (value) =>
                    onChanged(profile.copyWith(includePrivateHealth: value)),
              ),
              FilterChip(
                selected: profile.hasPet,
                label: Text(tr(pt: 'Pet', es: 'Mascota', en: 'Pet')),
                onSelected: (value) =>
                    onChanged(profile.copyWith(hasPet: value)),
              ),
            ],
          ),
          if (profile.children > 0) ...[
            const SizedBox(height: 18),
            Text(
              tr(
                pt: 'Escola para as crianças',
                es: 'Escuela para los niños',
                en: 'School for children',
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                pt: 'A rede pública não cobra mensalidade. Se considerar escola particular, informe um valor de planejamento por criança.',
                es: 'La red pública no cobra mensualidad. Si consideras una escuela privada, indica un valor estimado por niño.',
                en: 'Public schools charge no tuition. If considering a private school, enter a planning amount per child.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSoft),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(tr(pt: 'Pública', es: 'Pública', en: 'Public')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(
                    tr(pt: 'Particular', es: 'Privada', en: 'Private'),
                  ),
                ),
              ],
              selected: {profile.usePrivateSchool},
              onSelectionChanged: (selection) => onChanged(
                profile.copyWith(usePrivateSchool: selection.first),
              ),
            ),
            if (profile.usePrivateSchool) ...[
              const SizedBox(height: 10),
              Text(
                tr(
                  pt: 'Mensalidade informada por criança: ${_money(context, profile.privateSchoolMonthlyBrlPerChild)}',
                  es: 'Mensualidad indicada por niño: ${_money(context, profile.privateSchoolMonthlyBrlPerChild)}',
                  en: 'Entered tuition per child: ${_money(context, profile.privateSchoolMonthlyBrlPerChild)}',
                ),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: profile.privateSchoolMonthlyBrlPerChild.toDouble(),
                min: 500,
                max: 5000,
                divisions: 18,
                onChanged: (value) => onChanged(
                  profile.copyWith(
                    privateSchoolMonthlyBrlPerChild: value.round(),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              tr(
                pt: 'Pretendo estudar no ensino superior',
                es: 'Pienso estudiar en la educación superior',
                en: 'I plan to pursue higher education',
              ),
            ),
            subtitle: Text(
              tr(
                pt: 'Universidades públicas não cobram mensalidade; ingresso e documentos dependem do processo seletivo.',
                es: 'Las universidades públicas no cobran mensualidad; el ingreso y los documentos dependen del proceso selectivo.',
                en: 'Public universities charge no tuition; admission and documents depend on the selection process.',
              ),
            ),
            value: profile.includeHigherEducation,
            onChanged: (value) =>
                onChanged(profile.copyWith(includeHigherEducation: value)),
          ),
          if (profile.includeHigherEducation) ...[
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(tr(pt: 'Pública', es: 'Pública', en: 'Public')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(
                    tr(pt: 'Particular', es: 'Privada', en: 'Private'),
                  ),
                ),
              ],
              selected: {profile.usePrivateHigherEducation},
              onSelectionChanged: (selection) => onChanged(
                profile.copyWith(usePrivateHigherEducation: selection.first),
              ),
            ),
            if (profile.usePrivateHigherEducation) ...[
              const SizedBox(height: 10),
              Text(
                tr(
                  pt: 'Mensalidade universitária informada: ${_money(context, profile.privateHigherEducationMonthlyBrl)}',
                  es: 'Mensualidad universitaria indicada: ${_money(context, profile.privateHigherEducationMonthlyBrl)}',
                  en: 'Entered university tuition: ${_money(context, profile.privateHigherEducationMonthlyBrl)}',
                ),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: profile.privateHigherEducationMonthlyBrl.toDouble(),
                min: 500,
                max: 5000,
                divisions: 18,
                onChanged: (value) => onChanged(
                  profile.copyWith(
                    privateHigherEducationMonthlyBrl: value.round(),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 720
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: _PreviewTotalCard(
                      title: tr(
                        pt: 'Essencial para chegar',
                        es: 'Esencial para llegar',
                        en: 'Essentials for arrival',
                      ),
                      total: estimate.essentialTotalBrl,
                      lines: [
                        (
                          tr(
                            pt: 'Taxas oficiais',
                            es: 'Tasas oficiales',
                            en: 'Official fees',
                          ),
                          estimate.officialFeesBrl,
                        ),
                        (
                          tr(
                            pt: 'Reserva de moradia',
                            es: 'Reserva de vivienda',
                            en: 'Housing reserve',
                          ),
                          estimate.housingReserveBrl,
                        ),
                        (
                          tr(
                            pt: 'Hospedagem temporária',
                            es: 'Alojamiento temporal',
                            en: 'Temporary stay',
                          ),
                          estimate.temporaryStayBrl,
                        ),
                        (
                          tr(
                            pt: 'Primeiro mês',
                            es: 'Primer mes',
                            en: 'First month',
                          ),
                          estimate.monthlyEssentialsBrl,
                        ),
                      ],
                      exchange: exchange,
                      preferredCountryId: preferredCountryId,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _PreviewTotalCard(
                      title: tr(
                        pt: 'Reserva mais segura',
                        es: 'Reserva más segura',
                        en: 'Safer reserve',
                      ),
                      total: estimate.saferTotalBrl,
                      lines: [
                        (
                          tr(
                            pt: 'Base essencial',
                            es: 'Base esencial',
                            en: 'Essential base',
                          ),
                          estimate.essentialTotalBrl,
                        ),
                        (
                          tr(
                            pt: 'Serviços opcionais',
                            es: 'Servicios opcionales',
                            en: 'Optional services',
                          ),
                          estimate.optionalServicesBrl,
                        ),
                        (
                          tr(
                            pt: 'Educação particular',
                            es: 'Educación privada',
                            en: 'Private education',
                          ),
                          estimate.educationMonthlyBrl,
                        ),
                        (
                          tr(
                            pt: 'Reserva de 2 meses',
                            es: 'Reserva de 2 meses',
                            en: 'Two-month buffer',
                          ),
                          estimate.monthlyEssentialsBrl * 2,
                        ),
                      ],
                      exchange: exchange,
                      preferredCountryId: preferredCountryId,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _money(BuildContext context, num amount) {
    return MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: amount,
      exchangeRates: exchange,
      preferredCountryId: preferredCountryId,
    );
  }
}

class _CountControl extends StatelessWidget {
  const _CountControl({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        IconButton(
          tooltip: '-',
          onPressed: value > minimum ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Text('$value', style: Theme.of(context).textTheme.titleSmall),
        IconButton(
          tooltip: '+',
          onPressed: value < maximum ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}

class _PreviewTotalCard extends StatelessWidget {
  const _PreviewTotalCard({
    required this.title,
    required this.total,
    required this.lines,
    required this.exchange,
    required this.preferredCountryId,
  });

  final String title;
  final double total;
  final List<(String, double)> lines;
  final CopilotExchangeRates? exchange;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: total,
              exchangeRates: exchange,
              preferredCountryId: preferredCountryId,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ),
                  Text(
                    MultiCurrencyAmount.formatPreferredCurrency(
                      context: context,
                      amountInBrl: line.$2,
                      exchangeRates: exchange,
                      preferredCountryId: preferredCountryId,
                    ),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CostItemCard extends StatelessWidget {
  const _CostItemCard({
    required this.item,
    required this.exchange,
    required this.preferredCountryId,
  });

  final _CostItem item;
  final CopilotExchangeRates? exchange;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final hasAmount = item.amountInBrl != null;
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final freshness = SourceFreshnessPolicy.assess(
      lastVerified: item.lastVerified,
      reviewAfter: const Duration(days: 90),
    );

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: textPrimary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(label: _costTypeLabel(context, item.costType)),
              _InfoBadge(
                label: _freshnessLabel(context, freshness.status),
                warning: freshness.requiresWarning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            item.headline,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: textPrimary),
          ),
          if (hasAmount) ...[
            const SizedBox(height: 10),
            MultiCurrencyAmount(
              amountInBrl: item.amountInBrl!,
              exchangeRates: exchange,
              preferredCountryId: preferredCountryId,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.supporting,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PreparationWebViewPage(
                  title: item.sourceLabel,
                  uri: Uri.parse(item.sourceUrl),
                ),
              ),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(switch (Localizations.localeOf(context).languageCode) {
              'pt' => 'Fonte oficial · ${item.sourceLabel}',
              'es' => 'Fuente oficial · ${item.sourceLabel}',
              _ => 'Official source · ${item.sourceLabel}',
            }),
          ),
        ],
      ),
    );
  }

  String _costTypeLabel(BuildContext context, _CostType type) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch ((locale, type)) {
      ('pt', _CostType.fee) => 'Taxa',
      ('pt', _CostType.freeOrFee) => 'Grátis ou taxa',
      ('pt', _CostType.free) => 'Grátis',
      ('pt', _CostType.reserve) => 'Reserva',
      ('pt', _CostType.variable) => 'Variável',
      ('pt', _CostType.optionalMonthly) => 'Opcional · mensal',
      ('es', _CostType.fee) => 'Tasa',
      ('es', _CostType.freeOrFee) => 'Gratis o tasa',
      ('es', _CostType.free) => 'Gratis',
      ('es', _CostType.reserve) => 'Reserva',
      ('es', _CostType.variable) => 'Variable',
      ('es', _CostType.optionalMonthly) => 'Opcional · mensual',
      (_, _CostType.fee) => 'Fee',
      (_, _CostType.freeOrFee) => 'Free or fee',
      (_, _CostType.free) => 'Free',
      (_, _CostType.reserve) => 'Reserve',
      (_, _CostType.variable) => 'Variable',
      (_, _CostType.optionalMonthly) => 'Optional · monthly',
    };
  }

  String _freshnessLabel(BuildContext context, SourceFreshnessStatus status) {
    final locale = Localizations.localeOf(context).languageCode;
    final current = status == SourceFreshnessStatus.current;
    return switch (locale) {
      'pt' => current ? 'Fonte revisada' : 'Revisar na fonte',
      'es' => current ? 'Fuente revisada' : 'Revisar en la fuente',
      _ => current ? 'Source reviewed' : 'Check source',
    };
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, this.warning = false});

  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

enum _CostType { fee, freeOrFee, free, reserve, variable, optionalMonthly }

class _CostItem {
  const _CostItem({
    required this.icon,
    required this.title,
    required this.headline,
    required this.supporting,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.costType,
    this.amountInBrl,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String supporting;
  final String sourceLabel;
  final String sourceUrl;
  final _CostType costType;
  final double? amountInBrl;
  DateTime get lastVerified => DateTime(2026, 7, 28);
}

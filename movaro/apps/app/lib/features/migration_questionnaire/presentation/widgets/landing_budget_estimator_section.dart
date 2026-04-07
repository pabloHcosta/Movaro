import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/landing_budget_estimator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class LandingBudgetEstimatorSection extends StatelessWidget {
  const LandingBudgetEstimatorSection({
    required this.plan,
    this.exchangeRates,
    this.preferredCountryId,
    super.key,
  });

  final MigrationPlan plan;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estimate = LandingBudgetEstimator.build(plan: plan);
    final summary = _summaryLabel(context, estimate.summaryKey);
    final title = estimate.cityContext == null
        ? l10n.landingBudgetSectionTitle
        : l10n.landingBudgetSectionTitleWithCity(estimate.cityContext!);

    final cityBudget = plan.currentPlanCity?.budgetSnapshot;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          if (cityBudget != null) ...[
            const SizedBox(height: 18),
            _CityRealCostSection(
              budget: cityBudget,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ],
          const SizedBox(height: 18),
          if (exchangeRates != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                l10n.landingBudgetExchangeUpdatedAt(
                  _formatUpdatedAt(context, exchangeRates!.fetchedAt),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedFor(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                l10n.landingBudgetExchangeUnavailable,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 960;
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
                  for (final scenario in estimate.scenarios)
                    SizedBox(
                      width: cardWidth,
                      child: _ScenarioCard(
                        scenario: scenario,
                        title: _scenarioTitle(context, scenario.titleKey),
                        description: _scenarioBody(
                          context,
                          scenario.descriptionKey,
                        ),
                        exchangeRates: exchangeRates,
                        preferredCountryId: preferredCountryId,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            l10n.landingBudgetDisclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _summaryLabel(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetSummaryAsap' => l10n.landingBudgetSummaryAsap,
      'landingBudgetSummarySixMonths' => l10n.landingBudgetSummarySixMonths,
      'landingBudgetSummaryTwelveMonths' =>
        l10n.landingBudgetSummaryTwelveMonths,
      _ => l10n.landingBudgetSummaryResearching,
    };
  }

  String _scenarioTitle(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetLeanTitle' => l10n.landingBudgetLeanTitle,
      'landingBudgetComfortableTitle' => l10n.landingBudgetComfortableTitle,
      _ => l10n.landingBudgetBalancedTitle,
    };
  }

  String _scenarioBody(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'landingBudgetLeanBody' => l10n.landingBudgetLeanBody,
      'landingBudgetComfortableBody' => l10n.landingBudgetComfortableBody,
      _ => l10n.landingBudgetBalancedBody,
    };
  }

  String _formatUpdatedAt(BuildContext context, String rawValue) {
    final localeName = Localizations.localeOf(context).toString();
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    return DateFormat('dd/MM HH:mm', localeName).format(parsed.toLocal());
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.title,
    required this.description,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final LandingBudgetScenarioEstimate scenario;
  final String title;
  final String description;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final accent = switch (scenario.scenario) {
      LandingBudgetScenario.lean => AppColors.warning,
      LandingBudgetScenario.balanced => AppColors.primary,
      LandingBudgetScenario.comfortable => AppColors.success,
    };
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final total30 = MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: scenario.breakdown.total30DaysBrl,
      exchangeRates: exchangeRates,
      preferredCountryId: preferredCountryId,
      primaryLocale: locale,
    );
    final total90 = MultiCurrencyAmount.formatPreferredCurrency(
      context: context,
      amountInBrl: scenario.breakdown.total90DaysBrl,
      exchangeRates: exchangeRates,
      preferredCountryId: preferredCountryId,
      primaryLocale: locale,
    );

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: accent),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            total30,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.landingBudget30DaysLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 10),
          MultiCurrencyAmount(
            amountInBrl: scenario.breakdown.total30DaysBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _BudgetLine(
            label: l10n.landingBudgetMonthlyBaseLabel,
            amountInBrl: scenario.breakdown.monthlyBaseBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          _BudgetLine(
            label: l10n.landingBudgetSetupLabel,
            amountInBrl: scenario.breakdown.setupBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          _BudgetLine(
            label: l10n.landingBudgetBufferLabel,
            amountInBrl: scenario.breakdown.bufferBrl,
            exchangeRates: exchangeRates,
            preferredCountryId: preferredCountryId,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_outlined, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.landingBudget90DaysLabel(total90),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w600,
                    ),
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

// ─── Real city cost breakdown ─────────────────────────────────────────────────

class _CityRealCostSection extends StatelessWidget {
  const _CityRealCostSection({
    required this.budget,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final CityBudgetSnapshot budget;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  static const _kAccent = Color(0xFF3B7CC8);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1829) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1A2840) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_city_rounded,
                size: 14,
                color: _kAccent,
              ),
              const SizedBox(width: 6),
              Text(
                _sectionTitle(locale, budget.cityLabel),
                style: AppTypography.compactBadge.copyWith(
                  color: _kAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Sem aluguel',
              es: 'Sin alquiler',
              en: 'Excl. rent',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.singlePersonExcludingRent,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: '1 quarto fora do centro',
              es: '1 amb. fuera del centro',
              en: '1-bed outside centre',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.oneBedroomOutsideCentre,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: '1 quarto no centro',
              es: '1 amb. en el centro',
              en: '1-bed city centre',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.oneBedroomCityCentre,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Passe mensal',
              es: 'Pase mensual',
              en: 'Monthly pass',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.monthlyTransportPass,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(
            label: _label(
              locale,
              pt: 'Utilidades',
              es: 'Servicios',
              en: 'Utilities',
            ),
            value: MultiCurrencyAmount.formatPreferredCurrency(
              context: context,
              amountInBrl: budget.utilities,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _totalLabel(locale),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
              ),
              Text(
                '${MultiCurrencyAmount.formatPreferredCurrency(context: context, amountInBrl: budget.fairLivingTotal, exchangeRates: exchangeRates, preferredCountryId: preferredCountryId)}–${MultiCurrencyAmount.formatPreferredCurrency(context: context, amountInBrl: budget.wellLivingTotal, exchangeRates: exchangeRates, preferredCountryId: preferredCountryId)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _kAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _sourceNote(locale, budget.sourceLabel, budget.updatedAt),
            style: AppTypography.tinyLabel.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.28)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(String locale, String cityLabel) => switch (locale) {
    'pt' => 'Custos reais em $cityLabel',
    'es' => 'Costos reales en $cityLabel',
    _ => 'Real costs in $cityLabel',
  };

  String _totalLabel(String locale) => switch (locale) {
    'pt' => 'Viver justo → viver bem',
    'es' => 'Vivir justo → vivir bien',
    _ => 'Live fair → live well',
  };

  String _sourceNote(String locale, String source, String date) =>
      switch (locale) {
        'pt' => 'Fonte: $source · atualizado em $date',
        'es' => 'Fuente: $source · actualizado en $date',
        _ => 'Source: $source · updated $date',
      };

  String _label(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) => switch (locale) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.compactBadge.copyWith(
            color: AppColors.textPrimaryFor(context),
          ),
        ),
      ],
    );
  }
}

class _BudgetLine extends StatelessWidget {
  const _BudgetLine({
    required this.label,
    required this.amountInBrl,
    required this.exchangeRates,
    required this.preferredCountryId,
  });

  final String label;
  final num amountInBrl;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: MultiCurrencyAmount(
                amountInBrl: amountInBrl,
                exchangeRates: exchangeRates,
                preferredCountryId: preferredCountryId,
                compact: true,
                wrapSpacing: 6,
                runSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
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

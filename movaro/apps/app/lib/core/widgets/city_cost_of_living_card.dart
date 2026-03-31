import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/home/application/city_budget_data.dart';

class CityCostOfLivingCard extends StatelessWidget {
  const CityCostOfLivingCard({
    required this.budget,
    this.preferredCountryId,
    super.key,
  });

  final CityBudget budget;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    String copy({required String pt, required String es, required String en}) =>
        switch (locale) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy(
              pt: 'Quanto custa viver em ${budget.cityLabel}',
              es: 'Cuánto cuesta vivir en ${budget.cityLabel}',
              en: 'How much it costs to live in ${budget.cityLabel}',
            ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            copy(
              pt: 'Base real para 1 pessoa: custo mensal sem aluguel + aluguel de 1 quarto.',
              es: 'Base real para 1 persona: costo mensual sin alquiler + alquiler de 1 ambiente.',
              en: 'Real baseline for 1 person: monthly costs excluding rent + 1-bedroom rent.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CostPill(
                  tone: AppColors.warning,
                  label: copy(
                    pt: 'Viver justo',
                    es: 'Vivir justo',
                    en: 'Live fairly',
                  ),
                  amountInBrl: budget.fairLivingTotal,
                  preferredCountryId: preferredCountryId,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CostPill(
                  tone: AppColors.success,
                  label: copy(
                    pt: 'Viver bem',
                    es: 'Vivir bien',
                    en: 'Live well',
                  ),
                  amountInBrl: budget.wellLivingTotal,
                  preferredCountryId: preferredCountryId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 6,
            childAspectRatio: 2.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CostMetaChip(
                label: copy(
                  pt: 'Sem aluguel',
                  es: 'Sin alquiler',
                  en: 'Excl. rent',
                ),
                amountInBrl: budget.singlePersonExcludingRent,
                preferredCountryId: preferredCountryId,
              ),
              _CostMetaChip(
                label: copy(
                  pt: '1 quarto fora',
                  es: '1 amb. fuera',
                  en: '1-bed outside',
                ),
                amountInBrl: budget.oneBedroomOutsideCentre,
                preferredCountryId: preferredCountryId,
              ),
              _CostMetaChip(
                label: copy(
                  pt: '1 quarto centro',
                  es: '1 amb. centro',
                  en: '1-bed centre',
                ),
                amountInBrl: budget.oneBedroomCityCentre,
                preferredCountryId: preferredCountryId,
              ),
              _CostMetaChip(
                label: copy(
                  pt: 'Passe mensal',
                  es: 'Pase mensual',
                  en: 'Monthly pass',
                ),
                amountInBrl: budget.monthlyTransportPass,
                preferredCountryId: preferredCountryId,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            copy(
              pt: 'Fonte: ${budget.sourceLabel} · atualizado em ${budget.updatedAt}',
              es: 'Fuente: ${budget.sourceLabel} · actualizado en ${budget.updatedAt}',
              en: 'Source: ${budget.sourceLabel} · updated ${budget.updatedAt}',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostPill extends StatelessWidget {
  const _CostPill({
    required this.tone,
    required this.label,
    required this.amountInBrl,
    required this.preferredCountryId,
  });

  final Color tone;
  final String label;
  final num amountInBrl;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w900),
            child: MultiCurrencyAmount(
              amountInBrl: amountInBrl,
              exchangeRates: null,
              preferredCountryId: preferredCountryId,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostMetaChip extends StatelessWidget {
  const _CostMetaChip({
    required this.label,
    required this.amountInBrl,
    required this.preferredCountryId,
  });

  final String label;
  final num amountInBrl;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
            child: MultiCurrencyAmount(
              amountInBrl: amountInBrl,
              exchangeRates: null,
              preferredCountryId: preferredCountryId,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

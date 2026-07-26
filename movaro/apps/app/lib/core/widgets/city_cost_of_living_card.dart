import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';

class CityCostOfLivingCard extends StatelessWidget {
  const CityCostOfLivingCard({
    required this.budget,
    this.preferredCountryId,
    super.key,
  });

  final CityBudgetSnapshot budget;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;

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
          // ── Header ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  copy(
                    pt: 'Quanto custa viver em ${budget.cityLabel}',
                    es: 'Cuánto cuesta vivir en ${budget.cityLabel}',
                    en: 'Cost of living in ${budget.cityLabel}',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            copy(
              pt: 'Faixa estimada para 1 pessoa · aluguel e rotina variam por zona',
              es: 'Rango estimado para 1 persona · alquiler y rutina varían según la zona',
              en: 'Estimated range for 1 person · rent and routine vary by area',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // ── Main cost tiers ───────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CostTierCard(
                    tone: AppColors.warning,
                    icon: Icons.trending_flat_rounded,
                    label: copy(
                      pt: 'Mais econômico',
                      es: 'Más económico',
                      en: 'More economical',
                    ),
                    amountInBrl: budget.fairLivingTotal,
                    preferredCountryId: preferredCountryId,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CostTierCard(
                    tone: AppColors.success,
                    icon: Icons.trending_up_rounded,
                    label: copy(
                      pt: 'Mais confortável',
                      es: 'Más cómodo',
                      en: 'More comfortable',
                    ),
                    amountInBrl: budget.wellLivingTotal,
                    preferredCountryId: preferredCountryId,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Breakdown ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _BreakdownItem(
                        icon: Icons.receipt_long_outlined,
                        label: copy(
                          pt: 'Sem aluguel',
                          es: 'Sin alquiler',
                          en: 'Excl. rent',
                        ),
                        amountInBrl: budget.singlePersonExcludingRent,
                        preferredCountryId: preferredCountryId,
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: scheme.outlineVariant.withValues(alpha: 0.40),
                    ),
                    Expanded(
                      child: _BreakdownItem(
                        icon: Icons.home_outlined,
                        label: copy(
                          pt: 'Zona mais econômica',
                          es: 'Zona más económica',
                          en: 'Lower-cost area',
                        ),
                        amountInBrl: budget.planningRentLow,
                        preferredCountryId: preferredCountryId,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _BreakdownItem(
                        icon: Icons.apartment_outlined,
                        label: copy(
                          pt: 'Zona mais disputada',
                          es: 'Zona más demandada',
                          en: 'Higher-demand area',
                        ),
                        amountInBrl: budget.planningRentHigh,
                        preferredCountryId: preferredCountryId,
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: scheme.outlineVariant.withValues(alpha: 0.40),
                    ),
                    Expanded(
                      child: _BreakdownItem(
                        icon: Icons.directions_bus_outlined,
                        label: copy(
                          pt: 'Passe mensal',
                          es: 'Pase mensual',
                          en: 'Monthly pass',
                        ),
                        amountInBrl: budget.monthlyTransportPass,
                        preferredCountryId: preferredCountryId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Source ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.textSoftFor(context),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  copy(
                    pt: 'Referência, não orçamento fechado · ${budget.sourceLabel} · ${budget.updatedAt}',
                    es: 'Referencia, no presupuesto cerrado · ${budget.sourceLabel} · ${budget.updatedAt}',
                    en: 'Reference, not a fixed budget · ${budget.sourceLabel} · ${budget.updatedAt}',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cost tier card (Viver justo / Viver bem) ──────────────────────────────────

class _CostTierCard extends StatelessWidget {
  const _CostTierCard({
    required this.tone,
    required this.icon,
    required this.label,
    required this.amountInBrl,
    required this.preferredCountryId,
  });

  final Color tone;
  final IconData icon;
  final String label;
  final num amountInBrl;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tone.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: tone),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
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

// ── Breakdown item ────────────────────────────────────────────────────────────

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem({
    required this.icon,
    required this.label,
    required this.amountInBrl,
    required this.preferredCountryId,
  });

  final IconData icon;
  final String label;
  final num amountInBrl;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textSoftFor(context)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          child: MultiCurrencyAmount(
            amountInBrl: amountInBrl,
            exchangeRates: null,
            preferredCountryId: preferredCountryId,
            compact: true,
          ),
        ),
      ],
    );
  }
}

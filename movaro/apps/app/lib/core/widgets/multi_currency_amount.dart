import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class MultiCurrencyAmount extends StatelessWidget {
  const MultiCurrencyAmount({
    required this.amountInBrl,
    required this.exchangeRates,
    this.primaryLocale,
    this.compact = false,
    this.wrapSpacing = 8,
    this.runSpacing = 8,
    super.key,
  });

  final num amountInBrl;
  final CopilotExchangeRates? exchangeRates;
  final String? primaryLocale;
  final bool compact;
  final double wrapSpacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final primary = _formatCurrency(
      locale: primaryLocale ?? Localizations.localeOf(context).toString(),
      currencyCode: 'BRL',
      amount: amountInBrl,
    );

    if (exchangeRates == null) {
      return _AmountChip(label: primary, compact: compact);
    }

    return Wrap(
      spacing: wrapSpacing,
      runSpacing: runSpacing,
      children: [
        _AmountChip(label: primary, compact: compact),
        _AmountChip(
          label: _formatCurrency(
            locale: 'en_US',
            currencyCode: 'USD',
            amount: amountInBrl * exchangeRates!.brlToUsd,
          ),
          compact: compact,
        ),
        _AmountChip(
          label: _formatCurrency(
            locale: 'es_AR',
            currencyCode: 'ARS',
            amount: amountInBrl * exchangeRates!.brlToArs,
          ),
          compact: compact,
        ),
      ],
    );
  }

  static String formatCurrency({
    required String locale,
    required String currencyCode,
    required num amount,
  }) {
    return _formatCurrency(
      locale: locale,
      currencyCode: currencyCode,
      amount: amount,
    );
  }

  static String _formatCurrency({
    required String locale,
    required String currencyCode,
    required num amount,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: currencyCode == 'USD'
          ? 'US\$'
          : currencyCode == 'ARS'
          ? 'AR\$'
          : 'R\$',
      decimalDigits: currencyCode == 'BRL' ? 0 : 2,
    );

    return formatter.format(amount);
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textPrimaryFor(context),
        ),
      ),
    );
  }
}

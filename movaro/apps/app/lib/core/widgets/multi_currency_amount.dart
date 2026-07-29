import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/exchange_rates/exchange_rates_scope.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

/// Renders monetary values in the single currency selected in Settings.
///
/// Domain prices currently use BRL or USD as their reference currency. This
/// widget is the presentation boundary that converts those values with the
/// latest app-wide exchange-rate snapshot.
class MultiCurrencyAmount extends StatelessWidget {
  const MultiCurrencyAmount({
    required this.amountInBrl,
    required this.exchangeRates,
    this.preferredCountryId,
    this.primaryLocale,
    this.compact = false,
    this.wrapSpacing = 8,
    this.runSpacing = 8,
    super.key,
  });

  final num amountInBrl;
  final CopilotExchangeRates? exchangeRates;

  /// Kept for source compatibility. Currency is controlled only by Settings.
  final String? preferredCountryId;
  final String? primaryLocale;
  final bool compact;

  /// Kept for source compatibility with the former expandable selector.
  final double wrapSpacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final label = formatPreferredCurrency(
      context: context,
      amountInBrl: amountInBrl,
      exchangeRates: exchangeRates,
      primaryLocale: primaryLocale,
    );
    return _AmountChip(label: label, compact: compact);
  }

  static String formatCurrency({
    required String locale,
    required String currencyCode,
    required num amount,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: symbolFor(currencyCode),
      decimalDigits: currencyCode == 'USD' ? 2 : 0,
    );
    return formatter.format(amount);
  }

  static String symbolFor(String currencyCode) => switch (currencyCode) {
    'USD' => 'US\$',
    'ARS' => 'AR\$',
    'CLP' => 'CLP\$',
    'BRL' => 'R\$',
    _ => currencyCode,
  };

  static String formatPreferredCurrency({
    required BuildContext context,
    required num amountInBrl,
    required CopilotExchangeRates? exchangeRates,
    String? preferredCountryId,
    String? primaryLocale,
  }) {
    return _formatConverted(
      context: context,
      amount: amountInBrl,
      sourceCurrencyCode: 'BRL',
      exchangeRates: exchangeRates ?? ExchangeRatesScope.ratesOf(context),
    );
  }

  static String formatFromUsd({
    required BuildContext context,
    required num amountInUsd,
    String? preferredCountryId,
  }) {
    return _formatConverted(
      context: context,
      amount: amountInUsd,
      sourceCurrencyCode: 'USD',
      exchangeRates: ExchangeRatesScope.ratesOf(context),
    );
  }

  static String formatAmount({
    required BuildContext context,
    required num amount,
    required String sourceCurrencyCode,
    CopilotExchangeRates? exchangeRates,
  }) {
    return _formatConverted(
      context: context,
      amount: amount,
      sourceCurrencyCode: sourceCurrencyCode,
      exchangeRates: exchangeRates ?? ExchangeRatesScope.ratesOf(context),
    );
  }

  static double? convertToBrl({
    required num amount,
    required String sourceCurrencyCode,
    required CopilotExchangeRates? exchangeRates,
  }) {
    if (sourceCurrencyCode == 'BRL') return amount.toDouble();
    final rates = exchangeRates;
    if (rates == null || !rates.hasValidRates) return null;
    return switch (sourceCurrencyCode) {
      'USD' => amount * rates.usdToBrl,
      'ARS' => amount * rates.arsToBrl,
      'CLP' => amount / rates.brlToClp,
      _ => null,
    };
  }

  static String formatRangeFromUsd({
    required BuildContext context,
    required num minUsd,
    required num maxUsd,
    String? preferredCountryId,
  }) {
    final min = formatFromUsd(context: context, amountInUsd: minUsd);
    final max = formatFromUsd(context: context, amountInUsd: maxUsd);
    if (min.startsWith('—') && max == min) return min;
    return '$min–$max';
  }

  static String formatRangeFromBrl({
    required BuildContext context,
    required num minBrl,
    required num maxBrl,
    CopilotExchangeRates? exchangeRates,
    String? primaryLocale,
  }) {
    final min = formatPreferredCurrency(
      context: context,
      amountInBrl: minBrl,
      exchangeRates: exchangeRates,
      primaryLocale: primaryLocale,
    );
    final max = formatPreferredCurrency(
      context: context,
      amountInBrl: maxBrl,
      exchangeRates: exchangeRates,
      primaryLocale: primaryLocale,
    );
    if (min.startsWith('—') && max == min) return min;
    return '$min–$max';
  }

  static String _formatConverted({
    required BuildContext context,
    required num amount,
    required String sourceCurrencyCode,
    required CopilotExchangeRates? exchangeRates,
  }) {
    final targetCurrencyCode = context.preferredCurrencyCode;
    final converted = _convert(
      amount: amount.toDouble(),
      sourceCurrencyCode: sourceCurrencyCode,
      targetCurrencyCode: targetCurrencyCode,
      rates: exchangeRates,
    );
    if (converted == null) {
      return '— $targetCurrencyCode';
    }

    final rounded = _roundEstimate(converted, currencyCode: targetCurrencyCode);
    return '≈ ${formatCurrency(locale: _localeFor(targetCurrencyCode), currencyCode: targetCurrencyCode, amount: rounded)}';
  }

  static double? _convert({
    required double amount,
    required String sourceCurrencyCode,
    required String targetCurrencyCode,
    required CopilotExchangeRates? rates,
  }) {
    if (sourceCurrencyCode == targetCurrencyCode) return amount;
    if (rates == null || !rates.hasValidRates) return null;

    final amountInBrl = switch (sourceCurrencyCode) {
      'BRL' => amount,
      'USD' => amount * rates.usdToBrl,
      'ARS' => amount * rates.arsToBrl,
      'CLP' => amount / rates.brlToClp,
      'UYU' => amount / rates.brlToUyu,
      _ => null,
    };
    if (amountInBrl == null) return null;

    return switch (targetCurrencyCode) {
      'BRL' => amountInBrl,
      'USD' => amountInBrl * rates.brlToUsd,
      'ARS' => amountInBrl * rates.brlToArs,
      'CLP' => amountInBrl * rates.brlToClp,
      _ => null,
    };
  }

  static String _localeFor(String currencyCode) => switch (currencyCode) {
    'BRL' => 'pt_BR',
    'ARS' => 'es_AR',
    'CLP' => 'es_CL',
    _ => 'en_US',
  };

  static double _roundEstimate(double amount, {required String currencyCode}) {
    final increment = switch (currencyCode) {
      'USD' =>
        amount.abs() < 100
            ? 1
            : amount.abs() < 1000
            ? 5
            : 10,
      'BRL' =>
        amount.abs() < 1000
            ? 10
            : amount.abs() < 5000
            ? 50
            : amount.abs() < 20000
            ? 100
            : 500,
      'ARS' || 'CLP' =>
        amount.abs() < 10000
            ? 100
            : amount.abs() < 100000
            ? 1000
            : 5000,
      _ => 1,
    };
    return (amount / increment).round() * increment.toDouble();
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
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

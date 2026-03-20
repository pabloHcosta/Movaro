import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class MultiCurrencyAmount extends StatefulWidget {
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
  final String? preferredCountryId;
  final String? primaryLocale;
  final bool compact;
  final double wrapSpacing;
  final double runSpacing;

  @override
  State<MultiCurrencyAmount> createState() => _MultiCurrencyAmountState();

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

  static String formatPreferredCurrency({
    required BuildContext context,
    required num amountInBrl,
    required CopilotExchangeRates? exchangeRates,
    String? preferredCountryId,
    String? primaryLocale,
  }) {
    final options = _buildOptions(
      amountInBrl: amountInBrl,
      exchangeRates: exchangeRates,
      fallbackLocale:
          primaryLocale ?? Localizations.localeOf(context).toString(),
      preferredCountryId: preferredCountryId,
    );
    return options.first.label;
  }

  static List<_CurrencyOption> _buildOptions({
    required num amountInBrl,
    required CopilotExchangeRates? exchangeRates,
    required String fallbackLocale,
    String? preferredCountryId,
  }) {
    final optionsByCode = <String, _CurrencyOption>{
      'BRL': _CurrencyOption(
        currencyCode: 'BRL',
        label: _formatCurrency(
          locale: fallbackLocale,
          currencyCode: 'BRL',
          amount: amountInBrl,
        ),
      ),
    };

    if (exchangeRates != null) {
      optionsByCode['USD'] = _CurrencyOption(
        currencyCode: 'USD',
        label: _formatCurrency(
          locale: 'en_US',
          currencyCode: 'USD',
          amount: amountInBrl * exchangeRates.brlToUsd,
        ),
      );
      optionsByCode['ARS'] = _CurrencyOption(
        currencyCode: 'ARS',
        label: _formatCurrency(
          locale: 'es_AR',
          currencyCode: 'ARS',
          amount: amountInBrl * exchangeRates.brlToArs,
        ),
      );
    }

    final localCurrencyCode = _currencyCodeForCountry(preferredCountryId);
    final primaryCode =
        localCurrencyCode != null && optionsByCode.containsKey(localCurrencyCode)
        ? localCurrencyCode
        : optionsByCode.containsKey('USD')
        ? 'USD'
        : 'BRL';

    final orderedCodes = <String>[
      primaryCode,
      if (primaryCode != 'USD' && optionsByCode.containsKey('USD')) 'USD',
      if (primaryCode != 'BRL') 'BRL',
      if (localCurrencyCode != null &&
          localCurrencyCode != primaryCode &&
          localCurrencyCode != 'USD' &&
          localCurrencyCode != 'BRL' &&
          optionsByCode.containsKey(localCurrencyCode))
        localCurrencyCode,
    ];

    return orderedCodes
        .map((code) => optionsByCode[code])
        .whereType<_CurrencyOption>()
        .toList(growable: false);
  }

  static String? _currencyCodeForCountry(String? countryId) {
    switch (countryId?.toLowerCase()) {
      case 'argentina':
        return 'ARS';
      case 'brasil':
      case 'brazil':
        return 'BRL';
      case 'estados_unidos':
      case 'united_states':
      case 'usa':
        return 'USD';
      default:
        return null;
    }
  }

  static String _formatCurrency({
    required String locale,
    required String currencyCode,
    required num amount,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: switch (currencyCode) {
        'USD' => 'US\$',
        'ARS' => 'AR\$',
        'CLP' => 'CLP\$',
        _ => 'R\$',
      },
      decimalDigits: switch (currencyCode) {
        'USD' => 2,
        _ => 0,
      },
    );

    return formatter.format(amount);
  }
}

class _MultiCurrencyAmountState extends State<MultiCurrencyAmount> {
  String? _selectedCurrencyCode;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final options = MultiCurrencyAmount._buildOptions(
      amountInBrl: widget.amountInBrl,
      exchangeRates: widget.exchangeRates,
      fallbackLocale:
          widget.primaryLocale ?? Localizations.localeOf(context).toString(),
      preferredCountryId: widget.preferredCountryId,
    );

    final selected = options.firstWhere(
      (option) => option.currencyCode == _selectedCurrencyCode,
      orElse: () => options.first,
    );
    final selectedCurrencyCode = selected.currencyCode;

    if (options.length == 1) {
      return _AmountChip(
        label: selected.label,
        compact: widget.compact,
        selected: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AmountChip(
                label: selected.label,
                compact: widget.compact,
                selected: true,
              ),
              const SizedBox(width: 6),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: widget.compact ? 16 : 18,
                color: AppColors.textSoftFor(context),
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: widget.compact ? 6 : 8),
          Wrap(
            spacing: widget.wrapSpacing,
            runSpacing: widget.runSpacing,
            children: [
              for (final option in options)
                _AmountChip(
                  label: option.label,
                  compact: widget.compact,
                  selected: option.currencyCode == selectedCurrencyCode,
                  onTap: () {
                    setState(() {
                      _selectedCurrencyCode = option.currencyCode;
                      _isExpanded = false;
                    });
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CurrencyOption {
  const _CurrencyOption({
    required this.currencyCode,
    required this.label,
  });

  final String currencyCode;
  final String label;
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.compact,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.24)
              : AppColors.borderFor(context),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: selected
              ? AppColors.primary
              : AppColors.textPrimaryFor(context),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

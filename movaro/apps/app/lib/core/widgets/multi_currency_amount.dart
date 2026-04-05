import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/exchange_rates/exchange_rates_scope.dart';
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
    final settingsCurrencyCode = CurrencyScope.preferredCodeOf(context);
    // Use scope rates as fallback when no explicit rates are provided.
    final effectiveRates = exchangeRates ?? ExchangeRatesScope.ratesOf(context);
    final options = _buildOptions(
      amountInBrl: amountInBrl,
      exchangeRates: effectiveRates,
      fallbackLocale:
          primaryLocale ?? Localizations.localeOf(context).toString(),
      preferredCountryId: preferredCountryId,
      settingsCurrencyCode: settingsCurrencyCode,
    );
    return options.first.label;
  }

  static List<_CurrencyOption> _buildOptions({
    required num amountInBrl,
    required CopilotExchangeRates? exchangeRates,
    required String fallbackLocale,
    String? preferredCountryId,
    String? settingsCurrencyCode,
  }) {
    final effectiveRates = _EffectiveExchangeRates.resolve(exchangeRates);
    final optionsByCode = <String, _CurrencyOption>{
      'BRL': _CurrencyOption(
        currencyCode: 'BRL',
        label: _formatCurrency(
          locale: fallbackLocale,
          currencyCode: 'BRL',
          amount: amountInBrl,
        ),
      ),
      'USD': _CurrencyOption(
        currencyCode: 'USD',
        label: _formatCurrency(
          locale: 'en_US',
          currencyCode: 'USD',
          amount: amountInBrl * effectiveRates.brlToUsd,
        ),
      ),
      'EUR': _CurrencyOption(
        currencyCode: 'EUR',
        label: _formatCurrency(
          locale: 'en_EU',
          currencyCode: 'EUR',
          amount: amountInBrl * effectiveRates.brlToEur,
        ),
      ),
      'ARS': _CurrencyOption(
        currencyCode: 'ARS',
        label: _formatCurrency(
          locale: 'es_AR',
          currencyCode: 'ARS',
          amount: amountInBrl * effectiveRates.brlToArs,
        ),
      ),
      'CLP': _CurrencyOption(
        currencyCode: 'CLP',
        label: _formatCurrency(
          locale: 'es_CL',
          currencyCode: 'CLP',
          amount: amountInBrl * effectiveRates.brlToClp,
        ),
      ),
      'UYU': _CurrencyOption(
        currencyCode: 'UYU',
        label: _formatCurrency(
          locale: 'es_UY',
          currencyCode: 'UYU',
          amount: amountInBrl * effectiveRates.brlToUyu,
        ),
      ),
      'COP': _CurrencyOption(
        currencyCode: 'COP',
        label: _formatCurrency(
          locale: 'es_CO',
          currencyCode: 'COP',
          amount: amountInBrl * effectiveRates.brlToCop,
        ),
      ),
      'PEN': _CurrencyOption(
        currencyCode: 'PEN',
        label: _formatCurrency(
          locale: 'es_PE',
          currencyCode: 'PEN',
          amount: amountInBrl * effectiveRates.brlToPen,
        ),
      ),
      'PYG': _CurrencyOption(
        currencyCode: 'PYG',
        label: _formatCurrency(
          locale: 'es_PY',
          currencyCode: 'PYG',
          amount: amountInBrl * effectiveRates.brlToPyg,
        ),
      ),
      'BOB': _CurrencyOption(
        currencyCode: 'BOB',
        label: _formatCurrency(
          locale: 'es_BO',
          currencyCode: 'BOB',
          amount: amountInBrl * effectiveRates.brlToBob,
        ),
      ),
    };

    // Priority: explicit settings selection > country-inferred > USD > BRL
    final localCurrencyCode = _currencyCodeForCountry(preferredCountryId);
    final primaryCode =
        settingsCurrencyCode != null &&
            optionsByCode.containsKey(settingsCurrencyCode)
        ? settingsCurrencyCode
        : localCurrencyCode != null &&
            optionsByCode.containsKey(localCurrencyCode)
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
      case 'ar':
        return 'ARS';
      case 'chile':
      case 'cl':
        return 'CLP';
      case 'uruguai':
      case 'uruguay':
      case 'uy':
        return 'UYU';
      case 'colombia':
      case 'co':
        return 'COP';
      case 'peru':
      case 'peru':
      case 'pe':
        return 'PEN';
      case 'paraguai':
      case 'paraguay':
      case 'py':
        return 'PYG';
      case 'bolivia':
      case 'bo':
        return 'BOB';
      case 'brasil':
      case 'brazil':
      case 'br':
        return 'BRL';
      case 'estados_unidos':
      case 'united_states':
      case 'usa':
      case 'us':
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
        'EUR' => '€',
        'ARS' => 'AR\$',
        'CLP' => 'CLP\$',
        'UYU' => 'UYU\$',
        'COP' => 'COP\$',
        'PEN' => 'S/.',
        'PYG' => '₲',
        'BOB' => 'Bs.',
        'BRL' => 'R\$',
        _ => currencyCode,
      },
      decimalDigits: switch (currencyCode) {
        'USD' || 'EUR' || 'PEN' || 'BOB' => 2,
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
    final settingsCurrencyCode = context.preferredCurrencyCode;
    // Use scope rates as fallback when no explicit rates are provided.
    final effectiveRates =
        widget.exchangeRates ?? ExchangeRatesScope.ratesOf(context);
    final options = MultiCurrencyAmount._buildOptions(
      amountInBrl: widget.amountInBrl,
      exchangeRates: effectiveRates,
      fallbackLocale:
          widget.primaryLocale ?? Localizations.localeOf(context).toString(),
      preferredCountryId: widget.preferredCountryId,
      settingsCurrencyCode: settingsCurrencyCode,
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
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _AmountChip(
                label: selected.label,
                compact: widget.compact,
                selected: true,
              ),
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
  const _CurrencyOption({required this.currencyCode, required this.label});

  final String currencyCode;
  final String label;
}

class _EffectiveExchangeRates {
  const _EffectiveExchangeRates({
    required this.brlToUsd,
    required this.brlToEur,
    required this.brlToArs,
    required this.brlToClp,
    required this.brlToUyu,
    required this.brlToCop,
    required this.brlToPen,
    required this.brlToPyg,
    required this.brlToBob,
  });

  final double brlToUsd;
  final double brlToEur;
  final double brlToArs;
  final double brlToClp;
  final double brlToUyu;
  final double brlToCop;
  final double brlToPen;
  final double brlToPyg;
  final double brlToBob;

  static const _fallback = _EffectiveExchangeRates(
    brlToUsd: 0.20,
    brlToEur: 0.18,
    brlToArs: 190.0,
    brlToClp: 185.0,
    brlToUyu: 8.2,
    brlToCop: 840.0,
    brlToPen: 0.75,
    brlToPyg: 1560.0,
    brlToBob: 1.38,
  );

  static _EffectiveExchangeRates resolve(CopilotExchangeRates? liveRates) {
    if (liveRates == null) {
      return _fallback;
    }
    return _EffectiveExchangeRates(
      brlToUsd: liveRates.brlToUsd,
      brlToEur: liveRates.brlToEur,
      brlToArs: liveRates.brlToArs,
      brlToClp: liveRates.brlToClp,
      brlToUyu: liveRates.brlToUyu,
      brlToCop: liveRates.brlToCop,
      brlToPen: liveRates.brlToPen,
      brlToPyg: liveRates.brlToPyg,
      brlToBob: liveRates.brlToBob,
    );
  }
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

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

enum _HousingGuaranteeMode { deposit, insurance, temporary }

class HousingEntryCostSection extends StatefulWidget {
  const HousingEntryCostSection({
    required this.exchangeRatesService,
    this.cityName,
    this.preferredCountryId,
    super.key,
  });

  final CopilotExchangeRatesService exchangeRatesService;
  final String? cityName;
  final String? preferredCountryId;

  @override
  State<HousingEntryCostSection> createState() =>
      _HousingEntryCostSectionState();
}

class _HousingEntryCostSectionState extends State<HousingEntryCostSection> {
  double _monthlyRent = 2000;
  _HousingGuaranteeMode _mode = _HousingGuaranteeMode.deposit;
  late final Future<CopilotExchangeRates?> _exchangeRatesFuture;

  @override
  void initState() {
    super.initState();
    _exchangeRatesFuture = widget.exchangeRatesService.fetchLatest();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final breakdown = _estimate(_monthlyRent, _mode);

    return FutureBuilder<CopilotExchangeRates?>(
      future: _exchangeRatesFuture,
      builder: (context, snapshot) {
        final exchangeRates = snapshot.data;

        return FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cityName == null
                    ? l10n.housingEntrySectionTitle
                    : l10n.housingEntrySectionTitleWithCity(widget.cityName!),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                widget.cityName == null
                    ? l10n.housingEntrySectionBody
                    : l10n.housingEntrySectionBodyWithCity(widget.cityName!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              MultiCurrencyAmount(
                amountInBrl: _monthlyRent,
                exchangeRates: exchangeRates,
                preferredCountryId: widget.preferredCountryId,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.housingEntryRentLabel(
                  MultiCurrencyAmount.formatPreferredCurrency(
                    context: context,
                    amountInBrl: _monthlyRent,
                    exchangeRates: exchangeRates,
                    preferredCountryId: widget.preferredCountryId,
                  ),
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
              Slider(
                value: _monthlyRent,
                min: 1200,
                max: 5000,
                divisions: 19,
                label: MultiCurrencyAmount.formatPreferredCurrency(
                  context: context,
                  amountInBrl: _monthlyRent,
                  exchangeRates: exchangeRates,
                  preferredCountryId: widget.preferredCountryId,
                ),
                onChanged: (value) => setState(() => _monthlyRent = value),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ModeChip(
                    selected: _mode == _HousingGuaranteeMode.deposit,
                    label: l10n.housingEntryModeDeposit,
                    onTap: () =>
                        setState(() => _mode = _HousingGuaranteeMode.deposit),
                  ),
                  _ModeChip(
                    selected: _mode == _HousingGuaranteeMode.insurance,
                    label: l10n.housingEntryModeInsurance,
                    onTap: () =>
                        setState(() => _mode = _HousingGuaranteeMode.insurance),
                  ),
                  _ModeChip(
                    selected: _mode == _HousingGuaranteeMode.temporary,
                    label: l10n.housingEntryModeTemporary,
                    onTap: () =>
                        setState(() => _mode = _HousingGuaranteeMode.temporary),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final cardWidth = wide
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _BreakdownCard(
                          title: l10n.housingEntryTotalTitle,
                          amountInBrl: breakdown.total,
                          exchangeRates: exchangeRates,
                          preferredCountryId: widget.preferredCountryId,
                          description: _modeDescription(context, _mode),
                          lines: [
                            _BreakdownLine(
                              l10n.housingEntryFirstMonthLabel,
                              breakdown.firstMonth,
                            ),
                            _BreakdownLine(
                              l10n.housingEntryGuaranteeLabel,
                              breakdown.guarantee,
                            ),
                            _BreakdownLine(
                              l10n.housingEntrySetupLabel,
                              breakdown.setup,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _BreakdownCard(
                          title: l10n.housingEntryPlatformsTitle,
                          headlineText: l10n.housingEntryPlatformsHeadline,
                          description: l10n.housingEntryPlatformsBody,
                          preferredCountryId: widget.preferredCountryId,
                          lines: [
                            _BreakdownLine.text(
                              'QuintoAndar',
                              l10n.housingEntryPlatformsQuintoAndar,
                            ),
                            _BreakdownLine.text(
                              'ZAP / VivaReal',
                              l10n.housingEntryPlatformsZap,
                            ),
                            _BreakdownLine.text(
                              'CredPago',
                              l10n.housingEntryPlatformsCredPago,
                            ),
                            _BreakdownLine.text(
                              'Airbnb / Booking',
                              l10n.housingEntryPlatformsAirbnb,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Text(
                l10n.housingEntryDisclaimer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _HousingEntryBreakdown _estimate(
    double monthlyRent,
    _HousingGuaranteeMode mode,
  ) {
    switch (mode) {
      case _HousingGuaranteeMode.deposit:
        return _HousingEntryBreakdown(
          firstMonth: monthlyRent,
          guarantee: monthlyRent * 3,
          setup: monthlyRent * 0.25,
        );
      case _HousingGuaranteeMode.insurance:
        return _HousingEntryBreakdown(
          firstMonth: monthlyRent,
          guarantee: monthlyRent * 1.2,
          setup: monthlyRent * 0.20,
        );
      case _HousingGuaranteeMode.temporary:
        return _HousingEntryBreakdown(
          firstMonth: monthlyRent * 1.25,
          guarantee: 0,
          setup: monthlyRent * 0.35,
        );
    }
  }

  String _modeDescription(BuildContext context, _HousingGuaranteeMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case _HousingGuaranteeMode.deposit:
        return l10n.housingEntryModeDepositBody;
      case _HousingGuaranteeMode.insurance:
        return l10n.housingEntryModeInsuranceBody;
      case _HousingGuaranteeMode.temporary:
        return l10n.housingEntryModeTemporaryBody;
    }
  }
}

class _HousingEntryBreakdown {
  const _HousingEntryBreakdown({
    required this.firstMonth,
    required this.guarantee,
    required this.setup,
  });

  final double firstMonth;
  final double guarantee;
  final double setup;

  double get total => firstMonth + guarantee + setup;
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.14)
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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected
                ? AppColors.primary
                : AppColors.textPrimaryFor(context),
          ),
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.description,
    required this.lines,
    required this.preferredCountryId,
    this.amountInBrl,
    this.exchangeRates,
    this.headlineText,
  });

  final String title;
  final double? amountInBrl;
  final CopilotExchangeRates? exchangeRates;
  final String? preferredCountryId;
  final String? headlineText;
  final String description;
  final List<_BreakdownLine> lines;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          if (amountInBrl != null) ...[
            Text(
              MultiCurrencyAmount.formatPreferredCurrency(
                context: context,
                amountInBrl: amountInBrl!,
                exchangeRates: exchangeRates,
                preferredCountryId: preferredCountryId,
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
              ),
            ),
            const SizedBox(height: 8),
            MultiCurrencyAmount(
              amountInBrl: amountInBrl!,
              exchangeRates: exchangeRates,
              preferredCountryId: preferredCountryId,
            ),
          ] else if (headlineText != null) ...[
            Text(
              headlineText!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          for (final line in lines) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    line.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: line.amountInBrl == null
                      ? Text(
                          line.textValue ?? '',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textPrimaryFor(context),
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: MultiCurrencyAmount(
                            amountInBrl: line.amountInBrl!,
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
            if (line != lines.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _BreakdownLine {
  const _BreakdownLine(this.label, this.amountInBrl) : textValue = null;

  const _BreakdownLine.text(this.label, this.textValue) : amountInBrl = null;

  final String label;
  final double? amountInBrl;
  final String? textValue;
}

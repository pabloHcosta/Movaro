import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

enum _HousingGuaranteeMode { deposit, insurance, temporary }

class HousingEntryCostSection extends StatefulWidget {
  const HousingEntryCostSection({
    this.cityName,
    super.key,
  });

  final String? cityName;

  @override
  State<HousingEntryCostSection> createState() => _HousingEntryCostSectionState();
}

class _HousingEntryCostSectionState extends State<HousingEntryCostSection> {
  double _monthlyRent = 2000;
  _HousingGuaranteeMode _mode = _HousingGuaranteeMode.deposit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final breakdown = _estimate(_monthlyRent, _mode);
    final locale = Localizations.localeOf(context).toString();

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
          Text(
            l10n.housingEntryRentLabel(_formatCurrency(locale, _monthlyRent)),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          Slider(
            value: _monthlyRent,
            min: 1200,
            max: 5000,
            divisions: 19,
            label: _formatCurrency(locale, _monthlyRent),
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
                onTap: () => setState(() => _mode = _HousingGuaranteeMode.deposit),
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
                      headline: _formatCurrency(locale, breakdown.total),
                      description: _modeDescription(context, _mode),
                      lines: [
                        _BreakdownLine(
                          l10n.housingEntryFirstMonthLabel,
                          _formatCurrency(locale, breakdown.firstMonth),
                        ),
                        _BreakdownLine(
                          l10n.housingEntryGuaranteeLabel,
                          _formatCurrency(locale, breakdown.guarantee),
                        ),
                        _BreakdownLine(
                          l10n.housingEntrySetupLabel,
                          _formatCurrency(locale, breakdown.setup),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _BreakdownCard(
                      title: l10n.housingEntryPlatformsTitle,
                      headline: l10n.housingEntryPlatformsHeadline,
                      description: l10n.housingEntryPlatformsBody,
                      lines: [
                        _BreakdownLine(
                          'QuintoAndar',
                          l10n.housingEntryPlatformsQuintoAndar,
                        ),
                        _BreakdownLine(
                          'ZAP / VivaReal',
                          l10n.housingEntryPlatformsZap,
                        ),
                        _BreakdownLine(
                          'CredPago',
                          l10n.housingEntryPlatformsCredPago,
                        ),
                        _BreakdownLine(
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
  }

  _HousingEntryBreakdown _estimate(double monthlyRent, _HousingGuaranteeMode mode) {
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

  String _formatCurrency(String locale, num amount) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: 'BRL',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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
    required this.headline,
    required this.description,
    required this.lines,
  });

  final String title;
  final String headline;
  final String description;
  final List<_BreakdownLine> lines;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.isDark(context)
          ? const Color(0xCC111927)
          : Colors.white.withValues(alpha: 0.68),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Text(
            headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
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
                  child: Text(
                    line.value,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w600,
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
  const _BreakdownLine(this.label, this.value);

  final String label;
  final String value;
}

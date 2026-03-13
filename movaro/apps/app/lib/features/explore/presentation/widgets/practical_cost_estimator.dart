import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class PracticalCostEstimator extends StatefulWidget {
  const PracticalCostEstimator({super.key});

  @override
  State<PracticalCostEstimator> createState() => _PracticalCostEstimatorState();
}

class _PracticalCostEstimatorState extends State<PracticalCostEstimator> {
  late final Future<_ExchangeSnapshot> _exchangeFuture;

  @override
  void initState() {
    super.initState();
    _exchangeFuture = _ExchangeRateService().fetch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FutureBuilder<_ExchangeSnapshot>(
      future: _exchangeFuture,
      builder: (context, snapshot) {
        final exchange = snapshot.data;
        final hasExchange = exchange != null;
        final items = _items(context);

        return FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.documentationCostsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.documentationCostsBody,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textSoft),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  hasExchange
                      ? l10n.documentationCostsUpdatedAt(
                          _formatUpdatedAt(context, exchange.updatedAt),
                        )
                      : l10n.documentationCostsUnavailable,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSoft),
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
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
                      for (final item in items)
                        SizedBox(
                          width: cardWidth,
                          child: _CostItemCard(item: item, exchange: exchange),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.documentationCostsDisclaimer,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: textSoft),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CostItem> _items(BuildContext context) {
    final l10n = context.l10n;

    return [
      _CostItem(
        icon: Icons.badge_outlined,
        title: l10n.documentationCostCpfTitle,
        headline: l10n.documentationCostFreeValue,
        amountInBrl: 0,
        supporting: l10n.documentationCostCpfSupporting,
      ),
      _CostItem(
        icon: Icons.health_and_safety_outlined,
        title: l10n.documentationCostSusCardTitle,
        headline: l10n.documentationCostFreeValue,
        amountInBrl: 0,
        supporting: l10n.documentationCostSusCardSupporting,
      ),
      _CostItem(
        icon: Icons.local_hospital_outlined,
        title: l10n.documentationCostPublicCareTitle,
        headline: l10n.documentationCostFreeValue,
        amountInBrl: 0,
        supporting: l10n.documentationCostPublicCareSupporting,
      ),
      _CostItem(
        icon: Icons.directions_car_outlined,
        title: l10n.documentationCostDrivingTitle,
        headline: l10n.documentationCostDrivingValue,
        amountInBrl: 533.34,
        supporting: l10n.documentationCostDrivingSupporting,
      ),
      _CostItem(
        icon: Icons.favorite_outline_rounded,
        title: l10n.documentationCostPrivateHealthTitle,
        headline: l10n.documentationCostVariableValue,
        supporting: l10n.documentationCostPrivateHealthSupporting,
      ),
    ];
  }

  String _formatUpdatedAt(BuildContext context, DateTime value) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat('dd/MM HH:mm', localeName).format(value);
  }
}

class _CostItemCard extends StatelessWidget {
  const _CostItemCard({required this.item, required this.exchange});

  final _CostItem item;
  final _ExchangeSnapshot? exchange;

  @override
  Widget build(BuildContext context) {
    final hasRates = exchange != null && item.amountInBrl != null;
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: textPrimary),
          ),
          const SizedBox(height: 14),
          Text(item.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            item.headline,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            item.supporting,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
          if (hasRates) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AmountChip(
                  label: _formatCurrency(
                    locale: Localizations.localeOf(context).toString(),
                    currencyCode: 'BRL',
                    amount: item.amountInBrl!,
                  ),
                ),
                _AmountChip(
                  label: _formatCurrency(
                    locale: 'en_US',
                    currencyCode: 'USD',
                    amount: item.amountInBrl! / exchange!.usdToBrl,
                  ),
                ),
                _AmountChip(
                  label: _formatCurrency(
                    locale: 'es_AR',
                    currencyCode: 'ARS',
                    amount: item.amountInBrl! / exchange!.arsToBrl,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency({
    required String locale,
    required String currencyCode,
    required double amount,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: currencyCode == 'USD'
          ? 'US\$'
          : currencyCode == 'ARS'
          ? 'AR\$'
          : 'R\$',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );

    return formatter.format(amount);
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _CostItem {
  const _CostItem({
    required this.icon,
    required this.title,
    required this.headline,
    required this.supporting,
    this.amountInBrl,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String supporting;
  final double? amountInBrl;
}

class _ExchangeSnapshot {
  const _ExchangeSnapshot({
    required this.usdToBrl,
    required this.arsToBrl,
    required this.updatedAt,
  });

  final double usdToBrl;
  final double arsToBrl;
  final DateTime updatedAt;
}

class _ExchangeRateService {
  static final Uri _uri = Uri.parse(
    'https://economia.awesomeapi.com.br/json/last/USD-BRL,ARS-BRL',
  );

  Future<_ExchangeSnapshot> fetch() async {
    final response = await http.get(_uri).timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load exchange rates');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final usd =
        decoded['USDBRL'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final ars =
        decoded['ARSBRL'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    final usdBid = double.parse(usd['bid'] as String);
    final arsBid = double.parse(ars['bid'] as String);
    final updatedAt = DateTime.parse(usd['create_date'] as String);

    return _ExchangeSnapshot(
      usdToBrl: usdBid,
      arsToBrl: arsBid,
      updatedAt: updatedAt,
    );
  }
}

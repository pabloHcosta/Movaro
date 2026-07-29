import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class PracticalCostEstimator extends StatefulWidget {
  const PracticalCostEstimator({
    required this.exchangeRatesService,
    this.preferredCountryId,
    super.key,
  });

  final CopilotExchangeRatesService exchangeRatesService;
  final String? preferredCountryId;

  @override
  State<PracticalCostEstimator> createState() => _PracticalCostEstimatorState();
}

class _PracticalCostEstimatorState extends State<PracticalCostEstimator> {
  late final Future<CopilotExchangeRates?> _exchangeFuture;

  @override
  void initState() {
    super.initState();
    _exchangeFuture = widget.exchangeRatesService.fetchLatest();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FutureBuilder<CopilotExchangeRates?>(
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
                      ? _exchangeStatus(context, exchange)
                      : _localizedText(
                          context,
                          pt: 'Conversão indisponível agora · valores convertidos ficam ocultos, sem usar cotação antiga',
                          es: 'Conversión no disponible ahora · los valores convertidos se ocultan, sin usar una cotización antigua',
                          en: 'Conversion unavailable now · converted values stay hidden instead of using an old rate',
                        ),
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
                          child: _CostItemCard(
                            item: item,
                            exchange: exchange,
                            preferredCountryId: widget.preferredCountryId,
                          ),
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
        supporting: _localizedText(
          context,
          pt: 'Referência recente do Detran-ES. Seu estado e sua autoescola podem cobrar valores diferentes.',
          es: 'Referencia reciente del Detran-ES. Tu estado y tu autoescuela pueden cobrar distinto.',
          en: 'Recent Detran-ES reference. Your state and driving school may charge differently.',
        ),
      ),
      _CostItem(
        icon: Icons.favorite_outline_rounded,
        title: l10n.documentationCostPrivateHealthTitle,
        headline: l10n.documentationCostVariableValue,
        supporting: l10n.documentationCostPrivateHealthSupporting,
      ),
    ];
  }

  String _formatUpdatedAt(BuildContext context, String rawValue) {
    final localeName = Localizations.localeOf(context).toString();
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    final pattern = rawValue.contains('T') ? 'dd/MM HH:mm' : 'dd/MM/yyyy';
    return DateFormat(pattern, localeName).format(parsed.toLocal());
  }

  String _exchangeStatus(BuildContext context, CopilotExchangeRates exchange) {
    final reference = exchange.referenceDate ?? exchange.fetchedAt;
    return _localizedText(
      context,
      pt: 'Câmbio indicativo BCB + BCRA · referência ${_formatUpdatedAt(context, reference)} · valores arredondados',
      es: 'Cambio indicativo BCB + BCRA · referencia ${_formatUpdatedAt(context, reference)} · valores redondeados',
      en: 'Indicative BCB + BCRA exchange · reference ${_formatUpdatedAt(context, reference)} · rounded values',
    );
  }

  String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}

class _CostItemCard extends StatelessWidget {
  const _CostItemCard({
    required this.item,
    required this.exchange,
    required this.preferredCountryId,
  });

  final _CostItem item;
  final CopilotExchangeRates? exchange;
  final String? preferredCountryId;

  @override
  Widget build(BuildContext context) {
    final hasAmount = item.amountInBrl != null;
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
          if (hasAmount) ...[
            const SizedBox(height: 14),
            MultiCurrencyAmount(
              amountInBrl: item.amountInBrl!,
              exchangeRates: exchange,
              preferredCountryId: preferredCountryId,
            ),
          ],
        ],
      ),
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

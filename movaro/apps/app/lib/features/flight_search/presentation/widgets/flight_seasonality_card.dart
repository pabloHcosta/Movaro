import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

enum _PriceLevel { low, mid, high }

class _RouteData {
  const _RouteData({
    required this.originIata,
    required this.destIata,
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarning,
  });

  final String originIata;
  final String destIata;
  final List<_PriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarning;
}

class _DestinationSeasonalityProfile {
  const _DestinationSeasonalityProfile({
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarning,
  });

  final List<_PriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarning;
}

class _OriginPriceAdjustment {
  const _OriginPriceAdjustment({
    required this.lowMinDelta,
    required this.lowMaxDelta,
  });

  final int lowMinDelta;
  final int lowMaxDelta;
}

class _FlightSeasonalityCatalog {
  const _FlightSeasonalityCatalog._();

  static const Map<String, String> originHub = {
    'AR': 'EZE',
    'CL': 'SCL',
    'UY': 'MVD',
    'PY': 'ASU',
  };

  static const Map<String, String> cityToIata = {
    'florianopolis-sc': 'FLN',
    'balneario-camboriu-sc': 'NVT',
    'itajai-sc': 'NVT',
    'joinville-sc': 'NVT',
    'blumenau-sc': 'NVT',
    'sao-paulo-sp': 'GRU',
    'curitiba-pr': 'CWB',
    'rio-de-janeiro-rj': 'GIG',
    'armacao-dos-buzios-rj': 'GIG',
    'porto-alegre-rs': 'POA',
    'belo-horizonte-mg': 'CNF',
    'salvador-ba': 'SSA',
    'recife-pe': 'REC',
    'fortaleza-ce': 'FOR',
    'natal-rn': 'NAT',
    'joao-pessoa-pb': 'JPA',
    'aracaju-se': 'AJU',
    'maceio-al': 'MCZ',
    'campo-grande-ms': 'CGR',
    'manaus-am': 'MAO',
    'belem-pa': 'BEL',
  };

  static const monthLabels = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  static const _defaultMonths = [
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.mid,
    _PriceLevel.high,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.high,
  ];

  static const _coastalSouthMonths = [
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.mid,
    _PriceLevel.mid,
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.high,
  ];

  static const _northeastMonths = [
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.mid,
    _PriceLevel.mid,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.high,
  ];

  static const _northMonths = [
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.high,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.mid,
    _PriceLevel.mid,
    _PriceLevel.low,
    _PriceLevel.low,
    _PriceLevel.mid,
    _PriceLevel.high,
  ];

  static const Map<String, _DestinationSeasonalityProfile>
  destinationProfiles = {
    'GRU': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 133,
      lowUsdMax: 160,
    ),
    'FLN': _DestinationSeasonalityProfile(
      months: _coastalSouthMonths,
      lowUsdMin: 150,
      lowUsdMax: 200,
      seasonalWarning:
          'Floripa costuma ter menos voos diretos fora de mar-abr. Em outros meses, conexoes via SP ou POA sao comuns.',
    ),
    'NVT': _DestinationSeasonalityProfile(
      months: _coastalSouthMonths,
      lowUsdMin: 160,
      lowUsdMax: 210,
      seasonalWarning:
          'Navegantes atende Balneario, Itajai e Blumenau. Em parte do ano, a melhor tarifa aparece com conexao curta em SP.',
    ),
    'CWB': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 170,
      lowUsdMax: 250,
    ),
    'GIG': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 150,
      lowUsdMax: 220,
      seasonalWarning:
          'Fev costuma concentrar alta forte no Rio por conta do Carnaval. Se essa janela fizer sentido, vale monitorar cedo.',
    ),
    'POA': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 140,
      lowUsdMax: 190,
    ),
    'CNF': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 175,
      lowUsdMax: 240,
    ),
    'SSA': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 200,
      lowUsdMax: 280,
    ),
    'REC': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 210,
      lowUsdMax: 290,
    ),
    'FOR': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 210,
      lowUsdMax: 300,
    ),
    'NAT': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 220,
      lowUsdMax: 310,
    ),
    'JPA': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 215,
      lowUsdMax: 295,
    ),
    'AJU': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 205,
      lowUsdMax: 285,
    ),
    'MCZ': _DestinationSeasonalityProfile(
      months: _northeastMonths,
      lowUsdMin: 215,
      lowUsdMax: 300,
    ),
    'CGR': _DestinationSeasonalityProfile(
      months: _defaultMonths,
      lowUsdMin: 165,
      lowUsdMax: 235,
    ),
    'MAO': _DestinationSeasonalityProfile(
      months: _northMonths,
      lowUsdMin: 260,
      lowUsdMax: 360,
      seasonalWarning:
          'Manaus costuma variar mais por conexoes e oferta. Comparar alguns dias ao redor da data ajuda bastante.',
    ),
    'BEL': _DestinationSeasonalityProfile(
      months: _northMonths,
      lowUsdMin: 250,
      lowUsdMax: 340,
      seasonalWarning:
          'Belem tende a oscilar bastante entre conexoes e horarios. Vale abrir a busca ao vivo com alguma flexibilidade.',
    ),
  };

  static const Map<String, _OriginPriceAdjustment> originAdjustments = {
    'EZE': _OriginPriceAdjustment(lowMinDelta: 0, lowMaxDelta: 0),
    'AEP': _OriginPriceAdjustment(lowMinDelta: 5, lowMaxDelta: 10),
    'COR': _OriginPriceAdjustment(lowMinDelta: 8, lowMaxDelta: 15),
    'ROS': _OriginPriceAdjustment(lowMinDelta: 10, lowMaxDelta: 18),
    'MDZ': _OriginPriceAdjustment(lowMinDelta: 12, lowMaxDelta: 20),
    'NQN': _OriginPriceAdjustment(lowMinDelta: 18, lowMaxDelta: 26),
    'MDQ': _OriginPriceAdjustment(lowMinDelta: 15, lowMaxDelta: 22),
    'BRC': _OriginPriceAdjustment(lowMinDelta: 22, lowMaxDelta: 34),
    'SLA': _OriginPriceAdjustment(lowMinDelta: 18, lowMaxDelta: 30),
    'TUC': _OriginPriceAdjustment(lowMinDelta: 18, lowMaxDelta: 28),
    'JUJ': _OriginPriceAdjustment(lowMinDelta: 22, lowMaxDelta: 34),
    'PSS': _OriginPriceAdjustment(lowMinDelta: 14, lowMaxDelta: 24),
    'RES': _OriginPriceAdjustment(lowMinDelta: 14, lowMaxDelta: 24),
    'UAQ': _OriginPriceAdjustment(lowMinDelta: 18, lowMaxDelta: 28),
    'REL': _OriginPriceAdjustment(lowMinDelta: 28, lowMaxDelta: 42),
    'CRD': _OriginPriceAdjustment(lowMinDelta: 28, lowMaxDelta: 42),
    'FTE': _OriginPriceAdjustment(lowMinDelta: 40, lowMaxDelta: 60),
    'RGL': _OriginPriceAdjustment(lowMinDelta: 42, lowMaxDelta: 62),
    'USH': _OriginPriceAdjustment(lowMinDelta: 48, lowMaxDelta: 70),
    'SCL': _OriginPriceAdjustment(lowMinDelta: 10, lowMaxDelta: 20),
    'MVD': _OriginPriceAdjustment(lowMinDelta: 8, lowMaxDelta: 18),
    'ASU': _OriginPriceAdjustment(lowMinDelta: 10, lowMaxDelta: 20),
  };

  static _RouteData? resolveRoute({
    required String? originIata,
    required String? destIata,
  }) {
    if (originIata == null || destIata == null) {
      return null;
    }
    final destinationProfile = destinationProfiles[destIata.toUpperCase()];
    final originAdjustment = originAdjustments[originIata.toUpperCase()];
    if (destinationProfile == null || originAdjustment == null) {
      return null;
    }
    return _RouteData(
      originIata: originIata.toUpperCase(),
      destIata: destIata.toUpperCase(),
      months: destinationProfile.months,
      lowUsdMin: destinationProfile.lowUsdMin + originAdjustment.lowMinDelta,
      lowUsdMax: destinationProfile.lowUsdMax + originAdjustment.lowMaxDelta,
      seasonalWarning: destinationProfile.seasonalWarning,
    );
  }

  static List<String> cheapMonths(_RouteData data) => [
    for (var i = 0; i < data.months.length; i++)
      if (data.months[i] == _PriceLevel.low) monthLabels[i],
  ];
}

class FlightSeasonalityCard extends StatelessWidget {
  const FlightSeasonalityCard({
    required this.originCountryIso,
    this.originIata,
    this.cityId,
    this.destIata,
    super.key,
  });

  final String originCountryIso;
  final String? originIata;
  final String? cityId;
  final String? destIata;

  String? get _resolvedOriginIata {
    if (originIata != null && originIata!.isNotEmpty) {
      return originIata!.toUpperCase();
    }
    return _FlightSeasonalityCatalog.originHub[originCountryIso.toUpperCase()];
  }

  String? get _resolvedDestIata {
    if (destIata != null && destIata!.isNotEmpty) {
      return destIata!.toUpperCase();
    }
    if (cityId != null) {
      return _FlightSeasonalityCatalog.cityToIata[cityId!];
    }
    return null;
  }

  _RouteData? get _route => _FlightSeasonalityCatalog.resolveRoute(
    originIata: _resolvedOriginIata,
    destIata: _resolvedDestIata,
  );

  @override
  Widget build(BuildContext context) {
    final originIata = _resolvedOriginIata;
    final destinationIata = _resolvedDestIata;
    if (originIata == null || destinationIata == null) {
      return const SizedBox.shrink();
    }

    final data = _route;
    final cheapMonths = data == null
        ? const <String>[]
        : _FlightSeasonalityCatalog.cheapMonths(data);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Melhor epoca para voar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$originIata -> $destinationIata · Faixas historicas (USD)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 16),
          if (data != null) ...[
            _MonthBarChart(months: data.months),
            const SizedBox(height: 12),
            _PriceLegend(lowMin: data.lowUsdMin, lowMax: data.lowUsdMax),
            const SizedBox(height: 12),
            if (cheapMonths.isNotEmpty)
              _InfoCallout(
                icon: Icons.savings_outlined,
                color: AppColors.success,
                text:
                    'Mais barato: ${cheapMonths.join(', ')} · Ate 40% de economia',
              ),
            if (data.seasonalWarning != null) ...[
              const SizedBox(height: 8),
              _InfoCallout(
                icon: Icons.info_outline_rounded,
                color: AppColors.caution,
                text: data.seasonalWarning!,
              ),
            ],
          ] else
            _InfoCallout(
              icon: Icons.insights_outlined,
              color: AppColors.primary,
              text:
                  'Ainda nao temos historico suficiente para essa rota exata. Use a busca ao vivo abaixo para ver a combinacao real entre origem e destino.',
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _openSkyscanner(context, originIata, destinationIata),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(
                'Ver precos ao vivo  $originIata -> $destinationIata',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Faixas historicas · Precos reais variam conforme a data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSkyscanner(BuildContext context, String origin, String dest) {
    final uri = Uri.parse(
      'https://www.skyscanner.com/transport/flights/'
      '${origin.toLowerCase()}/${dest.toLowerCase()}/'
      '?adults=1&cabinclass=economy&currency=USD',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(
          title: 'Passagens $origin -> $dest',
          uri: uri,
        ),
      ),
    );
  }
}

class _MonthBarChart extends StatelessWidget {
  const _MonthBarChart({required this.months});

  final List<_PriceLevel> months;

  static const _labels = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  Color _barColor(_PriceLevel level) => switch (level) {
    _PriceLevel.low => AppColors.success,
    _PriceLevel.mid => AppColors.warning,
    _PriceLevel.high => AppColors.danger,
  };

  double _barHeight(_PriceLevel level) => switch (level) {
    _PriceLevel.low => 22.0,
    _PriceLevel.mid => 36.0,
    _PriceLevel.high => 50.0,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final level = months[i];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: _barHeight(level),
                    decoration: BoxDecoration(
                      color: _barColor(level).withValues(alpha: 0.70),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _labels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      height: 1,
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PriceLegend extends StatelessWidget {
  const _PriceLegend({required this.lowMin, required this.lowMax});

  final int lowMin;
  final int lowMax;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(
          color: AppColors.success,
          label: 'Barato (\$$lowMin-\$$lowMax)',
        ),
        const _LegendDot(color: AppColors.warning, label: 'Medio'),
        const _LegendDot(color: AppColors.danger, label: 'Caro'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSoftFor(context),
          ),
        ),
      ],
    );
  }
}

class _InfoCallout extends StatelessWidget {
  const _InfoCallout({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightPriceBadge extends StatelessWidget {
  const FlightPriceBadge({
    required this.originCountryIso,
    this.originIata,
    this.cityId,
    this.destIata,
    super.key,
  });

  final String originCountryIso;
  final String? originIata;
  final String? cityId;
  final String? destIata;

  String? get _resolvedOrigin {
    if (originIata != null && originIata!.isNotEmpty) {
      return originIata!.toUpperCase();
    }
    return _FlightSeasonalityCatalog.originHub[originCountryIso.toUpperCase()];
  }

  String? get _resolvedDest {
    if (destIata != null && destIata!.isNotEmpty) {
      return destIata!.toUpperCase();
    }
    if (cityId != null) {
      return _FlightSeasonalityCatalog.cityToIata[cityId!];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final route = _FlightSeasonalityCatalog.resolveRoute(
      originIata: _resolvedOrigin,
      destIata: _resolvedDest,
    );
    if (route == null) {
      return const SizedBox.shrink();
    }
    final bestMonths = _FlightSeasonalityCatalog.cheapMonths(
      route,
    ).take(4).join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flight_takeoff_rounded,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
                children: [
                  const TextSpan(text: 'Passagem: '),
                  TextSpan(
                    text: 'a partir de \$${route.lowUsdMin} USD',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '  ·  Mais barato: '),
                  TextSpan(
                    text: bestMonths,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

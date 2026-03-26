import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum _PriceLevel { low, mid, high }

class _RouteData {
  const _RouteData({
    required this.originIata,
    required this.destIata,
    required this.months, // 12 elements, Jan–Dec
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarning,
  });

  final String originIata;
  final String destIata;
  final List<_PriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;

  /// Optional one-line warning shown below the chart (e.g. seasonal routes).
  final String? seasonalWarning;
}

// ── Main widget ───────────────────────────────────────────────────────────────

/// Static flight-price seasonality chart for Buenos Aires → Brazilian cities.
///
/// Shows which months are cheapest based on historical data (no API).
/// Includes a Skyscanner deep-link to browse live prices.
class FlightSeasonalityCard extends StatelessWidget {
  const FlightSeasonalityCard({
    required this.originCountryIso,
    this.cityId,
    this.destIata,
    super.key,
  });

  /// ISO country code of the origin (e.g. 'AR').
  final String originCountryIso;

  /// Movaro city ID (e.g. 'florianopolis-sc'). Used when [destIata] is null.
  final String? cityId;

  /// Explicit destination IATA code. Takes precedence over [cityId] lookup.
  final String? destIata;

  // ── Static data ─────────────────────────────────────────────────────────────

  static const Map<String, String> _originHub = {
    'AR': 'EZE',
    'CL': 'SCL',
    'UY': 'MVD',
    'PY': 'ASU',
  };

  static const Map<String, String> _cityToIata = {
    'florianopolis-sc': 'FLN',
    'balneario-camboriu-sc': 'FLN',
    'itajai-sc': 'FLN',
    'joinville-sc': 'FLN',
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

  // months list = Jan … Dec  (12 elements)
  static final Map<String, _RouteData> _routes = {
    'EZE:GRU': _RouteData(
      originIata: 'EZE',
      destIata: 'GRU',
      months: [
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
      ],
      lowUsdMin: 133,
      lowUsdMax: 160,
    ),
    'EZE:FLN': _RouteData(
      originIata: 'EZE',
      destIata: 'FLN',
      months: [
        _PriceLevel.high,
        _PriceLevel.high,
        _PriceLevel.low,
        _PriceLevel.low,
        _PriceLevel.high,
        _PriceLevel.high,
        _PriceLevel.high,
        _PriceLevel.high,
        _PriceLevel.low,
        _PriceLevel.low,
        _PriceLevel.low,
        _PriceLevel.high,
      ],
      lowUsdMin: 150,
      lowUsdMax: 200,
      seasonalWarning:
          'Voo direto EZE→FLN apenas em mar–abr. '
          'Outros meses: conexão via GRU (~5 h no total).',
    ),
    'EZE:CWB': _RouteData(
      originIata: 'EZE',
      destIata: 'CWB',
      months: [
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
      ],
      lowUsdMin: 170,
      lowUsdMax: 250,
    ),
    'EZE:GIG': _RouteData(
      originIata: 'EZE',
      destIata: 'GIG',
      months: [
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
      ],
      lowUsdMin: 150,
      lowUsdMax: 220,
      seasonalWarning:
          'Fev tem Carnaval no Rio: passagens chegam a \$500+. '
          'Reserve com no mínimo 6 meses de antecedência se viajar nessa época.',
    ),
    'EZE:POA': _RouteData(
      originIata: 'EZE',
      destIata: 'POA',
      months: [
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
      ],
      lowUsdMin: 140,
      lowUsdMax: 190,
    ),
    'EZE:SSA': _RouteData(
      originIata: 'EZE',
      destIata: 'SSA',
      months: [
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
      ],
      lowUsdMin: 200,
      lowUsdMax: 280,
    ),
    'EZE:REC': _RouteData(
      originIata: 'EZE',
      destIata: 'REC',
      months: [
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
      ],
      lowUsdMin: 210,
      lowUsdMax: 290,
    ),
    'EZE:FOR': _RouteData(
      originIata: 'EZE',
      destIata: 'FOR',
      months: [
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
      ],
      lowUsdMin: 210,
      lowUsdMax: 300,
    ),
  };

  static const _monthLabels = [
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _resolvedOriginIata =>
      _originHub[originCountryIso.toUpperCase()] ?? 'EZE';

  String get _resolvedDestIata {
    if (destIata != null && destIata!.isNotEmpty) {
      return destIata!.toUpperCase();
    }
    if (cityId != null) {
      return _cityToIata[cityId!] ?? 'GRU';
    }
    return 'GRU';
  }

  _RouteData? get _route {
    final key = '$_resolvedOriginIata:$_resolvedDestIata';
    return _routes[key] ?? _routes['$_resolvedOriginIata:GRU'];
  }

  List<String> _cheapMonths(_RouteData data) => [
    for (var i = 0; i < 12; i++)
      if (data.months[i] == _PriceLevel.low) _monthLabels[i],
  ];

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final data = _route;
    if (data == null) return const SizedBox.shrink();

    final originIata = _resolvedOriginIata;
    final dIata = _resolvedDestIata;
    final cheap = _cheapMonths(data);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Melhor época para voar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$originIata → $dIata · Faixas históricas (USD)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 16),

          // ── Bar chart ──────────────────────────────────────────────────────
          _MonthBarChart(months: data.months),
          const SizedBox(height: 12),

          // ── Legend ─────────────────────────────────────────────────────────
          _PriceLegend(lowMin: data.lowUsdMin, lowMax: data.lowUsdMax),
          const SizedBox(height: 12),

          // ── Cheapest months callout ─────────────────────────────────────────
          if (cheap.isNotEmpty)
            _InfoCallout(
              icon: Icons.savings_outlined,
              color: AppColors.success,
              text: 'Mais barato: ${cheap.join(', ')} · Até 40% de economia',
            ),

          // ── Seasonal warning ──────────────────────────────────────────────
          if (data.seasonalWarning != null) ...[
            const SizedBox(height: 8),
            _InfoCallout(
              icon: Icons.info_outline_rounded,
              color: AppColors.caution,
              text: data.seasonalWarning!,
            ),
          ],

          const SizedBox(height: 14),

          // ── CTA ─────────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openSkyscanner(context, originIata, dIata),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text('Ver preços ao vivo  $originIata → $dIata'),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Faixas históricas · Preços reais variam conforme a data',
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
          title: 'Passagens $origin → $dest',
          uri: uri,
        ),
      ),
    );
  }
}

// ── Month bar chart ───────────────────────────────────────────────────────────

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
    _PriceLevel.low => 24.0,
    _PriceLevel.mid => 40.0,
    _PriceLevel.high => 54.0,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final level = months[i];
          final color = _barColor(level);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: _barHeight(level),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.70),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _labels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
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

// ── Legend ────────────────────────────────────────────────────────────────────

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
          label: 'Barato (\$$lowMin–\$$lowMax)',
        ),
        _LegendDot(color: AppColors.warning, label: 'Médio'),
        _LegendDot(color: AppColors.danger, label: 'Caro'),
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

// ── Info callout (reusable) ───────────────────────────────────────────────────

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

// ── Compact badge (used in result reveal page) ────────────────────────────────

/// A small inline badge showing the price range and best months for a route.
/// Intended for use in tight spaces like cards and result pages.
class FlightPriceBadge extends StatelessWidget {
  const FlightPriceBadge({
    required this.originCountryIso,
    this.cityId,
    this.destIata,
    super.key,
  });

  final String originCountryIso;
  final String? cityId;
  final String? destIata;

  static const Map<String, String> _originHub = {
    'AR': 'EZE',
    'CL': 'SCL',
    'UY': 'MVD',
  };

  static const Map<String, String> _cityToIata = {
    'florianopolis-sc': 'FLN',
    'balneario-camboriu-sc': 'FLN',
    'itajai-sc': 'FLN',
    'joinville-sc': 'FLN',
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
    'campo-grande-ms': 'CGR',
  };

  // Minimal route price data for badge display
  static const Map<String, ({int min, int max, String best})> _badgeData = {
    'EZE:GRU': (min: 133, max: 160, best: 'Abr, Mai, Nov'),
    'EZE:FLN': (min: 150, max: 200, best: 'Mar, Abr, Set, Out'),
    'EZE:CWB': (min: 170, max: 250, best: 'Abr, Mai, Nov'),
    'EZE:GIG': (min: 150, max: 220, best: 'Abr, Mai, Set, Out'),
    'EZE:POA': (min: 140, max: 190, best: 'Abr, Mai, Set, Nov'),
    'EZE:SSA': (min: 200, max: 280, best: 'Abr, Mai, Out, Nov'),
    'EZE:REC': (min: 210, max: 290, best: 'Abr, Mai, Out, Nov'),
    'EZE:FOR': (min: 210, max: 300, best: 'Abr, Mai, Out, Nov'),
  };

  String get _resolvedOrigin =>
      _originHub[originCountryIso.toUpperCase()] ?? 'EZE';

  String get _resolvedDest {
    if (destIata != null && destIata!.isNotEmpty) {
      return destIata!.toUpperCase();
    }
    if (cityId != null) {
      return _cityToIata[cityId!] ?? 'GRU';
    }
    return 'GRU';
  }

  @override
  Widget build(BuildContext context) {
    final key = '$_resolvedOrigin:$_resolvedDest';
    final data = _badgeData[key] ?? _badgeData['$_resolvedOrigin:GRU'];
    if (data == null) return const SizedBox.shrink();

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
                  TextSpan(text: 'Passagem: '),
                  TextSpan(
                    text: 'a partir de \$${data.min} USD',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: '  ·  Mais barato: '),
                  TextSpan(
                    text: data.best,
                    style: TextStyle(
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

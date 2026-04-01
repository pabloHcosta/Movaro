import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

enum _PriceLevel { low, mid, high }

class _RouteData {
  const _RouteData({
    required this.originIata,
    required this.destIata,
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarningKey,
  });

  final String originIata;
  final String destIata;
  final List<_PriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarningKey;
}

class _DestinationSeasonalityProfile {
  const _DestinationSeasonalityProfile({
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarningKey,
  });

  final List<_PriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarningKey;
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
      seasonalWarningKey: 'fln',
    ),
    'NVT': _DestinationSeasonalityProfile(
      months: _coastalSouthMonths,
      lowUsdMin: 160,
      lowUsdMax: 210,
      seasonalWarningKey: 'nvt',
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
      seasonalWarningKey: 'gig',
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
      seasonalWarningKey: 'mao',
    ),
    'BEL': _DestinationSeasonalityProfile(
      months: _northMonths,
      lowUsdMin: 250,
      lowUsdMax: 340,
      seasonalWarningKey: 'bel',
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
      seasonalWarningKey: destinationProfile.seasonalWarningKey,
    );
  }

  static List<String> cheapMonths(_RouteData data, List<String> monthLabels) => [
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
    this.routeInsight,
    super.key,
  });

  final String originCountryIso;
  final String? originIata;
  final String? cityId;
  final String? destIata;
  final TravelRouteInsight? routeInsight;

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
    final l10n = context.l10n;
    final originIata = _resolvedOriginIata;
    final destinationIata = _resolvedDestIata;
    if (originIata == null || destinationIata == null) {
      return const SizedBox.shrink();
    }

    final data = routeInsight == null ? _route : _RouteData(
      originIata: routeInsight!.originIata,
      destIata: routeInsight!.destIata,
      months: routeInsight!.months.map((item) => switch (item) {
        TravelRoutePriceLevel.low => _PriceLevel.low,
        TravelRoutePriceLevel.mid => _PriceLevel.mid,
        TravelRoutePriceLevel.high => _PriceLevel.high,
      }).toList(growable: false),
      lowUsdMin: routeInsight!.lowUsdMin,
      lowUsdMax: routeInsight!.lowUsdMax,
      seasonalWarningKey: routeInsight!.seasonalWarningKey,
    );
    final monthLabels = _monthLabels(l10n);
    final cheapMonths = data == null
        ? const <String>[]
        : _FlightSeasonalityCatalog.cheapMonths(data, monthLabels);

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
                l10n.flightSeasonalityTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.flightSeasonalitySubtitle(originIata, destinationIata),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 16),
          if (data != null) ...[
            _MonthBarChart(
              months: data.months,
              labels: _monthInitials(l10n),
            ),
            const SizedBox(height: 12),
            _PriceLegend(lowMin: data.lowUsdMin, lowMax: data.lowUsdMax),
            const SizedBox(height: 12),
            if (cheapMonths.isNotEmpty)
              _InfoCallout(
                icon: Icons.savings_outlined,
                color: AppColors.success,
                text: l10n.flightSeasonalitySavingsMonths(
                  cheapMonths.join(', '),
                ),
              ),
            if (data.seasonalWarningKey != null) ...[
              const SizedBox(height: 8),
              _InfoCallout(
                icon: Icons.info_outline_rounded,
                color: AppColors.caution,
                text: _seasonalWarning(l10n, data.seasonalWarningKey!),
              ),
            ],
          ] else
            _InfoCallout(
              icon: Icons.insights_outlined,
              color: AppColors.primary,
              text: l10n.flightSeasonalityFallback,
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _openSkyscanner(context, originIata, destinationIata),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(
                l10n.flightSeasonalityLiveButton(originIata, destinationIata),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              l10n.flightSeasonalityFooter,
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
          title: context.l10n.flightSeasonalityWebviewTitle(origin, dest),
          uri: uri,
        ),
      ),
    );
  }
}

class _MonthBarChart extends StatelessWidget {
  const _MonthBarChart({required this.months, required this.labels});

  final List<_PriceLevel> months;
  final List<String> labels;

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
                    labels[i],
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
          label: context.l10n.flightSeasonalityLegendLow(lowMin, lowMax),
        ),
        _LegendDot(
          color: AppColors.warning,
          label: context.l10n.flightSeasonalityLegendMid,
        ),
        _LegendDot(
          color: AppColors.danger,
          label: context.l10n.flightSeasonalityLegendHigh,
        ),
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
    this.routeInsight,
    super.key,
  });

  final String originCountryIso;
  final String? originIata;
  final String? cityId;
  final String? destIata;
  final TravelRouteInsight? routeInsight;

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
    final route = routeInsight == null
        ? _FlightSeasonalityCatalog.resolveRoute(
            originIata: _resolvedOrigin,
            destIata: _resolvedDest,
          )
        : _RouteData(
            originIata: routeInsight!.originIata,
            destIata: routeInsight!.destIata,
            months: routeInsight!.months.map((item) => switch (item) {
              TravelRoutePriceLevel.low => _PriceLevel.low,
              TravelRoutePriceLevel.mid => _PriceLevel.mid,
              TravelRoutePriceLevel.high => _PriceLevel.high,
            }).toList(growable: false),
            lowUsdMin: routeInsight!.lowUsdMin,
            lowUsdMax: routeInsight!.lowUsdMax,
            seasonalWarningKey: routeInsight!.seasonalWarningKey,
          );
    if (route == null) {
      return const SizedBox.shrink();
    }
    final bestMonths = _FlightSeasonalityCatalog.cheapMonths(
      route,
      _monthLabels(context.l10n),
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
                  TextSpan(text: context.l10n.flightSeasonalityBadgePrefix),
                  TextSpan(
                    text: context.l10n.flightSeasonalityBadgeFrom(
                      route.lowUsdMin,
                    ),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: context.l10n.flightSeasonalityBadgeCheapestPrefix,
                  ),
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

List<String> _monthLabels(AppLocalizations l10n) => [
  l10n.commonMonthAbbrevJan,
  l10n.commonMonthAbbrevFeb,
  l10n.commonMonthAbbrevMar,
  l10n.commonMonthAbbrevApr,
  l10n.commonMonthAbbrevMay,
  l10n.commonMonthAbbrevJun,
  l10n.commonMonthAbbrevJul,
  l10n.commonMonthAbbrevAug,
  l10n.commonMonthAbbrevSep,
  l10n.commonMonthAbbrevOct,
  l10n.commonMonthAbbrevNov,
  l10n.commonMonthAbbrevDec,
];

List<String> _monthInitials(AppLocalizations l10n) => [
  l10n.commonMonthInitialJan,
  l10n.commonMonthInitialFeb,
  l10n.commonMonthInitialMar,
  l10n.commonMonthInitialApr,
  l10n.commonMonthInitialMay,
  l10n.commonMonthInitialJun,
  l10n.commonMonthInitialJul,
  l10n.commonMonthInitialAug,
  l10n.commonMonthInitialSep,
  l10n.commonMonthInitialOct,
  l10n.commonMonthInitialNov,
  l10n.commonMonthInitialDec,
];

String _seasonalWarning(AppLocalizations l10n, String key) => switch (key) {
  'fln' => l10n.flightSeasonalityWarningFln,
  'nvt' => l10n.flightSeasonalityWarningNvt,
  'gig' => l10n.flightSeasonalityWarningGig,
  'mao' => l10n.flightSeasonalityWarningMao,
  'bel' => l10n.flightSeasonalityWarningBel,
  _ => '',
};

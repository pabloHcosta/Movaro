import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';

enum FlightRoutePriceLevel { low, mid, high }

class FlightRoutePriceInsight {
  const FlightRoutePriceInsight({
    required this.originIata,
    required this.destIata,
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarningKey,
  });

  final String originIata;
  final String destIata;
  final List<FlightRoutePriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarningKey;

  double get lowUsdAverage => (lowUsdMin + lowUsdMax) / 2;
}

class FlightRoutePricePressure {
  const FlightRoutePricePressure({
    required this.label,
    required this.relativeLoad,
    required this.deltaVsCheapest,
  });

  final String label;
  final double relativeLoad;
  final int deltaVsCheapest;
}

class _DestinationSeasonalityProfile {
  const _DestinationSeasonalityProfile({
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    this.seasonalWarningKey,
  });

  final List<FlightRoutePriceLevel> months;
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

class FlightRoutePriceInsightService {
  const FlightRoutePriceInsightService._();

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
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.high,
  ];

  static const _coastalSouthMonths = [
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.high,
  ];

  static const _northeastMonths = [
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.high,
  ];

  static const _northMonths = [
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.high,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.low,
    FlightRoutePriceLevel.mid,
    FlightRoutePriceLevel.high,
  ];

  static const Map<String, _DestinationSeasonalityProfile>
  _destinationProfiles = {
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

  static const Map<String, _OriginPriceAdjustment> _originAdjustments = {
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

  static FlightRoutePriceInsight? resolveRoute({
    required String? originIata,
    required String? destIata,
  }) {
    if (originIata == null || destIata == null) {
      return null;
    }
    final destinationProfile = _destinationProfiles[destIata.toUpperCase()];
    final originAdjustment = _originAdjustments[originIata.toUpperCase()];
    if (destinationProfile == null || originAdjustment == null) {
      return null;
    }
    return FlightRoutePriceInsight(
      originIata: originIata.toUpperCase(),
      destIata: destIata.toUpperCase(),
      months: destinationProfile.months,
      lowUsdMin: destinationProfile.lowUsdMin + originAdjustment.lowMinDelta,
      lowUsdMax: destinationProfile.lowUsdMax + originAdjustment.lowMaxDelta,
      seasonalWarningKey: destinationProfile.seasonalWarningKey,
    );
  }

  static FlightRoutePriceInsight? resolveRouteForCity({
    required String? originIata,
    String? cityId,
    String? destIata,
  }) {
    final resolvedDest =
        destIata?.toUpperCase() ??
        (cityId == null ? null : cityToIata[cityId.toLowerCase()]);
    return resolveRoute(originIata: originIata, destIata: resolvedDest);
  }

  static TravelRouteInsight? resolveTravelRoute({
    required String? originIata,
    required String? destIata,
  }) {
    final route = resolveRoute(originIata: originIata, destIata: destIata);
    if (route == null) return null;

    return TravelRouteInsight(
      originIata: route.originIata,
      destIata: route.destIata,
      months: route.months
          .map(
            (level) => switch (level) {
              FlightRoutePriceLevel.low => TravelRoutePriceLevel.low,
              FlightRoutePriceLevel.mid => TravelRoutePriceLevel.mid,
              FlightRoutePriceLevel.high => TravelRoutePriceLevel.high,
            },
          )
          .toList(growable: false),
      lowUsdMin: route.lowUsdMin,
      lowUsdMax: route.lowUsdMax,
      sourceLabel: 'Estimativa de rota modelada (não oficial)',
      sourceType: 'modeled_estimate',
      seasonalWarningKey: route.seasonalWarningKey,
    );
  }

  static FlightRoutePricePressure classifyPressure({
    required TravelRouteInsight route,
    int? baseArrivalBudgetBrl,
    double? usdToBrl,
    int? cheapestComparableUsdAverage,
  }) {
    final routeAverage = route.lowUsdAverage.round();
    final routeBudgetBrl = usdToBrl == null
        ? null
        : (routeAverage * usdToBrl).round();
    final relativeLoad =
        (routeBudgetBrl != null &&
            baseArrivalBudgetBrl != null &&
            baseArrivalBudgetBrl > 0)
        ? routeBudgetBrl / baseArrivalBudgetBrl
        : 0.0;
    final deltaVsCheapest = cheapestComparableUsdAverage == null
        ? 0
        : routeAverage - cheapestComparableUsdAverage;

    if (routeAverage >= 250 || relativeLoad >= 0.40 || deltaVsCheapest >= 55) {
      return FlightRoutePricePressure(
        label: 'high',
        relativeLoad: relativeLoad,
        deltaVsCheapest: deltaVsCheapest,
      );
    }
    if (routeAverage >= 180 || relativeLoad >= 0.28 || deltaVsCheapest >= 25) {
      return FlightRoutePricePressure(
        label: 'medium',
        relativeLoad: relativeLoad,
        deltaVsCheapest: deltaVsCheapest,
      );
    }
    return FlightRoutePricePressure(
      label: 'low',
      relativeLoad: relativeLoad,
      deltaVsCheapest: deltaVsCheapest,
    );
  }
}

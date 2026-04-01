enum TravelRoutePriceLevel { low, mid, high }

class TravelRouteInsight {
  const TravelRouteInsight({
    required this.originIata,
    required this.destIata,
    required this.months,
    required this.lowUsdMin,
    required this.lowUsdMax,
    required this.sourceLabel,
    required this.sourceType,
    this.seasonalWarningKey,
    this.sourceUrl,
  });

  final String originIata;
  final String destIata;
  final List<TravelRoutePriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarningKey;
  final String sourceLabel;
  final String? sourceUrl;
  final String sourceType;

  double get lowUsdAverage => (lowUsdMin + lowUsdMax) / 2;
}

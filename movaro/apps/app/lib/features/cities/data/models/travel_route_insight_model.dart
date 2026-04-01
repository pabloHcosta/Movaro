import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';

class TravelRouteInsightModel {
  const TravelRouteInsightModel({
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

  factory TravelRouteInsightModel.fromJson(Map<String, dynamic> json) {
    return TravelRouteInsightModel(
      originIata: json['originIata'] as String,
      destIata: json['destIata'] as String,
      months: (json['months'] as List<dynamic>)
          .map((item) => switch (item as String) {
                'low' => TravelRoutePriceLevel.low,
                'mid' => TravelRoutePriceLevel.mid,
                _ => TravelRoutePriceLevel.high,
              })
          .toList(),
      lowUsdMin: json['lowUsdMin'] as int,
      lowUsdMax: json['lowUsdMax'] as int,
      seasonalWarningKey: json['seasonalWarningKey'] as String?,
      sourceLabel: json['sourceLabel'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      sourceType: (json['sourceType'] as String?) ?? 'community',
    );
  }

  final String originIata;
  final String destIata;
  final List<TravelRoutePriceLevel> months;
  final int lowUsdMin;
  final int lowUsdMax;
  final String? seasonalWarningKey;
  final String sourceLabel;
  final String? sourceUrl;
  final String sourceType;

  TravelRouteInsight toEntity() => TravelRouteInsight(
    originIata: originIata,
    destIata: destIata,
    months: months,
    lowUsdMin: lowUsdMin,
    lowUsdMax: lowUsdMax,
    seasonalWarningKey: seasonalWarningKey,
    sourceLabel: sourceLabel,
    sourceUrl: sourceUrl,
    sourceType: sourceType,
  );
}

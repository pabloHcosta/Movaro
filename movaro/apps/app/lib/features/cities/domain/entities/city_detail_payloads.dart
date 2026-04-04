import 'package:movaro_app/features/cities/domain/entities/city_public_opinion.dart';

class CityDetailInsight {
  const CityDetailInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.shortText,
    required this.content,
    required this.source,
    required this.generatedAt,
    this.theme,
    this.placeHighlights = const [],
    this.ctaLabel,
    this.expiresAt,
  });

  final String id;
  final String type;
  final String? theme;
  final String title;
  final String shortText;
  final String content;
  final List<String> placeHighlights;
  final String? ctaLabel;
  final String source;
  final String generatedAt;
  final String? expiresAt;
}

class CityDetailSource {
  const CityDetailSource({required this.label, this.type, this.url});

  final String label;
  final String? type;
  final String? url;
}

class CityDetailSocialSignal {
  const CityDetailSocialSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.source,
  });

  final String id;
  final String label;
  final num value;
  final String unit;
  final String source;
}

class CityDetailSocialProof {
  const CityDetailSocialProof({
    required this.cityId,
    required this.cityName,
    required this.argentinaPopularityScore,
    required this.socialSignals,
    required this.sources,
    this.publicOpinion,
    this.routineInsight,
    this.neighborhoodInsight,
  });

  final String cityId;
  final String cityName;
  final int argentinaPopularityScore;
  final CityPublicOpinion? publicOpinion;
  final List<CityDetailSocialSignal> socialSignals;
  final CityDetailInsight? routineInsight;
  final CityDetailInsight? neighborhoodInsight;
  final List<CityDetailSource> sources;
}

class CityDetailClimateCurrentWeather {
  const CityDetailClimateCurrentWeather({
    required this.temperatureCelsius,
    required this.weatherCode,
    required this.isDay,
    required this.windSpeedKmh,
    required this.fetchedAt,
    required this.conditionLabel,
  });

  final double temperatureCelsius;
  final int? weatherCode;
  final bool? isDay;
  final double? windSpeedKmh;
  final String fetchedAt;
  final String conditionLabel;
}

class CityDetailClimateSeasonality {
  const CityDetailClimateSeasonality({
    required this.peakMonths,
    required this.lowMonths,
    required this.severity,
    required this.visitorsLabel,
    required this.rentNotes,
    required this.jobNotes,
    required this.updatedAt,
    required this.sourceLabel,
    required this.sourceType,
    this.populationMultiplierNote,
    this.sourceUrl,
  });

  final List<int> peakMonths;
  final List<int> lowMonths;
  final String severity;
  final String visitorsLabel;
  final String rentNotes;
  final String jobNotes;
  final String? populationMultiplierNote;
  final String updatedAt;
  final String sourceLabel;
  final String sourceType;
  final String? sourceUrl;
}

class CityDetailClimateSummary {
  const CityDetailClimateSummary({
    required this.cityId,
    required this.cityName,
    required this.currentWeather,
    required this.sources,
    this.seasonality,
  });

  final String cityId;
  final String cityName;
  final CityDetailClimateCurrentWeather currentWeather;
  final CityDetailClimateSeasonality? seasonality;
  final List<CityDetailSource> sources;
}

class CityDetailArrivalBudget {
  const CityDetailArrivalBudget({
    required this.fairLivingTotalBrl,
    required this.averageMonthlyNetSalaryBrl,
    required this.reserveMonths,
    required this.sourceLabel,
    required this.updatedAt,
    this.reserveAmountBrl,
  });

  final int? fairLivingTotalBrl;
  final int averageMonthlyNetSalaryBrl;
  final int reserveMonths;
  final int? reserveAmountBrl;
  final String sourceLabel;
  final String updatedAt;
}

class CityDetailFocusItem {
  const CityDetailFocusItem({
    required this.id,
    required this.label,
    required this.score,
  });

  final String id;
  final String label;
  final int score;
}

class CityDetailNeighborhoodPlace {
  const CityDetailNeighborhoodPlace({
    required this.id,
    required this.name,
    required this.shortText,
    required this.mapUrl,
    required this.source,
    this.neighborhood,
    this.region,
  });

  final String id;
  final String name;
  final String? neighborhood;
  final String? region;
  final String shortText;
  final String mapUrl;
  final String source;
}

class CityDetailArrivalStory {
  const CityDetailArrivalStory({
    required this.cityId,
    required this.cityName,
    required this.neighborhoods,
    required this.firstMonthFocus,
    required this.sources,
    this.story,
    this.firstMonthBudget,
  });

  final String cityId;
  final String cityName;
  final CityDetailInsight? story;
  final CityDetailArrivalBudget? firstMonthBudget;
  final List<CityDetailFocusItem> firstMonthFocus;
  final List<CityDetailNeighborhoodPlace> neighborhoods;
  final List<CityDetailSource> sources;
}

class CityDetailComparisonCity {
  const CityDetailComparisonCity({
    required this.cityId,
    required this.cityName,
    required this.stateCode,
  });

  final String cityId;
  final String cityName;
  final String stateCode;
}

class CityDetailComparisonMetricValue {
  const CityDetailComparisonMetricValue({
    required this.cityId,
    required this.cityName,
    required this.value,
  });

  final String cityId;
  final String cityName;
  final num? value;
}

class CityDetailComparisonMetric {
  const CityDetailComparisonMetric({
    required this.id,
    required this.label,
    required this.unit,
    required this.comparisons,
    this.primaryValue,
    this.benchmark,
    this.primaryIsBest = false,
    this.benchmarkLabel,
  });

  final String id;
  final String label;
  final String unit;
  final num? primaryValue;
  final num? benchmark;
  final bool primaryIsBest;
  final String? benchmarkLabel;
  final List<CityDetailComparisonMetricValue> comparisons;
}

class CityDetailComparison {
  const CityDetailComparison({
    required this.cityId,
    required this.cityName,
    required this.compareTo,
    required this.metrics,
    required this.sources,
  });

  final String cityId;
  final String cityName;
  final List<CityDetailComparisonCity> compareTo;
  final List<CityDetailComparisonMetric> metrics;
  final List<CityDetailSource> sources;
}

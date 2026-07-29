import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityRecommendationProfile {
  const CityRecommendationProfile({
    required this.destinationCountryCode,
    required this.intent,
    required this.priorities,
    this.funding = '',
    this.workArrangement = '',
    this.travelGroup = '',
    this.childrenCount,
    this.availableCapital = '',
    this.constraints = const [],
    this.supportNeeds = const [],
    this.originLatitude,
    this.originLongitude,
  });

  final String destinationCountryCode;
  final String intent;
  final String funding;
  final String workArrangement;
  final String travelGroup;
  final int? childrenCount;
  final String availableCapital;
  final List<String> priorities;
  final List<String> constraints;
  final List<String> supportNeeds;
  final double? originLatitude;
  final double? originLongitude;
}

class CityRecommendationEvidence {
  const CityRecommendationEvidence({
    required this.dimension,
    required this.provider,
    required this.sourceType,
    required this.freshnessStatus,
    this.updatedAt,
    this.url,
  });

  final String dimension;
  final String provider;
  final String sourceType;
  final String freshnessStatus;
  final String? updatedAt;
  final String? url;
}

class RecommendedCity {
  const RecommendedCity({
    required this.city,
    required this.score,
    required this.dimensions,
    required this.reasons,
    required this.tradeoffs,
    required this.dataCoverage,
    required this.freshnessStatus,
    required this.evidence,
    this.rank = 0,
    this.dataUpdatedAt,
  });

  final int rank;
  final City city;
  final double score;
  final Map<String, double> dimensions;
  final List<String> reasons;
  final List<String> tradeoffs;
  final double dataCoverage;
  final String? dataUpdatedAt;
  final String freshnessStatus;
  final List<CityRecommendationEvidence> evidence;
}

class CityRecommendationResult {
  const CityRecommendationResult({
    required this.methodologyVersion,
    required this.generatedAt,
    required this.catalogSize,
    required this.eligibleCityCount,
    required this.profileCompleteness,
    required this.dataCoverage,
    required this.appliedHardFilters,
    required this.unavailableDimensions,
    required this.warnings,
    required this.recommendations,
    required this.sourceSummary,
    this.recommendationId = '',
    this.stabilityBand = 'insufficient_data',
    this.reliabilityBand = 'limited',
    this.scoreSeparationBand = 'single_result',
    this.scenariosEvaluated = 0,
  });

  final String recommendationId;
  final String methodologyVersion;
  final String generatedAt;
  final int catalogSize;
  final int eligibleCityCount;
  final double profileCompleteness;
  final double dataCoverage;
  final List<String> appliedHardFilters;
  final List<String> unavailableDimensions;
  final List<String> warnings;
  final List<RecommendedCity> recommendations;
  final List<CityRecommendationEvidence> sourceSummary;
  final String stabilityBand;
  final String reliabilityBand;
  final String scoreSeparationBand;
  final int scenariosEvaluated;
}

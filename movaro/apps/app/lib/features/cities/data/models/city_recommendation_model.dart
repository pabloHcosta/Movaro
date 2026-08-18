import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';

class CityRecommendationModel {
  const CityRecommendationModel._();

  static CityRecommendationResult fromJson(Map<String, dynamic> json) {
    return CityRecommendationResult(
      recommendationId: json['recommendationId'] as String? ?? '',
      methodologyVersion: json['methodologyVersion'] as String? ?? 'unknown',
      generatedAt: json['generatedAt'] as String? ?? '',
      catalogSize: json['catalogSize'] as int? ?? 0,
      eligibleCityCount: json['eligibleCityCount'] as int? ?? 0,
      profileCompleteness:
          (json['profileCompleteness'] as num?)?.toDouble() ?? 0,
      dataCoverage: (json['dataCoverage'] as num?)?.toDouble() ?? 0,
      appliedHardFilters: _strings(json['appliedHardFilters']),
      unavailableDimensions: _strings(json['unavailableDimensions']),
      warnings: _strings(json['warnings']),
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_recommendedCity)
          .toList(growable: false),
      sourceSummary: (json['sourceSummary'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_evidence)
          .toList(growable: false),
      stabilityBand:
          (json['evaluation'] as Map<String, dynamic>?)?['stabilityBand']
              as String? ??
          'insufficient_data',
      reliabilityBand:
          (json['evaluation'] as Map<String, dynamic>?)?['reliabilityBand']
              as String? ??
          'limited',
      scoreSeparationBand:
          (json['evaluation'] as Map<String, dynamic>?)?['scoreSeparationBand']
              as String? ??
          'single_result',
      scenariosEvaluated:
          (json['evaluation'] as Map<String, dynamic>?)?['scenariosEvaluated']
              as int? ??
          0,
      refinement: _refinement(json['refinement']),
    );
  }

  static CityRecommendationRefinement? _refinement(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return CityRecommendationRefinement(
      status: raw['status'] as String? ?? 'no_candidates',
      questionId: raw['questionId'] as String?,
      discriminationGain: (raw['discriminationGain'] as num?)?.toDouble() ?? 0,
      gainBand: raw['gainBand'] as String? ?? 'none',
      minimumGain: (raw['minimumGain'] as num?)?.toDouble() ?? 0,
      scenariosEvaluated: raw['scenariosEvaluated'] as int? ?? 0,
      candidates: (raw['candidates'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CityRecommendationRefinementCandidate(
              questionId: item['questionId'] as String? ?? '',
              discriminationGain:
                  (item['discriminationGain'] as num?)?.toDouble() ?? 0,
              scenariosEvaluated: item['scenariosEvaluated'] as int? ?? 0,
              topCityVariants: item['topCityVariants'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  static RecommendedCity _recommendedCity(Map<String, dynamic> json) {
    final dimensions = (json['dimensions'] as Map<String, dynamic>? ?? const {})
        .map((key, value) => MapEntry(key, (value as num).toDouble()));
    return RecommendedCity(
      rank: json['rank'] as int? ?? 0,
      city: CityModel.fromJson(json['city'] as Map<String, dynamic>).toEntity(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      dimensions: dimensions,
      reasons: _strings(json['reasons']),
      tradeoffs: _strings(json['tradeoffs']),
      dataCoverage: (json['dataCoverage'] as num?)?.toDouble() ?? 0,
      dataUpdatedAt: json['dataUpdatedAt'] as String?,
      freshnessStatus: json['freshnessStatus'] as String? ?? 'unknown',
      evidence: (json['evidence'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_evidence)
          .toList(growable: false),
    );
  }

  static CityRecommendationEvidence _evidence(Map<String, dynamic> json) {
    return CityRecommendationEvidence(
      dimension: json['dimension'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? 'curated',
      updatedAt: json['updatedAt'] as String?,
      freshnessStatus: json['freshnessStatus'] as String? ?? 'unknown',
      url: json['url'] as String?,
    );
  }

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const []).whereType<String>().toList(
        growable: false,
      );
}

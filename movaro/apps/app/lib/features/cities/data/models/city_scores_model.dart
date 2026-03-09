import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';

class CityScoresModel {
  const CityScoresModel({
    required this.economical,
    required this.popularForArgentinians,
    required this.languageAdaptation,
    required this.workOpportunity,
    required this.overall,
  });

  factory CityScoresModel.fromJson(Map<String, dynamic> json) {
    return CityScoresModel(
      economical: json['economical'] as int,
      popularForArgentinians: json['popularForArgentinians'] as int,
      languageAdaptation: json['languageAdaptation'] as int,
      workOpportunity: json['workOpportunity'] as int,
      overall: json['overall'] as int,
    );
  }

  final int economical;
  final int popularForArgentinians;
  final int languageAdaptation;
  final int workOpportunity;
  final int overall;

  factory CityScoresModel.fromEntity(CityScores scores) {
    return CityScoresModel(
      economical: scores.economical,
      popularForArgentinians: scores.popularForArgentinians,
      languageAdaptation: scores.languageAdaptation,
      workOpportunity: scores.workOpportunity,
      overall: scores.overall,
    );
  }

  Map<String, dynamic> toJson() => {
    'economical': economical,
    'popularForArgentinians': popularForArgentinians,
    'languageAdaptation': languageAdaptation,
    'workOpportunity': workOpportunity,
    'overall': overall,
  };

  CityScores toEntity() => CityScores(
    economical: economical,
    popularForArgentinians: popularForArgentinians,
    languageAdaptation: languageAdaptation,
    workOpportunity: workOpportunity,
    overall: overall,
  );
}

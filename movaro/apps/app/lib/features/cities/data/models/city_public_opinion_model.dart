import 'package:movaro_app/features/cities/domain/entities/city_public_opinion.dart';

class CityPublicOpinionModel {
  const CityPublicOpinionModel({
    required this.provider,
    required this.placeName,
    required this.placeUrl,
    required this.rating,
    required this.userRatingCount,
    required this.summary,
    required this.positivePoints,
    required this.criticalPoints,
    required this.collectedAt,
  });

  factory CityPublicOpinionModel.fromJson(Map<String, dynamic> json) {
    return CityPublicOpinionModel(
      provider: json['provider'] as String,
      placeName: json['placeName'] as String?,
      placeUrl: json['placeUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['userRatingCount'] as int?,
      summary: json['summary'] as String?,
      positivePoints: (json['positivePoints'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      criticalPoints: (json['criticalPoints'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      collectedAt: json['collectedAt'] as String,
    );
  }

  final String provider;
  final String? placeName;
  final String? placeUrl;
  final double? rating;
  final int? userRatingCount;
  final String? summary;
  final List<String> positivePoints;
  final List<String> criticalPoints;
  final String collectedAt;

  factory CityPublicOpinionModel.fromEntity(CityPublicOpinion opinion) {
    return CityPublicOpinionModel(
      provider: opinion.provider,
      placeName: opinion.placeName,
      placeUrl: opinion.placeUrl,
      rating: opinion.rating,
      userRatingCount: opinion.userRatingCount,
      summary: opinion.summary,
      positivePoints: opinion.positivePoints,
      criticalPoints: opinion.criticalPoints,
      collectedAt: opinion.collectedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'placeName': placeName,
    'placeUrl': placeUrl,
    'rating': rating,
    'userRatingCount': userRatingCount,
    'summary': summary,
    'positivePoints': positivePoints,
    'criticalPoints': criticalPoints,
    'collectedAt': collectedAt,
  };

  CityPublicOpinion toEntity() => CityPublicOpinion(
    provider: provider,
    placeName: placeName,
    placeUrl: placeUrl,
    rating: rating,
    userRatingCount: userRatingCount,
    summary: summary,
    positivePoints: positivePoints,
    criticalPoints: criticalPoints,
    collectedAt: collectedAt,
  );
}

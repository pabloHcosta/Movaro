class CityPublicOpinion {
  const CityPublicOpinion({
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

  final String provider;
  final String? placeName;
  final String? placeUrl;
  final double? rating;
  final int? userRatingCount;
  final String? summary;
  final List<String> positivePoints;
  final List<String> criticalPoints;
  final String collectedAt;
}

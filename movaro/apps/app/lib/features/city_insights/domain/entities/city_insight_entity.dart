enum CityInsightType {
  lifestyle,
  costOfLiving,
  housing,
  work,
  practicalTip,
  motivation,
}

enum CityInsightTheme {
  neighborhoods,
  beaches,
  parks,
  nightlife,
  foodAndCafes,
  cultureAndEvents,
  viewpoints,
  localRoutine,
}

class CityInsightEntity {
  const CityInsightEntity({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.type,
    required this.title,
    required this.shortText,
    required this.content,
    required this.source,
    required this.generatedAt,
    this.theme,
    this.placeHighlights = const [],
    this.imageUrl,
    this.ctaLabel,
    this.expiresAt,
  });

  final String id;
  final String cityId;
  final String cityName;
  final CityInsightType type;
  final CityInsightTheme? theme;
  final String title;
  final String shortText;
  final String content;
  final String source;
  final DateTime generatedAt;
  final List<String> placeHighlights;
  final String? imageUrl;
  final String? ctaLabel;
  final DateTime? expiresAt;
}

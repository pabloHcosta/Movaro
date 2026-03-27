import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';

class CityInsightModel {
  const CityInsightModel({
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
  final String type;
  final String? theme;
  final String title;
  final String shortText;
  final String content;
  final String source;
  final String generatedAt;
  final List<String> placeHighlights;
  final String? imageUrl;
  final String? ctaLabel;
  final String? expiresAt;

  factory CityInsightModel.fromJson(Map<String, dynamic> json) {
    return CityInsightModel(
      id: json['id'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      type: json['type'] as String? ?? 'motivation',
      theme: json['theme'] as String?,
      title: json['title'] as String? ?? '',
      shortText: json['shortText'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: json['source'] as String? ?? 'template',
      generatedAt: json['generatedAt'] as String? ?? '',
      placeHighlights: (json['placeHighlights'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      imageUrl: json['imageUrl'] as String?,
      ctaLabel: json['ctaLabel'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  factory CityInsightModel.fromEntity(CityInsightEntity entity) {
    return CityInsightModel(
      id: entity.id,
      cityId: entity.cityId,
      cityName: entity.cityName,
      type: _typeToWire(entity.type),
      theme: entity.theme == null ? null : _themeToWire(entity.theme!),
      title: entity.title,
      shortText: entity.shortText,
      content: entity.content,
      source: entity.source,
      generatedAt: entity.generatedAt.toIso8601String(),
      placeHighlights: entity.placeHighlights,
      imageUrl: entity.imageUrl,
      ctaLabel: entity.ctaLabel,
      expiresAt: entity.expiresAt?.toIso8601String(),
    );
  }

  CityInsightEntity toEntity() {
    return CityInsightEntity(
      id: id,
      cityId: cityId,
      cityName: cityName,
      type: _typeFromWire(type),
      theme: theme == null ? null : _themeFromWire(theme!),
      title: title,
      shortText: shortText,
      content: content,
      source: source,
      generatedAt: DateTime.tryParse(generatedAt) ?? DateTime.now(),
      placeHighlights: placeHighlights,
      imageUrl: imageUrl,
      ctaLabel: ctaLabel,
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt!),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cityId': cityId,
    'cityName': cityName,
    'type': type,
    if (theme != null) 'theme': theme,
    'title': title,
    'shortText': shortText,
    'content': content,
    'source': source,
    'generatedAt': generatedAt,
    'placeHighlights': placeHighlights,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (ctaLabel != null) 'ctaLabel': ctaLabel,
    if (expiresAt != null) 'expiresAt': expiresAt,
  };
}

CityInsightType _typeFromWire(String value) {
  switch (value) {
    case 'lifestyle':
      return CityInsightType.lifestyle;
    case 'cost_of_living':
      return CityInsightType.costOfLiving;
    case 'housing':
      return CityInsightType.housing;
    case 'work':
      return CityInsightType.work;
    case 'practical_tip':
      return CityInsightType.practicalTip;
    case 'motivation':
    default:
      return CityInsightType.motivation;
  }
}

String _typeToWire(CityInsightType value) {
  switch (value) {
    case CityInsightType.lifestyle:
      return 'lifestyle';
    case CityInsightType.costOfLiving:
      return 'cost_of_living';
    case CityInsightType.housing:
      return 'housing';
    case CityInsightType.work:
      return 'work';
    case CityInsightType.practicalTip:
      return 'practical_tip';
    case CityInsightType.motivation:
      return 'motivation';
  }
}

CityInsightTheme _themeFromWire(String value) {
  switch (value) {
    case 'neighborhoods':
      return CityInsightTheme.neighborhoods;
    case 'beaches':
      return CityInsightTheme.beaches;
    case 'parks':
      return CityInsightTheme.parks;
    case 'nightlife':
      return CityInsightTheme.nightlife;
    case 'food_and_cafes':
      return CityInsightTheme.foodAndCafes;
    case 'culture_and_events':
      return CityInsightTheme.cultureAndEvents;
    case 'viewpoints':
      return CityInsightTheme.viewpoints;
    case 'local_routine':
    default:
      return CityInsightTheme.localRoutine;
  }
}

String _themeToWire(CityInsightTheme value) {
  switch (value) {
    case CityInsightTheme.neighborhoods:
      return 'neighborhoods';
    case CityInsightTheme.beaches:
      return 'beaches';
    case CityInsightTheme.parks:
      return 'parks';
    case CityInsightTheme.nightlife:
      return 'nightlife';
    case CityInsightTheme.foodAndCafes:
      return 'food_and_cafes';
    case CityInsightTheme.cultureAndEvents:
      return 'culture_and_events';
    case CityInsightTheme.viewpoints:
      return 'viewpoints';
    case CityInsightTheme.localRoutine:
      return 'local_routine';
  }
}

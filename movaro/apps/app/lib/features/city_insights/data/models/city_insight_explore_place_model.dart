import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';

class CityInsightExplorePlaceModel {
  const CityInsightExplorePlaceModel({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.theme,
    required this.name,
    required this.category,
    required this.shortText,
    required this.mapUrl,
    required this.source,
    this.neighborhood,
    this.region,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String cityId;
  final String cityName;
  final String theme;
  final String name;
  final String category;
  final String? neighborhood;
  final String? region;
  final String shortText;
  final String? imageUrl;
  final String mapUrl;
  final double? latitude;
  final double? longitude;
  final String source;

  factory CityInsightExplorePlaceModel.fromJson(Map<String, dynamic> json) {
    return CityInsightExplorePlaceModel(
      id: json['id'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      theme: json['theme'] as String? ?? 'local_routine',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      neighborhood: json['neighborhood'] as String?,
      region: json['region'] as String?,
      shortText: json['shortText'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      mapUrl: json['mapUrl'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      source: json['source'] as String? ?? 'template',
    );
  }

  factory CityInsightExplorePlaceModel.fromEntity(
    CityInsightExplorePlaceEntity entity,
  ) {
    return CityInsightExplorePlaceModel(
      id: entity.id,
      cityId: entity.cityId,
      cityName: entity.cityName,
      theme: _themeToWire(entity.theme),
      name: entity.name,
      category: entity.category,
      neighborhood: entity.neighborhood,
      region: entity.region,
      shortText: entity.shortText,
      imageUrl: entity.imageUrl,
      mapUrl: entity.mapUrl,
      latitude: entity.latitude,
      longitude: entity.longitude,
      source: entity.source,
    );
  }

  CityInsightExplorePlaceEntity toEntity() {
    return CityInsightExplorePlaceEntity(
      id: id,
      cityId: cityId,
      cityName: cityName,
      theme: _themeFromWire(theme),
      name: name,
      category: category,
      neighborhood: neighborhood,
      region: region,
      shortText: shortText,
      imageUrl: imageUrl,
      mapUrl: mapUrl,
      latitude: latitude,
      longitude: longitude,
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cityId': cityId,
    'cityName': cityName,
    'theme': theme,
    'name': name,
    'category': category,
    if (neighborhood != null) 'neighborhood': neighborhood,
    if (region != null) 'region': region,
    'shortText': shortText,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'mapUrl': mapUrl,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'source': source,
  };
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

import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';

class CityInsightExplorePlaceEntity {
  const CityInsightExplorePlaceEntity({
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
  final CityInsightTheme theme;
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
}

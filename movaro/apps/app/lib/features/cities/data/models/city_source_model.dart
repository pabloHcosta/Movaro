import 'package:movaro_app/features/cities/domain/entities/city_source.dart';

class CitySourceModel {
  const CitySourceModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.isOfficial,
    required this.url,
    required this.sourceType,
  });

  factory CitySourceModel.fromJson(Map<String, dynamic> json) {
    return CitySourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String,
      isOfficial: json['isOfficial'] as bool,
      url: json['url'] as String?,
      sourceType: (json['sourceType'] as String?) ??
          ((json['isOfficial'] as bool) ? 'official' : 'curated'),
    );
  }

  final String id;
  final String title;
  final String provider;
  final String description;
  final bool isOfficial;
  final String? url;
  final String sourceType;

  factory CitySourceModel.fromEntity(CitySource source) {
    return CitySourceModel(
      id: source.id,
      title: source.title,
      provider: source.provider,
      description: source.description,
      isOfficial: source.isOfficial,
      url: source.url,
      sourceType: source.sourceType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'provider': provider,
    'description': description,
    'isOfficial': isOfficial,
    'url': url,
    'sourceType': sourceType,
  };

  CitySource toEntity() => CitySource(
    id: id,
    title: title,
    provider: provider,
    description: description,
    isOfficial: isOfficial,
    url: url,
    sourceType: sourceType,
  );
}

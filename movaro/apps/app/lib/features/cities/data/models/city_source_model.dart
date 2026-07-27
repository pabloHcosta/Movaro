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
    this.referenceValue,
    this.referenceUnit,
    this.referencePeriod,
    this.updatedAt,
  });

  factory CitySourceModel.fromJson(Map<String, dynamic> json) {
    return CitySourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String,
      isOfficial: json['isOfficial'] as bool,
      url: json['url'] as String?,
      sourceType:
          (json['sourceType'] as String?) ??
          ((json['isOfficial'] as bool) ? 'official' : 'curated'),
      referenceValue: (json['referenceValue'] as num?)?.toDouble(),
      referenceUnit: json['referenceUnit'] as String?,
      referencePeriod: json['referencePeriod'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String title;
  final String provider;
  final String description;
  final bool isOfficial;
  final String? url;
  final String sourceType;
  final double? referenceValue;
  final String? referenceUnit;
  final String? referencePeriod;
  final String? updatedAt;

  factory CitySourceModel.fromEntity(CitySource source) {
    return CitySourceModel(
      id: source.id,
      title: source.title,
      provider: source.provider,
      description: source.description,
      isOfficial: source.isOfficial,
      url: source.url,
      sourceType: source.sourceType,
      referenceValue: source.referenceValue,
      referenceUnit: source.referenceUnit,
      referencePeriod: source.referencePeriod,
      updatedAt: source.updatedAt,
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
    if (referenceValue != null) 'referenceValue': referenceValue,
    if (referenceUnit != null) 'referenceUnit': referenceUnit,
    if (referencePeriod != null) 'referencePeriod': referencePeriod,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };

  CitySource toEntity() => CitySource(
    id: id,
    title: title,
    provider: provider,
    description: description,
    isOfficial: isOfficial,
    url: url,
    sourceType: sourceType,
    referenceValue: referenceValue,
    referenceUnit: referenceUnit,
    referencePeriod: referencePeriod,
    updatedAt: updatedAt,
  );
}

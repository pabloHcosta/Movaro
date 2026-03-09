import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';

class CatalogCountryModel {
  const CatalogCountryModel({required this.id, required this.name});

  factory CatalogCountryModel.fromJson(Map<String, dynamic> json) {
    return CatalogCountryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String name;

  CatalogCountry toEntity() => CatalogCountry(id: id, name: name);
}

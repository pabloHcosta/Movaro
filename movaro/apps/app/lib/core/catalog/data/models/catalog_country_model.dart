import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/country_coverage.dart';

class CatalogCountryModel {
  const CatalogCountryModel({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.locationAliases,
    required this.coverage,
  });

  factory CatalogCountryModel.fromJson(Map<String, dynamic> json) {
    final coverageJson = json['coverage'] as Map<String, dynamic>? ?? const {};
    return CatalogCountryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isoCode: json['isoCode'] as String? ?? '',
      locationAliases:
          (json['locationAliases'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      coverage: CountryCoverage(
        originStatus: CoverageStatus.fromJson(
          coverageJson['originStatus'] as String?,
        ),
        destinationStatus: CoverageStatus.fromJson(
          coverageJson['destinationStatus'] as String?,
        ),
        publicContentStatus: CoverageStatus.fromJson(
          coverageJson['publicContentStatus'] as String?,
        ),
        supportedDestinationIds:
            (coverageJson['supportedDestinationIds'] as List<dynamic>? ??
                    const <dynamic>[])
                .whereType<String>()
                .toList(growable: false),
      ),
    );
  }

  final String id;
  final String name;
  final String isoCode;
  final List<String> locationAliases;
  final CountryCoverage coverage;

  CatalogCountry toEntity() => CatalogCountry(
    id: id,
    name: name,
    isoCode: isoCode,
    locationAliases: locationAliases,
    coverage: coverage,
  );
}

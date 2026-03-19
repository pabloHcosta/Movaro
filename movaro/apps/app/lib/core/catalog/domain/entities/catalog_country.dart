import 'package:movaro_app/core/journey/country_coverage.dart';

class CatalogCountry {
  const CatalogCountry({
    required this.id,
    required this.name,
    required this.isoCode,
    this.locationAliases = const <String>[],
    this.coverage = const CountryCoverage(
      originStatus: CoverageStatus.unsupported,
      destinationStatus: CoverageStatus.unsupported,
    ),
  });

  final String id;
  final String name;
  final String isoCode;
  final List<String> locationAliases;
  final CountryCoverage coverage;
}

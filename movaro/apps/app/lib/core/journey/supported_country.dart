import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/country_coverage.dart';

class SupportedCountry {
  const SupportedCountry({
    required this.country,
    required this.coverage,
  });

  final CatalogCountry country;
  final CountryCoverage coverage;

  bool get isFullySupported =>
      coverage.canPlanAsOrigin || coverage.canPlanAsDestination;
}

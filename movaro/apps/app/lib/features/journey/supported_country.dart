import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/journey/country_coverage.dart';

class SupportedCountry {
  const SupportedCountry({required this.country, required this.coverage});

  final CatalogCountry country;
  final CountryCoverage coverage;

  bool get isFullySupported =>
      coverage.canPlanAsOrigin || coverage.canPlanAsDestination;
}

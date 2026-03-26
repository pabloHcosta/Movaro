import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';

class JourneySelection {
  const JourneySelection({this.origin, this.destination});

  final CatalogCountry? origin;
  final CatalogCountry? destination;

  bool get isComplete => origin != null && destination != null;
}

import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/journey/detected_location.dart';

class ActiveJourney {
  const ActiveJourney({
    this.detectedLocation,
    this.origin,
    this.destination,
    this.isSupportedRoute = false,
  });

  final DetectedLocation? detectedLocation;
  final CatalogCountry? origin;
  final CatalogCountry? destination;
  final bool isSupportedRoute;

  bool get hasDetectedLocation => detectedLocation != null;
  bool get hasConfirmedOrigin => origin != null;
  bool get hasDestination => destination != null;
  bool get isComplete => origin != null && destination != null;
}

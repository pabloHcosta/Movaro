import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/flight_search/domain/models/airport.dart';
import 'package:movaro_app/features/flight_search/domain/services/airport_finder_service.dart';
import 'package:movaro_app/features/location/location_data.dart';

class FlightRouteContextResolver {
  const FlightRouteContextResolver._();

  static const _finder = AirportFinderService();

  static const Map<String, String> _countryIsoAliases = {
    'ar': 'AR',
    'argentina': 'AR',
    'br': 'BR',
    'brazil': 'BR',
    'brasil': 'BR',
    'uy': 'UY',
    'uruguay': 'UY',
    'cl': 'CL',
    'chile': 'CL',
    'py': 'PY',
    'paraguay': 'PY',
  };

  static String? normalizeCountryIso(String? rawCountry) {
    final normalized = rawCountry?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return _countryIsoAliases[normalized] ?? rawCountry!.trim().toUpperCase();
  }

  static String resolveOriginCountryIso({
    String? savedCountryCode,
    String? planOriginCountry,
    String fallback = 'AR',
  }) {
    return normalizeCountryIso(savedCountryCode) ??
        normalizeCountryIso(planOriginCountry) ??
        fallback;
  }

  static String resolveDestinationCountryIso({
    String? cityCountryCode,
    String? planDestinationCountry,
    String fallback = 'BR',
  }) {
    return normalizeCountryIso(cityCountryCode) ??
        normalizeCountryIso(planDestinationCountry) ??
        fallback;
  }

  static Airport? resolveOriginAirport({
    LocationData? savedLocation,
    required String originCountryIso,
  }) {
    final normalizedOrigin = normalizeCountryIso(originCountryIso);
    final normalizedSavedCountry = normalizeCountryIso(
      savedLocation?.countryCode,
    );

    if (savedLocation != null &&
        normalizedOrigin != null &&
        normalizedSavedCountry == normalizedOrigin) {
      final nearest = _finder.findNearest(
        latitude: savedLocation.latitude,
        longitude: savedLocation.longitude,
        countryIso: normalizedOrigin,
        maxResults: 1,
      );
      if (nearest.isNotEmpty) {
        return nearest.first;
      }
    }

    if (normalizedOrigin == null) {
      return null;
    }
    return AirportDatabase.mainHubFor(normalizedOrigin);
  }

  static Airport? resolveDestinationAirport({
    String? destinationCityName,
    String? destinationCountryIso,
    double? destinationLatitude,
    double? destinationLongitude,
  }) {
    final normalizedCountry = normalizeCountryIso(destinationCountryIso);
    if (normalizedCountry == null) {
      return null;
    }

    final normalizedCity = destinationCityName?.trim();
    if (normalizedCity != null && normalizedCity.isNotEmpty) {
      final directMatch = AirportDatabase.forCityName(
        normalizedCity,
        normalizedCountry,
      );
      if (directMatch != null) {
        return directMatch;
      }
    }

    if (destinationLatitude != null && destinationLongitude != null) {
      final nearest = _finder.findNearest(
        latitude: destinationLatitude,
        longitude: destinationLongitude,
        countryIso: normalizedCountry,
        maxResults: 1,
      );
      if (nearest.isNotEmpty) {
        return nearest.first;
      }
    }

    return AirportDatabase.mainHubFor(normalizedCountry);
  }
}

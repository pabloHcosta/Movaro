import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/journey/detected_location.dart';

enum DeviceLocationOutcome {
  available,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  failed,
}

class DeviceLocationLookupResult {
  const DeviceLocationLookupResult({required this.outcome, this.location});

  final DeviceLocationOutcome outcome;
  final DetectedLocation? location;
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<DeviceLocationLookupResult> detectCountryHint(
    List<CatalogCountry> countries,
  ) async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return const DeviceLocationLookupResult(
        outcome: DeviceLocationOutcome.servicesDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const DeviceLocationLookupResult(
        outcome: DeviceLocationOutcome.permissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const DeviceLocationLookupResult(
        outcome: DeviceLocationOutcome.permissionDeniedForever,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isEmpty ? null : placemarks.first;
      final country = _resolveCountry(
        countries,
        countryName: placemark?.country,
        isoCode: placemark?.isoCountryCode,
      );

      return DeviceLocationLookupResult(
        outcome: DeviceLocationOutcome.available,
        location: DetectedLocation(
          countryId: country?.id,
          countryName: placemark?.country ?? country?.name ?? '',
          city: placemark?.locality,
          region: placemark?.administrativeArea,
          latitude: position.latitude,
          longitude: position.longitude,
          detectedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      return const DeviceLocationLookupResult(
        outcome: DeviceLocationOutcome.failed,
      );
    }
  }

  CatalogCountry? _resolveCountry(
    List<CatalogCountry> countries, {
    String? countryName,
    String? isoCode,
  }) {
    final normalizedCountry = _normalize(countryName);
    final normalizedIso = _normalize(isoCode);

    for (final country in countries) {
      if (normalizedIso.isNotEmpty &&
          _normalize(country.isoCode) == normalizedIso) {
        return country;
      }

      if (normalizedCountry == _normalize(country.name)) {
        return country;
      }

      if (country.locationAliases.any(
        (alias) => _normalize(alias) == normalizedCountry,
      )) {
        return country;
      }
    }

    return null;
  }

  String _normalize(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

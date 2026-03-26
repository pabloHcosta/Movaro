import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movaro_app/features/location/location_data.dart';

class LocationService {
  const LocationService();

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<LocationData?> reverseGeocode(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      return LocationData(
        cityName: place.locality ?? place.subAdministrativeArea ?? '',
        stateName: place.administrativeArea ?? '',
        countryName: place.country ?? '',
        countryCode: place.isoCountryCode ?? '',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}

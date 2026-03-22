import 'dart:math' as math;

import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/flight_search/domain/models/airport.dart';

/// Finds airports near the user's GPS position using the Haversine formula.
class AirportFinderService {
  const AirportFinderService();

  static const _earthRadiusKm = 6371.0;

  /// Returns up to [maxResults] airports for [countryIso], ordered by distance
  /// from the provided coordinates (nearest first).
  ///
  /// Falls back to the full country list when there are fewer airports than
  /// [maxResults].
  List<Airport> findNearest({
    required double latitude,
    required double longitude,
    required String countryIso,
    int maxResults = 3,
  }) {
    final airports = AirportDatabase.forCountry(countryIso);
    if (airports.isEmpty) return const [];

    final scored = airports.map((a) {
      final dist = _haversineKm(latitude, longitude, a.latitude, a.longitude);
      return (airport: a, distanceKm: dist);
    }).toList()
      ..sort((x, y) => x.distanceKm.compareTo(y.distanceKm));

    return scored.take(maxResults).map((e) => e.airport).toList();
  }

  /// Haversine great-circle distance in kilometres.
  double _haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  double _toRad(double deg) => deg * math.pi / 180;
}

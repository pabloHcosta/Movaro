import 'package:movaro_app/features/flight_search/domain/models/airport.dart';

/// Immutable parameters for a one-way flight search.
///
/// Migration is a one-way journey — no return date is ever included.
class FlightSearchParams {
  const FlightSearchParams({
    required this.origin,
    required this.destination,
    required this.departureDate,
  });

  final Airport origin;
  final Airport destination;

  /// Departure date. Always required — the search button is disabled until
  /// this field is populated.
  final DateTime departureDate;
}

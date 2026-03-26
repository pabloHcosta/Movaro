import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';

void main() {
  group('FlightRouteContextResolver.resolveDestinationAirport', () {
    test('matches destination city names even without accents', () {
      final airport = FlightRouteContextResolver.resolveDestinationAirport(
        destinationCityName: 'Joao Pessoa',
        destinationCountryIso: 'BR',
      );

      expect(airport?.iataCode, 'JPA');
    });

    test('falls back to the nearest airport when the city has no airport', () {
      final airport = FlightRouteContextResolver.resolveDestinationAirport(
        destinationCityName: 'Caruaru',
        destinationCountryIso: 'BR',
        destinationLatitude: -8.2842,
        destinationLongitude: -35.9699,
      );

      expect(airport?.iataCode, 'REC');
    });
  });
}

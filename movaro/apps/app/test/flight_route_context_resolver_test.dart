import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/flight_search/data/airport_database.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_logistics_assessment_service.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_price_insight_service.dart';
import 'package:movaro_app/features/location/location_data.dart';

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

  group('origin-aware flight logistics', () {
    const salta = LocationData(
      cityName: 'Salta',
      stateName: 'Salta',
      countryName: 'Argentina',
      countryCode: 'AR',
      latitude: -24.7821,
      longitude: -65.4232,
    );

    test('flags a Salta to Northeast route as high connection pressure', () {
      final origin = FlightRouteContextResolver.resolveOriginAirport(
        savedLocation: salta,
        originCountryIso: 'AR',
      );
      final destination = AirportDatabase.forIata('MCZ');
      final assessment = FlightLogisticsAssessmentService.assess(
        originLocation: salta,
        originAirport: origin,
        destinationAirport: destination,
      );

      expect(origin?.iataCode, 'SLA');
      expect(assessment?.connectionPressure, FlightConnectionPressure.high);
      expect(assessment?.shouldHighlight, isTrue);
    });

    test('keeps a Brazilian gateway route below high pressure', () {
      final origin = AirportDatabase.forIata('SLA');
      final destination = AirportDatabase.forIata('FLN');
      final assessment = FlightLogisticsAssessmentService.assess(
        originLocation: salta,
        originAirport: origin,
        destinationAirport: destination,
      );

      expect(assessment?.connectionPressure, FlightConnectionPressure.medium);
    });

    test('creates a modeled route fallback for the confirmed origin', () {
      final route = FlightRoutePriceInsightService.resolveTravelRoute(
        originIata: 'SLA',
        destIata: 'MCZ',
      );

      expect(route, isNotNull);
      expect(route?.originIata, 'SLA');
      expect(route?.destIata, 'MCZ');
      expect(route?.sourceType, 'modeled_estimate');
      expect(route!.lowUsdMin, greaterThan(215));
    });
  });

  group('Argentina-wide origin coverage', () {
    final localityCases = <({LocationData location, String airportIata})>[
      (
        location: const LocationData(
          cityName: 'Buenos Aires',
          stateName: 'Ciudad Autónoma de Buenos Aires',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -34.6037,
          longitude: -58.3816,
        ),
        airportIata: 'AEP',
      ),
      (
        location: const LocationData(
          cityName: 'Córdoba',
          stateName: 'Córdoba',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -31.4201,
          longitude: -64.1888,
        ),
        airportIata: 'COR',
      ),
      (
        location: const LocationData(
          cityName: 'Mendoza',
          stateName: 'Mendoza',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -32.8895,
          longitude: -68.8458,
        ),
        airportIata: 'MDZ',
      ),
      (
        location: const LocationData(
          cityName: 'San Salvador de Jujuy',
          stateName: 'Jujuy',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -24.1858,
          longitude: -65.2995,
        ),
        airportIata: 'JUJ',
      ),
      (
        location: const LocationData(
          cityName: 'Posadas',
          stateName: 'Misiones',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -27.3621,
          longitude: -55.9009,
        ),
        airportIata: 'PSS',
      ),
      (
        location: const LocationData(
          cityName: 'San Carlos de Bariloche',
          stateName: 'Río Negro',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -41.1335,
          longitude: -71.3103,
        ),
        airportIata: 'BRC',
      ),
      (
        location: const LocationData(
          cityName: 'Ushuaia',
          stateName: 'Tierra del Fuego',
          countryName: 'Argentina',
          countryCode: 'AR',
          latitude: -54.8019,
          longitude: -68.3030,
        ),
        airportIata: 'USH',
      ),
    ];

    for (final testCase in localityCases) {
      test(
        'resolves ${testCase.location.cityName} to ${testCase.airportIata}',
        () {
          final airport = FlightRouteContextResolver.resolveOriginAirport(
            savedLocation: testCase.location,
            originCountryIso: 'AR',
          );

          expect(airport?.iataCode, testCase.airportIata);
        },
      );
    }

    test('has route estimates for every registered Argentine airport', () {
      final argentineAirports = AirportDatabase.forCountry('AR');

      expect(argentineAirports, isNotEmpty);
      for (final airport in argentineAirports) {
        final route = FlightRoutePriceInsightService.resolveTravelRoute(
          originIata: airport.iataCode,
          destIata: 'FLN',
        );
        expect(
          route,
          isNotNull,
          reason: 'Missing origin coverage for ${airport.iataCode}',
        );
      }
    });
  });
}

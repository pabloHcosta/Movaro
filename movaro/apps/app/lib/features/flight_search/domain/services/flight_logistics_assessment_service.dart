import 'package:movaro_app/features/flight_search/domain/models/airport.dart';
import 'package:movaro_app/features/flight_search/domain/services/airport_finder_service.dart';
import 'package:movaro_app/features/location/location_data.dart';

enum FlightConnectionPressure { low, medium, high }

class FlightLogisticsAssessment {
  const FlightLogisticsAssessment({
    required this.originCity,
    required this.originAirport,
    required this.destinationAirport,
    required this.airportAccessKm,
    required this.connectionPressure,
  });

  final String originCity;
  final Airport originAirport;
  final Airport destinationAirport;
  final int airportAccessKm;
  final FlightConnectionPressure connectionPressure;

  bool get shouldHighlight =>
      connectionPressure != FlightConnectionPressure.low ||
      airportAccessKm >= 120;
}

class FlightLogisticsAssessmentService {
  const FlightLogisticsAssessmentService._();

  static const _finder = AirportFinderService();
  static const _majorArgentinaGateways = {'EZE', 'AEP'};
  static const _regionalArgentinaGateways = {'COR', 'MDZ', 'ROS'};
  static const _majorBrazilGateways = {'GRU', 'GIG', 'FLN', 'POA'};

  static FlightLogisticsAssessment? assess({
    required LocationData? originLocation,
    required Airport? originAirport,
    required Airport? destinationAirport,
  }) {
    if (originLocation == null ||
        originAirport == null ||
        destinationAirport == null) {
      return null;
    }

    final accessKm = _finder
        .distanceKm(
          fromLatitude: originLocation.latitude,
          fromLongitude: originLocation.longitude,
          toLatitude: originAirport.latitude,
          toLongitude: originAirport.longitude,
        )
        .round();
    final originIata = originAirport.iataCode.toUpperCase();
    final destinationIata = destinationAirport.iataCode.toUpperCase();
    final isBrazilGateway = _majorBrazilGateways.contains(destinationIata);

    var pressure = switch (originIata) {
      final value when _majorArgentinaGateways.contains(value) =>
        isBrazilGateway
            ? FlightConnectionPressure.low
            : FlightConnectionPressure.medium,
      final value when _regionalArgentinaGateways.contains(value) =>
        isBrazilGateway
            ? FlightConnectionPressure.medium
            : FlightConnectionPressure.high,
      _ =>
        isBrazilGateway
            ? FlightConnectionPressure.medium
            : FlightConnectionPressure.high,
    };

    if (accessKm >= 180) {
      pressure = FlightConnectionPressure.high;
    } else if (accessKm >= 120 && pressure == FlightConnectionPressure.low) {
      pressure = FlightConnectionPressure.medium;
    }

    return FlightLogisticsAssessment(
      originCity: originLocation.cityName.isNotEmpty
          ? originLocation.cityName
          : originLocation.stateName,
      originAirport: originAirport,
      destinationAirport: destinationAirport,
      airportAccessKm: accessKm,
      connectionPressure: pressure,
    );
  }
}

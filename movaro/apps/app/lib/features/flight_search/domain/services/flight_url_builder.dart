import 'package:movaro_app/features/flight_search/domain/models/flight_search_params.dart';

/// Builds a stable Google Flights deep-link from [FlightSearchParams].
///
/// URL format (tested March 2026):
///   https://www.google.com/travel/flights?q=Flights+from+EZE+to+GRU+on+2025-05-15
///
/// Language (`hl`) is derived from the origin country. Currency can be supplied
/// from the app-wide preference and defaults to USD.
///
/// Examples:
///   AR origin → &curr=ARS&hl=es    (Spanish, Argentine Peso)
///   BR origin → &curr=BRL&hl=pt-BR (Portuguese, Brazilian Real)
class FlightUrlBuilder {
  const FlightUrlBuilder._();

  /// Maps ISO country code → (currency, language tag).
  static const Map<String, ({String curr, String hl})> _localeByCountry = {
    'AR': (curr: 'ARS', hl: 'es'),
    'BR': (curr: 'BRL', hl: 'pt-BR'),
    'CL': (curr: 'CLP', hl: 'es'),
    'UY': (curr: 'UYU', hl: 'es'),
    'PY': (curr: 'PYG', hl: 'es'),
    'CO': (curr: 'COP', hl: 'es'),
    'PE': (curr: 'PEN', hl: 'es'),
    'MX': (curr: 'MXN', hl: 'es'),
    'US': (curr: 'USD', hl: 'en'),
  };

  static Uri build(FlightSearchParams params, {String currencyCode = 'USD'}) {
    final origin = params.origin.iataCode;
    final destination = params.destination.iataCode;
    final date = _formatDate(params.departureDate);

    final query = 'Flights from $origin to $destination on $date';

    // Locale is driven by where the user is flying FROM, not where they go.
    final locale = _localeByCountry[params.origin.countryIso.toUpperCase()];
    final supportedCurrency =
        const {'USD', 'BRL', 'ARS', 'CLP'}.contains(currencyCode.toUpperCase())
        ? currencyCode.toUpperCase()
        : 'USD';
    final languageParam = locale == null ? '' : '&hl=${locale.hl}';
    final extraParams = '&curr=$supportedCurrency$languageParam';

    return Uri.parse(
      'https://www.google.com/travel/flights'
      '?q=${Uri.encodeComponent(query)}'
      '$extraParams',
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';
}

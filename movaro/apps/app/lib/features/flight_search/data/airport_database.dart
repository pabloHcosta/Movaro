import 'package:movaro_app/features/flight_search/domain/models/airport.dart';

/// Static in-memory airport catalogue, keyed by ISO country code.
///
/// Data is [const] — zero I/O overhead at runtime.
/// Extend by adding entries to [airportsByCountry].
class AirportDatabase {
  const AirportDatabase._();

  // ── Argentina ─────────────────────────────────────────────────────────────

  static const _ezeiza = Airport(
    iataCode: 'EZE',
    name: 'Ministro Pistarini',
    city: 'Buenos Aires',
    countryIso: 'AR',
    region: 'Buenos Aires',
    latitude: -34.8222,
    longitude: -58.5358,
    isMainHub: true,
  );

  static const _aeroparque = Airport(
    iataCode: 'AEP',
    name: 'Jorge Newbery',
    city: 'Buenos Aires',
    countryIso: 'AR',
    region: 'Buenos Aires',
    latitude: -34.5592,
    longitude: -58.4156,
    isMainHub: true,
  );

  static const _cordoba = Airport(
    iataCode: 'COR',
    name: 'Ambrosio Taravella',
    city: 'Córdoba',
    countryIso: 'AR',
    region: 'Córdoba',
    latitude: -31.3236,
    longitude: -64.2080,
  );

  static const _rosario = Airport(
    iataCode: 'ROS',
    name: 'Islas Malvinas',
    city: 'Rosário',
    countryIso: 'AR',
    region: 'Santa Fe',
    latitude: -32.9036,
    longitude: -60.7855,
  );

  static const _mendoza = Airport(
    iataCode: 'MDZ',
    name: 'El Plumerillo',
    city: 'Mendoza',
    countryIso: 'AR',
    region: 'Mendoza',
    latitude: -32.8317,
    longitude: -68.7929,
  );

  static const _bariloche = Airport(
    iataCode: 'BRC',
    name: 'Teniente Candelaria',
    city: 'Bariloche',
    countryIso: 'AR',
    region: 'Río Negro',
    latitude: -41.1512,
    longitude: -71.1575,
  );

  static const _salta = Airport(
    iataCode: 'SLA',
    name: 'Martín Miguel de Güemes',
    city: 'Salta',
    countryIso: 'AR',
    region: 'Salta',
    latitude: -24.8560,
    longitude: -65.4862,
  );

  static const _tucuman = Airport(
    iataCode: 'TUC',
    name: 'Benjamín Matienzo',
    city: 'Tucumán',
    countryIso: 'AR',
    region: 'Tucumán',
    latitude: -26.8409,
    longitude: -65.1049,
  );

  static const _marDelPlata = Airport(
    iataCode: 'MDQ',
    name: 'Ástor Piazzolla',
    city: 'Mar del Plata',
    countryIso: 'AR',
    region: 'Buenos Aires',
    latitude: -37.9342,
    longitude: -57.5733,
  );

  static const _neuquen = Airport(
    iataCode: 'NQN',
    name: 'Presidente Perón',
    city: 'Neuquén',
    countryIso: 'AR',
    region: 'Neuquén',
    latitude: -38.9490,
    longitude: -68.1557,
  );

  static const _jujuy = Airport(
    iataCode: 'JUJ',
    name: 'Gobernador Horacio Guzmán',
    city: 'Jujuy',
    countryIso: 'AR',
    region: 'Jujuy',
    latitude: -24.3928,
    longitude: -65.0978,
  );

  static const _posadas = Airport(
    iataCode: 'PSS',
    name: 'Libertador General San Martín',
    city: 'Posadas',
    countryIso: 'AR',
    region: 'Misiones',
    latitude: -27.3858,
    longitude: -55.9709,
  );

  static const _rioGallegos = Airport(
    iataCode: 'RGL',
    name: 'Piloto Civil Norberto Fernández',
    city: 'Río Gallegos',
    countryIso: 'AR',
    region: 'Santa Cruz',
    latitude: -51.6089,
    longitude: -69.3126,
  );

  static const _elCalafate = Airport(
    iataCode: 'FTE',
    name: 'Comandante Armando Tola',
    city: 'El Calafate',
    countryIso: 'AR',
    region: 'Santa Cruz',
    latitude: -50.2803,
    longitude: -72.0531,
  );

  static const _ushuaia = Airport(
    iataCode: 'USH',
    name: 'Malvinas Argentinas',
    city: 'Ushuaia',
    countryIso: 'AR',
    region: 'Tierra del Fuego',
    latitude: -54.8433,
    longitude: -68.2958,
  );

  static const _comodoro = Airport(
    iataCode: 'CRD',
    name: 'General Enrique Mosconi',
    city: 'Comodoro Rivadavia',
    countryIso: 'AR',
    region: 'Chubut',
    latitude: -45.7853,
    longitude: -67.4655,
  );

  static const _trelew = Airport(
    iataCode: 'REL',
    name: 'Almirante Marcos A. Zar',
    city: 'Trelew',
    countryIso: 'AR',
    region: 'Chubut',
    latitude: -43.2105,
    longitude: -65.2703,
  );

  static const _sanJuan = Airport(
    iataCode: 'UAQ',
    name: 'Domingo Faustino Sarmiento',
    city: 'San Juan',
    countryIso: 'AR',
    region: 'San Juan',
    latitude: -31.5715,
    longitude: -68.4182,
  );

  static const _resistencia = Airport(
    iataCode: 'RES',
    name: 'Resistencia',
    city: 'Resistencia',
    countryIso: 'AR',
    region: 'Chaco',
    latitude: -27.4500,
    longitude: -59.0561,
  );

  // ── Brazil ─────────────────────────────────────────────────────────────────

  static const _guarulhos = Airport(
    iataCode: 'GRU',
    name: 'Guarulhos / André Franco Montoro',
    city: 'São Paulo',
    countryIso: 'BR',
    region: 'São Paulo',
    latitude: -23.4356,
    longitude: -46.4731,
    isMainHub: true,
  );

  static const _viracopos = Airport(
    iataCode: 'VCP',
    name: 'Viracopos / Campinas',
    city: 'Campinas',
    countryIso: 'BR',
    region: 'São Paulo',
    latitude: -23.0075,
    longitude: -47.1345,
  );

  static const _galeao = Airport(
    iataCode: 'GIG',
    name: 'Galeão / Tom Jobim',
    city: 'Rio de Janeiro',
    countryIso: 'BR',
    region: 'Rio de Janeiro',
    latitude: -22.8100,
    longitude: -43.2506,
    isMainHub: true,
  );

  static const _florianopolis = Airport(
    iataCode: 'FLN',
    name: 'Hercílio Luz',
    city: 'Florianópolis',
    countryIso: 'BR',
    region: 'Santa Catarina',
    latitude: -27.6703,
    longitude: -48.5525,
  );

  static const _curitiba = Airport(
    iataCode: 'CWB',
    name: 'Afonso Pena',
    city: 'Curitiba',
    countryIso: 'BR',
    region: 'Paraná',
    latitude: -25.5285,
    longitude: -49.1758,
  );

  static const _portoAlegre = Airport(
    iataCode: 'POA',
    name: 'Salgado Filho',
    city: 'Porto Alegre',
    countryIso: 'BR',
    region: 'Rio Grande do Sul',
    latitude: -29.9944,
    longitude: -51.1714,
  );

  static const _beloBrizonte = Airport(
    iataCode: 'CNF',
    name: 'Confins / Tancredo Neves',
    city: 'Belo Horizonte',
    countryIso: 'BR',
    region: 'Minas Gerais',
    latitude: -19.6244,
    longitude: -43.9719,
  );

  static const _brasilia = Airport(
    iataCode: 'BSB',
    name: 'Presidente Juscelino Kubitschek',
    city: 'Brasília',
    countryIso: 'BR',
    region: 'Distrito Federal',
    latitude: -15.8711,
    longitude: -47.9186,
  );

  static const _salvador = Airport(
    iataCode: 'SSA',
    name: 'Deputado Luís Eduardo Magalhães',
    city: 'Salvador',
    countryIso: 'BR',
    region: 'Bahia',
    latitude: -12.9086,
    longitude: -38.3225,
  );

  static const _recife = Airport(
    iataCode: 'REC',
    name: 'Guararapes / Gilberto Freyre',
    city: 'Recife',
    countryIso: 'BR',
    region: 'Pernambuco',
    latitude: -8.1265,
    longitude: -34.9227,
  );

  static const _fortaleza = Airport(
    iataCode: 'FOR',
    name: 'Pinto Martins',
    city: 'Fortaleza',
    countryIso: 'BR',
    region: 'Ceará',
    latitude: -3.7761,
    longitude: -38.5322,
  );

  static const _manaus = Airport(
    iataCode: 'MAO',
    name: 'Eduardo Gomes',
    city: 'Manaus',
    countryIso: 'BR',
    region: 'Amazonas',
    latitude: -3.0386,
    longitude: -60.0497,
  );

  static const _navegantes = Airport(
    iataCode: 'NVT',
    name: 'Navegantes / Ministro Victor Konder',
    city: 'Navegantes',
    countryIso: 'BR',
    region: 'Santa Catarina',
    latitude: -26.8797,
    longitude: -48.6514,
  );

  static const _joaoPessoa = Airport(
    iataCode: 'JPA',
    name: 'Presidente Castro Pinto',
    city: 'João Pessoa',
    countryIso: 'BR',
    region: 'Paraíba',
    latitude: -7.1458,
    longitude: -34.9486,
  );

  static const _natal = Airport(
    iataCode: 'NAT',
    name: 'Governador Aluízio Alves',
    city: 'Natal',
    countryIso: 'BR',
    region: 'Rio Grande do Norte',
    latitude: -5.7681,
    longitude: -35.3761,
  );

  static const _aracaju = Airport(
    iataCode: 'AJU',
    name: 'Santa Maria',
    city: 'Aracaju',
    countryIso: 'BR',
    region: 'Sergipe',
    latitude: -10.9840,
    longitude: -37.0703,
  );

  static const _maceio = Airport(
    iataCode: 'MCZ',
    name: 'Zumbi dos Palmares',
    city: 'Maceió',
    countryIso: 'BR',
    region: 'Alagoas',
    latitude: -9.5108,
    longitude: -35.7917,
  );

  static const _belem = Airport(
    iataCode: 'BEL',
    name: 'Val-de-Cans / Júlio Cezar Ribeiro',
    city: 'Belém',
    countryIso: 'BR',
    region: 'Pará',
    latitude: -1.3793,
    longitude: -48.4763,
  );

  static const _campoGrande = Airport(
    iataCode: 'CGR',
    name: 'Campo Grande',
    city: 'Campo Grande',
    countryIso: 'BR',
    region: 'Mato Grosso do Sul',
    latitude: -20.4687,
    longitude: -54.6725,
  );

  // ── Public catalogue ───────────────────────────────────────────────────────

  static const Map<String, List<Airport>> airportsByCountry = {
    'AR': [
      _ezeiza,
      _aeroparque,
      _cordoba,
      _rosario,
      _mendoza,
      _bariloche,
      _salta,
      _tucuman,
      _marDelPlata,
      _neuquen,
      _jujuy,
      _posadas,
      _rioGallegos,
      _elCalafate,
      _ushuaia,
      _comodoro,
      _trelew,
      _sanJuan,
      _resistencia,
    ],
    'BR': [
      _guarulhos,
      _viracopos,
      _galeao,
      _florianopolis,
      _navegantes,
      _curitiba,
      _portoAlegre,
      _beloBrizonte,
      _brasilia,
      _salvador,
      _recife,
      _fortaleza,
      _natal,
      _joaoPessoa,
      _aracaju,
      _maceio,
      _campoGrande,
      _manaus,
      _belem,
    ],
  };

  /// Returns all airports for [countryIso], or an empty list if unknown.
  static List<Airport> forCountry(String countryIso) =>
      airportsByCountry[countryIso.toUpperCase()] ?? const [];

  /// Returns the main international hub for [countryIso], or null.
  static Airport? mainHubFor(String countryIso) {
    final airports = forCountry(countryIso);
    for (final a in airports) {
      if (a.isMainHub) return a;
    }
    return airports.isEmpty ? null : airports.first;
  }

  /// Returns the airport that best matches the given [cityName] by checking
  /// whether the city name contains the airport's city (case-insensitive).
  static Airport? forCityName(String cityName, String countryIso) {
    final normalised = _normalizeText(cityName);
    final airports = forCountry(countryIso);
    for (final a in airports) {
      final airportCity = _normalizeText(a.city);
      final airportRegion = _normalizeText(a.region);
      if (normalised.contains(airportCity) ||
          airportCity.contains(normalised) ||
          normalised.contains(airportRegion)) {
        return a;
      }
    }
    return null;
  }

  static String _normalizeText(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    final buffer = StringBuffer();
    for (final rune in value.trim().toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}

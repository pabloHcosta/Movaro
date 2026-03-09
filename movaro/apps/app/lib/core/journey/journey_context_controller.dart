import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/journey/journey_preferences_store.dart';
import 'package:movaro_app/core/journey/journey_selection.dart';

class JourneyContextController extends ChangeNotifier {
  JourneyContextController({
    required CatalogRepository catalogRepository,
    JourneyPreferencesStore? store,
  }) : _catalogRepository = catalogRepository,
       _store = store ?? JourneyPreferencesStore();

  final CatalogRepository _catalogRepository;
  final JourneyPreferencesStore _store;

  List<CatalogCountry> _countries = const [];
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasSeenIntro = false;
  String? _originCountryId;
  String? _destinationCountryId;

  List<CatalogCountry> get countries => _countries;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasSeenIntro => _hasSeenIntro;
  String? get originCountryId => _originCountryId;
  String? get destinationCountryId => _destinationCountryId;

  CatalogCountry? get selectedOrigin =>
      _firstWhereOrNull((country) => country.id == _originCountryId);

  CatalogCountry? get selectedDestination =>
      _firstWhereOrNull((country) => country.id == _destinationCountryId);

  JourneySelection get selection => JourneySelection(
    origin: selectedOrigin,
    destination: selectedDestination,
  );

  bool get hasSelectedJourney => selection.isComplete;

  bool get hasSupportedJourney =>
      _originCountryId == 'argentina' && _destinationCountryId == 'brasil';

  List<CatalogCountry> get availableOrigins => _countries;

  List<CatalogCountry> get availableDestinations => _countries;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _countries = await _catalogRepository.getCountries();
      final persisted = await _store.read();
      _hasSeenIntro = persisted['hasSeenIntro'] == true;
      _originCountryId = _resolveCountryId(persisted['originCountryId']);
      _destinationCountryId = _resolveCountryId(
        persisted['destinationCountryId'],
      );
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markIntroSeen() async {
    _hasSeenIntro = true;
    await _persist();
    notifyListeners();
  }

  Future<void> setOriginCountry(String countryId) async {
    _originCountryId = countryId;

    if (_destinationCountryId == countryId) {
      _destinationCountryId = null;
    }

    await _persist();
    notifyListeners();
  }

  Future<void> setDestinationCountry(String countryId) async {
    _destinationCountryId = countryId;
    await _persist();
    notifyListeners();
  }

  Future<void> completeJourney({
    required String originCountryId,
    required String destinationCountryId,
  }) async {
    _originCountryId = originCountryId;
    _destinationCountryId = destinationCountryId;
    await _persist();
    notifyListeners();
  }

  Future<void> clearJourney() async {
    _originCountryId = null;
    _destinationCountryId = null;
    await _persist();
    notifyListeners();
  }

  bool isOriginAvailableNow(CatalogCountry country) => country.id == 'argentina';

  bool isDestinationAvailableNow(CatalogCountry country) =>
      country.id == 'brasil';

  bool canUseAsOrigin(CatalogCountry country) => isOriginAvailableNow(country);

  bool canUseAsDestination(CatalogCountry country) =>
      isDestinationAvailableNow(country);

  String journeyValueFor(CatalogCountry? country) =>
      country?.journeyValue ?? '';

  String? _resolveCountryId(Object? rawValue) {
    if (rawValue is! String) {
      return null;
    }

    return _firstWhereOrNull((country) => country.id == rawValue)?.id;
  }

  CatalogCountry? _firstWhereOrNull(
    bool Function(CatalogCountry country) predicate,
  ) {
    for (final country in _countries) {
      if (predicate(country)) {
        return country;
      }
    }

    return null;
  }

  Future<void> _persist() {
    return _store.write({
      'hasSeenIntro': _hasSeenIntro,
      'originCountryId': _originCountryId,
      'destinationCountryId': _destinationCountryId,
    });
  }
}

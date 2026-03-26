import 'package:flutter/foundation.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/features/journey/active_journey.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/journey/journey_country_metadata.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/journey/journey_selection.dart';
import 'package:movaro_app/features/journey/supported_country.dart';
import 'package:movaro_app/features/location/device_location_service.dart';

class JourneyContextController extends ChangeNotifier {
  JourneyContextController({
    required CatalogRepository catalogRepository,
    JourneyPreferencesStore? store,
    DeviceLocationService? locationService,
  }) : _catalogRepository = catalogRepository,
       _store = store ?? JourneyPreferencesStore(),
       _locationService = locationService ?? const DeviceLocationService();

  final CatalogRepository _catalogRepository;
  final JourneyPreferencesStore _store;
  final DeviceLocationService _locationService;

  List<CatalogCountry> _countries = const [];
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasSeenIntro = false;
  String? _originCountryId;
  String? _destinationCountryId;
  DetectedLocation? _detectedLocation;
  DetectedLocationRequestState _detectedLocationState =
      DetectedLocationRequestState.idle;

  List<CatalogCountry> get countries => _countries;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasSeenIntro => _hasSeenIntro;
  String? get originCountryId => _originCountryId;
  String? get destinationCountryId => _destinationCountryId;
  DetectedLocation? get detectedLocation => _detectedLocation;
  DetectedLocationRequestState get detectedLocationState =>
      _detectedLocationState;
  bool get isDetectingLocation =>
      _detectedLocationState == DetectedLocationRequestState.requesting;

  CatalogCountry? get selectedOrigin =>
      _firstWhereOrNull((country) => country.id == _originCountryId);

  CatalogCountry? get selectedDestination =>
      _firstWhereOrNull((country) => country.id == _destinationCountryId);

  JourneySelection get selection => JourneySelection(
    origin: selectedOrigin,
    destination: selectedDestination,
  );

  List<SupportedCountry> get supportedCountries => _countries
      .map(
        (country) =>
            SupportedCountry(country: country, coverage: country.coverage),
      )
      .toList(growable: false);

  ActiveJourney get activeJourney => ActiveJourney(
    detectedLocation: _detectedLocation,
    origin: selectedOrigin,
    destination: selectedDestination,
    isSupportedRoute: _isSupportedRoute(
      originCountryId: _originCountryId,
      destinationCountryId: _destinationCountryId,
    ),
  );

  bool get hasJourneyDraft =>
      _originCountryId != null ||
      _destinationCountryId != null ||
      _detectedLocation != null;

  bool get hasDestinationSelected => selectedDestination != null;
  bool get hasDetectedLocation => _detectedLocation != null;
  bool get hasSelectedJourney => selection.isComplete;

  bool get isJourneyReadyForPlanning =>
      selection.isComplete &&
      _isSupportedRoute(
        originCountryId: _originCountryId,
        destinationCountryId: _destinationCountryId,
      );

  bool get canEnterQuestionnaire {
    final destination = selectedDestination;
    if (destination == null || !destination.coverage.canPlanAsDestination) {
      return false;
    }

    if (_originCountryId == null) {
      return true;
    }

    return isJourneyReadyForPlanning;
  }

  bool get hasSupportedJourney => isJourneyReadyForPlanning;

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
      final detectedLocationJson = persisted['detectedLocation'];
      if (detectedLocationJson is Map<String, dynamic>) {
        _detectedLocation = DetectedLocation.fromJson(detectedLocationJson);
      } else if (detectedLocationJson is Map) {
        _detectedLocation = DetectedLocation.fromJson(
          detectedLocationJson.cast<String, dynamic>(),
        );
      }
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
    _originCountryId = _resolveCountryId(countryId) ?? countryId;

    if (_destinationCountryId == _originCountryId) {
      _destinationCountryId = null;
    }

    await _persist();
    notifyListeners();
  }

  Future<void> clearOriginCountry() async {
    _originCountryId = null;
    await _persist();
    notifyListeners();
  }

  Future<void> setDestinationCountry(String countryId) async {
    _destinationCountryId = _resolveCountryId(countryId) ?? countryId;

    if (_originCountryId == _destinationCountryId) {
      _originCountryId = null;
    }

    await _persist();
    notifyListeners();
  }

  Future<void> completeJourney({
    required String originCountryId,
    required String destinationCountryId,
  }) async {
    _originCountryId = _resolveCountryId(originCountryId) ?? originCountryId;
    _destinationCountryId =
        _resolveCountryId(destinationCountryId) ?? destinationCountryId;
    await _persist();
    notifyListeners();
  }

  Future<void> setDetectedLocation(DetectedLocation? location) async {
    _detectedLocation = location;
    _detectedLocationState = location == null
        ? DetectedLocationRequestState.idle
        : DetectedLocationRequestState.available;
    await _persist();
    notifyListeners();
  }

  Future<void> clearDetectedLocation() async {
    _detectedLocation = null;
    _detectedLocationState = DetectedLocationRequestState.idle;
    await _persist();
    notifyListeners();
  }

  Future<DetectedLocationRequestState> requestDetectedLocation() async {
    _detectedLocationState = DetectedLocationRequestState.requesting;
    notifyListeners();

    final result = await _locationService.detectCountryHint(_countries);
    switch (result.outcome) {
      case DeviceLocationOutcome.available:
        _detectedLocation = result.location;
        _detectedLocationState = DetectedLocationRequestState.available;
      case DeviceLocationOutcome.permissionDenied:
        _detectedLocationState = DetectedLocationRequestState.denied;
      case DeviceLocationOutcome.permissionDeniedForever:
        _detectedLocationState = DetectedLocationRequestState.deniedForever;
      case DeviceLocationOutcome.servicesDisabled:
        _detectedLocationState = DetectedLocationRequestState.unavailable;
      case DeviceLocationOutcome.failed:
        _detectedLocationState = DetectedLocationRequestState.failed;
    }

    await _persist();
    notifyListeners();
    return _detectedLocationState;
  }

  Future<void> confirmDetectedCountryAsOrigin() async {
    final countryId = _detectedLocation?.countryId;
    if (countryId == null) {
      return;
    }
    await setOriginCountry(countryId);
  }

  Future<void> clearJourney() async {
    _originCountryId = null;
    _destinationCountryId = null;
    _detectedLocation = null;
    _detectedLocationState = DetectedLocationRequestState.idle;
    await _persist();
    notifyListeners();
  }

  bool isOriginAvailableNow(CatalogCountry country) =>
      country.coverage.canPlanAsOrigin;

  bool isDestinationAvailableNow(CatalogCountry country) =>
      country.coverage.canPlanAsDestination;

  bool canUseAsOrigin(CatalogCountry country) =>
      country.coverage.canPlanAsOrigin;

  bool canUseAsDestination(CatalogCountry country) =>
      country.coverage.canPlanAsDestination;

  bool canChooseAsOrigin(CatalogCountry country) =>
      country.coverage.canChooseAsOrigin;

  bool canChooseAsDestination(CatalogCountry country) =>
      country.coverage.canChooseAsDestination;

  bool isRouteSupported({
    String? originCountryId,
    String? destinationCountryId,
  }) {
    return _isSupportedRoute(
      originCountryId: originCountryId,
      destinationCountryId: destinationCountryId,
    );
  }

  String journeyValueFor(CatalogCountry? country) =>
      country?.journeyValue ?? '';

  String? _resolveCountryId(Object? rawValue) {
    if (rawValue is! String) {
      return null;
    }

    return _firstWhereOrNull(
      (country) =>
          country.id == rawValue ||
          country.journeyValue.toLowerCase() == rawValue.toLowerCase() ||
          country.isoCode.toLowerCase() == rawValue.toLowerCase(),
    )?.id;
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

  bool _isSupportedRoute({
    String? originCountryId,
    String? destinationCountryId,
  }) {
    if (originCountryId == null || destinationCountryId == null) {
      return false;
    }

    final origin = _firstWhereOrNull(
      (country) => country.id == originCountryId,
    );
    final destination = _firstWhereOrNull(
      (country) => country.id == destinationCountryId,
    );

    if (origin == null || destination == null) {
      return false;
    }

    return origin.coverage.canPlanAsOrigin &&
        destination.coverage.canPlanAsDestination &&
        origin.coverage.supportsDestination(destination.id);
  }

  Future<void> _persist() {
    return _store.write({
      'hasSeenIntro': _hasSeenIntro,
      'originCountryId': _originCountryId,
      'destinationCountryId': _destinationCountryId,
      'detectedLocation': _detectedLocation?.toJson(),
    });
  }
}

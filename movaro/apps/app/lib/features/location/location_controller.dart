import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/features/journey/detected_location.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/location/location_service.dart';
import 'package:movaro_app/features/location/location_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends ChangeNotifier {
  LocationController({
    required JourneyContextController journeyContextController,
    LocationStorage? storage,
    LocationService? service,
  }) : _journeyContextController = journeyContextController,
       _storage = storage ?? LocationStorage(),
       _service = service ?? const LocationService();

  final JourneyContextController _journeyContextController;
  final LocationStorage _storage;
  final LocationService _service;

  bool _isInitialized = false;
  bool _isBusy = false;
  String _permissionStatus = 'not_asked';
  bool _wasAsked = false;
  DateTime? _lastAskedAt;
  LocationData? _savedLocation;

  bool get isInitialized => _isInitialized;
  bool get isBusy => _isBusy;
  String get permissionStatus => _permissionStatus;
  bool get hasGrantedPermission => _permissionStatus == 'granted';
  bool get isPermanentlyDenied => _permissionStatus == 'permanently_denied';
  LocationData? get savedLocation => _savedLocation;
  String? get matchedCountryId => _matchCountry(_savedLocation)?.id;

  Future<void> initialize() async {
    if (_isInitialized) {
      await _syncDetectedLocation();
      notifyListeners();
      return;
    }

    _permissionStatus = await _storage.getPermissionStatus();
    _wasAsked = await _storage.wasPermissionAsked();
    _lastAskedAt = await _storage.getLastAskedDate();
    _savedLocation = await _storage.getSavedLocation();

    final nativeStatus = await Permission.locationWhenInUse.status;
    if (nativeStatus.isPermanentlyDenied && _permissionStatus != 'granted') {
      _permissionStatus = 'permanently_denied';
      await _storage.savePermissionStatus(_permissionStatus);
      _lastAskedAt = await _storage.getLastAskedDate();
    } else if (nativeStatus.isGranted && _permissionStatus != 'granted') {
      _permissionStatus = 'granted';
      await _storage.savePermissionStatus(_permissionStatus);
      _lastAskedAt = await _storage.getLastAskedDate();
    }

    _isInitialized = true;
    await _syncDetectedLocation();
    notifyListeners();
  }

  Future<bool> shouldRequestAgain() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_permissionStatus == 'permanently_denied') {
      return false;
    }

    if (_permissionStatus == 'granted') {
      return false;
    }

    if (!_wasAsked) {
      return true;
    }

    if (_permissionStatus == 'denied') {
      if (_lastAskedAt == null) {
        return true;
      }
      return DateTime.now().difference(_lastAskedAt!).inDays >= 7;
    }

    return true;
  }

  Future<bool> shouldShowInlineBanner() async {
    return shouldRequestAgain();
  }

  Future<void> deferPermission() async {
    await _storage.savePermissionStatus('denied');
    _permissionStatus = 'denied';
    _wasAsked = true;
    _lastAskedAt = await _storage.getLastAskedDate();
    notifyListeners();
  }

  Future<LocationPermissionRequestResult> requestPermissionAndCapture() async {
    _setBusy(true);
    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        await _storage.savePermissionStatus('denied');
        _permissionStatus = 'denied';
        _wasAsked = true;
        _lastAskedAt = await _storage.getLastAskedDate();
        notifyListeners();
        return const LocationPermissionRequestResult(
          outcome: LocationPermissionOutcome.denied,
        );
      }

      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _storage.savePermissionStatus('denied');
        _permissionStatus = 'denied';
        _wasAsked = true;
        _lastAskedAt = await _storage.getLastAskedDate();
        notifyListeners();
        return const LocationPermissionRequestResult(
          outcome: LocationPermissionOutcome.denied,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        await _storage.savePermissionStatus('permanently_denied');
        _permissionStatus = 'permanently_denied';
        _wasAsked = true;
        _lastAskedAt = await _storage.getLastAskedDate();
        notifyListeners();
        return const LocationPermissionRequestResult(
          outcome: LocationPermissionOutcome.permanentlyDenied,
        );
      }

      final position = await _service.getCurrentPosition();
      final location = position == null
          ? null
          : await _service.reverseGeocode(position);

      await _storage.savePermissionStatus('granted');
      _permissionStatus = 'granted';
      _wasAsked = true;
      _lastAskedAt = await _storage.getLastAskedDate();

      if (location != null) {
        _savedLocation = location;
        await _storage.saveLocation(location);
      }

      await _syncDetectedLocation();
      notifyListeners();
      return LocationPermissionRequestResult(
        outcome: LocationPermissionOutcome.granted,
        location: _savedLocation,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  String? fallbackPreferredCountryId(String? explicitCountryId) {
    return explicitCountryId ?? matchedCountryId;
  }

  Future<void> _syncDetectedLocation() async {
    final location = _savedLocation;
    if (location == null) {
      return;
    }

    await _journeyContextController.setDetectedLocation(
      DetectedLocation(
        countryId: _matchCountry(location)?.id,
        countryName: location.countryName,
        city: location.cityName.isEmpty ? null : location.cityName,
        region: location.stateName.isEmpty ? null : location.stateName,
        latitude: location.latitude,
        longitude: location.longitude,
        detectedAt: _lastAskedAt,
      ),
    );
  }

  CatalogCountry? _matchCountry(LocationData? location) {
    if (location == null) {
      return null;
    }

    final normalizedCode = location.countryCode.trim().toLowerCase();
    final normalizedName = location.countryName.trim().toLowerCase();

    for (final country in _journeyContextController.countries) {
      if (country.isoCode.trim().toLowerCase() == normalizedCode) {
        return country;
      }

      if (country.name.trim().toLowerCase() == normalizedName) {
        return country;
      }

      if (country.locationAliases.any(
        (alias) => alias.trim().toLowerCase() == normalizedName,
      )) {
        return country;
      }
    }

    return null;
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}

enum LocationPermissionOutcome { granted, denied, permanentlyDenied }

class LocationPermissionRequestResult {
  const LocationPermissionRequestResult({required this.outcome, this.location});

  final LocationPermissionOutcome outcome;
  final LocationData? location;
}

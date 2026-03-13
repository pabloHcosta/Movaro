import 'package:flutter/foundation.dart';
import 'package:movaro_app/features/cities/application/services/city_favorites_store.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';

enum CityFavoriteToggleResult { added, removed, limitReached }

class CitiesController extends ChangeNotifier {
  CitiesController({
    required CitiesRepository repository,
    CityFavoritesStore? favoritesStore,
  }) : _repository = repository,
       _favoritesStore = favoritesStore ?? CityFavoritesStore();

  final CitiesRepository _repository;
  final CityFavoritesStore _favoritesStore;
  static const int maxFavoriteCities = 3;

  CityHighlights? _highlights;
  CityMethodology? _methodology;
  final Map<String, City> _cityCache = {};
  final Map<String, CityWeather> _weatherCache = {};
  final Set<String> _favoriteCityIds = {};
  List<City> _catalog = const [];
  List<City> _searchResults = const [];
  bool _isLoadingHighlights = false;
  bool _isLoadingCatalog = false;
  bool _isSearching = false;
  bool _isLoadingCity = false;
  Object? _exploreError;
  Object? _catalogError;
  Object? _searchError;
  Object? _cityError;
  Object? _methodologyError;
  Future<void>? _pendingExploreRequest;
  Future<void>? _pendingCatalogRequest;
  Future<CityMethodology?>? _pendingMethodologyRequest;
  Future<void>? _pendingInitialization;
  bool _isInitialized = false;
  final Map<String, Future<City?>> _pendingCityRequests = {};
  final Map<String, Future<CityWeather?>> _pendingWeatherRequests = {};

  CityHighlights? get highlights => _highlights;
  CityMethodology? get methodology => _methodology;
  List<City> get catalog => _catalog;
  List<City> get searchResults => _searchResults;
  Set<String> get favoriteCityIds => _favoriteCityIds;
  List<City> get favoriteCities => _favoriteCityIds
      .map((cityId) => _cityCache[cityId])
      .whereType<City>()
      .toList(growable: false);
  bool get isLoadingHighlights => _isLoadingHighlights;
  bool get isLoadingCatalog => _isLoadingCatalog;
  bool get isSearching => _isSearching;
  bool get isLoadingCity => _isLoadingCity;
  bool get isInitialized => _isInitialized;
  Object? get exploreError => _exploreError;
  Object? get catalogError => _catalogError;
  Object? get searchError => _searchError;
  Object? get cityError => _cityError;
  Object? get methodologyError => _methodologyError;

  bool isFavorite(String cityId) => _favoriteCityIds.contains(cityId);
  CityWeather? weatherFor(String cityId) => _weatherCache[cityId];

  Future<void> initialize({bool preloadData = false}) async {
    if (_isInitialized && !preloadData) {
      return;
    }

    final pendingInitialization = _pendingInitialization;
    if (pendingInitialization != null) {
      return pendingInitialization;
    }

    final request = _performInitialize(preloadData: preloadData);
    _pendingInitialization = request;
    await request;
  }

  Future<void> _performInitialize({required bool preloadData}) async {
    try {
      await _restoreFavorites();

      if (preloadData) {
        await Future.wait([
          loadCatalog().catchError((_) {}),
          loadExplore().catchError((_) {}),
          loadMethodology().catchError((_) => null),
        ]);
      }

      _isInitialized = true;
      notifyListeners();
    } finally {
      _pendingInitialization = null;
    }
  }

  Future<void> prefetchExplore() => loadExplore();

  Future<void> prefetchCatalog() => loadCatalog();

  Future<void> prefetchMethodology() async {
    await loadMethodology();
  }

  Future<City?> prefetchCityDetail(String id) async {
    return loadCityById(id);
  }

  Future<CityWeather?> prefetchCityWeather(String cityId) async {
    return loadWeatherForCity(cityId);
  }

  Future<void> loadExplore() async {
    if (_highlights != null && !_isLoadingHighlights) {
      return;
    }

    final pendingRequest = _pendingExploreRequest;
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _performLoadExplore();
    _pendingExploreRequest = request;
    await request;
  }

  Future<void> _performLoadExplore() async {
    _isLoadingHighlights = true;
    _exploreError = null;
    notifyListeners();

    try {
      _highlights = await _repository.getHighlights();
      _methodology ??= await _repository.getMethodology();
      for (final group in [
        _highlights!.mostChosenByArgentinians,
        _highlights!.easiestForSpanishSpeakers,
        _highlights!.mostEconomical,
        _highlights!.bestForWork,
      ]) {
        for (final city in group) {
          _cityCache[city.id] = city;
        }
      }
    } catch (error) {
      _exploreError = error;
    } finally {
      _isLoadingHighlights = false;
      _pendingExploreRequest = null;
      notifyListeners();
    }
  }

  Future<City?> loadCityById(String id) async {
    if (_cityCache.containsKey(id)) {
      _cityError = null;
      return _cityCache[id];
    }

    final pendingRequest = _pendingCityRequests[id];
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _performLoadCityById(id);
    _pendingCityRequests[id] = request;
    return request;
  }

  Future<City?> _performLoadCityById(String id) async {
    _isLoadingCity = true;
    _cityError = null;
    notifyListeners();

    try {
      final city = await _repository.getCityById(id);
      _cityCache[id] = city;
      return city;
    } catch (error) {
      _cityError = error;
      return null;
    } finally {
      _isLoadingCity = false;
      _pendingCityRequests.remove(id);
      notifyListeners();
    }
  }

  Future<CityWeather?> loadWeatherForCity(String cityId) async {
    if (_weatherCache.containsKey(cityId)) {
      return _weatherCache[cityId];
    }

    final pendingRequest = _pendingWeatherRequests[cityId];
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _performLoadWeatherForCity(cityId);
    _pendingWeatherRequests[cityId] = request;
    return request;
  }

  Future<CityWeather?> _performLoadWeatherForCity(String cityId) async {
    try {
      final weather = await _repository.getCityWeather(cityId);
      _weatherCache[cityId] = weather;
      notifyListeners();
      return weather;
    } catch (_) {
      return null;
    } finally {
      _pendingWeatherRequests.remove(cityId);
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = const [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchCities(query);
      for (final city in _searchResults) {
        _cityCache[city.id] = city;
      }
    } catch (error) {
      _searchError = error;
      _searchResults = const [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadCatalog() async {
    if (_catalog.isNotEmpty && !_isLoadingCatalog) {
      return;
    }

    final pendingRequest = _pendingCatalogRequest;
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _performLoadCatalog();
    _pendingCatalogRequest = request;
    await request;
  }

  Future<void> _performLoadCatalog() async {
    _isLoadingCatalog = true;
    _catalogError = null;
    notifyListeners();

    try {
      _catalog = await _repository.getCities(countryCode: 'BR');
      for (final city in _catalog) {
        _cityCache[city.id] = city;
      }
    } catch (error) {
      _catalogError = error;
    } finally {
      _isLoadingCatalog = false;
      _pendingCatalogRequest = null;
      notifyListeners();
    }
  }

  Future<CityMethodology?> loadMethodology() async {
    if (_methodology != null) {
      return _methodology;
    }

    final pendingRequest = _pendingMethodologyRequest;
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _performLoadMethodology();
    _pendingMethodologyRequest = request;
    return request;
  }

  Future<CityMethodology?> _performLoadMethodology() async {
    try {
      _methodology = await _repository.getMethodology();
      _methodologyError = null;
      notifyListeners();
      return _methodology;
    } catch (error) {
      _methodologyError = error;
      notifyListeners();
      return null;
    } finally {
      _pendingMethodologyRequest = null;
    }
  }

  Future<CityFavoriteToggleResult> toggleFavorite(String cityId) async {
    if (_favoriteCityIds.contains(cityId)) {
      _favoriteCityIds.remove(cityId);
      await _favoritesStore.write(_favoriteCityIds.toList(growable: false));
      notifyListeners();
      return CityFavoriteToggleResult.removed;
    }

    if (_favoriteCityIds.length >= maxFavoriteCities) {
      return CityFavoriteToggleResult.limitReached;
    }

    _favoriteCityIds.add(cityId);
    await _favoritesStore.write(_favoriteCityIds.toList(growable: false));
    notifyListeners();
    return CityFavoriteToggleResult.added;
  }

  Future<void> _restoreFavorites() async {
    final stored = await _favoritesStore.read();
    _favoriteCityIds
      ..clear()
      ..addAll(stored.take(maxFavoriteCities));
    notifyListeners();
  }
}

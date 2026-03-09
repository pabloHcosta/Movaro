import 'package:movaro_app/core/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({required SeedCatalogDataSource dataSource})
    : _dataSource = dataSource;

  final SeedCatalogDataSource _dataSource;
  List<CatalogCountry>? _countriesCache;
  Future<List<CatalogCountry>>? _pendingCountriesRequest;

  @override
  Future<List<CatalogCountry>> getCountries() async {
    final cachedCountries = _countriesCache;
    if (cachedCountries != null) {
      return cachedCountries;
    }

    final pendingRequest = _pendingCountriesRequest;
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = _loadCountries();
    _pendingCountriesRequest = request;
    return request;
  }

  Future<List<CatalogCountry>> _loadCountries() async {
    try {
      final countries = await _dataSource.loadCountries();
      final mappedCountries = countries
          .map((country) => country.toEntity())
          .toList();
      _countriesCache = List.unmodifiable(mappedCountries);
      return _countriesCache!;
    } finally {
      _pendingCountriesRequest = null;
    }
  }
}

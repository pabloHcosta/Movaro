import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';

abstract class CatalogRepository {
  Future<List<CatalogCountry>> getCountries();
}

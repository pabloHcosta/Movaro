import 'package:movaro_app/features/catalog/domain/entities/catalog_country.dart';

abstract class CatalogRepository {
  Future<List<CatalogCountry>> getCountries();
}

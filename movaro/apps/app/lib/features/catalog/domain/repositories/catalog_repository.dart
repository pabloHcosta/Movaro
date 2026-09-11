import 'package:mudavi_app/features/catalog/domain/entities/catalog_country.dart';

abstract class CatalogRepository {
  Future<List<CatalogCountry>> getCountries();
}

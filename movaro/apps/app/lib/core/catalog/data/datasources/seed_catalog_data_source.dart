import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:movaro_app/core/catalog/data/models/catalog_country_model.dart';

class SeedCatalogDataSource {
  static const countriesAsset = 'assets/seed/countries.json';

  List<CatalogCountryModel>? _countriesCache;

  Future<List<CatalogCountryModel>> loadCountries() async {
    if (_countriesCache != null) {
      return _countriesCache!;
    }

    final rawJson = await rootBundle.loadString(countriesAsset);
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    _countriesCache = decoded
        .map(
          (item) => CatalogCountryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return _countriesCache!;
  }
}

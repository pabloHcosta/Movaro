import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/data/datasources/cities_asset_fallback.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled city snapshot parses through CityModel (offline-first)',
    () async {
      final raw = await rootBundle.loadString(
        'assets/seed/snapshots/cities_br.json',
      );
      final list = jsonDecode(raw) as List<dynamic>;
      expect(list.length, 44);

      final cities = list
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      expect(cities.length, 44);
      expect(cities.any((c) => c.id == 'chapeco-sc'), isTrue);
      expect(cities.any((c) => c.id == 'caxias-do-sul-rs'), isTrue);
      expect(cities.every((city) => city.sources.safety != null), isTrue);
      expect(
        cities.every(
          (city) =>
              city.sources.safety!.provider.contains('Ipea') &&
              city.sources.safety!.referenceValue != null &&
              city.sources.safety!.referencePeriod == '2022-2024' &&
              city.sources.safety!.url?.contains('dados-series/20') == true,
        ),
        isTrue,
      );
    },
  );

  test(
    'asset fallback routes catalog, single city, search and unmapped paths',
    () async {
      final fallback = CitiesAssetFallback();

      final catalog = await fallback.resolve('/api/v1/cities?countryCode=BR');
      expect(catalog, isA<List<dynamic>>());
      expect((catalog as List<dynamic>).length, 44);

      final single = await fallback.resolve('/api/v1/cities/chapeco-sc');
      expect(single, isA<Map<String, dynamic>>());
      expect((single as Map<String, dynamic>)['id'], 'chapeco-sc');

      final search = await fallback.resolve('/api/v1/cities/search?q=campinas');
      expect(search, isA<List<dynamic>>());
      expect((search as List<dynamic>).isNotEmpty, isTrue);

      // Live-only surfaces have no offline mirror -> null so callers degrade.
      final weather = await fallback.resolve(
        '/api/v1/cities/chapeco-sc/weather',
      );
      expect(weather, isNull);
    },
  );
}

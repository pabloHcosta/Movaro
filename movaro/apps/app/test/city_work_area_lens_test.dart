import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/application/services/city_work_area_lens.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<City> cities;

  setUpAll(() async {
    final raw = await rootBundle.loadString(
      'assets/seed/snapshots/cities_br.json',
    );
    cities = (jsonDecode(raw) as List<dynamic>)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  });

  test('availableAreas surfaces real industries, most common first', () {
    final areas = CityWorkAreaLens.availableAreas(cities);
    expect(areas, isNotEmpty);
    // Catalog uses these labels; at least the common ones must appear.
    final lower = areas.map((a) => a.toLowerCase()).toList();
    expect(lower.contains('servicos'), isTrue, reason: 'areas=$areas');
    expect(lower.contains('tecnologia'), isTrue, reason: 'areas=$areas');
  });

  test('applyWorkLens filters by area and ranks by work opportunity', () {
    final agro = CityWorkAreaLens.applyWorkLens(cities, area: 'Agroindustria');
    expect(agro, isNotEmpty);
    // Every result actually offers the area.
    expect(
      agro.every((c) => CityWorkAreaLens.offersArea(c, 'Agroindustria')),
      isTrue,
    );
    // Chapecó (agroindustry hub) should be present.
    expect(agro.any((c) => c.id == 'chapeco-sc'), isTrue);
    // Ranked by work opportunity (descending).
    for (var i = 0; i < agro.length - 1; i++) {
      expect(
        agro[i].movaroScores.workOpportunity >=
            agro[i + 1].movaroScores.workOpportunity,
        isTrue,
      );
    }
  });

  test('offersArea is accent- and case-insensitive', () {
    final chapeco = cities.firstWhere((c) => c.id == 'chapeco-sc');
    // Catalog stores "Servicos" (no cedilla); a query with the accent matches.
    expect(CityWorkAreaLens.offersArea(chapeco, 'Serviços'), isTrue);
    expect(CityWorkAreaLens.offersArea(chapeco, 'SERVICOS'), isTrue);
    expect(CityWorkAreaLens.offersArea(chapeco, 'Turismo'), isFalse);
  });

  test('no area returns the whole catalog ranked by work opportunity', () {
    final all = CityWorkAreaLens.applyWorkLens(cities);
    expect(all.length, cities.length);
    for (var i = 0; i < all.length - 1; i++) {
      expect(
        all[i].movaroScores.workOpportunity >=
            all[i + 1].movaroScores.workOpportunity,
        isTrue,
      );
    }
  });
}

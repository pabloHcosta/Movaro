import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/location/argentina_locality_catalog.dart';
import 'package:movaro_app/features/location/argentina_origin_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads and searches Argentine localities without requiring accents',
    () async {
      final bundle = _StringAssetBundle({
        ArgentinaLocalityCatalog.assetPath: jsonEncode({
          'localities': [
            {
              'id': '1',
              'name': 'Córdoba',
              'provinceId': '14',
              'province': 'Córdoba',
              'department': 'Capital',
              'latitude': -31.42,
              'longitude': -64.18,
            },
            {
              'id': '2',
              'name': 'San Rafael',
              'provinceId': '50',
              'province': 'Mendoza',
              'department': 'San Rafael',
              'latitude': -34.61,
              'longitude': -68.33,
            },
          ],
        }),
      });
      final catalog = ArgentinaLocalityCatalog(bundle: bundle);

      final localities = await catalog.load();
      final matches = catalog.search(localities, 'cordoba');

      expect(localities, hasLength(2));
      expect(matches.single.name, 'Córdoba');
    },
  );

  test('maps the confirmed city region to the recommendation profile', () {
    expect(
      ArgentinaOriginClassifier.classify(
        city: 'San Rafael',
        province: 'Mendoza',
      ),
      'mendoza',
    );
    expect(
      ArgentinaOriginClassifier.classify(city: 'Rosario', province: 'Santa Fe'),
      'rosario',
    );
    expect(
      ArgentinaOriginClassifier.classify(city: 'Posadas', province: 'Misiones'),
      'litoral',
    );
  });
}

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}

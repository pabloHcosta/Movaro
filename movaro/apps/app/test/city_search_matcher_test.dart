import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_search_matcher.dart';

void main() {
  group('CitySearchMatcher', () {
    test('ranks a common unaccented São Paulo typo above unrelated cities', () {
      final saoPaulo = CitySearchMatcher.score(
        'so paulo',
        'São Paulo',
        'São Paulo',
      );
      final joaoPessoa = CitySearchMatcher.score(
        'so paulo',
        'João Pessoa',
        'Paraíba',
      );

      expect(saoPaulo, greaterThan(joaoPessoa));
      expect(saoPaulo, greaterThan(0));
    });

    test('keeps Spanish aliases for Brazilian cities', () {
      expect(
        CitySearchMatcher.score('san pablo', 'São Paulo', 'São Paulo'),
        greaterThan(0),
      );
    });
  });
}

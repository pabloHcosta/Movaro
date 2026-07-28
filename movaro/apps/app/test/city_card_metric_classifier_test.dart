import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card_metric_classifier.dart';

void main() {
  group('CityCardMetricClassifier', () {
    test('turns internal scores into three stable reading levels', () {
      expect(CityCardMetricClassifier.levelFor(100), CityCardMetricLevel.high);
      expect(CityCardMetricClassifier.levelFor(70), CityCardMetricLevel.high);
      expect(CityCardMetricClassifier.levelFor(69), CityCardMetricLevel.medium);
      expect(CityCardMetricClassifier.levelFor(50), CityCardMetricLevel.medium);
      expect(CityCardMetricClassifier.levelFor(49), CityCardMetricLevel.low);
    });

    test('describes source coverage without exposing a technical fraction', () {
      expect(
        CityCardMetricClassifier.coverageFor(8),
        CityCardDataCoverage.broad,
      );
      expect(
        CityCardMetricClassifier.coverageFor(7),
        CityCardDataCoverage.broad,
      );
      expect(
        CityCardMetricClassifier.coverageFor(6),
        CityCardDataCoverage.good,
      );
      expect(
        CityCardMetricClassifier.coverageFor(5),
        CityCardDataCoverage.good,
      );
      expect(
        CityCardMetricClassifier.coverageFor(4),
        CityCardDataCoverage.partial,
      );
    });
  });
}

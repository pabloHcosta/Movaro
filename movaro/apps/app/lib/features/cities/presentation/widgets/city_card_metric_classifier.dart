enum CityCardMetricLevel { low, medium, high }

enum CityCardDataCoverage { partial, good, broad }

class CityCardMetricClassifier {
  const CityCardMetricClassifier._();

  static CityCardMetricLevel levelFor(int score) {
    if (score >= 70) {
      return CityCardMetricLevel.high;
    }
    if (score >= 50) {
      return CityCardMetricLevel.medium;
    }
    return CityCardMetricLevel.low;
  }

  static CityCardDataCoverage coverageFor(int sourceCount) {
    if (sourceCount >= 7) {
      return CityCardDataCoverage.broad;
    }
    if (sourceCount >= 5) {
      return CityCardDataCoverage.good;
    }
    return CityCardDataCoverage.partial;
  }
}

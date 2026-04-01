class CityBudgetSnapshot {
  const CityBudgetSnapshot({
    required this.cityLabel,
    required this.singlePersonExcludingRent,
    required this.oneBedroomOutsideCentre,
    required this.oneBedroomCityCentre,
    required this.averageMonthlyNetSalary,
    required this.monthlyTransportPass,
    required this.utilities,
    required this.updatedAt,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.sourceType,
  });

  final String cityLabel;
  final int singlePersonExcludingRent;
  final int oneBedroomOutsideCentre;
  final int oneBedroomCityCentre;
  final int averageMonthlyNetSalary;
  final int monthlyTransportPass;
  final int utilities;
  final String updatedAt;
  final String sourceLabel;
  final String sourceUrl;
  final String sourceType;

  int get cheaperRent => oneBedroomOutsideCentre < oneBedroomCityCentre
      ? oneBedroomOutsideCentre
      : oneBedroomCityCentre;

  int get pricierRent => oneBedroomOutsideCentre > oneBedroomCityCentre
      ? oneBedroomOutsideCentre
      : oneBedroomCityCentre;

  int get fairLivingTotal => singlePersonExcludingRent + cheaperRent;
  int get wellLivingTotal => singlePersonExcludingRent + pricierRent;
  int get fairLivingGap => averageMonthlyNetSalary - fairLivingTotal;
  double get fairLivingCoverageRatio =>
      fairLivingTotal == 0 ? 0 : averageMonthlyNetSalary / fairLivingTotal;
}

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

  /// Prevents a single implausible source observation from making the whole
  /// city look artificially cheap. It does not replace the raw value shown in
  /// the source breakdown; it is only the safer planning baseline.
  bool get hasSuspiciousRentSpread =>
      cheaperRent < (pricierRent * 0.35).round();

  int get planningRentLow =>
      hasSuspiciousRentSpread ? (pricierRent * 0.65).round() : cheaperRent;

  int get planningRentHigh => pricierRent;

  int get fairLivingTotal => singlePersonExcludingRent + planningRentLow;
  int get wellLivingTotal => singlePersonExcludingRent + planningRentHigh;
  int get fairLivingGap => averageMonthlyNetSalary - fairLivingTotal;
  double get fairLivingCoverageRatio =>
      fairLivingTotal == 0 ? 0 : averageMonthlyNetSalary / fairLivingTotal;
}

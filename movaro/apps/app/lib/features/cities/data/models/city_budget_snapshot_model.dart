import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';

class CityBudgetSnapshotModel {
  const CityBudgetSnapshotModel({
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

  factory CityBudgetSnapshotModel.fromJson(Map<String, dynamic> json) {
    return CityBudgetSnapshotModel(
      cityLabel: json['cityLabel'] as String,
      singlePersonExcludingRent: json['singlePersonExcludingRent'] as int,
      oneBedroomOutsideCentre: json['oneBedroomOutsideCentre'] as int,
      oneBedroomCityCentre: json['oneBedroomCityCentre'] as int,
      averageMonthlyNetSalary: json['averageMonthlyNetSalary'] as int,
      monthlyTransportPass: json['monthlyTransportPass'] as int,
      utilities: json['utilities'] as int,
      updatedAt: json['updatedAt'] as String,
      sourceLabel: json['sourceLabel'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sourceType: (json['sourceType'] as String?) ?? 'community',
    );
  }

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

  CityBudgetSnapshot toEntity() => CityBudgetSnapshot(
    cityLabel: cityLabel,
    singlePersonExcludingRent: singlePersonExcludingRent,
    oneBedroomOutsideCentre: oneBedroomOutsideCentre,
    oneBedroomCityCentre: oneBedroomCityCentre,
    averageMonthlyNetSalary: averageMonthlyNetSalary,
    monthlyTransportPass: monthlyTransportPass,
    utilities: utilities,
    updatedAt: updatedAt,
    sourceLabel: sourceLabel,
    sourceUrl: sourceUrl,
    sourceType: sourceType,
  );
}

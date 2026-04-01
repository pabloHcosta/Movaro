import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_public_opinion.dart';
import 'package:movaro_app/features/cities/domain/entities/city_seasonality_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';

class City {
  const City({
    required this.id,
    required this.name,
    required this.stateCode,
    required this.stateName,
    required this.countryCode,
    required this.ibgeCode,
    required this.latitude,
    required this.longitude,
    required this.population,
    required this.idhmScore,
    required this.idhmReferenceYear,
    required this.costOfLivingScore,
    required this.rentScore,
    required this.safetyScore,
    required this.argentinaPopularityScore,
    required this.spanishSupportScore,
    required this.jobMarketScore,
    required this.unemploymentRate,
    required this.economicActivityScore,
    required this.topIndustries,
    required this.movaroScores,
    required this.recommendationReasons,
    required this.sources,
    required this.updatedAt,
    required this.regionName,
    this.budgetSnapshot,
    this.seasonalitySnapshot,
    this.publicOpinion,
  });

  final String id;
  final String name;
  final String stateCode;
  final String stateName;
  final String countryCode;
  final int ibgeCode;
  final double latitude;
  final double longitude;
  final int population;
  final double idhmScore;
  final int idhmReferenceYear;
  final int costOfLivingScore;
  final int rentScore;
  final int safetyScore;
  final int argentinaPopularityScore;
  final int spanishSupportScore;
  final int jobMarketScore;
  final double unemploymentRate;
  final int economicActivityScore;
  final List<String> topIndustries;
  final CityScores movaroScores;
  final List<String> recommendationReasons;
  final CitySources sources;
  final String updatedAt;
  final String? regionName;
  final CityBudgetSnapshot? budgetSnapshot;
  final CitySeasonalitySnapshot? seasonalitySnapshot;
  final CityPublicOpinion? publicOpinion;
}

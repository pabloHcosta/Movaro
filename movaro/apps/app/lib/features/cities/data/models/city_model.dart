import 'package:movaro_app/features/cities/data/models/city_budget_snapshot_model.dart';
import 'package:movaro_app/features/cities/data/models/city_public_opinion_model.dart';
import 'package:movaro_app/features/cities/data/models/city_scores_model.dart';
import 'package:movaro_app/features/cities/data/models/city_seasonality_snapshot_model.dart';
import 'package:movaro_app/features/cities/data/models/city_sources_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityModel {
  const CityModel({
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

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      stateCode: json['stateCode'] as String,
      stateName: json['stateName'] as String,
      countryCode: json['countryCode'] as String,
      ibgeCode: json['ibgeCode'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      population: json['population'] as int,
      idhmScore: (json['idhmScore'] as num).toDouble(),
      idhmReferenceYear: json['idhmReferenceYear'] as int,
      costOfLivingScore: json['costOfLivingScore'] as int,
      rentScore: json['rentScore'] as int,
      safetyScore: json['safetyScore'] as int,
      argentinaPopularityScore: json['argentinaPopularityScore'] as int,
      spanishSupportScore: json['spanishSupportScore'] as int,
      jobMarketScore: json['jobMarketScore'] as int,
      unemploymentRate: (json['unemploymentRate'] as num).toDouble(),
      economicActivityScore: json['economicActivityScore'] as int,
      topIndustries: (json['topIndustries'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      movaroScores: CityScoresModel.fromJson(
        json['movaroScores'] as Map<String, dynamic>,
      ),
      recommendationReasons: (json['recommendationReasons'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      sources: CitySourcesModel.fromJson(
        json['sources'] as Map<String, dynamic>,
      ),
      updatedAt: json['updatedAt'] as String,
      regionName: json['regionName'] as String?,
      budgetSnapshot: json['budgetSnapshot'] == null
          ? null
          : CityBudgetSnapshotModel.fromJson(
              json['budgetSnapshot'] as Map<String, dynamic>,
            ),
      seasonalitySnapshot: json['seasonalitySnapshot'] == null
          ? null
          : CitySeasonalitySnapshotModel.fromJson(
              json['seasonalitySnapshot'] as Map<String, dynamic>,
            ),
      publicOpinion: json['publicOpinion'] == null
          ? null
          : CityPublicOpinionModel.fromJson(
              json['publicOpinion'] as Map<String, dynamic>,
            ),
    );
  }

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
  final CityScoresModel movaroScores;
  final List<String> recommendationReasons;
  final CitySourcesModel sources;
  final String updatedAt;
  final String? regionName;
  final CityBudgetSnapshotModel? budgetSnapshot;
  final CitySeasonalitySnapshotModel? seasonalitySnapshot;
  final CityPublicOpinionModel? publicOpinion;

  factory CityModel.fromEntity(City city) {
    return CityModel(
      id: city.id,
      name: city.name,
      stateCode: city.stateCode,
      stateName: city.stateName,
      countryCode: city.countryCode,
      ibgeCode: city.ibgeCode,
      latitude: city.latitude,
      longitude: city.longitude,
      population: city.population,
      idhmScore: city.idhmScore,
      idhmReferenceYear: city.idhmReferenceYear,
      costOfLivingScore: city.costOfLivingScore,
      rentScore: city.rentScore,
      safetyScore: city.safetyScore,
      argentinaPopularityScore: city.argentinaPopularityScore,
      spanishSupportScore: city.spanishSupportScore,
      jobMarketScore: city.jobMarketScore,
      unemploymentRate: city.unemploymentRate,
      economicActivityScore: city.economicActivityScore,
      topIndustries: city.topIndustries,
      movaroScores: CityScoresModel.fromEntity(city.movaroScores),
      recommendationReasons: city.recommendationReasons,
      sources: CitySourcesModel.fromEntity(city.sources),
      updatedAt: city.updatedAt,
      regionName: city.regionName,
      budgetSnapshot: city.budgetSnapshot == null
          ? null
          : CityBudgetSnapshotModel.fromJson({
              'cityLabel': city.budgetSnapshot!.cityLabel,
              'singlePersonExcludingRent':
                  city.budgetSnapshot!.singlePersonExcludingRent,
              'oneBedroomOutsideCentre':
                  city.budgetSnapshot!.oneBedroomOutsideCentre,
              'oneBedroomCityCentre': city.budgetSnapshot!.oneBedroomCityCentre,
              'averageMonthlyNetSalary':
                  city.budgetSnapshot!.averageMonthlyNetSalary,
              'monthlyTransportPass': city.budgetSnapshot!.monthlyTransportPass,
              'utilities': city.budgetSnapshot!.utilities,
              'updatedAt': city.budgetSnapshot!.updatedAt,
              'sourceLabel': city.budgetSnapshot!.sourceLabel,
              'sourceUrl': city.budgetSnapshot!.sourceUrl,
              'sourceType': city.budgetSnapshot!.sourceType,
            }),
      seasonalitySnapshot: city.seasonalitySnapshot == null
          ? null
          : CitySeasonalitySnapshotModel.fromJson({
              'peakMonths': city.seasonalitySnapshot!.peakMonths,
              'lowMonths': city.seasonalitySnapshot!.lowMonths,
              'severity': city.seasonalitySnapshot!.severity.name,
              'visitorsLabelPt': city.seasonalitySnapshot!.visitorsLabelPt,
              'visitorsLabelEs': city.seasonalitySnapshot!.visitorsLabelEs,
              'visitorsLabelEn': city.seasonalitySnapshot!.visitorsLabelEn,
              'rentNotesPt': city.seasonalitySnapshot!.rentNotesPt,
              'rentNotesEs': city.seasonalitySnapshot!.rentNotesEs,
              'rentNotesEn': city.seasonalitySnapshot!.rentNotesEn,
              'jobNotesPt': city.seasonalitySnapshot!.jobNotesPt,
              'jobNotesEs': city.seasonalitySnapshot!.jobNotesEs,
              'jobNotesEn': city.seasonalitySnapshot!.jobNotesEn,
              'populationMultiplierNote':
                  city.seasonalitySnapshot!.populationMultiplierNote,
              'updatedAt': city.seasonalitySnapshot!.updatedAt,
              'sourceLabel': city.seasonalitySnapshot!.sourceLabel,
              'sourceUrl': city.seasonalitySnapshot!.sourceUrl,
              'sourceType': city.seasonalitySnapshot!.sourceType,
            }),
      publicOpinion: city.publicOpinion == null
          ? null
          : CityPublicOpinionModel.fromEntity(city.publicOpinion!),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stateCode': stateCode,
    'stateName': stateName,
    'countryCode': countryCode,
    'ibgeCode': ibgeCode,
    'latitude': latitude,
    'longitude': longitude,
    'population': population,
    'idhmScore': idhmScore,
    'idhmReferenceYear': idhmReferenceYear,
    'costOfLivingScore': costOfLivingScore,
    'rentScore': rentScore,
    'safetyScore': safetyScore,
    'argentinaPopularityScore': argentinaPopularityScore,
    'spanishSupportScore': spanishSupportScore,
    'jobMarketScore': jobMarketScore,
    'unemploymentRate': unemploymentRate,
    'economicActivityScore': economicActivityScore,
    'topIndustries': topIndustries,
    'movaroScores': movaroScores.toJson(),
    'recommendationReasons': recommendationReasons,
    'sources': sources.toJson(),
    'updatedAt': updatedAt,
    'regionName': regionName,
    'budgetSnapshot': budgetSnapshot == null
        ? null
        : {
            'cityLabel': budgetSnapshot!.cityLabel,
            'singlePersonExcludingRent':
                budgetSnapshot!.singlePersonExcludingRent,
            'oneBedroomOutsideCentre': budgetSnapshot!.oneBedroomOutsideCentre,
            'oneBedroomCityCentre': budgetSnapshot!.oneBedroomCityCentre,
            'averageMonthlyNetSalary': budgetSnapshot!.averageMonthlyNetSalary,
            'monthlyTransportPass': budgetSnapshot!.monthlyTransportPass,
            'utilities': budgetSnapshot!.utilities,
            'updatedAt': budgetSnapshot!.updatedAt,
            'sourceLabel': budgetSnapshot!.sourceLabel,
            'sourceUrl': budgetSnapshot!.sourceUrl,
            'sourceType': budgetSnapshot!.sourceType,
          },
    'seasonalitySnapshot': seasonalitySnapshot == null
        ? null
        : {
            'peakMonths': seasonalitySnapshot!.peakMonths,
            'lowMonths': seasonalitySnapshot!.lowMonths,
            'severity': seasonalitySnapshot!.severity.name,
            'visitorsLabelPt': seasonalitySnapshot!.visitorsLabelPt,
            'visitorsLabelEs': seasonalitySnapshot!.visitorsLabelEs,
            'visitorsLabelEn': seasonalitySnapshot!.visitorsLabelEn,
            'rentNotesPt': seasonalitySnapshot!.rentNotesPt,
            'rentNotesEs': seasonalitySnapshot!.rentNotesEs,
            'rentNotesEn': seasonalitySnapshot!.rentNotesEn,
            'jobNotesPt': seasonalitySnapshot!.jobNotesPt,
            'jobNotesEs': seasonalitySnapshot!.jobNotesEs,
            'jobNotesEn': seasonalitySnapshot!.jobNotesEn,
            'populationMultiplierNote':
                seasonalitySnapshot!.populationMultiplierNote,
            'updatedAt': seasonalitySnapshot!.updatedAt,
            'sourceLabel': seasonalitySnapshot!.sourceLabel,
            'sourceUrl': seasonalitySnapshot!.sourceUrl,
            'sourceType': seasonalitySnapshot!.sourceType,
          },
    'publicOpinion': publicOpinion?.toJson(),
  };

  City toEntity() => City(
    id: id,
    name: name,
    stateCode: stateCode,
    stateName: stateName,
    countryCode: countryCode,
    ibgeCode: ibgeCode,
    latitude: latitude,
    longitude: longitude,
    population: population,
    idhmScore: idhmScore,
    idhmReferenceYear: idhmReferenceYear,
    costOfLivingScore: costOfLivingScore,
    rentScore: rentScore,
    safetyScore: safetyScore,
    argentinaPopularityScore: argentinaPopularityScore,
    spanishSupportScore: spanishSupportScore,
    jobMarketScore: jobMarketScore,
    unemploymentRate: unemploymentRate,
    economicActivityScore: economicActivityScore,
    topIndustries: topIndustries,
    movaroScores: movaroScores.toEntity(),
    recommendationReasons: recommendationReasons,
    sources: sources.toEntity(),
    updatedAt: updatedAt,
    regionName: regionName,
    budgetSnapshot: budgetSnapshot?.toEntity(),
    seasonalitySnapshot: seasonalitySnapshot?.toEntity(),
    publicOpinion: publicOpinion?.toEntity(),
  );
}

import 'package:movaro_app/features/cities/data/models/city_public_opinion_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';

class CityDetailPayloadsModel {
  const CityDetailPayloadsModel._();

  static CityDetailInsight insightFromJson(Map<String, dynamic> json) =>
      CityDetailInsight(
        id: json['id'] as String,
        type: json['type'] as String,
        theme: json['theme'] as String?,
        title: json['title'] as String,
        shortText: json['shortText'] as String,
        content: json['content'] as String,
        placeHighlights: (json['placeHighlights'] as List<dynamic>? ?? const [])
            .map((item) => item as String)
            .toList(growable: false),
        ctaLabel: json['ctaLabel'] as String?,
        source: json['source'] as String,
        generatedAt: json['generatedAt'] as String,
        expiresAt: json['expiresAt'] as String?,
      );

  static CityDetailSource sourceFromJson(Map<String, dynamic> json) =>
      CityDetailSource(
        label: json['label'] as String,
        type: json['type'] as String?,
        url: json['url'] as String?,
      );

  static CityDetailSocialProof socialProofFromJson(Map<String, dynamic> json) =>
      CityDetailSocialProof(
        cityId: json['cityId'] as String,
        cityName: json['cityName'] as String,
        argentinaPopularityScore: json['argentinaPopularityScore'] as int,
        publicOpinion: json['publicOpinion'] == null
            ? null
            : CityPublicOpinionModel.fromJson(
                json['publicOpinion'] as Map<String, dynamic>,
              ).toEntity(),
        socialSignals: (json['socialSignals'] as List<dynamic>? ?? const [])
            .map((item) => item as Map<String, dynamic>)
            .map(
              (item) => CityDetailSocialSignal(
                id: item['id'] as String,
                label: item['label'] as String,
                value: item['value'] as num,
                unit: item['unit'] as String,
                source: item['source'] as String,
              ),
            )
            .toList(growable: false),
        routineInsight: json['routineInsight'] == null
            ? null
            : insightFromJson(json['routineInsight'] as Map<String, dynamic>),
        neighborhoodInsight: json['neighborhoodInsight'] == null
            ? null
            : insightFromJson(
                json['neighborhoodInsight'] as Map<String, dynamic>,
              ),
        sources: (json['sources'] as List<dynamic>? ?? const [])
            .map((item) => sourceFromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );

  static CityDetailClimateSummary climateSummaryFromJson(
    Map<String, dynamic> json,
  ) => CityDetailClimateSummary(
    cityId: json['cityId'] as String,
    cityName: json['cityName'] as String,
    currentWeather: CityDetailClimateCurrentWeather(
      temperatureCelsius: (json['currentWeather']['temperatureCelsius'] as num)
          .toDouble(),
      weatherCode: json['currentWeather']['weatherCode'] as int?,
      isDay: json['currentWeather']['isDay'] as bool?,
      windSpeedKmh: (json['currentWeather']['windSpeedKmh'] as num?)
          ?.toDouble(),
      fetchedAt: json['currentWeather']['fetchedAt'] as String,
      conditionLabel: json['currentWeather']['conditionLabel'] as String,
    ),
    seasonality: json['seasonality'] == null
        ? null
        : CityDetailClimateSeasonality(
            peakMonths: (json['seasonality']['peakMonths'] as List<dynamic>)
                .map((item) => item as int)
                .toList(growable: false),
            lowMonths: (json['seasonality']['lowMonths'] as List<dynamic>)
                .map((item) => item as int)
                .toList(growable: false),
            severity: json['seasonality']['severity'] as String,
            visitorsLabel: json['seasonality']['visitorsLabel'] as String,
            rentNotes: json['seasonality']['rentNotes'] as String,
            jobNotes: json['seasonality']['jobNotes'] as String,
            populationMultiplierNote:
                json['seasonality']['populationMultiplierNote'] as String?,
            updatedAt: json['seasonality']['updatedAt'] as String,
            sourceLabel: json['seasonality']['sourceLabel'] as String,
            sourceType: json['seasonality']['sourceType'] as String,
            sourceUrl: json['seasonality']['sourceUrl'] as String?,
          ),
    sources: (json['sources'] as List<dynamic>? ?? const [])
        .map((item) => sourceFromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

  static CityDetailArrivalStory arrivalStoryFromJson(
    Map<String, dynamic> json,
  ) => CityDetailArrivalStory(
    cityId: json['cityId'] as String,
    cityName: json['cityName'] as String,
    story: json['story'] == null
        ? null
        : insightFromJson(json['story'] as Map<String, dynamic>),
    firstMonthBudget: json['firstMonthBudget'] == null
        ? null
        : CityDetailArrivalBudget(
            fairLivingTotalBrl:
                json['firstMonthBudget']['fairLivingTotalBrl'] as int?,
            averageMonthlyNetSalaryBrl:
                json['firstMonthBudget']['averageMonthlyNetSalaryBrl'] as int,
            reserveMonths: json['firstMonthBudget']['reserveMonths'] as int,
            reserveAmountBrl:
                json['firstMonthBudget']['reserveAmountBrl'] as int?,
            sourceLabel: json['firstMonthBudget']['sourceLabel'] as String,
            updatedAt: json['firstMonthBudget']['updatedAt'] as String,
          ),
    firstMonthFocus: (json['firstMonthFocus'] as List<dynamic>? ?? const [])
        .map(
          (item) => CityDetailFocusItem(
            id: item['id'] as String,
            label: item['label'] as String,
            score: item['score'] as int,
          ),
        )
        .toList(growable: false),
    neighborhoods: (json['neighborhoods'] as List<dynamic>? ?? const [])
        .map(
          (item) => CityDetailNeighborhoodPlace(
            id: item['id'] as String,
            name: item['name'] as String,
            neighborhood: item['neighborhood'] as String?,
            region: item['region'] as String?,
            shortText: item['shortText'] as String,
            mapUrl: item['mapUrl'] as String,
            source: item['source'] as String,
          ),
        )
        .toList(growable: false),
    sources: (json['sources'] as List<dynamic>? ?? const [])
        .map((item) => sourceFromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

  static CityDetailComparison comparisonFromJson(Map<String, dynamic> json) =>
      CityDetailComparison(
        cityId: json['cityId'] as String,
        cityName: json['cityName'] as String,
        compareTo: (json['compareTo'] as List<dynamic>? ?? const [])
            .map(
              (item) => CityDetailComparisonCity(
                cityId: item['cityId'] as String,
                cityName: item['cityName'] as String,
                stateCode: item['stateCode'] as String,
              ),
            )
            .toList(growable: false),
        metrics: (json['metrics'] as List<dynamic>? ?? const [])
            .map(
              (item) => CityDetailComparisonMetric(
                id: item['id'] as String,
                label: item['label'] as String,
                unit: item['unit'] as String,
                primaryValue: item['primaryValue'] as num?,
                benchmark: item['benchmark'] as num?,
                primaryIsBest: item['primaryIsBest'] as bool? ?? false,
                benchmarkLabel: item['benchmarkLabel'] as String?,
                comparisons: (item['comparisons'] as List<dynamic>? ?? const [])
                    .map(
                      (entry) => CityDetailComparisonMetricValue(
                        cityId: entry['cityId'] as String,
                        cityName: entry['cityName'] as String,
                        value: entry['value'] as num?,
                      ),
                    )
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
        sources: (json['sources'] as List<dynamic>? ?? const [])
            .map((item) => sourceFromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );
}

import 'dart:math' as math;

import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_step_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class MigrationPlanGenerator {
  const MigrationPlanGenerator({required CitiesRepository citiesRepository})
    : _citiesRepository = citiesRepository;

  final CitiesRepository _citiesRepository;

  Future<MigrationPlan> generate({required List<Answer> answers}) async {
    final answerMap = {
      for (final answer in answers) answer.questionId: answer.value,
    };

    final originCountry = answerMap['origin_country'] ?? '';
    final destinationCountry = answerMap['destination_country'] ?? '';
    final goal = answerMap['goal'] ?? '';
    final portugueseFamiliarity = answerMap['portuguese_familiarity'] ?? '';
    final timeline = answerMap['timeline'] ?? '';
    final recommendation = await _recommendCity(
      destinationCountry: destinationCountry,
      goal: goal,
      portugueseFamiliarity: portugueseFamiliarity,
      timeline: timeline,
    );

    if (_isBrazilJourney(destinationCountry)) {
      return MigrationPlanModel(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        goal: goal,
        timeline: timeline,
        recommendedCity: recommendation.city,
        candidateCities: recommendation.candidates,
        cityRecommendationReasons: recommendation.reasons,
        isCityConfirmed: false,
        steps: const [
          MigrationStepModel(
            title: 'step_visa_residence',
            description: 'step_desc_visa_residence',
            category: 'documentation',
            estimatedDays: 7,
          ),
          MigrationStepModel(
            title: 'step_cpf',
            description: 'step_desc_cpf',
            category: 'documentation',
            estimatedDays: 3,
          ),
          MigrationStepModel(
            title: 'step_bank_account',
            description: 'step_desc_bank_account',
            category: 'financial',
            estimatedDays: 5,
          ),
          MigrationStepModel(
            title: 'step_housing',
            description: 'step_desc_housing',
            category: 'housing',
            estimatedDays: 14,
          ),
          MigrationStepModel(
            title: 'step_settle_documents',
            description: 'step_desc_settle_documents',
            category: 'settlement',
            estimatedDays: 10,
          ),
        ],
      ).toEntity();
    }

    return MigrationPlanModel(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      goal: goal,
      timeline: timeline,
      recommendedCity: recommendation.city,
      candidateCities: recommendation.candidates,
      cityRecommendationReasons: recommendation.reasons,
      isCityConfirmed: false,
      steps: const [
        MigrationStepModel(
          title: 'step_map_destinations',
          description: 'step_desc_map_destinations',
          category: 'research',
          estimatedDays: 7,
        ),
        MigrationStepModel(
          title: 'step_decision_criteria',
          description: 'step_desc_decision_criteria',
          category: 'planning',
          estimatedDays: 5,
        ),
      ],
    ).toEntity();
  }

  Future<({City? city, List<City> candidates, List<String> reasons})> _recommendCity({
    required String destinationCountry,
    required String goal,
    required String portugueseFamiliarity,
    required String timeline,
  }) async {
    if (!_isBrazilJourney(destinationCountry)) {
      return (city: null, candidates: const <City>[], reasons: const <String>[]);
    }

    try {
      final cities = await _citiesRepository.getCities(countryCode: 'BR');

      if (cities.isEmpty) {
        return (city: null, candidates: const <City>[], reasons: const <String>[]);
      }

      final rankedCities =
          cities
              .map(
                (city) => (
                  city: city,
                  score: _scoreCity(
                    city: city,
                    goal: goal,
                    portugueseFamiliarity: portugueseFamiliarity,
                    timeline: timeline,
                  ),
                ),
              )
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));

      final recommendedCity = rankedCities.first.city;
      final candidateCities = rankedCities
          .take(4)
          .map((entry) => entry.city)
          .toList();

      return (
        city: recommendedCity,
        candidates: candidateCities,
        reasons: _buildRecommendationReasons(
          city: recommendedCity,
          goal: goal,
          portugueseFamiliarity: portugueseFamiliarity,
          timeline: timeline,
        ),
      );
    } catch (_) {
      return (city: null, candidates: const <City>[], reasons: const <String>[]);
    }
  }

  double _scoreCity({
    required City city,
    required String goal,
    required String portugueseFamiliarity,
    required String timeline,
  }) {
    var score = city.movaroScores.overall.toDouble();

    switch (goal) {
      case 'work':
        score += city.movaroScores.workOpportunity * 1.4;
        score += city.jobMarketScore * 0.4;
      case 'remote_work':
        score += city.movaroScores.economical * 0.8;
        score += city.safetyScore * 0.7;
        score += _industryBonus(city, const ['Tecnologia', 'Servicos']);
      case 'study':
        score += city.safetyScore * 0.5;
        score += math.min(city.population / 100000, 12);
        score += city.movaroScores.workOpportunity * 0.3;
      case 'entrepreneur':
        score += city.economicActivityScore * 0.9;
        score += math.min(city.population / 80000, 16);
      case 'retire':
        score += city.safetyScore * 1.0;
        score += city.movaroScores.economical * 0.8;
      case 'quality_of_life':
        score += city.safetyScore * 1.0;
        score += city.movaroScores.economical * 0.7;
        score += city.movaroScores.popularForArgentinians * 0.2;
      case 'beach_life':
        score += city.safetyScore * 0.9;
        score += city.movaroScores.economical * 0.45;
        score += city.movaroScores.popularForArgentinians * 0.35;
        score += CityCoastalProfile.isCoastal(city) ? 90 : -35;
      default:
        score += city.movaroScores.overall * 0.3;
    }

    switch (portugueseFamiliarity) {
      case 'no_portuguese':
        score += city.movaroScores.languageAdaptation * 1.15;
        score += city.spanishSupportScore * 0.35;
      case 'basic_portuguese':
        score += city.movaroScores.languageAdaptation * 0.65;
      case 'comfortable_portuguese':
        score += city.movaroScores.languageAdaptation * 0.15;
      default:
        score += city.movaroScores.languageAdaptation * 0.35;
    }

    switch (timeline) {
      case 'asap':
        score += city.movaroScores.popularForArgentinians * 0.35;
        score += city.movaroScores.economical * 0.2;
      case '6_months':
        score += city.movaroScores.popularForArgentinians * 0.2;
        score += city.movaroScores.economical * 0.15;
      case '12_months':
        score += city.movaroScores.economical * 0.15;
      case 'researching':
        score += city.movaroScores.overall * 0.1;
      default:
        break;
    }

    return score;
  }

  double _industryBonus(City city, List<String> industries) {
    final normalizedIndustries = city.topIndustries.map((item) => item.trim());

    for (final industry in industries) {
      if (normalizedIndustries.contains(industry)) {
        return 12;
      }
    }

    return 0;
  }

  List<String> _buildRecommendationReasons({
    required City city,
    required String goal,
    required String portugueseFamiliarity,
    required String timeline,
  }) {
    final reasons = <String>[];

    switch (goal) {
      case 'work':
        reasons.add('plan_reason_goal_work');
      case 'remote_work':
        reasons.add('plan_reason_goal_remote_work');
      case 'study':
        reasons.add('plan_reason_goal_study');
      case 'entrepreneur':
        reasons.add('plan_reason_goal_entrepreneur');
      case 'retire':
        reasons.add('plan_reason_goal_retire');
      case 'quality_of_life':
        reasons.add('plan_reason_goal_quality_of_life');
      case 'beach_life':
        reasons.add('plan_reason_goal_beach_life');
      default:
        break;
    }

    switch (timeline) {
      case 'asap':
        reasons.add('plan_reason_timeline_asap');
      case '6_months':
        reasons.add('plan_reason_timeline_6_months');
      case '12_months':
        reasons.add('plan_reason_timeline_12_months');
      default:
        break;
    }

    switch (portugueseFamiliarity) {
      case 'no_portuguese':
        reasons.add('plan_reason_language_needs_support');
      case 'basic_portuguese':
        reasons.add('plan_reason_language_basic');
      default:
        break;
    }

    for (final reason in city.recommendationReasons) {
      if (reasons.length >= 3) {
        break;
      }

      if (!reasons.contains(reason)) {
        reasons.add(reason);
      }
    }

    return reasons;
  }

  bool _isBrazilJourney(String destinationCountry) =>
      destinationCountry == 'brazil' || destinationCountry == 'brasil';
}

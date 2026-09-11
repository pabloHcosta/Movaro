enum WorkExperienceLevel { starting, junior, experienced }

enum PortugueseWorkLevel { starting, functional, professional }

enum ProfessionRegulationStatus { no, unsure, requiredPending, requiredReady }

enum WorkViabilityLevel { incomplete, attention, viable }

class WorkViabilityProfile {
  const WorkViabilityProfile({
    this.workArea = '',
    this.experienceLevel,
    this.portugueseLevel,
    this.regulationStatus,
    this.reviewedOpenings = 0,
    this.expectedMonthlyIncomeBrl,
    this.essentialMonthlyCostBrl,
  });

  final String workArea;
  final WorkExperienceLevel? experienceLevel;
  final PortugueseWorkLevel? portugueseLevel;
  final ProfessionRegulationStatus? regulationStatus;
  final int reviewedOpenings;
  final int? expectedMonthlyIncomeBrl;
  final int? essentialMonthlyCostBrl;

  bool get isComplete =>
      workArea.trim().isNotEmpty &&
      experienceLevel != null &&
      portugueseLevel != null &&
      regulationStatus != null &&
      expectedMonthlyIncomeBrl != null &&
      expectedMonthlyIncomeBrl! > 0 &&
      essentialMonthlyCostBrl != null &&
      essentialMonthlyCostBrl! > 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workArea': workArea.trim(),
    'experienceLevel': experienceLevel?.name,
    'portugueseLevel': portugueseLevel?.name,
    'regulationStatus': regulationStatus?.name,
    'reviewedOpenings': reviewedOpenings,
    'expectedMonthlyIncomeBrl': expectedMonthlyIncomeBrl,
    'essentialMonthlyCostBrl': essentialMonthlyCostBrl,
  };

  factory WorkViabilityProfile.fromJson(Map<String, dynamic>? value) {
    if (value == null) return const WorkViabilityProfile();
    return WorkViabilityProfile(
      workArea: value['workArea'] is String ? value['workArea'] as String : '',
      experienceLevel: _enumByName(
        WorkExperienceLevel.values,
        value['experienceLevel'],
      ),
      portugueseLevel: _enumByName(
        PortugueseWorkLevel.values,
        value['portugueseLevel'],
      ),
      regulationStatus: value['regulationStatus'] == 'yes'
          ? ProfessionRegulationStatus.requiredPending
          : _enumByName(
              ProfessionRegulationStatus.values,
              value['regulationStatus'],
            ),
      reviewedOpenings: _nonNegativeInt(value['reviewedOpenings']) ?? 0,
      expectedMonthlyIncomeBrl: _positiveInt(value['expectedMonthlyIncomeBrl']),
      essentialMonthlyCostBrl: _positiveInt(value['essentialMonthlyCostBrl']),
    );
  }
}

class WorkViabilityAssessment {
  const WorkViabilityAssessment({
    required this.level,
    required this.signalKeys,
    required this.actionKeys,
    this.monthlyGapBrl,
  });

  final WorkViabilityLevel level;
  final List<String> signalKeys;
  final List<String> actionKeys;
  final int? monthlyGapBrl;
}

class WorkViabilityAssessor {
  const WorkViabilityAssessor._();

  static WorkViabilityAssessment assess(WorkViabilityProfile profile) {
    if (!profile.isComplete) {
      return const WorkViabilityAssessment(
        level: WorkViabilityLevel.incomplete,
        signalKeys: <String>['complete_profile'],
        actionKeys: <String>['complete_profile'],
      );
    }

    final signals = <String>[];
    final actions = <String>[];
    var hasMaterialRisk = false;
    int? monthlyGap;

    if (profile.reviewedOpenings < 3) {
      signals.add('limited_opening_evidence');
      actions.add('review_three_openings');
      hasMaterialRisk = true;
    } else {
      signals.add('opening_evidence_recorded');
    }

    if (profile.portugueseLevel == PortugueseWorkLevel.starting) {
      signals.add('portuguese_gap');
      actions.add('prepare_portuguese_profile');
      hasMaterialRisk = true;
    }

    if (profile.experienceLevel == WorkExperienceLevel.starting) {
      signals.add('experience_gap');
      actions.add('target_entry_roles');
      hasMaterialRisk = true;
    }

    if (profile.regulationStatus == ProfessionRegulationStatus.unsure ||
        profile.regulationStatus ==
            ProfessionRegulationStatus.requiredPending) {
      signals.add(
        profile.regulationStatus == ProfessionRegulationStatus.unsure
            ? 'regulation_unknown'
            : 'regulated_profession',
      );
      actions.add('confirm_profession_recognition');
      hasMaterialRisk = true;
    } else if (profile.regulationStatus ==
        ProfessionRegulationStatus.requiredReady) {
      signals.add('recognition_ready');
    }

    final income = profile.expectedMonthlyIncomeBrl!;
    final cost = profile.essentialMonthlyCostBrl!;
    if (income < cost) {
      monthlyGap = cost - income;
      signals.add('income_below_cost');
      actions.add('close_income_gap');
      hasMaterialRisk = true;
    } else {
      signals.add('income_covers_cost');
    }

    return WorkViabilityAssessment(
      level: hasMaterialRisk
          ? WorkViabilityLevel.attention
          : WorkViabilityLevel.viable,
      signalKeys: List<String>.unmodifiable(signals),
      actionKeys: List<String>.unmodifiable(actions),
      monthlyGapBrl: monthlyGap,
    );
  }
}

T? _enumByName<T extends Enum>(List<T> values, Object? rawValue) {
  if (rawValue is! String) return null;
  for (final value in values) {
    if (value.name == rawValue) return value;
  }
  return null;
}

int? _positiveInt(Object? value) {
  final parsed = value is num ? value.toInt() : null;
  return parsed != null && parsed > 0 ? parsed : null;
}

int? _nonNegativeInt(Object? value) {
  final parsed = value is num ? value.toInt() : null;
  return parsed != null && parsed >= 0 ? parsed : null;
}

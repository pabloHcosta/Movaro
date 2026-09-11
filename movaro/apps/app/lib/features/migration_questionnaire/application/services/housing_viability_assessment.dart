enum HousingRequirementStatus { accepted, pending, unavailable }

enum HousingLeaseStatus { searching, underReview, signedWithKeys }

enum HousingViabilityLevel { incomplete, attention, viable }

class HousingViabilityProfile {
  const HousingViabilityProfile({
    this.reviewedListings = 0,
    this.monthlyIncomeBrl,
    this.monthlyHousingCostBrl,
    this.upfrontRequiredBrl,
    this.upfrontAvailableBrl,
    this.incomeProofStatus,
    this.guaranteeStatus,
    this.hasTemporaryFallback,
    this.leaseStatus,
  });

  final int reviewedListings;
  final int? monthlyIncomeBrl;
  final int? monthlyHousingCostBrl;
  final int? upfrontRequiredBrl;
  final int? upfrontAvailableBrl;
  final HousingRequirementStatus? incomeProofStatus;
  final HousingRequirementStatus? guaranteeStatus;
  final bool? hasTemporaryFallback;
  final HousingLeaseStatus? leaseStatus;

  bool get isComplete =>
      monthlyIncomeBrl != null &&
      monthlyIncomeBrl! > 0 &&
      monthlyHousingCostBrl != null &&
      monthlyHousingCostBrl! > 0 &&
      upfrontRequiredBrl != null &&
      upfrontRequiredBrl! >= 0 &&
      upfrontAvailableBrl != null &&
      upfrontAvailableBrl! >= 0 &&
      incomeProofStatus != null &&
      guaranteeStatus != null &&
      hasTemporaryFallback != null &&
      leaseStatus != null;

  bool get hasCompletedOutcome =>
      isComplete && leaseStatus == HousingLeaseStatus.signedWithKeys;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'reviewedListings': reviewedListings,
    'monthlyIncomeBrl': monthlyIncomeBrl,
    'monthlyHousingCostBrl': monthlyHousingCostBrl,
    'upfrontRequiredBrl': upfrontRequiredBrl,
    'upfrontAvailableBrl': upfrontAvailableBrl,
    'incomeProofStatus': incomeProofStatus?.name,
    'guaranteeStatus': guaranteeStatus?.name,
    'hasTemporaryFallback': hasTemporaryFallback,
    'leaseStatus': leaseStatus?.name,
  };

  factory HousingViabilityProfile.fromJson(Map<String, dynamic>? value) {
    if (value == null) return const HousingViabilityProfile();
    return HousingViabilityProfile(
      reviewedListings: _nonNegativeInt(value['reviewedListings']) ?? 0,
      monthlyIncomeBrl: _positiveInt(value['monthlyIncomeBrl']),
      monthlyHousingCostBrl: _positiveInt(value['monthlyHousingCostBrl']),
      upfrontRequiredBrl: _nonNegativeInt(value['upfrontRequiredBrl']),
      upfrontAvailableBrl: _nonNegativeInt(value['upfrontAvailableBrl']),
      incomeProofStatus: _enumByName(
        HousingRequirementStatus.values,
        value['incomeProofStatus'],
      ),
      guaranteeStatus: _enumByName(
        HousingRequirementStatus.values,
        value['guaranteeStatus'],
      ),
      hasTemporaryFallback: value['hasTemporaryFallback'] is bool
          ? value['hasTemporaryFallback'] as bool
          : null,
      leaseStatus: _enumByName(HousingLeaseStatus.values, value['leaseStatus']),
    );
  }
}

class HousingViabilityAssessment {
  const HousingViabilityAssessment({
    required this.level,
    required this.signalKeys,
    required this.actionKeys,
    this.upfrontGapBrl,
    this.housingIncomeRatio,
  });

  final HousingViabilityLevel level;
  final List<String> signalKeys;
  final List<String> actionKeys;
  final int? upfrontGapBrl;
  final double? housingIncomeRatio;
}

class HousingViabilityAssessor {
  const HousingViabilityAssessor._();

  static HousingViabilityAssessment assess(HousingViabilityProfile profile) {
    if (!profile.isComplete) {
      return const HousingViabilityAssessment(
        level: HousingViabilityLevel.incomplete,
        signalKeys: <String>['complete_profile'],
        actionKeys: <String>['complete_profile'],
      );
    }

    final signals = <String>[];
    final actions = <String>[];
    var hasMaterialRisk = false;

    if (profile.reviewedListings < 3) {
      signals.add('limited_listing_evidence');
      actions.add('compare_three_listings');
      hasMaterialRisk = true;
    } else {
      signals.add('listing_evidence_recorded');
    }

    final ratio = profile.monthlyHousingCostBrl! / profile.monthlyIncomeBrl!;
    if (ratio > 0.35) {
      signals.add('high_housing_ratio');
      actions.add('adjust_housing_budget');
      hasMaterialRisk = true;
    } else {
      signals.add('housing_ratio_within_plan');
    }

    final upfrontGap =
        profile.upfrontRequiredBrl! - profile.upfrontAvailableBrl!;
    final normalizedGap = upfrontGap > 0 ? upfrontGap : null;
    if (normalizedGap != null) {
      signals.add('upfront_funds_gap');
      actions.add('close_upfront_gap');
      hasMaterialRisk = true;
    } else {
      signals.add('upfront_funds_covered');
    }

    _assessRequirement(
      status: profile.incomeProofStatus!,
      acceptedSignal: 'income_proof_accepted',
      pendingSignal: 'income_proof_pending',
      unavailableSignal: 'income_proof_unavailable',
      action: 'confirm_income_proof',
      signals: signals,
      actions: actions,
      markRisk: () => hasMaterialRisk = true,
    );
    _assessRequirement(
      status: profile.guaranteeStatus!,
      acceptedSignal: 'guarantee_accepted',
      pendingSignal: 'guarantee_pending',
      unavailableSignal: 'guarantee_unavailable',
      action: 'confirm_rental_guarantee',
      signals: signals,
      actions: actions,
      markRisk: () => hasMaterialRisk = true,
    );

    if (profile.hasTemporaryFallback == true) {
      signals.add('temporary_fallback_ready');
    } else {
      signals.add('temporary_fallback_missing');
      actions.add('prepare_temporary_fallback');
      hasMaterialRisk = true;
    }

    switch (profile.leaseStatus!) {
      case HousingLeaseStatus.searching:
        signals.add('lease_searching');
        actions.add('continue_verified_search');
        hasMaterialRisk = true;
      case HousingLeaseStatus.underReview:
        signals.add('lease_under_review');
        actions.add('review_before_signing');
        hasMaterialRisk = true;
      case HousingLeaseStatus.signedWithKeys:
        signals.add('lease_secured');
    }

    return HousingViabilityAssessment(
      level: hasMaterialRisk
          ? HousingViabilityLevel.attention
          : HousingViabilityLevel.viable,
      signalKeys: List<String>.unmodifiable(signals),
      actionKeys: List<String>.unmodifiable(actions),
      upfrontGapBrl: normalizedGap,
      housingIncomeRatio: ratio,
    );
  }

  static void _assessRequirement({
    required HousingRequirementStatus status,
    required String acceptedSignal,
    required String pendingSignal,
    required String unavailableSignal,
    required String action,
    required List<String> signals,
    required List<String> actions,
    required void Function() markRisk,
  }) {
    switch (status) {
      case HousingRequirementStatus.accepted:
        signals.add(acceptedSignal);
      case HousingRequirementStatus.pending:
        signals.add(pendingSignal);
        actions.add(action);
        markRisk();
      case HousingRequirementStatus.unavailable:
        signals.add(unavailableSignal);
        actions.add(action);
        markRisk();
    }
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

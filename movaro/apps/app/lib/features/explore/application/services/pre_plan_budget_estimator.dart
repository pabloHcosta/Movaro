class PrePlanBudgetProfile {
  const PrePlanBudgetProfile({
    this.adults = 1,
    this.children = 0,
    this.temporaryStayDays = 14,
    this.plannedMonthlyRentBrl = 2000,
    this.includePublicTransit = true,
    this.includePrivateHealth = false,
    this.hasPet = false,
    this.usePrivateSchool = false,
    this.privateSchoolMonthlyBrlPerChild = 1500,
    this.includeHigherEducation = false,
    this.usePrivateHigherEducation = false,
    this.privateHigherEducationMonthlyBrl = 1200,
  });

  final int adults;
  final int children;
  final int temporaryStayDays;
  final int plannedMonthlyRentBrl;
  final bool includePublicTransit;
  final bool includePrivateHealth;
  final bool hasPet;
  final bool usePrivateSchool;
  final int privateSchoolMonthlyBrlPerChild;
  final bool includeHigherEducation;
  final bool usePrivateHigherEducation;
  final int privateHigherEducationMonthlyBrl;

  int get travelers => adults + children;

  PrePlanBudgetProfile copyWith({
    int? adults,
    int? children,
    int? temporaryStayDays,
    int? plannedMonthlyRentBrl,
    bool? includePublicTransit,
    bool? includePrivateHealth,
    bool? hasPet,
    bool? usePrivateSchool,
    int? privateSchoolMonthlyBrlPerChild,
    bool? includeHigherEducation,
    bool? usePrivateHigherEducation,
    int? privateHigherEducationMonthlyBrl,
  }) {
    return PrePlanBudgetProfile(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      temporaryStayDays: temporaryStayDays ?? this.temporaryStayDays,
      plannedMonthlyRentBrl:
          plannedMonthlyRentBrl ?? this.plannedMonthlyRentBrl,
      includePublicTransit: includePublicTransit ?? this.includePublicTransit,
      includePrivateHealth: includePrivateHealth ?? this.includePrivateHealth,
      hasPet: hasPet ?? this.hasPet,
      usePrivateSchool: usePrivateSchool ?? this.usePrivateSchool,
      privateSchoolMonthlyBrlPerChild:
          privateSchoolMonthlyBrlPerChild ??
          this.privateSchoolMonthlyBrlPerChild,
      includeHigherEducation:
          includeHigherEducation ?? this.includeHigherEducation,
      usePrivateHigherEducation:
          usePrivateHigherEducation ?? this.usePrivateHigherEducation,
      privateHigherEducationMonthlyBrl:
          privateHigherEducationMonthlyBrl ??
          this.privateHigherEducationMonthlyBrl,
    );
  }
}

class PrePlanBudgetEstimate {
  const PrePlanBudgetEstimate({
    required this.officialFeesBrl,
    required this.housingReserveBrl,
    required this.temporaryStayBrl,
    required this.monthlyEssentialsBrl,
    required this.optionalServicesBrl,
    required this.educationMonthlyBrl,
  });

  final double officialFeesBrl;
  final double housingReserveBrl;
  final double temporaryStayBrl;
  final double monthlyEssentialsBrl;
  final double optionalServicesBrl;
  final double educationMonthlyBrl;

  double get essentialTotalBrl =>
      officialFeesBrl +
      housingReserveBrl +
      temporaryStayBrl +
      monthlyEssentialsBrl;

  double get recommendedTotalBrl =>
      essentialTotalBrl + optionalServicesBrl + educationMonthlyBrl;

  double get saferTotalBrl => recommendedTotalBrl + (monthlyEssentialsBrl * 2);
}

/// A city-neutral preview used before the user confirms a destination city.
///
/// Inputs are deliberately explicit and nothing is persisted to the migration
/// plan. City datasets belong exclusively to the execution budget.
class PrePlanBudgetEstimator {
  const PrePlanBudgetEstimator._();

  static const double residenceAndCrnmFeesBrl = 372.90;

  static PrePlanBudgetEstimate build(PrePlanBudgetProfile profile) {
    final householdFactor =
        profile.adults + (profile.children * 0.65).clamp(0, 2.6);
    final officialFees = residenceAndCrnmFeesBrl * profile.travelers;
    final housingReserve = profile.plannedMonthlyRentBrl * 4.25;
    final temporaryStay =
        profile.temporaryStayDays * 180 * householdFactor.clamp(1, 3);
    final foodAndBasics = 1200 * householdFactor;
    final transit = profile.includePublicTransit ? 250 * profile.travelers : 0;
    final monthlyEssentials =
        foodAndBasics + transit + (profile.plannedMonthlyRentBrl * 0.3);
    final privateHealth = profile.includePrivateHealth
        ? 450 * profile.travelers
        : 0;
    final pet = profile.hasPet ? 350 : 0;
    final privateSchool = profile.usePrivateSchool
        ? profile.privateSchoolMonthlyBrlPerChild * profile.children
        : 0;
    final privateHigherEducation =
        profile.includeHigherEducation && profile.usePrivateHigherEducation
        ? profile.privateHigherEducationMonthlyBrl
        : 0;

    return PrePlanBudgetEstimate(
      officialFeesBrl: officialFees,
      housingReserveBrl: housingReserve.toDouble(),
      temporaryStayBrl: temporaryStay.toDouble(),
      monthlyEssentialsBrl: monthlyEssentials.toDouble(),
      optionalServicesBrl: (privateHealth + pet).toDouble(),
      educationMonthlyBrl: (privateSchool + privateHigherEducation).toDouble(),
    );
  }
}

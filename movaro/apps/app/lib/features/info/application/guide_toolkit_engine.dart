import 'package:movaro_app/features/info/domain/entities/guide_toolkit.dart';

class GuideToolkitEngine {
  const GuideToolkitEngine();

  GuideToolkitResult evaluate({
    required GuideToolkitKind kind,
    Set<String> answers = const {},
    Map<String, double> amounts = const {},
  }) {
    return switch (kind) {
      GuideToolkitKind.finance => _finance(answers),
      GuideToolkitKind.costs => _costs(answers, amounts),
      GuideToolkitKind.housing => _housing(answers, amounts),
      GuideToolkitKind.work => _work(answers),
      GuideToolkitKind.tax => _tax(answers),
      GuideToolkitKind.family => _family(answers),
      GuideToolkitKind.dependencies => _dependencies(answers),
      GuideToolkitKind.health => _health(answers),
      GuideToolkitKind.petsCustoms => _petsCustoms(answers),
      GuideToolkitKind.utilities => _utilities(answers),
      GuideToolkitKind.protection => _protection(answers),
      GuideToolkitKind.consumer => _consumer(answers),
      GuideToolkitKind.longTerm => _longTerm(answers),
    };
  }

  GuideToolkitResult _finance(Set<String> answers) {
    final actions = <String>[];
    if (!answers.contains('cpf')) actions.add('finance_get_cpf');
    if (!answers.contains('phone')) actions.add('finance_get_phone');
    if (!answers.contains('address')) actions.add('finance_address_proof');
    if (!answers.contains('bank')) actions.add('finance_open_account');
    if (!answers.contains('pix')) actions.add('finance_enable_pix');
    if (!answers.contains('govbr')) actions.add('finance_strengthen_govbr');
    return GuideToolkitResult(
      status: actions.isEmpty ? 'ready' : 'path_ready',
      actionIds: actions,
    );
  }

  GuideToolkitResult _costs(Set<String> answers, Map<String, double> amounts) {
    final rent = amounts['rent'] ?? 0;
    final housingFees = amounts['housingFees'] ?? 0;
    final living = amounts['living'] ?? 0;
    final travel = amounts['travel'] ?? 0;
    final setup = amounts['setup'] ?? 0;
    final months = amounts['months']?.clamp(1, 3) ?? 1;
    final guaranteeMonths = amounts['guaranteeMonths']?.clamp(0, 3) ?? 0;
    final monthly = rent + housingFees + living;
    final entry = travel + setup + (rent * guaranteeMonths);
    final reserve = entry + (monthly * months);
    return GuideToolkitResult(
      status: monthly > 0 ? 'estimate_ready' : 'needs_values',
      monthlyTotal: monthly,
      entryTotal: entry,
      reserveTotal: reserve,
      actionIds: const [
        'costs_compare_income',
        'costs_keep_emergency_buffer',
        'costs_review_city_prices',
      ],
    );
  }

  GuideToolkitResult _housing(
    Set<String> answers,
    Map<String, double> amounts,
  ) {
    final rent = amounts['rent'] ?? 0;
    final fees = amounts['housingFees'] ?? 0;
    final guaranteeMonths = answers.contains('deposit')
        ? 3.0
        : answers.contains('insurance')
        ? 1.5
        : 0.0;
    final entry = rent + fees + (rent * guaranteeMonths);
    return GuideToolkitResult(
      status: rent > 0 ? 'estimate_ready' : 'needs_values',
      monthlyTotal: rent + fees,
      entryTotal: entry,
      actionIds: const [
        'housing_verify_owner',
        'housing_compare_guarantee',
        'housing_inspection',
        'housing_read_charges',
        'housing_no_advance_pix',
      ],
    );
  }

  GuideToolkitResult _work(Set<String> answers) {
    final actions = <String>[];
    if (!answers.contains('cpf')) actions.add('work_get_cpf');
    if (!answers.contains('authorized')) actions.add('work_confirm_status');
    if (answers.contains('clt')) actions.add('work_enable_ctps');
    if (answers.contains('pj')) actions.add('work_check_mei');
    if (answers.contains('remote')) actions.add('work_remote_tax');
    if (answers.contains('regulated')) actions.add('work_validate_diploma');
    actions.addAll(const ['work_adapt_resume', 'work_safe_search']);
    return GuideToolkitResult(
      status: answers.contains('cpf') && answers.contains('authorized')
          ? 'documents_ready'
          : 'documents_pending',
      actionIds: actions.toSet().toList(growable: false),
      requiresProfessional: answers.contains('remote'),
    );
  }

  GuideToolkitResult _tax(Set<String> answers) {
    final hasRiskFacts = answers.intersection(const {
      'permanent',
      'over183',
      'foreignIncome',
      'foreignAssets',
      'company',
    }).isNotEmpty;
    final actions = <String>[
      'tax_record_dates',
      if (answers.contains('foreignIncome')) 'tax_list_foreign_income',
      if (answers.contains('foreignAssets')) 'tax_list_assets',
      if (answers.contains('company')) 'tax_map_company_role',
      'tax_collect_paid_tax',
      'tax_find_cross_border_accountant',
    ];
    return GuideToolkitResult(
      status: hasRiskFacts ? 'professional_review' : 'monitor_status',
      actionIds: actions,
      requiresProfessional: true,
    );
  }

  GuideToolkitResult _family(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('partner')) actions.add('family_relationship_docs');
    if (answers.contains('children')) {
      actions.addAll(const [
        'family_child_travel_authorization',
        'family_civil_school_docs',
      ]);
    }
    if (answers.contains('school')) actions.add('family_school_enrollment');
    if (answers.contains('childcare')) actions.add('family_childcare_city');
    if (answers.contains('diploma')) actions.add('family_diploma_route');
    if (answers.contains('regulated')) actions.add('family_professional_board');
    actions.add('family_check_residence_route');
    return GuideToolkitResult(status: 'path_ready', actionIds: actions);
  }

  GuideToolkitResult _dependencies(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('residence')) actions.add('dependency_residence');
    if (answers.contains('cpf')) actions.add('dependency_cpf');
    if (answers.contains('phone')) actions.add('dependency_phone');
    if (answers.contains('address')) actions.add('dependency_address');
    if (answers.contains('bank')) actions.add('dependency_bank');
    if (answers.contains('work')) actions.add('dependency_work');
    if (answers.contains('school')) actions.add('dependency_school');
    if (actions.isEmpty) actions.add('dependency_choose_blocker');
    return GuideToolkitResult(status: 'sequence_ready', actionIds: actions);
  }

  GuideToolkitResult _health(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('emergency')) actions.add('health_emergency_channel');
    if (answers.contains('continuousMedication')) {
      actions.addAll(const [
        'health_prepare_summary',
        'health_carry_prescription',
        'health_book_local_care',
      ]);
    }
    if (answers.contains('controlledMedication')) {
      actions.add('health_check_controlled_medicine');
    }
    if (answers.contains('vaccination')) actions.add('health_vaccine_record');
    if (answers.contains('pregnancy')) actions.add('health_prenatal');
    if (answers.contains('mentalHealth')) actions.add('health_mental_health');
    if (answers.contains('dental')) actions.add('health_dental');
    if (answers.contains('privatePlan')) actions.add('health_compare_plan');
    actions.add('health_find_ubs');
    return GuideToolkitResult(
      status: answers.contains('emergency') ? 'urgent_referral' : 'care_path',
      actionIds: actions.toSet().toList(growable: false),
      requiresProfessional: answers.intersection(const {
        'continuousMedication',
        'controlledMedication',
        'pregnancy',
        'mentalHealth',
      }).isNotEmpty,
    );
  }

  GuideToolkitResult _petsCustoms(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('dogCat')) {
      actions.addAll(const ['moving_pet_origin_authority', 'moving_pet_cvi']);
    }
    if (answers.contains('otherPet')) actions.add('moving_other_pet_rules');
    if (answers.contains('foodPlants')) actions.add('moving_check_agriculture');
    if (answers.contains('medicines')) actions.add('moving_medicine_documents');
    if (answers.contains('electronics')) actions.add('moving_list_electronics');
    if (answers.contains('householdGoods')) actions.add('moving_baggage_route');
    if (answers.contains('vehicle')) actions.add('moving_vehicle_route');
    actions.addAll(const ['moving_check_carrier', 'moving_declare_uncertain']);
    return GuideToolkitResult(
      status: 'entry_checklist',
      actionIds: actions.toSet().toList(growable: false),
      requiresProfessional:
          answers.contains('medicines') ||
          answers.contains('vehicle') ||
          answers.contains('otherPet'),
    );
  }

  GuideToolkitResult _utilities(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('phone')) actions.add('utilities_phone');
    if (answers.contains('internet')) actions.add('utilities_internet');
    if (answers.contains('energy')) actions.add('utilities_energy');
    if (answers.contains('water')) actions.add('utilities_water');
    if (answers.contains('address')) actions.add('utilities_address_proof');
    if (answers.contains('previousDebt')) {
      actions.add('utilities_previous_debt');
    }
    if (actions.isEmpty) actions.add('utilities_choose_service');
    actions.add('utilities_keep_protocol');
    return GuideToolkitResult(status: 'setup_path', actionIds: actions);
  }

  GuideToolkitResult _protection(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('urgent')) actions.add('protection_emergency');
    if (answers.contains('womenViolence')) actions.add('protection_women');
    if (answers.contains('discrimination')) actions.add('protection_disque100');
    if (answers.contains('laborExploitation')) {
      actions.add('protection_labor_exploitation');
    }
    if (answers.contains('legalAid')) actions.add('protection_legal_aid');
    if (answers.contains('socialAid')) actions.add('protection_social_aid');
    if (actions.isEmpty) actions.add('protection_choose_situation');
    actions.add('protection_preserve_evidence');
    return GuideToolkitResult(
      status: answers.contains('urgent') ? 'urgent_referral' : 'support_path',
      actionIds: actions,
      requiresProfessional:
          answers.contains('legalAid') || answers.contains('laborExploitation'),
    );
  }

  GuideToolkitResult _consumer(Set<String> answers) {
    final actions = <String>['consumer_contact_company'];
    if (answers.contains('bank')) actions.add('consumer_bank_channel');
    if (answers.contains('telecom')) actions.add('consumer_anatel');
    if (answers.contains('energy')) actions.add('consumer_aneel');
    if (answers.contains('housing')) actions.add('consumer_housing_docs');
    if (answers.contains('online')) actions.add('consumer_online_purchase');
    if (answers.contains('fraud')) actions.add('consumer_fraud_response');
    actions.addAll(const ['consumer_escalate', 'consumer_keep_evidence']);
    return GuideToolkitResult(
      status: answers.contains('fraud') ? 'protect_first' : 'complaint_path',
      actionIds: actions.toSet().toList(growable: false),
      requiresProfessional: answers.contains('housing'),
    );
  }

  GuideToolkitResult _longTerm(Set<String> answers) {
    final actions = <String>[];
    if (answers.contains('brazilContributions')) {
      actions.add('longterm_brazil_records');
    }
    if (answers.contains('argentinaContributions')) {
      actions.add('longterm_argentina_records');
    }
    if (answers.contains('retirement')) actions.add('longterm_agreement');
    if (answers.contains('disability')) actions.add('longterm_disability');
    if (answers.contains('dependents')) actions.add('longterm_dependents');
    if (answers.contains('naturalization')) {
      actions.addAll(const [
        'longterm_naturalization_type',
        'longterm_residence_evidence',
        'longterm_language_records',
        'longterm_naturalizarse',
      ]);
    }
    if (answers.contains('childNaturalization')) {
      actions.add('longterm_child_naturalization');
    }
    if (actions.isEmpty) actions.add('longterm_choose_goal');
    return GuideToolkitResult(
      status: 'professional_screening',
      actionIds: actions,
      requiresProfessional: true,
    );
  }
}

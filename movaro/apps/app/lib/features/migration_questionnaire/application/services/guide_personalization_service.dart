import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class GuidePersonalizationService {
  const GuidePersonalizationService._();

  static List<GuideActionItem> personalize({
    required MigrationPlan plan,
    required List<GuideActionItem> items,
    required Set<String> explicitCompletedIds,
    required Map<String, GuideDismissReason> explicitDismissedReasons,
    String localeCode = 'pt',
  }) {
    final activeConditions = _activeConditions(plan);
    final personalized = <GuideActionItem>[
      ..._questionnaireMilestones(plan: plan, localeCode: localeCode),
    ];

    for (final item in items) {
      final touchedByUser =
          explicitCompletedIds.contains(item.id) ||
          explicitDismissedReasons.containsKey(item.id);
      final applicability = item.applicabilityConditions.isNotEmpty
          ? item.applicabilityConditions
          : _legacyApplicabilityConditions(item.id);
      final shouldAutoDismiss =
          !touchedByUser &&
          applicability.isNotEmpty &&
          !_isApplicable(applicability, activeConditions);

      personalized.add(
        item.copyWith(
          applicabilityConditions: applicability,
          tier: _inferTier(item),
          isDismissible: !_isSurveyMilestone(item.id),
          isCompleted: shouldAutoDismiss ? true : item.isCompleted,
          dismissReason: shouldAutoDismiss
              ? GuideDismissReason.notApplicable
              : item.dismissReason,
        ),
      );
    }

    personalized.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return personalized;
  }

  static List<GuideActionItem> _questionnaireMilestones({
    required MigrationPlan plan,
    required String localeCode,
  }) {
    var orderIndex = -3;
    final milestones = <GuideActionItem>[];

    if (plan.goal.isNotEmpty) {
      milestones.add(
        GuideActionItem(
          id: 'questionnaire_goal_defined',
          title: _t(
            localeCode,
            pt: 'Seu objetivo já está definido',
            es: 'Tu objetivo ya esta definido',
            en: 'Your migration goal is already defined',
          ),
          shortDescription: _goalSummary(plan.goal, localeCode),
          type: GuideActionType.informative,
          phase: GuidePhase.preparation,
          orderIndex: orderIndex++,
          isCompleted: true,
          tier: GuideItemTier.optional,
          isDismissible: false,
          badgeLabel: _t(
            localeCode,
            pt: 'Respondido no questionário',
            es: 'Respondido en el cuestionario',
            en: 'Answered in the questionnaire',
          ),
          context: _t(
            localeCode,
            pt: 'Você não começa do zero: o guia já sabe por que você quer se mudar.',
            es: 'No empiezas de cero: la guia ya sabe por que quieres mudarte.',
            en: 'You are not starting from zero: the guide already knows why you want to move.',
          ),
        ),
      );
    }

    if (plan.timeline.isNotEmpty) {
      milestones.add(
        GuideActionItem(
          id: 'questionnaire_timeline_defined',
          title: _t(
            localeCode,
            pt: 'Sua janela de mudança já está mapeada',
            es: 'Tu ventana de mudanza ya esta mapeada',
            en: 'Your move timeline is already mapped',
          ),
          shortDescription: _timelineSummary(plan.timeline, localeCode),
          type: GuideActionType.informative,
          phase: GuidePhase.preparation,
          orderIndex: orderIndex++,
          isCompleted: true,
          tier: GuideItemTier.optional,
          isDismissible: false,
          badgeLabel: _t(
            localeCode,
            pt: 'Respondido no questionário',
            es: 'Respondido en el cuestionario',
            en: 'Answered in the questionnaire',
          ),
          context: _t(
            localeCode,
            pt: 'Esse contexto já ajusta a urgência real do plano.',
            es: 'Ese contexto ya ajusta la urgencia real del plan.',
            en: 'That context already adjusts the real urgency of the plan.',
          ),
        ),
      );
    }

    final selectedCity = plan.currentPlanCity;
    if (selectedCity != null) {
      milestones.add(
        GuideActionItem(
          id: 'questionnaire_city_selected',
          title: _t(
            localeCode,
            pt: plan.isCityConfirmed
                ? 'Sua cidade já está confirmada'
                : 'Você já tem uma cidade-alvo',
            es: plan.isCityConfirmed
                ? 'Tu ciudad ya esta confirmada'
                : 'Ya tienes una ciudad objetivo',
            en: plan.isCityConfirmed
                ? 'Your city is already confirmed'
                : 'You already have a target city',
          ),
          shortDescription: selectedCity.name,
          type: GuideActionType.informative,
          phase: GuidePhase.preparation,
          orderIndex: orderIndex++,
          isCompleted: true,
          tier: GuideItemTier.optional,
          isDismissible: false,
          badgeLabel: _t(
            localeCode,
            pt: 'Respondido no questionário',
            es: 'Respondido en el cuestionario',
            en: 'Answered in the questionnaire',
          ),
          context: _t(
            localeCode,
            pt: 'Isso reduz bastante a incerteza das próximas decisões de moradia, custo e chegada.',
            es: 'Eso reduce bastante la incertidumbre de las proximas decisiones de vivienda, costo y llegada.',
            en: 'This already reduces a lot of uncertainty around housing, cost, and arrival decisions.',
          ),
        ),
      );
    }

    return milestones;
  }

  static bool _isApplicable(
    List<String> applicabilityConditions,
    Set<String> activeConditions,
  ) {
    return applicabilityConditions.any(activeConditions.contains);
  }

  static List<String> _legacyApplicabilityConditions(String itemId) {
    if (itemId == 'item_2_3_ctps' || itemId == 'carteira_trabalho') {
      return const <String>['formal_work_goal'];
    }
    if (itemId == 'item_3_4_trabalho') {
      return const <String>['income_strategy_goal'];
    }
    if (itemId == 'item_4_4_mei') {
      return const <String>['self_employed_goal'];
    }
    return const <String>[];
  }

  static Set<String> _activeConditions(MigrationPlan plan) {
    final conditions = <String>{};
    final goal = plan.goal;
    final hasKids =
        plan.travelGroup == 'family_kids' ||
        plan.travelGroup == 'solo_parent' ||
        (plan.childrenCount ?? 0) > 0 ||
        plan.selectedConstraints.contains('children_school');

    if (goal == 'find_job_br') {
      conditions.add('job_search_goal');
    }
    if (goal == 'study') {
      conditions.add('study_goal');
    }
    if (goal == 'remote_income' ||
        goal == 'remote_work' ||
        goal == 'entrepreneur') {
      conditions.add('self_employed_goal');
      conditions.add('remote_income_goal');
    }
    if (goal == 'find_job_br' || goal == 'study') {
      conditions.add('formal_work_goal');
    }
    if (goal == 'find_job_br' ||
        goal == 'study' ||
        goal == 'remote_income' ||
        goal == 'remote_work' ||
        goal == 'entrepreneur') {
      conditions.add('income_strategy_goal');
    }
    if (hasKids) {
      conditions.add('family_with_kids');
    }
    if (plan.selectedConstraints.contains('travel_with_pet')) {
      conditions.add('traveling_with_pet');
    }
    if (plan.selectedConstraints.contains('continuous_medication')) {
      conditions.add('continuous_medication');
    }
    if (plan.selectedConstraints.contains('foreign_income') ||
        goal == 'remote_income' ||
        goal == 'remote_work') {
      conditions.add('foreign_income');
    }
    if (plan.travelGroup == 'partner' ||
        plan.travelGroup == 'family_kids' ||
        plan.travelGroup == 'solo_parent' ||
        goal == 'family_partner') {
      conditions.add('family_or_partner_move');
    }
    if (plan.currentPlanCity != null || plan.isCityConfirmed) {
      conditions.add('city_selected');
    }
    if (plan.isCityConfirmed) {
      conditions.add('city_confirmed');
    }
    if (plan.timeline == 'in_0_3m' || plan.timeline == 'in_3_6m') {
      conditions.add('near_term_move');
    }
    if (plan.timeline == 'in_6_12m' ||
        plan.timeline == 'in_12m_plus' ||
        plan.timeline == 'just_exploring' ||
        plan.timeline == 'depends') {
      conditions.add('long_horizon_move');
    }

    return conditions;
  }

  static GuideItemTier? _inferTier(GuideActionItem item) {
    if (item.tier != null) {
      return item.tier;
    }
    if (item.preArrivalRequired ||
        item.urgencyLevel == GuideUrgencyLevel.critical) {
      return GuideItemTier.critical;
    }
    if (item.urgencyLevel == GuideUrgencyLevel.urgent ||
        item.urgencyLevel == GuideUrgencyLevel.watch) {
      return GuideItemTier.recommended;
    }
    return null;
  }

  static bool _isSurveyMilestone(String itemId) {
    return itemId.startsWith('questionnaire_');
  }

  static String _goalSummary(String goal, String localeCode) {
    return switch (goal) {
      'find_job_br' => _t(
        localeCode,
        pt: 'Objetivo: encontrar trabalho no Brasil.',
        es: 'Objetivo: encontrar trabajo en Brasil.',
        en: 'Goal: find a job in Brazil.',
      ),
      'remote_income' || 'remote_work' => _t(
        localeCode,
        pt: 'Objetivo: manter renda remota ao mudar.',
        es: 'Objetivo: mantener ingreso remoto al mudarte.',
        en: 'Goal: keep remote income while moving.',
      ),
      'study' => _t(
        localeCode,
        pt: 'Objetivo: estudar e estruturar a chegada em torno disso.',
        es: 'Objetivo: estudiar y estructurar la llegada alrededor de eso.',
        en: 'Goal: study and structure the move around that.',
      ),
      'family_partner' => _t(
        localeCode,
        pt: 'Objetivo: reorganizar a mudança por vínculo familiar.',
        es: 'Objetivo: reorganizar la mudanza por vinculo familiar.',
        en: 'Goal: organize the move around a family connection.',
      ),
      'fresh_start' => _t(
        localeCode,
        pt: 'Objetivo: construir uma nova base de vida no Brasil.',
        es: 'Objetivo: construir una nueva base de vida en Brasil.',
        en: 'Goal: build a new life base in Brazil.',
      ),
      _ => _t(
        localeCode,
        pt: 'Objetivo de mudança respondido.',
        es: 'Objetivo de mudanza respondido.',
        en: 'Migration goal answered.',
      ),
    };
  }

  static String _timelineSummary(String timeline, String localeCode) {
    return switch (timeline) {
      'in_0_3m' => _t(
        localeCode,
        pt: 'Prazo: mudança prevista para os próximos 3 meses.',
        es: 'Plazo: mudanza prevista para los proximos 3 meses.',
        en: 'Timeline: move planned for the next 3 months.',
      ),
      'in_3_6m' => _t(
        localeCode,
        pt: 'Prazo: mudança prevista para 3 a 6 meses.',
        es: 'Plazo: mudanza prevista para 3 a 6 meses.',
        en: 'Timeline: move planned for 3 to 6 months.',
      ),
      'in_6_12m' => _t(
        localeCode,
        pt: 'Prazo: mudança prevista para 6 a 12 meses.',
        es: 'Plazo: mudanza prevista para 6 a 12 meses.',
        en: 'Timeline: move planned for 6 to 12 months.',
      ),
      'in_12m_plus' => _t(
        localeCode,
        pt: 'Prazo: mudança no longo prazo.',
        es: 'Plazo: mudanza a largo plazo.',
        en: 'Timeline: long-term move.',
      ),
      'just_exploring' || 'depends' => _t(
        localeCode,
        pt: 'Prazo: você já sinalizou que ainda está calibrando o momento certo.',
        es: 'Plazo: ya indicaste que todavia estas calibrando el momento correcto.',
        en: 'Timeline: you already signaled that the timing is still being calibrated.',
      ),
      _ => _t(
        localeCode,
        pt: 'Prazo da mudança respondido.',
        es: 'Plazo de la mudanza respondido.',
        en: 'Move timeline answered.',
      ),
    };
  }

  static String _t(
    String localeCode, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (localeCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}

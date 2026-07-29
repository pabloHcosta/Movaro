import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_personalization_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_focus_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/models/guide_task_presentation_policy.dart';

void main() {
  group('ArgentinaBrazilGuideDatasource safety review', () {
    test('builds the reviewed journey in a stable order', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'find_job_br'),
        localeCode: 'pt',
      );

      expect(
        items.map((item) => item.orderIndex),
        orderedEquals(List<int>.generate(items.length, (index) => index)),
      );
      expect(
        items.map((item) => item.id),
        containsAll(<String>[
          'item_0_2_document_folder',
          'item_1_0_entry_proof',
          'item_2_1_govbr',
          'item_3_4_work_rights',
          'item_3_4_formal_work_ready',
          'item_0_7_family_documents',
        ]),
      );
    });

    test('starts every task with at most one expanded working section', () {
      for (final item in ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'find_job_br'),
        localeCode: 'pt',
      )) {
        final policy = GuideTaskPresentationPolicy.fromItem(
          item,
          deferChecklist: false,
        );
        final expandedCount = GuideTaskSectionKind.values
            .where(policy.startsExpanded)
            .length;

        expect(
          expandedCount,
          lessThanOrEqualTo(1),
          reason: '${item.id} exposes too many competing sections',
        );
      }
    });

    test('uses CPF and Gov.br instead of residence as the CTPS dependency', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'find_job_br'),
        localeCode: 'pt',
      );
      final ctps = _item(items, 'item_2_3_ctps');

      expect(ctps.dependencies, <String>['item_2_1_govbr']);
      expect(ctps.context, contains('emitida automaticamente'));
      expect(
        ctps.requirements,
        containsAll(<String>['CPF regular', 'Conta Gov.br']),
      );
    });

    test('makes safe initial housing a critical pre-arrival milestone', () {
      final housing = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'quality_of_life'),
          localeCode: 'pt',
        ),
        'item_1_2_housing_temporary',
      );

      expect(housing.tier, GuideItemTier.critical);
      expect(housing.preArrivalRequired, isTrue);
      expect(housing.blockingReason, contains('hospedagem inicial segura'));
    });

    test('separates job preparation from permission to start formal work', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'find_job_br'),
        localeCode: 'pt',
      );
      final research = _item(items, 'item_0_5_mercado_trabalho');
      final formalWork = _item(items, 'item_3_4_formal_work_ready');

      expect(research.dependencies, isEmpty);
      expect(research.preArrivalRequired, isTrue);
      expect(
        formalWork.dependencies,
        containsAll(<String>['item_2_1_cpf', 'item_2_2_residencia']),
      );
      expect(formalWork.tier, GuideItemTier.critical);
    });

    test('exposes the complete residence document categories', () {
      final residence = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'quality_of_life'),
          localeCode: 'pt',
        ),
        'item_2_2_residencia',
      );
      final requirements = residence.requirements!.join(' ');

      expect(requirements, contains('cinco anos'));
      expect(requirements, contains('filiação'));
      expect(requirements, contains('Comprovante de ingresso'));
      expect(requirements, contains('Declaração pessoal'));
    });

    test('removes unsafe salary, health, tax, and rental claims', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'remote_work'),
        localeCode: 'pt',
      );
      final allReviewedText = items
          .expand(
            (item) => <String>[
              item.title,
              item.shortDescription,
              item.context ?? '',
              item.whyItMatters ?? '',
              ...?item.steps,
              ...?item.tips,
              ...?item.communityTips,
              ...?item.warningFlags,
            ],
          )
          .join(' ');

      expect(allReviewedText, isNot(contains('o líquido é o valor anunciado')));
      expect(allReviewedText, isNot(contains('MEI simplifica')));
      expect(allReviewedText, isNot(contains('R\$150–400')));
      expect(allReviewedText, isNot(contains('traduzir com IA')));
      expect(allReviewedText, isNot(contains('30-50%')));
      expect(allReviewedText, isNot(contains('causa mais comum de crise')));
      expect(
        allReviewedText,
        isNot(contains('não consegue CPF no primeiro dia')),
      );

      final rent = _item(items, 'item_3_2_aluguel_fixo');
      expect(
        rent.warningFlags,
        contains(contains('proíbe mais de uma modalidade de garantia')),
      );
    });

    test('covers traveler vaccines and initial travel assistance', () {
      final health = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'quality_of_life'),
          localeCode: 'pt',
        ),
        'item_0_6_saude_entender',
      );
      final steps = health.steps?.join(' ') ?? '';
      final supportUrls =
          health.supportLinks?.map((link) => link.url).toList() ?? const [];

      expect(steps, contains('carteira de vacinação'));
      expect(steps, contains('seguro de viagem'));
      expect(
        supportUrls,
        contains(PreparationResourceLinks.travelerVaccinationGuide.toString()),
      );
      expect(
        supportUrls,
        contains(
          PreparationResourceLinks.argentinaBrazilTravelRecommendations
              .toString(),
        ),
      );
    });

    test('uses current official jobs and foreign-driving sources', () {
      expect(
        PreparationResourceLinks.officialJobsPortal,
        Uri.parse('https://empregabrasil.trabalho.gov.br/'),
      );

      final cnh = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'quality_of_life'),
          localeCode: 'pt',
        ),
        'item_4_1_cnh',
      );
      expect(cnh.evidence?.sourceLabel, contains('1.020/2025'));
      expect(cnh.steps?.join(' '), contains('PID quando aplicável'));
      expect(cnh.steps?.join(' '), contains('180 dias'));
    });

    test('job-market research opens vacancy sources, never the CTPS page', () {
      final research = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'find_job_br'),
          localeCode: 'pt',
        ),
        'item_0_5_mercado_trabalho',
      );
      final links = <String>[
        research.primaryActionTarget ?? '',
        ...?research.externalOfficialLinks?.map((link) => link.url),
      ];

      expect(
        research.primaryActionTarget,
        PreparationResourceLinks.officialJobsPortal.toString(),
      );
      expect(
        PreparationResourceLinks.vagasJobsPortal,
        Uri.parse('https://www.vagas.com.br/'),
      );
      expect(links.join(' '), isNot(contains('carteira-de-trabalho')));
      expect(
        research.steps?.join(' '),
        isNot(contains('Carteira de Trabalho')),
      );
    });

    test('income strategy offers the three routes instead of opening CTPS', () {
      final strategy = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'find_job_br'),
          localeCode: 'pt',
        ),
        'item_3_4_trabalho',
      );
      final links =
          strategy.externalOfficialLinks?.map((link) => link.url).toList() ??
          const <String>[];

      expect(strategy.primaryActionTarget, isNull);
      expect(links, hasLength(3));
      expect(
        links,
        contains(PreparationResourceLinks.officialJobsPortal.toString()),
      );
      expect(links, contains(PreparationResourceLinks.meiGuide.toString()));
      expect(
        links,
        contains(PreparationResourceLinks.foreignIncomeTaxGuide.toString()),
      );
      expect(links.join(' '), isNot(contains('carteira-de-trabalho')));
    });

    test('supports Pix payments before a Brazilian bank account', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'quality_of_life'),
        localeCode: 'pt',
      );
      final money = _item(items, 'item_1_3_money');
      final pix = _item(items, 'item_3_3_pix');
      final allReviewedText = items
          .expand(
            (item) => <String>[
              item.shortDescription,
              item.context ?? '',
              ...?item.steps,
              ...?item.warningFlags,
            ],
          )
          .join(' ');

      expect(
        allReviewedText,
        isNot(contains('ainda não terá conta bancária nem Pix')),
      );
      expect(money.context, contains('não cria uma conta'));
      expect(
        money.supportLinks?.map((link) => Uri.parse(link.url).host),
        containsAll(<String>[
          'www.mercadolibre.com.ar',
          'www.prexcard.com.ar',
          'help.belo.app',
        ]),
      );
      expect(pix.phase, GuidePhase.preparation);
      expect(pix.dependencies, <String>['item_1_3_money']);
      expect(pix.context, contains('duas rotas diferentes'));
      expect(pix.steps?.join(' '), contains('QR'));
      expect(pix.warningFlags?.join(' '), contains('não cria uma conta'));
      expect(
        items.indexWhere((item) => item.id == 'item_3_3_pix'),
        lessThan(
          items.indexWhere((item) => item.id == 'item_3_1_conta_bancaria'),
        ),
      );
    });

    test('schedules actions by real execution moment', () {
      final items = ArgentinaBrazilGuideDataSource.build(
        _plan(goal: 'find_job_br'),
        localeCode: 'pt',
      );

      expect(
        _item(items, 'item_4_7_seguranca_emergencia').resolvedExecutionWindow,
        GuideExecutionWindow.arrivalDay,
      );
      expect(
        _item(items, 'item_1_0_entry_proof').resolvedExecutionWindow,
        GuideExecutionWindow.arrivalDay,
      );
      expect(
        _item(items, 'item_1_1_chip').resolvedExecutionWindow,
        GuideExecutionWindow.arrivalDay,
      );
      expect(
        _item(items, 'item_4_2_saude').resolvedExecutionWindow,
        GuideExecutionWindow.firstWeek,
      );
      expect(
        _item(items, 'item_3_4_formal_work_ready').resolvedExecutionWindow,
        GuideExecutionWindow.firstWeek,
      );
      expect(
        _item(items, 'item_3_2_aluguel_fixo').resolvedExecutionWindow,
        GuideExecutionWindow.firstMonth,
      );

      expect(
        items.indexWhere((item) => item.id == 'item_1_1_chip'),
        lessThan(
          items.indexWhere(
            (item) => item.id == 'item_4_7_seguranca_emergencia',
          ),
        ),
      );
      expect(
        items.indexWhere((item) => item.id == 'item_1_0_entry_proof'),
        lessThan(items.indexWhere((item) => item.id == 'item_1_1_chip')),
      );
      expect(
        items.indexWhere((item) => item.id == 'item_4_7_seguranca_emergencia'),
        lessThan(items.indexWhere((item) => item.id == 'item_4_2_saude')),
      );
      final emergency = _item(items, 'item_4_7_seguranca_emergencia');
      expect(emergency.dependencies, <String>['item_1_1_chip']);
      expect(emergency.preArrivalRequired, isFalse);
    });

    test('guides SIM choice without unsupported carrier rankings', () {
      final sim = _item(
        ArgentinaBrazilGuideDataSource.build(
          _plan(goal: 'find_job_br'),
          localeCode: 'pt',
        ),
        'item_1_1_chip',
      );
      final reviewedText = <String>[
        ...?sim.steps,
        ...?sim.tips,
        for (final option in sim.decisionOptions ?? const [])
          '${option.description} ${option.pros.join(' ')} ${option.cons.join(' ')}',
      ].join(' ');

      expect(reviewedText, contains('identidade de país do Mercosul'));
      expect(reviewedText, contains('Não use o CPF de outra pessoa'));
      expect(reviewedText, isNot(contains('Melhor cobertura')));
      expect(reviewedText, isNot(contains('mais econômica')));
      expect(sim.costInfo, isNot(contains('R\$ 20-50')));
      expect(sim.dependencies, contains('item_1_0_entry_proof'));
      expect(sim.primaryActionTarget, isNull);
      expect(
        sim.supportLinks?.map((link) => link.url),
        containsAll(<String>[
          PreparationResourceLinks.anatelMobileCoverage.toString(),
          PreparationResourceLinks.anatelPrepaidRegistration.toString(),
          PreparationResourceLinks.timForeignVisitors.toString(),
        ]),
      );
      expect(
        sim.externalOfficialLinks?.map((link) => link.url),
        containsAll(<String>[
          PreparationResourceLinks.claroPrepaidPlans.toString(),
          PreparationResourceLinks.vivoPrepaidPlans.toString(),
          PreparationResourceLinks.timPrepaidPlans.toString(),
          PreparationResourceLinks.timForeignVisitors.toString(),
          PreparationResourceLinks.anatelMobileCoverage.toString(),
          PreparationResourceLinks.anatelPrepaidRegistration.toString(),
        ]),
      );
    });

    test(
      'transitions from arrival proof to SIM, emergency contacts and SUS',
      () {
        final plan = _plan(goal: 'find_job_br');
        final personalized = GuidePersonalizationService.personalize(
          plan: plan,
          items: ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt'),
          explicitCompletedIds: const <String>{},
          explicitDismissedReasons: const <String, GuideDismissReason>{},
        );
        var state = personalized
            .map(
              (item) =>
                  item.resolvedExecutionWindow ==
                      GuideExecutionWindow.beforeTravel
                  ? item.copyWith(isCompleted: true)
                  : item,
            )
            .toList();

        expect(
          GuideFocusEngine.build(plan: plan, items: state).current?.id,
          'item_1_0_entry_proof',
        );

        state = state
            .map(
              (item) => item.id == 'item_1_0_entry_proof'
                  ? item.copyWith(isCompleted: true)
                  : item,
            )
            .toList();
        expect(
          GuideFocusEngine.build(plan: plan, items: state).current?.id,
          'item_1_1_chip',
        );

        state = state
            .map(
              (item) => item.id == 'item_1_1_chip'
                  ? item.copyWith(isCompleted: true)
                  : item,
            )
            .toList();
        expect(
          GuideFocusEngine.build(plan: plan, items: state).current?.id,
          'item_4_7_seguranca_emergencia',
        );

        state = state
            .map(
              (item) => item.id == 'item_4_7_seguranca_emergencia'
                  ? item.copyWith(isCompleted: true)
                  : item,
            )
            .toList();
        expect(
          GuideFocusEngine.build(plan: plan, items: state).current?.id,
          'item_4_2_saude',
        );
      },
    );
  });

  group('GuidePersonalizationService reviewed conditions', () {
    test('keeps formal-work steps active for the legacy work goal', () {
      final plan = _plan(goal: 'work');
      final items = ArgentinaBrazilGuideDataSource.build(
        plan,
        localeCode: 'pt',
      );
      final personalized = GuidePersonalizationService.personalize(
        plan: plan,
        items: items,
        explicitCompletedIds: const <String>{},
        explicitDismissedReasons: const <String, GuideDismissReason>{},
      );

      expect(_item(personalized, 'item_2_3_ctps').dismissReason, isNull);
      expect(
        _item(personalized, 'item_3_4_formal_work_ready').dismissReason,
        isNull,
      );
      expect(
        _item(personalized, 'item_4_3_permanencia').dismissReason,
        GuideDismissReason.notApplicable,
      );
    });

    test('does not force the formal-work route into every study plan', () {
      final plan = _plan(goal: 'study');
      final personalized = GuidePersonalizationService.personalize(
        plan: plan,
        items: ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt'),
        explicitCompletedIds: const <String>{},
        explicitDismissedReasons: const <String, GuideDismissReason>{},
      );

      expect(
        _item(personalized, 'item_3_4_formal_work_ready').dismissReason,
        GuideDismissReason.notApplicable,
      );
    });

    test(
      'keeps primary progress compact while covering arrival essentials',
      () {
        for (final plan in <MigrationPlan>[
          _plan(goal: 'find_job_br'),
          _plan(
            goal: 'quality_of_life',
            travelGroup: 'family_kids',
            childrenCount: 1,
          ),
          _plan(goal: 'study'),
        ]) {
          final personalized = GuidePersonalizationService.personalize(
            plan: plan,
            items: ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt'),
            explicitCompletedIds: const <String>{},
            explicitDismissedReasons: const <String, GuideDismissReason>{},
          );
          final focus = GuideFocusEngine.build(plan: plan, items: personalized);

          expect(focus.coreTotalCount, inInclusiveRange(11, 15));
        }
      },
    );

    test('starts every profile with pre-travel foundations', () {
      final scenarios = <MigrationPlan>[
        _plan(goal: 'find_job_br'),
        _plan(goal: 'study'),
        _plan(
          goal: 'quality_of_life',
          travelGroup: 'family_kids',
          childrenCount: 1,
        ),
      ];

      for (final plan in scenarios) {
        final personalized = GuidePersonalizationService.personalize(
          plan: plan,
          items: ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt'),
          explicitCompletedIds: const <String>{},
          explicitDismissedReasons: const <String, GuideDismissReason>{},
        );
        final focus = GuideFocusEngine.build(plan: plan, items: personalized);

        expect(
          focus.now.map((item) => item.id),
          orderedEquals(<String>[
            'item_0_1_rule_90_days',
            'item_0_2_document_folder',
            'item_0_6_saude_entender',
          ]),
        );
        expect(
          focus.now.map((item) => item.id),
          isNot(contains('item_4_7_seguranca_emergencia')),
        );
      }
    });

    test('activates family document steps only for families with children', () {
      final soloPlan = _plan(goal: 'quality_of_life');
      final familyPlan = _plan(
        goal: 'quality_of_life',
        travelGroup: 'family_kids',
        childrenCount: 1,
      );

      final soloItems = GuidePersonalizationService.personalize(
        plan: soloPlan,
        items: ArgentinaBrazilGuideDataSource.build(soloPlan, localeCode: 'pt'),
        explicitCompletedIds: const <String>{},
        explicitDismissedReasons: const <String, GuideDismissReason>{},
      );
      final familyItems = GuidePersonalizationService.personalize(
        plan: familyPlan,
        items: ArgentinaBrazilGuideDataSource.build(
          familyPlan,
          localeCode: 'pt',
        ),
        explicitCompletedIds: const <String>{},
        explicitDismissedReasons: const <String, GuideDismissReason>{},
      );

      expect(
        _item(soloItems, 'item_0_7_family_documents').dismissReason,
        GuideDismissReason.notApplicable,
      );
      expect(
        _item(familyItems, 'item_0_7_family_documents').dismissReason,
        isNull,
      );
    });
  });
}

MigrationPlan _plan({
  required String goal,
  String travelGroup = 'solo',
  int? childrenCount,
}) {
  return MigrationPlan(
    originCountry: 'Argentina',
    destinationCountry: 'Brasil',
    goal: goal,
    timeline: 'in_3_6m',
    steps: const [],
    travelGroup: travelGroup,
    childrenCount: childrenCount,
  );
}

GuideActionItem _item(List<GuideActionItem> items, String id) {
  return items.firstWhere((item) => item.id == id);
}

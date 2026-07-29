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

      final rent = _item(items, 'item_3_2_aluguel_fixo');
      expect(
        rent.warningFlags,
        contains(contains('proíbe mais de uma modalidade de garantia')),
      );
    });

    test('uses current official jobs and foreign-driving sources', () {
      expect(PreparationResourceLinks.officialJobsPortal.host, 'www.gov.br');

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

    test('keeps primary progress between 9 and 12 personalized milestones', () {
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

        expect(focus.coreTotalCount, inInclusiveRange(9, 12));
      }
    });

    test('changes the top focus set for work, study, and family profiles', () {
      final scenarios = <(MigrationPlan, String)>[
        (_plan(goal: 'find_job_br'), 'item_0_5_mercado_trabalho'),
        (_plan(goal: 'study'), 'item_0_7_ingresso_ensino_superior'),
        (
          _plan(
            goal: 'quality_of_life',
            travelGroup: 'family_kids',
            childrenCount: 1,
          ),
          'item_0_7_family_documents',
        ),
      ];

      for (final (plan, expectedFirstId) in scenarios) {
        final personalized = GuidePersonalizationService.personalize(
          plan: plan,
          items: ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt'),
          explicitCompletedIds: const <String>{},
          explicitDismissedReasons: const <String, GuideDismissReason>{},
        );
        final focus = GuideFocusEngine.build(plan: plan, items: personalized);

        expect(focus.now.map((item) => item.id), contains(expectedFirstId));
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

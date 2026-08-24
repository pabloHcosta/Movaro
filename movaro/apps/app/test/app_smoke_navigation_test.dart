import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/bootstrap/app_dependencies.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/theme/theme_controller.dart';
import 'package:movaro_app/core/exchange_rates/exchange_rates_controller.dart';
import 'package:movaro_app/features/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/core/environment/api_source.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/info/domain/entities/quick_guide_answer.dart';
import 'package:movaro_app/features/info/domain/entities/guide_toolkit.dart';
import 'package:movaro_app/features/info/presentation/pages/guide_toolkit_page.dart';
import 'package:movaro_app/features/info/presentation/pages/quick_guide_answer_page.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/auth/data/datasources/fake_auth_data_source.dart';
import 'package:movaro_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/city_insights/domain/repositories/city_insight_repository.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/datasources/copilot_exchange_rates_remote_data_source.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/question_repository_impl.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _AppTestHarness harness;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    harness = await _AppTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets(
    'public home supports no-journey entry and cities remain accessible',
    (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        harness.buildApp(initialRoute: AppRoutes.publicHome),
      );
      await _pumpScreen(tester);

      expect(find.text('Plano'), findsOneWidget);
      expect(find.text('Ajuda'), findsOneWidget);
      expect(find.text('Mais'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('home-action-discover')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('home-action-known-city')),
        findsOneWidget,
      );
      expect(find.text('Resolver uma dúvida agora'), findsOneWidget);

      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.cities));
      await _pumpScreen(tester);

      expect(find.byType(TextField), findsWidgets);

      await tester.enterText(find.byType(TextField).first, 'Curitiba');
      await tester.pump(const Duration(milliseconds: 350));
      await _pumpScreen(tester);

      expect(find.text('Curitiba'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('help navigation is clear and localized in supported languages', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.byIcon(Icons.help_center_outlined), findsOneWidget);

    harness.localeController.setLocale(const Locale('es'));
    await _pumpScreen(tester);
    expect(find.text('Ayuda'), findsOneWidget);

    harness.localeController.setLocale(const Locale('en'));
    await _pumpScreen(tester);
    expect(find.text('Help'), findsOneWidget);
  });

  testWidgets('public home discover action confirms the origin city first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final discoverAction = find.byKey(const ValueKey('home-action-discover'));
    await tester.ensureVisible(discoverAction);
    await tester.tap(discoverAction);
    await _pumpScreen(tester);

    expect(find.text('Encontramos sua cidade'), findsOneWidget);
    expect(find.text('San Rafael'), findsOneWidget);
    expect(find.text('Sim, esta é minha cidade'), findsOneWidget);
    expect(find.text('Quero escolher outra'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('primary navigation stays stable without a plan', (tester) async {
    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    await tester.tap(find.text('Plano'));
    await _pumpScreen(tester);
    expect(
      find.text('Transforme uma cidade em um caminho claro'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ajuda'));
    await _pumpScreen(tester);
    expect(find.text('O que você precisa resolver?'), findsOneWidget);

    await tester.tap(find.text('Mais'));
    await _pumpScreen(tester);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Cidades favoritas'), findsOneWidget);

    await tester.tap(find.text('Configurações'));
    await _pumpScreen(tester);
    expect(find.text('Experiência do app'), findsOneWidget);
  });

  testWidgets('guide hero remains usable with 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.tools));
    await _pumpScreen(tester);

    expect(find.text('O que você precisa resolver?'), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-question-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-question-submit')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('guide-question-field')),
      'aluguel sem fiador',
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('guide-question-results')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('guide-question-suggestion-housing.guarantees'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('free text only filters reviewed questions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.tools));
    await _pumpScreen(tester);

    final field = find.byKey(const ValueKey('guide-question-field'));
    await tester.enterText(field, 'uma pergunta sem cobertura xyzzy');
    await tester.pump();

    expect(find.byKey(const ValueKey('guide-question-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-question-submit')), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('O que você precisa resolver?'), findsOneWidget);
    expect(field, findsOneWidget);

    await tester.enterText(field, 'matricula escola');
    await tester.pump();
    final reviewedQuestion = find.byKey(
      const ValueKey('guide-question-suggestion-education.school'),
    );
    expect(reviewedQuestion, findsOneWidget);

    await tester.tap(reviewedQuestion);
    await _pumpScreen(tester);
    expect(find.byKey(const ValueKey('guide-question-field')), findsNothing);
  });

  testWidgets('recent questions stay compact until the user expands them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({
      'quick_guide_recent_questions_v1': [
        'Pergunta recente 1',
        'Pergunta recente 2',
        'Pergunta recente 3',
        'Pergunta recente 4',
        'Pergunta recente 5',
      ],
    });

    await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.tools));
    await _pumpScreen(tester);

    expect(find.text('Pergunta recente 1'), findsOneWidget);
    expect(find.text('Pergunta recente 2'), findsNothing);
    expect(find.text('Pergunta recente 3'), findsNothing);
    expect(find.text('Ver todas (5)'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver todas (5)'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Ver todas (5)'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pergunta recente 5'), findsOneWidget);
    expect(find.text('Mostrar menos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile help groups stay progressive at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.tools));
    await _pumpScreen(tester);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Resolver um problema agora'),
      280,
      scrollable: scrollable,
    );
    expect(find.text('Resolver um problema agora'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Preparar a mudança'),
      280,
      scrollable: scrollable,
    );
    expect(find.text('Preparar a mudança'), findsOneWidget);
    expect(find.text('Entender a compra do voo'), findsNothing);

    final showPreparation = find.ancestor(
      of: find.text('Ver todos os preparativos'),
      matching: find.byType(OutlinedButton),
    );
    await tester.scrollUntilVisible(
      showPreparation,
      280,
      scrollable: scrollable,
    );
    await tester.tap(showPreparation);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('Entender a compra do voo'),
      280,
      scrollable: scrollable,
    );
    expect(find.text('Entender a compra do voo'), findsOneWidget);
    expect(find.text('Levar pets, bagagem e bens'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Saúde, direitos e futuro'),
      280,
      scrollable: scrollable,
    );
    expect(find.text('Saúde, direitos e futuro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guide answer exposes trust, context, sources and feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    const answer = QuickGuideAnswer(
      entryId: 'education-test',
      topic: 'education',
      question: 'Como funciona a escola?',
      answer: 'Procure a rede de ensino responsável pelo seu endereço.',
      coverage: QuickGuideCoverage.conditional,
      coverageReason:
          'A aplicação depende de detalhes da rede de ensino local.',
      expiresAt: '2027-02-18',
      trust: QuickGuideTrust(
        reason: 'A aplicação depende de detalhes da rede de ensino local.',
        evidenceCoverage: 1,
        freshness: QuickGuideFreshness.current,
      ),
      reviewedAt: '2026-08-18',
      context: QuickGuideContext(
        originCountry: 'argentina',
        destinationCountry: 'brasil',
      ),
      actions: [],
      caveats: ['Confirme os documentos solicitados pela rede local.'],
      claims: [
        QuickGuideClaim(
          id: 'education-network',
          text: 'Procure a rede de ensino responsável pelo seu endereço.',
          evidenceIds: ['mec-basic-education'],
          status: QuickGuideClaimStatus.conditional,
        ),
      ],
      followUpQuestion: QuickGuideFollowUpQuestion(
        id: 'education-level',
        contextKey: 'educationLevel',
        prompt: 'Você quer escola ou universidade?',
        options: [
          QuickGuideFollowUpOption(value: 'basic', label: 'Escola'),
          QuickGuideFollowUpOption(value: 'university', label: 'Universidade'),
        ],
      ),
      decisionTitle: 'Caminho recomendado',
      steps: [
        QuickGuideStep(id: 'education-1', label: 'Confirme a rede local.'),
      ],
      nextSteps: ['Peça a lista atual de documentos.'],
      fallbackPath: ['Peça a orientação da rede por escrito.'],
      recovery: QuickGuideRecovery(
        reason: 'partial_coverage',
        message: 'Use uma pergunta revisada para continuar com segurança.',
        suggestions: [
          QuickGuideRecoverySuggestion(
            id: 'education-school',
            topic: 'education',
            question: 'Como matriculo meu filho na escola pública?',
          ),
        ],
      ),
      sources: [
        QuickGuideSource(
          id: 'mec-basic-education',
          title: 'Educação básica',
          publisher: 'Ministério da Educação',
          url: 'https://www.gov.br/mec/pt-br/assuntos/eb',
          checkedAt: '2026-08-18',
          validUntil: '2027-02-18',
          scope: 'Visão federal da educação básica.',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: QuickGuideAnswerPage(
          request: const QuickGuideAnswerRequest(
            question: 'Como funciona a escola?',
          ),
          environment: harness.environment,
          journeyContextController: harness.journeyContextController,
          citiesController: harness.citiesController,
          migrationQuestionnaireController:
              harness.migrationQuestionnaireController,
          initialAnswer: answer,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'initial answer layout');

    final answerScrollable = find
        .descendant(
          of: find.byKey(const Key('quick-guide-answer-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(find.text('Pode variar no seu caso'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Você quer escola ou universidade?'),
      260,
      scrollable: answerScrollable,
    );
    expect(tester.takeException(), isNull, reason: 'clarifier layout');
    expect(find.text('Universidade'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Confirme a rede local.'),
      260,
      scrollable: answerScrollable,
    );
    expect(tester.takeException(), isNull, reason: 'decision layout');
    expect(find.text('Caminho recomendado'), findsOneWidget);
    expect(find.text('O que fazer agora'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Peça a lista atual de documentos.'),
      260,
      scrollable: answerScrollable,
    );
    expect(tester.takeException(), isNull, reason: 'next steps layout');
    expect(find.byKey(const Key('quick-guide-answer-actions')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Se algo bloquear seu caminho'),
      260,
      scrollable: answerScrollable,
    );
    expect(tester.takeException(), isNull, reason: 'fallback layout');
    expect(find.text('Se algo bloquear seu caminho'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Local considerado'),
      260,
      scrollable: answerScrollable,
    );
    expect(tester.takeException(), isNull, reason: 'context layout');
    expect(find.text('Local considerado'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Como verificamos'),
      260,
      scrollable: answerScrollable,
    );
    expect(find.text('Como verificamos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Isso ajudou?'),
      260,
      scrollable: answerScrollable,
    );
    expect(find.text('Isso ajudou?'), findsOneWidget);
    await tester.ensureVisible(find.text('Não'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();
    expect(find.text('O que faltou?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('A ação não funcionou'),
      260,
      scrollable: answerScrollable,
    );
    expect(find.text('Não é meu caso'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Como matriculo meu filho na escola pública?'),
      -260,
      scrollable: answerScrollable,
    );
    await tester.ensureVisible(
      find.text('Como matriculo meu filho na escola pública?'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Como matriculo meu filho na escola pública?'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('guide answer keeps one visual skeleton across core topics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const topics = <(String, String)>[
      ('documents', 'Documentos'),
      ('education', 'Educação'),
      ('housing', 'Moradia e aluguel'),
      ('work', 'Trabalho'),
      ('money', 'Custos e dinheiro'),
      ('health', 'Saúde'),
    ];

    for (final topic in topics) {
      final answer = QuickGuideAnswer(
        entryId: 'visual-${topic.$1}',
        topic: topic.$1,
        question: 'Dúvida sobre ${topic.$2}',
        answer: 'Resposta revisada para este tema.',
        coverage: QuickGuideCoverage.confirmed,
        context: const QuickGuideContext(
          originCountry: 'argentina',
          destinationCountry: 'brasil',
        ),
        actions: const [],
        caveats: const [],
        sources: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('pt'),
          supportedLocales: AppLocalization.supportedLocales,
          localizationsDelegates: AppLocalization.localizationsDelegates,
          home: QuickGuideAnswerPage(
            key: ValueKey(topic.$1),
            request: QuickGuideAnswerRequest(question: answer.question),
            environment: harness.environment,
            journeyContextController: harness.journeyContextController,
            citiesController: harness.citiesController,
            migrationQuestionnaireController:
                harness.migrationQuestionnaireController,
            initialAnswer: answer,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('quick-guide-topic-identity')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('quick-guide-answer-hero')), findsOneWidget);
      expect(find.byKey(const Key('quick-guide-answer-context')), findsNothing);
      expect(find.text(topic.$2), findsOneWidget);
      expect(tester.takeException(), isNull, reason: topic.$1);
    }
  });

  testWidgets('offline answer prioritizes action over ineffective context', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const answer = QuickGuideAnswer(
      entryId: 'education-offline',
      topic: 'education',
      question: 'Como funciona a escola pública?',
      answer: 'Procure a rede responsável pelo endereço.',
      coverage: QuickGuideCoverage.partial,
      coverageReason: 'Sem verificação atual das fontes.',
      context: QuickGuideContext(
        originCountry: 'argentina',
        destinationCountry: 'brasil',
      ),
      actions: [],
      nextSteps: ['Identifique a rede responsável pelo endereço.'],
      fallbackPath: ['Peça a orientação por escrito.'],
      caveats: ['Conecte-se antes de tomar uma decisão importante.'],
      sources: [],
      offline: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: QuickGuideAnswerPage(
          request: const QuickGuideAnswerRequest(
            question: 'Como funciona a escola pública?',
          ),
          environment: harness.environment,
          journeyContextController: harness.journeyContextController,
          citiesController: harness.citiesController,
          migrationQuestionnaireController:
              harness.migrationQuestionnaireController,
          initialAnswer: answer,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Em resumo'), findsOneWidget);
    expect(find.text('O que fazer agora'), findsOneWidget);
    expect(find.byKey(const Key('quick-guide-answer-actions')), findsOneWidget);
    expect(find.byKey(const Key('quick-guide-answer-context')), findsNothing);
    expect(find.byKey(const Key('quick-guide-answer-sources')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stage three toolkit stays usable with accessibility text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: GuideToolkitPage(
          request: const GuideToolkitRequest(kind: GuideToolkitKind.work),
          journeyContextController: harness.journeyContextController,
          citiesController: harness.citiesController,
          migrationQuestionnaireController:
              harness.migrationQuestionnaireController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assistente de trabalho'), findsOneWidget);
    expect(
      find.text('Ferramenta independente · não altera o plano'),
      findsOneWidget,
    );
    final calculate = find.byKey(const Key('guide-toolkit-calculate'));
    final toolkitScrollable = find
        .descendant(
          of: find.byKey(const Key('guide-toolkit-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      calculate,
      280,
      scrollable: toolkitScrollable,
    );
    await tester.drag(toolkitScrollable, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(calculate);
    await tester.pumpAndSettle();
    expect(find.text('Seu caminho para trabalhar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('help topics stay isolated and render each concept once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<void> pumpSection(DocumentationGuideSection section) async {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(section),
          theme: AppTheme.light(),
          locale: const Locale('pt'),
          supportedLocales: AppLocalization.supportedLocales,
          localizationsDelegates: AppLocalization.localizationsDelegates,
          home: DocumentationTopicPage(
            section: section,
            exchangeRatesService: harness.copilotExchangeRatesService,
            preferredCurrencyCountryId: 'argentina',
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpSection(DocumentationGuideSection.documents);
    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.text('Só o CPF resolve banco e contrato?'), findsOneWidget);
    expect(find.text('Posso trabalhar só com visto de visita?'), findsNothing);
    expect(find.text('Estrangeiro pode usar o SUS?'), findsNothing);

    await pumpSection(DocumentationGuideSection.health);
    expect(find.text('SUS, posto de saúde e acesso público'), findsOneWidget);
    expect(find.text('Saúde privada'), findsOneWidget);

    await pumpSection(DocumentationGuideSection.work);
    expect(find.text('Carteira assinada'), findsOneWidget);
    expect(find.text('PJ, CNPJ e trabalho por conta própria'), findsOneWidget);
    expect(
      find.text('Mercado de trabalho e expectativa de renda'),
      findsOneWidget,
    );
    expect(find.text('Previdência pública e aposentadoria'), findsOneWidget);

    await pumpSection(DocumentationGuideSection.costs);
    expect(find.text('Calcular reserva de chegada'), findsOneWidget);
    expect(find.text('O que entra na reserva de chegada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('P1 health toolkit produces a safe reviewed care path', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: GuideToolkitPage(
          request: const GuideToolkitRequest(kind: GuideToolkitKind.health),
          journeyContextController: harness.journeyContextController,
          citiesController: harness.citiesController,
          migrationQuestionnaireController:
              harness.migrationQuestionnaireController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saúde contínua'), findsOneWidget);
    final toolkitScrollable = find
        .descendant(
          of: find.byKey(const Key('guide-toolkit-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    final continuousCare = find.text('Tratamento ou medicamento contínuo');
    await tester.drag(toolkitScrollable, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(continuousCare);
    final calculate = find.byKey(const Key('guide-toolkit-calculate'));
    await tester.scrollUntilVisible(
      calculate,
      280,
      scrollable: toolkitScrollable,
    );
    await tester.tap(calculate);
    await tester.pumpAndSettle();

    expect(find.text('Sua continuidade de cuidado'), findsOneWidget);
    await tester.fling(toolkitScrollable, const Offset(0, -2200), 3000);
    await tester.pumpAndSettle();
    final medicalNotice = find.textContaining('Não substitui avaliação médica');
    expect(medicalNotice, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public home known-city action confirms the origin city first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final knownCityAction = find.byKey(
      const ValueKey('home-action-known-city'),
    );
    await tester.ensureVisible(knownCityAction);
    await tester.tap(knownCityAction);
    await _pumpScreen(tester);

    expect(find.text('Encontramos sua cidade'), findsOneWidget);
    expect(find.text('San Rafael'), findsOneWidget);
    expect(find.text('Sim, esta é minha cidade'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('a confirmed origin city is reused without opening the sheet', (
    tester,
  ) async {
    harness.locationController.confirmedOriginCity = true;

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final discoverAction = find.byKey(const ValueKey('home-action-discover'));
    await tester.ensureVisible(discoverAction);
    await tester.tap(discoverAction);
    await _pumpScreen(tester);

    expect(find.text('Encontramos sua cidade'), findsNothing);
    expect(harness.locationController.confirmationChecks, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('city search resolves human-friendly aliases in autocomplete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.citiesSearch),
    );
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'poa');
    await tester.pump();
    await _pumpScreen(tester);

    expect(find.text('Porto Alegre'), findsWidgets);
    expect(find.textContaining('cidades encontradas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('comparison hero fits three cities on a mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    unawaited(
      navigator.pushNamed(
        AppRoutes.cityComparison,
        arguments: const [_curitiba, _portoAlegre, _salvador],
      ),
    );
    await _pumpScreen(tester);

    expect(find.text('Seu melhor encaixe, lado a lado'), findsOneWidget);
    expect(find.textContaining('MELHOR PARA O SEU PERFIL'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('copilot redirects to result reveal until city is confirmed', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.migrationPlanCopilot),
    );
    await _pumpScreen(tester);

    expect(find.text('Ver detalhes'), findsOneWidget);
    expect(find.text('Explorar alternativas'), findsOneWidget);
    expect(find.textContaining('Escolher'), findsOneWidget);
    expect(find.textContaining('e ver meu plano'), findsOneWidget);
    expect(find.textContaining('apareceu primeiro'), findsOneWidget);
    expect(find.text('Compare antes de decidir'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('result routes fall back to plan entry when no plan exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.migrationResultReveal),
    );
    await _pumpScreen(tester);

    expect(
      find.text('Transforme uma cidade em um caminho claro'),
      findsWidgets,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('confirmed city turns public home into execution home', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('Ver cidade'), findsOneWidget);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('help answers do not import or open a confirmed plan', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.tools));
    await _pumpScreen(tester);

    expect(
      find.text('Respostas e recursos sem entrar no plano'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Educação'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Educação')),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Educação'));
    await _pumpScreen(tester);

    expect(find.text('Resposta da Ajuda'), findsOneWidget);
    expect(
      find.text('Como matriculo meu filho na escola pública?'),
      findsWidgets,
    );
    expect(find.text(city.name), findsNothing);
    expect(find.text('Ver plano completo'), findsNothing);
    expect(find.textContaining('progresso do plano'), findsNothing);
  });

  testWidgets('copilot back falls back to public home when opened as root', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.migrationPlanCopilot),
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('Ver plano completo'), findsOneWidget);

    await tester.tap(
      find.byIcon(Icons.arrow_back_rounded).first,
      warnIfMissed: false,
    );
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('home lets the user cancel replacing the current plan', (
    tester,
  ) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
    await _pumpScreen(tester);
    await tester.tap(find.text('Novo plano'));
    await _pumpScreen(tester);

    expect(find.text('Começar um novo plano'), findsOneWidget);

    await tester.tap(find.text('Cancelar — manter Curitiba'));
    await _pumpScreen(tester);

    expect(find.text('Execução'), findsWidgets);
    expect(find.text('SUA JORNADA'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('home lets the user rebuild the current plan', (tester) async {
    await tester.runAsync(harness.generateLeanPlan);

    final city = harness
        .migrationQuestionnaireController
        .generatedPlan!
        .highlightedCity!;
    await tester.runAsync(
      () => harness.migrationQuestionnaireController.confirmPlanCity(city),
    );

    await tester.pumpWidget(
      harness.buildApp(initialRoute: AppRoutes.publicHome),
    );
    await _pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
    await _pumpScreen(tester);
    await tester.tap(find.text('Novo plano'));
    await _pumpScreen(tester);

    await tester.tap(find.text('Sim, começar do zero'));
    await _pumpScreen(tester);

    expect(find.byKey(const ValueKey('home-action-discover')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-action-known-city')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 600));
}

class _AppTestHarness {
  _AppTestHarness({required this.dependencies, required this.tempDirectory});

  final AppDependencies dependencies;
  final Directory tempDirectory;

  AppEnvironment get environment => dependencies.environment;
  AuthController get authController => dependencies.authController;
  CatalogRepositoryImpl get catalogRepository =>
      dependencies.catalogRepository as CatalogRepositoryImpl;
  CitiesController get citiesController => dependencies.citiesController;
  MigrationQuestionnaireController get migrationQuestionnaireController =>
      dependencies.migrationQuestionnaireController;
  CopilotExchangeRatesService get copilotExchangeRatesService =>
      dependencies.copilotExchangeRatesService;
  ApiHealthService get apiHealthService => dependencies.apiHealthService;
  JourneyContextController get journeyContextController =>
      dependencies.journeyContextController;
  _FakeLocationController get locationController =>
      dependencies.locationController as _FakeLocationController;
  LocaleController get localeController => dependencies.localeController;
  ThemeController get themeController => dependencies.themeController;

  static Future<_AppTestHarness> create({
    bool seedJourney = true,
    bool initializeQuestionnaire = true,
  }) async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'movaro_app_smoke',
    );
    final environment = AppEnvironment(
      flavor: AppFlavor.development,
      environmentName: 'test',
      apiSource: ApiSource.local,
      apiBaseUrl: 'http://127.0.0.1:3000',
      localApiBaseUrl: 'http://127.0.0.1:3000',
      railwayApiBaseUrl: 'https://movaro-production.up.railway.app',
      appName: 'Movaro Test',
    );
    final catalogRepository = CatalogRepositoryImpl(
      dataSource: SeedCatalogDataSource(),
    );
    final authController = AuthController(
      repository: AuthRepositoryImpl(
        dataSource: FakeAuthDataSource(environment: environment),
      ),
    );
    final journeyContextController = JourneyContextController(
      catalogRepository: catalogRepository,
      store: JourneyPreferencesStore(
        directoryProvider: () async => tempDirectory,
      ),
    );
    final locationController = _FakeLocationController(
      journeyContextController: journeyContextController,
    );
    const citiesRepository = _FakeCitiesRepository();
    final citiesController = _SmokeCitiesController(
      repository: citiesRepository,
    );
    final migrationQuestionnaireController = MigrationQuestionnaireController(
      questionRepository: QuestionRepositoryImpl(
        catalogRepository: catalogRepository,
        journeyContextController: journeyContextController,
      ),
      migrationPlanRepository: LocalMigrationPlanRepository(
        directoryProvider: () async => tempDirectory,
      ),
      planGenerator: MigrationPlanGenerator(citiesRepository: citiesRepository),
      journeyContextController: journeyContextController,
      flowDraftStore: _InMemoryQuestionnaireFlowDraftStore(),
    );
    final copilotExchangeRatesService = _FakeCopilotExchangeRatesService(
      environment: environment,
      store: CopilotExchangeRatesStore(
        directoryProvider: () async => tempDirectory,
      ),
    );
    final apiHealthService = ApiHealthService(environment: environment);
    final cityInsightsController = CityInsightController(
      repository: _FakeCityInsightRepository(),
    );
    final localeController = LocaleController();
    localeController.setLocale(const Locale('pt'));
    final themeController = ThemeController();
    final currencyController = CurrencyController();
    final exchangeRatesController = ExchangeRatesController(
      service: copilotExchangeRatesService,
    );
    final guideFlowMetricsStore = GuideFlowMetricsStore(
      preferences: await SharedPreferences.getInstance(),
    );
    await guideFlowMetricsStore.initialize();

    await journeyContextController.initialize();
    await journeyContextController.markIntroSeen();
    if (seedJourney) {
      await journeyContextController.completeJourney(
        originCountryId: 'argentina',
        destinationCountryId: 'brasil',
      );
    }
    await authController.initialize();
    if (initializeQuestionnaire) {
      await migrationQuestionnaireController.initialize();
    }

    return _AppTestHarness(
      dependencies: AppDependencies(
        environment: environment,
        authController: authController,
        catalogRepository: catalogRepository,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
        copilotExchangeRatesService: copilotExchangeRatesService,
        apiHealthService: apiHealthService,
        cityInsightsController: cityInsightsController,
        journeyContextController: journeyContextController,
        locationController: locationController,
        localeController: localeController,
        themeController: themeController,
        currencyController: currencyController,
        exchangeRatesController: exchangeRatesController,
        guideFlowMetricsStore: guideFlowMetricsStore,
      ),
      tempDirectory: tempDirectory,
    );
  }

  Widget buildApp({required String initialRoute}) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return LocaleScope(
          controller: localeController,
          child: MaterialApp(
            key: ValueKey(initialRoute),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.themeMode,
            locale: localeController.locale,
            supportedLocales: AppLocalization.supportedLocales,
            localizationsDelegates: AppLocalization.localizationsDelegates,
            onGenerateRoute: AppRouter(
              dependencies: dependencies,
            ).onGenerateRoute,
            initialRoute: initialRoute,
          ),
        );
      },
    );
  }

  Future<void> generateLeanPlan() async {
    migrationQuestionnaireController.selectVariant(QuestionnaireVariant.lean);
    migrationQuestionnaireController.selectAnswer('intent', 'remote_income');
    await migrationQuestionnaireController.goNext();
    migrationQuestionnaireController.selectAnswer('timeline', 'in_3_6m');
    await migrationQuestionnaireController.goNext();
    migrationQuestionnaireController.toggleAnswer('priorities', 'low_cost');
    migrationQuestionnaireController.toggleAnswer('priorities', 'safety');
    await migrationQuestionnaireController.goNext();
    await migrationQuestionnaireController.skipRefine();
  }

  Future<void> dispose() async {
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

class _FakeCitiesRepository implements CitiesRepository {
  const _FakeCitiesRepository();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<CityHighlights> getHighlights() async {
    return const CityHighlights(
      mostChosenByArgentinians: [_curitiba, _portoAlegre],
      easiestForSpanishSpeakers: [_portoAlegre, _curitiba],
      mostEconomical: [_curitiba, _salvador],
      bestForWork: [_curitiba, _portoAlegre],
    );
  }

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async {
    return _allCities;
  }

  @override
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  ) async {
    return CityRecommendationResult(
      methodologyVersion: 'city-recommendation-v2.0.0-test',
      generatedAt: '2026-07-29T12:00:00.000Z',
      catalogSize: _allCities.length,
      eligibleCityCount: _allCities.length,
      profileCompleteness: 0.8,
      dataCoverage: 0.8,
      appliedHardFilters: profile.constraints,
      unavailableDimensions: const [],
      warnings: const [],
      recommendations: _allCities.indexed
          .map(
            (entry) => RecommendedCity(
              city: entry.$2,
              score: 0.88 - entry.$1 * 0.08,
              dimensions: const {'affordability': 0.78, 'safety': 0.8},
              reasons: const ['plan_reason_budget_fit'],
              tradeoffs: const [],
              dataCoverage: 0.8,
              freshnessStatus: 'fresh',
              evidence: const [],
            ),
          )
          .toList(growable: false),
      sourceSummary: const [],
    );
  }

  @override
  Future<City> getCityById(String id) async {
    return _allCities.firstWhere((city) => city.id == id);
  }

  @override
  Future<CityMethodology> getMethodology() async {
    return const CityMethodology(
      principles: ['Dados oficiais', 'Pontuacao comparativa'],
      formulas: {'overall': 'weighted_index'},
      note: 'Test methodology note.',
    );
  }

  @override
  Future<List<City>> searchCities(String query) async {
    return _allCities
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<CityWeather> getCityWeather(String cityId) async {
    return const CityWeather(
      temperatureCelsius: 24,
      weatherCode: 1,
      isDay: true,
      windSpeedKmh: 11,
      fetchedAt: '2026-03-12T12:00:00Z',
    );
  }

  @override
  Future<TravelRouteInsight?> getCityTravelInsight(
    String cityId, {
    String? originIata,
    String? destIata,
  }) async => null;
}

class _SmokeCitiesController extends CitiesController {
  _SmokeCitiesController({required super.repository});

  @override
  Future<void> prefetchCatalog() async {}

  @override
  Future<void> prefetchExplore() async {}

  @override
  Future<void> prefetchMethodology() async {}
}

class _FakeLocationController extends LocationController {
  _FakeLocationController({required super.journeyContextController});

  bool confirmedOriginCity = false;
  int confirmationChecks = 0;

  @override
  LocationData? get savedLocation => const LocationData(
    cityName: 'San Rafael',
    stateName: 'Mendoza',
    countryName: 'Argentina',
    countryCode: 'AR',
    latitude: -34.61,
    longitude: -68.33,
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasConfirmedOriginCity() async {
    confirmationChecks += 1;
    return confirmedOriginCity;
  }

  @override
  Future<void> confirmSavedOriginCity() async {
    confirmedOriginCity = true;
  }

  @override
  Future<bool> shouldRequestAgain() async => false;

  @override
  Future<bool> shouldShowInlineBanner() async => false;
}

class _InMemoryQuestionnaireFlowDraftStore extends QuestionnaireFlowDraftStore {
  QuestionnaireFlowDraftSnapshot? _snapshot;

  @override
  Future<QuestionnaireFlowDraftSnapshot?> read() async => _snapshot;

  @override
  Future<void> write({
    required List<Answer> answers,
    required int currentIndex,
    required String? selectedVariantId,
    required bool showRefinePrompt,
    required bool isRefineResolved,
    required bool includeConstraints,
    String? adaptiveQuestionId,
  }) async {
    _snapshot = QuestionnaireFlowDraftSnapshot(
      answers: answers,
      currentIndex: currentIndex,
      selectedVariantId: selectedVariantId,
      showRefinePrompt: showRefinePrompt,
      isRefineResolved: isRefineResolved,
      includeConstraints: includeConstraints,
      adaptiveQuestionId: adaptiveQuestionId,
    );
  }

  @override
  Future<void> clear() async {
    _snapshot = null;
  }
}

class _FakeCityInsightRepository implements CityInsightRepository {
  @override
  Future<List<CityInsightEntity>> getCityInsights({
    required String cityId,
    String? goal,
    String? timeline,
    String locale = 'pt',
    bool forceRefresh = false,
  }) async => const [];

  @override
  Future<List<CityInsightExplorePlaceEntity>> getExplorePlaces({
    required String cityId,
    required CityInsightTheme theme,
    String locale = 'pt',
    String? seedPlace,
    bool forceRefresh = false,
  }) async => const [];
}

class _FakeCopilotExchangeRatesService extends CopilotExchangeRatesService {
  _FakeCopilotExchangeRatesService({
    required AppEnvironment environment,
    required super.store,
  }) : super(
         remoteDataSource: CopilotExchangeRatesRemoteDataSource(
           environment: environment,
         ),
       );

  @override
  Future<CopilotExchangeRates?> fetchLatest() async {
    const snapshot = CopilotExchangeRates(
      usdToBrl: 5.1,
      brlToUsd: 0.196,
      brlToArs: 190.0,
      arsToBrl: 0.0052,
      usdToArs: 969.0,
      arsToUsd: 0.00103,
      brlToEur: 0.17,
      brlToClp: 170.0,
      brlToUyu: 7.5,
      brlToCop: 720.0,
      brlToPen: 0.66,
      brlToPyg: 1350.0,
      brlToBob: 1.2,
      fetchedAt: '2026-03-12T12:00:00Z',
      source: 'test',
      sources: ['test'],
    );
    return snapshot;
  }
}

const _source = CitySource(
  id: 'test_source',
  title: 'Test source',
  provider: 'Movaro',
  description: 'Mock source',
  isOfficial: true,
  url: null,
  sourceType: 'official',
);

const _sources = CitySources(
  territorialIdentity: _source,
  population: _source,
  humanDevelopment: _source,
  curatedMetrics: _source,
  ranking: _source,
);

const _curitiba = City(
  id: 'curitiba',
  name: 'Curitiba',
  stateCode: 'PR',
  stateName: 'Parana',
  countryCode: 'BR',
  ibgeCode: 1,
  latitude: -25.43,
  longitude: -49.27,
  population: 1770000,
  idhmScore: 0.82,
  idhmReferenceYear: 2021,
  costOfLivingScore: 62,
  rentScore: 60,
  safetyScore: 78,
  argentinaPopularityScore: 58,
  spanishSupportScore: 54,
  jobMarketScore: 74,
  unemploymentRate: 6,
  economicActivityScore: 76,
  topIndustries: ['Tecnologia', 'Servicos'],
  movaroScores: CityScores(
    economical: 76,
    popularForArgentinians: 68,
    languageAdaptation: 72,
    workOpportunity: 82,
    overall: 84,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Sul',
);

const _portoAlegre = City(
  id: 'porto_alegre',
  name: 'Porto Alegre',
  stateCode: 'RS',
  stateName: 'Rio Grande do Sul',
  countryCode: 'BR',
  ibgeCode: 2,
  latitude: -30.03,
  longitude: -51.23,
  population: 1330000,
  idhmScore: 0.81,
  idhmReferenceYear: 2021,
  costOfLivingScore: 60,
  rentScore: 58,
  safetyScore: 70,
  argentinaPopularityScore: 72,
  spanishSupportScore: 75,
  jobMarketScore: 66,
  unemploymentRate: 6.5,
  economicActivityScore: 71,
  topIndustries: ['Servicos', 'Industria'],
  movaroScores: CityScores(
    economical: 70,
    popularForArgentinians: 80,
    languageAdaptation: 82,
    workOpportunity: 70,
    overall: 78,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Sul',
);

const _salvador = City(
  id: 'salvador',
  name: 'Salvador',
  stateCode: 'BA',
  stateName: 'Bahia',
  countryCode: 'BR',
  ibgeCode: 3,
  latitude: -12.97,
  longitude: -38.5,
  population: 2410000,
  idhmScore: 0.76,
  idhmReferenceYear: 2021,
  costOfLivingScore: 68,
  rentScore: 66,
  safetyScore: 55,
  argentinaPopularityScore: 52,
  spanishSupportScore: 48,
  jobMarketScore: 61,
  unemploymentRate: 9.2,
  economicActivityScore: 64,
  topIndustries: ['Turismo', 'Servicos'],
  movaroScores: CityScores(
    economical: 72,
    popularForArgentinians: 60,
    languageAdaptation: 58,
    workOpportunity: 64,
    overall: 69,
  ),
  recommendationReasons: ['reason'],
  sources: _sources,
  updatedAt: '2026-03-12',
  regionName: 'Nordeste',
);

const _allCities = <City>[_curitiba, _portoAlegre, _salvador];

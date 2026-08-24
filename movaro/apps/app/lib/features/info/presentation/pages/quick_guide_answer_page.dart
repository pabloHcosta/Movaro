import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/quick_guide_answer_service.dart';
import 'package:movaro_app/features/info/application/quick_guide_preferences_store.dart';
import 'package:movaro_app/features/info/domain/entities/quick_guide_answer.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/preparation_webview_page.dart';

class QuickGuideAnswerRequest {
  const QuickGuideAnswerRequest({required this.question});

  final String question;
}

class QuickGuideAnswerPage extends StatefulWidget {
  const QuickGuideAnswerPage({
    required this.request,
    required this.environment,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    this.answerService,
    this.initialAnswer,
    super.key,
  });

  final QuickGuideAnswerRequest request;
  final AppEnvironment environment;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final QuickGuideAnswerService? answerService;
  final QuickGuideAnswer? initialAnswer;

  @override
  State<QuickGuideAnswerPage> createState() => _QuickGuideAnswerPageState();
}

class _QuickGuideAnswerPageState extends State<QuickGuideAnswerPage> {
  Future<QuickGuideAnswer>? _answerFuture;
  final QuickGuidePreferencesStore _preferencesStore =
      const QuickGuidePreferencesStore();
  bool? _helpful;
  String? _feedbackReason;
  bool _didRestoreFeedback = false;
  final Map<String, String> _answers = {};
  String? _selectedCityId;
  String? _selectedCityName;
  String? _currentQuestion;
  bool _didInitializeContext = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitializeContext) {
      _didInitializeContext = true;
      _currentQuestion = widget.request.question.trim();
      // Help owns its context. A plan city is never imported implicitly.
      _selectedCityId = null;
      _selectedCityName = null;
    }
    if (_answerFuture == null) {
      _answerFuture = widget.initialAnswer != null
          ? Future.value(widget.initialAnswer)
          : _resolve();
      unawaited(_answerFuture!.then(_restoreFeedback));
    }
  }

  Future<void> _restoreFeedback(QuickGuideAnswer answer) async {
    if (_didRestoreFeedback) return;
    _didRestoreFeedback = true;
    final value = await _preferencesStore.loadFeedback(answer.feedbackKey);
    final reason = await _preferencesStore.loadFeedbackReason(
      answer.feedbackKey,
    );
    if (mounted && (value != null || reason != null)) {
      setState(() {
        _helpful = value;
        _feedbackReason = reason;
      });
    }
    await _preferencesStore.recordEvent(
      'guideAnswerShown',
      dimension: answer.topic,
    );
    await _preferencesStore.recordEvent(
      'guideCoverageShown',
      dimension: answer.coverage.name,
    );
    if (answer.sections.length > 1) {
      await _preferencesStore.recordEvent('guideCompoundAnswerShown');
    }
    if (answer.followUpQuestion != null) {
      await _preferencesStore.recordEvent('guideClarificationShown');
    }
    if (answer.coverage == QuickGuideCoverage.notCovered) {
      await _preferencesStore.recordEvent(
        'guideNoResult',
        dimension: answer.recovery?.reason ?? 'unknown',
      );
    } else if (answer.recovery != null) {
      await _preferencesStore.recordEvent(
        'guideRecoveryShown',
        dimension: answer.recovery!.reason,
      );
    }
  }

  void _setHelpful(QuickGuideAnswer answer, bool value) {
    setState(() {
      _helpful = value;
      if (value) _feedbackReason = null;
    });
    unawaited(_preferencesStore.saveFeedback(answer.feedbackKey, value));
  }

  void _setFeedbackReason(QuickGuideAnswer answer, String reason) {
    setState(() {
      _helpful = false;
      _feedbackReason = reason;
    });
    unawaited(
      _preferencesStore.saveFeedback(answer.feedbackKey, false, reason: reason),
    );
  }

  Future<QuickGuideAnswer> _resolve() {
    final journey = widget.journeyContextController.selection;
    final service =
        widget.answerService ??
        QuickGuideAnswerService(
          client: NetworkClient(environment: widget.environment),
        );
    return service.resolve(
      question: _currentQuestion ?? widget.request.question,
      originCountry: journey.origin?.name ?? 'argentina',
      destinationCountry: journey.destination?.name ?? 'brasil',
      cityId: _selectedCityId,
      locale: Localizations.localeOf(context).languageCode,
      answers: _answers,
    );
  }

  Future<void> _editCityContext() async {
    if (widget.citiesController.catalog.isEmpty) {
      await widget.citiesController.loadCatalog();
    }
    if (!mounted) return;
    final cities = widget.citiesController.catalog
        .where((city) => city.countryCode.toUpperCase() == 'BR')
        .toList(growable: false);
    if (cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              pt: 'Não foi possível carregar as cidades agora.',
              es: 'No fue posible cargar las ciudades ahora.',
              en: 'Cities could not be loaded right now.',
            ),
          ),
        ),
      );
      return;
    }
    City? initialSelection;
    for (final city in cities) {
      if (city.id == _selectedCityId) {
        initialSelection = city;
        break;
      }
    }
    final selected = await CityPickerBottomSheet.show(
      context: context,
      cities: cities,
      initialSelection: initialSelection,
      title: _t(
        context,
        pt: 'Usar contexto de qual cidade?',
        es: '¿Usar el contexto de qué ciudad?',
        en: 'Use context from which city?',
      ),
      subtitle: _t(
        context,
        pt: 'A cidade pode mudar procedimentos locais, não as regras federais.',
        es: 'La ciudad puede cambiar trámites locales, no las reglas federales.',
        en: 'The city may change local procedures, not federal rules.',
      ),
      confirmLabel: _t(
        context,
        pt: 'Usar esta cidade',
        es: 'Usar esta ciudad',
        en: 'Use this city',
      ),
    );
    if (!mounted || selected == null || selected.id == _selectedCityId) return;
    _selectedCityId = selected.id;
    _selectedCityName = selected.name;
    unawaited(
      _preferencesStore.recordEvent('guideContextUpdated', dimension: 'city'),
    );
    _reloadWithCurrentContext();
  }

  void _clearCityContext() {
    if (_selectedCityId == null) return;
    _selectedCityId = null;
    _selectedCityName = null;
    unawaited(
      _preferencesStore.recordEvent(
        'guideContextUpdated',
        dimension: 'city_removed',
      ),
    );
    _reloadWithCurrentContext();
  }

  void _reloadWithCurrentContext() {
    final future = _resolve();
    setState(() {
      _helpful = null;
      _feedbackReason = null;
      _didRestoreFeedback = false;
      _answerFuture = future;
    });
    unawaited(future.then(_restoreFeedback));
  }

  void _answerFollowUp(
    QuickGuideFollowUpQuestion question,
    QuickGuideFollowUpOption option,
  ) {
    _answers[question.contextKey] = option.value;
    unawaited(
      _preferencesStore.recordEvent(
        'guideClarificationAnswered',
        dimension: question.contextKey,
      ),
    );
    final future = _resolve();
    setState(() {
      _helpful = null;
      _feedbackReason = null;
      _didRestoreFeedback = false;
      _answerFuture = future;
    });
    unawaited(future.then(_restoreFeedback));
  }

  void _retry() {
    final future = _resolve();
    setState(() {
      _helpful = null;
      _feedbackReason = null;
      _didRestoreFeedback = false;
      _answerFuture = future;
    });
    unawaited(future.then(_restoreFeedback));
  }

  void _reformulate(QuickGuideRecoverySuggestion suggestion) {
    final question = suggestion.question.trim();
    if (question.isEmpty || question == _currentQuestion) return;
    _currentQuestion = question;
    _answers.clear();
    unawaited(
      _preferencesStore.recordEvent(
        'guideQueryReformulated',
        dimension: suggestion.topic,
      ),
    );
    unawaited(_preferencesStore.recordQuery(question, topic: suggestion.topic));
    final future = _resolve();
    setState(() {
      _helpful = null;
      _feedbackReason = null;
      _didRestoreFeedback = false;
      _answerFuture = future;
    });
    unawaited(future.then(_restoreFeedback));
  }

  void _openSource(QuickGuideSource source) {
    final uri = Uri.tryParse(source.url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return;
    }
    unawaited(_preferencesStore.recordEvent('guideSourceOpened'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreparationWebViewPage(title: source.title, uri: uri),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    0,
                  ),
                  child: AppGlassHeader(
                    title: _t(
                      context,
                      pt: 'Resposta da Ajuda',
                      es: 'Respuesta de Ayuda',
                      en: 'Help answer',
                    ),
                    subtitle: _t(
                      context,
                      pt: 'Rápida, contextual e independente do plano',
                      es: 'Rápida, contextual e independiente del plan',
                      en: 'Fast, contextual, and separate from your plan',
                    ),
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<QuickGuideAnswer>(
                    future: _answerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return _LoadingAnswer(
                          question: _currentQuestion ?? widget.request.question,
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return _AnswerError(onRetry: _retry);
                      }
                      return _answerContent(snapshot.requireData);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 3,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }

  Widget _answerContent(QuickGuideAnswer answer) {
    final cityName = _selectedCityId == answer.context.cityId
        ? _selectedCityName
        : null;
    final topic = _topicVisual(context, answer.topic);
    final showRecoveryEarly =
        answer.recovery != null &&
        (answer.coverage == QuickGuideCoverage.notCovered ||
            answer.coverage == QuickGuideCoverage.partial);
    final showLocationContext =
        answer.context.cityId != null ||
        (!answer.offline &&
            (answer.coverage == QuickGuideCoverage.conditional ||
                answer.coverage == QuickGuideCoverage.needsContext));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: ListView(
          key: const Key('quick-guide-answer-scroll'),
          padding: EdgeInsets.fromLTRB(
            context.pageHorizontalPadding,
            24,
            context.pageHorizontalPadding,
            132,
          ),
          children: [
            _TopicIdentity(topic: topic),
            const SizedBox(height: 14),
            Semantics(
              header: true,
              child: Text(
                answer.question.isEmpty
                    ? widget.request.question
                    : answer.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _AnswerHero(
              key: const Key('quick-guide-answer-hero'),
              answer: answer,
            ),
            if (answer.followUpQuestion case final question?) ...[
              const SizedBox(height: 16),
              _FollowUpCard(
                key: const Key('quick-guide-answer-clarifier'),
                question: question,
                onSelected: (option) => _answerFollowUp(question, option),
              ),
            ],
            if (showRecoveryEarly) ...[
              const SizedBox(height: 16),
              _RecoveryCard(
                recovery: answer.recovery!,
                onSelected: _reformulate,
              ),
            ],
            if (answer.sections.length > 1) ...[
              const SizedBox(height: 16),
              _ResolutionSections(answer: answer, onSourceTap: _openSource),
            ],
            if (answer.steps.isNotEmpty || answer.nextSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              _DecisionStepsCard(
                key: const Key('quick-guide-answer-actions'),
                title: answer.decisionTitle,
                steps: answer.steps,
                nextSteps: answer.nextSteps,
              ),
            ],
            if (answer.caveats.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CaveatsCard(
                key: const Key('quick-guide-answer-caveats'),
                items: answer.caveats,
              ),
            ],
            if (answer.fallbackPath.isNotEmpty) ...[
              const SizedBox(height: 12),
              _FallbackPathCard(
                key: const Key('quick-guide-answer-fallback'),
                items: answer.fallbackPath,
              ),
            ],
            if (answer.recovery case final recovery?
                when !showRecoveryEarly) ...[
              const SizedBox(height: 16),
              _RecoveryCard(recovery: recovery, onSelected: _reformulate),
            ],
            if (showLocationContext) ...[
              const SizedBox(height: 16),
              _ContextCard(
                key: const Key('quick-guide-answer-context'),
                answer: answer,
                cityName: cityName,
                onEditCity: _editCityContext,
                onClearCity: answer.context.cityId == null
                    ? null
                    : _clearCityContext,
              ),
            ],
            if (answer.sources.isNotEmpty || answer.reviewedAt != null) ...[
              const SizedBox(height: 16),
              _SourcesDisclosure(answer: answer, onSourceTap: _openSource),
            ],
            const SizedBox(height: 16),
            _FeedbackCard(
              key: const Key('quick-guide-answer-feedback'),
              value: _helpful,
              reason: _feedbackReason,
              onChanged: (value) => _setHelpful(answer, value),
              onReasonChanged: (reason) => _setFeedbackReason(answer, reason),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  _t(
                    context,
                    pt: 'Buscar outra dúvida',
                    es: 'Buscar otra duda',
                    en: 'Find another question',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicVisualData {
  const _TopicVisualData({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String description;
}

_TopicVisualData _topicVisual(BuildContext context, String topic) {
  return switch (topic) {
    'documents' => _TopicVisualData(
      icon: Icons.folder_copy_outlined,
      color: const Color(0xFF7557E8),
      label: _t(context, pt: 'Documentos', es: 'Documentos', en: 'Documents'),
      description: _t(
        context,
        pt: 'Residência, CPF e registros',
        es: 'Residencia, CPF y registros',
        en: 'Residency, CPF, and records',
      ),
    ),
    'education' => _TopicVisualData(
      icon: Icons.school_outlined,
      color: const Color(0xFF00897B),
      label: _t(context, pt: 'Educação', es: 'Educación', en: 'Education'),
      description: _t(
        context,
        pt: 'Escola, universidade e validação',
        es: 'Escuela, universidad y validación',
        en: 'School, university, and validation',
      ),
    ),
    'housing' || 'utilities' => _TopicVisualData(
      icon: Icons.home_work_outlined,
      color: const Color(0xFFE58A16),
      label: _t(
        context,
        pt: 'Moradia e aluguel',
        es: 'Vivienda y alquiler',
        en: 'Housing and rent',
      ),
      description: _t(
        context,
        pt: 'Busca, contrato e serviços da casa',
        es: 'Búsqueda, contrato y servicios del hogar',
        en: 'Search, contracts, and home utilities',
      ),
    ),
    'work' => _TopicVisualData(
      icon: Icons.work_outline_rounded,
      color: AppColors.primary,
      label: _t(context, pt: 'Trabalho', es: 'Trabajo', en: 'Work'),
      description: _t(
        context,
        pt: 'Documentos, direitos e oportunidades',
        es: 'Documentos, derechos y oportunidades',
        en: 'Documents, rights, and opportunities',
      ),
    ),
    'money' || 'finance' || 'costs' || 'tax' => _TopicVisualData(
      icon: Icons.savings_outlined,
      color: AppColors.success,
      label: _t(
        context,
        pt: 'Custos e dinheiro',
        es: 'Costos y dinero',
        en: 'Costs and money',
      ),
      description: _t(
        context,
        pt: 'Reserva, contas e pagamentos',
        es: 'Reserva, cuentas y pagos',
        en: 'Reserve, accounts, and payments',
      ),
    ),
    'health' => _TopicVisualData(
      icon: Icons.health_and_safety_outlined,
      color: const Color(0xFFE34B67),
      label: _t(context, pt: 'Saúde', es: 'Salud', en: 'Health'),
      description: _t(
        context,
        pt: 'SUS, cuidados e emergências',
        es: 'SUS, atención y emergencias',
        en: 'SUS, care, and emergencies',
      ),
    ),
    'family' => _TopicVisualData(
      icon: Icons.family_restroom_rounded,
      color: const Color(0xFFB04B9B),
      label: _t(context, pt: 'Família', es: 'Familia', en: 'Family'),
      description: _t(
        context,
        pt: 'Dependentes, escola e cuidados',
        es: 'Dependientes, escuela y cuidados',
        en: 'Dependents, school, and care',
      ),
    ),
    'rights' || 'protection' || 'consumer' => _TopicVisualData(
      icon: Icons.gavel_rounded,
      color: const Color(0xFF4361A9),
      label: _t(context, pt: 'Direitos', es: 'Derechos', en: 'Rights'),
      description: _t(
        context,
        pt: 'Proteção, consumo e segurança',
        es: 'Protección, consumo y seguridad',
        en: 'Protection, consumer rights, and safety',
      ),
    ),
    'arrival' || 'flights' || 'driving' || 'pets_customs' => _TopicVisualData(
      icon: Icons.flight_land_rounded,
      color: const Color(0xFF157E96),
      label: _t(context, pt: 'Chegada', es: 'Llegada', en: 'Arrival'),
      description: _t(
        context,
        pt: 'Viagem, transporte e primeiros dias',
        es: 'Viaje, transporte y primeros días',
        en: 'Travel, transport, and first days',
      ),
    ),
    'long_term' => _TopicVisualData(
      icon: Icons.flag_outlined,
      color: const Color(0xFF5C6F7B),
      label: _t(
        context,
        pt: 'Vida no Brasil',
        es: 'Vida en Brasil',
        en: 'Life in Brazil',
      ),
      description: _t(
        context,
        pt: 'Permanência e decisões de longo prazo',
        es: 'Permanencia y decisiones a largo plazo',
        en: 'Long-term residence and decisions',
      ),
    ),
    _ => _TopicVisualData(
      icon: Icons.help_center_outlined,
      color: AppColors.primary,
      label: _t(
        context,
        pt: 'Ajuda rápida',
        es: 'Ayuda rápida',
        en: 'Quick help',
      ),
      description: _t(
        context,
        pt: 'Orientação para viver no Brasil',
        es: 'Orientación para vivir en Brasil',
        en: 'Guidance for living in Brazil',
      ),
    ),
  };
}

class _TopicIdentity extends StatelessWidget {
  const _TopicIdentity({required this.topic});

  final _TopicVisualData topic;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('quick-guide-topic-identity'),
      container: true,
      label: '${topic.label}. ${topic.description}',
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: topic.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: topic.color.withValues(alpha: 0.2)),
            ),
            child: Icon(topic.icon, color: topic.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              topic.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: topic.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerHero extends StatelessWidget {
  const _AnswerHero({required this.answer, super.key});

  final QuickGuideAnswer answer;

  @override
  Widget build(BuildContext context) {
    final status = switch (answer.coverage) {
      QuickGuideCoverage.confirmed => (
        Icons.verified_rounded,
        _t(
          context,
          pt: 'Resposta verificada',
          es: 'Respuesta verificada',
          en: 'Verified answer',
        ),
        AppColors.success,
      ),
      QuickGuideCoverage.conditional => (
        Icons.fact_check_outlined,
        _t(
          context,
          pt: 'Pode variar no seu caso',
          es: 'Puede variar en tu caso',
          en: 'May vary for your case',
        ),
        AppColors.primary,
      ),
      QuickGuideCoverage.needsContext => (
        Icons.tune_rounded,
        _t(
          context,
          pt: 'Responda para ajustar',
          es: 'Respondé para ajustar',
          en: 'Answer to refine',
        ),
        AppColors.caution,
      ),
      QuickGuideCoverage.partial => (
        Icons.info_rounded,
        _t(
          context,
          pt: 'Resposta limitada',
          es: 'Respuesta limitada',
          en: 'Limited answer',
        ),
        AppColors.caution,
      ),
      QuickGuideCoverage.notCovered => (
        Icons.search_off_rounded,
        _t(
          context,
          pt: 'Ainda sem resposta revisada',
          es: 'Aún sin respuesta revisada',
          en: 'No reviewed answer yet',
        ),
        AppColors.textSoftFor(context),
      ),
    };
    final isDark = AppColors.isDark(context);
    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xF21B2942), Color(0xF20A1424)]
            : const [Color(0xFFF7FBFF), Color(0xFFEAF3FF)],
      ),
      borderColor: AppColors.primary.withValues(alpha: isDark ? 0.32 : 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              _t(context, pt: 'Em resumo', es: 'En resumen', en: 'In short'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DirectAnswer(answer: answer),
          const SizedBox(height: 18),
          _StatusPill(icon: status.$1, label: status.$2, color: status.$3),
          if (answer.coverage != QuickGuideCoverage.confirmed &&
              answer.coverageReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Semantics(
              label: answer.coverageReason,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(status.$1, size: 17, color: status.$3),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      answer.coverageReason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Icon(icon, size: 16, color: color),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionSections extends StatelessWidget {
  const _ResolutionSections({required this.answer, required this.onSourceTap});

  final QuickGuideAnswer answer;
  final ValueChanged<QuickGuideSource> onSourceTap;

  @override
  Widget build(BuildContext context) {
    final claimsById = {for (final claim in answer.claims) claim.id: claim};
    final sourcesById = {
      for (final source in answer.sources)
        if (source.id.isNotEmpty) source.id: source,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: _t(
            context,
            pt: 'Sua dúvida, por partes',
            es: 'Tu duda, por partes',
            en: 'Your question, by part',
          ),
          subtitle: _t(
            context,
            pt: 'Cada assunto mantém sua própria cobertura e evidência.',
            es: 'Cada tema mantiene su propia cobertura y evidencia.',
            en: 'Each subject keeps its own coverage and evidence.',
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < answer.sections.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              container: true,
              label: _t(
                context,
                pt: 'Parte ${index + 1} de ${answer.sections.length}: ${answer.sections[index].title}',
                es: 'Parte ${index + 1} de ${answer.sections.length}: ${answer.sections[index].title}',
                en: 'Part ${index + 1} of ${answer.sections.length}: ${answer.sections[index].title}',
              ),
              child: FrostedPanel(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            answer.sections[index].title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimaryFor(context),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Icon(
                          answer.sections[index].coverage ==
                                  QuickGuideCoverage.partial
                              ? Icons.info_outline_rounded
                              : Icons.fact_check_outlined,
                          color:
                              answer.sections[index].coverage ==
                                  QuickGuideCoverage.partial
                              ? AppColors.caution
                              : AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      answer.sections[index].answer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        height: 1.5,
                      ),
                    ),
                    if (answer.sections[index].claimIds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final source
                              in answer.sections[index].claimIds
                                  .expand(
                                    (claimId) =>
                                        claimsById[claimId]?.evidenceIds ??
                                        const [],
                                  )
                                  .map((evidenceId) => sourcesById[evidenceId])
                                  .whereType<QuickGuideSource>()
                                  .toSet())
                            ActionChip(
                              avatar: const Icon(
                                Icons.open_in_new_rounded,
                                size: 15,
                              ),
                              label: Text(source.publisher),
                              tooltip: source.title,
                              onPressed: () => onSourceTap(source),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({
    required this.question,
    required this.onSelected,
    super.key,
  });

  final QuickGuideFollowUpQuestion question;
  final ValueChanged<QuickGuideFollowUpOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return _AnswerSectionCard(
      semanticLabel: question.prompt,
      liveRegion: true,
      icon: Icons.tune_rounded,
      tone: AppColors.primary,
      title: _t(
        context,
        pt: 'Um detalhe muda a resposta',
        es: 'Un dato cambia la respuesta',
        en: 'One detail changes the answer',
      ),
      subtitle: question.prompt,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in question.options)
            OutlinedButton(
              onPressed: () => onSelected(option),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppColors.surfaceFor(context),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(option.label),
            ),
        ],
      ),
    );
  }
}

class _AnswerSectionCard extends StatelessWidget {
  const _AnswerSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.tone = AppColors.primary,
    this.semanticLabel,
    this.liveRegion = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color tone;
  final String? semanticLabel;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: semanticLabel,
      child: FrostedPanel(
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(22),
        borderColor: tone.withValues(alpha: 0.22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: tone, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimaryFor(context),
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSoftFor(context),
                                height: 1.42,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DecisionStepsCard extends StatelessWidget {
  const _DecisionStepsCard({
    required this.title,
    required this.steps,
    required this.nextSteps,
    super.key,
  });

  final String? title;
  final List<QuickGuideStep> steps;
  final List<String> nextSteps;

  @override
  Widget build(BuildContext context) {
    final seen = <String>{};
    final items = <String>[
      ...steps.map((step) => step.label),
      ...nextSteps,
    ].where((item) => seen.add(item.trim().toLowerCase())).toList();
    return _AnswerSectionCard(
      icon: Icons.signpost_outlined,
      title: _t(
        context,
        pt: 'O que fazer agora',
        es: 'Qué hacer ahora',
        en: 'What to do now',
      ),
      subtitle: title,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      items[index],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackPathCard extends StatelessWidget {
  const _FallbackPathCard({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.caution.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.caution.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.alt_route_rounded, color: AppColors.caution),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          _t(
            context,
            pt: 'Se algo bloquear seu caminho',
            es: 'Si algo bloquea tu camino',
            en: 'If something blocks your path',
          ),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.caution,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.recovery, required this.onSelected});

  final QuickGuideRecovery recovery;
  final ValueChanged<QuickGuideRecoverySuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return _AnswerSectionCard(
      icon: Icons.assistant_direction_rounded,
      title: _t(
        context,
        pt: 'Vamos por um caminho seguro',
        es: 'Probemos un camino seguro',
        en: 'Let’s take a safe path',
      ),
      subtitle: recovery.message,
      liveRegion: true,
      child: Column(
        children: [
          if (recovery.suggestions.isNotEmpty)
            for (final suggestion in recovery.suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: OutlinedButton(
                    onPressed: () => onSelected(suggestion),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.answer,
    required this.cityName,
    required this.onEditCity,
    required this.onClearCity,
    super.key,
  });
  final QuickGuideAnswer answer;
  final String? cityName;
  final VoidCallback onEditCity;
  final VoidCallback? onClearCity;

  @override
  Widget build(BuildContext context) {
    final route =
        '${_country(answer.context.originCountry)} → ${_country(answer.context.destinationCountry)}';
    final location =
        cityName ??
        _t(
          context,
          pt: 'sem cidade definida',
          es: 'sin ciudad definida',
          en: 'no city selected',
        );
    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        context,
                        pt: 'Local considerado',
                        es: 'Lugar considerado',
                        en: 'Location considered',
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$route · $location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEditCity,
                icon: const Icon(Icons.location_city_outlined, size: 18),
                label: Text(
                  cityName == null
                      ? _t(
                          context,
                          pt: 'Adicionar cidade',
                          es: 'Agregar ciudad',
                          en: 'Add city',
                        )
                      : _t(
                          context,
                          pt: 'Trocar cidade',
                          es: 'Cambiar ciudad',
                          en: 'Change city',
                        ),
                ),
              ),
              if (onClearCity != null)
                TextButton(
                  onPressed: onClearCity,
                  child: Text(
                    _t(
                      context,
                      pt: 'Usar sem cidade',
                      es: 'Usar sin ciudad',
                      en: 'Use without city',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DirectAnswer extends StatelessWidget {
  const _DirectAnswer({required this.answer});

  final QuickGuideAnswer answer;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      answer.answer,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimaryFor(context),
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
    );
  }
}

class _CaveatsCard extends StatelessWidget {
  const _CaveatsCard({required this.items, super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _AnswerSectionCard(
      semanticLabel: _t(
        context,
        pt: 'Atenção',
        es: 'Atención',
        en: 'Attention',
      ),
      icon: Icons.shield_outlined,
      tone: AppColors.caution,
      title: _t(
        context,
        pt: 'Antes de agir',
        es: 'Antes de actuar',
        en: 'Before you act',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 8,
              ),
              child: Text(
                items[index],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.42,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _SourcesDisclosure extends StatelessWidget {
  const _SourcesDisclosure({required this.answer, required this.onSourceTap});

  final QuickGuideAnswer answer;
  final ValueChanged<QuickGuideSource> onSourceTap;

  @override
  Widget build(BuildContext context) {
    final sourceCount = answer.sources.length;
    final summary = [
      if (sourceCount > 0)
        _t(
          context,
          pt: '$sourceCount ${sourceCount == 1 ? 'fonte oficial' : 'fontes oficiais'}',
          es: '$sourceCount ${sourceCount == 1 ? 'fuente oficial' : 'fuentes oficiales'}',
          en: '$sourceCount official ${sourceCount == 1 ? 'source' : 'sources'}',
        ),
      if (answer.reviewedAt != null)
        _t(
          context,
          pt: 'revisado em ${_date(answer.reviewedAt!)}',
          es: 'revisado el ${_date(answer.reviewedAt!)}',
          en: 'reviewed on ${_date(answer.reviewedAt!)}',
        ),
    ].join(' · ');
    return Container(
      key: const Key('quick-guide-answer-sources'),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context).withValues(alpha: 0.72),
        border: Border.all(color: AppColors.borderFor(context)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: const Icon(
          Icons.verified_user_outlined,
          color: AppColors.primary,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          _t(
            context,
            pt: 'Como verificamos',
            es: 'Cómo lo verificamos',
            en: 'How we verified it',
          ),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: summary.isEmpty
            ? null
            : Text(
                summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoftFor(context),
                ),
              ),
        children: [
          if (answer.claims.isNotEmpty && answer.sections.length <= 1) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _t(
                  context,
                  pt: 'Evidências consideradas',
                  es: 'Evidencias consideradas',
                  en: 'Evidence considered',
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < answer.claims.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == answer.claims.length - 1 ? 14 : 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      answer.claims[index].status ==
                              QuickGuideClaimStatus.verified
                          ? Icons.verified_outlined
                          : Icons.rule_rounded,
                      size: 18,
                      color:
                          answer.claims[index].status ==
                              QuickGuideClaimStatus.verified
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        answer.claims[index].text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimaryFor(context),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (answer.editorialOwner != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _t(
                    context,
                    pt: 'Responsável editorial: ${answer.editorialOwner!}',
                    es: 'Responsable editorial: ${answer.editorialOwner!}',
                    en: 'Editorial owner: ${answer.editorialOwner!}',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ),
            ),
          if (answer.expiresAt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _t(
                    context,
                    pt: 'Vigência editorial até ${_date(answer.expiresAt!)}',
                    es: 'Vigencia editorial hasta ${_date(answer.expiresAt!)}',
                    en: 'Editorial validity until ${_date(answer.expiresAt!)}',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ),
            ),
          if (answer.sources.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _t(
                    context,
                    pt: 'Fontes oficiais',
                    es: 'Fuentes oficiales',
                    en: 'Official sources',
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          for (final source in answer.sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SourceCard(
                source: source,
                onTap: () => onSourceTap(source),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source, required this.onTap});
  final QuickGuideSource source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      label: '${source.title}, ${source.publisher}',
      child: FrostedPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.textPrimaryFor(context),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${source.publisher} · ${_date(source.checkedAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSoftFor(context)),
                        ),
                        if (source.scope.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            source.scope,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.35,
                                ),
                          ),
                        ],
                        if (source.validUntil != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            _t(
                              context,
                              pt: 'Vigência editorial até ${_date(source.validUntil!)}',
                              es: 'Vigencia editorial hasta ${_date(source.validUntil!)}',
                              en: 'Editorial validity until ${_date(source.validUntil!)}',
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.value,
    required this.reason,
    required this.onChanged,
    required this.onReasonChanged,
    super.key,
  });
  final bool? value;
  final String? reason;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    final title = value == null
        ? _t(
            context,
            pt: 'Isso ajudou?',
            es: '¿Esto te ayudó?',
            en: 'Was this helpful?',
          )
        : value == false && reason == null
        ? _t(
            context,
            pt: 'O que faltou?',
            es: '¿Qué faltó?',
            en: 'What was missing?',
          )
        : _t(
            context,
            pt: 'Obrigado pelo feedback.',
            es: 'Gracias por tu opinión.',
            en: 'Thanks for your feedback.',
          );
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FeedbackButton(
                  label: _t(context, pt: 'Sim', es: 'Sí', en: 'Yes'),
                  icon: Icons.thumb_up_alt_outlined,
                  selected: value == true,
                  onPressed: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeedbackButton(
                  label: _t(context, pt: 'Não', es: 'No', en: 'No'),
                  icon: Icons.thumb_down_alt_outlined,
                  selected: value == false,
                  onPressed: () => onChanged(false),
                ),
              ),
            ],
          ),
          if (value == false) ...[
            const SizedBox(height: 14),
            Text(
              _t(
                context,
                pt: 'Escolha um motivo. Não armazenamos o texto da sua pergunta nas métricas.',
                es: 'Elegí un motivo. No guardamos el texto de tu pregunta en las métricas.',
                en: 'Choose a reason. We do not store your question text in metrics.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _feedbackReasons(context))
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: ChoiceChip(
                      label: Text(item.$2),
                      selected: reason == item.$1,
                      onSelected: (_) => onReasonChanged(item.$1),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<(String, String)> _feedbackReasons(BuildContext context) => [
    (
      'outdated',
      _t(context, pt: 'Desatualizada', es: 'Desactualizada', en: 'Outdated'),
    ),
    (
      'incorrect',
      _t(
        context,
        pt: 'Parece incorreta',
        es: 'Parece incorrecta',
        en: 'Seems incorrect',
      ),
    ),
    (
      'not_my_case',
      _t(context, pt: 'Não é meu caso', es: 'No es mi caso', en: 'Not my case'),
    ),
    (
      'too_generic',
      _t(
        context,
        pt: 'Genérica demais',
        es: 'Demasiado genérica',
        en: 'Too generic',
      ),
    ),
    (
      'confusing',
      _t(context, pt: 'Ficou confusa', es: 'Quedó confusa', en: 'Confusing'),
    ),
    (
      'action_failed',
      _t(
        context,
        pt: 'A ação não funcionou',
        es: 'La acción no funcionó',
        en: 'Action failed',
      ),
    ),
  ];
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : null,
            side: BorderSide(
              color: selected
                  ? AppColors.primary
                  : AppColors.borderFor(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingAnswer extends StatelessWidget {
  const _LoadingAnswer({required this.question});
  final String question;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: _t(
        context,
        pt: 'Preparando resposta',
        es: 'Preparando respuesta',
        en: 'Preparing answer',
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: FrostedPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t(
                      context,
                      pt: 'Organizando uma resposta confiável…',
                      es: 'Organizando una respuesta confiable…',
                      en: 'Preparing a trustworthy answer…',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerError extends StatelessWidget {
  const _AnswerError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FrostedPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 34),
              const SizedBox(height: 14),
              Text(
                _t(
                  context,
                  pt: 'Não foi possível preparar a resposta.',
                  es: 'No se pudo preparar la respuesta.',
                  en: 'We could not prepare the answer.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: onRetry,
                  child: Text(
                    _t(
                      context,
                      pt: 'Tentar novamente',
                      es: 'Intentar de nuevo',
                      en: 'Try again',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _t(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

String _country(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'argentina' || 'ar' => 'Argentina',
    'brasil' || 'brazil' || 'br' => 'Brasil',
    _ => value.trim().isEmpty ? '—' : value.trim(),
  };
}

String _date(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return value;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

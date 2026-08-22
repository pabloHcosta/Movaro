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
            Semantics(
              header: true,
              child: Text(
                _t(
                  context,
                  pt: 'SUA PERGUNTA',
                  es: 'TU PREGUNTA',
                  en: 'YOUR QUESTION',
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
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
            const SizedBox(height: 20),
            _AnswerHero(answer: answer, onSourceTap: _openSource),
            if (answer.sections.length > 1) ...[
              const SizedBox(height: 16),
              _ResolutionSections(answer: answer, onSourceTap: _openSource),
            ],
            const SizedBox(height: 16),
            _ContextCard(
              answer: answer,
              cityName: cityName,
              onEditCity: _editCityContext,
              onClearCity: answer.context.cityId == null
                  ? null
                  : _clearCityContext,
            ),
            if (answer.followUpQuestion case final question?) ...[
              const SizedBox(height: 16),
              _FollowUpCard(
                question: question,
                onSelected: (option) => _answerFollowUp(question, option),
              ),
            ],
            if (answer.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              _DecisionStepsCard(
                title: answer.decisionTitle,
                steps: answer.steps,
              ),
            ],
            if (answer.nextSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              _PracticalStepsCard(items: answer.nextSteps),
            ],
            if (answer.fallbackPath.isNotEmpty) ...[
              const SizedBox(height: 12),
              _FallbackPathCard(items: answer.fallbackPath),
            ],
            if (answer.recovery case final recovery?) ...[
              const SizedBox(height: 16),
              _RecoveryCard(recovery: recovery, onSelected: _reformulate),
            ],
            if (answer.caveats.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CaveatsCard(items: answer.caveats),
            ],
            if (answer.sources.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle(
                title: _t(
                  context,
                  pt: 'Fontes usadas',
                  es: 'Fuentes utilizadas',
                  en: 'Sources used',
                ),
                subtitle: _t(
                  context,
                  pt: 'Veja o escopo e a vigência de cada fonte.',
                  es: 'Consultá el alcance y la vigencia de cada fuente.',
                  en: 'Review the scope and validity of each source.',
                ),
              ),
              const SizedBox(height: 12),
              for (final source in answer.sources)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SourceCard(
                    source: source,
                    onTap: () => _openSource(source),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            _FeedbackCard(
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
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text(
                  _t(
                    context,
                    pt: 'Fazer outra pergunta',
                    es: 'Hacer otra pregunta',
                    en: 'Ask another question',
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

class _AnswerHero extends StatelessWidget {
  const _AnswerHero({required this.answer, required this.onSourceTap});

  final QuickGuideAnswer answer;
  final ValueChanged<QuickGuideSource> onSourceTap;

  @override
  Widget build(BuildContext context) {
    final status = switch (answer.coverage) {
      QuickGuideCoverage.confirmed => (
        Icons.verified_rounded,
        _t(
          context,
          pt: 'Confirmado para este contexto',
          es: 'Confirmado para este contexto',
          en: 'Confirmed for this context',
        ),
        AppColors.success,
      ),
      QuickGuideCoverage.conditional => (
        Icons.fact_check_outlined,
        _t(
          context,
          pt: 'Aplica-se com condições',
          es: 'Se aplica con condiciones',
          en: 'Applies with conditions',
        ),
        AppColors.primary,
      ),
      QuickGuideCoverage.needsContext => (
        Icons.tune_rounded,
        _t(
          context,
          pt: 'Precisa de um detalhe',
          es: 'Necesita un dato',
          en: 'Needs one detail',
        ),
        AppColors.caution,
      ),
      QuickGuideCoverage.partial => (
        Icons.info_rounded,
        _t(
          context,
          pt: 'Cobertura parcial',
          es: 'Cobertura parcial',
          en: 'Partial coverage',
        ),
        AppColors.caution,
      ),
      QuickGuideCoverage.notCovered => (
        Icons.search_off_rounded,
        _t(
          context,
          pt: 'Sem cobertura específica',
          es: 'Sin cobertura específica',
          en: 'No specific coverage',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(icon: status.$1, label: status.$2, color: status.$3),
              if (answer.offline)
                _StatusPill(
                  icon: Icons.offline_bolt_rounded,
                  label: _t(
                    context,
                    pt: 'Disponível offline',
                    es: 'Disponible sin conexión',
                    en: 'Available offline',
                  ),
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              _t(
                context,
                pt: 'Resposta direta',
                es: 'Respuesta directa',
                en: 'Direct answer',
              ),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DirectAnswerWithEvidence(answer: answer, onSourceTap: onSourceTap),
          if (answer.coverageReason.isNotEmpty) ...[
            const SizedBox(height: 14),
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
          if (answer.reviewedAt != null) ...[
            const SizedBox(height: 16),
            Text(
              _t(
                context,
                pt: answer.expiresAt == null
                    ? 'Revisado em ${_date(answer.reviewedAt!)}'
                    : 'Revisado em ${_date(answer.reviewedAt!)} · válido até ${_date(answer.expiresAt!)}',
                es: answer.expiresAt == null
                    ? 'Revisado el ${_date(answer.reviewedAt!)}'
                    : 'Revisado el ${_date(answer.reviewedAt!)} · válido hasta ${_date(answer.expiresAt!)}',
                en: answer.expiresAt == null
                    ? 'Reviewed on ${_date(answer.reviewedAt!)}'
                    : 'Reviewed on ${_date(answer.reviewedAt!)} · valid until ${_date(answer.expiresAt!)}',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
            if (answer.editorialOwner != null) ...[
              const SizedBox(height: 4),
              Text(
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
            ],
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
  const _FollowUpCard({required this.question, required this.onSelected});

  final QuickGuideFollowUpQuestion question;
  final ValueChanged<QuickGuideFollowUpOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: question.prompt,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.14),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          context,
                          pt: 'Um detalhe muda a resposta',
                          es: 'Un dato cambia la respuesta',
                          en: 'One detail changes the answer',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.prompt,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimaryFor(context),
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
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
          ],
        ),
      ),
    );
  }
}

class _DecisionStepsCard extends StatelessWidget {
  const _DecisionStepsCard({required this.title, required this.steps});

  final String? title;
  final List<QuickGuideStep> steps;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ??
                _t(
                  context,
                  pt: 'Caminho recomendado',
                  es: 'Camino recomendado',
                  en: 'Recommended path',
                ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == steps.length - 1 ? 0 : 14,
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
                      steps[index].label,
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

class _PracticalStepsCard extends StatelessWidget {
  const _PracticalStepsCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: AppColors.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _t(
                    context,
                    pt: 'Próximos passos',
                    es: 'Próximos pasos',
                    en: 'Next steps',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
  const _FallbackPathCard({required this.items});

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
    return Semantics(
      container: true,
      liveRegion: true,
      child: FrostedPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(24),
        borderColor: AppColors.primary.withValues(alpha: 0.24),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.assistant_direction_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          context,
                          pt: 'Vamos por um caminho seguro',
                          es: 'Probemos un camino seguro',
                          en: 'Let’s take a safe path',
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimaryFor(context),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recovery.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (recovery.suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
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
          ],
        ),
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
  });
  final QuickGuideAnswer answer;
  final String? cityName;
  final VoidCallback onEditCity;
  final VoidCallback? onClearCity;

  @override
  Widget build(BuildContext context) {
    final route =
        '${_country(answer.context.originCountry)} → ${_country(answer.context.destinationCountry)}';
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        context,
                        pt: 'Contexto usado',
                        es: 'Contexto usado',
                        en: 'Context used',
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cityName == null ? route : '$route · $cityName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _t(
                    context,
                    pt: 'Esta consulta não altera seu plano.',
                    es: 'Esta consulta no cambia tu plan.',
                    en: 'This query does not change your plan.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
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

class _DirectAnswerWithEvidence extends StatelessWidget {
  const _DirectAnswerWithEvidence({
    required this.answer,
    required this.onSourceTap,
  });

  final QuickGuideAnswer answer;
  final ValueChanged<QuickGuideSource> onSourceTap;

  @override
  Widget build(BuildContext context) {
    final claims = answer.claims;
    if (claims.isEmpty || answer.sections.length > 1) {
      return SelectableText(
        answer.answer,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w600,
          height: 1.55,
        ),
      );
    }
    final sourceById = {
      for (final source in answer.sources)
        if (source.id.isNotEmpty) source.id: source,
    };
    return Column(
      children: [
        for (var index = 0; index < claims.length; index++) ...[
          Semantics(
            container: true,
            label: _t(
              context,
              pt: 'Afirmação ${index + 1} de ${claims.length}',
              es: 'Afirmación ${index + 1} de ${claims.length}',
              en: 'Claim ${index + 1} of ${claims.length}',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      claims[index].status == QuickGuideClaimStatus.verified
                          ? Icons.verified_outlined
                          : Icons.rule_rounded,
                      size: 21,
                      color:
                          claims[index].status == QuickGuideClaimStatus.verified
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        claims[index].text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimaryFor(context),
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 31),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final evidenceId in claims[index].evidenceIds)
                        if (sourceById[evidenceId] case final source?)
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
                ),
              ],
            ),
          ),
          if (index < claims.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.borderFor(context)),
            ),
        ],
      ],
    );
  }
}

class _CaveatsCard extends StatelessWidget {
  const _CaveatsCard({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _t(context, pt: 'Atenção', es: 'Atención', en: 'Attention'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.caution.withValues(alpha: 0.09),
          border: Border.all(color: AppColors.caution.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.caution),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      context,
                      pt: 'Vale confirmar',
                      es: 'Conviene confirmar',
                      en: 'Worth confirming',
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
  });
  final bool? value;
  final String? reason;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value == null
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
                  ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
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

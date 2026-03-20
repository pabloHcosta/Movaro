import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/question_repository.dart';

class MigrationQuestionnaireController extends ChangeNotifier {
  MigrationQuestionnaireController({
    required QuestionRepository questionRepository,
    required MigrationPlanRepository migrationPlanRepository,
    required MigrationPlanGenerator planGenerator,
    required JourneyContextController journeyContextController,
    QuestionnaireFlowDraftStore? flowDraftStore,
  }) : _questionRepository = questionRepository,
       _migrationPlanRepository = migrationPlanRepository,
       _planGenerator = planGenerator,
       _journeyContextController = journeyContextController,
       _flowDraftStore = flowDraftStore ?? QuestionnaireFlowDraftStore();

  final QuestionRepository _questionRepository;
  final MigrationPlanRepository _migrationPlanRepository;
  final MigrationPlanGenerator _planGenerator;
  final JourneyContextController _journeyContextController;
  final QuestionnaireFlowDraftStore _flowDraftStore;

  List<Question> _questions = const [];
  List<Answer> _answers = const [];
  List<MigrationPlan> _savedPlans = const [];
  MigrationPlan? _generatedPlan;
  QuestionnaireVariant? _selectedVariant;
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isGeneratingPlan = false;
  bool _isSavingPlan = false;
  bool _showRefinePrompt = false;
  bool _isRefineResolved = false;
  bool _includeConstraints = false;

  List<Question> get questions => _questions;
  List<Question> get activeQuestions => _activeQuestions;
  List<Answer> get answers => _answers;
  List<MigrationPlan> get savedPlans => _savedPlans;
  MigrationPlan? get generatedPlan => _generatedPlan;
  QuestionnaireVariant? get selectedVariant => _selectedVariant;
  JourneyContextController get journeyContextController =>
      _journeyContextController;
  int get currentIndex => _currentIndex;
  bool get hasSelectedVariant => _selectedVariant != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isInitializing || _isGeneratingPlan || _isSavingPlan;
  bool get isInitializing => _isInitializing;
  bool get isGeneratingPlan => _isGeneratingPlan;
  bool get isSavingPlan => _isSavingPlan;
  bool get isRefinePromptVisible => _showRefinePrompt;
  bool get hasInProgressDraft =>
      _selectedVariant != null ||
      _answers.any(
        (answer) =>
            answer.questionId != 'origin_country' &&
            answer.questionId != 'destination_country',
      );

  List<Question> get coreQuestions {
    final variant = _selectedVariant;
    if (variant == null) {
      return const [];
    }

    return _questions
        .where((question) => question.variants.contains(variant))
        .toList(growable: false);
  }

  Question? get optionalConstraintsQuestion {
    for (final question in _questions) {
      if (question.id == 'constraints') {
        return question;
      }
    }
    return null;
  }

  List<Question> get _activeQuestions {
    return coreQuestions;
  }

  Question? get currentQuestion {
    if (_showRefinePrompt || !hasSelectedVariant) {
      return null;
    }

    final activeQuestions = _activeQuestions;
    if (activeQuestions.isEmpty || _currentIndex >= activeQuestions.length) {
      return null;
    }

    return activeQuestions[_currentIndex];
  }

  double get progress {
    final total = totalStepsForProgress;
    if (total == 0 || _showRefinePrompt) {
      return total == 0 ? 0 : 1;
    }

    return (_currentIndex + 1) / total;
  }

  int get totalStepsForProgress => _activeQuestions.length;

  int get currentStepForProgress {
    if (_showRefinePrompt) {
      return coreQuestions.length;
    }
    return currentQuestion == null ? 0 : _currentIndex + 1;
  }

  bool get isStrategicVariant =>
      _selectedVariant == QuestionnaireVariant.strategic;

  Future<void> initialize() async {
    if (_isInitialized) {
      _syncJourneyAnswers();
      notifyListeners();
      return;
    }

    _setInitializing(true);
    try {
      _questions = await _questionRepository.getQuestions();
      _savedPlans = await _migrationPlanRepository.getSavedPlans();
      _generatedPlan = await _migrationPlanRepository.getCurrentPlan();
      final draft = _generatedPlan == null
          ? await _flowDraftStore.read()
          : null;
      _restoreDraft(draft);
      _syncJourneyAnswers();
      _clampCurrentIndex();
      _isInitialized = true;
      notifyListeners();
    } finally {
      _setInitializing(false);
    }
  }

  Future<void> resetFlow() async {
    _answers = const [];
    _syncJourneyAnswers();
    _generatedPlan = null;
    _selectedVariant = null;
    _currentIndex = 0;
    _showRefinePrompt = false;
    _isRefineResolved = false;
    _includeConstraints = false;
    await _flowDraftStore.clear();
    notifyListeners();
  }

  Future<void> clearCurrentPlan() async {
    _answers = const [];
    _syncJourneyAnswers();
    _generatedPlan = null;
    _selectedVariant = null;
    _currentIndex = 0;
    _showRefinePrompt = false;
    _isRefineResolved = false;
    _includeConstraints = false;
    await _migrationPlanRepository.setCurrentPlan(null);
    await _flowDraftStore.clear();
    notifyListeners();
  }

  void selectVariant(QuestionnaireVariant variant) {
    _selectedVariant = variant;
    _currentIndex = 0;
    _showRefinePrompt = false;
    _isRefineResolved = false;
    _includeConstraints = false;
    if (variant == QuestionnaireVariant.lean) {
      _removeAnswer('constraints');
    }
    notifyListeners();
    _persistDraft();
  }

  void selectAnswer(String questionId, String value) {
    _setAnswer(questionId, <String>[value]);
    _syncJourneySelection(questionId, <String>[value]);
  }

  Future<void> setJourneyDestination(String countryId) async {
    await _journeyContextController.setDestinationCountry(countryId);
    _syncJourneyAnswers();
    notifyListeners();
    _persistDraft();
  }

  bool toggleAnswer(String questionId, String value) {
    Question? question;
    for (final item in _questions) {
      if (item.id == questionId) {
        question = item;
        break;
      }
    }
    if (question == null) {
      return false;
    }

    final currentValues = List<String>.from(answerValuesFor(questionId));
    const exclusiveValues = {'balanced_unsure', 'no_constraints'};

    if (currentValues.contains(value)) {
      currentValues.remove(value);
      _setAnswer(questionId, currentValues);
      return true;
    }

    if (exclusiveValues.contains(value)) {
      _setAnswer(questionId, <String>[value]);
      return true;
    }

    currentValues.removeWhere(exclusiveValues.contains);
    if (currentValues.length >= question.maxSelections) {
      return false;
    }

    currentValues.add(value);
    _setAnswer(questionId, currentValues);
    return true;
  }

  List<String> answerValuesFor(String questionId) {
    final match = _answers.where((answer) => answer.questionId == questionId);
    if (match.isEmpty) {
      return const [];
    }

    return List<String>.from(match.first.values);
  }

  String? answerFor(String questionId) {
    final values = answerValuesFor(questionId);
    if (values.isEmpty) {
      return null;
    }

    return values.first;
  }

  bool get canGoBack =>
      _showRefinePrompt || _currentIndex > 0 || hasSelectedVariant;

  bool get canGoNext {
    final question = currentQuestion;
    if (_showRefinePrompt) {
      return true;
    }

    if (question == null) {
      return false;
    }

    final values = answerValuesFor(question.id);
    if (question.isOptional) {
      return true;
    }

    if (question.id == 'origin_country') {
      return values.isNotEmpty && answerFor('destination_country') != null;
    }

    if (question.id == 'priorities') {
      return values.isNotEmpty;
    }

    return values.isNotEmpty;
  }

  bool get isLastQuestion {
    final question = currentQuestion;
    if (question == null) {
      return false;
    }

    return identical(question, _activeQuestions.last);
  }

  void goBack() {
    if (!canGoBack) {
      return;
    }

    if (_showRefinePrompt) {
      _showRefinePrompt = false;
      notifyListeners();
      _persistDraft();
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex -= 1;
      notifyListeners();
      _persistDraft();
      return;
    }

    _selectedVariant = null;
    _includeConstraints = false;
    _isRefineResolved = false;
    notifyListeners();
    _persistDraft();
  }

  Future<bool> goNext() async {
    if (!canGoNext) {
      return false;
    }

    final question = currentQuestion;
    if (question == null) {
      return false;
    }

    if (isLastQuestion) {
      return _generatePlan();
    }

    _currentIndex += 1;
    notifyListeners();
    _persistDraft();
    return false;
  }

  void acceptRefine() {
    _showRefinePrompt = false;
    _isRefineResolved = true;
    _includeConstraints = false;
    notifyListeners();
    _persistDraft();
  }

  Future<bool> skipRefine() async {
    _showRefinePrompt = false;
    _isRefineResolved = true;
    _includeConstraints = false;
    _removeAnswer('constraints');
    notifyListeners();
    _persistDraft();
    return _generatePlan();
  }

  Future<bool> skipOptionalQuestion() async {
    final question = currentQuestion;
    if (question == null || !question.isOptional) {
      return false;
    }

    _setAnswer(question.id, const []);
    return _generatePlan();
  }

  Future<void> saveGeneratedPlan() async {
    final plan = _generatedPlan;
    if (plan == null) {
      return;
    }

    _setSavingPlan(true);
    try {
      await _migrationPlanRepository.savePlan(plan);
      _savedPlans = await _migrationPlanRepository.getSavedPlans();
      notifyListeners();
    } finally {
      _setSavingPlan(false);
    }
  }

  Future<void> confirmPlanCity(City city) async {
    final plan = _generatedPlan;
    if (plan == null) {
      return;
    }

    _generatedPlan = plan.copyWith(
      recommendedCity: city,
      isCityConfirmed: true,
    );
    notifyListeners();
    await _migrationPlanRepository.setCurrentPlan(_generatedPlan);
  }

  void _setInitializing(bool value) {
    _isInitializing = value;
    notifyListeners();
  }

  void _setGeneratingPlan(bool value) {
    _isGeneratingPlan = value;
    notifyListeners();
  }

  void _setSavingPlan(bool value) {
    _isSavingPlan = value;
    notifyListeners();
  }

  Future<bool> _generatePlan() async {
    _syncJourneyAnswers();
    if (!_journeyContextController.isJourneyReadyForPlanning ||
        answerFor('origin_country') == null ||
        answerFor('destination_country') == null) {
      notifyListeners();
      return false;
    }

    _setGeneratingPlan(true);
    try {
      _generatedPlan = await _planGenerator.generate(
        answers: _answers,
        variant: _selectedVariant ?? QuestionnaireVariant.lean,
      );
      await _migrationPlanRepository.setCurrentPlan(_generatedPlan);
      await _flowDraftStore.clear();
      notifyListeners();
      return true;
    } finally {
      _setGeneratingPlan(false);
    }
  }

  void _setAnswer(String questionId, List<String> values) {
    final nextAnswers = List<Answer>.from(_answers);
    final existingIndex = nextAnswers.indexWhere(
      (answer) => answer.questionId == questionId,
    );

    if (values.isEmpty) {
      if (existingIndex != -1) {
        nextAnswers.removeAt(existingIndex);
      }
      _answers = nextAnswers;
      notifyListeners();
      _persistDraft();
      return;
    }

    final answer = Answer(questionId: questionId, values: values);

    if (existingIndex == -1) {
      nextAnswers.add(answer);
    } else {
      nextAnswers[existingIndex] = answer;
    }

    _answers = nextAnswers;
    notifyListeners();
    _persistDraft();
  }

  void _removeAnswer(String questionId) {
    _answers = _answers
        .where((answer) => answer.questionId != questionId)
        .toList(growable: false);
  }

  void _syncJourneySelection(String questionId, List<String> values) {
    if (questionId != 'origin_country' || values.isEmpty) {
      return;
    }

    final destinationCountryId = _journeyContextController.destinationCountryId;
    final originCountryId = _resolveCountryId(values.first);
    if (destinationCountryId == null || originCountryId == null) {
      return;
    }

    unawaited(
      _journeyContextController.completeJourney(
        originCountryId: originCountryId,
        destinationCountryId: destinationCountryId,
      ),
    );
    _syncJourneyAnswers();
    notifyListeners();
    _persistDraft();
  }

  void _syncJourneyAnswers() {
    final nextAnswers = _answers
        .where(
          (answer) =>
              answer.questionId != 'origin_country' &&
              answer.questionId != 'destination_country',
        )
        .toList();

    final originValue = _journeyContextController.journeyValueFor(
      _journeyContextController.selectedOrigin,
    );
    final destinationValue = _journeyContextController.journeyValueFor(
      _journeyContextController.selectedDestination,
    );

    if (originValue.isNotEmpty) {
      nextAnswers.add(
        Answer(questionId: 'origin_country', values: [originValue]),
      );
    }

    if (destinationValue.isNotEmpty) {
      nextAnswers.add(
        Answer(questionId: 'destination_country', values: [destinationValue]),
      );
    }

    _answers = nextAnswers;
  }

  String? _resolveCountryId(String value) {
    for (final country in _journeyContextController.countries) {
      if (country.id == value ||
          _journeyContextController.journeyValueFor(country) == value) {
        return country.id;
      }
    }

    return null;
  }

  void _restoreDraft(QuestionnaireFlowDraftSnapshot? draft) {
    if (draft == null) {
      return;
    }

    _answers = draft.answers;
    _selectedVariant = QuestionnaireVariantX.fromId(draft.selectedVariantId);
    _showRefinePrompt = draft.showRefinePrompt;
    _isRefineResolved = draft.isRefineResolved;
    _includeConstraints = draft.includeConstraints;
    _currentIndex = draft.currentIndex;
  }

  void _clampCurrentIndex() {
    final activeQuestions = _activeQuestions;
    if (activeQuestions.isEmpty) {
      _currentIndex = 0;
      return;
    }

    final maxIndex = activeQuestions.length - 1;
    if (_currentIndex > maxIndex) {
      _currentIndex = maxIndex;
    }
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
  }

  void _persistDraft() {
    if (_generatedPlan != null) {
      return;
    }

    unawaited(
      _flowDraftStore.write(
        answers: _answers,
        currentIndex: _currentIndex,
        selectedVariantId: _selectedVariant?.id,
        showRefinePrompt: _showRefinePrompt,
        isRefineResolved: _isRefineResolved,
        includeConstraints: _includeConstraints,
      ),
    );
  }
}

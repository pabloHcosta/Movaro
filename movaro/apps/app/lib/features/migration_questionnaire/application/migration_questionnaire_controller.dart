import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/latest_migration_plan_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/migration_plan_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/question_repository.dart';

class MigrationQuestionnaireController extends ChangeNotifier {
  MigrationQuestionnaireController({
    required QuestionRepository questionRepository,
    required MigrationPlanRepository migrationPlanRepository,
    required MigrationPlanGenerator planGenerator,
    required JourneyContextController journeyContextController,
    LatestMigrationPlanStore? latestPlanStore,
  }) : _questionRepository = questionRepository,
       _migrationPlanRepository = migrationPlanRepository,
       _planGenerator = planGenerator,
       _journeyContextController = journeyContextController,
       _latestPlanStore = latestPlanStore ?? LatestMigrationPlanStore();

  final QuestionRepository _questionRepository;
  final MigrationPlanRepository _migrationPlanRepository;
  final MigrationPlanGenerator _planGenerator;
  final JourneyContextController _journeyContextController;
  final LatestMigrationPlanStore _latestPlanStore;

  List<Question> _questions = const [];
  List<Answer> _answers = const [];
  List<MigrationPlan> _savedPlans = const [];
  MigrationPlan? _generatedPlan;
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isGeneratingPlan = false;
  bool _isSavingPlan = false;

  List<Question> get questions => _questions;
  List<Answer> get answers => _answers;
  List<MigrationPlan> get savedPlans => _savedPlans;
  MigrationPlan? get generatedPlan => _generatedPlan;
  int get currentIndex => _currentIndex;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isInitializing || _isGeneratingPlan || _isSavingPlan;
  bool get isInitializing => _isInitializing;
  bool get isGeneratingPlan => _isGeneratingPlan;
  bool get isSavingPlan => _isSavingPlan;

  Question? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];

  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  Future<void> initialize() async {
    if (_isInitialized) {
      _syncJourneyAnswers();
      notifyListeners();
      return;
    }

    _setInitializing(true);
    try {
      _questions = await _questionRepository.getQuestions();
      _syncJourneyAnswers();
      _savedPlans = await _migrationPlanRepository.getSavedPlans();
      _generatedPlan = await _latestPlanStore.read();
      _isInitialized = true;
      notifyListeners();
    } finally {
      _setInitializing(false);
    }
  }

  void resetFlow() {
    _answers = const [];
    _syncJourneyAnswers();
    _generatedPlan = null;
    _currentIndex = 0;
    notifyListeners();
  }

  void selectAnswer(String questionId, String value) {
    final nextAnswers = List<Answer>.from(_answers);
    final existingIndex = nextAnswers.indexWhere(
      (answer) => answer.questionId == questionId,
    );

    final answer = Answer(questionId: questionId, value: value);

    if (existingIndex == -1) {
      nextAnswers.add(answer);
    } else {
      nextAnswers[existingIndex] = answer;
    }

    _answers = nextAnswers;
    notifyListeners();
  }

  String? answerFor(String questionId) {
    final match = _answers.where((answer) => answer.questionId == questionId);
    if (match.isEmpty) {
      return null;
    }

    return match.first.value;
  }

  bool get canGoBack => _currentIndex > 0;

  bool get canGoNext {
    final question = currentQuestion;
    if (question == null) {
      return false;
    }

    return answerFor(question.id) != null;
  }

  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentIndex == _questions.length - 1;

  void goBack() {
    if (!canGoBack) {
      return;
    }

    _currentIndex -= 1;
    notifyListeners();
  }

  Future<bool> goNext() async {
    if (!canGoNext) {
      return false;
    }

    if (isLastQuestion) {
      _setGeneratingPlan(true);
      try {
        _generatedPlan = await _planGenerator.generate(answers: _answers);
        await _latestPlanStore.write(_generatedPlan!);
        notifyListeners();
        return true;
      } finally {
        _setGeneratingPlan(false);
      }
    }

    _currentIndex += 1;
    notifyListeners();
    return false;
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

    _generatedPlan = plan.copyWith(recommendedCity: city, isCityConfirmed: true);
    notifyListeners();
    await _latestPlanStore.write(_generatedPlan!);
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
      nextAnswers.add(Answer(questionId: 'origin_country', value: originValue));
    }

    if (destinationValue.isNotEmpty) {
      nextAnswers.add(
        Answer(questionId: 'destination_country', value: destinationValue),
      );
    }

    _answers = nextAnswers;
  }
}

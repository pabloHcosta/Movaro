import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/option_model.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/question_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  const QuestionRepositoryImpl({
    required CatalogRepository catalogRepository,
    required JourneyContextController journeyContextController,
  })
    : _catalogRepository = catalogRepository,
      _journeyContextController = journeyContextController;

  final CatalogRepository _catalogRepository;
  final JourneyContextController _journeyContextController;

  @override
  Future<List<Question>> getQuestions() async {
    await _catalogRepository.getCountries();

    if (!_journeyContextController.hasSelectedJourney) {
      return const [];
    }

    return [
      QuestionModel(
        id: 'goal',
        title: 'goal',
        type: 'single_choice',
        options: const [
          OptionModel(
            id: 'quality_of_life',
            label: 'quality_of_life',
            value: 'quality_of_life',
          ),
          OptionModel(
            id: 'beach_life',
            label: 'beach_life',
            value: 'beach_life',
          ),
          OptionModel(id: 'work', label: 'work', value: 'work'),
          OptionModel(
            id: 'remote_work',
            label: 'remote_work',
            value: 'remote_work',
          ),
          OptionModel(id: 'study', label: 'study', value: 'study'),
          OptionModel(
            id: 'entrepreneur',
            label: 'entrepreneur',
            value: 'entrepreneur',
          ),
          OptionModel(id: 'retire', label: 'retire', value: 'retire'),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'portuguese_familiarity',
        title: 'portuguese_familiarity',
        type: 'single_choice',
        options: const [
          OptionModel(
            id: 'no_portuguese',
            label: 'no_portuguese',
            value: 'no_portuguese',
          ),
          OptionModel(
            id: 'basic_portuguese',
            label: 'basic_portuguese',
            value: 'basic_portuguese',
          ),
          OptionModel(
            id: 'comfortable_portuguese',
            label: 'comfortable_portuguese',
            value: 'comfortable_portuguese',
          ),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'timeline',
        title: 'timeline',
        type: 'single_choice',
        options: const [
          OptionModel(
            id: 'researching',
            label: 'researching',
            value: 'researching',
          ),
          OptionModel(id: '6_months', label: '6_months', value: '6_months'),
          OptionModel(id: 'asap', label: 'asap', value: 'asap'),
          OptionModel(id: '12_months', label: '12_months', value: '12_months'),
        ],
      ).toEntity(),
    ];
  }
}

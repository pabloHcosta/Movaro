import 'package:mudavi_app/features/migration_questionnaire/domain/entities/question.dart';

abstract class QuestionRepository {
  Future<List<Question>> getQuestions();
}

import 'package:movaro_app/features/migration_questionnaire/data/models/option_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
  });

  final String id;
  final String title;
  final String type;
  final List<OptionModel> options;

  Question toEntity() => Question(
    id: id,
    title: title,
    type: type,
    options: options.map((option) => option.toEntity()).toList(),
  );
}

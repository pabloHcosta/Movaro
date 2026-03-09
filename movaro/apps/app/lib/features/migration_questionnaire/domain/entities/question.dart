import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';

class Question {
  const Question({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
  });

  final String id;
  final String title;
  final String type;
  final List<Option> options;
}

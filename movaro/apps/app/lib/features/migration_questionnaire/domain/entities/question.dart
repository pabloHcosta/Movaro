import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

class Question {
  const Question({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    this.maxSelections = 1,
    this.isOptional = false,
    this.variants = QuestionnaireVariant.values,
  });

  final String id;
  final String title;
  final String type;
  final List<Option> options;
  final int maxSelections;
  final bool isOptional;
  final List<QuestionnaireVariant> variants;
}

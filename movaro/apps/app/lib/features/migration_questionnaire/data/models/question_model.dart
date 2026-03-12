import 'package:movaro_app/features/migration_questionnaire/data/models/option_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

class QuestionModel {
  const QuestionModel({
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
  final List<OptionModel> options;
  final int maxSelections;
  final bool isOptional;
  final List<QuestionnaireVariant> variants;

  Question toEntity() => Question(
    id: id,
    title: title,
    type: type,
    options: options.map((option) => option.toEntity()).toList(),
    maxSelections: maxSelections,
    isOptional: isOptional,
    variants: variants,
  );
}

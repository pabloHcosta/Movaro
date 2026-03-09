import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_step.dart';

class MigrationStepModel {
  const MigrationStepModel({
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedDays,
  });

  factory MigrationStepModel.fromJson(Map<String, dynamic> json) {
    return MigrationStepModel(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      estimatedDays: json['estimatedDays'] as int,
    );
  }

  final String title;
  final String description;
  final String category;
  final int estimatedDays;

  factory MigrationStepModel.fromEntity(MigrationStep step) {
    return MigrationStepModel(
      title: step.title,
      description: step.description,
      category: step.category,
      estimatedDays: step.estimatedDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'estimatedDays': estimatedDays,
  };

  MigrationStep toEntity() => MigrationStep(
    title: title,
    description: description,
    category: category,
    estimatedDays: estimatedDays,
  );
}

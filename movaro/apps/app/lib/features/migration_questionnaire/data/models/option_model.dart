import 'package:movaro_app/features/migration_questionnaire/domain/entities/option.dart';

class OptionModel {
  const OptionModel({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  Option toEntity() => Option(id: id, label: label, value: value);
}

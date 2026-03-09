import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';

class CityMethodologyModel {
  const CityMethodologyModel({
    required this.principles,
    required this.formulas,
    required this.note,
  });

  factory CityMethodologyModel.fromJson(Map<String, dynamic> json) {
    return CityMethodologyModel(
      principles: (json['principles'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      formulas: (json['formulas'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as String),
      ),
      note: json['note'] as String,
    );
  }

  final List<String> principles;
  final Map<String, String> formulas;
  final String note;

  CityMethodology toEntity() =>
      CityMethodology(principles: principles, formulas: formulas, note: note);
}

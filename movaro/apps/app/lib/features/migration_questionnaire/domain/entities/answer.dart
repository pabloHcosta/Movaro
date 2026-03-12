class Answer {
  const Answer({required this.questionId, required this.values});

  final String questionId;
  final List<String> values;

  String? get primaryValue => values.isEmpty ? null : values.first;
}

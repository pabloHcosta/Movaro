class MigrationStep {
  const MigrationStep({
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedDays,
  });

  final String title;
  final String description;
  final String category;
  final int estimatedDays;
}

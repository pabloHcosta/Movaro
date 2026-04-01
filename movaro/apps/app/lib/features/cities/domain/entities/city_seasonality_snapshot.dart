enum CitySeasonalitySeverity { high, medium }

class CitySeasonalitySnapshot {
  const CitySeasonalitySnapshot({
    required this.peakMonths,
    required this.lowMonths,
    required this.severity,
    required this.visitorsLabelPt,
    required this.visitorsLabelEs,
    required this.visitorsLabelEn,
    required this.rentNotesPt,
    required this.rentNotesEs,
    required this.rentNotesEn,
    required this.jobNotesPt,
    required this.jobNotesEs,
    required this.jobNotesEn,
    required this.updatedAt,
    required this.sourceLabel,
    required this.sourceType,
    this.populationMultiplierNote,
    this.sourceUrl,
  });

  final List<int> peakMonths;
  final List<int> lowMonths;
  final CitySeasonalitySeverity severity;
  final String visitorsLabelPt;
  final String visitorsLabelEs;
  final String visitorsLabelEn;
  final String rentNotesPt;
  final String rentNotesEs;
  final String rentNotesEn;
  final String jobNotesPt;
  final String jobNotesEs;
  final String jobNotesEn;
  final String? populationMultiplierNote;
  final String updatedAt;
  final String sourceLabel;
  final String? sourceUrl;
  final String sourceType;

  String visitorsLabel(String locale) => switch (locale) {
        'pt' => visitorsLabelPt,
        'es' => visitorsLabelEs,
        _ => visitorsLabelEn,
      };

  String rentNotes(String locale) => switch (locale) {
        'pt' => rentNotesPt,
        'es' => rentNotesEs,
        _ => rentNotesEn,
      };

  String jobNotes(String locale) => switch (locale) {
        'pt' => jobNotesPt,
        'es' => jobNotesEs,
        _ => jobNotesEn,
      };
}

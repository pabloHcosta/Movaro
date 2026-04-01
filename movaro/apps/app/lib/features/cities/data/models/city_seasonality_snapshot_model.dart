import 'package:movaro_app/features/cities/domain/entities/city_seasonality_snapshot.dart';

class CitySeasonalitySnapshotModel {
  const CitySeasonalitySnapshotModel({
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

  factory CitySeasonalitySnapshotModel.fromJson(Map<String, dynamic> json) {
    return CitySeasonalitySnapshotModel(
      peakMonths: (json['peakMonths'] as List<dynamic>).cast<int>(),
      lowMonths: (json['lowMonths'] as List<dynamic>).cast<int>(),
      severity: (json['severity'] as String) == 'high'
          ? CitySeasonalitySeverity.high
          : CitySeasonalitySeverity.medium,
      visitorsLabelPt: json['visitorsLabelPt'] as String,
      visitorsLabelEs: json['visitorsLabelEs'] as String,
      visitorsLabelEn: json['visitorsLabelEn'] as String,
      rentNotesPt: json['rentNotesPt'] as String,
      rentNotesEs: json['rentNotesEs'] as String,
      rentNotesEn: json['rentNotesEn'] as String,
      jobNotesPt: json['jobNotesPt'] as String,
      jobNotesEs: json['jobNotesEs'] as String,
      jobNotesEn: json['jobNotesEn'] as String,
      populationMultiplierNote: json['populationMultiplierNote'] as String?,
      updatedAt: json['updatedAt'] as String,
      sourceLabel: json['sourceLabel'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      sourceType: (json['sourceType'] as String?) ?? 'curated',
    );
  }

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

  CitySeasonalitySnapshot toEntity() => CitySeasonalitySnapshot(
    peakMonths: peakMonths,
    lowMonths: lowMonths,
    severity: severity,
    visitorsLabelPt: visitorsLabelPt,
    visitorsLabelEs: visitorsLabelEs,
    visitorsLabelEn: visitorsLabelEn,
    rentNotesPt: rentNotesPt,
    rentNotesEs: rentNotesEs,
    rentNotesEn: rentNotesEn,
    jobNotesPt: jobNotesPt,
    jobNotesEs: jobNotesEs,
    jobNotesEn: jobNotesEn,
    populationMultiplierNote: populationMultiplierNote,
    updatedAt: updatedAt,
    sourceLabel: sourceLabel,
    sourceUrl: sourceUrl,
    sourceType: sourceType,
  );
}

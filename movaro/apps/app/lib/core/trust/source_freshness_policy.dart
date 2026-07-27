import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';

enum SourceFreshnessStatus { current, reviewSoon, stale, invalidFutureDate }

class SourceFreshnessAssessment {
  const SourceFreshnessAssessment({
    required this.status,
    required this.age,
    required this.reviewAfter,
  });

  final SourceFreshnessStatus status;
  final Duration age;
  final Duration reviewAfter;

  bool get requiresWarning =>
      status == SourceFreshnessStatus.stale ||
      status == SourceFreshnessStatus.invalidFutureDate;
}

/// Central review policy for claims shown as practical guidance.
///
/// It intentionally does not hide stale guidance: legal and migration steps
/// can still be useful as orientation. Instead, presentation surfaces must
/// warn users and lead with the original source.
class SourceFreshnessPolicy {
  const SourceFreshnessPolicy._();

  static SourceFreshnessAssessment assessEvidence(
    GuideEvidence evidence, {
    DateTime? now,
  }) {
    return assess(
      lastVerified: evidence.lastVerified,
      reviewAfter: reviewWindow(evidence.type),
      now: now,
    );
  }

  static SourceFreshnessAssessment assess({
    required DateTime lastVerified,
    required Duration reviewAfter,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final age = today.difference(lastVerified);
    if (age < const Duration(days: -1)) {
      return SourceFreshnessAssessment(
        status: SourceFreshnessStatus.invalidFutureDate,
        age: age,
        reviewAfter: reviewAfter,
      );
    }
    if (age > reviewAfter) {
      return SourceFreshnessAssessment(
        status: SourceFreshnessStatus.stale,
        age: age,
        reviewAfter: reviewAfter,
      );
    }
    final reviewSoonAt = Duration(
      milliseconds: (reviewAfter.inMilliseconds * 0.8).round(),
    );
    return SourceFreshnessAssessment(
      status: age >= reviewSoonAt
          ? SourceFreshnessStatus.reviewSoon
          : SourceFreshnessStatus.current,
      age: age,
      reviewAfter: reviewAfter,
    );
  }

  static Duration reviewWindow(GuideEvidenceType type) => switch (type) {
    GuideEvidenceType.official => const Duration(days: 90),
    GuideEvidenceType.derived => const Duration(days: 30),
    GuideEvidenceType.marketReference => const Duration(days: 14),
    GuideEvidenceType.movaroGuidance => const Duration(days: 180),
  };

  static DateTime? parseCurationDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }
}

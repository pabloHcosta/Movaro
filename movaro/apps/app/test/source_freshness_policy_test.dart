import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/core/trust/source_freshness_policy.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';

void main() {
  test('market references expire faster than official rules', () {
    final checked = DateTime(2026, 1, 1);
    final now = DateTime(2026, 2, 1);

    final market = SourceFreshnessPolicy.assess(
      lastVerified: checked,
      reviewAfter: SourceFreshnessPolicy.reviewWindow(
        GuideEvidenceType.marketReference,
      ),
      now: now,
    );
    final official = SourceFreshnessPolicy.assess(
      lastVerified: checked,
      reviewAfter: SourceFreshnessPolicy.reviewWindow(
        GuideEvidenceType.official,
      ),
      now: now,
    );

    expect(market.status, SourceFreshnessStatus.stale);
    expect(official.status, SourceFreshnessStatus.current);
  });

  test('future verification dates are rejected', () {
    final result = SourceFreshnessPolicy.assess(
      lastVerified: DateTime(2026, 8, 1),
      reviewAfter: const Duration(days: 90),
      now: DateTime(2026, 7, 1),
    );

    expect(result.status, SourceFreshnessStatus.invalidFutureDate);
    expect(result.requiresWarning, isTrue);
  });
}

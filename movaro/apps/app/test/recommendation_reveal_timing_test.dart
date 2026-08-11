import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/recommendation_reveal_timing.dart';

void main() {
  test('keeps the standard reveal visible for at least 2.6 seconds', () {
    expect(
      RecommendationRevealTiming.remaining(
        elapsed: const Duration(milliseconds: 400),
        reduceMotion: false,
      ),
      const Duration(milliseconds: 2200),
    );
  });

  test('does not add delay after a slow generation', () {
    expect(
      RecommendationRevealTiming.remaining(
        elapsed: const Duration(seconds: 4),
        reduceMotion: false,
      ),
      Duration.zero,
    );
  });

  test('uses a shorter minimum when motion is reduced', () {
    expect(
      RecommendationRevealTiming.remaining(
        elapsed: const Duration(milliseconds: 500),
        reduceMotion: true,
      ),
      const Duration(milliseconds: 700),
    );
  });
}

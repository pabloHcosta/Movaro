abstract final class RecommendationRevealTiming {
  static const standardMinimum = Duration(milliseconds: 2600);
  static const reducedMotionMinimum = Duration(milliseconds: 1200);

  static Duration minimum({required bool reduceMotion}) {
    return reduceMotion ? reducedMotionMinimum : standardMinimum;
  }

  static Duration remaining({
    required Duration elapsed,
    required bool reduceMotion,
  }) {
    final difference = minimum(reduceMotion: reduceMotion) - elapsed;
    return difference.isNegative ? Duration.zero : difference;
  }
}

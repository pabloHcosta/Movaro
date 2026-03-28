/// Represents the user's current migration journey stage.
///
/// Drives home layout, content tone, and which features surface prominently.
enum UserJourneyStage {
  /// User is exploring options — has not committed to a city or timeline.
  /// Home should inspire and answer "is this realistic for me?"
  explorer,

  /// User has a plan but is not yet in active execution mode (3-12 months out).
  /// Home should orient and build confidence around the plan.
  planner,

  /// User is in active execution mode (0-3 months, or has completed ≥1 step).
  /// Home should drive urgency, show next action, surface blockers.
  executor,
}

class UserJourneyStageDetector {
  const UserJourneyStageDetector._();

  /// Derives the journey stage from the plan timeline and completion state.
  static UserJourneyStage detect({
    required String? timeline,
    required int completedSteps,
    required int totalSteps,
  }) {
    if (timeline == null) return UserJourneyStage.explorer;

    // Any completed step signals active execution regardless of timeline.
    if (completedSteps > 0) return UserJourneyStage.executor;

    return switch (timeline) {
      'in_0_3m' => UserJourneyStage.executor,
      'in_3_6m' => UserJourneyStage.planner,
      'in_6_12m' => UserJourneyStage.planner,
      _ => UserJourneyStage.explorer, // 'later', 'undecided', unknown
    };
  }
}

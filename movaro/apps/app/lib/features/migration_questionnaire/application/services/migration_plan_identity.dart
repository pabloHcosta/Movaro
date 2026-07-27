import 'dart:convert';
import 'dart:math';

import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

/// Gives each generated plan its own persistence boundary.
///
/// Older plans did not have an id, so [storageKeyFor] keeps a deterministic
/// fallback for backward compatibility. Every newly generated plan receives a
/// random id and can never inherit progress from another plan by accident.
class MigrationPlanIdentity {
  const MigrationPlanIdentity._();

  static String generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(18, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String storageKeyFor(MigrationPlan plan) {
    final planId = plan.id?.trim();
    if (planId != null && planId.isNotEmpty) {
      return 'plan::$planId';
    }

    return [
      'legacy',
      plan.originCountry,
      plan.destinationCountry,
      plan.goal,
      plan.timeline,
      plan.currentPlanCity?.id ?? 'no-city',
    ].join('::');
  }
}

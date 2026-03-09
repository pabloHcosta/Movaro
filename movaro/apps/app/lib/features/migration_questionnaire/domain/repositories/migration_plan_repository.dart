import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

abstract class MigrationPlanRepository {
  Future<void> savePlan(MigrationPlan plan);

  Future<List<MigrationPlan>> getSavedPlans();
}

import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

abstract class MigrationPlanRepository {
  Future<MigrationPlan?> getCurrentPlan();

  Future<void> setCurrentPlan(MigrationPlan? plan);

  Future<void> savePlan(MigrationPlan plan);

  Future<List<MigrationPlan>> getSavedPlans();
}

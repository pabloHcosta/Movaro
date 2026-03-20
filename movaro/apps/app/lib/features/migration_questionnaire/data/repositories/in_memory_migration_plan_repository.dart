import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/migration_plan_repository.dart';

class InMemoryMigrationPlanRepository implements MigrationPlanRepository {
  final List<MigrationPlan> _savedPlans = [];
  MigrationPlan? _currentPlan;

  @override
  Future<MigrationPlan?> getCurrentPlan() async {
    return _currentPlan;
  }

  @override
  Future<void> setCurrentPlan(MigrationPlan? plan) async {
    _currentPlan = plan;
  }

  @override
  Future<List<MigrationPlan>> getSavedPlans() async {
    return List<MigrationPlan>.unmodifiable(_savedPlans);
  }

  @override
  Future<void> savePlan(MigrationPlan plan) async {
    _savedPlans.add(plan);
  }
}

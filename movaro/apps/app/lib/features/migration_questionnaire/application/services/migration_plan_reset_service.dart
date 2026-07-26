import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/latest_migration_plan_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';

/// Clears data that belongs to the previous plan without touching global
/// preferences such as language, currency, favorites, or the confirmed origin.
class MigrationPlanResetService {
  MigrationPlanResetService({
    required MigrationCopilotProgressStore copilotProgressStore,
    GuideEventSuggestionStore? eventSuggestionStore,
    LatestMigrationPlanStore? latestPlanStore,
  }) : _copilotProgressStore = copilotProgressStore,
       _eventSuggestionStore =
           eventSuggestionStore ?? GuideEventSuggestionStore(),
       _latestPlanStore = latestPlanStore ?? LatestMigrationPlanStore();

  final MigrationCopilotProgressStore _copilotProgressStore;
  final GuideEventSuggestionStore _eventSuggestionStore;
  final LatestMigrationPlanStore _latestPlanStore;

  Future<void> clearPreviousPlanData() async {
    await Future.wait<void>([
      _copilotProgressStore.clear(),
      _eventSuggestionStore.clear(),
      _latestPlanStore.clear(),
    ]);
    await PlanNotificationService.instance.cancelPlanReminders();
    await PlanNotificationService.instance.cancelPFReminder();
  }
}

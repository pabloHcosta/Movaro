import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/latest_migration_plan_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

/// Clears data that belongs to the previous plan without touching global
/// preferences such as language, currency, favorites, or the confirmed origin.
class MigrationPlanResetService {
  /// Tasks whose result belongs to the selected city, rather than to the
  /// person. Documents such as CPF, antecedentes and RNM deliberately stay
  /// outside this set and survive a city change.
  static const cityScopedTaskIds = <String>{
    'item_0_3_budget',
    'item_0_4_flight',
    'item_0_5_mercado_trabalho',
    'item_1_2_housing_temporary',
    'item_3_2_aluguel_fixo',
    'item_3_4_trabalho',
    'item_3_6_familia_escola',
    'item_4_7_seguranca_emergencia',
    'item_4_8_revisao_custo_real',
    'item_4_9_reavaliar_bairro',
  };

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

  Future<void> retainTransferableProgressForCityChange(
    MigrationPlan plan,
  ) async {
    final snapshot = await _copilotProgressStore.read(plan);
    bool transferable(String id) => !cityScopedTaskIds.contains(id);

    await _copilotProgressStore.write(
      plan: plan,
      readinessCompletedIds: snapshot.readinessCompletedIds
          .where(transferable)
          .toSet(),
      documentCompletedIds: snapshot.documentCompletedIds
          .where(transferable)
          .toSet(),
      arrivalCompletedIds: snapshot.arrivalCompletedIds
          .where(transferable)
          .toSet(),
      activeItemId:
          snapshot.activeItemId != null && transferable(snapshot.activeItemId!)
          ? snapshot.activeItemId
          : null,
      completedAtById: Map<String, String>.fromEntries(
        snapshot.completedAtById.entries.where(
          (entry) => transferable(entry.key),
        ),
      ),
      prioritizedItemIds: snapshot.prioritizedItemIds
          .where(transferable)
          .toSet(),
      dismissedReasonsById: Map<String, GuideDismissReason>.fromEntries(
        snapshot.dismissedReasonsById.entries.where(
          (entry) => transferable(entry.key),
        ),
      ),
      taskStatesById: Map<String, GuideTaskState>.fromEntries(
        snapshot.taskStatesById.entries.where(
          (entry) => transferable(entry.key),
        ),
      ),
      taskDecisionDataById: Map<String, Map<String, dynamic>>.fromEntries(
        snapshot.taskDecisionDataById.entries.where(
          (entry) => transferable(entry.key),
        ),
      ),
    );
  }

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

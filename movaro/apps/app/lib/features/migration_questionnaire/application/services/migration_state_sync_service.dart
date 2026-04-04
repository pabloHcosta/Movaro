import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/storage/local_installation_id_store.dart';
import 'package:movaro_app/features/journey/journey_preferences_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/questionnaire_flow_draft_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/repositories/local_migration_plan_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MigrationStateSyncService implements MigrationSyncScheduler {
  MigrationStateSyncService({
    required bool enabled,
    required LocalMigrationPlanRepository migrationPlanRepository,
    required QuestionnaireFlowDraftStore flowDraftStore,
    required JourneyPreferencesStore journeyPreferencesStore,
    required MigrationCopilotProgressStore copilotProgressStore,
    LocalInstallationIdStore? installationIdStore,
  }) : _enabled = enabled,
       _migrationPlanRepository = migrationPlanRepository,
       _flowDraftStore = flowDraftStore,
       _journeyPreferencesStore = journeyPreferencesStore,
       _copilotProgressStore = copilotProgressStore,
       _installationIdStore = installationIdStore ?? LocalInstallationIdStore();

  static const String _tableName = 'app_state_snapshots';
  static const String _scope = 'migration';
  static const Duration _debounce = Duration(milliseconds: 900);
  static const Duration _networkRetryCooldown = Duration(minutes: 1);

  final bool _enabled;
  final LocalMigrationPlanRepository _migrationPlanRepository;
  final QuestionnaireFlowDraftStore _flowDraftStore;
  final JourneyPreferencesStore _journeyPreferencesStore;
  final MigrationCopilotProgressStore _copilotProgressStore;
  final LocalInstallationIdStore _installationIdStore;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isAuthUnavailable = false;
  bool _hasLoggedAuthUnavailable = false;
  DateTime? _networkRetryNotBefore;

  bool get _isAvailable => _enabled && !_isNetworkRetryCooldownActive;
  SupabaseClient get _client => Supabase.instance.client;
  bool get _isNetworkRetryCooldownActive {
    final retryAt = _networkRetryNotBefore;
    if (retryAt == null) {
      return false;
    }

    if (DateTime.now().isAfter(retryAt)) {
      _networkRetryNotBefore = null;
      return false;
    }

    return true;
  }

  @override
  void scheduleSync() {
    if (!_isAvailable || _isAuthUnavailable) {
      return;
    }

    _syncTimer?.cancel();
    _syncTimer = Timer(_debounce, () {
      unawaited(syncNow());
    });
  }

  Future<void> restoreIfNeeded() async {
    if (!_isAvailable || _isAuthUnavailable) {
      return;
    }

    try {
      if (await _hasMeaningfulLocalData()) {
        return;
      }

      await _ensureAnonymousSession();
      final userId = _client.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final response = await _client
          .from(_tableName)
          .select('payload')
          .eq('user_id', userId)
          .eq('scope', _scope)
          .maybeSingle();

      if (response is! Map<String, dynamic>) {
        return;
      }

      final payload = response['payload'];
      if (payload is! Map<String, dynamic>) {
        return;
      }

      await MigrationStateSyncCoordinator.suspend(() async {
        await _applySnapshot(payload);
      });
    } catch (error, stackTrace) {
      if (_handleTransientSyncFailure(error)) {
        return;
      }

      debugPrint('MigrationStateSyncService.restoreIfNeeded failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> syncNow() async {
    if (!_isAvailable || _isSyncing || _isAuthUnavailable) {
      return;
    }

    _syncTimer?.cancel();
    _syncTimer = null;
    _isSyncing = true;

    try {
      await _ensureAnonymousSession();
      final userId = _client.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        return;
      }

      if (!await _hasMeaningfulLocalData()) {
        await _client
            .from(_tableName)
            .delete()
            .eq('user_id', userId)
            .eq('scope', _scope);
        return;
      }

      final installationId = await _installationIdStore.getOrCreate();
      final payload = await _buildSnapshotPayload();

      await _client.from(_tableName).upsert(<String, dynamic>{
        'user_id': userId,
        'scope': _scope,
        'installation_id': installationId,
        'payload': payload,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,scope');
    } catch (error, stackTrace) {
      if (_handleTransientSyncFailure(error)) {
        return;
      }

      debugPrint('MigrationStateSyncService.syncNow failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _ensureAnonymousSession() async {
    final session = _client.auth.currentSession;
    if (session != null && session.user.id.isNotEmpty) {
      return;
    }

    try {
      await _client.auth.signInAnonymously();
    } on AuthRetryableFetchException catch (error) {
      _handleTransientSyncFailure(error);
      return;
    } on AuthApiException catch (error) {
      if (error.code == 'anonymous_provider_disabled') {
        _isAuthUnavailable = true;
        if (!_hasLoggedAuthUnavailable) {
          _hasLoggedAuthUnavailable = true;
          debugPrint(
            'MigrationStateSyncService disabled: Supabase anonymous sign-ins are disabled for this project.',
          );
        }
        return;
      }
      rethrow;
    }
  }

  bool _handleTransientSyncFailure(Object error) {
    if (!_isTransientNetworkError(error)) {
      return false;
    }

    final retryAt = DateTime.now().add(_networkRetryCooldown);
    final shouldLog =
        _networkRetryNotBefore == null ||
        retryAt.isAfter(_networkRetryNotBefore!);
    _networkRetryNotBefore = retryAt;
    _syncTimer?.cancel();
    _syncTimer = null;

    if (shouldLog) {
      debugPrint(
        'MigrationStateSyncService paused: Supabase is temporarily unreachable. Retrying after ${_networkRetryCooldown.inMinutes} minute(s).',
      );
    }

    return true;
  }

  bool _isTransientNetworkError(Object error) {
    if (error is AuthRetryableFetchException) {
      return true;
    }

    final message = error.toString();
    return message.contains('SocketException') ||
        message.contains('ClientException') ||
        message.contains('Failed host lookup');
  }

  Future<bool> _hasMeaningfulLocalData() async {
    final hasPlanData = await _migrationPlanRepository.hasLocalData();
    final hasDraftData = await _flowDraftStore.hasLocalData();
    final hasJourneyData = await _journeyPreferencesStore.hasLocalData();
    final hasProgressData = await _copilotProgressStore.hasLocalData();
    return hasPlanData || hasDraftData || hasJourneyData || hasProgressData;
  }

  Future<Map<String, dynamic>> _buildSnapshotPayload() async {
    return <String, dynamic>{
      'schemaVersion': 1,
      'syncedAt': DateTime.now().toUtc().toIso8601String(),
      'journey': await _journeyPreferencesStore.read(),
      'migrationPlans': await _migrationPlanRepository.exportState(),
      'questionnaireDraft': await _flowDraftStore.exportState(),
      'copilotProgress': await _copilotProgressStore.exportState(),
    };
  }

  Future<void> _applySnapshot(Map<String, dynamic> payload) async {
    final journey = payload['journey'];
    final migrationPlans = payload['migrationPlans'];
    final questionnaireDraft = payload['questionnaireDraft'];
    final copilotProgress = payload['copilotProgress'];

    if (journey is Map<String, dynamic>) {
      await _journeyPreferencesStore.write(journey);
    }

    if (migrationPlans is Map<String, dynamic>) {
      await _migrationPlanRepository.importState(migrationPlans);
    }

    if (questionnaireDraft is Map<String, dynamic>) {
      await _flowDraftStore.importState(questionnaireDraft);
    }

    if (copilotProgress is Map<String, dynamic>) {
      await _copilotProgressStore.importState(copilotProgress);
    }
  }
}

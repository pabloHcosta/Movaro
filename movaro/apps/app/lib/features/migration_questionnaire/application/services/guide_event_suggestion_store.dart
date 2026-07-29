import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_identity.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:path_provider/path_provider.dart';

typedef GuideEventSuggestionDirectoryProvider = Future<Directory> Function();

class GuideEventSuggestionPreference {
  const GuideEventSuggestionPreference({
    this.presentedAt,
    this.addedAt,
    this.skippedAt,
    this.remindAfter,
  });

  final String? presentedAt;
  final String? addedAt;
  final String? skippedAt;
  final String? remindAfter;

  bool get isAdded => addedAt != null;
  bool get isSkipped => skippedAt != null;

  bool shouldAutoPrompt(DateTime now) {
    if (isAdded || isSkipped) {
      return false;
    }

    final deferredUntil = DateTime.tryParse(remindAfter ?? '');
    if (deferredUntil != null) {
      return !deferredUntil.isAfter(now);
    }

    return presentedAt == null;
  }
}

class GuideEventSuggestionStore {
  static const _storageKey = 'movaro_guide_event_suggestions';

  GuideEventSuggestionStore({
    GuideEventSuggestionDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final GuideEventSuggestionDirectoryProvider _directoryProvider;

  Future<GuideEventSuggestionPreference> readPreference({
    required MigrationPlan plan,
    required String suggestionId,
  }) async {
    try {
      final data = await _readAll();
      final planEntry = data[MigrationPlanIdentity.storageKeyFor(plan)];
      if (planEntry is! Map<String, dynamic>) {
        return const GuideEventSuggestionPreference();
      }

      final raw = planEntry[suggestionId];
      if (raw is! Map<String, dynamic>) {
        return const GuideEventSuggestionPreference();
      }

      return GuideEventSuggestionPreference(
        presentedAt: raw['presentedAt'] as String?,
        addedAt: raw['addedAt'] as String?,
        skippedAt: raw['skippedAt'] as String?,
        remindAfter: raw['remindAfter'] as String?,
      );
    } catch (_) {
      return const GuideEventSuggestionPreference();
    }
  }

  Future<void> markPresented({
    required MigrationPlan plan,
    required String suggestionId,
  }) {
    return _writePreference(
      plan: plan,
      suggestionId: suggestionId,
      values: <String, dynamic>{
        'presentedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> markAdded({
    required MigrationPlan plan,
    required String suggestionId,
  }) {
    return _writePreference(
      plan: plan,
      suggestionId: suggestionId,
      values: <String, dynamic>{
        'addedAt': DateTime.now().toIso8601String(),
        'remindAfter': null,
      },
    );
  }

  Future<void> markSkipped({
    required MigrationPlan plan,
    required String suggestionId,
  }) {
    return _writePreference(
      plan: plan,
      suggestionId: suggestionId,
      values: <String, dynamic>{'skippedAt': DateTime.now().toIso8601String()},
    );
  }

  Future<void> remindLater({
    required MigrationPlan plan,
    required String suggestionId,
    Duration delay = const Duration(days: 3),
  }) {
    return _writePreference(
      plan: plan,
      suggestionId: suggestionId,
      values: <String, dynamic>{
        'presentedAt': DateTime.now().toIso8601String(),
        'remindAfter': DateTime.now().add(delay).toIso8601String(),
      },
    );
  }

  Future<void> clear() async {
    await PersistentJsonStore.delete(key: _storageKey, fileProvider: _file);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<Map<String, dynamic>> _readAll() async {
    final data = await PersistentJsonStore.read(
      key: _storageKey,
      fileProvider: _file,
    );
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> _writePreference({
    required MigrationPlan plan,
    required String suggestionId,
    required Map<String, dynamic> values,
  }) async {
    final data = await _readAll();
    final key = MigrationPlanIdentity.storageKeyFor(plan);
    final rawPlanEntry = data[key];
    final planEntry = rawPlanEntry is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawPlanEntry)
        : <String, dynamic>{};
    final rawPreference = planEntry[suggestionId];
    final preference = rawPreference is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawPreference)
        : <String, dynamic>{};

    preference.addAll(values);
    preference['updatedAt'] = DateTime.now().toIso8601String();
    planEntry[suggestionId] = preference;
    data[key] = planEntry;

    await PersistentJsonStore.write(
      key: _storageKey,
      data: data,
      fileProvider: _file,
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_guide_event_suggestions.json');
  }
}

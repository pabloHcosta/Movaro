import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';

typedef QuestionnaireFlowDirectoryProvider = Future<Directory> Function();

class QuestionnaireFlowDraftSnapshot {
  const QuestionnaireFlowDraftSnapshot({
    this.answers = const <Answer>[],
    this.currentIndex = 0,
    this.selectedVariantId,
    this.showRefinePrompt = false,
    this.isRefineResolved = false,
    this.includeConstraints = false,
    this.adaptiveQuestionId,
  });

  final List<Answer> answers;
  final int currentIndex;
  final String? selectedVariantId;
  final bool showRefinePrompt;
  final bool isRefineResolved;
  final bool includeConstraints;
  final String? adaptiveQuestionId;
}

class QuestionnaireFlowDraftStore {
  static const _storageKey = 'movaro_questionnaire_flow_draft';

  QuestionnaireFlowDraftStore({
    QuestionnaireFlowDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final QuestionnaireFlowDirectoryProvider _directoryProvider;

  Future<QuestionnaireFlowDraftSnapshot?> read() async {
    try {
      final decoded = await exportState();
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return QuestionnaireFlowDraftSnapshot(
        currentIndex: (decoded['currentIndex'] as num?)?.toInt() ?? 0,
        selectedVariantId: decoded['selectedVariantId'] as String?,
        showRefinePrompt: decoded['showRefinePrompt'] == true,
        isRefineResolved: decoded['isRefineResolved'] == true,
        includeConstraints: decoded['includeConstraints'] == true,
        adaptiveQuestionId: decoded['adaptiveQuestionId'] as String?,
        answers: _readAnswers(decoded['answers']),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> exportState() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required List<Answer> answers,
    required int currentIndex,
    required String? selectedVariantId,
    required bool showRefinePrompt,
    required bool isRefineResolved,
    required bool includeConstraints,
    String? adaptiveQuestionId,
  }) async {
    await PersistentJsonStore.write(
      key: _storageKey,
      fileProvider: _file,
      data: <String, dynamic>{
        'answers': answers
            .map(
              (answer) => <String, dynamic>{
                'questionId': answer.questionId,
                'values': answer.values,
              },
            )
            .toList(growable: false),
        'currentIndex': currentIndex,
        'selectedVariantId': selectedVariantId,
        'showRefinePrompt': showRefinePrompt,
        'isRefineResolved': isRefineResolved,
        'includeConstraints': includeConstraints,
        'adaptiveQuestionId': ?adaptiveQuestionId,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> clear() async {
    await PersistentJsonStore.delete(key: _storageKey, fileProvider: _file);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> importState(Map<String, dynamic>? value) async {
    if (value == null || value.isEmpty) {
      await clear();
      return;
    }

    await PersistentJsonStore.write(
      key: _storageKey,
      data: value,
      fileProvider: _file,
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<bool> hasLocalData() async {
    final value = await exportState();
    return value != null && value.isNotEmpty;
  }

  List<Answer> _readAnswers(Object? rawValue) {
    if (rawValue is! List) {
      return const <Answer>[];
    }

    final answers = <Answer>[];
    for (final item in rawValue) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final questionId = item['questionId'];
      final values = item['values'];
      if (questionId is! String || values is! List) {
        continue;
      }

      answers.add(
        Answer(
          questionId: questionId,
          values: values.whereType<String>().toList(growable: false),
        ),
      );
    }

    return answers;
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_questionnaire_flow_draft.json');
  }
}

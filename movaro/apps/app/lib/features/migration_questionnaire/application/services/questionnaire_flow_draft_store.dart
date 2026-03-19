import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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
  });

  final List<Answer> answers;
  final int currentIndex;
  final String? selectedVariantId;
  final bool showRefinePrompt;
  final bool isRefineResolved;
  final bool includeConstraints;
}

class QuestionnaireFlowDraftStore {
  QuestionnaireFlowDraftStore({
    QuestionnaireFlowDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final QuestionnaireFlowDirectoryProvider _directoryProvider;

  Future<QuestionnaireFlowDraftSnapshot?> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return null;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return QuestionnaireFlowDraftSnapshot(
        currentIndex: (decoded['currentIndex'] as num?)?.toInt() ?? 0,
        selectedVariantId: decoded['selectedVariantId'] as String?,
        showRefinePrompt: decoded['showRefinePrompt'] == true,
        isRefineResolved: decoded['isRefineResolved'] == true,
        includeConstraints: decoded['includeConstraints'] == true,
        answers: _readAnswers(decoded['answers']),
      );
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
  }) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(<String, dynamic>{
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
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> clear() async {
    final file = await _file();
    if (file.existsSync()) {
      await file.delete();
    }
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

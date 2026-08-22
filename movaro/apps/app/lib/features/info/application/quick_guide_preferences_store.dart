import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only Guide history and privacy-preserving counters.
///
/// Raw questions are never written to telemetry. They are kept only on the
/// device so the user can reuse or erase them.
class QuickGuidePreferencesStore {
  const QuickGuidePreferencesStore();

  static const _recentKey = 'quick_guide_recent_questions_v1';
  static const _feedbackKey = 'quick_guide_feedback_v1';
  static const _eventCountsKey = 'quick_guide_event_counts_v1';

  Future<List<String>> loadRecentQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_recentKey) ?? const [])
        .where((item) => item.trim().isNotEmpty)
        .take(5)
        .toList(growable: false);
  }

  Future<void> recordQuery(String question, {required String topic}) async {
    final normalized = question.trim();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentKey) ?? <String>[];
    recent.removeWhere(
      (item) => item.trim().toLowerCase() == normalized.toLowerCase(),
    );
    await prefs.setStringList(
      _recentKey,
      [normalized, ...recent].take(5).toList(growable: false),
    );
    await recordEvent('guideQuerySubmitted', dimension: topic);
  }

  Future<void> clearRecentQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
    await recordEvent('guideHistoryCleared');
  }

  Future<bool?> loadFeedback(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedbackKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final value = decoded[entryId];
    if (value is bool) return value;
    if (value is Map<String, dynamic>) return value['helpful'] as bool?;
    return null;
  }

  Future<String?> loadFeedbackReason(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedbackKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final value = decoded[entryId];
    if (value is! Map<String, dynamic>) return null;
    return value['reason'] as String?;
  }

  Future<void> saveFeedback(
    String entryId,
    bool helpful, {
    String? reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedbackKey);
    final values = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) values.addAll(decoded);
    }
    final safeReason = _safeDimension(reason);
    values[entryId] = <String, dynamic>{
      'helpful': helpful,
      if (!helpful && safeReason != null) 'reason': safeReason,
    };
    await prefs.setString(_feedbackKey, jsonEncode(values));
    await recordEvent(helpful ? 'guideAnswerHelpful' : 'guideAnswerNotHelpful');
    if (!helpful && safeReason != null) {
      await recordEvent('guideFeedbackReason', dimension: safeReason);
    }
  }

  Future<void> recordEvent(String name, {String? dimension}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventCountsKey);
    final values = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) values.addAll(decoded);
    }
    final safeDimension = _safeDimension(dimension);
    final key = safeDimension == null || safeDimension.isEmpty
        ? name
        : '$name:$safeDimension';
    values[key] = (values[key] as num? ?? 0).toInt() + 1;
    await prefs.setString(_eventCountsKey, jsonEncode(values));
  }

  String? _safeDimension(String? value) {
    final normalized = value
        ?.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')
        .toLowerCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Tracks consecutive active days in the app.
///
/// Activity is registered by calling [recordActivity] on app launch and
/// whenever the user marks a guide item as complete.
///
/// Rules:
///  - Same day → keep current streak (idempotent).
///  - Previous day → increment streak.
///  - Older date → reset to 1 (streak broken).
///  - 0 or no record → start at 1.
class StreakService {
  static const _lastDateKey = 'movaro_streak_last_date';
  static const _daysKey = 'movaro_streak_days';

  /// Records today's activity and returns the updated streak count.
  Future<int> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = _key(now);

    final lastStr = prefs.getString(_lastDateKey) ?? '';
    var streak = prefs.getInt(_daysKey) ?? 0;

    if (lastStr.isEmpty) {
      streak = 1;
    } else if (lastStr == todayStr) {
      // Already recorded today — nothing changes.
    } else {
      final last = _parse(lastStr);
      final diff = _daysBetween(last, DateTime(now.year, now.month, now.day));
      streak = diff == 1 ? streak + 1 : 1;
    }

    await prefs.setString(_lastDateKey, todayStr);
    await prefs.setInt(_daysKey, streak);
    return streak;
  }

  /// Returns the current streak. Returns 0 if it has been broken (gap > 1 day).
  Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_lastDateKey);
    if (lastStr == null || lastStr.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = _parse(lastStr);
    if (_daysBetween(last, today) > 1) return 0;

    return prefs.getInt(_daysKey) ?? 0;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parse(String s) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  static int _daysBetween(DateTime a, DateTime b) =>
      b.difference(a).inDays.abs();
}

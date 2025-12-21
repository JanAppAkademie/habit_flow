import 'package:shared_preferences/shared_preferences.dart';

class StreakRepository {
  static const _streakKey = 'streak_count';
  static const _lastDateKey = 'streak_last_date';

  Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_streakKey) ?? 0;
    final lastDateValue = prefs.getString(_lastDateKey);
    if (lastDateValue == null) return 0;

    final lastDate = _parseDate(lastDateValue);
    final today = _dateOnly(DateTime.now());
    if (_isSameDay(lastDate, today) ||
        _isSameDay(lastDate, _yesterday(today))) {
      return streak;
    }

    await prefs.setInt(_streakKey, 0);
    return 0;
  }

  Future<int> recordCompletion(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(date);
    final lastDateValue = prefs.getString(_lastDateKey);
    final lastDate =
        lastDateValue == null ? null : _parseDate(lastDateValue);

    var streak = prefs.getInt(_streakKey) ?? 0;
    if (lastDate != null && _isSameDay(lastDate, today)) {
      return streak;
    }

    if (lastDate != null && _isSameDay(lastDate, _yesterday(today))) {
      streak += 1;
    } else {
      streak = 1;
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastDateKey, _formatDate(today));
    return streak;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _yesterday(DateTime value) =>
      DateTime(value.year, value.month, value.day - 1);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

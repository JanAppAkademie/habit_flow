import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
abstract class Habit with _$Habit {
  const Habit._();

  const factory Habit({
    required String id,
    @Default(true) bool isActive,
    required String name,
    String? description,
    @Default('daily') String interval,
    @Default(false) bool wasNotificated,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<DateTime> completedDates,
    required String userId,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

  // Custom getters
  int get streakCount => _calculateStreak();

  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  // Calculate current streak
  int _calculateStreak() {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 0;
    final now = DateTime.now();
    DateTime expectedDate = DateTime(now.year, now.month, now.day);

    for (final date in sortedDates) {
      final completedDate = DateTime(date.year, date.month, date.day);

      if (completedDate == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Add completion for today
  Habit markAsCompleted() {
    if (isCompletedToday) return this;

    return copyWith(
      completedDates: [...completedDates, DateTime.now()],
      updatedAt: DateTime.now(),
    );
  }

  // Remove today's completion
  Habit markAsIncomplete() {
    if (!isCompletedToday) return this;

    final now = DateTime.now();
    final filtered = completedDates.where((date) =>
        !(date.year == now.year &&
            date.month == now.month &&
            date.day == now.day)).toList();

    return copyWith(
      completedDates: filtered,
      updatedAt: DateTime.now(),
    );
  }
}

import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String? userId;

  @HiveField(1)
  String? id;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool? isCompleted;

  @HiveField(5)
  List<DateTime>? completedDates;

  @HiveField(6)
  DateTime? createdAt;

  Habit({
    required this.userId,
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    this.completedDates,
    this.createdAt,
  });

  bool isCompletedToday() {
    if (completedDates == null || completedDates!.isEmpty) {
      return false;
    }
    DateTime now = DateTime.now();
    for (DateTime date in completedDates!) {
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return true;
      }
    }
    return false;
  }

  // Streak berechnen
  int get currentStreak {
    if (completedDates == null || completedDates!.isEmpty) {
      return 0;
    }
    List<DateTime> dates = [];
    dates.addAll(completedDates!);
    dates.sort((a, b) {
      return b.compareTo(a);
    });
    int streak = 0;
    DateTime now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    if (isCompletedToday() == false) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    for (DateTime date in dates) {
      bool isSameDay = date.year == checkDate.year &&
          date.month == checkDate.month &&
          date.day == checkDate.day;
      if (isSameDay) {
        streak = streak + 1;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        return streak;
      }
    }
    return streak;
  }
}

import 'package:hive_ce/hive.dart';
import 'habit.dart';

part 'habit_hive_adapter.g.dart';

@HiveType(typeId: 0)
class HabitHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final bool completedToday;

  @HiveField(5)
  final List<DateTime> completedDates;

  @HiveField(6)
  final DateTime? lastCompletedAt;

  HabitHive({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.completedToday,
    required this.completedDates,
    this.lastCompletedAt,
  });

  factory HabitHive.fromHabit(Habit habit) {
    return HabitHive(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      createdAt: habit.createdAt,
      completedToday: habit.completedToday,
      completedDates: habit.completedDates,
      lastCompletedAt: habit.lastCompletedAt,
    );
  }

  Habit toHabit() {
    return Habit(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      completedToday: completedToday,
      completedDates: completedDates,
      lastCompletedAt: lastCompletedAt,
    );
  }
}

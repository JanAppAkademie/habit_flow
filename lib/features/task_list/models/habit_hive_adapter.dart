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
  final DateTime updatedAt;

  @HiveField(5)
  final bool completedToday;

  @HiveField(6)
  final List<DateTime> completedDates;

  @HiveField(7)
  final DateTime? lastCompletedAt;

  @HiveField(8)
  final bool needsSync;

  HabitHive({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.completedToday,
    required this.completedDates,
    this.lastCompletedAt,
    this.needsSync = false,
  });


  factory HabitHive.fromHabit(Habit habit) {
    return HabitHive(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
      completedToday: habit.completedToday,
      completedDates: habit.completedDates,
      lastCompletedAt: habit.lastCompletedAt,
      needsSync: habit.needsSync,
    );
  }

  Habit toHabit() {
    return Habit(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedToday: completedToday,
      completedDates: completedDates,
      lastCompletedAt: lastCompletedAt,
      needsSync: needsSync,
    );
  }
}

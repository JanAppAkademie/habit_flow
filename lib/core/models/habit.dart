import 'package:hive_ce/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final bool isDone;

  @HiveField(2)
  final int streakCount;

  Habit({
    required this.title,
    this.isDone = false,
    this.streakCount = 0,
  });

  Habit copyWith({
    String? title,
    bool? isDone,
    int? streakCount,
  }) {
    return Habit(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}

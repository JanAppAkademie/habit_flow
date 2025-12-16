class Habit {
  final String title;
  final bool isDone;
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

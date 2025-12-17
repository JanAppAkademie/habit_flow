class Habit {
  bool isActive;
  final String name;
  final DateTime createdAt;

  Habit({required this.name}) : isActive = true, createdAt = DateTime.now();
}

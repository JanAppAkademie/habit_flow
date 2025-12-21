class Habit {
  bool isActive;
  final String name;
  final DateTime createdAt;

  Habit({required this.name}) : isActive = true, createdAt = DateTime.now();

  factory Habit.fromMap(Map<String, dynamic> json) {
    return Habit(name: json['name']);
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'isActive': isActive,
    'created_at': createdAt.toIso8601String(),
  };
}

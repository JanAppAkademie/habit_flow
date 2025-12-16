class Habit {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final bool completedToday;
  final List<DateTime> completedDates; // Alle Tage, an denen Habit erledigt wurde
  final DateTime? lastCompletedAt;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.completedToday,
    required this.completedDates,
    this.lastCompletedAt,
  });

  /// Berechnet die aktuelle Streak (aufeinanderfolgende Tage) rückwärts von heute
  int calculateStreak() {
    if (completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Rückwärts zählen von heute bis zur ersten Lücke
    while (true) {
      final isCompleted = completedDates.any((date) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        return dateOnly == current;
      });

      if (!isCompleted) break;

      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    bool? completedToday,
    List<DateTime>? completedDates,
    DateTime? lastCompletedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedToday: completedToday ?? this.completedToday,
      completedDates: completedDates ?? this.completedDates,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.completedToday == completedToday &&
        other.completedDates == completedDates &&
        other.lastCompletedAt == lastCompletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        completedToday.hashCode ^
        completedDates.hashCode ^
        lastCompletedAt.hashCode;
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, description: $description, createdAt: $createdAt, completedToday: $completedToday, completedDates: $completedDates, lastCompletedAt: $lastCompletedAt)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'completed_today': completedToday,
      'completed_dates': completedDates.map((d) => d.toIso8601String()).toList(),
      'last_completed_at': lastCompletedAt?.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedToday: json['completed_today'] as bool,
      completedDates: ((json['completed_dates'] as List?) ?? [])
        .map((d) => DateTime.parse(d as String))
        .toList(),
      lastCompletedAt: json['last_completed_at'] != null
        ? DateTime.parse(json['last_completed_at'] as String)
        : null,
    );
  }
}

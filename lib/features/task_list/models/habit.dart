class Habit {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool completedToday;
  final List<DateTime> completedDates; // Alle Tage, an denen Habit erledigt wurde
  final DateTime? lastCompletedAt;
  final bool needsSync;

  Habit({
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
    DateTime? updatedAt,
    bool? completedToday,
    List<DateTime>? completedDates,
    DateTime? lastCompletedAt,
    bool? needsSync,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedToday: completedToday ?? this.completedToday,
      completedDates: completedDates ?? this.completedDates,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      needsSync: needsSync ?? this.needsSync,
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
      other.updatedAt == updatedAt &&
      other.completedToday == completedToday &&
      other.completedDates == completedDates &&
      other.lastCompletedAt == lastCompletedAt &&
      other.needsSync == needsSync;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      completedToday.hashCode ^
      completedDates.hashCode ^
      lastCompletedAt.hashCode ^
      needsSync.hashCode;
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, completedToday: $completedToday, completedDates: $completedDates, lastCompletedAt: $lastCompletedAt, needsSync: $needsSync)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_today': completedToday,
      'completed_dates': completedDates.map((d) => d.toIso8601String()).toList(),
      'last_completed_at': lastCompletedAt?.toIso8601String(),
      'needs_sync': needsSync,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: _toDateTimeNonNull(json['created_at']),
      updatedAt: _toDateTimeNonNull(json['updated_at']),
      completedToday: _toBool(json['completed_today']),
      completedDates: (((json['completed_dates'] as List?) ?? [])
        .map((d) => _toDateTime(d))
        .where((d) => d != null)
        .map((d) => d as DateTime)
        .toList()),
      lastCompletedAt: _toDateTime(json['last_completed_at']),
      needsSync: _toBool(json['needs_sync']),
    );
  }
}

// Helper conversions used for defensive JSON parsing
DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      final maybe = int.tryParse(v);
      if (maybe != null) return DateTime.fromMillisecondsSinceEpoch(maybe);
    }
  }
  return null;
}

DateTime _toDateTimeNonNull(dynamic v) => _toDateTime(v) ?? DateTime.now();

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1' || s == 't') return true;
    return false;
  }
  return false;
}

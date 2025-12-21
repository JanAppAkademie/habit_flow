import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Habit extends HiveObject {
  Habit({
    required this.title,
    this.lastCompletionDate,
    this.streakCount = 0,
    String? id,
    DateTime? updatedAt,
  }) : id = id ?? _uuid.v4(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  factory Habit.fromRemote(Map<String, dynamic> remote) {
    final lastCompletionRaw = remote['last_completion_date'] as String?;
    final updatedAtRaw = remote['updated_at'] as String?;
    return Habit(
      id: remote['id'] as String? ?? _uuid.v4(),
      title: remote['title'] as String? ?? '',
      lastCompletionDate: lastCompletionRaw != null
          ? DateTime.parse(lastCompletionRaw).toLocal()
          : null,
      streakCount: remote['streak_count'] as int? ?? 0,
      updatedAt: updatedAtRaw != null
          ? DateTime.parse(updatedAtRaw).toUtc()
          : DateTime.now().toUtc(),
    );
  }

  static const boxName = 'habits';

  String title;
  final String id;
  DateTime? lastCompletionDate;
  int streakCount;
  DateTime updatedAt;

  bool get isCompletedToday {
    if (lastCompletionDate == null) {
      return false;
    }
    return _isSameDay(lastCompletionDate!, DateTime.now());
  }

  int get currentStreak {
    if (lastCompletionDate == null) {
      return 0;
    }
    final today = _normalizeDate(DateTime.now());
    final last = _normalizeDate(lastCompletionDate!);
    final difference = today.difference(last).inDays;
    if (difference > 1) {
      return 0;
    }
    return streakCount;
  }

  void markCompletedToday() {
    final today = _normalizeDate(DateTime.now());
    final last = lastCompletionDate != null
        ? _normalizeDate(lastCompletionDate!)
        : null;
    final streakBase = currentStreak;

    if (last != null &&
        _isSameDay(last, today.subtract(const Duration(days: 1)))) {
      streakCount = streakBase + 1;
    } else if (last != null && _isSameDay(last, today)) {
      return;
    } else {
      streakCount = 1;
    }

    lastCompletionDate = today;
    touch();
  }

  void resetCompletion() {
    lastCompletionDate = null;
    streakCount = 0;
    touch();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void touch() {
    updatedAt = DateTime.now().toUtc();
  }

  void applyRemote(Habit remote) {
    title = remote.title;
    lastCompletionDate = remote.lastCompletionDate;
    streakCount = remote.streakCount;
    updatedAt = remote.updatedAt;
  }

  Map<String, dynamic> toRemoteMap() {
    return {
      'id': id,
      'title': title,
      'last_completion_date': lastCompletionDate?.toUtc().toIso8601String(),
      'streak_count': streakCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final title = fields[0] as String? ?? '';
    final rawCompletion = fields[1];
    final rawStreak = fields[2];
    final rawId = fields[3];
    final rawUpdatedAt = fields[4];

    DateTime? lastCompletion;
    if (rawCompletion is DateTime) {
      lastCompletion = rawCompletion;
    } else if (rawCompletion is bool && rawCompletion) {
      lastCompletion = Habit._normalizeDate(DateTime.now());
    }

    final streak = rawStreak is int
        ? rawStreak
        : (lastCompletion != null ? 1 : 0);

    final id = rawId is String && rawId.isNotEmpty ? rawId : _uuid.v4();
    final updatedAt = rawUpdatedAt is DateTime
        ? rawUpdatedAt
        : DateTime.now().toUtc();

    return Habit(
      title: title,
      lastCompletionDate: lastCompletion,
      streakCount: streak,
      id: id,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.lastCompletionDate)
      ..writeByte(2)
      ..write(obj.streakCount)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_hive_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitHiveAdapter extends TypeAdapter<HabitHive> {
  @override
  final typeId = 0;

  @override
  HabitHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitHive(
      id: _toStringSafe(fields[0]),
      name: _toStringSafe(fields[1]),
      description: _toStringSafe(fields[2]),
      createdAt: _toDateTimeNonNull(fields[3]),
      updatedAt: _toDateTimeNonNull(fields[4]),
      completedToday: _toBool(fields[5]),
      completedDates: _toDateTimeList(fields[6]),
      lastCompletedAt: _toDateTime(fields[7]),
      needsSync: _toBool(fields[8]),
    );
  }

  @override
  void write(BinaryWriter writer, HabitHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.completedToday)
      ..writeByte(6)
      ..write(obj.completedDates)
      ..writeByte(7)
      ..write(obj.lastCompletedAt)
      ..writeByte(8)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Helper conversions to be tolerant with older persisted formats
DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    // Try ISO parse, otherwise try parse as int millis string
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

List<DateTime> _toDateTimeList(dynamic v) {
  if (v == null) return <DateTime>[];
  if (v is List) {
    return v.map((e) => _toDateTime(e) ?? DateTime.now()).toList();
  }
  // single value fallback
  final single = _toDateTime(v);
  return single == null ? <DateTime>[] : <DateTime>[single];
}

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1') return true;
    return false;
  }
  return false;
}

String _toStringSafe(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

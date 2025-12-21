import 'package:hive_ce/hive.dart';

class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task copyWith({String? title, bool? isCompleted, DateTime? updatedAt}) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Task.fromSupabase(Map<String, dynamic> data) {
    final createdAtValue = data['created_at'] as String;
    final updatedAtValue =
        data['updated_at'] as String? ?? createdAtValue;
    return Task(
      id: data['id'] as String,
      title: data['title'] as String,
      isCompleted: data['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(createdAtValue),
      updatedAt: DateTime.parse(updatedAtValue),
    );
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final createdAt =
        DateTime.fromMillisecondsSinceEpoch(fields[3] as int);
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      createdAt: createdAt,
      updatedAt: fields[4] == null
          ? createdAt
          : DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }
}

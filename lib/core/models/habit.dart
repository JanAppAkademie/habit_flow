import 'package:hive_ce/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 20)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isActive;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final bool deleted;

  const Habit({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
  });

  Habit copyWith({
    String? name,
    bool? isActive,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Habit _$HabitFromJson(Map<String, dynamic> json) => _Habit(
  id: json['id'] as String,
  isActive: json['isActive'] as bool? ?? true,
  name: json['name'] as String,
  description: json['description'] as String?,
  interval: json['interval'] as String? ?? 'daily',
  wasNotificated: json['wasNotificated'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  completedDates:
      (json['completedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
  userId: json['userId'] as String,
);

Map<String, dynamic> _$HabitToJson(_Habit instance) => <String, dynamic>{
  'id': instance.id,
  'isActive': instance.isActive,
  'name': instance.name,
  'description': instance.description,
  'interval': instance.interval,
  'wasNotificated': instance.wasNotificated,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'completedDates': instance.completedDates
      .map((e) => e.toIso8601String())
      .toList(),
  'userId': instance.userId,
};

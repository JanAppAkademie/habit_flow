// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  guestMode: json['guestMode'] as bool? ?? false,
  name: json['name'] as String,
  isSynced: json['isSynced'] as bool? ?? false,
  createdTime: DateTime.parse(json['createdTime'] as String),
  updatedTime: DateTime.parse(json['updatedTime'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'password': instance.password,
  'guestMode': instance.guestMode,
  'name': instance.name,
  'isSynced': instance.isSynced,
  'createdTime': instance.createdTime.toIso8601String(),
  'updatedTime': instance.updatedTime.toIso8601String(),
};

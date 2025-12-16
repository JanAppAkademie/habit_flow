// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
  theme: json['theme'] as String? ?? 'system',
  notificationsOn: json['notificationsOn'] as bool? ?? true,
  reminderTime: json['reminderTime'] as String?,
  syncType: json['syncType'] as String? ?? 'automatic',
);

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
  'theme': instance.theme,
  'notificationsOn': instance.notificationsOn,
  'reminderTime': instance.reminderTime,
  'syncType': instance.syncType,
};

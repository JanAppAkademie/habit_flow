import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    @Default('system') String theme, // "light", "dark", "system"
    @Default(true) bool notificationsOn,
    String? reminderTime, // Stored as "HH:mm" string
    @Default('automatic') String syncType, // "automatic", "manual"
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

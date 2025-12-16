import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/core/models/settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<Settings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return const Settings();
    }

    try {
      return Settings.fromJson(json.decode(settingsJson));
    } catch (e) {
      return const Settings();
    }
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }

  Future<void> saveTheme(String theme) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(theme: theme));
  }

  Future<String> getTheme() async {
    final settings = await getSettings();
    return settings.theme;
  }

  Future<void> saveNotifications(bool enabled) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(notificationsOn: enabled));
  }

  Future<bool> getNotifications() async {
    final settings = await getSettings();
    return settings.notificationsOn;
  }

  Future<void> saveReminderTime(String? time) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(reminderTime: time));
  }

  Future<String?> getReminderTime() async {
    final settings = await getSettings();
    return settings.reminderTime;
  }

  Future<void> saveSyncType(String syncType) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(syncType: syncType));
  }

  Future<String> getSyncType() async {
    final settings = await getSettings();
    return settings.syncType;
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}

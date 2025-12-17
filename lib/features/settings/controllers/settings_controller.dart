import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/notifications/notification_service.dart';
import 'package:habit_flow/features/notifications/providers/notification_providers.dart';
import 'package:habit_flow/features/settings/data/settings_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._service, this._notificationService);

  final SettingsService _service;
  final NotificationService _notificationService;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  bool get isInitialized => _isInitialized;

  Future<void> loadSettings() async {
    _themeMode = await _service.loadThemeMode();
    _notificationsEnabled = await _service.loadNotificationsEnabled();
    _reminderTime = await _service.loadReminderTime();
    _isInitialized = true;
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    }
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    await _service.updateThemeMode(mode);
  }

  Future<void> updateNotificationsEnabled(bool isEnabled) async {
    if (isEnabled == _notificationsEnabled) {
      return;
    }
    _notificationsEnabled = isEnabled;
    notifyListeners();
    await _service.updateNotificationsEnabled(isEnabled);

    if (isEnabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        _notificationsEnabled = false;
        notifyListeners();
        await _service.updateNotificationsEnabled(false);
        return;
      }
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      await _notificationService.cancelReminder();
    }
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    if (time == _reminderTime) {
      return;
    }
    _reminderTime = time;
    notifyListeners();
    await _service.updateReminderTime(time);
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(time);
    }
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsControllerProvider =
    ChangeNotifierProvider<SettingsController>((ref) {
  final controller = SettingsController(
    ref.watch(settingsServiceProvider),
    ref.watch(notificationServiceProvider),
  );
  controller.loadSettings();
  ref.onDispose(controller.dispose);
  return controller;
});

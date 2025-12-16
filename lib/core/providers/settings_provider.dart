import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/models/settings.dart';
import 'package:habit_flow/core/services/settings_service.dart';

// Settings Service Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Settings State Provider
final settingsProvider = FutureProvider<Settings>((ref) async {
  final service = ref.read(settingsServiceProvider);
  return service.getSettings();
});

// Theme Provider
final themeProvider = FutureProvider<String>((ref) async {
  final service = ref.read(settingsServiceProvider);
  return service.getTheme();
});

// Notifications Provider
final notificationsProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(settingsServiceProvider);
  return service.getNotifications();
});

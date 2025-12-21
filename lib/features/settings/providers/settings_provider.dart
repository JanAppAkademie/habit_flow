import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final autoSyncProvider = AsyncNotifierProvider<AutoSyncNotifier, bool>(
  AutoSyncNotifier.new,
);

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AutoSyncNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getAutoSync();
  }

  Future<void> setAutoSync(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = const AsyncValue.loading();
    await repository.setAutoSync(value);
    state = AsyncValue.data(value);
  }
}

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = const AsyncValue.loading();
    await repository.setThemeMode(value);
    state = AsyncValue.data(value);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController implemented as a Riverpod Notifier.
///
/// - `build()` returns the default ThemeMode and triggers an async
///   load of the persisted preference.
/// - `setTheme()` updates state and persists the selection.
class ThemeModeProvider extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Start with system as a safe default; then load persisted value.
    _loadPersisted();
    return ThemeMode.system;
  }

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('theme_mode');
      if (stored == 'light') {
        state = ThemeMode.light;
      } else if (stored == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      // Ignore and keep default
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system';
      await prefs.setString('theme_mode', key);
    } catch (_) {
      // ignore persistence errors
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeProvider, ThemeMode>(ThemeModeProvider.new);

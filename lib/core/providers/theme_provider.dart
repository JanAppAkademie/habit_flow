import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController implementiert als Riverpod-Notifier.
///
/// - `build()` gibt den Standard-`ThemeMode` zurück und startet asynchron
///   das Laden der persistierten Einstellung.
/// - `setTheme()` aktualisiert den Zustand und speichert die Auswahl persistent.
class ThemeModeProvider extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Starte mit `system` als sichere Standardeinstellung; lade anschließend den gespeicherten Wert.
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
      // Fehler beim Laden ignorieren und Standardwert beibehalten
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system';
      await prefs.setString('theme_mode', key);
    } catch (_) {
      debugPrint('Fehler beim Speichern des ThemeMode');
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeProvider, ThemeMode>(ThemeModeProvider.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provide a `ValueNotifier<ThemeMode>` via a plain `Provider`.
/// We listen to the notifier with `ValueListenableBuilder` in the app
/// so changes to `.value` update the UI without requiring other provider types.
/// Global ValueNotifier instance for theme mode (exported for main.dart)
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Provides the global ValueNotifier for theme mode
final themeControllerProvider = Provider<ValueNotifier<ThemeMode>>((ref) {
  return themeModeNotifier;
});



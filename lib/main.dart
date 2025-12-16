import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:habit_flow/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/features/task_list/services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://pigfirlzdgauqjdvgmzq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpZ2Zpcmx6ZGdhdXFqZHZnbXpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTczMzUsImV4cCI6MjA4MTM3MzMzNX0.lS-o0QiWv2TTlZ0U9moOutyRE6inrM8WlLMt1GbyQfc',
  );

  // Initialize repository
  await initializeHabitRepository();

  // Load persisted theme and override the theme controller provider
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('theme_mode');
  final initialTheme =
      stored == 'light' ? ThemeMode.light :
      stored == 'dark' ? ThemeMode.dark :
      ThemeMode.system;

  // Set initial value for the global ValueNotifier
  themeModeNotifier.value = initialTheme;
  // Initialize Notification Service
  await NotificationService.initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('de')],
      path: 'assets/langs',
      fallbackLocale: const Locale('de'),
      child: const ProviderScope(child: App()),
    ),
  );
}

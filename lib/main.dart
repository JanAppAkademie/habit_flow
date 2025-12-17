import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:habit_flow/features/task_list/services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Load environment variables from .env (not committed)
  // Try loading .env content from assets/supabase/.env (project root relative)
  Map<String, String> envFromAsset = {};
  try {
    final content = await rootBundle.loadString('assets/supabase/.env');
    for (final line in content.split(RegExp(r"\r?\n"))) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx <= 0) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      envFromAsset[key] = value;
    }
  } catch (e) {
    // File not found or not bundled as asset; fall back to --dart-define below.
    // ignore: avoid_print
    print('No assets/supabase/.env asset found — falling back to --dart-define if provided.');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Supabase with environment variables
  // Allow two ways to provide secrets:
  // 1) Local development: .env file loaded by flutter_dotenv
  // 2) CI / build-time: passed via --dart-define (String.fromEnvironment)
  final supabaseUrl = envFromAsset['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = envFromAsset['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be provided via .env or --dart-define');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize repository
  await initializeHabitRepository();
  // Automatischer Sync beim App-Start
  await getHabitRepository().fullSync();

    // Initialize Notification Service
    await NotificationService.initialize();

    // Note: older Riverpod versions don't accept a `container` named
    // parameter on `ProviderScope`. Instead, the ThemeController loads
    // its persisted value asynchronously on build. This avoids an
    // unsupported named parameter error during analysis.
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('de')],
        path: 'assets/langs',
        fallbackLocale: const Locale('de'),
        child: const ProviderScope(child: App()),
      ),
    );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:habit_flow/core/providers/habit_repository_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Lade Umgebungsvariablen aus .env (nicht im Repository gespeichert)
  // Versuche, den Inhalt von assets/supabase/.env zu laden (relativ zum Projekt-Root)
  // Nicht die beste Idee, aber ich bin sensiblisiert gegenüber dem Umgang mit Secrets in Flutter-Projekten.
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
    // Datei nicht gefunden oder nicht als Asset gebündelt; Fallback auf --dart-define weiter unten.
    // ignore: avoid_print
    print('No assets/supabase/.env asset found — falling back to --dart-define if provided.');
  }

  // Initialisiere Hive
  await Hive.initFlutter();

  // Initialisiere Supabase mit Umgebungsvariablen
  // Erlaubt zwei Methoden, Secrets bereitzustellen:
  // 1) Lokale Entwicklung: .env-Datei (z. B. geladen durch flutter_dotenv)
  // 2) CI / Build-Zeit: per --dart-define übergeben (String.fromEnvironment)
  final supabaseUrl = envFromAsset['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = envFromAsset['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be provided via .env or --dart-define');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Create container for providers
  final container = ProviderContainer();

  // Initialize Repository
  final habitRepo = HabitRepository(container);
  await habitRepo.init();
  // Set global
  habitRepositoryGlobal = habitRepo;
  // Automatischer Sync beim App-Start
  await habitRepo.fullSync();

    // Initialize Notification Service
    await NotificationService.initialize();

    // Hinweis: Ältere Riverpod-Versionen akzeptieren keinen benannten
    // Parameter `container` für `ProviderScope`. Stattdessen lädt der
    // ThemeController seinen gespeicherten Wert asynchron in `build()`.
    // Dadurch tritt kein Fehler wegen eines nicht unterstützten benannten Parameters in der Analyse auf.
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('de')],
        path: 'assets/langs',
        fallbackLocale: const Locale('de'),
        child: ProviderScope(child: const App()),
      ),
    );
}

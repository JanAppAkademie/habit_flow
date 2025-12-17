# Habit Flow — Übersicht (README_HRE)

**Kurzbeschreibung**
- **Zweck**: Eine kleine Flutter-App zur Verwaltung von Gewohnheiten (Habits) mit lokalem Persistieren und bidirektionaler Synchronisation mit Supabase.
- **Ziel**: Robustheit gegenüber Datenmodell-Änderungen, Geräte-gebundene Synchronisation, Offline-first mit späterer Konfliktauflösung.

**Haupt-Features**
- **Lokale Persistenz**: Hive (via `hive_ce_flutter`) speichert Habits lokal auf dem Gerät.
- **Bidirektionale Synchronisation**: Vollsync zwischen lokalem Hive und Supabase inkl. Upload lokaler Änderungen und Download von Serverdaten.
- **Geräte‑Scoped Sync**: Jede Änderung enthält ein `device_id`‑Feld; Downloads sind gefiltert (dieses Gerät ODER server-seeded rows), um unerwünschte Überschreibungen zu vermeiden.
- **Sync-Queue & Status**: `SyncNotifier` (NotifierProvider) verwaltet ausstehende Uploads und bietet `SyncState` (isSynced, isRunning, queueLength), das in der UI reflektiert wird.
- **Offline‑Robustheit & Migration**: Defensive Deserialisierung in den Hive TypeAdapters und Repository‑Level Normalisierung konvertiert ältere/abweichende Persistenzformate (z. B. int/Strings für DateTime, bool als int) ohne Absturz.
- **Benachrichtigungen**: Hintergrund‑/lokale Notifications via `flutter_local_notifications` werden unterstützt (NotificationService).
- **UI/UX**: Pull-to-Refresh (`RefreshIndicator`) zur manuellen Synchronisation plus ein tappbares Cloud-Icon links, das Sync auslöst; Icon-Farbe spiegelt Sync/Connectivity-Status.
- **Lokalisierung**: App ist auf Deutsch lokalisiert mittels `easy_localization` (`assets/langs/de.json`).
- **Quotes Auto-Refresh**: Zitat-Widget refresh alle Minute via Riverpod/Timer.

**Wichtige technische Eigenschaften**
- **Framework**: Flutter + Riverpod (`flutter_riverpod`) für State Management — vollständig migriert, kein ValueNotifier mehr; alles über Provider und Notifier.
- **Local DB**: Hive (CE) mit generierten TypeAdapters (`build_runner` + `hive_generator` pattern). Adapter enthalten defensive Parsing-Logik.
- **Backend**: Supabase (`supabase_flutter`) als Postgres-Backend mit REST/Realtime-Funktionen.
- **Secrets Handling**: Supabase-Keys werden nicht hardcodiert.
  - Primär: `assets/supabase/.env` (lokal, nicht versioniert) mit `SUPABASE_URL` und `SUPABASE_ANON_KEY` (diese Datei ist in `.gitignore`).
  - Fallback: Build-time `--dart-define` (`SUPABASE_URL` und `SUPABASE_ANON_KEY`) für CI/CD.
- **Device ID**: Interne UUIDv4-Generator-Implementierung (kein externes `uuid`-Package) — persistiert in `SharedPreferences`.
- **Dependencies (Kerngruppen)**: `flutter_riverpod`, `hive_ce_flutter`, `supabase_flutter`, `easy_localization`, `flutter_local_notifications`, `shared_preferences`.
- **Codegen**: `build_runner` wird verwendet, um Hive-Adapter zu erzeugen. Änderungen am Modell erfordern ggf. Regeneration der Adapter.
- **Fehlerhärtung**: Adapter + Repository enthalten defensiven Code, um Migrationen von alten Formaten sicher durchzuführen.

 **Dateien & Orte (wichtig)**
- **App-Entry**: `lib/main.dart` — initialisiert Hive, Supabase, Repository, NotificationService und EasyLocalization.
- **UI**: `lib/app.dart` und Bildschirm-Komponenten unter `lib/features/` (z. B. `lib/features/task_list/screens/list_screen.dart`, `lib/features/settings/`).
- **Model/Adapter**: `lib/features/task_list/models/` enthält `habit.dart` und die generierten Hive-Adapter.
- **Repository/Sync**: `lib/features/task_list/models/habit_repository.dart`, `lib/core/providers/sync_provider.dart` (SyncNotifier).
- **Globale Services & Provider**: `lib/core/services/` (z. B. `notification_service.dart`, `device_id.dart`, `quote_api.dart`) und `lib/core/providers/` (z. B. `connectivity_provider.dart`, `theme_provider.dart`, `sync_provider.dart`, `notification_provider.dart`, `quote_provider.dart`).
- **Localization**: `assets/langs/de.json` enthält die deutschen Übersetzungen.
- **Env-Dateien**: `assets/supabase/.env` (lokal, in `.gitignore`) und `assets/supabase/.env.example` als Vorlage.
- **Generated files / codegen**: `lib/hive_registrar.g.dart` (und weitere `*.g.dart`-Dateien nach `build_runner`).

**Wichtige Befehle / Setup**
- Abhängigkeiten installieren:

```bash
flutter pub get
```

- Falls Adapter neu generiert werden müssen (bei Modelländerungen):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- App starten:

```bash
flutter run
```

- Alternative (CI/Build) — Supabase-Keys per `--dart-define` übergeben:

```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

- Lokale `.env` (als Asset) anlegen:
  - Datei: `assets/supabase/.env`
  - Inhalt:

```
SUPABASE_URL=https://xyz.supabase.co
SUPABASE_ANON_KEY=eyJ...your_anon_key_here
```

Stellen Sie sicher, dass `assets/supabase/.env` in `pubspec.yaml` unter `assets:` eingetragen ist (dies ist bereits vorbereitet).



**Verzeichnisstruktur (Kurzübersicht)**

Hier eine kompakte Ansicht der Projektstruktur als ASCII-Graphik. Sie zeigt die wichtigsten Ordner und Dateien, die im Projekt verwendet werden:

```
habit_flow/
├─ pubspec.yaml
├─ README_HRE.md
├─ README.md
├─ android/
│  ├─ build.gradle.kts
│  └─ ...
├─ assets/
│  ├─ langs/
│  │  └─ de.json
│  └─ supabase/
│     ├─ .env         # lokal, in .gitignore
│     └─ .env.example
├─ build/
├─ docs/
├─ ios/
│  └─ Runner/
├─ lib/
│  ├─ app.dart
│  ├─ main.dart
│  ├─ hive_registrar.g.dart
│  ├─ core/
│  │  ├─ providers/
│  │  │  ├─ connectivity_provider.dart
│  │  │  ├─ notification_provider.dart
│  │  │  ├─ quote_provider.dart
│  │  │  ├─ reminder_time_provider.dart
│  │  │  ├─ sync_provider.dart
│  │  │  └─ theme_provider.dart
│  │  ├─ router/
│  │  │  └─ app_router.dart
│  │  ├─ services/
│  │  │  ├─ device_id.dart
│  │  │  ├─ notification_service.dart
│  │  │  └─ quote_api.dart
│  │  └─ theme/
│  └─ features/
│     ├─ settings/
│        ├─ screens/
│           └─ settings_screen.dart
│     ├─ splash/
│        ├─ screens/
│        │  └─ slpash_screen.dart
│        └─ widgets/
│           └─ quote_widget.dart
│     └─ task_list/
│        ├─ models/
│        │  ├─ habit.dart
│        │  ├─ habit_hive_adapter.dart
│        │  ├─ habit_hive_adapter.g.dart
│        │  ├─ habit_repository.dart
│        │  └─ habit_repository_provider.dart
│        ├─ screens/
│        │  └─ list_screen.dart
│        └─ widgets/
│           ├─ empty_content.dart
│           ├─ habit_dialog.dart
│           └─ item_list.dart
├─ test/
  └─ widget_test.dart

```

# HabitFlow — Projektbeschreibung

## Was ist HabitFlow?

- Mobile App zum Aufbauen und Verfolgen täglicher Gewohnheiten mit Zitaten und Sync

---
## Features

### Gewohnheiten verwalten
- Eigene Habits erstellen, bearbeiten, löschen

### Tägliches Abhaken
- Hauptscreen zeigt alle Habits für heute
- Ein Tap markiert Habit als erledigt
- Fortschrittsanzeige (z.B. "4 von 6 erledigt")

### Streaks
- Zählt aufeinanderfolgende Tage mit erledigten Habits
- Prominente Anzeige 
- Streak bricht bei verpasstem Tag ab

### Motivationszitate
- Inspirierendes Zitat beim App-Start
- Zitate von externer API (DummyJSON)
- Neues Zitat per Pull-to-Refresh

### Einstellungen
- Theme wählen (Hell / Dunkel / System)
- Benachrichtigungen ein/aus
- Erinnerungszeit festlegen

### Offline-First mit Cloud-Sync
- App funktioniert komplett offline
- Lokale Speicherung mit Hive und SharedPreferences
- Automatischer Sync mit Supabase

#### Architektur
- Habits werden als Hive-Objekte (`lib/features/task_list/models/habit.dart`) mit UUID und `updatedAt`-Zeitstempel gespeichert, damit Konflikte eindeutig aufgelöst werden können.
- Einstellungen sowie Sync-Queues (ausstehende Upserts/Löschungen) liegen in SharedPreferences, dadurch funktionieren Änderungen auch ohne Internet und werden beim nächsten Start automatisch übertragen.
- `HabitSyncService` (`lib/core/sync/habit_sync_service.dart`) lauscht auf lokale Änderungen, kümmert sich um das asynchrone Hochladen/Herunterladen und meldet Fehlversuche zurück in die Queue, bis Supabase wieder erreichbar ist.

#### Supabase einrichten
1. Tabelle `habits` anlegen (SQL-Beispiel):
   ```sql
   create table public.habits (
     id uuid primary key,
     title text not null,
     last_completion_date timestamptz,
     streak_count int2 default 0,
     updated_at timestamptz not null default now()
   );
   ```
2. Projekt-URL und anon-key als `dart-define` übergeben (Default-Werte liegen in `lib/core/config/supabase_options.dart`):
   ```bash
   flutter run \
     --dart-define SUPABASE_URL=https://<project>.supabase.co \
     --dart-define SUPABASE_ANON_KEY=<anon-key>
   ```
3. Ohne gültige Keys läuft die App weiterhin vollständig offline, der Sync-Service deaktiviert sich automatisch.

---

## Verlauf des Projekts:

### Montag: 
- Vorstellung Projekt
- Projektaufgabe Persistente Liste (Abgabe Mittwoch 9:00 Uhr)
### Dienstag:
- Aufbau Architektur/UML/Setup
- Setup Supabase
### Mittwoch: 
- Review Projektaufgabe + Umbau 
- Projektaufgabe Anbindung Backend (Abgabe Freitag 9:00 Uhr)
### Donnerstag: 
- Anbindung DummyJSON (Zitate) + Settings
- Wissenscheck
### Freitag:
- Review Anbindung Backend
- Einbauen Streaks


import 'package:hive_ce/hive.dart';
import 'habit.dart';
import 'habit_hive_adapter.dart';
import 'package:habit_flow/core/services/sync_service.dart';
import 'package:habit_flow/core/services/device_id.dart';




class HabitRepository {
  static const String _boxName = 'habits';
  late Box<HabitHive> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(HabitHiveAdapter());
    _box = await Hive.openBox<HabitHive>(_boxName);
    // Normalize existing entries: rewrite entries using current adapter/format
    try {
      for (final key in _box.keys.toList()) {
        try {
          final hive = _box.get(key);
          if (hive == null) continue;
          final habit = hive.toHabit();
          final rewritten = HabitHive.fromHabit(habit);
          await _box.put(hive.id, rewritten);
        } catch (e) {
          // If one entry is corrupt/unreadable, remove it to avoid crashing.
          await _box.delete(key);
        }
      }
    } catch (_) {}
    await SyncService().init();
    // Migration: Alte Daten mit streakDays zu completedDates migrieren
    try {
      final keysToUpdate = <String>[];
      for (var hive in _box.values) {
        if (hive.completedDates.isEmpty && hive.lastCompletedAt != null) {
          keysToUpdate.add(hive.id);
        }
      }
      for (var id in keysToUpdate) {
        final hive = _box.get(id);
        if (hive != null) {
          final migratedHive = HabitHive(
            id: hive.id,
            name: hive.name,
            description: hive.description,
            createdAt: hive.createdAt,
            updatedAt: DateTime.now(),
            completedToday: hive.completedToday,
            completedDates: hive.lastCompletedAt != null 
                ? [hive.lastCompletedAt!] 
                : [],
            lastCompletedAt: hive.lastCompletedAt,
            needsSync: true,
          );
          await _box.put(id, migratedHive);
        }
      }
    } catch (e) {
      await _box.clear();
    }
    _initialized = true;
  }

  /// Lädt alle Habits aus Supabase und synchronisiert sie mit der lokalen Hive-Datenbank
  Future<void> syncFromSupabase() async {
    final supabase = SyncService().supabase;
    // Only pull rows that belong to this device (device-scoped sync)
    final deviceId = await DeviceId.getOrCreate();
    // Hybrid: pull rows for this device OR server-seeded rows (device_id IS NULL)
    final response = await supabase.from('habits').select().or("device_id.eq.'$deviceId',device_id.is.null");
    for (final json in response) {
      final remoteHabit = Habit.fromJson(Map<String, dynamic>.from(json));
      final local = await getById(remoteHabit.id);
      if (local == null) {
        // Nur remote vorhanden: lokal speichern
        await _box.put(remoteHabit.id, HabitHive.fromHabit(remoteHabit));
      } else {
        // Konfliktlösung: updatedAt entscheidet
        if (remoteHabit.updatedAt.isAfter(local.updatedAt)) {
          await _box.put(remoteHabit.id, HabitHive.fromHabit(remoteHabit));
        }
      }
    }
  }

  /// Lädt alle lokalen Habits, die needsSync=true, zu Supabase hoch
  Future<void> uploadLocalChanges() async {
    final supabase = SyncService().supabase;
    final dirtyHabits = _box.values
        .map((hive) => hive.toHabit())
        .where((h) => h.needsSync)
        .toList();
    for (final habit in dirtyHabits) {
      final deviceId = await DeviceId.getOrCreate();
      final payload = Map<String, dynamic>.from(habit.toJson());
      payload['device_id'] = deviceId;
      await supabase.from('habits').upsert([payload]);
      // Nach erfolgreichem Upload needsSync zurücksetzen
      final updated = habit.copyWith(needsSync: false);
      await _box.put(habit.id, HabitHive.fromHabit(updated));
    }
  }

  /// Führt einen vollständigen Sync durch (bidirektional)
  Future<void> fullSync() async {
    // Mark sync as in-progress so UI can show syncing state
    try {
      SyncService().isSynced.value = false;
    } catch (_) {}
    try {
      await uploadLocalChanges();
      await syncFromSupabase();
    } finally {
      try {
        SyncService().isSynced.value = true;
      } catch (_) {}
    }
  }

  Future<List<Habit>> getAll() async {
    if (!_initialized) await init();
    return _box.values.map((hive) => hive.toHabit()).toList();
  }

  Future<Habit?> getById(String id) async {
    if (!_initialized) await init();
    final hive = _box.get(id);
    return hive?.toHabit();
  }

  Future<void> add(Habit habit) async {
    if (!_initialized) await init();
    await _box.put(habit.id, HabitHive.fromHabit(habit));
    await SyncService().addToQueue(habit, 'insert');
    await SyncService().trySync();
  }

  Future<void> update(Habit habit) async {
    if (!_initialized) await init();
    await _box.put(habit.id, HabitHive.fromHabit(habit));
    await SyncService().addToQueue(habit, 'update');
    await SyncService().trySync();
  }

  Future<void> delete(String id) async {
    if (!_initialized) await init();
    final habit = await getById(id);
    await _box.delete(id);
    if (habit != null) {
      await SyncService().addToQueue(habit, 'delete');
      await SyncService().trySync();
    }
  }

  Future<void> clear() async {
    if (!_initialized) await init();
    await _box.clear();
  }

  Stream<List<Habit>> watchAll() {
    return _box.watch().map((_) => getAll()).asyncExpand((future) {
      return Stream.value(future);
    }).asyncMap((future) => future);
  }
}

// Global instance
late final HabitRepository _habitRepository;

Future<void> initializeHabitRepository() async {
  _habitRepository = HabitRepository();
  await _habitRepository.init();
}

HabitRepository getHabitRepository() => _habitRepository;

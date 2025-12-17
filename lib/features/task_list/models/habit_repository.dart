
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'habit.dart';
import 'habit_hive_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/services/device_id.dart';
import 'package:habit_flow/core/providers/sync_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




class HabitRepository {
  final ProviderContainer container;
  static const String _boxName = 'habits';
  late Box<HabitHive> _box;
  bool _initialized = false;

  HabitRepository(this.container);

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(HabitHiveAdapter());
    _box = await Hive.openBox<HabitHive>(_boxName);
    // Normalisiere bestehende Einträge: Schreibe Einträge mit dem aktuellen Adapter/Format neu
    try {
      for (final key in _box.keys.toList()) {
        try {
          final hive = _box.get(key);
          if (hive == null) continue;
          final habit = hive.toHabit();
          final rewritten = HabitHive.fromHabit(habit);
          await _box.put(hive.id, rewritten);
        } catch (e) {
          // Wenn ein Eintrag korrupt oder nicht lesbar ist, entferne ihn, um Abstürze zu vermeiden.
          await _box.delete(key);
        }
      }
    } catch (_) {}
    // await SyncService().init(); // now in provider
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
    final supabase = Supabase.instance.client;
    try {
      // Nur Zeilen abrufen, die zu diesem Gerät gehören (gerätbezogene Synchronisation)
      final deviceId = await DeviceId.getOrCreate();
      // Hybrid: Zeilen für dieses Gerät ODER vom Server angelegte Zeilen abrufen (device_id IST NULL)
      final response = await supabase.from('habits').select().or("device_id.eq.'$deviceId',device_id.is.null");
      for (final json in response) {
        try {
          final remoteHabit = Habit.fromJson(Map<String, dynamic>.from(json));
          final local = await getById(remoteHabit.id);
          if (local == null) {
            // Nur remote vorhanden: lokal speichern
            await _box.put(remoteHabit.id, HabitHive.fromHabit(remoteHabit));
          } else {
            // Konfliktlösung: `updatedAt` entscheidet
            if (remoteHabit.updatedAt.isAfter(local.updatedAt)) {
              await _box.put(remoteHabit.id, HabitHive.fromHabit(remoteHabit));
            }
          }
        } catch (e) {
          debugPrint('[HabitRepository] Failed to apply remote habit entry: $e');
          // continue with next entry
        }
      }
    } catch (e) {
      debugPrint('[HabitRepository] syncFromSupabase failed: $e');
      // If network is unavailable or Supabase cannot be reached, simply return
      // and keep local data intact. A later retry will pick up pending changes.
      return;
    }
  }

  /// Lädt alle lokalen Habits, die `needsSync=true` haben, zu Supabase hoch
  Future<void> uploadLocalChanges() async {
    final supabase = Supabase.instance.client;
    final dirtyHabits = _box.values
        .map((hive) => hive.toHabit())
        .where((h) => h.needsSync)
        .toList();
    for (final habit in dirtyHabits) {
      try {
        final deviceId = await DeviceId.getOrCreate();
        final payload = Map<String, dynamic>.from(habit.toJson());
        payload['device_id'] = deviceId;
        await supabase.from('habits').upsert([payload]);
        // Nach erfolgreichem Upload `needsSync` zurücksetzen
        final updated = habit.copyWith(needsSync: false);
        await _box.put(habit.id, HabitHive.fromHabit(updated));
      } catch (e) {
        debugPrint('[HabitRepository] uploadLocalChanges: failed to upload habit ${habit.id}: $e');
        // leave needsSync = true so it will be retried later
      }
    }
  }

  Future<void> fullSync() async {
    // Markiere Sync als in Arbeit, damit die UI einen Sync-Zustand anzeigen kann
    final syncNotifier = container.read(syncServiceProvider.notifier);
    syncNotifier.setIsSynced(false);
    var success = false;
    try {
      await uploadLocalChanges();
      await syncFromSupabase();
      success = true;
    } catch (e) {
      debugPrint('[HabitRepository] fullSync failed: $e');
      success = false;
    } finally {
      syncNotifier.setIsSynced(success);
    }
  }

  Future<List<Habit>> getAll() async {
    if (!_initialized) await init();
    final list = _box.values.map((hive) => hive.toHabit()).toList();
    // Sort by creation time descending so newest items appear at the top.
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<Habit?> getById(String id) async {
    if (!_initialized) await init();
    final hive = _box.get(id);
    return hive?.toHabit();
  }

  Future<void> add(Habit habit) async {
    if (!_initialized) await init();
    await _box.put(habit.id, HabitHive.fromHabit(habit));
    final syncNotifier = container.read(syncServiceProvider.notifier);
    await syncNotifier.addToQueue(habit, 'insert');
    await syncNotifier.trySync();
  }

  Future<void> update(Habit habit) async {
    if (!_initialized) await init();
    await _box.put(habit.id, HabitHive.fromHabit(habit));
    final syncNotifier = container.read(syncServiceProvider.notifier);
    await syncNotifier.addToQueue(habit, 'update');
    await syncNotifier.trySync();
  }

  Future<void> delete(String id) async {
    if (!_initialized) await init();
    final habit = await getById(id);
    await _box.delete(id);
    if (habit != null) {
      final syncNotifier = container.read(syncServiceProvider.notifier);
      await syncNotifier.addToQueue(habit, 'delete');
      await syncNotifier.trySync();
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

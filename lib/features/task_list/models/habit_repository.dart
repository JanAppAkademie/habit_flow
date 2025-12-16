import 'package:hive_ce/hive.dart';
import 'habit.dart';
import 'habit_hive_adapter.dart';
import 'package:habit_flow/core/services/sync_service.dart';

class HabitRepository {
  static const String _boxName = 'habits';
  late Box<HabitHive> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(HabitHiveAdapter());
    _box = await Hive.openBox<HabitHive>(_boxName);
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
            completedToday: hive.completedToday,
            completedDates: hive.lastCompletedAt != null 
                ? [hive.lastCompletedAt!] 
                : [],
            lastCompletedAt: hive.lastCompletedAt,
          );
          await _box.put(id, migratedHive);
        }
      }
    } catch (e) {
      await _box.clear();
    }
    _initialized = true;
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

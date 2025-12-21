import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:habit_flow/core/sync/habit_sync_service.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';

class HabitListController extends StateNotifier<List<Habit>> {
  HabitListController(this._box, this._syncService) : super(const []) {
    _subscription = _box.watch().listen((_) {
      _emitCurrentHabits();
    });
    _emitCurrentHabits();
  }

  final Box<Habit> _box;
  final HabitSyncService _syncService;
  late final StreamSubscription<BoxEvent> _subscription;

  void _emitCurrentHabits() {
    state = List.unmodifiable(_box.values.toList(growable: false));
  }

  Future<void> addHabit(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final habit = Habit(title: trimmed);
    await _box.add(habit);
    await _syncService.queueUpsert(habit);
  }

  Future<void> editHabit(Habit habit, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;
    habit.title = trimmed;
    habit.touch();
    await habit.save();
    await _syncService.queueUpsert(habit);
  }

  Future<void> deleteHabit(Habit habit) async {
    final id = habit.id;
    await habit.delete();
    await _syncService.queueDelete(id);
  }

  Future<void> toggleHabitCompletion(Habit habit) async {
    if (habit.isCompletedToday) {
      habit.resetCompletion();
    } else {
      habit.markCompletedToday();
    }
    await habit.save();
    await _syncService.queueUpsert(habit);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final habitBoxProvider = Provider<Box<Habit>>((ref) {
  return Hive.box<Habit>(Habit.boxName);
});

final habitListControllerProvider =
    StateNotifierProvider<HabitListController, List<Habit>>((ref) {
      final box = ref.watch(habitBoxProvider);
      final syncService = ref.watch(habitSyncServiceProvider);
      return HabitListController(box, syncService);
    });

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';

class HabitListController extends StateNotifier<List<Habit>> {
  HabitListController(this._box) : super(const []) {
    _subscription = _box.watch().listen((_) {
      _emitCurrentHabits();
    });
    _emitCurrentHabits();
  }

  final Box<Habit> _box;
  late final StreamSubscription<BoxEvent> _subscription;

  void _emitCurrentHabits() {
    state = List.unmodifiable(_box.values.toList(growable: false));
  }

  Future<void> addHabit(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _box.add(Habit(title: trimmed));
  }

  Future<void> editHabit(Habit habit, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;
    habit.title = trimmed;
    await habit.save();
  }

  Future<void> deleteHabit(Habit habit) async {
    await habit.delete();
  }

  Future<void> toggleHabitCompletion(Habit habit) async {
    if (habit.isCompletedToday) {
      habit.resetCompletion();
    } else {
      habit.markCompletedToday();
    }
    await habit.save();
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
  return HabitListController(box);
});

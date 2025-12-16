import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Habit List Notifier
class HabitListNotifier extends Notifier<List<Habit>> {
  late Box _habitBox;

  @override
  List<Habit> build() {
    _habitBox = Hive.box('habits');
    return _loadHabits();
  }

  List<Habit> _loadHabits() {
    final habits = <Habit>[];
    for (var key in _habitBox.keys) {
      final habitJson = _habitBox.get(key);
      if (habitJson != null && habitJson is Map) {
        try {
          habits.add(Habit.fromJson(Map<String, dynamic>.from(habitJson)));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    return habits;
  }

  Future<void> addHabit(String name, {String? description, String userId = 'guest'}) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userId,
    );

    await _habitBox.put(habit.id, habit.toJson());
    state = [...state, habit];
  }

  Future<void> toggleHabit(String id) async {
    final habitIndex = state.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;

    final habit = state[habitIndex];
    final updatedHabit = habit.isCompletedToday
        ? habit.markAsIncomplete()
        : habit.markAsCompleted();

    await _habitBox.put(id, updatedHabit.toJson());
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == habitIndex) updatedHabit else state[i],
    ];
  }

  Future<void> updateHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
    await _habitBox.put(habit.id, updatedHabit.toJson());

    state = [
      for (final h in state)
        if (h.id == habit.id) updatedHabit else h,
    ];
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> clearAllHabits() async {
    await _habitBox.clear();
    state = [];
  }
}

// Habit List Provider
final habitListProvider = NotifierProvider<HabitListNotifier, List<Habit>>(
  HabitListNotifier.new,
);

// Active Habits Provider (derived state)
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.where((h) => h.isActive).toList();
});

// Completed Today Count Provider (derived state)
final completedTodayCountProvider = Provider<int>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.where((h) => h.isCompletedToday).length;
});

// Total Habits Count Provider (derived state)
final totalHabitsCountProvider = Provider<int>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.length;
});

// Habits with Active Streaks Provider (derived state)
final habitsWithStreaksProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.where((h) => h.streakCount > 0).toList()
    ..sort((a, b) => b.streakCount.compareTo(a.streakCount));
});

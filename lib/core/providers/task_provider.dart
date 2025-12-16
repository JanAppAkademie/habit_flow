import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:habit_flow/core/models/habit.dart';

class TasksNotifier extends Notifier<List<Habit>> {
  late Box<Habit> _box;

  @override
  List<Habit> build() {
    // Box öffnen (in main.dart bereits geöffnet)
    _box = Hive.box<Habit>('habits');

    // Initialer State = Inhalt der Box
    return _box.values.toList();
  }

  void addTask(String title) {
    final habit = Habit(title: title);
    _box.add(habit);
    state = _box.values.toList();
  }

  void toggleTask(int index) {
    final habit = state[index];
    final updated = habit.copyWith(isDone: !habit.isDone);
    _box.putAt(index, updated);
    state = _box.values.toList();
  }

  void removeTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  void updateTask(int index, String newTitle) {
    final habit = state[index];
    final updated = habit.copyWith(title: newTitle);
    _box.putAt(index, updated);
    state = _box.values.toList();
  }

  void incrementStreak(int index) {
    final habit = state[index];
    final updated = habit.copyWith(streakCount: habit.streakCount + 1);
    _box.putAt(index, updated);
    state = _box.values.toList();
  }
}

// Provider
final tasksProvider = NotifierProvider<TasksNotifier, List<Habit>>(() {
  return TasksNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/models/habit.dart';

// Notifier für Habits
class TasksNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => [];

  void addTask(String title) {
    state = [...state, Habit(title: title)];
  }

  void toggleTask(int index) {
    final habit = state[index];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          habit.copyWith(isDone: !habit.isDone)
        else
          state[i],
    ];
  }

  void removeTask(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void incrementStreak(int index) {
    final habit = state[index];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          habit.copyWith(streakCount: habit.streakCount + 1)
        else
          state[i],
    ];
  }
}

// Provider
final tasksProvider = NotifierProvider<TasksNotifier, List<Habit>>(() {
  return TasksNotifier();
});

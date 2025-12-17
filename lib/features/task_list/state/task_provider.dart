import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/services/hive_service.dart';

final taskListProvider = NotifierProvider<TaskListNotifier, List<Habit>>(
  TaskListNotifier.new,
);

class TaskListNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    return HiveService.getAllTasks();
  }

  Future<void> addTask(Habit habit) async {
    await HiveService.addTask(habit);
    state = [...state, habit];
  }

  Future<void> updateTask(int index, Habit habit) async {
    await HiveService.updateTask(index, habit);

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) habit else state[i],
    ];
  }

  Future<void> deleteTask(int index) async {
    await HiveService.deleteTask(index);

    state = state.where((habit) => state.indexOf(habit) != index).toList();

  }
}

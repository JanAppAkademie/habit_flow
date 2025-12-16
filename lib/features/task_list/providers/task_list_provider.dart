import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../data/repositories/habit_repository.dart';
import '../models/task.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final box = Hive.box<Task>(HabitRepository.tasksBoxName);
  return HabitRepository(box);
});

final taskListProvider = NotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

class TaskListNotifier extends Notifier<List<Task>> {
  StreamSubscription? _subscription;
  late HabitRepository _repository;

  @override
  List<Task> build() {
    _repository = ref.watch(habitRepositoryProvider);
    _subscription?.cancel();
    _subscription = _repository.watchTasks().listen((_) {
      state = _repository.getTasks();
    });
    ref.onDispose(() => _subscription?.cancel());
    return _repository.getTasks();
  }

  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmed,
    );

    await _repository.saveTask(task);
  }

  Future<void> renameTask(Task task, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed == task.title) return;

    final updated = task.copyWith(title: trimmed);
    await _repository.saveTask(updated);
  }

  Future<void> toggleTask(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repository.saveTask(updated);
  }

  Future<void> deleteTask(Task task) async {
    await _repository.deleteTask(task.id);
  }
}

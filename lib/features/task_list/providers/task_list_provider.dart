import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../sync/data/habit_sync_repository.dart';
import '../../sync/providers/habit_sync_provider.dart';
import '../../streaks/providers/streak_provider.dart';
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
  late final HabitSyncRepository _syncRepository;

  @override
  List<Task> build() {
    _repository = ref.watch(habitRepositoryProvider);
    _syncRepository = ref.watch(habitSyncRepositoryProvider);
    final tasks = _repository.getTasks();
    _subscription?.cancel();
    _subscription = _repository.watchTasks().listen((_) {
      final updatedTasks = _repository.getTasks();
      state = updatedTasks;
      _updateStreak(updatedTasks);
    });
    ref.onDispose(() => _subscription?.cancel());
    Future.microtask(() => _updateStreak(tasks));
    return tasks;
  }

  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmed,
      updatedAt: DateTime.now(),
    );

    await _repository.saveTask(task);
    _updateStreak(_repository.getTasks());
    await _maybeAutoSync();
  }

  Future<void> renameTask(Task task, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed == task.title) return;

    final updated = task.copyWith(
      title: trimmed,
      updatedAt: DateTime.now(),
    );
    await _repository.saveTask(updated);
    _updateStreak(_repository.getTasks());
    await _maybeAutoSync();
  }

  Future<void> toggleTask(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.saveTask(updated);
    _updateStreak(_repository.getTasks());
    await _maybeAutoSync();
  }

  Future<void> deleteTask(Task task) async {
    await _repository.deleteTask(task.id);
    _updateStreak(_repository.getTasks());
    await _maybeAutoSync();
  }

  Future<void> syncNow() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final tasks = _repository.getTasks();
    await _syncRepository.pushTasks(userId: user.id, tasks: tasks);
    final remoteTasks = await _syncRepository.pullTasks(userId: user.id);
    final localIds = tasks.map((task) => task.id).toSet();
    final remoteOnlyIds = remoteTasks
        .where((task) => !localIds.contains(task.id))
        .map((task) => task.id);
    await _syncRepository.deleteTasks(
      userId: user.id,
      taskIds: remoteOnlyIds,
    );
  }

  Future<void> _maybeAutoSync() async {
    final autoSync =
        await ref.read(settingsRepositoryProvider).getAutoSync();
    if (!autoSync) return;
    await syncNow();
  }

  void _updateStreak(List<Task> tasks) {
    ref.read(streakProvider.notifier).updateFromTasks(tasks);
  }
}

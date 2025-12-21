import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task_list/models/task.dart';
import '../data/streak_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository();
});

final streakProvider = AsyncNotifierProvider<StreakNotifier, int>(
  StreakNotifier.new,
);

class StreakNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final repository = ref.watch(streakRepositoryProvider);
    return repository.getStreakCount();
  }

  Future<void> updateFromTasks(List<Task> tasks) async {
    if (tasks.isEmpty) return;
    final allCompleted = tasks.every((task) => task.isCompleted);
    if (!allCompleted) return;

    final repository = ref.read(streakRepositoryProvider);
    final newStreak = await repository.recordCompletion(DateTime.now());
    state = AsyncValue.data(newStreak);
  }

  Future<void> refresh() async {
    final repository = ref.read(streakRepositoryProvider);
    final value = await repository.getStreakCount();
    state = AsyncValue.data(value);
  }
}

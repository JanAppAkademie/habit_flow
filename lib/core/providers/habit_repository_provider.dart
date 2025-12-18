import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';

late HabitRepository habitRepositoryGlobal;

final habitRepositoryProvider = Provider<HabitRepository>((ref) => habitRepositoryGlobal);

final habitProvider = FutureProvider<List<Habit>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getAll();
});
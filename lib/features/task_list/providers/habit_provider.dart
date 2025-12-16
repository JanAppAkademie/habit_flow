import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';

final habitProvider = FutureProvider<List<Habit>>((ref) async {
  return getHabitRepository().getAll();
});

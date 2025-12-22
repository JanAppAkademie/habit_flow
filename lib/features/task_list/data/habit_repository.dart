import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/features/task_list/data/habit_local_data_source.dart';
import 'package:habit_flow/features/task_list/data/habit_remote_data_source.dart';

class HabitRepository {
  final HabitLocalDataSource local;
  final HabitRemoteDataSource remote;

  HabitRepository({required this.local, required this.remote});

  Future<List<Habit>> sync() async {
    final localHabits = local.getAll();
    final remoteHabits = await remote.fetchAll();
    final mergedHabits = localHabits + remoteHabits;
    return mergedHabits;
  }
}

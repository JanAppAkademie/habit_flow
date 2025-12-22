import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/models/habit.dart';

part 'habit_provider.g.dart';

@riverpod
class HabitList extends _$HabitList {
  @override
  Future<List<Habit>> build() async {
    final box = await Hive.openBox<Habit>('habitsBox');
    return box.values.toList();
  }

  Future<void> addHabit(String name) async {
    final box = Hive.box<Habit>('habitsBox');

    final newHabit = Habit(
      name: name,
      createdAt: DateTime.now(),
    );

    await box.add(newHabit);

    final oldList = state.value ?? [];

    final newList = List<Habit>.from(oldList);

    newList.add(newHabit);
    state = AsyncData(newList);
  }

  Future<void> toggleHabit(Habit habit) async {
    habit.isCompleted = !(habit.isCompleted ?? false);

    await habit.save();
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(Habit habit) async {
    await habit.delete();
    ref.invalidateSelf();
  }
}

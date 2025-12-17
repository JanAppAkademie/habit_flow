import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/hive/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService {
  static late Box<Habit> _taskBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapters();

    // Boxen öffnen
    _taskBox = await Hive.openBox<Habit>('tasks');
  }

  static List<Habit> getAllTasks() => _taskBox.values.toList();

  static Future<void> addTask(Habit habit) async => await _taskBox.add(habit);

  static Future<void> updateTask(int key, Habit habit) async =>
      await _taskBox.put(key, habit);

  static Future<void> deleteTask(int index) async =>
      await _taskBox.delete(index);
      
  static Box<Habit> get petBox => _taskBox;
}

import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/services/hive_service.dart';

class HabitLocalDataSource {
  List<Habit> getAll() {
    return HiveService.getAllTasks();
  }
}

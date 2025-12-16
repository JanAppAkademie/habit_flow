import 'package:hive_ce/hive.dart';
import 'package:habit_flow/features/task_list/models/task.dart';

class HabitRepository {
  HabitRepository(this._taskBox);

  static const tasksBoxName = 'tasksBox';

  final Box<Task> _taskBox;

  static Future<void> initStore() async {
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isBoxOpen(tasksBoxName)) {
      await Hive.openBox<Task>(tasksBoxName);
    }
  }

  List<Task> getTasks() {
    final tasks = _taskBox.values.toList();
    tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return tasks;
  }

  Future<void> saveTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Stream<BoxEvent> watchTasks() => _taskBox.watch();
}

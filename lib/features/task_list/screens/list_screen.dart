import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/task.dart';
import 'package:habit_flow/features/task_list/providers/task_list_provider.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  Future<void> _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
  }) async {
    final controller = TextEditingController(text: task?.title ?? '');
    final notifier = ref.read(taskListProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Titel der Aufgabe'),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (task == null) {
                  notifier.addTask(controller.text);
                } else {
                  notifier.renameTask(task, controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final notifier = ref.read(taskListProvider.notifier);
    final completedCount = tasks
        .where((task) => task.isCompleted)
        .length; // progress counter
    final progressValue = tasks.isEmpty
        ? 0.0
        : completedCount / tasks.length.toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: tasks.isEmpty
          ? const EmptyContent()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$completedCount von ${tasks.length} erledigt'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progressValue),
                    ],
                  ),
                ),
                Expanded(
                  child: ItemList(
                    tasks: tasks,
                    onToggle: notifier.toggleTask,
                    onEdit: (task) => _showTaskDialog(context, ref, task: task),
                    onDelete: notifier.deleteTask,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

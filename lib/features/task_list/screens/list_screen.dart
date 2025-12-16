import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/task_provider.dart';
import 'package:habit_flow/features/task_list/widgets/addtaskbutton.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';
import 'package:habit_flow/features/task_list/widgets/edittaskdialog.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: tasks.isEmpty
          ? const EmptyContent()
          : ItemList(
              items: tasks, // direkt Habits übergeben
              onEdit: (index) {
                showDialog(
                  context: context,
                  builder: (_) => EditTaskDialog(
                    initialValue: tasks[index].title,
                    onSave: (updatedTitle) {
                      ref.read(tasksProvider.notifier).updateTask(index, updatedTitle);
                    },
                  ),
                );
              },
              onDelete: (index) {
                ref.read(tasksProvider.notifier).removeTask(index);
              },
              onToggle: (index) {
                ref.read(tasksProvider.notifier).toggleTask(index);
              },
            ),
      floatingActionButton: const AddTaskButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

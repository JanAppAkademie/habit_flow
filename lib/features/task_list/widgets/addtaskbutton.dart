import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/task_provider.dart';
import 'package:habit_flow/features/task_list/widgets/edittaskdialog.dart';

class AddTaskButton extends ConsumerWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => EditTaskDialog(
            onSave: (newTitle) {
              ref.read(tasksProvider.notifier).addTask(newTitle);
            },
          ),
        );
      },
      child: const Text("Task hinzufügen"),
    );
  }
}

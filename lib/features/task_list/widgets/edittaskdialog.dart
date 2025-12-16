import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/task_provider.dart';

class EditTaskDialog extends ConsumerWidget {
  const EditTaskDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('Task bearbeiten'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Gib einen Task ein',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(tasksProvider.notifier).addTask(controller.text);
            Navigator.pop(context);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

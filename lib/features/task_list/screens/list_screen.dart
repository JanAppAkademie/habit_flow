import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/provider/item_provider.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends ConsumerWidget {
  ListScreen({super.key});

  final TextEditingController _addController = TextEditingController();

  void openNewTask(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task hinzufügen'),
        content: TextField(
          autofocus: true,
          controller: _addController,
          decoration: const InputDecoration(hintText: "Task hinzufügen"),
        ),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
              _addController.clear();
            },
          ),
          TextButton(
            child: const Text('Speichern'),
            onPressed: () {
              if (_addController.text.isNotEmpty) {
                ref.read(itemProvider.notifier).addItem(_addController.text);
              }
              _addController.clear();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const EmptyContent()
                  : ItemList(
                      items: items,
                      onEdit: (index, newItem) {
                        ref
                            .read(itemProvider.notifier)
                            .editItem(index, newItem);
                      },
                      onDelete: (index) {
                        ref.read(itemProvider.notifier).deleteItem(index);
                      },
                    ),
            ),
            TextButton(
              onPressed: () => openNewTask(context, ref),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Text("Task Hinzufügen"), Icon(Icons.add)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';
import 'package:hive_ce/hive.dart';

final itemProvider = NotifierProvider<ItemNotifier, List<String>>(
  ItemNotifier.new,
);

class ItemNotifier extends Notifier<List<String>> {
  late final Box box;

  @override
  List<String> build() {
    box = Hive.box('HabitFlowBox');

    // Listen to changes in Hive box
    box.watch(key: 'TODO_LIST').listen((_) {
      state = box.get('TODO_LIST', defaultValue: <String>[]).cast<String>();
    });

    // Initial state
    return box.get('TODO_LIST', defaultValue: <String>[]).cast<String>();
  }

  void addItem(String item) {
    final updatedList = [...state, item];
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }

  void editItem(int index, String newItem) {
    final updatedList = [...state];
    updatedList[index] = newItem;
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }

  void deleteItem(int index) {
    final updatedList = [...state]..removeAt(index);
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }
}

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
    final _items = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? const EmptyContent()
                  : ItemList(
                      items: _items,
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

import 'package:flutter/material.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<String> _items = [];
  final TextEditingController _addController = TextEditingController();
  final _habitBox = Hive.box("HabitFlowBox");

  @override
  void initState() {
    _items = _habitBox.get("TODO_LIST") ?? [];
    super.initState();
  }

  void openNewTask() {
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
              Navigator.of(context).pop();
              addTask();
            },
          ),
        ],
      ),
    );
  }

  void addTask() {
    String task = _addController.text;
    setState(() {
      _items.add(task);
      _addController.clear();
    });
    saveToDatabase();
  }

  void deleteTodo(int index) {
    setState(() {
      _items.removeAt(index);
    });
    saveToDatabase();
  }

  void editTodo(int index, edit) {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, edit);
    });
    saveToDatabase();
  }

  void saveToDatabase() {
    _habitBox.put("TODO_LIST", _items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? const EmptyContent()
                  : ItemList(
                      items: _items,
                      onEdit: (index, newItem) {
                        editTodo(index, newItem);
                      },
                      onDelete: (index) {
                        deleteTodo(index);
                      },
                    ),
            ),
            TextButton(
              onPressed: openNewTask,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Task Hinzufügen"), Icon(Icons.add)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

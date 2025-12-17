//features/task_list/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/widgets/app_bar.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';
import 'package:uuid/uuid.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _uuid = const Uuid();
  late final Box<Habit> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<Habit>('habits');
  }

  Future<void> addHabit() async {
    final controller = TextEditingController();

    final name = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task hinzufügen'),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final habit = Habit(
      id: _uuid.v4(),
      name: trimmed,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      deleted: false,
    );

    await box.put(habit.id, habit); // key = id
  }

  Future<void> editHabit(Habit habit) async {
    final controller = TextEditingController(text: habit.name);

    final newName = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task bearbeiten'),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    final trimmed = (newName ?? '').trim();
    if (trimmed.isEmpty) return;

    await box.put(
      habit.id,
      habit.copyWith(name: trimmed, updatedAt: DateTime.now()),
    );
  }

  Future<void> deleteHabit(Habit habit) async {
    await box.delete(habit.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabitAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.where((h) => !h.deleted).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (habits.isEmpty) return const EmptyContent();

          return ItemList(
            items: habits.map((h) => h.name).toList(),
            onEdit: (index, newItem) async {
              final habit = habits[index];
              final trimmed = newItem.trim();
              if (trimmed.isEmpty) return;

              await box.put(
                habit.id,
                habit.copyWith(name: trimmed, updatedAt: DateTime.now()),
              );
            },
            onDelete: (index) async {
              final habit = habits[index];
              await box.delete(habit.id);
            },
          );
        },
      ),
    );
  }
}

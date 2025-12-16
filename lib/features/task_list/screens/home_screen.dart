import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/task_provider.dart';
import 'package:habit_flow/features/task_list/widgets/edittaskdialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      body: ListView(
        children: tasks.map((t) => ListTile(title: Text(t.title))).toList(),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const EditTaskDialog(),
          );
        },
        child: const Text("Aufgabe hinzufügen"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // 👉 Hier wieder einsetzen
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: Navigation
        },
      ),
    );
  }
}

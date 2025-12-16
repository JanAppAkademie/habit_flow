import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/providers/task_provider.dart';
import 'package:habit_flow/features/task_list/widgets/addtaskbutton.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: tasks.isEmpty
          ? const EmptyContent()
          : ListView(
              children: tasks.map((t) => ListTile(
                title: Text(t.title),
                trailing: Icon(
                  t.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: t.isDone ? Colors.green : null,
                ),
                onTap: () {
                  final index = tasks.indexOf(t);
                  ref.read(tasksProvider.notifier).toggleTask(index);
                },
              )).toList(),
            ),

      floatingActionButton: const AddTaskButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

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
          if (index == 0) {
            context.go(AppRoutes.list);   // zum ListScreen!
          } else if (index == 1) {
            // später Statistik‑Screen einbauen
          }
        },
      ),
    );
  }
}

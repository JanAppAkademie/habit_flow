import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/features/task_list/state/task_provider.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends ConsumerWidget {
  ListScreen({super.key});

  final textController = TextEditingController();
  final selectedIndex = ValueNotifier<int>(0); // Optional für NavigationBar

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(taskListProvider);
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Habit Flow'))),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.purple);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: Colors.purple);
            }

            return TextStyle(color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex.value,
          destinations: [
            NavigationDestination(icon: Icon(Icons.list), label: "Aufgaben"),
            NavigationDestination(
              icon: Icon(Icons.stacked_line_chart),
              label: "Statistik",
            ),
          ],
          onDestinationSelected: (value) => selectedIndex.value = value,
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const EmptyContent()
            : Column(
                children: [
                  Expanded(
                    child: ItemList(
                      items: items,
                      onEdit: (index, newItem) async {
                        //final habit = items[index];
                        await ref
                            .read(taskListProvider.notifier)
                            .updateTask(index, newItem);
                      },
                      onDelete: (index) async {
                        await ref
                            .read(taskListProvider.notifier)
                            .deleteTask(index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: "Task Hinzufügen",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            if (textController.text.isEmpty) return;

                            final newHabit = Habit(name: textController.text);
                            await ref
                                .read(taskListProvider.notifier)
                                .addTask(newHabit);
                            textController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

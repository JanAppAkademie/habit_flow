import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/providers/habit_provider.dart';

class ItemList extends ConsumerWidget {
  const ItemList({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) {
    final nameController = TextEditingController(text: habit.name);
    final descriptionController = TextEditingController(
      text: habit.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gewohnheit bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Name der Gewohnheit",
                  labelText: "Name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "Beschreibung (optional)",
                  labelText: "Beschreibung",
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Speichern'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final updatedHabit = habit.copyWith(
                    name: nameController.text,
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  );
                  ref.read(habitListProvider.notifier).updateHabit(updatedHabit);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gewohnheit löschen?'),
          content: Text(
            'Möchtest du "${habit.name}" wirklich löschen? Dies kann nicht rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Löschen'),
              onPressed: () {
                ref.read(habitListProvider.notifier).deleteHabit(habit.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habit.isCompletedToday;
        final streakCount = habit.streakCount;

        return Card(
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (_) {
                ref.read(habitListProvider.notifier).toggleHabit(habit.id);
              },
            ),
            title: Text(
              habit.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (habit.description != null && habit.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      habit.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (streakCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '$streakCount Tage Streak',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, ref, habit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, ref, habit),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

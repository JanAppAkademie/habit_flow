import 'package:flutter/material.dart';
import 'package:habit_flow/core/models/habit.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    this.onToggle,
  });

  final List<Habit> items;
  final void Function(int index) onEdit;
  final void Function(int index) onDelete;
  final void Function(int index)? onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final habit = items[index];
        return ListTile(
          title: Text(habit.title),
          subtitle: Text('Streak: ${habit.streakCount}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(index),
              ),
              IconButton(
                icon: Icon(
                  habit.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: habit.isDone ? Colors.green : null,
                ),
                onPressed: () => onToggle?.call(index),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 1, color: Colors.white10),
    );
  }
}

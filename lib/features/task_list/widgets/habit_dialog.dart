import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';

class HabitDialog extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitDialog({
    super.key,
    this.habit,
  });

  @override
  ConsumerState<HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends ConsumerState<HabitDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.habit?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.habit == null ? 'Neue Gewohnheit' : 'Gewohnheit bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Meditation',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                hintText: 'z.B. 10 Minuten Morgen-Meditation',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bitte geben Sie einen Namen ein')),
              );
              return;
            }

            final habit = widget.habit != null
                ? widget.habit!.copyWith(
                    name: _nameController.text,
                    description: _descriptionController.text,
                  )
                : Habit(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    createdAt: DateTime.now(),
                    completedToday: false,
                    completedDates: [],
                    lastCompletedAt: null,
                  );

            Navigator.pop(context, habit);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

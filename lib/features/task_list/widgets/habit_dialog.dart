import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
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
      title: Text(widget.habit == null ? 'habit_dialog.new'.tr() : 'habit_dialog.edit'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'habit_dialog.name'.tr(),
                hintText: 'habit_dialog.name_hint'.tr(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'habit_dialog.description'.tr(),
                hintText: 'habit_dialog.description_hint'.tr(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('habit_dialog.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('habit_dialog.name_required'.tr())),
              );
              return;
            }

            final habit = widget.habit != null
                ? widget.habit!.copyWith(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    updatedAt: DateTime.now(),
                    needsSync: true,
                  )
                : Habit(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    completedToday: false,
                    completedDates: [],
                    lastCompletedAt: null,
                    needsSync: true,
                  );

            Navigator.pop(context, habit);
          },
          child: Text('habit_dialog.save'.tr()),
        ),
      ],
    );
  }
}

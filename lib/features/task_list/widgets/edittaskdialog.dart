import 'package:flutter/material.dart';

class EditTaskDialog extends StatelessWidget {
  final String? initialValue;                // optionaler Startwert
  final void Function(String) onSave;        // Callback für Speichern

  const EditTaskDialog({
    super.key,
    this.initialValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue ?? '');

    return AlertDialog(
      title: Text(initialValue == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Gib einen Task ein',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            onSave(controller.text);         // Übergibt den Wert zurück
            Navigator.pop(context);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

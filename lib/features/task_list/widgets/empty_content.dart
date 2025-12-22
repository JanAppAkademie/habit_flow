import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/data.dart';
import 'package:habit_flow/features/task_list/screens/list_screen.dart';

class EmptyContent extends StatelessWidget {
  EmptyContent({super.key});

  ListScreen test = const ListScreen();

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sentiment_satisfied_alt, size: 144),
          const SizedBox(height: 10),
          TextField(
            autocorrect: false,
            controller: controller,
            decoration: const InputDecoration(hintText: "To Do Aufgabe"),
          ),
          TextButton(
            onPressed: () {
              addItems(controller.text);

              context.push("/list");
            },
            child: const Text("Hinzufügen"),
          ),
        ],
      ),
    );
  }
}

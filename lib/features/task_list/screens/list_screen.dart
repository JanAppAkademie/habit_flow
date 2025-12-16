import 'package:flutter/material.dart';
import 'package:habit_flow/data.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  //final List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: items.isEmpty
          ? EmptyContent()
          : ItemList(
              items: items,
              onEdit: (index, newItem) {},
              onDelete: (index) {},
            ),
    );
  }
}

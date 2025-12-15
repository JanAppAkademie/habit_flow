import 'package:flutter/material.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<String> _items = [
    'Aufstehen',
    'Zähne putze',
    'Kurs Vorlesung',
    'Kurs Tutorium I',
    'Mittag',
    'Sport',
    'Kurs Tutorium II',
    'Essen',
    'Sport',
    'TV schauen',
    'Schlafen gehen',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Flow')),
      body: _items.isEmpty
          ? const EmptyContent()
          : ItemList(items: _items, onEdit: (index, newItem) {}, onDelete: (index) {}),
    );
  }
}

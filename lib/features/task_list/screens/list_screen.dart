import 'package:flutter/material.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<String> _items = ["Test"];
  final textController = TextEditingController();
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
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
          selectedIndex: _selectedIndex,
          destinations: [
            NavigationDestination(icon: Icon(Icons.list), label: "Aufgaben"),
            NavigationDestination(
              icon: Icon(Icons.stacked_line_chart),
              label: "Statistik",
            ),
          ],
          onDestinationSelected: (value) => setState(() {
            _selectedIndex = value;
          }),
        ),
      ),
      body: SafeArea(
        child: _items.isEmpty
            ? const EmptyContent()
            : Column(
                children: [
                  Expanded(
                    child: ItemList(
                      items: _items,
                      onEdit: (index, newItem) {},
                      onDelete: (index) {},
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
                          onPressed: () {},
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

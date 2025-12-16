import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/habit_provider.dart';
import 'package:habit_flow/features/task_list/screens/list_screen.dart';
import 'package:habit_flow/features/statistics/screens/statistics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _taskController = TextEditingController();

  final List<Widget> _screens = const [
    ListScreen(),
    StatisticsScreen(),
  ];

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addHabit() {
    if (_taskController.text.trim().isNotEmpty) {
      ref.read(habitListProvider.notifier).addHabit(
            _taskController.text.trim(),
          );
      _taskController.clear();
      // Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input field for adding new tasks - only show on Aufgaben tab
          if (_currentIndex == 0)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: 'Neue Gewohnheit hinzufügen...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        onSubmitted: (_) => _addHabit(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addHabit,
                      icon: const Icon(Icons.add),
                      tooltip: 'Hinzufügen',
                    ),
                  ],
                ),
              ),
            ),
          // Bottom Navigation Bar
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.checklist),
                label: 'Aufgaben',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart),
                label: 'Statistik',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Habit Flow')),
      body: const ListScreen(),
    );
  }
}

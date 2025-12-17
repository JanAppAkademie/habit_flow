import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await HiveService.addTask(Habit(name: "Test"));
  runApp(ProviderScope(child: const App()));
}

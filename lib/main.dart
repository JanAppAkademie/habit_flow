import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:habit_flow/core/services/hive_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await HiveService.addTask(Habit(name: "Test"));
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    anonKey: dotenv.get('SUPABASE_API'),
    url: dotenv.get('SUPABASE_URL'),
  );
  runApp(ProviderScope(child: const App()));
}

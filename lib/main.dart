import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://iqwzkcxwiyqinrlnlitq.supabase.co';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlxd3prY3h3aXlxaW5ybG5saXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5MDkxMzQsImV4cCI6MjA4MTQ4NTEzNH0.xRGZ79flq4UaAUsbMA9WOgCNmgzyjl9rwA8cW5zg4A8";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habits');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(ProviderScope(child: const App()));
}

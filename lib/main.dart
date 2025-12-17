
import 'package:flutter/material.dart';
import 'package:habit_flow/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:hive_ce/hive.dart';
import 'package:habit_flow/core/models/habit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
Hive.registerAdapter(HabitAdapter());
await Hive.openBox<Habit>('habits');


  await Supabase.initialize(
    url: 'https://jhlafztgakdsujnxxzxp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpobGFmenRnYWtkc3Vqbnh4enhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4NzAwMzAsImV4cCI6MjA4MTQ0NjAzMH0.PVBt9d_JsEj6oWeD8Uy5PYDdFoSl0kIV-wZJEM3YHqw',
  );

  runApp(const App());
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/models/habit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialisieren
  await Hive.initFlutter();

  // Adapter registrieren
  Hive.registerAdapter(HabitAdapter());

  // Box öffnen
  await Hive.openBox<Habit>('habits');

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

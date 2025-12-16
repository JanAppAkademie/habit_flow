import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter
  await Hive.initFlutter();

  // Open Hive boxes (storing objects as JSON strings)
  await Hive.openBox('habits');
  await Hive.openBox('users');
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

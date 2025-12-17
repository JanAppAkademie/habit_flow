import 'package:habit_flow/core/models/habit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([AdapterSpec<Habit>()])
class HiveAdapters {}

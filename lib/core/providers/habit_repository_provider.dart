import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/task_list/models/habit_repository.dart';

late HabitRepository habitRepositoryGlobal;

final habitRepositoryProvider = Provider<HabitRepository>((ref) => habitRepositoryGlobal);
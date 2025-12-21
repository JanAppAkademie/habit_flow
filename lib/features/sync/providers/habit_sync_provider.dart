import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/habit_sync_repository.dart';

final habitSyncRepositoryProvider = Provider<HabitSyncRepository>((ref) {
  final client = Supabase.instance.client;
  return HabitSyncRepository(client);
});

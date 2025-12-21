import 'package:supabase_flutter/supabase_flutter.dart';

import '../../task_list/models/task.dart';

class HabitSyncRepository {
  HabitSyncRepository(this._client);

  final SupabaseClient _client;

  Future<void> pushTasks({
    required String userId,
    required List<Task> tasks,
  }) async {
    if (tasks.isEmpty) return;

    final payload = tasks.map((task) {
      return {
        'id': task.id,
        'user_id': userId,
        'title': task.title,
        'is_completed': task.isCompleted,
        'created_at': task.createdAt.toIso8601String(),
        'updated_at': task.updatedAt.toIso8601String(),
      };
    }).toList();

    await _client.from('habits').upsert(
          payload,
          onConflict: 'id,user_id',
        );
  }

  Future<List<Task>> pullTasks({required String userId}) async {
    final data = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List<dynamic>)
        .map((row) => Task.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTasks({
    required String userId,
    required Iterable<String> taskIds,
  }) async {
    final ids = taskIds.toList();
    if (ids.isEmpty) return;
    await _client
        .from('habits')
        .delete()
        .eq('user_id', userId)
        .inFilter('id', ids);
  }
}

import 'package:habit_flow/core/models/habit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HabitRemoteDataSource {
  Future<List<Habit>> fetchAll() async {
    final client = Supabase.instance.client;
    final response = await client.from('Habit').select();

    return (response as List)
        .map((json) => Habit.fromMap(json as Map<String, dynamic>))
        .toList();
  }
}

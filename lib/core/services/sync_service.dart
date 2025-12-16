import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



/// Einfache Sync-Queue für Habits
class SyncService {
    // ValueNotifier für Sync-Status (true = synchronisiert, false = ausstehend)
    final ValueNotifier<bool> isSynced = ValueNotifier<bool>(true);
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Keine persistente Queue mehr
    final List<Map<String, dynamic>> _queue = [];
  final supabase = Supabase.instance.client;
  StreamSubscription? _connectivitySub;

  Future<void> init() async {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {

      if (result.any((r) => r != ConnectivityResult.none)) {
        trySync();
      }

      
     // if (result != ConnectivityResult.none) {
     //   trySync();
     // }
    });
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _queue.clear();
  }

  Future<void> addToQueue(Habit habit, String action) async {
    // action: 'insert', 'update', 'delete'
    // Ersetze ggf. vorhandene Einträge mit gleicher ID
    _queue.removeWhere((entry) => entry['habit']['id'] == habit.id);
    _queue.add({
      'habit': habit.toJson(),
      'action': action,
    });
    isSynced.value = false;
  }

  Future<void> trySync() async {
    if (_queue.isEmpty) {
      isSynced.value = true;
      debugPrint('[SyncService] Keine ausstehenden Syncs.');
      return;
    }
    debugPrint('[SyncService] Starte Sync für ${_queue.length} Einträge...');
    final toRemove = <Map<String, dynamic>>[];
    for (final entry in _queue) {
      final habitJson = entry['habit'] as Map<String, dynamic>;
      final action = entry['action'] as String;
      try {
        debugPrint('[SyncService] Sync: $action für Habit ${habitJson['id']}');
        if (action == 'delete') {
          await supabase.from('habits').delete().eq('id', habitJson['id']);
        } else {
          await supabase.from('habits').upsert([habitJson]);
        }
        toRemove.add(entry);
      } catch (e) {
        debugPrint('[SyncService] Fehler beim Sync von ${habitJson['id']}: $e');
        // Fehler beim Sync, später erneut versuchen
      }
    }
    _queue.removeWhere((entry) => toRemove.contains(entry));
    isSynced.value = _queue.isEmpty;
    debugPrint('[SyncService] Sync abgeschlossen. Noch ausstehend: ${_queue.length}');
  }
  // Getter für Queue-Länge
  int get queueLength => _queue.length;
}

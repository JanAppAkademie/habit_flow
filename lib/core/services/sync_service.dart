import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/core/services/device_id.dart';
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
  bool _syncRunning = false;

  Future<void> init() async {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      // `onConnectivityChanged` liefert ein einzelnes `ConnectivityResult`.
      if (result.any((status) => status != ConnectivityResult.none)) {
        trySync();
      }
    });
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _queue.clear();
  }

  Future<void> addToQueue(Habit habit, String action) async {
    // Aktion: 'insert', 'update', 'delete'
    // Ersetze ggf. vorhandene Einträge mit gleicher ID
    _queue.removeWhere((entry) => entry['habit']['id'] == habit.id);
    final deviceId = await DeviceId.getOrCreate();
    final payload = Map<String, dynamic>.from(habit.toJson());
    payload['device_id'] = deviceId;
    _queue.add({
      'habit': payload,
      'action': action,
    });
    isSynced.value = false;
  }

  Future<void> trySync() async {
    if (_syncRunning) {
      debugPrint('[SyncService] trySync() called but a sync is already running; skipping');
      return;
    }

    _syncRunning = true;
    try {
      if (_queue.isEmpty) {
        isSynced.value = true;
        debugPrint('[SyncService] No pending syncs.');
        return;
      }
      debugPrint('[SyncService] Starting sync for ${_queue.length} entries...');
    final toRemove = <Map<String, dynamic>>[];
    for (final entry in _queue) {
      final habitJson = entry['habit'] as Map<String, dynamic>;
      final action = entry['action'] as String;
      try {
        debugPrint('[SyncService] Sync: $action for Habit ${habitJson['id']}');
        if (action == 'delete') {
          await supabase.from('habits').delete().eq('id', habitJson['id']);
        } else {
          await supabase.from('habits').upsert([habitJson]);
        }
        toRemove.add(entry);
      } catch (e) {
        debugPrint('[SyncService] Error syncing ${habitJson['id']}: $e');
        // Fehlerbehandlung: Behalte den Eintrag in der Queue für einen späteren Versuch
      }
    }
    _queue.removeWhere((entry) => toRemove.contains(entry));
    isSynced.value = _queue.isEmpty;
    debugPrint('[SyncService] Sync finished. Remaining: ${_queue.length}');
    } finally {
      _syncRunning = false;
    }
  }
  // Getter für Queue-Länge
  int get queueLength => _queue.length;
}

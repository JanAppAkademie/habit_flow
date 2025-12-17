import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
  /// Notifier for running state so UI/providers can listen.
  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);

  /// Expose whether a sync is currently running.
  bool get isRunning => isRunningNotifier.value;

  Future<void> init() async {
    // Use InternetConnectionChecker which actually verifies internet reachability
    // and avoid acting on transient platform connectivity events (e.g. connected to
    // a WiFi network without actual internet). Add a small debounce so DNS can
    // settle before attempting a sync.
    _connectivitySub = InternetConnectionChecker().onStatusChange.listen((status) {
      final online = status == InternetConnectionStatus.connected;
      debugPrint('[SyncService.init] InternetConnectionChecker status: $status -> online=$online');
      if (!online) return;

      // Debounce slightly to avoid racing against flaky DNS/resolution on some networks
      Future.delayed(const Duration(seconds: 1), () async {
        final stillOnline = await InternetConnectionChecker().hasConnection;
        debugPrint('[SyncService.init] post-debounce hasConnection=$stillOnline');
        if (stillOnline) {
          trySync();
        } else {
          debugPrint('[SyncService.init] Skipping trySync() after debounce; no connection');
        }
      });
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
    // Quick pre-check: ensure we actually have working internet before starting.
    final hasNet = await InternetConnectionChecker().hasConnection;
    if (!hasNet) {
      debugPrint('[SyncService] trySync() aborted: no internet connectivity detected');
      return;
    }

    if (_syncRunning) {
      debugPrint('[SyncService] trySync() called but a sync is already running; skipping');
      return;
    }

    debugPrint('[SyncService] trySync() called — starting sync');
    _syncRunning = true;
    isRunningNotifier.value = true;
    try {
      if (_queue.isEmpty) {
        isSynced.value = true;
        debugPrint('[SyncService] No pending syncs.');
        return;
      }
      debugPrint('[SyncService] Starting sync for ${_queue.length} entries...');
      // Explicit, unmistakable log for audit/debugging
      debugPrint('[SyncService] Ich synchronisiere diese Fucking lokale Database zu Supabase');
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
    // Report a clear, timestamped summary of what was synchronized
    final syncedCount = toRemove.length;
    final remaining = _queue.length;
    final ts = DateTime.now().toIso8601String();
    if (syncedCount > 0) {
      debugPrint('[SyncService] PERFORMED SYNC -> synced=$syncedCount remaining=$remaining at $ts');
    } else {
      debugPrint('[SyncService] SYNC RUN (no entries synced) -> remaining=$remaining at $ts');
    }
    isSynced.value = _queue.isEmpty;
    } finally {
      _syncRunning = false;
      isRunningNotifier.value = false;
      debugPrint('[SyncService] trySync() finished — running set to false');
    }
  }
  // Getter für Queue-Länge
  int get queueLength => _queue.length;
}

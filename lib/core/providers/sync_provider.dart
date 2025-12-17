import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/core/services/device_id.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncState {
  final bool isSynced;
  final bool isRunning;
  final int queueLength;

  const SyncState({
    required this.isSynced,
    required this.isRunning,
    required this.queueLength,
  });

  SyncState copyWith({
    bool? isSynced,
    bool? isRunning,
    int? queueLength,
  }) {
    return SyncState(
      isSynced: isSynced ?? this.isSynced,
      isRunning: isRunning ?? this.isRunning,
      queueLength: queueLength ?? this.queueLength,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  final List<Map<String, dynamic>> _queue = [];
  final supabase = Supabase.instance.client;
  StreamSubscription? _connectivitySub;
  bool _syncRunning = false;

  @override
  SyncState build() {
    _connectivitySub = InternetConnectionChecker().onStatusChange.listen((status) {
      final online = status == InternetConnectionStatus.connected;
      debugPrint('[SyncNotifier.build] InternetConnectionChecker status: $status -> online=$online');
      if (!online) return;

      Future.delayed(const Duration(seconds: 1), () async {
        final stillOnline = await InternetConnectionChecker().hasConnection;
        debugPrint('[SyncNotifier.build] post-debounce hasConnection=$stillOnline');
        if (stillOnline) {
          trySync();
        } else {
          debugPrint('[SyncNotifier.build] Skipping trySync() after debounce; no connection');
        }
      });
    });

    ref.onDispose(() {
      _connectivitySub?.cancel();
      _queue.clear();
    });

    return const SyncState(isSynced: true, isRunning: false, queueLength: 0);
  }

  Future<void> addToQueue(Habit habit, String action) async {
    _queue.removeWhere((entry) => entry['habit']['id'] == habit.id);
    final deviceId = await DeviceId.getOrCreate();
    final payload = Map<String, dynamic>.from(habit.toJson());
    payload['device_id'] = deviceId;
    _queue.add({
      'habit': payload,
      'action': action,
    });
    state = state.copyWith(isSynced: false, queueLength: _queue.length);
  }

  Future<void> trySync() async {
    final hasNet = await InternetConnectionChecker().hasConnection;
    if (!hasNet) {
      debugPrint('[SyncNotifier] trySync() aborted: no internet connectivity detected');
      return;
    }

    if (_syncRunning) {
      debugPrint('[SyncNotifier] trySync() called but a sync is already running; skipping');
      return;
    }

    debugPrint('[SyncNotifier] trySync() called — starting sync');
    _syncRunning = true;
    state = state.copyWith(isRunning: true);
    try {
      if (_queue.isEmpty) {
        state = state.copyWith(isSynced: true);
        debugPrint('[SyncNotifier] No pending syncs.');
        return;
      }
      debugPrint('[SyncNotifier] Starting sync for ${_queue.length} entries...');
      debugPrint('[SyncNotifier] Ich synchronisiere diese Fucking lokale Database zu Supabase');
      final toRemove = <Map<String, dynamic>>[];
      for (final entry in _queue) {
        final habitJson = entry['habit'] as Map<String, dynamic>;
        final action = entry['action'] as String;
        try {
          debugPrint('[SyncNotifier] Sync: $action for Habit ${habitJson['id']}');
          if (action == 'delete') {
            await supabase.from('habits').delete().eq('id', habitJson['id']);
          } else {
            await supabase.from('habits').upsert([habitJson]);
          }
          toRemove.add(entry);
        } catch (e) {
          debugPrint('[SyncNotifier] Error syncing ${habitJson['id']}: $e');
        }
      }
      _queue.removeWhere((entry) => toRemove.contains(entry));
      final syncedCount = toRemove.length;
      final remaining = _queue.length;
      final ts = DateTime.now().toIso8601String();
      if (syncedCount > 0) {
        debugPrint('[SyncNotifier] PERFORMED SYNC -> synced=$syncedCount remaining=$remaining at $ts');
      } else {
        debugPrint('[SyncNotifier] SYNC RUN (no entries synced) -> remaining=$remaining at $ts');
      }
      state = state.copyWith(isSynced: _queue.isEmpty, queueLength: _queue.length);
    } finally {
      _syncRunning = false;
      state = state.copyWith(isRunning: false);
      debugPrint('[SyncNotifier] trySync() finished — running set to false');
    }
  }

  void setIsSynced(bool v) {
    state = state.copyWith(isSynced: v);
  }
}

final syncServiceProvider = NotifierProvider<SyncNotifier, SyncState>(() => SyncNotifier());
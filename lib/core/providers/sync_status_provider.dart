import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_flow/core/services/sync_service.dart';

class SyncStatusNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initialwert setzen
    _listen();
    final v = SyncService().isSynced.value;
    debugPrint('[sync_status_provider] build -> isSynced=$v');
    return v;
  }

  void _listen() {
    // ValueNotifier-Änderungen an Riverpod weiterleiten
    SyncService().isSynced.addListener(_update);
  }

  void _update() {
    final v = SyncService().isSynced.value;
    debugPrint('[sync_status_provider] _update -> isSynced=$v');
    state = v;
  }

  void dispose() {
    SyncService().isSynced.removeListener(_update);
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, bool>(SyncStatusNotifier.new);

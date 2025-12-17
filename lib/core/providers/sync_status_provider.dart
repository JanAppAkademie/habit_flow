import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/services/sync_service.dart';

class SyncStatusNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initialwert setzen
    _listen();
    return SyncService().isSynced.value;
  }

  void _listen() {
    // ValueNotifier-Änderungen an Riverpod weiterleiten
    SyncService().isSynced.addListener(_update);
  }

  void _update() {
    state = SyncService().isSynced.value;
  }

  void dispose() {
    SyncService().isSynced.removeListener(_update);
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, bool>(SyncStatusNotifier.new);

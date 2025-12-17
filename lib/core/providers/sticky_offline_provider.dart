import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_provider.dart';
import 'sync_status_provider.dart';

/// Sticky flag: becomes true when device goes offline and remains true
/// until a successful sync occurs. This keeps UI indicators (cloud icon)
/// showing an alert state even after connectivity is restored until sync finishes.
final stickyOfflineProvider = NotifierProvider<StickyOfflineNotifier, bool>(StickyOfflineNotifier.new);

class StickyOfflineNotifier extends Notifier<bool> {
  @override
  bool build() {
    // initial state: not sticky
    // listen to connectivity and sync status changes
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      final prevVal = previous?.value;
      final nextVal = next.value;
      // if became offline, set sticky
      if (prevVal == true && nextVal == false) {
        debugPrint('[StickyOfflineNotifier] Connectivity lost, setting sticky flag.');
        state = true;
      }
      // if there was no previous (initial) and next is false, also set
      if (previous == null && nextVal == false) {
        debugPrint('[StickyOfflineNotifier] Initial offline detected, setting sticky flag.');
        state = true;
      }
    });

    ref.listen<bool>(syncStatusProvider, (previous, next) {
      // when sync reports true (all synced), clear sticky flag
      if (next == true) {
        debugPrint('[StickyOfflineNotifier] Sync successful, clearing sticky flag.');
        state = false;
      }
    });

  //  debugPrint('[StickyOfflineNotifier] Initialized with state: $state');
    return false;
  }
}

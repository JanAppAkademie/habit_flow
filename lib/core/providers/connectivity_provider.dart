import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Provides a stream of `true`/`false` representing whether the device has
/// working internet connectivity. Uses `internet_connection_checker` which
/// performs lightweight checks and exposes `onStatusChange`.
final connectivityProvider = StreamProvider<bool>((ref) {
  final checker = InternetConnectionChecker();

  // Log status changes for debugging
  final stream = checker.onStatusChange.map((status) {
    final online = status == InternetConnectionStatus.connected;
    debugPrint('[connectivity_provider] internet_connection_checker status: $status -> online=$online');
    return online;
  });

  ref.onDispose(() {
    debugPrint('[connectivity_provider] disposing InternetConnectionChecker');
    // InternetConnectionChecker does not require explicit disposal in this
    // package version — we only log for debugging.
  });

  return stream;
});

/// Verify that we can resolve a public hostname. This gives a better
/// indication of actual internet access than the raw platform connectivity
/// enum which only indicates network interfaces.
// Note: historical DNS lookup helper removed; using `internet_connection_checker`.

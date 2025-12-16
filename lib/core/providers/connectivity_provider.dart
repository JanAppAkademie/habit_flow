import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a simple online/offline boolean stream.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emit initial status
  try {
    final result = await connectivity.checkConnectivity();
    yield result.any((status) => status != ConnectivityResult.none);
  } catch (_) {
    yield false;
  }

  // Then forward changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield result.any((status) => status != ConnectivityResult.none);
  }
});

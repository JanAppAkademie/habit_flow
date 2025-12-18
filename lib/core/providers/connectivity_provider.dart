import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final checker = InternetConnectionChecker();

  final stream = checker.onStatusChange.map((status) {
    final online = status == InternetConnectionStatus.connected;
    debugPrint('[connectivity_provider] internet_connection_checker status: $status -> online=$online');
    return online;
  });

  ref.onDispose(() {
    debugPrint('[connectivity_provider] disposing InternetConnectionChecker');
  });

  return stream;
});


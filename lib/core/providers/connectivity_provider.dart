import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stellt einen einfachen Stream bereit, der online/offline als booleschen Wert zurückgibt.
///
/// Gibt `true` zurück, wenn das Gerät irgendeine Verbindung außer `none` hat,
/// andernfalls `false`.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Initialen Konnektivitätsstatus ausgeben (checkConnectivity liefert ein einzelnes ConnectivityResult)
  try {
    final result = await connectivity.checkConnectivity();
    yield result.any((status) => status != ConnectivityResult.none);
  } catch (_) {
    yield false;
  }

  // Änderungen des Konnektivitätsstatus weiterleiten
  await for (final result in connectivity.onConnectivityChanged) {
    yield result.any((status) => status != ConnectivityResult.none);
  }
});

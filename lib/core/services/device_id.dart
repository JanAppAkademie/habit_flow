import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceId {
  static const _key = 'device_id';

  /// Returns existing device id or creates & persists a new UUID v4.
  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = _generateUuidV4();
    await prefs.setString(_key, id);
    return id;
  }

  /// Remove stored device id (for testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Simple UUID v4 generator (no external package) — not cryptographically secure
  static String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    // Per RFC 4122 v4
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    String hex(int i) => bytes[i].toRadixString(16).padLeft(2, '0');
    final parts = [
      List.generate(4, (i) => hex(i)).join(),
      List.generate(2, (i) => hex(i + 4)).join(),
      List.generate(2, (i) => hex(i + 6)).join(),
      List.generate(2, (i) => hex(i + 8)).join(),
      List.generate(6, (i) => hex(i + 10)).join(),
    ];
    return parts.join('-');
  }
}

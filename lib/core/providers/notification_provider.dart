import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NotificationController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    state = enabled;
  }
}

final notificationControllerProvider = NotifierProvider<NotificationController, bool>(NotificationController.new);

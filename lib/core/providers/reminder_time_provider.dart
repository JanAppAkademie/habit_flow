
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderTimeController extends Notifier<TimeOfDay?> {
  @override
  TimeOfDay? build() {
    _load();
    return null;
  }

  Future<void> setTime(TimeOfDay? time) async {
    state = time;
    final prefs = await SharedPreferences.getInstance();
    if (time != null) {
      await prefs.setInt('reminder_hour', time.hour);
      await prefs.setInt('reminder_minute', time.minute);
    } else {
      await prefs.remove('reminder_hour');
      await prefs.remove('reminder_minute');
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');
    if (hour != null && minute != null) {
      state = TimeOfDay(hour: hour, minute: minute);
    } else {
      state = null;
    }
  }
}

final reminderTimeControllerProvider = NotifierProvider<ReminderTimeController, TimeOfDay?>(ReminderTimeController.new);

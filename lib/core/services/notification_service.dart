
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

// Muss top-level sein für flutter_local_notifications
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  debugPrint('[NotificationService] Background notification tapped: \\${response.payload}');
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> showInstantNotification() async {
    await _notifications.show(
      9999, // ID für Sofort-Notification
      'notifications.instant_title'.tr(),
      'notifications.instant_body'.tr(),
      const NotificationDetails(
        android: AndroidNotificationDetails('habitflow_channel', 'Erinnerungen', importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
    debugPrint('[NotificationService] Sofortige Notification ausgelöst!');
  }

  static Future<void> initialize() async {
    debugPrint('[NotificationService] Initializing notifications...');
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[NotificationService] Notification tapped: \\${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
    // Anfrage für Benachrichtigungsberechtigung (Android 13+)
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('[NotificationService] Notification permission requested: \\${result.isGranted ? 'GRANTED' : 'DENIED'}');
      } else {
        debugPrint('[NotificationService] Notification permission already granted.');
      }
    }
    // Anfrage für Benachrichtigungsberechtigung (iOS)
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    tz.initializeTimeZones();
    debugPrint('[NotificationService] Initialization complete. (UTC mode)');
  }

  static Future<void> scheduleDaily(TimeOfDay time) async {
    final now = DateTime.now();
    // Plane Notification für lokale Zeitzone
    var tzTime = tz.TZDateTime.local(now.year, now.month, now.day, time.hour, time.minute);
    if (!tzTime.isAfter(now)) {
      debugPrint('[NotificationService] (LOCAL) Gewählte Zeit ist in der Vergangenheit, verschiebe auf nächsten Tag ([1m${tzTime.add(const Duration(days: 1))}[0m)');
      tzTime = tzTime.add(const Duration(days: 1));
    }
    debugPrint('[NotificationService] (LOCAL) Scheduling daily notification for ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} (${tzTime.toString()})');
    await _notifications.zonedSchedule(
      0,
      'notifications.reminder_title'.tr(),
      'notifications.reminder_body'.tr(),
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('habitflow_channel', 'Erinnerungen', importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[NotificationService] (LOCAL) Notification scheduled for $tzTime');
  }

  
  static Future<void> cancelAll() async {
    debugPrint('[NotificationService] Cancelling all notifications...');
    await _notifications.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled.');
  }
}

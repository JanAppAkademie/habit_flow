import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/notifications/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden with an initialized NotificationService.',
  );
});

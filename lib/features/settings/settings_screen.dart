import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/theme_provider.dart';
import 'package:habit_flow/core/providers/notification_provider.dart';
import 'package:habit_flow/core/providers/reminder_time_provider.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final _ = ref.watch(notificationControllerProvider);
    final reminderTime = ref.watch(reminderTimeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('settings.appearance'.tr(), style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: <ButtonSegment<ThemeMode>>[
                ButtonSegment(value: ThemeMode.system, label: Text('settings.system'.tr())),
                ButtonSegment(value: ThemeMode.dark, label: Text('settings.dark'.tr())),
                ButtonSegment(value: ThemeMode.light, label: Text('settings.light'.tr())),
              ],
              selected: <ThemeMode>{themeMode},
              onSelectionChanged: (newSelection) async {
                final selected = newSelection.isNotEmpty ? newSelection.first : ThemeMode.system;
                await ref.read(themeModeProvider.notifier).setTheme(selected);
              },
            ),
          ),

          const Divider(),
     /*     Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('notifications.title'.tr(), style: Theme.of(context).textTheme.titleMedium),
          ),
          */
          Consumer(
            builder: (context, ref, _) {
              final enabled = ref.watch(notificationControllerProvider);
              return SwitchListTile(
                title: Text('notifications.title'.tr()),
                subtitle: Text(enabled ? 'notifications.active'.tr() : 'notifications.inactive'.tr()),
                value: enabled,
                onChanged: (v) async {
                  await ref.read(notificationControllerProvider.notifier).setEnabled(v);
                  if (!v) {
                    await NotificationService.cancelAll();
                  } else {
                    final time = ref.read(reminderTimeControllerProvider);
                    if (time != null) {
                      await NotificationService.scheduleDaily(time);
                    }
                  }
                },
              );
            },
          ),

          ListTile(
            title: Text('notifications.reminder_time'.tr()),
            subtitle: Text(reminderTime != null ? reminderTime.format(context) : 'notifications.not_set'.tr()),
            leading: const Icon(Icons.alarm),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: reminderTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                await ref.read(reminderTimeControllerProvider.notifier).setTime(picked);
                await NotificationService.cancelAll();
                final enabled = ref.read(notificationControllerProvider);
                if (enabled) {
                  await NotificationService.scheduleDaily(picked);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

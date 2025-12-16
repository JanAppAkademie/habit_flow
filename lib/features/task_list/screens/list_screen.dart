import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:habit_flow/features/task_list/providers/habit_provider.dart';
import 'package:habit_flow/core/theme/theme_provider.dart';
import 'package:habit_flow/core/services/sync_status_provider.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/habit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/features/splash/quote_widget.dart';
import 'package:habit_flow/features/task_list/providers/notification_provider.dart';
import 'package:habit_flow/features/task_list/providers/reminder_time_provider.dart';
import 'package:habit_flow/features/task_list/services/notification_service.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);
    final repository = getHabitRepository();
    final notificationsEnabled = ref.watch(notificationControllerProvider);

    return habitsAsync.when(
      data: (habits) {
        final completedCount = habits.where((h) => h.completedToday).length;
        final totalCount = habits.length;

        final themeNotifier = ref.watch(themeControllerProvider);

        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                final synced = ref.watch(syncStatusProvider);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    synced ? Icons.cloud_done : Icons.cloud_upload,
                    color: synced ? Colors.green : Colors.orange,
                    size: 26,
                  ),
                );
              },
            ),
            title: const Text('Habit Flow'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: notificationsEnabled ? 'Benachrichtigungen deaktivieren' : 'Benachrichtigungen aktivieren',
                icon: Icon(notificationsEnabled ? Icons.notifications_active : Icons.notifications_off),
                onPressed: () async {
                  await ref.read(notificationControllerProvider.notifier).setEnabled(!notificationsEnabled);
                  final snackBar = SnackBar(
                    content: Text(notificationsEnabled ? 'Benachrichtigungen deaktiviert' : 'Benachrichtigungen aktiviert'),
                    duration: const Duration(seconds: 1),
                  );
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) {
                  IconData icon;
                  String tooltip;
                  switch (mode) {
                    case ThemeMode.dark:
                      icon = Icons.dark_mode;
                      tooltip = 'Light mode';
                      break;
                    case ThemeMode.light:
                      icon = Icons.light_mode;
                      tooltip = 'System mode';
                      break;
                    case ThemeMode.system:
                      icon = Icons.brightness_auto;
                      tooltip = 'Dark mode';
                      break;
                  }
                  return IconButton(
                    tooltip: tooltip,
                    icon: Icon(icon),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      ThemeMode newMode;
                      switch (mode) {
                        case ThemeMode.dark:
                          newMode = ThemeMode.light;
                          break;
                        case ThemeMode.light:
                          newMode = ThemeMode.system;
                          break;
                        case ThemeMode.system:
                          newMode = ThemeMode.dark;
                          break;
                      }
                      // persist
                      await prefs.setString(
                        'theme_mode',
                        newMode == ThemeMode.dark
                            ? 'dark'
                            : newMode == ThemeMode.light
                                ? 'light'
                                : 'system',
                      );
                      // update provider state
                      themeNotifier.value = newMode;
                    },
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final reminderTime = ref.watch(reminderTimeControllerProvider);
                  return IconButton(
                    tooltip: reminderTime != null
                        ? 'Erinnerungszeit: ${reminderTime.format(context)} ändern'
                        : 'Erinnerungszeit festlegen',
                    icon: Icon(Icons.alarm, color: reminderTime != null ? Colors.redAccent : null),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        await ref.read(reminderTimeControllerProvider.notifier).setTime(picked);
                        await NotificationService.cancelAll();
                        await NotificationService.scheduleDaily(picked);
                        final notificationsEnabled = ref.read(notificationControllerProvider);
                        if (!notificationsEnabled) {
                          // Falls Benachrichtigungen deaktiviert sind, aktivieren
                          await ref.read(notificationControllerProvider.notifier).setEnabled(true);
                          if (context.mounted) {
                            final snackBar = SnackBar(
                              content: Text('reminder_set_snackbar'.tr(namedArgs: {'time': picked.format(context)})),
                              duration: const Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Motivationszitat mit Pull-to-Refresh
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 16, right: 16, bottom: 0),
                child: QuoteWidget(),
              ),
              // Progress indicator
              if (habits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'done_of_total'.tr(namedArgs: {'done': completedCount.toString(), 'total': totalCount.toString()}),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalCount > 0 ? completedCount / totalCount : 0,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              // Habits list
              Expanded(
                child: habits.isEmpty
                    ? const EmptyContent()
                    : ListView.builder(
                        itemCount: habits.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Card(
                              child: ListTile(
                                leading: Checkbox(
                                  value: habit.completedToday,
                                  onChanged: (value) async {
                                    // Heute zum completedDates hinzufügen oder entfernen
                                    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                    final updatedDates = List<DateTime>.from(habit.completedDates);

                                    if (!habit.completedToday) {
                                      // Hinzufügen
                                      updatedDates.add(today);
                                    } else {
                                      // Entfernen
                                      updatedDates.removeWhere((d) {
                                        final dateOnly = DateTime(d.year, d.month, d.day);
                                        return dateOnly == today;
                                      });
                                    }

                                    final updated = habit.copyWith(
                                      completedToday: !habit.completedToday,
                                      completedDates: updatedDates,
                                      lastCompletedAt: !habit.completedToday ? DateTime.now() : habit.lastCompletedAt,
                                    );
                                    await repository.update(updated);
                                    // ignore: unawaited_futures, unused_result
                                    ref.refresh(habitProvider);
                                  },
                                ),
                                title: Text(habit.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(habit.description),
                                    const SizedBox(height: 4),
                                    // 🔥 Streak-Anzeige
                                    Text(
                                      'streak'.tr(namedArgs: {'days': habit.calculateStreak().toString()}),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text('edit'.tr()),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              HabitDialog(habit: habit),
                                        ).then((result) async {
                                          if (result is Habit) {
                                            await repository.update(result);
                                            // ignore: unawaited_futures, unused_result
                                            ref.refresh(habitProvider);
                                          }
                                        });
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: Text('delete'.tr()),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('delete_confirm_title'.tr()),
                                            content: Text(
                                              'delete_confirm_text'.tr(namedArgs: {'habit': habit.name}),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text('cancel'.tr()),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await repository.delete(habit.id);
                                                  // ignore: unawaited_futures, unused_result
                                                  ref.refresh(habitProvider);
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text('delete'.tr()),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HabitDialog(),
              ).then((result) async {
                if (result is Habit) {
                  await repository.add(result);
                  // ignore: unawaited_futures, unused_result
                  ref.refresh(habitProvider);
                }
              });
            },
            child: Icon(Icons.add, semanticLabel: 'add'.tr()),
          ),
        );
      },
      loading: () {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('loading'.tr()),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text('error'.tr(namedArgs: {'error': error.toString()})),
          ),
        );
      },
    );
  }
}


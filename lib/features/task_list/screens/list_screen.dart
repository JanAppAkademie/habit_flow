import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/features/task_list/models/habit_repository.dart';
import 'package:habit_flow/core/providers/habit_provider.dart';
import 'package:habit_flow/core/providers/theme_provider.dart';
import 'package:habit_flow/core/providers/sync_status_provider.dart';
import 'package:habit_flow/core/providers/connectivity_provider.dart';
import 'package:habit_flow/core/services/sync_service.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/habit_dialog.dart';
import 'package:habit_flow/features/task_list/widgets/motivation_banner.dart';


class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  late final ScrollController _scrollController = ScrollController();

  // We must register Riverpod listeners inside `build()` for ConsumerState.
  // Use [_listenersAttached] to ensure we only register them once.
  bool _listenersAttached = false;

  @override
  Widget build(BuildContext context) {
    // Attach listeners from inside build to satisfy Riverpod's debug checks.
    if (!_listenersAttached) {
      _listenersAttached = true;
      debugPrint('[ListScreen] Attaching connectivity and sync listeners');

      ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
        debugPrint('[ListScreen.connectivity.listen] previous=$previous next=$next');
        next.when(
          data: (online) async {
            final now = DateTime.now().toIso8601String();
            debugPrint('[ListScreen] connectivity changed -> online: $online at $now');
            if (!online) {
              debugPrint('[ListScreen] offline — no sync will be attempted');
              return;
            }

            // Evaluate SyncService state to decide whether to sync
            final isSynced = SyncService().isSynced.value;
            final queueLen = SyncService().queueLength;
            final running = ref.read(syncRunningProvider);
            final needSync = !isSynced || queueLen > 0;
            debugPrint('[ListScreen] back online -> needSync=$needSync isSynced=$isSynced queueLen=$queueLen running=$running');

            if (running) {
              debugPrint('[ListScreen] A sync is already running; skipping explicit trySync() call');
              return;
            }

            if (needSync) {
              debugPrint('[ListScreen] calling SyncService.trySync()');
              try {
                await SyncService().trySync();
                debugPrint('[ListScreen] SyncService.trySync() returned; isSynced=${SyncService().isSynced.value} queueLen=${SyncService().queueLength} isRunning=${ref.read(syncRunningProvider)}');
              } catch (e) {
                debugPrint('[ListScreen] trySync() threw: $e');
              }
            } else {
              debugPrint('[ListScreen] No sync necessary on reconnect (needSync=false)');
            }
          },
          loading: () {},
          error: (_, __) {},
        );
      });

      ref.listen<bool>(syncStatusProvider, (previous, next) {
        debugPrint('[ListScreen] syncStatusProvider changed -> $previous -> $next');
      });
    }
    final repository = getHabitRepository();

    // Log build-time state to help debug missing events
    final syncedDbg = ref.watch(syncStatusProvider);
    final onlineAsyncDbg = ref.watch(connectivityProvider);
    final onlineDbg = onlineAsyncDbg.when(data: (v) => v, loading: () => true, error: (_,__) => false);
    final runningDbg = ref.watch(syncRunningProvider);
    final queueDbg = SyncService().queueLength;
    debugPrint('[ListScreen.build] synced=$syncedDbg online=$onlineDbg running=$runningDbg queueLen=$queueDbg');

    return ref.watch(habitProvider).when(
      data: (habits) {
        final completedCount = habits.where((h) => h.completedToday).length;
        final totalCount = habits.length;

        final _ = ref.watch(themeModeProvider);
        final synced = ref.watch(syncStatusProvider);
        final onlineAsync = ref.watch(connectivityProvider);
        final online = onlineAsync.when(data: (v) => v, loading: () => true, error: (_,__) => false);

        final running = ref.watch(syncRunningProvider);
        final queueLen = SyncService().queueLength;

        // Determine icon + color
        IconData cloudIcon;
        Color cloudColor;
        if (!online) {
          cloudIcon = Icons.cloud_off;
          cloudColor = Colors.redAccent;
        } else if (running) {
          cloudIcon = Icons.sync;
          cloudColor = Colors.orange;
        } else if (queueLen > 0 || !synced) {
          cloudIcon = Icons.sync;
          cloudColor = Colors.orangeAccent;
        } else {
          cloudIcon = Icons.cloud_done;
          cloudColor = Colors.green;
        }

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Builder(builder: (context) {
                // Determine AppBar background to avoid using an icon color that
                // would blend into it. Use a white icon for the sync state to
                // make syncing clearly visible; for other states keep the
                // cloudColor but fallback to onPrimary if it would match the
                // AppBar background.
                final appBarBg = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary;
                Color iconColor;
                if (cloudIcon == Icons.sync) {
                  iconColor = Colors.white; // user preference: sync icon white
                } else {
                  iconColor = cloudColor;
                  if (iconColor == appBarBg) {
                    iconColor = Theme.of(context).colorScheme.onPrimary;
                  }
                }

                return IconButton(
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    cloudIcon,
                    color: iconColor,
                    size: 26,
                  ),
                  onPressed: () async {
                    try {
                      await repository.fullSync();
                      // refresh provider to reload local data
                      // ignore: unused_result
                      ref.refresh(habitProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('sync.finished'.tr()), duration: const Duration(seconds: 1)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('sync.error'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                );
              }),
            ),
            title: Text('habit_flow'.tr()),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings screen
                  context.push(AppRoutes.settings);
                },
              ), 
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const HabitDialog(),
                  ).then((result) async {
                    if (result is Habit) {
                      await repository.add(result);
                      // refresh provider to reload local data
                      // ignore: unused_result
                      ref.refresh(habitProvider);
                      // Scroll to top so the newly created item (newest) is visible
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Motivation banner (extracted to provider + widget)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 16, right: 16, bottom: 0),
                child: MotivationBanner(),
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
              // Habits list with Pull-to-Refresh (RefreshIndicator)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await repository.fullSync();
                      // refresh provider to reload local data
                      // ignore: unused_result
                      ref.refresh(habitProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('sync.finished'.tr()), duration: const Duration(seconds: 1)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('sync.error'.tr()), backgroundColor: Colors.red),
                          //SnackBar(content: Text('sync.error'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: habits.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 200,
                            child: const EmptyContent(),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount: habits.length,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
              ),
            ],
          ),
          // FloatingActionButton removed; use AppBar action for adding a habit
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


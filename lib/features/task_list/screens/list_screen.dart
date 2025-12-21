import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/task_list/models/task.dart';
import 'package:habit_flow/features/task_list/providers/task_list_provider.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/features/quotes/providers/quote_provider.dart';
import 'package:habit_flow/features/quotes/models/quote.dart';
import 'package:habit_flow/features/streaks/providers/streak_provider.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  Future<void> _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
  }) async {
    final controller = TextEditingController(text: task?.title ?? '');
    final notifier = ref.read(taskListProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Titel der Aufgabe'),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (task == null) {
                  notifier.addTask(controller.text);
                } else {
                  notifier.renameTask(task, controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final notifier = ref.read(taskListProvider.notifier);
    final quoteAsync = ref.watch(quoteProvider);
    final streakAsync = ref.watch(streakProvider);
    final completedCount = tasks
        .where((task) => task.isCompleted)
        .length; // progress counter
    final progressValue = tasks.isEmpty
        ? 0.0
        : completedCount / tasks.length.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(quoteProvider.notifier).refreshQuote(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _QuoteCard(quoteAsync: quoteAsync),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _StreakCard(streakAsync: streakAsync),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$completedCount von ${tasks.length} erledigt'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progressValue),
                ],
              ),
            ),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyContent(),
              )
            else
              ItemList(
                tasks: tasks,
                onToggle: notifier.toggleTask,
                onEdit: (task) => _showTaskDialog(context, ref, task: task),
                onDelete: notifier.deleteTask,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quoteAsync});

  final AsyncValue<Quote> quoteAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: quoteAsync.when(
          data: (quote) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '"${quote.text}"',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '- ${quote.author}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Motivation'),
              const SizedBox(height: 8),
              Text('Fehler beim Laden: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakAsync});

  final AsyncValue<int> streakAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: streakAsync.when(
          data: (streak) {
            return Row(
              children: [
                const Icon(Icons.local_fire_department, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('$streak Tage in Folge'),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Streak'),
              const SizedBox(height: 8),
              Text('Fehler beim Laden: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/features/quotes/controllers/quote_notifier.dart';
import 'package:habit_flow/features/quotes/models/quote.dart';
import 'package:habit_flow/features/task_list/controllers/habit_list_controller.dart';
import 'package:habit_flow/features/task_list/models/habit.dart';
import 'package:habit_flow/features/task_list/widgets/empty_content.dart';
import 'package:habit_flow/features/task_list/widgets/item_list.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListControllerProvider);
    final quoteState = ref.watch(quoteProvider);

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Habit'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(quoteProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          children: [
            _buildQuoteCard(context, quoteState, ref),
            const SizedBox(height: 16),
            _buildStreakCard(
              context,
              habits: habits,
            ),
            const SizedBox(height: 16),
            if (habits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: EmptyContent(),
              )
            else
              ItemList(
                items: habits,
                onEdit: (habit, newItem) =>
                    _editHabit(ref, habit, newItem),
                onDelete: (habit) => _deleteHabit(ref, habit),
                onToggleCompletion: (habit) =>
                    _toggleHabitCompletion(ref, habit),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuen Habit anlegen'),
          content: TextField(
            autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'z. B. 10 Minuten laufen',
            ),
            onSubmitted: (_) => _submitNewHabit(context, ref, controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () =>
                  _submitNewHabit(context, ref, controller),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _submitNewHabit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
  ) {
    final text = controller.text.trim();

    if (text.isEmpty) {
      HapticFeedback.mediumImpact();
      return;
    }

    ref.read(habitListControllerProvider.notifier).addHabit(text);
    Navigator.of(context).pop();
  }

  void _editHabit(WidgetRef ref, Habit habit, String newTitle) {
    ref.read(habitListControllerProvider.notifier).editHabit(
          habit,
          newTitle,
        );
  }

  void _deleteHabit(WidgetRef ref, Habit habit) {
    ref.read(habitListControllerProvider.notifier).deleteHabit(habit);
  }

  void _toggleHabitCompletion(WidgetRef ref, Habit habit) {
    ref
        .read(habitListControllerProvider.notifier)
        .toggleHabitCompletion(habit);
  }

  Widget _buildQuoteCard(
    BuildContext context,
    AsyncValue<Quote> quoteState,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardBackground = LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.primary.withValues(alpha: 0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.format_quote, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Motivationszitat',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: quoteState.isLoading
                    ? null
                    : () => ref.refresh(quoteProvider.future),
              ),
            ],
          ),
          const SizedBox(height: 16),
          quoteState.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (_, __) => Text(
              'Zitat konnte nicht geladen werden. Bitte versuche es erneut.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
            data: (quote) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '„${quote.text}“',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  quote.author,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context, {
    required List<Habit> habits,
  }) {
    final totalHabits = habits.length;
    final completedCount =
        habits.where((habit) => habit.isCompletedToday).length;
    final bestStreak = habits.fold<int>(
      0,
      (previousValue, habit) =>
          habit.currentStreak > previousValue ? habit.currentStreak : previousValue,
    );
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Heutiger Fortschritt',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            totalHabits == 0
                ? 'Lege deinen ersten Habit an, um loszulegen!'
                : '$completedCount von $totalHabits Habits erledigt',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Text(
            'Bester Streak',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$bestStreak',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text(
                bestStreak == 1 ? 'Tag' : 'Tage',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ein Tag Pause setzt den Streak zurück.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/providers/motivation_provider.dart';

class MotivationBanner extends ConsumerWidget {
  const MotivationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mot = ref.watch(motivationProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: mot.when(
        data: (text) {
          if (text == null || text.isEmpty) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(motivationProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 100,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: Text(
                      text,
                      key: ValueKey<String>(text),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:habit_flow/core/router/app_router.dart';
import '../../core/providers/quote_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeNavigate();
  }

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(quoteProvider);
    _maybeNavigate();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: const Color.fromRGBO(228, 132, 255, 0.724),
                child: Text(
                  'splash.welcome'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_outline, size: 48),
              const SizedBox(height: 32),
              quoteAsync.when(
                data: (quote) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${quote.quote}"',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- ${quote.author}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('splash.quote_error'.tr(), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeNavigate() {
    if (_navigated) return;
    final quoteAsync = ref.read(quoteProvider);
    if (quoteAsync is AsyncData || quoteAsync is AsyncError) {
      _navigated = true;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) context.go(AppRoutes.home);
      });
    }
  }
}

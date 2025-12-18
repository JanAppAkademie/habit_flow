import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'package:habit_flow/core/providers/quote_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    void navigateToHome() {
     // final quoteAsync = ref.read(quoteFetchRandom);
     // if (quoteAsync is AsyncData || quoteAsync is AsyncError) {
        Future.delayed(const Duration(milliseconds: 3000), () 
        {
          if (context.mounted) context.go(AppRoutes.home);
        }
        );
    //  }
    }

    navigateToHome();
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
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
              ),
    //          const SizedBox(height: 20),
    //          const Icon(Icons.check_circle_outline, size: 48),
              const SizedBox(height: 32),
              ref.watch(quoteFetchRandom).when(
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
}



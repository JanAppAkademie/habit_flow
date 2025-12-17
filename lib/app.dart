import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return EasyLocalization(
      supportedLocales: const [Locale('de')],
      path: 'assets/langs',
      fallbackLocale: const Locale('de'),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: themeMode,
        title: tr('habit_flow'),
        routerConfig: appRouter,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
      ),
    );
  }
}

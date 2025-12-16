import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_flow/core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeControllerProvider);
    return EasyLocalization(
      supportedLocales: const [Locale('de')],
      path: 'assets/langs',
      fallbackLocale: const Locale('de'),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: themeMode,
            title: tr('habit_flow'),
            routerConfig: appRouter,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
          );
        },
      ),
    );
  }
}

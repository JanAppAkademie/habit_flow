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
        theme: (() {

          const orangeColor = Color(0xFFFF9500);
          
          final cs = ColorScheme.light(
            primary: orangeColor,
            onPrimary: Colors.white,
            secondary: orangeColor,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          );

          //final cs = ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light);
          return ThemeData(
            colorScheme: cs,
            primaryColor: cs.primary,
            scaffoldBackgroundColor: cs.surface,
            appBarTheme: AppBarTheme(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
            useMaterial3: true,
          );
        })(),
        darkTheme: (() {
          const orangeColor = Color(0xFFFFAA33); // Helleres Orange für besseren Kontrast im Dark Mode

          final cs = ColorScheme.dark(
            primary: orangeColor,
            onPrimary: Colors.black,
            secondary: orangeColor,
            onSecondary: Colors.black,
            error: Colors.redAccent,
            onError: Colors.black,
            // OLED: Pure Black (#000000), Normal: iOS Dark Gray
            surface: Colors.black,
            onSurface: Colors.white,
          );

          //final cs = ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark);
          return ThemeData(
            colorScheme: cs,
            primaryColor: cs.primary,
            scaffoldBackgroundColor: cs.surface,
            appBarTheme: AppBarTheme(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
            useMaterial3: true,
          );
        })(),
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

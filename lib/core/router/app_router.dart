// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:habit_flow/features/splash/splash_screen.dart';
import 'package:habit_flow/features/task_list/screens/home_screen.dart';
import 'package:habit_flow/features/auth/auth_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const auth = '/auth';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
  path: AppRoutes.auth,
  builder: (context, state) => const AuthScreen(),
),
  ],
);

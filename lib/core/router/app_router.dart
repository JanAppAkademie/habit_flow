import 'package:go_router/go_router.dart';
import 'package:habit_flow/features/splash/splash_screen.dart';
import 'package:habit_flow/features/task_list/screens/home_screen.dart';
import 'package:habit_flow/features/task_list/screens/list_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const list = '/list';
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
      path: AppRoutes.list,
      builder: (context, state) => const ListScreen(),
    ),
  ],
);

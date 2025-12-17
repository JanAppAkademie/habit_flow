// core/widgets/app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_flow/core/router/app_router.dart';

class HabitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Habit Flow'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sync - später')));
          },
        ),

        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              context.go(AppRoutes.auth);
            }
          },
        ),
      ],
    );
  }
}

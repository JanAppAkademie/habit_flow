import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Bitte E-Mail und Passwort eingeben.');
      return;
    }

    final authRepository = ref.read(authRepositoryProvider);
    try {
      final response = await authRepository.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await authRepository.upsertUserProfile(user);
      }
      _showMessage('Erfolgreich angemeldet.');
    } catch (error) {
      _showMessage('Login fehlgeschlagen: $error');
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Bitte E-Mail und Passwort eingeben.');
      return;
    }

    final authRepository = ref.read(authRepositoryProvider);
    try {
      final response = await authRepository.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await authRepository.upsertUserProfile(user);
      }
      _showMessage('Registrierung erfolgreich.');
    } catch (error) {
      _showMessage('Registrierung fehlgeschlagen: $error');
    }
  }

  Future<void> _handleSignOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    try {
      await authRepository.signOut();
      _showMessage('Abgemeldet.');
    } catch (error) {
      _showMessage('Logout fehlgeschlagen: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoSyncAsync = ref.watch(autoSyncProvider);
    final userAsync = ref.watch(authUserProvider);
    final themeModeAsync = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Darstellung',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          themeModeAsync.when(
            data: (mode) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: mode,
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(themeModeProvider.notifier).setThemeMode(value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dunkel'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Hell'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Fehler: $error'),
          ),
          const SizedBox(height: 16),
          Text(
            'Sync',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          autoSyncAsync.when(
            data: (autoSync) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Automatischer Sync'),
                value: autoSync,
                onChanged: (value) {
                  ref.read(autoSyncProvider.notifier).setAutoSync(value);
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Fehler: $error'),
          ),
          const SizedBox(height: 12),
          if (autoSyncAsync.asData?.value == false &&
              userAsync.asData?.value != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final user = userAsync.asData?.value;
                    if (user == null) return;
                    ref.read(taskListProvider.notifier).syncNow();
                    _showMessage('Sync gestartet.');
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Jetzt synchronisieren'),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userAsync.asData?.value == null
                          ? 'Login aktiviert Cloud-Sync fuer deine Habits.'
                          : 'Cloud-Sync ist aktiv.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          userAsync.when(
            data: (user) {
              if (user == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Passwort'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _handleSignIn,
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: _handleSignUp,
                      child: const Text('Registrieren'),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Angemeldet als: ${user.email ?? user.id}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _handleSignOut,
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Fehler: $error'),
          ),
        ],
      ),
    );
  }
}

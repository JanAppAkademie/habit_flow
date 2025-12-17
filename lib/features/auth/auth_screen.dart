// features/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_flow/core/router/app_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _pwCtrl.text;

      if (email.isEmpty || password.length < 6) {
        throw Exception('Email und Passwort (min. 6 Zeichen) erforderlich.');
      }

      final auth = Supabase.instance.client.auth;

      if (_isLogin) {
        await auth.signInWithPassword(email: email, password: password);
      } else {
        await auth.signUp(email: email, password: password);
        // Если в Supabase отключено email confirmation — ты сразу будешь залогинен.
      }

      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registrierung')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading
                    ? 'Bitte warten...'
                    : (_isLogin ? 'Einloggen' : 'Registrieren')),
              ),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? 'Noch kein Konto? Registrieren'
                  : 'Schon ein Konto? Einloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
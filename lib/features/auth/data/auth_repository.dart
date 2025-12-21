import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange
      .map((event) => event.session?.user);

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> upsertUserProfile(User user) async {
    await _client.from('users').upsert({
      'id': user.id,
      'email': user.email,
    });
  }
}

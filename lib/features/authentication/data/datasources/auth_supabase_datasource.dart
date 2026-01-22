import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> logOut() {
    return _client.auth.signOut();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  // Récupérer l'utilisateur actuel n'importe où
  User? get currentUser => _client.auth.currentUser;

  // Vérifier si on est connecté
  bool get isConnected => _client.auth.currentSession != null;

  // Cette méthode sera appelée par ton ViewModel
  Future<void> login() async {
    if (!isConnected) {
      await _client.auth.signInWithPassword(
        email: 'test-f8@mail.com',
        password: 'test',
      );
    }
  }
}
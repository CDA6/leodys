import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthDatasource {
  static const String _webClientId =
      '35039953060-2ftqbtc1ruqescq3mb5jrbpn7rvi98rj.apps.googleusercontent.com';
  static const String? _iosClientId = null;
  static const List<String> _scopes = ['email', 'profile'];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      await _googleSignIn.initialize();
    } else {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
        clientId: _iosClientId,
      );
    }

    _isInitialized = true;
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final SupabaseClient client = Supabase.instance.client;

      if (kIsWeb) {
        final response = await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );

        if (!response) {
          throw const AuthException('Échec de l\'initialisation OAuth Google');
        }

        throw const AuthException('Authentification en cours dans un nouvel onglet...');
      } else {
        final googleUser = await _googleSignIn.authenticate();

        String? idToken = googleUser.authentication.idToken;

        if (idToken == null) {
          final serverAuth =
          await googleUser.authorizationClient.authorizeServer(_scopes);

          if (serverAuth?.serverAuthCode != null) {
            idToken = serverAuth!.serverAuthCode;
          }
        }

        String? accessToken;
        try {
          final authorization =
          await googleUser.authorizationClient.authorizationForScopes(_scopes);
          accessToken = authorization?.accessToken;
        } catch (_) {}

        if (idToken == null) {
          throw const AuthException('Pas de ID Token ni serverAuthCode trouvé');
        }

        final response = await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        return response;
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur Google Sign-In: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _isInitialized = false;
  }
}
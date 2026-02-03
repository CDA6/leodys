import 'package:flutter/foundation.dart';
import 'package:leodys/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:leodys/features/authentication/data/repositories/biometric_repository_impl.dart';
import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';
import 'package:leodys/features/authentication/domain/repositories/biometric_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final BiometricRepository _biometricRepository = BiometricRepositoryImpl();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  bool _isLoggedOut = true;

  bool get isAuthenticated => !_isLoggedOut;

  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricRepository.canUseBiometric();
    } catch (e) {
      return false;
    }
  }

  bool hasValidSession() {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) return false;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > now;
  }

  Future<void> signIn(String email, String password) async {
    final response = await _authRepository.signIn(email, password);

    if (response.session == null) {
      throw Exception('Échec de la connexion');
    }

    _isLoggedOut = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final response = await _authRepository.signInWithGoogle();

    if (response.session == null) {
      throw Exception('Échec de la connexion Google');
    }

    _isLoggedOut = false;
    notifyListeners();
  }

  Future<bool> signInWithBiometric() async {
    if (!hasValidSession()) return false;

    final success = await _biometricRepository.authenticate();

    if (success) {
      _isLoggedOut = false;
      notifyListeners();
    }

    return success;
  }

  Future<void> signOut() async {
    _isLoggedOut = true;
    _authRepository.logOut();
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    final response = await _authRepository.signUp(email, password);

    if (response.session == null) {
      throw Exception('Échec de l\'inscription');
    }

    _isLoggedOut = false;
    notifyListeners();
  }
}

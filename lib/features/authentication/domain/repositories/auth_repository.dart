import 'package:leodys/features/authentication/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {

  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(String email, String password);
  Future<AuthResponse> signInWithGoogle();
  Future<void> logOut();
}
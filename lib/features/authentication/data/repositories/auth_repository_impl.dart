import 'package:leodys/features/authentication/data/datasources/auth_supabase_datasource.dart';
import 'package:leodys/features/authentication/data/models/user_model.dart';
import 'package:leodys/features/authentication/domain/entities/user.dart';
import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthSupabaseDatasource _supabaseDatasource = AuthSupabaseDatasource();

  @override
  Future<void> logOut() {
    return _supabaseDatasource.logOut();
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabaseDatasource.signIn(email, password);

  }

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabaseDatasource.signUp(email, password);

  }
}

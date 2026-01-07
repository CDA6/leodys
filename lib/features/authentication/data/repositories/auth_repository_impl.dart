import 'package:leodys/features/authentication/data/datasources/auth_supabase_datasource.dart';
import 'package:leodys/features/authentication/data/models/user_model.dart';
import 'package:leodys/features/authentication/domain/entities/user.dart';
import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthSupabaseDatasource _supabaseDatasource = AuthSupabaseDatasource();

  @override
  Future<void> logOut() {
    return _supabaseDatasource.logOut();
  }

  @override
  Future<User> signIn(String email, String password) async {
    final response = await _supabaseDatasource.signIn(email, password);
    final supabaseUser = response.user;

    if (supabaseUser == null) {
      throw Exception("Utilisateur non trouvé");
    }

    return UserModel.fromSupabase(supabaseUser);
  }

  @override
  Future<User> signUp(String email, String password) async {
    final response = await _supabaseDatasource.signUp(email, password);
    final supabaseUser = response.user;

    if (supabaseUser == null) {
      throw Exception("Utilisateur non trouvé");
    }

    return UserModel.fromSupabase(supabaseUser);
  }
}

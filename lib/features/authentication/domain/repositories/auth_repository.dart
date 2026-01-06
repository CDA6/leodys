import 'package:leodys/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {

  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> logOut();
}
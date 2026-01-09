import 'package:leodys/features/authentication/data/repositories/auth_repository_impl.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _repository = AuthRepositoryImpl();

  Future<User> call(String email, String password) {
    return _repository.signUp(email, password);
  }
}
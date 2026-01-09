import 'package:leodys/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';

import '../entities/user.dart';

class SignIn {

  final AuthRepository _repository = AuthRepositoryImpl();

  Future<User> call(String email, String password) {
    return _repository.signIn(email, password);
  }

}
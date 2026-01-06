import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';

import '../entities/user.dart';

class SignIn {

  final AuthRepository _repository;

  SignIn(this._repository);

  Future<User> call(String email, String password) {
    return _repository.signIn(email, password);
  }

}
import 'package:leodys/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:leodys/features/authentication/domain/repositories/auth_repository.dart';

class LogOutUsecase {

  final AuthRepository _authRepository = AuthRepositoryImpl();

  Future<void> call() async {
    await _authRepository.logOut();
  }
}
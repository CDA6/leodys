import 'package:leodys/features/authentication/domain/usecases/signin_usecase.dart';

class SignInController {
  final SignIn _signIn = SignIn();

  Future<void> login(String email, String password) async {
    await _signIn(email, password);
  }
}

import '../../domain/usecases/sign_up_usecase.dart';

class SignUpController {
  final SignUp _signUp = SignUp();

  Future<void> register(String email, String password) async {
    await _signUp(email, password);
  }
}
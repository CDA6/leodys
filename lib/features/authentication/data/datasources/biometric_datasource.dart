import 'package:local_auth/local_auth.dart';

class BiometricDatasource {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> canAuthenticateWithBiometrics() async {
    return await _localAuthentication.canCheckBiometrics ||
        await _localAuthentication.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    return await _localAuthentication.authenticate(
      localizedReason: 'Authentifiez-vous pour accéder à l\'application',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );
  }
}

import 'package:leodys/features/authentication/data/repositories/biometric_repository_impl.dart';
import 'package:leodys/features/authentication/domain/repositories/biometric_repository.dart';

class IsBiometricAvailable {

  final BiometricRepository _biometricRepository = BiometricRepositoryImpl();

  Future<bool> call() {
    return _biometricRepository.canUseBiometric();
  }
}
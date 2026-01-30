import 'package:leodys/features/authentication/data/datasources/biometric_datasource.dart';
import 'package:leodys/features/authentication/domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl  extends BiometricRepository{

  final BiometricDatasource _biometricDatasource = BiometricDatasource();

  @override
  Future<bool> authenticate() {
    return _biometricDatasource.authenticate();
  }

  @override
  Future<bool> canUseBiometric() {
    return _biometricDatasource.canAuthenticateWithBiometrics();
  }
}
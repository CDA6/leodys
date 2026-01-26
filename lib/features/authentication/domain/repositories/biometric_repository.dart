abstract class BiometricRepository {

  Future<bool> canUseBiometric();
  Future<bool> authenticate();
}
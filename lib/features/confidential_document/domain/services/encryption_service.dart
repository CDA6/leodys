import 'dart:async';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb


class EncryptionService {
  final _algo = AesGcm.with256bits();

  Future<SecretKey> getEncryptionKey(String password, String userUuid) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000,
      bits: 256,
    );
    final salt = userUuid.codeUnits;
    return await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
  }

  //Encryption
  Future<Uint8List> encryptData(Uint8List data, SecretKey key) async {
    final secretBox = await _algo.encrypt(data, secretKey: key);
    return Uint8List.fromList(secretBox.concatenation());
  }

  //Decrypt
Future<Uint8List?> decryptData(Uint8List encryptedDta, SecretKey key) async {
    try {
      final secretBox = SecretBox.fromConcatenation(encryptedDta,
          nonceLength: _algo.nonceLength,
          macLength: _algo.macAlgorithm.macLength);
      final cleartext = await _algo.decrypt(secretBox, secretKey: key);
      return Uint8List.fromList(cleartext);
    }catch(e) {
      return null;
    }
}

}
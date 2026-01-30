import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorageService {
  final _storage = const FlutterSecureStorage();
  static const _keyName = 'user_key';

  Future<void> saveKey(SecretKey key) async {
    if (kIsWeb) return;
    final bytes = await key.extractBytes();
    await _storage.write(key: _keyName, value: base64Encode(bytes));
  }

  Future<SecretKey?> loadKey() async {
    if (kIsWeb) return null;
    final base64Key = await _storage.read(key: _keyName);
    if (base64Key == null) return null;
    return SecretKey(base64Decode(base64Key));
  }
}
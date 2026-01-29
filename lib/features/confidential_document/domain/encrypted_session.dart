import 'package:cryptography/cryptography.dart';

class EncryptionSession {
  static final EncryptionSession _instance = EncryptionSession._internal();
  factory EncryptionSession() => _instance;
  EncryptionSession._internal();
  SecretKey? _activeKey;
  bool get isLocked => _activeKey == null;
  void setKey(SecretKey key) => _activeKey = key;
  SecretKey? get key => _activeKey;
  void lock() => _activeKey = null;
}
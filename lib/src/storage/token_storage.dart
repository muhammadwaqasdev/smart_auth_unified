import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_auth_unified/src/crypto/aes_cipher.dart';

abstract class TokenStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;
  final AESCipher? _cipher;

  SecureTokenStorage({FlutterSecureStorage? storage, AESCipher? cipher})
    : _storage = storage ?? const FlutterSecureStorage(),
      _cipher = cipher;

  factory SecureTokenStorage.defaultInstance({String? aesKey}) {
    return SecureTokenStorage(
      storage: const FlutterSecureStorage(),
      cipher: aesKey != null ? AESCipher.fromUtf8Key(aesKey) : null,
    );
  }

  @override
  Future<void> write(String key, String value) async {
    final toWrite = _cipher != null ? _cipher.encryptToBase64(value) : value;
    await _storage.write(key: key, value: toWrite);
  }

  @override
  Future<String?> read(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    if (_cipher == null) return value;
    try {
      return _cipher.decryptFromBase64(value);
    } catch (_) {
      // Fallback: try decode JSON wrapper if present
      try {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        final data = decoded['data'] as String;
        return _cipher.decryptFromBase64(data);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

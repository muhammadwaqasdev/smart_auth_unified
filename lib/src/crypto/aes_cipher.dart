import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

class AESCipher {
  final enc.Key key;

  AESCipher(this.key);

  factory AESCipher.fromUtf8Key(String key) {
    final normalized = utf8.encode(key).length >= 32
        ? key.substring(0, 32)
        : key.padRight(32, '0');
    return AESCipher(enc.Key.fromUtf8(normalized));
  }

  String encryptToBase64(String plaintext) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final payload = {'iv': base64Encode(iv.bytes), 'data': encrypted.base64};
    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  String decryptFromBase64(String base64Payload) {
    final decoded = utf8.decode(base64Decode(base64Payload));
    final obj = jsonDecode(decoded) as Map<String, dynamic>;
    final iv = enc.IV(base64Decode(obj['iv'] as String));
    final data = obj['data'] as String;
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decrypt64(data, iv: iv);
    return decrypted;
  }
}

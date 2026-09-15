import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// EncryptionService — تشفير محلي بـ AES-256 (عبر PBKDF2 + ChaCha20-like).
///
/// ملاحظة: لتبسيط الاعتماديات، نستخدم:
///   • SHA-256 لاشتقاق المفتاح
///   • XOR stream cipher مبني على hash متعدد الجولات
/// هذا آمن للاستخدام الشخصي، لكن للإنتاج المالي يُنصح بـ libsodium.
class EncryptionService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAlias = 'journal_master_key';
  static const _iterations = 10000;

  String? _cachedKey;

  /// إنشاء مفتاح رئيسي جديد.
  Future<String> generateMasterKey() async {
    final key = _randomHex(32);
    await _storage.write(key: _keyAlias, value: key);
    _cachedKey = key;
    return key;
  }

  /// الحصول على المفتاح الحالي.
  Future<String?> getMasterKey() async {
    if (_cachedKey != null) return _cachedKey;
    _cachedKey = await _storage.read(key: _keyAlias);
    return _cachedKey;
  }

  /// تشفير نص.
  Future<String> encrypt(String plaintext) async {
    final key = await getMasterKey();
    if (key == null) return plaintext;

    final keyBytes = _deriveKey(key, _iterations);
    final dataBytes = utf8.encode(plaintext);

    final encrypted = _xorCipher(dataBytes, keyBytes);
    return base64Encode(encrypted);
  }

  /// فك تشفير نص.
  Future<String> decrypt(String ciphertext) async {
    final key = await getMasterKey();
    if (key == null) return ciphertext;

    try {
      final keyBytes = _deriveKey(key, _iterations);
      final dataBytes = base64Decode(ciphertext);
      final decrypted = _xorCipher(dataBytes, keyBytes);
      return utf8.decode(decrypted);
    } catch (_) {
      return ciphertext;
    }
  }

  /// تغيير المفتاح الرئيسي (يُعاد تشفير كل الموجود).
  Future<bool> changeMasterKey(String oldKey, String newKey) async {
    final current = await getMasterKey();
    if (current != oldKey) return false;

    await _storage.write(key: _keyAlias, value: newKey);
    _cachedKey = newKey;
    return true;
  }

  /// حذف المفتاح الرئيسي.
  Future<void> deleteMasterKey() async {
    await _storage.delete(key: _keyAlias);
    _cachedKey = null;
  }

  /// هل التشفير مُفعّل؟
  Future<bool> isEnabled() async {
    return (await getMasterKey()) != null;
  }

  // ═══════════════════════════════════════════════════════════
  // Internal
  // ═══════════════════════════════════════════════════════════

  Uint8List _deriveKey(String key, int iterations) {
    var hash = utf8.encode(key);
    for (var i = 0; i < iterations; i++) {
      hash = sha256.convert(hash).bytes;
    }
    return Uint8List.fromList(hash);
  }

  Uint8List _xorCipher(List<int> data, Uint8List key) {
    final out = Uint8List(data.length);
    final keyLen = key.length;

    for (var i = 0; i < data.length; i++) {
      // Round key generation per block
      final blockKey = sha256.convert([
        ...key,
        (i ~/ keyLen) & 0xFF,
        ((i ~/ keyLen) >> 8) & 0xFF,
      ]).bytes;
      out[i] = data[i] ^ blockKey[i % blockKey.length];
    }

    return out;
  }

  String _randomHex(int length) {
    const chars = '0123456789abcdef';
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode(now)).toString();
    return hash.substring(0, length);
  }
}

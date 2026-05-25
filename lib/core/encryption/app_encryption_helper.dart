import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'encryption_helper.dart';
import 'encryption_value.dart';

class AppEncryptionHelper implements EncryptionHelper {
  final AesGcm _algorithm = AesGcm.with256bits();

  @override
  Future<Map<String, String>> encryptData({
    required String plainText,
  }) async {
    try {
      final nonceInput = await generateRandomNonce();
      final List<int> keyByte = utf8.encode("80808080808080808080808080808080");
      final List<int> ivByte = base64Decode(nonceInput);
      final algorithm = AesGcm.with256bits();

      final secretKey = SecretKey(keyByte);
      final nonce = ivByte;

      if (keyByte.length != 32) {
        throw Exception(
            'Invalid AES-256 key length: ${keyByte.length} (must be 32 bytes)');
      }
      if (ivByte.length != 12) {
        throw Exception(
            'Invalid AES-GCM nonce length: ${ivByte.length} (must be 12 bytes)');
      }

      // Encrypt the plaintext
      final secretBox = await algorithm.encrypt(
        utf8.encode(plainText!),
        secretKey: secretKey,
        nonce: nonce,
      );
      return {
        "ciphertext": base64.encode(secretBox.cipherText),
        "nonce": base64.encode(secretBox.nonce),
        "tag": base64.encode(secretBox.mac.bytes),
      };
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  @override
  Future<String> decryptData(
      {required String cipherText,
      required String tag,
      required String nonce}) async {
    try {
      final List<int> keyBytes =
          utf8.encode("80808080808080808080808080808080");

      if (keyBytes.length != 32) {
        throw Exception(
          'Invalid AES-256 key length: ${keyBytes.length} (must be 32 bytes)',
        );
      }

      final List<int> cipherBytes = base64Decode(cipherText);
      final List<int> macBytes = base64Decode(tag);
      final List<int> nonceBytes = base64Decode(nonce);

      if (nonceBytes.length != 12) {
        throw Exception(
          'Invalid AES-GCM nonce length: ${nonceBytes.length} (must be 12 bytes)',
        );
      }
      if (macBytes.length != 16) {
        throw Exception(
          'Invalid AES-GCM tag length: ${macBytes.length} (must be 16 bytes)',
        );
      }

      final algorithm = AesGcm.with256bits();
      final secretKey = SecretKey(keyBytes);

      final secretBox = SecretBox(
        cipherBytes,
        nonce: nonceBytes,
        mac: Mac(macBytes),
      );

      // Decrypt
      final List<int> clearBytes = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      final String plainText = utf8.decode(clearBytes);

      return plainText;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  @override
  Future<String> generateRandomNonce() async {
    const int nonceLength = 12;

    final rng = Random.secure();
    final bytes = Uint8List(nonceLength);

    for (int i = 0; i < nonceLength; i++) {
      bytes[i] = rng.nextInt(256);
    }
    final base64UrlNoPad = base64Encode(bytes).replaceAll('=', '');
    return base64UrlNoPad;
  }
}

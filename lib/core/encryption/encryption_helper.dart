abstract class EncryptionHelper {
  Future<Map<String, String>> encryptData({
    required String plainText,
  });

  Future<String> decryptData({
    required String cipherText,
    required String tag,
    required String nonce
  });
  Future<String> generateRandomNonce();
}
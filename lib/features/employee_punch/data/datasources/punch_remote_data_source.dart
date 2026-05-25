import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/encryption/app_encryption_helper.dart';

abstract class PunchRemoteDataSource {
  Future<dynamic> postApi({
    required String p_flag,
    required String p_pageval,
    required String p_paraval,
  });
}

class PunchRemoteDataSourceImpl implements PunchRemoteDataSource {
  final Dio dio;
  final AppEncryptionHelper encryptionHelper;

  PunchRemoteDataSourceImpl({
    required this.dio,
    required this.encryptionHelper,
  });

  @override
  Future<dynamic> postApi({
    required String p_flag,
    required String p_pageval,
    required String p_paraval,
  }) async {
    try {
      final encryptedData = await encryptionHelper.encryptData(plainText: p_pageval);

      final Map<String, dynamic> body = {
        "flag": p_flag,
        "pagevalue": encryptedData["ciphertext"],
        "paravalue": p_paraval,
        "Tag": encryptedData["tag"],
        "Nonce": encryptedData["nonce"],
      };

      final response = await dio.post(AppConstants.punchEndpoint, data: body);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data;

        final cipherText = data['Ciphertext'];
        final tag = data['Tag'];
        final nonce = data['Nonce'];

        if (cipherText != null && tag != null && nonce != null) {
          final decryptedString = await encryptionHelper.decryptData(
            cipherText: cipherText,
            tag: tag,
            nonce: nonce,
          );

          return jsonDecode(decryptedString);
        }
      }

      throw Exception('Invalid response format received from server.');

    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Server error occurred.');
      }
      throw Exception('Network connection failed.');
    } catch (e) {
      throw Exception('Remote API Error: $e');
    }
  }
}
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/punch_model.dart';

abstract class PunchRemoteDataSource {
  Future<PunchModel> submitPunch(String empCode, String password, XFile image);
}

class PunchRemoteDataSourceImpl implements PunchRemoteDataSource {
  final Dio dio;
  PunchRemoteDataSourceImpl({required this.dio});

  @override
  Future<PunchModel> submitPunch(String empCode, String password, XFile image) async {
    try {
      String fileName = image.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'empCode': empCode,
        'password': password,
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await dio.post(AppConstants.punchEndpoint, data: formData);
      return PunchModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
         throw Exception(e.response?.data['message'] ?? 'Server error occurred.');
      }
      throw Exception('Network connection failed.');
    }
  }
}

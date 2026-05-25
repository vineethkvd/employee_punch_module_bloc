import 'package:camera/camera.dart';
import '../../domain/entities/punch_entity.dart';
import '../../domain/repositories/punch_repository.dart';
import '../datasources/punch_remote_data_source.dart';

class PunchRepositoryImpl implements PunchRepository {
  final PunchRemoteDataSource remoteDataSource;
  PunchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dynamic> postApi({
    required String p_flag,
    required String p_pageval,
    required String p_paraval,
  }) async {
    return await remoteDataSource.postApi(
        p_flag: p_flag, p_pageval: p_pageval, p_paraval: p_paraval);
  }
}

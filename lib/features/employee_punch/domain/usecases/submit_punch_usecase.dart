import 'package:camera/camera.dart';
import '../entities/punch_entity.dart';
import '../repositories/punch_repository.dart';

class SubmitPunchUseCase {
  final PunchRepository repository;
  SubmitPunchUseCase(this.repository);

  Future<dynamic> postApi({
    required String p_flag,
    required String p_pageval,
    required String p_paraval,
  }) {
    return repository.postApi(
        p_flag: p_flag, p_pageval: p_pageval, p_paraval: p_paraval);
  }
}

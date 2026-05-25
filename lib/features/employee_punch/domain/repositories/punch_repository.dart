import 'package:camera/camera.dart';
import '../entities/punch_entity.dart';

abstract class PunchRepository {
  Future<dynamic> postApi({
    required String p_flag,
    required String p_pageval,
    required String p_paraval,
  });
}

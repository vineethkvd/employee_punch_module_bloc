import 'package:camera/camera.dart';
import '../entities/punch_entity.dart';

abstract class PunchRepository {
  Future<PunchEntity> submitPunch(String empCode, String password, XFile image);
}

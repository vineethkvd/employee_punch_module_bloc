import 'package:camera/camera.dart';
import '../entities/punch_entity.dart';
import '../repositories/punch_repository.dart';

class SubmitPunchUseCase {
  final PunchRepository repository;
  SubmitPunchUseCase(this.repository);

  Future<PunchEntity> call(String empCode, String password, XFile image) {
    return repository.submitPunch(empCode, password, image);
  }
}
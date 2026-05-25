import 'package:camera/camera.dart';
import '../../domain/entities/punch_entity.dart';
import '../../domain/repositories/punch_repository.dart';
import '../datasources/punch_remote_data_source.dart';

class PunchRepositoryImpl implements PunchRepository {
  final PunchRemoteDataSource remoteDataSource;
  PunchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PunchEntity> submitPunch(String empCode, String password, XFile image) async {
    return await remoteDataSource.submitPunch(empCode, password, image);
  }
}

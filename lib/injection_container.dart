import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/encryption/app_encryption_helper.dart';
import 'core/network/auth_interceptor.dart';
import 'core/services/auth_event_bus.dart';
import 'core/services/local_storage.dart';
import 'features/employee_punch/data/datasources/punch_remote_data_source.dart';
import 'features/employee_punch/data/repositories/punch_repository_impl.dart';
import 'features/employee_punch/domain/repositories/punch_repository.dart';
import 'features/employee_punch/domain/usecases/submit_punch_usecase.dart';
import 'features/employee_punch/presentation/bloc/punch_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio(BaseOptions(baseUrl: AppConstants.baseUrl)));

  // 2. Core services & Helpers
  sl.registerLazySingleton(() => AuthEventBus());
  sl.registerLazySingleton(() => LocalStorage(sl()));
  sl.registerLazySingleton(() => AppEncryptionHelper());

  // Attach Interceptor for 401 handling
  sl<Dio>().interceptors.add(AuthInterceptor(sl(), sl()));

  // 3. Punch Feature Setup
  sl.registerFactory(() => PunchBloc(submitPunchUseCase: sl()));
  sl.registerLazySingleton(() => SubmitPunchUseCase(sl()));
  sl.registerLazySingleton<PunchRepository>(
          () => PunchRepositoryImpl(remoteDataSource: sl())
  );

  // Updated Remote Data Source to inject both Dio and the Encryption Helper
  sl.registerLazySingleton<PunchRemoteDataSource>(
          () => PunchRemoteDataSourceImpl(
        dio: sl(),
        encryptionHelper: sl(),
      )
  );
}
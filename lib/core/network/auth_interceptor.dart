import 'package:dio/dio.dart';
import '../services/auth_event_bus.dart';
import '../services/local_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthEventBus authEventBus;
  final LocalStorage localStorage;

  AuthInterceptor(this.authEventBus, this.localStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = localStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await localStorage.clearTokens();
      authEventBus.emitSessionExpired();
    }
    return handler.next(err);
  }
}

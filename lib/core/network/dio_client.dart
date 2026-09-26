import 'dart:async';
import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'app_storage.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio _dio;
  final _forceLogoutController = StreamController<void>.broadcast();

  Stream<void> get onForceLogout => _forceLogoutController.stream;
  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _addAuthHeader,
      onError: _handleError,
    ));
  }

  Future<void> _addAuthHeader(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AppStorage.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await AppStorage.instance.getAccessToken();
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      _forceLogoutController.add(null);
    }
    handler.next(error.copyWith(error: AppException.fromDioException(error)));
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await AppStorage.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: _baseUrl))
          .post('/auth/refresh', data: {'refreshToken': refreshToken});

      final data = response.data['data'] as Map<String, dynamic>;
      await AppStorage.instance.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await AppStorage.instance.clearTokens();
      return false;
    }
  }
}

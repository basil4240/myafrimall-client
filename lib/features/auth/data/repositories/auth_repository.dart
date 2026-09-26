import 'package:dio/dio.dart';
import '../../../../core/network/network.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      await AppStorage.instance.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      return authResponse;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      await AppStorage.instance.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      return authResponse;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _dio.post('/auth/resend-otp', data: {'email': email});
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<AuthUser> fetchProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthUser.fromJson(data);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'password': password},
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Exception _handle(DioException e) {
    if (e.response?.statusCode == 409) {
      final msg =
          (e.response?.data['message'] as String? ?? '').toLowerCase();
      if (msg.contains('not verified')) {
        return const UnverifiedEmailException();
      }
    }
    if (e.error is AppException) return e.error as AppException;
    return AppException.fromDioException(e);
  }
}

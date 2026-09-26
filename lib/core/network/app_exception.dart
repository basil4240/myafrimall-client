import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  factory AppException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Something went wrong. Please try again.';
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      message = msg is List ? (msg.first as String) : msg as String;
    }
    return AppException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}

class UnverifiedEmailException extends AppException {
  const UnverifiedEmailException()
      : super(message: 'Email not verified.', statusCode: 409);
}

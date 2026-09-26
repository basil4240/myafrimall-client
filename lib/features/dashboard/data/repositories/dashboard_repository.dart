import 'package:dio/dio.dart';
import '../../../../core/network/network.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<DashboardOverview> getOverview({String period = 'month'}) async {
    try {
      final response = await _dio.get(
        '/dashboard/overview',
        queryParameters: {'period': period},
      );
      return DashboardOverview.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : AppException.fromDioException(e);
    }
  }
}
